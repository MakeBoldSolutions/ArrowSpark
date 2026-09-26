---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
description: Draft or update a pull request from the verified code, knowledge, tests, and Git delta.
handoffs:
  - label: Run Verification (optional)
    agent: devspark.verify
    prompt: Produce proof-of-change evidence before opening the PR
  - label: Review Pull Request
    agent: devspark.pr-review
    prompt: Review the pull request for constitution compliance
scripts:
  sh: .devspark/scripts/bash/create-pr.sh --mode preflight --json $ARGUMENTS
  ps: .devspark/scripts/powershell/create-pr.ps1 -Mode Preflight -Json $ARGUMENTS
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Routing Contract

Planning records are normally absent because successful implementation deletes them after required
verification. Do not warn about a missing spec or quickfix, search Git history for one, reconstruct
one, or assess whether implementation adhered to one. If an active planning artifact remains, warn
that implementation finalization is incomplete; do not use it as durable PR content.

## Overview

`/devspark.create-pr` is the default post-implementation step for every route. It gathers the branch
delta, current knowledge, tests, verification evidence, and host metadata; drafts a self-contained PR;
and asks the user to confirm before creating or updating it.

This command is advisory. Dirty trees, failed verification, code/knowledge mismatches, and unresolved
review findings are warnings the agent must explain. Missing planning records are normal.

## Definition of Done

Done when: the user has explicitly confirmed (step 4) and the PR has been created or updated (step 5), with the step-6 result report printed. Do not call the create/update script before that confirmation, and do not keep re-drafting once the user has approved — act on their decision.

## Outline

Load and obey the shared preamble contract at `/.devspark/templates/command-preamble-contract.md` (installed repos) or `templates/command-preamble-contract.md` (source repos) before step 1 — it covers multi-app scope resolution and the 2-tier override check for scripts.

### 1. Run Preflight Context

Run `{SCRIPT}` once from the repository root and parse the returned JSON.

Use the script output as the source of truth for:

- current branch, target branch, dirty tree status, and push status
- authentication status and creation support
- existing PR (number, URL, title, state, draft flag)
- changed code, tests, and current `.knowledge/` nodes
- `knowledge.index_fresh` / `knowledge.gap_summary` — a real `build_knowledge_index.py --check` result
  (`null` fields mean the engine wasn't found, e.g. a very old install; treat that as unknown, not clean)
- gate artifact scan results and severities
- gate acknowledgements from tasks or quickfix records
- `diff.lines_summary`, `diff.commit_log` (hash/subject/author/date), `diff.file_changes` (status/path)

If auth is unavailable or the platform does not support automated PR creation, report that clearly and stop before any create/update action.

### 2. Surface Warnings Before Drafting

Present any relevant warnings before drafting the PR:

- dirty working tree
- existing PR already open for this branch
- failed or missing verification for behavior-bearing changes
- material code/knowledge mismatch
- a planning artifact that remains after implementation
- unresolved blocking gate artifacts
- explicit gate acknowledgements already recorded in tasks or quickfix artifacts
- no gate artifacts found
- **planning artifact still present** — route back to `/devspark.implement` to complete verification,
  update current knowledge, and delete the artifact. Never attach it to the PR as a permanent record.

Use recommendation language, not hard-block language.

**Advisory-only noise**: If preflight surfaces environment or tooling problems you did not cause and cannot fix from the diff — missing/expired credentials, network errors, missing CLI tools, truncated terminal output — report them as an advisory note only. Do not cite them as a reason for reject/needs-changes language; that judgment belongs to actual code-risk findings in the diff itself.

#### Verify Reminder (optional, non-blocking)

After the warnings, surface a short, one-time reminder that **offers** — but never requires — running verification, so the developer makes an informed choice without adding a mandatory step:

- Explain in one or two sentences what `/devspark.verify` does: it runs the change and records the actual command output as empirical proof that it works, as opposed to a document review.
- Offer the choice explicitly:
  - **Run it now** → hand off to `/devspark.verify`, then return here to draft the PR.
  - **Skip and continue** → proceed straight to drafting. This is the **default**, and it keeps the fast `quickfix → create-pr → pr-review` path at three steps.
- Tailor the strength of the reminder to context, but keep it advisory in every case:
  - If `spec.md` declares one or more `verify:<mode>` gates and no passing `gates/verify.md` exists, phrase it as a clear recommendation ("this change declared verification; running it is recommended before review").
  - Otherwise (e.g. a low-risk quickfix with no declared verify mode), phrase it as a light optional nudge ("optional: prove the fix works before review").
- Never block on this, and never run verify without the developer choosing it. If `--auto` (or a standing autonomy instruction) is in effect, skip the offer and continue without running verify, noting in the step-6 result that verification was not run.

#### Work-Item Linkage (optional, non-mutating)

Where a repository tracks work externally, a reference in the PR body is the only thread connecting
the change to the request behind it. A reference that resolves to nothing is worth knowing about
before review, not after.

Run this check only when `.devspark/scripts/bash/workitem.sh --operation check --json` (or the
PowerShell twin) reports `work_tracking_configured: true`. When it reports `false`, skip this
subsection entirely and say nothing about work items.

- Collect the references already present in the branch, the commit messages, and any body drafted so
  far — forms such as `AB#1234`, `#1234`, or a full work-item URL.
- Pass them to the `verify-link` operation. **This operation only reads.** It resolves each
  reference and reports whether the item exists and whether it sits inside the configured area path.
  It never writes to the work item, never posts a comment, and never changes a state — creating the
  PR must not mutate the board as a side effect.
- **Reproduce every reference verbatim** in the PR body. Do not normalise `#1234` to `AB#1234`, do
  not re-order them, and do not drop one because it failed to resolve. The reference the developer
  wrote is the one their tooling matches on.
- Surface a warning for any reference that does not resolve, or that resolves outside the configured
  area path. Both are advisory — report them and continue drafting.

**Posting back to the work item is a separate decision.** Announcing the pull request on the item is
useful to some teams and unwanted noise to others, so it is **off unless the repository opts in**,
and even then it is confirmed on its own. Never fold it into the confirmation for creating the PR:
agreeing to open a pull request is not agreeing to write on someone's board. Show the exact comment
text before posting, and treat a refusal as final for this run. A standing autonomy instruction does
not supply this confirmation, because the effect lands outside the repository where nobody reviewing
the diff would see it.

### 3. Draft the PR Title and Description

Derive the title from the resulting delta: most recent `diff.commit_log` subject, changed behavior,
then branch name.

Build the body from the preflight JSON (keep total under 4,000 characters):

- **Summary** — resulting behavior and user impact inferred from code, tests, knowledge, and commits
- **Changes** — file list from `diff.file_changes` (status + path) and `diff.lines_summary`
- **Code/Knowledge Consistency** — whether changed behavior is accurately represented by current
  `.knowledge/`, including any gap requiring reviewer attention
- **Verification** — exact commands and outcomes for tests, lint, builds, or runtime checks
- **Quality Gates** — gate artifact statuses, or "No gate artifacts found". **Test signal wording**: if you observed both a functional test result and a separate policy/coverage-gate result (e.g. a test run that passes but a coverage or lint threshold that fails, or vice versa), report them as two distinct statements — never collapse them into a single "tests failed"/"tests passed" line. Name the specific gate that failed when it isn't the tests themselves.
- **Knowledge Evidence** — for `.knowledge/` nodes changed in this diff, note whether each cites a
  test-verified (`verified_by: execution`) claim or a code-only one, and whether a code-only entry
  carries a `fallback_reason`. A code-only entry with no adjacent reason is a note for the reviewer,
  not a blocker — surfaces the same signal `/devspark.pr-review` §6c checks mechanically, so a human
  sees it here without digging for it. Also state `knowledge.index_fresh` from the preflight JSON
  plainly ("knowledge index is current" / "knowledge index is stale: <gap_summary>") — this is a
  real computed fact from `build_knowledge_index.py --check`, not a judgment call. Omit this bullet
  entirely if the diff touches no `.knowledge/` nodes AND the index is fresh.
- **Gate Acknowledgements** — explicit decisions to proceed (omit section if none)
- **Notes** — warnings, reviewer hints, user-supplied notes

### 4. Ask for Explicit Confirmation

Before creating or updating the PR, show the user:

- proposed title
- proposed body
- whether this will create a new PR or update an existing one
- any flags inferred or requested (`--draft`, `--reviewer`, `--label`, `--assignee`)

Ask explicitly whether to:

- create the PR
- update the existing PR
- adjust the draft first
- stop without changing anything

Do **not** call the create/update script mode until the user confirms.

**Autonomy override**: if `--auto` (or a standing autonomy instruction) is in effect, skip the wait — create or update the PR as `--draft` (regardless of whether `--draft` was otherwise requested) and proceed without waiting for a reply. Opening a PR is visible to others but a draft is reversible, so this is the one auto-bypass in this command that defaults to the more conservative flag rather than the literal request. Report the action taken (and that it was auto-selected) in the step-6 result.

### 5. Create or Update the PR

When the user confirms, run the platform script in create or update mode.

Supported flags:

- `--draft`
- `--reviewer <name>`
- `--label <label>`
- `--assignee <name>`
- `--base <branch>`
- `--issue <ref>`

Use create mode when no PR exists. Use update mode when a PR already exists for the branch or the user explicitly chooses update.

If a quickfix record for this branch still lives under `.devspark.work/quickfixes/` with a blank
`**PR**` field, fill in the new PR number now and commit that one-line update on the same branch —
this is the only place that field gets populated, so a quickfix record left over from before this
command existed should not be treated as an error.

### 6. Report Result

After creation or update, report:

- PR number
- PR URL
- PR title
- whether it is draft or ready for review
- any warnings that still remain unresolved

#### PR-Review Reminder (optional, non-blocking)

After reporting the result above, offer — but never require — an immediate handoff into review:

- Ask explicitly: "Run `/devspark.pr-review` now for this PR? [Y/n]".
- **Yes** → hand off to `/devspark.pr-review` for this PR number.
- **No / no answer** → stop here. This is the default, and it keeps the fast
  `quickfix → create-pr → pr-review` path at three separate, deliberate steps.
- **Autonomy override**: if `--auto` (or a standing autonomy instruction) is in effect, skip the
  ask and do not run pr-review automatically — note in this result that it was not run. Review
  stays a distinct, separately-invoked pass even under autonomy: pr-review needs a real PR number
  that only exists after this step, and running it in the same breath risks the same commit
  reviewing its own work with no independent pass.

## Guidelines

- Branches with no spec are the expected post-implementation state.
- Never include spec, task, quickfix, feature, or requirement identifiers in the PR title or body.
- If gate artifacts are absent, recommend `/devspark.analyze` or `/devspark.critic` before merge.
- Surface gate acknowledgements plainly in the draft body rather than burying them in prose.
