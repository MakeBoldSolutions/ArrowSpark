---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
description: Implement the active route, update current knowledge and tests, verify the delta, and populate code/knowledge linkage for in-sprint validation.
handoffs:
  - label: Create Pull Request
    agent: devspark.create-pr
    prompt: Draft a pull request for the implemented changes
    send: true
scripts:
  sh: .devspark/scripts/bash/check-prerequisites.sh --json --include-tasks
  ps: .devspark/scripts/powershell/check-prerequisites.ps1 -Json -IncludeTasks
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Workflow Position

Load and obey the shared preamble contract at `/.devspark/templates/command-preamble-contract.md` (installed repos) or `templates/command-preamble-contract.md` (source repos) before step 1.

Delivery gateway between authoring (`specify → clarify → plan → tasks → analyze + critic`) and shipping (`create-pr → pr-review`). Also the resume point for `/devspark.quickfix` and for a `quick-spec` route — this command drives implementation for **all three** route sizes (full-spec, quick-spec, quickfix), not full-spec alone.

- **Owns**: executing the active route's task list (`tasks.md` for full-spec, the `## Action Plan` for quick-spec, the `## Validation Checklist` for quickfix); updating affected code, tests, and current `.knowledge/` together; verifying their consistency; and populating `code_ref`/`knowledge_ref` linkage on every item so the delta stays validate-able against code, tests, and knowledge for as long as it remains in `.devspark.work/`. Implement never archives anything — `/devspark.release` is the sole command that later moves a completed, linkage-verified item into `.archive/{YYYY-MM-DD}/`.
- **Traceability requirement**: before marking an item complete, update its temporary spec/plan/tasks or
  quickfix record with every affected production-code path, test path, and current `.knowledge/` path.
  Record `n/a` plus a brief reason only for a category that was genuinely unchanged. Never add a
  reference from code, tests, or `.knowledge/` back to any temporary planning document.
- **Does NOT own**: re-specifying scope (`/devspark.specify` or `/devspark.quickfix`), re-planning (`/devspark.plan`), adding/removing tasks (`/devspark.tasks`), producing gate artifacts (`/devspark.analyze`, `/devspark.critic`, `/devspark.clarify`, `/devspark.checklist`), the PR itself (`/devspark.create-pr`, `/devspark.pr-review`).
- **If scope grows mid-implementation**: halt, mark partial work in the active task list, route back to the appropriate authoring command. Never silently expand scope. If a quick-spec or quickfix route outgrows its size, recommend `/devspark.specify {original problem}` rather than backfilling `plan.md`/`tasks.md` mid-flight.

## Definition of Done

**Full-spec route**: every task in `tasks.md` is `[X]`, every phase has a `**Checkpoint**: Phase complete` line, every finished user story in `spec.md` carries `✅ Complete`, the step-4 gate pre-flight table re-run shows no regression, and every required verification passes.

**Quick-spec route**: every `## Action Plan` item in `spec.md` is `[x]` and every required gate passes.

**Quickfix route**: every `## Validation Checklist` item in the quickfix record is `[x]` and every required verification passes.

For every route, Done also requires: affected current knowledge and tests are updated with the code;
the code/knowledge/test delta is mutually consistent; every task/action-plan/checklist item's
`code_ref`/`knowledge_ref` marker is populated (real path or explained `n/a`), never left `pending`;
shipped code and `.knowledge/` contain no planning identifiers; and the route's own completion marker
(`spec.md` `**Status**`, or the quickfix record's completion marker) is set to `Complete`. The spec
directory or quickfix record stays exactly where it is in `.devspark.work/` — implement never moves,
archives, or deletes it. That stay is deliberate: the populated linkage is what lets anyone validate
the delta against code, tests, and knowledge for the rest of the sprint. `/devspark.release` is the
only command that later sweeps a completed, linkage-verified item into `.archive/{YYYY-MM-DD}/`.

If any condition can't be met in one pass, stop and report exactly which one is unmet — don't keep narrating remaining steps.

**Chat output budget**: `tasks.md`/`spec.md`/`plan.md` carry full detail. In chat, report progress at phase checkpoints (one line per phase), not one line per task, plus the step 9 final summary. Don't restate file contents already written to disk.

## Constitution Authority

Load `/.knowledge/governance/constitution.md` at step 4. Treat every mandated principle as **non-negotiable**:

- Missing task for a runtime-bearing principle (observability, accessibility, security baseline, test coverage, audit logging, telemetry) with no matching `## Constitution Waivers` entry in `plan.md` → **halt** and route to `/devspark.tasks`. Do not add the task yourself.
- An implementation choice that conflicts with a principle MUST be refused even if the task description appears to permit it → amend via `/devspark.plan` or propose via `/devspark.evolve-constitution`.
- Preserve `## Constitution Waivers` from `plan.md` through to the PR.

## Outline

Multi-app scope and script resolution are defined by the shared preamble contract.

1. Run `{SCRIPT}` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

   **Detect the active route** before doing anything else — never assume full-spec:

   - If `FEATURE_DIR/spec.md` exists, read its frontmatter `classification`.
     - `classification: quick-spec` → follow **Quick-Spec Route** (below), then run **Finalize Every Route**. Do not route to `/devspark.plan`/`/devspark.tasks` to backfill artifacts quick-spec's own contract never requires.
     - `classification: full-spec` (or no `classification` field, for pre-existing specs) → continue with steps 2-10 below. If `FEATURE_DIR/tasks.md` is missing, halt: "Run `/devspark.tasks` first to create the task list."
   - If `FEATURE_DIR/spec.md` does not exist for this branch, check for a quickfix record matching the current branch under `.devspark.work/quickfixes/` (filename equal to the branch name, e.g. `042-fix-null-guard.md`). If found → follow **Quickfix Route** (below), then run **Finalize Every Route**.
   - If neither a spec nor a quickfix record exists, halt: "No spec or quickfix record found for this branch — run `/devspark.specify` or `/devspark.quickfix` first."

2. **Check checklists status** (if FEATURE_DIR/checklists/ exists):
   - `{SCRIPT}` (check-prerequisites) already computed the exact counts — read the `CHECKLISTS`/`CHECKLISTS_OVERALL` fields from its step-1 JSON output rather than re-counting checkbox lines yourself. Render its `CHECKLISTS` array as a table:

     ```text
     | Checklist | Total | Completed | Incomplete | Status |
     |-----------|-------|-----------|------------|--------|
     | ux.md     | 12    | 12        | 0          | ✓ PASS |
     | test.md   | 8     | 5         | 3          | ✗ FAIL |
     | security.md | 6   | 6         | 0          | ✓ PASS |
     ```

   - `CHECKLISTS_OVERALL` from the script is authoritative: `PASS` when every checklist has 0 incomplete items, `FAIL` otherwise.

   - **If any checklist is incomplete**:
     - Display the table with incomplete item counts
     - Ask: "Some checklists are incomplete. Do you want to proceed with implementation anyway? (yes/no)"
     - Wait for user response before continuing
     - If user says "no" or "wait" or "stop", halt execution
     - If user says "yes" or "proceed" or "continue", proceed to step 3 and record the explicit override in `tasks.md` under `## Gate Acknowledgements`
     - **Autonomy override**: if `--auto` (or a standing autonomy instruction) is in effect, skip the wait — proceed to step 3 and record `auto-selected: true` in the Gate Acknowledgement instead of waiting for a reply.

   - **If all checklists are complete**:
     - Display the table showing all checklists passed
     - Automatically proceed to step 3

3. **Update Spec Status to In Progress**:
   - Read `FEATURE_DIR/spec.md`
   - If the `**Status**:` field is `Draft`, update it to `In Progress`
   - This ensures the spec is no longer marked as Draft once implementation begins
   - Preserve the lifecycle comment if present: `**Status**: In Progress <!-- Valid: Draft | In Progress | Complete -->`

4. Load and analyze the implementation context:
   - **REQUIRED**: Read tasks.md for the complete task list and execution plan
   - **REQUIRED**: Read plan.md for tech stack, architecture, file structure, any `## Constitution Waivers`, and the `## Context Resolution` `context_resolved` list
   - **REQUIRED**: Read `/.knowledge/governance/constitution.md` and extract mandated principles (see Constitution Authority above)
   - **IF EXISTS**: Read data-model.md for entities and relationships
   - **IF EXISTS**: Read contracts/ for API specifications and test requirements
   - **IF EXISTS**: Read research.md for technical decisions and constraints
   - **IF EXISTS**: Read quickstart.md for integration scenarios

   **Consume `context_resolved` as already-resolved** — `/devspark.plan` did the bounded projection
   so this command doesn't have to. Every entry is equally authoritative regardless of its `kind`: a
   flat Knowledge document carries exactly the same weight as an entity, an entity layer, or a
   decision, and a resolved set containing no entities at all is complete, not deficient. Never
   traverse `.knowledge/` more than **one additional hop** beyond an item already named in
   `context_resolved`. If a task genuinely requires escalating past that one hop (the resolved set
   doesn't cover something the task needs), do the extra hop, but log it: append a line to `plan.md`
   under a `## Implementation Notes` entry noting the task ID, the item and relation that required
   the escalation, and why. This is an attributable signal, not a failure — frequent escalation on
   the same pair means the corpus's relations are too sparse (add the edge directly); escalation
   despite a passing `context_resolved` means `/devspark.critic`'s sufficiency check missed a gap
   (tighten that prompt, don't just patch here).

   **Gate pre-flight (hard halt on failure unless the user explicitly overrides)**:

   Before writing any code, verify each gate below. Present results as a single table, then act on the worst finding.

   | Gate                            | Source of truth                             | Pass condition                                                  | On fail                                                                      |
   | ------------------------------- | ------------------------------------------- | --------------------------------------------------------------- | ---------------------------------------------------------------------------- |
   | Clarifications resolved         | `spec.md`                                   | No `[NEEDS CLARIFICATION]` markers remain                       | Route to `/devspark.clarify`                                                 |
   | Required gates from frontmatter | `spec.md` YAML `required_gates`             | Each listed gate has a matching artifact in FEATURE_DIR         | Route to the listed gate command                                             |
   | Analyze findings                | FEATURE_DIR/analysis.md (or analyze output) | No `severity: critical` findings with `status: open`            | Route to `/devspark.analyze` (or `/devspark.address-pr-review`-style triage) |
   | Critic findings                 | FEATURE_DIR/critique.md (or critic output)  | No `severity: critical` findings with `status: open`            | Route to `/devspark.critic`                                                  |
   | Gate freshness                  | `gates/analyze.md`, `gates/critic.md` `reviewed_artifacts[]` | For each `reviewed_artifacts` entry, `git hash-object <path>` matches the recorded `hash` | If mismatched AND the gate has an open SHOWSTOPPER/CRITICAL finding: mark **STALE**, route to the mismatched gate command for re-run (never auto-overridden, `--auto` or not) |
   | Verification (if required)      | `spec.md` `required_gates` `verify:<mode>` entries vs. `gates/verify.md` | Not checked on the first pre-flight pass (code doesn't exist yet). On the step-9 re-run (implementation reporting done), every declared `verify:<mode>` has a matching `modes[]` entry in `gates/verify.md` with `status: pass` | Route to `/devspark.verify` to produce the proof before reporting Done |
   | Checklists                      | step 2 result                               | All checklists at 0 incomplete (or explicit override recorded)  | Already handled in step 2                                                    |
   | Constitution coverage           | constitution.md vs tasks.md                 | Every runtime-bearing mandated principle has a task OR a waiver | Route to `/devspark.tasks` (regenerate) or `/devspark.plan` (record waiver)  |
   | Plan waivers acknowledged       | `plan.md` `## Constitution Waivers`         | All waivers have rationale + expiry                             | Route to `/devspark.plan`                                                    |

   If any required gate fails, surface the failure with context and ask the user whether to (a) fix first (recommended), (b) review findings, or (c) proceed anyway. If the user proceeds anyway, append or update a `## Gate Acknowledgements` section in `tasks.md` with: the failing gate(s), the unresolved findings (by ID), the user's explicit decision, and a UTC timestamp. This section will be surfaced in the PR body by `/devspark.create-pr`.

   **Autonomy override**: if `--auto` (or a standing autonomy instruction) is in effect, auto-select option (a) — route to `/devspark.tasks` for gate remediation (or the listed gate command) instead of waiting for a reply — and record `auto-selected: true` in the Gate Acknowledgement. **Exception, never auto-overridden**: a failing "Constitution coverage" or "Plan waivers acknowledged" row, a **STALE** "Gate freshness" row, or any finding whose severity is SHOWSTOPPER or carries a `§`-coded constitution citation — those always halt and wait for a human, `--auto` or not.

   The YAML frontmatter classification and `required_gates` in `spec.md` are authoritative; if the prose disagrees with the metadata, treat the metadata as truth and flag the mismatch.

5. **Project Setup Verification**:
   - **REQUIRED**: Create/verify ignore files based on actual project setup:

   **Detection & Creation Logic**:
   - Check if the following command succeeds to determine if the repository is a git repo (create/verify .gitignore if so):

     ```sh
     git rev-parse --git-dir 2>/dev/null
     ```

   - Check if Dockerfile\* exists or Docker in plan.md → create/verify .dockerignore
   - Check if .eslintrc\* exists → create/verify .eslintignore
   - Check if eslint.config.\* exists → ensure the config's `ignores` entries cover required patterns
   - Check if .prettierrc\* exists → create/verify .prettierignore
   - Check if .npmrc or package.json exists → create/verify .npmignore (if publishing)
   - Check if terraform files (\*.tf) exist → create/verify .terraformignore
   - Check if .helmignore needed (helm charts present) → create/verify .helmignore

   **If ignore file already exists**: Verify it contains essential patterns, append missing critical patterns only
   **If ignore file missing**: Create with full pattern set for detected technology

   **Common Patterns by Technology** (from plan.md tech stack):
   - **Node.js/JavaScript/TypeScript**: `node_modules/`, `dist/`, `build/`, `*.log`, `.env*`
   - **Python**: `__pycache__/`, `*.pyc`, `.venv/`, `venv/`, `dist/`, `*.egg-info/`
   - **Java**: `target/`, `*.class`, `*.jar`, `.gradle/`, `build/`
   - **C#/.NET**: `bin/`, `obj/`, `*.user`, `*.suo`, `packages/`
   - **Go**: `*.exe`, `*.test`, `vendor/`, `*.out`
   - **Ruby**: `.bundle/`, `log/`, `tmp/`, `*.gem`, `vendor/bundle/`
   - **PHP**: `vendor/`, `*.log`, `*.cache`, `*.env`
   - **Rust**: `target/`, `debug/`, `release/`, `*.rs.bk`, `*.rlib`, `*.prof*`, `.idea/`, `*.log`, `.env*`
   - **Kotlin**: `build/`, `out/`, `.gradle/`, `.idea/`, `*.class`, `*.jar`, `*.iml`, `*.log`, `.env*`
   - **C++**: `build/`, `bin/`, `obj/`, `out/`, `*.o`, `*.so`, `*.a`, `*.exe`, `*.dll`, `.idea/`, `*.log`, `.env*`
   - **C**: `build/`, `bin/`, `obj/`, `out/`, `*.o`, `*.a`, `*.so`, `*.exe`, `Makefile`, `config.log`, `.idea/`, `*.log`, `.env*`
   - **Swift**: `.build/`, `DerivedData/`, `*.swiftpm/`, `Packages/`
   - **R**: `.Rproj.user/`, `.Rhistory`, `.RData`, `.Ruserdata`, `*.Rproj`, `packrat/`, `renv/`
   - **Universal**: `.DS_Store`, `Thumbs.db`, `*.tmp`, `*.swp`, `.vscode/`, `.idea/`

   **Tool-Specific Patterns**:
   - **Docker**: `node_modules/`, `.git/`, `Dockerfile*`, `.dockerignore`, `*.log*`, `.env*`, `coverage/`
   - **ESLint**: `node_modules/`, `dist/`, `build/`, `coverage/`, `*.min.js`
   - **Prettier**: `node_modules/`, `dist/`, `build/`, `coverage/`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
   - **Terraform**: `.terraform/`, `*.tfstate*`, `*.tfvars`, `.terraform.lock.hcl`
   - **Kubernetes/k8s**: `*.secret.yaml`, `secrets/`, `.kube/`, `kubeconfig*`, `*.key`, `*.crt`

6. Parse tasks.md structure and extract:
   - **Task phases**: Setup, Foundational, User Story phases (priority order), Polish
   - **Task dependencies**: Sequential vs parallel execution rules
   - **Task details**: ID, description, file paths, parallel markers [P]
   - **Execution flow**: Order and dependency requirements

7. Execute implementation phase-by-phase, in the order parsed in step 6:
   - Complete each phase fully (including its tests, per TDD) before moving to the next; verify completion before proceeding
   - Within a phase, respect sequential dependencies; run `[P]`-marked tasks together
   - Within a phase, write test tasks before the implementation tasks they cover
   - Tasks touching the same file must run sequentially even if marked `[P]`

8. Progress tracking, artifact sync, and error handling:

   **Continuous artifact sync** (required — do this as work happens, not at the end):
   - **Current knowledge and tests** — when a task changes behavior, update every matching
     `.knowledge/` node selected by `appliesTo` and the affected tests in the same revision. If no
     node describes material new behavior, create one with typed frontmatter and accurate
     `appliesTo`; do not copy planning prose or identifiers into it. If the new behavior genuinely
     warrants a *new entity* (not just a flat doc), run `scripts/scaffold-entity.py` (default:
     dry-run) to draft `_entity.yaml` plus candidate layer doc(s) from the changed source paths,
     review the draft, then re-run with `--write` only after explicit confirmation — this is an
     assisted alternative to hand-authoring, never a substitute for review.
   - **Index regeneration cadence** — run `python scripts/build_knowledge_index.py --repo-root .`
     immediately after any task that touched `.knowledge/`, not only once at Finalize step 2. This
     catches an entity/frontmatter mistake within the same task instead of only at the very end.
   - **Evidence preference** — when a node's `source_of_truth` needs updating for this change, prefer
     citing a test that asserts the claim over a bare code reference: attempt a test first, and only
     fall back to a code-only reference when a test genuinely isn't practical (e.g. requires live
     timing, external infra, or manual verification). When falling back, record *why* in the node's
     text next to `source_of_truth` — one line, e.g. "code-only: requires live token expiry timing,
     not practical in a unit test" — so the gap is visible to `/devspark.pr-review` and
     `/devspark.site-audit` rather than silently accepted.
   - **Task linkage (`code_ref`/`knowledge_ref`)** — the moment a task's checkbox flips to `[X]`,
    overwrite its `(code_ref: pending | knowledge_ref: pending)` marker with every real durable
    path touched. `code_ref` includes all production and test files when applicable; for
     example: `code_ref: src/Auth/TokenService.cs::RefreshToken, tests/Auth/TokenServiceTests.cs |
     knowledge_ref: entities/token_service/architecture.md`.
     If a task genuinely touches neither (a pure research/decision task), write `n/a` with a one-line
     reason instead of leaving `pending`. Never batch this at the end — it happens task-by-task, same
     discipline as checking the box itself.
   - **tasks.md** — mark each task `[X]` immediately on completion. Never batch updates at the end of a phase. If a task is partially done, leave it `[ ]` and add a brief `<!-- WIP: ... -->` note rather than half-checking it.
   - **tasks.md phase checkpoints** — when every task in a phase (Setup, Foundational, User Story N, Polish) is `[X]`, append a checkpoint line under that phase heading: `**Checkpoint**: Phase complete — YYYY-MM-DD`. For user-story phases, this is the signal that the story is independently shippable.
   - **spec.md user stories** — when all tasks tagged `[USn]` are `[X]`, update the corresponding `### User Story n` heading by appending `✅ Complete` (preserve the priority marker). This keeps the spec a live picture of delivered scope.
   - **spec.md lifecycle status** — flip `**Status**: Draft` to `**Status**: In Progress` on the first completed task (already done in step 3); the final flip to `Complete` happens in step 10.
   - **plan.md** — if implementation discovers a deviation from the plan (different library chosen, contract adjusted, etc.), update plan.md inline and add a short `## Implementation Notes` entry dated and linked to the task ID. Do NOT silently diverge.
   - **Constitution waivers** — if a new waiver becomes necessary mid-implementation, **halt**, route the user to `/devspark.plan` to record it, then resume. Never invent waivers from within implement.
   - **Gate finding resolution** — when a task whose description includes `(resolves: <finding_id>[, <finding_id>...])` is marked `[X]`, flip each referenced finding's `status` from `open` to `resolved` and fill in `outcome` (one line: what changed, which commit/task) in the gate file that originated it (`gates/critic.md` for `critic-*` ids, `gates/analyze.md` for `analyze-*` ids). This is what lets a re-run of `/devspark.critic`/`/devspark.analyze` converge instead of re-reporting the same finding. Apply command-preamble-contract.md §9 (Genuine Fix Discipline) before flipping status: resolve the underlying intent, not just the mechanical check the finding cites.

   **Progress reporting and error handling**:
   - Update tasks.md per task as it completes (already required above); in chat, report progress at phase checkpoints only — one line per phase, not one line per task
   - Halt execution if any non-parallel task fails; report it immediately regardless of checkpoint batching
   - For parallel tasks `[P]`, continue with successful tasks, report failed ones with context
   - Provide clear error messages with context for debugging
   - Suggest next steps if implementation cannot proceed

   **Structural quality self-check** (best-effort, non-blocking, no new tooling required): at each phase checkpoint, if the repo already has a linter/static-analysis config for the touched language (e.g. `.eslintrc*`/`eslint.config.*`, `ruff`/`pyproject.toml` `[tool.ruff]`, `phpmd.xml`, PMD ruleset), run it scoped to the files this phase touched (`git diff --name-only` against the branch base) rather than the whole repo. For any finding, apply command-preamble-contract.md §9 (Genuine Fix Discipline) and its §9.1 intent-cue table before fixing — do not silently satisfy the bare metric. Skip entirely if no such tool is already configured; this step never installs a new linter or blocks progress on a missing one.

   **Governance expectations for the create-pr/pr-review handoff**:
   - Branch sync must pass (`HEAD` not behind `origin/main`)
   - Every `## Gate Acknowledgements` entry and every `## Constitution Waivers` entry will be surfaced by `/devspark.create-pr` in the PR body — make sure they are accurate.

9. Completion validation:
    - Verify all required tasks in `tasks.md` are `[X]`
    - Verify every phase has a `**Checkpoint**: Phase complete` line (per step 8 sync rules)
    - Verify every completed user story in `spec.md` carries the `✅ Complete` marker
    - Check that the implemented behavior, affected tests, and current `.knowledge/` agree
    - Validate that tests pass and coverage meets requirements
    - Confirm the implementation follows the technical plan (and that any deviations are recorded under `## Implementation Notes` in `plan.md`)
    - Re-run the gate pre-flight table from step 4 and confirm nothing regressed during implementation
    - If `spec.md` `required_gates` declares any `verify:<mode>` entries, route to `/devspark.verify` now that code exists and wait for `gates/verify.md` to show `status: pass` for every declared mode before reporting Done
    - Run `.devspark/scripts/{powershell,bash}/check-planning-references.*` (or `scripts/{powershell,bash}/check-planning-references.*` in source repos) and confirm it reports `ok: true` before proceeding — this is the deterministic backstop for the no-spec-reference check below, not a substitute for it
    - Regenerate `.knowledge/index.json` and validate the current-only knowledge schema
    - Report final status with summary of completed work, any remaining `## Gate Acknowledgements`, and any active `## Constitution Waivers`

10. **Spec Lifecycle Status Update**:
    - After all tasks in tasks.md are marked `[X]` (complete):
      1. Read `FEATURE_DIR/spec.md`
      2. Update the `**Status**:` field from `Draft` or `In Progress` to `Complete`
         - Find the line matching `**Status**:` and replace its value with `Complete`
         - Preserve the lifecycle comment if present: `**Status**: Complete <!-- Valid: Draft | In Progress | Complete -->`
      3. Continue to **Finalize Every Route**; do not report completion while the bundle remains.
    - If any tasks remain incomplete (`- [ ]`):
      1. Update spec status to `In Progress` (if currently `Draft`)
      2. Report which tasks are still incomplete
      3. Do NOT mark spec as `Complete`

Note: Steps 2-10 above are the **full-spec route** and assume a complete task breakdown exists in `tasks.md`. The two routes below are separate, self-contained execution paths — do not mix their steps with the full-spec steps above.

## Quick-Spec Route (no `plan.md`/`tasks.md`)

Triggered when `spec.md` frontmatter declares `classification: quick-spec`. quick-spec's own contract (`required_artifacts: intent, action-plan`) never produces `plan.md` or `tasks.md` — treat the spec's `## Action Plan` as the task list instead of routing to `/devspark.plan`/`/devspark.tasks` to backfill them.

1. Read `spec.md`'s `## Action Plan` section. If its items are plain numbered text (not yet checkboxes), convert each to a checkbox in place, preserving the original wording: `- [ ] 1. First concrete implementation step`.
2. If `**Status**` is `Draft`, update it to `In Progress` (mirrors full-spec step 3).
3. Gate pre-flight, scoped to what `required_gates` in frontmatter actually lists (typically `checklist` only): if `FEATURE_DIR/checklists/` exists, run the same checklist-completeness check as full-spec step 2. Do not apply the full-spec gate table (constitution coverage, analyze, critic, verify) unless `required_gates` explicitly names them — quick-spec's contract does not require those gates by default.
4. Implement each Action Plan item in order; check it off `[x]` immediately on completion — never batch updates at the end. If implementation deviates from an item's plan, add a short `## Implementation Notes` section to `spec.md` (dated) describing the deviation, mirroring the role `plan.md`'s `## Implementation Notes` plays for full-spec.
5. **Completion**: once every Action Plan item is `[x]`, update `**Status**` to `Complete`. This is the fix for the previously-documented gap where quick-spec had no `/devspark.implement` step to flip status automatically — `/devspark.create-pr` no longer needs to catch and patch a stuck `Draft` status.
6. Continue to **Finalize Every Route**.

## Quickfix Route (`.devspark.work/quickfixes/` record, no `spec.md`)

Triggered when no `spec.md` exists for this branch but a matching quickfix record does. This is the resume point `/devspark.quickfix`'s own header promises but previously left entirely manual.

1. Read the quickfix record's `## Validation Checklist` — treat each item as the task list.
2. Implement the fix described in the record's TLDR (WHAT/WHY/HOW). As work progresses, append dated notes to the record's `## Implementation Notes` section (mirroring `plan.md`'s role for full-spec) and check off `## Validation Checklist` items `[x]` as each is verified — never batch updates at the end.
3. Gate pre-flight, scoped to what the record already captured: honor its `## Constitution Compliance` table and any `## Gate Acknowledgements` entries. Do not run the full-spec gate table (analyze/critic/verify) unless the record's frontmatter `required_gates` explicitly names them.
4. Once every `## Validation Checklist` item is `[x]`, continue to **Finalize Every Route**.

## Finalize Every Route

1. Run all required verification and refuse finalization on any failure.
2. Confirm changed code, affected tests, and matching `.knowledge/` nodes describe the same resulting
  behavior. Regenerate `.knowledge/index.json`.
3. Check whether the delta touches anything an existing `.knowledge/governance/decisions/` doc
  claims about — a rejected alternative, a stated rationale, an entity listed in a decision's
  `constrains` (or an entity carrying a matching `constrained_by` pointer). If it does, correct that
  decision doc in place now — never leave it stale, never add a new decision file or a "superseded
  by" note for the same topic.
4. **Verify linkage**: for the full-spec route, confirm every task in `tasks.md` has a populated
  `code_ref` and `knowledge_ref` (real path(s), or an explained `n/a`) — none left as `pending`. For
  quick-spec and quickfix, apply the same check to their `code_ref`/`knowledge_ref` markers. Halt and
  finish the remaining markers before continuing. This linkage is what lets anyone validate the delta
  against code, tests, and knowledge while the spec or quickfix record stays live in `.devspark.work/`
  for the rest of the sprint — it is no longer a gate for moving anything anywhere.
5. Run `check-planning-references.*` again (it checks both directions in one pass: a leaked
  reference in durable content, and a completed item still marked `pending` from step 4). If it
  reports any finding, fix it before continuing — remove a leaked planning identifier (spec IDs,
  `FR-###`, `T###`, phase references, quickfix IDs, or paths into `.devspark.work/` or `.archive/`)
  from durable code, tests, or `.knowledge/`, or fill in a linkage marker step 4 missed. Linkage is
  strictly one-directional: the ephemeral spec/plan/tasks/quickfix record points at code via
  `code_ref`/`knowledge_ref`; code, tests, and `.knowledge/` never point back at it. Never add a
  spec/plan/task/quickfix/feature comment, identifier, or link to durable code, tests, or
  `.knowledge/` to "document" where a change came from — that provenance belongs solely in the
  planning bundle's own linkage markers.
6. Leave `FEATURE_DIR` (or the quickfix record) exactly where it is under `.devspark.work/` with its
  completion marker set to `Complete`. Implement never moves, archives, or deletes it —
  `/devspark.release` is the sole command that later sweeps completed, linkage-verified work out of
  `.devspark.work/` into `.archive/{YYYY-MM-DD}/`. For a quickfix record, also fill in its
  `## Completion` block now: `**Completed**` (today's date) and `**Commit**` (the final commit SHA
  that carries the fix) — leave `**PR**` blank, since it isn't known yet.
7. Recommend `/devspark.create-pr`. The PR must stand alone and review the verified delta.
