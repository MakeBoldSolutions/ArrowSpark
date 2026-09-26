#!/usr/bin/env bash
# BSW.DevSpark - (c) 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com
# Next-step router context script.
# Detects the current lifecycle state locally (git + filesystem, best-effort gh)
# and recommends the single next DevSpark command to run.

set -u

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

JSON_MODE=false
for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
    esac
done

REPO_ROOT=$(get_repo_root)
CURRENT_BRANCH=$(get_current_branch)
ASSISTANT_NAME=$(get_assistant_name)
GIT_USER=$(get_git_user)

# Orientation facts ("where am I"): repo name + host platform, from config or remote.
REPO_NAME=$(get_devspark_config_value '.repository')
[[ -z "$REPO_NAME" ]] && REPO_NAME=$(basename "$REPO_ROOT")
PLATFORM=$(get_devspark_config_value '.platform')
if [[ -z "$PLATFORM" ]]; then
    PLATFORM="unknown"
    remote_url=$(git remote get-url origin 2>/dev/null || true)
    if [[ "$remote_url" == *dev.azure.com* || "$remote_url" == *visualstudio.com* ]]; then PLATFORM="azdo"
    elif [[ "$remote_url" == *github.com* ]]; then PLATFORM="github"
    elif [[ "$remote_url" == *gitlab* ]]; then PLATFORM="gitlab"
    fi
fi

HAS_GIT="false"
if has_git; then HAS_GIT="true"; fi

CONSTITUTION_PATH="$REPO_ROOT/.knowledge/governance/constitution.md"
CONSTITUTION_EXISTS="false"
[[ -f "$CONSTITUTION_PATH" ]] && CONSTITUTION_EXISTS="true"

# Default (target) branch detection
DEFAULT_BRANCH="main"
if [[ "$HAS_GIT" == "true" ]]; then
    HEAD_REF=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || echo "")
    if [[ -n "$HEAD_REF" ]]; then
        DEFAULT_BRANCH="${HEAD_REF#origin/}"
    elif git show-ref --verify --quiet refs/heads/master 2>/dev/null; then
        DEFAULT_BRANCH="master"
    fi
fi

IS_DEFAULT_BRANCH="false"
if [[ "$CURRENT_BRANCH" == "$DEFAULT_BRANCH" || "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
    IS_DEFAULT_BRANCH="true"
fi

# Git state
DIRTY="false"
HAS_REMOTE="false"
BRANCH_PUSHED="false"
BEHIND_TARGET="false"
if [[ "$HAS_GIT" == "true" ]]; then
    [[ -n "$(git status --porcelain 2>/dev/null)" ]] && DIRTY="true"
    [[ -n "$(git remote 2>/dev/null)" ]] && HAS_REMOTE="true"
    if [[ "$HAS_REMOTE" == "true" ]]; then
        if git rev-parse --verify --quiet "refs/remotes/origin/$CURRENT_BRANCH" >/dev/null 2>&1; then
            BRANCH_PUSHED="true"
        fi
        BEHIND_COUNT=$(git rev-list --count "HEAD..origin/$DEFAULT_BRANCH" 2>/dev/null || echo "0")
        [[ "$BEHIND_COUNT" =~ ^[0-9]+$ && "$BEHIND_COUNT" -gt 0 ]] && BEHIND_TARGET="true"
    fi
fi

# Spec / quickfix detection for the current branch
SPEC_DIR="$REPO_ROOT/.devspark.work/specs/$CURRENT_BRANCH"
SPEC_EXISTS="false"
[[ -f "$SPEC_DIR/spec.md" ]] && SPEC_EXISTS="true"

# Spec authoring sub-state (plan -> tasks -> analyze -> critic -> implement -> verify)
PLAN_EXISTS="false"
TASKS_EXISTS="false"
TASKS_TOTAL=0
TASKS_DONE=0
TASKS_COMPLETE="false"
CLASSIFICATION=""
SPEC_STATUS=""
IS_FULL_SPEC="false"
REQUIRE_ANALYZE="false"
REQUIRE_CRITIC="false"
REQUIRE_CHECKLIST="false"
ANALYZE_GATE="false"
CRITIC_GATE="false"
CHECKLIST_GATE="false"
VERIFY_REQUIRED="false"
VERIFY_PASSED="false"
if [[ "$SPEC_EXISTS" == "true" ]]; then
    [[ -f "$SPEC_DIR/plan.md" ]] && PLAN_EXISTS="true"
    if [[ -f "$SPEC_DIR/tasks.md" ]]; then
        TASKS_EXISTS="true"
        TASKS_TOTAL=$(grep -cE '^[[:space:]]*[-*][[:space:]]*\[[ xX]\]' "$SPEC_DIR/tasks.md" 2>/dev/null)
        TASKS_DONE=$(grep -cE '^[[:space:]]*[-*][[:space:]]*\[[xX]\]' "$SPEC_DIR/tasks.md" 2>/dev/null)
        [[ -z "$TASKS_TOTAL" ]] && TASKS_TOTAL=0
        [[ -z "$TASKS_DONE" ]] && TASKS_DONE=0
        if [[ "$TASKS_TOTAL" -gt 0 && "$TASKS_DONE" -ge "$TASKS_TOTAL" ]]; then TASKS_COMPLETE="true"; fi
    fi
    CLASSIFICATION=$(grep -m1 -E '^classification:' "$SPEC_DIR/spec.md" 2>/dev/null | sed -E 's/^classification:[[:space:]]*//; s/[[:space:]]*$//')
    SPEC_STATUS=$(grep -m1 -E '^\*\*Status\*\*:' "$SPEC_DIR/spec.md" 2>/dev/null | sed -E 's/^\*\*Status\*\*:[[:space:]]*//; s/[[:space:]]*<!--.*//; s/[[:space:]]*$//')
    REQ_GATES=$(grep -m1 -E '^required_gates:' "$SPEC_DIR/spec.md" 2>/dev/null || echo "")
    [[ "$REQ_GATES" == *"verify:"* ]] && VERIFY_REQUIRED="true"
    [[ "$REQ_GATES" == *"analyze"* ]] && REQUIRE_ANALYZE="true"
    [[ "$REQ_GATES" == *"critic"* ]] && REQUIRE_CRITIC="true"
    [[ "$REQ_GATES" == *"checklist"* ]] && REQUIRE_CHECKLIST="true"
    if [[ "$CLASSIFICATION" == *"full-spec"* ]]; then
        IS_FULL_SPEC="true"
    elif [[ -z "$CLASSIFICATION" && ( "$PLAN_EXISTS" == "true" || "$TASKS_EXISTS" == "true" ) ]]; then
        IS_FULL_SPEC="true"
    fi
    [[ -f "$SPEC_DIR/gates/analyze.md" ]] && ANALYZE_GATE="true"
    [[ -f "$SPEC_DIR/gates/critic.md" ]] && CRITIC_GATE="true"
    [[ -f "$SPEC_DIR/gates/checklist.md" ]] && CHECKLIST_GATE="true"
    if [[ -f "$SPEC_DIR/gates/verify.md" ]] && grep -qE '^status:[[:space:]]*pass' "$SPEC_DIR/gates/verify.md" 2>/dev/null; then VERIFY_PASSED="true"; fi
fi

# Advisory gates that are required but whose artifact is missing/unmet (never block progress)
PENDING_GATES=""
if [[ "$SPEC_EXISTS" == "true" ]]; then
    [[ "$REQUIRE_CHECKLIST" == "true" && "$CHECKLIST_GATE" == "false" ]] && PENDING_GATES="${PENDING_GATES:+$PENDING_GATES, }checklist"
    [[ "$REQUIRE_ANALYZE" == "true" && "$ANALYZE_GATE" == "false" ]] && PENDING_GATES="${PENDING_GATES:+$PENDING_GATES, }analyze"
    [[ "$REQUIRE_CRITIC" == "true" && "$CRITIC_GATE" == "false" ]] && PENDING_GATES="${PENDING_GATES:+$PENDING_GATES, }critic"
    [[ "$VERIFY_REQUIRED" == "true" && "$VERIFY_PASSED" == "false" ]] && PENDING_GATES="${PENDING_GATES:+$PENDING_GATES, }verify"
fi

QUICKFIX_EXISTS="false"
QUICKFIX_COMPLETE="false"
if [[ "$CURRENT_BRANCH" =~ ^QF- || "$CURRENT_BRANCH" =~ ^[0-9][0-9][0-9]-fix- ]]; then
    QUICKFIX_RECORD="$REPO_ROOT/.devspark.work/quickfixes/$CURRENT_BRANCH.md"
    if [[ -f "$QUICKFIX_RECORD" ]]; then
        QUICKFIX_EXISTS="true"
        if grep -qE '^[[:space:]]*-[[:space:]]*\*\*Completed\*\*:[[:space:]]*[^[:space:]]' "$QUICKFIX_RECORD" 2>/dev/null; then QUICKFIX_COMPLETE="true"; fi
    fi
fi

# Best-effort PR + review detection (platform-aware)
PR_EXISTS="false"
PR_NUMBER=""
PR_STATE=""
if [[ "$HAS_GIT" == "true" ]]; then
    if [[ "$PLATFORM" == "azdo" ]] && command -v az >/dev/null 2>&1; then
        IFS=$'\t' read -r NAZ_ORG NAZ_PROJ NAZ_REPO < <(get_azdo_repo_context)
        AZ_PR_JSON=$(az repos pr list --organization "https://dev.azure.com/$NAZ_ORG" --project "$NAZ_PROJ" --repository "$NAZ_REPO" --source-branch "$CURRENT_BRANCH" --status active --top 1 --output json 2>/dev/null | jq '.[0] // {}' 2>/dev/null || echo '{}')
        PR_NUMBER=$(echo "$AZ_PR_JSON" | jq -r '.pullRequestId // empty')
        PR_STATE=$(echo "$AZ_PR_JSON" | jq -r '.status // empty')
        [[ -n "$PR_NUMBER" ]] && PR_EXISTS="true"
    elif command -v gh >/dev/null 2>&1; then
        PR_JSON=$(gh pr view --json number,state 2>/dev/null || echo "")
        if [[ -n "$PR_JSON" ]]; then
            PR_NUMBER=$(echo "$PR_JSON" | jq -r '.number // empty' 2>/dev/null || echo "")
            PR_STATE=$(echo "$PR_JSON" | jq -r '.state // empty' 2>/dev/null || echo "")
            [[ -n "$PR_NUMBER" ]] && PR_EXISTS="true"
        fi
    fi
fi

REVIEW_FILE_EXISTS="false"
REVIEW_OPEN="false"
REVIEW_DIR="$REPO_ROOT/.devspark.work/pr-review"
if [[ -d "$REVIEW_DIR" ]]; then
    REVIEW_FILE=""
    if [[ -n "$PR_NUMBER" && -f "$REVIEW_DIR/pr-$PR_NUMBER.md" ]]; then
        REVIEW_FILE="$REVIEW_DIR/pr-$PR_NUMBER.md"
    else
        REVIEW_FILE=$(ls -t "$REVIEW_DIR"/pr-*.md 2>/dev/null | head -1 || echo "")
    fi
    if [[ -n "$REVIEW_FILE" && -f "$REVIEW_FILE" ]]; then
        REVIEW_FILE_EXISTS="true"
        grep -q "Open" "$REVIEW_FILE" 2>/dev/null && REVIEW_OPEN="true"
    fi
fi

# ---- Recommendation ladder ----
RECOMMENDED="/devspark.specify"
STATE="unknown"
REASON="Describe the work to /devspark.specify and it will route you."

if [[ "$CONSTITUTION_EXISTS" == "false" ]]; then
    RECOMMENDED="/devspark.constitution"
    STATE="no-constitution"
    REASON="No project constitution found. Create your principles first so every command has a validation baseline."
elif [[ "$IS_DEFAULT_BRANCH" == "true" && "$SPEC_EXISTS" == "false" && "$QUICKFIX_EXISTS" == "false" ]]; then
    RECOMMENDED="/devspark.specify"
    STATE="no-active-work"
    REASON="You're on '$CURRENT_BRANCH' with no active spec or quickfix. Start with /devspark.specify (unsure of size) or /devspark.quickfix (small, contained fix)."
elif [[ "$SPEC_EXISTS" == "true" && "$IS_FULL_SPEC" == "true" && "$PLAN_EXISTS" == "false" ]]; then
    RECOMMENDED="/devspark.plan"
    STATE="spec-needs-plan"
    REASON="Spec exists for '$CURRENT_BRANCH' but there's no plan yet. Run /devspark.plan to produce the technical design."
elif [[ "$SPEC_EXISTS" == "true" && "$IS_FULL_SPEC" == "true" && "$PLAN_EXISTS" == "true" && "$TASKS_EXISTS" == "false" ]]; then
    RECOMMENDED="/devspark.tasks"
    STATE="plan-needs-tasks"
    REASON="Plan exists but there's no task breakdown. Run /devspark.tasks to generate the ordered task list."
elif [[ "$SPEC_EXISTS" == "true" && "$IS_FULL_SPEC" == "true" && "$TASKS_EXISTS" == "true" && "$TASKS_DONE" -eq 0 && "$REQUIRE_ANALYZE" == "true" && "$ANALYZE_GATE" == "false" ]]; then
    RECOMMENDED="/devspark.analyze"
    STATE="tasks-need-analyze"
    REASON="Tasks are ready and this full-spec route requires an analysis gate. Run /devspark.analyze to check spec/plan/tasks consistency before implementing."
elif [[ "$SPEC_EXISTS" == "true" && "$IS_FULL_SPEC" == "true" && "$TASKS_EXISTS" == "true" && "$TASKS_DONE" -eq 0 && "$REQUIRE_CRITIC" == "true" && "$CRITIC_GATE" == "false" ]]; then
    RECOMMENDED="/devspark.critic"
    STATE="tasks-need-critic"
    REASON="Analysis is done and this full-spec route requires a risk review. Run /devspark.critic for an adversarial pre-mortem before implementing."
elif [[ "$SPEC_EXISTS" == "true" && "$IS_FULL_SPEC" == "true" && "$TASKS_EXISTS" == "true" && "$TASKS_COMPLETE" == "false" ]]; then
    RECOMMENDED="/devspark.implement"
    STATE="tasks-incomplete"
    REASON="Tasks are defined ($TASKS_DONE/$TASKS_TOTAL complete) but not finished. Run /devspark.implement to execute the remaining tasks."
elif [[ "$SPEC_EXISTS" == "true" && "$IS_FULL_SPEC" == "true" && "$TASKS_COMPLETE" == "true" ]]; then
    RECOMMENDED="/devspark.implement"
    STATE="implementation-needs-finalization"
    REASON="The task list is complete but the temporary planning bundle still exists. Run /devspark.implement to verify code, tests, and current knowledge, then delete the bundle."
elif [[ "$SPEC_EXISTS" == "true" && "$IS_FULL_SPEC" == "false" ]]; then
    RECOMMENDED="/devspark.implement"
    STATE="quickspec-needs-implement"
    REASON="A temporary quick-spec exists for '$CURRENT_BRANCH' (Status: ${SPEC_STATUS:-Draft}). Run /devspark.implement to finish its action plan, verify the durable result, and delete the bundle."
elif [[ "$QUICKFIX_EXISTS" == "true" && "$PR_EXISTS" == "false" ]]; then
    RECOMMENDED="/devspark.implement"
    STATE="quickfix-open"
    REASON="A temporary quickfix record exists for '$CURRENT_BRANCH'. Run /devspark.implement to finish the change, verify code, tests, and current knowledge, and delete the record."
elif [[ "$DIRTY" == "true" ]]; then
    RECOMMENDED="commit"
    STATE="uncommitted-changes"
    REASON="You have uncommitted changes on '$CURRENT_BRANCH'. Commit your work (then re-run /devspark.next). If this is a spec route mid-implementation, continue with /devspark.implement."
elif [[ "$PR_EXISTS" == "false" ]]; then
    RECOMMENDED="/devspark.create-pr"
    STATE="ready-for-pr"
    REASON="Work is committed on '$CURRENT_BRANCH' and no PR exists yet. Open one with /devspark.create-pr (it will publish the branch and let you optionally run /devspark.verify)."
elif [[ "$PR_EXISTS" == "true" && "$REVIEW_FILE_EXISTS" == "false" ]]; then
    RECOMMENDED="/devspark.pr-review"
    STATE="pr-needs-review"
    REASON="PR #$PR_NUMBER is open but has no review yet. Run /devspark.pr-review to review it against the constitution."
elif [[ "$REVIEW_FILE_EXISTS" == "true" && "$REVIEW_OPEN" == "true" ]]; then
    RECOMMENDED="/devspark.address-pr-review"
    STATE="review-has-open-findings"
    REASON="PR #$PR_NUMBER has open review findings. Run /devspark.address-pr-review to fix them, then re-review with /devspark.pr-review #$PR_NUMBER re-review."
elif [[ "$REVIEW_FILE_EXISTS" == "true" && "$BEHIND_TARGET" == "true" ]]; then
    RECOMMENDED="sync"
    STATE="behind-target"
    REASON="Review looks clear but '$CURRENT_BRANCH' is behind '$DEFAULT_BRANCH'. Sync it (merge origin/$DEFAULT_BRANCH in) before merging the PR."
elif [[ "$REVIEW_FILE_EXISTS" == "true" ]]; then
    RECOMMENDED="merge"
    STATE="ready-to-merge"
    REASON="PR #$PR_NUMBER is reviewed and the branch is in sync. Approve and merge it in your Git portal (GitHub / Azure DevOps)."
fi

# Surface still-open advisory gates without blocking the primary recommendation.
if [[ -n "$PENDING_GATES" && ! "$RECOMMENDED" =~ (analyze|critic|checklist|verify|constitution) ]]; then
    REASON="$REASON Open advisory gates still recommended before merge: $PENDING_GATES."
fi

if [[ "$JSON_MODE" == true ]]; then
    cat <<EOF
{
  "REPO_ROOT": "$REPO_ROOT",
  "REPO_NAME": "$REPO_NAME",
  "PLATFORM": "$PLATFORM",
  "ASSISTANT_NAME": "$ASSISTANT_NAME",
  "GIT_USER": "$GIT_USER",
  "HAS_GIT": $HAS_GIT,
  "CONSTITUTION_EXISTS": $CONSTITUTION_EXISTS,
  "CURRENT_BRANCH": "$CURRENT_BRANCH",
  "DEFAULT_BRANCH": "$DEFAULT_BRANCH",
  "IS_DEFAULT_BRANCH": $IS_DEFAULT_BRANCH,
  "DIRTY": $DIRTY,
  "HAS_REMOTE": $HAS_REMOTE,
  "BRANCH_PUSHED": $BRANCH_PUSHED,
  "BEHIND_TARGET": $BEHIND_TARGET,
  "SPEC_EXISTS": $SPEC_EXISTS,
  "IS_FULL_SPEC": $IS_FULL_SPEC,
  "SPEC_STATUS": "$SPEC_STATUS",
  "PLAN_EXISTS": $PLAN_EXISTS,
  "TASKS_EXISTS": $TASKS_EXISTS,
  "TASKS_TOTAL": $TASKS_TOTAL,
  "TASKS_DONE": $TASKS_DONE,
  "TASKS_COMPLETE": $TASKS_COMPLETE,
  "VERIFY_REQUIRED": $VERIFY_REQUIRED,
  "VERIFY_PASSED": $VERIFY_PASSED,
  "PENDING_GATES": $(echo "$PENDING_GATES" | jq -R -s '.' 2>/dev/null || echo '""'),
  "QUICKFIX_EXISTS": $QUICKFIX_EXISTS,
  "QUICKFIX_COMPLETE": $QUICKFIX_COMPLETE,
  "PR_EXISTS": $PR_EXISTS,
  "PR_NUMBER": "$PR_NUMBER",
  "PR_STATE": "$PR_STATE",
  "REVIEW_FILE_EXISTS": $REVIEW_FILE_EXISTS,
  "REVIEW_OPEN": $REVIEW_OPEN,
  "RECOMMENDED_COMMAND": "$RECOMMENDED",
  "STATE": "$STATE",
  "REASON": $(echo "$REASON" | jq -R -s '.')
}
EOF
else
    echo "Next-Step Router"
    echo "================"
    echo "Assistant: $ASSISTANT_NAME"
    echo "Repo: $REPO_NAME ($PLATFORM)"
    echo "Branch: $CURRENT_BRANCH (default: $DEFAULT_BRANCH)"
    echo "State: $STATE"
    echo "Recommended: $RECOMMENDED"
    echo "Reason: $REASON"
fi
