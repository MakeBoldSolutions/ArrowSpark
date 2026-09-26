---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
description: Generate an actionable, dependency-ordered tasks.md for the feature based on available design artifacts.
handoffs:
  - label: Analyze For Consistency
    agent: devspark.analyze
    prompt: Run a project analysis for consistency
    send: true
  - label: Implement Project
    agent: devspark.implement
    prompt: Start the implementation in phases
    send: true
scripts:
  sh: .devspark/scripts/bash/check-prerequisites.sh --json --require-plan
  ps: .devspark/scripts/powershell/check-prerequisites.ps1 -Json -RequirePlan
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Workflow Position

**Step 4 of 4** in the authoring chain (`specify → clarify → plan → tasks`).

- **Owns**: a complete, dependency-ordered, story-organized temporary `tasks.md` immediately executable by `/devspark.implement`, including affected current-knowledge updates, tests, and verification. Every task carries empty `code_ref`/`knowledge_ref` placeholders from creation — `/devspark.implement` fills them as it completes each task, so the delta stays validate-able against code, tests, and knowledge for as long as `tasks.md` remains in `.devspark.work/`. `/devspark.release` is the only command that later checks every one is populated before archiving.
- **Does NOT own**: revisiting WHAT/WHY (spec is authoritative); redesigning architecture/stack/contracts (→ `/devspark.plan`); resolving `[NEEDS CLARIFICATION]` (→ `/devspark.clarify`); gate artifacts beyond the opt-in `## Gate Acknowledgements` note (→ `/devspark.analyze`, `/devspark.critic`).
- **Pre-flight**: if `plan.md` is missing or `spec.md` still contains `[NEEDS CLARIFICATION]` markers, halt and route back to the appropriate earlier step.

## Definition of Done

Done when: `tasks.md` exists with every task in the required checklist format (checkbox, ID, optional `[P]`/`[Story]` labels, file path, `code_ref`/`knowledge_ref` placeholder), organized by phase and user story, with a dependency/parallel-execution section. On a re-run with existing gate findings, done means the `## Gate Remediation` phase is appended (step 3) and reported — not full regeneration. This command stops after writing tasks.md — it does not begin implementation. Chat output: report only the step-6 summary (counts, MVP scope); the task list itself lives in the file.

## Constitution Authority

Load `/.knowledge/governance/constitution.md` before generating tasks. **Non-negotiable** in one specific way: every mandated principle that requires runtime behavior (observability, structured logging, accessibility, security baseline, test coverage, telemetry, audit logging, etc.) MUST have a corresponding task in either the Foundational phase or the relevant user-story phase. If the plan accepted a Constitution Waiver, surface it as a task-section note rather than silently skipping the principle's task.

## Outline

Load and obey the shared preamble contract at `/.devspark/templates/command-preamble-contract.md` (installed repos) or `templates/command-preamble-contract.md` (source repos) before step 1 — it covers multi-app scope resolution and the 2-tier override check for scripts.

1. **Setup**: Run `{SCRIPT}` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Load design documents**: Read from FEATURE_DIR:
   - **Required**: plan.md (tech stack, libraries, structure), spec.md (user stories with priorities)
   - **Required for principle enforcement**: `/.knowledge/governance/constitution.md` (load once; extract mandated principles that imply runtime tasks — observability, accessibility, security baseline, test coverage, audit logging, etc.)
   - **Optional**: data-model.md (entities), contracts/ (interface contracts), research.md (decisions), quickstart.md (test scenarios)
   - Note: Not all projects have all documents. Generate tasks based on what's available.

   Before generating tasks, read the YAML frontmatter in `spec.md` and treat it as authoritative for `classification`, `risk_level`, and `required_gates`. If the prose implies a heavier or lighter route than the metadata, flag that mismatch to the user instead of guessing.

   Before generating tasks, inspect any existing gate artifacts under FEATURE_DIR:
   - `checklists/*.md`
   - `analyze.md`, `critic.md`
   - `gates/*.md`

   **Mode detection**: if `tasks.md` does **not** yet exist, skip step 3 and continue at step 4 (initial generation). If `tasks.md` **already exists**, this is a re-run — go to step 3 (Gate Remediation Merge) and stop there; do not regenerate from scratch.

   If required gates exist and contain unresolved blocking findings, or a checklist has incomplete items, summarize the findings and recommend the next action. Ask the user whether to fix first, review findings, or proceed anyway. Do not hard-block. **Autonomy override**: if the invocation includes `--auto` (or the conversation has established a standing autonomy instruction), skip the ask — auto-select "fix first" when `gates/critic.md`/`gates/analyze.md` have open findings (route to step 3) and "proceed" otherwise; either way, record the auto-selected choice under `## Gate Acknowledgements` with `auto-selected: true`. A constitution-violation finding (CRITICAL/SHOWSTOPPER tied to a `§`-coded principle) is never auto-proceeded past, `--auto` or not.

   If the user (or `--auto`) chooses to proceed anyway, record the decision in `tasks.md` under a `## Gate Acknowledgements` section with the gate name, the unresolved concern, and the user's explicit choice.

3. **Gate Remediation Merge** (re-run only, when `tasks.md` already exists — initial generation skips straight to step 4):

   - Load the `findings:` YAML from `gates/critic.md` and `gates/analyze.md` (when present). Both already use the Shared Review Resolution Contract (`finding_id`, `severity`, `description`, `recommended_action`, `execution_mode`, `status`, `outcome`), so they merge directly — no schema translation needed.
   - Merge and dedupe: findings citing the same file:line/section with overlapping descriptions are one row with both `finding_id`s noted (`critic-004 / analyze-009`).
   - Keep only `status: open` findings. Sort by severity: showstopper > critical > high > medium > low (CON findings are out of scope here — those feed `/devspark.evolve-constitution`, not tasks).
   - Present the merged list as one table with an elaborated recommendation per row (not just the stored `recommended_action` one-liner — reason about the actual fix given the current spec/plan/code).
   - Selection: ask which findings to address this round (`all` allowed) — **unless** `--auto`/standing autonomy is set, in which case: `execution_mode: auto` findings are selected automatically, `execution_mode: selective` findings are selected with a single batch note (not asked one-by-one), and `execution_mode: manual` findings are always left for the human regardless of autonomy.
   - For each selected finding, append a task under a new `## Gate Remediation` phase (after Polish) in the existing `tasks.md`: `- [ ] T0NN [P?] Fix <one-line description> in <file path> (resolves: <finding_id>[, <finding_id>...]) (code_ref: pending | knowledge_ref: pending)`. Do not touch already-checked `[X]` tasks or existing phases.
   - Report the count of tasks appended and recommend `/devspark.implement` to execute them. After remediation tasks are implemented, re-run `/devspark.critic` and `/devspark.analyze` to confirm the findings are gone — loop (re-run this step) until no open blocking findings remain.
   - This step is terminal for a re-run: do not fall through to step 4 afterward.

4. **Execute task generation workflow** (initial generation only):
   - Load plan.md and extract tech stack, libraries, project structure
   - Load spec.md and extract user stories with their priorities (P1, P2, P3, etc.)
   - If data-model.md exists: Extract entities and map to user stories
   - If contracts/ exists: Map interface contracts to user stories
   - If research.md exists: Extract decisions for setup tasks
   - Generate tasks organized by user story (see Task Generation Rules below)
   - **Enforce constitution-mandated tasks**: for every loaded principle that requires runtime behavior, ensure a concrete task exists in the appropriate phase (Foundational for cross-cutting concerns like logging/auth-baseline; story phase for story-specific obligations). If a Constitution Waiver was recorded in `plan.md`, add a single annotation task referencing it rather than silently omitting the principle.
   - Generate dependency graph showing user story completion order
   - Create parallel execution examples per user story
   - Validate task completeness (each user story has all needed tasks, independently testable)

5. **Generate tasks.md**: Use `/.devspark/templates/tasks-template.md` in installed repos, or `templates/tasks-template.md` in source repos, as the structure. Fill with:
   - Correct feature name from plan.md
   - Phase 1: Setup tasks (project initialization)
   - Phase 2: Foundational tasks (blocking prerequisites for all user stories)
   - Phase 3+: One phase per user story (in priority order from spec.md)
   - Each phase includes: story goal, independent test criteria, tests (if requested), implementation tasks
   - Final Phase: verification, current-knowledge consistency, no-planning-reference validation,
     and deletion of the complete `FEATURE_DIR` after every required check passes
   - All tasks must follow the strict checklist format (see Task Generation Rules below)
   - Clear file paths for each task
   - Dependencies section showing story completion order
   - Parallel execution examples per story
   - Implementation strategy section (MVP first, incremental delivery)
   - `## Gate Acknowledgements` section when the user proceeds with unresolved findings

   **Current knowledge tasks**: for each behavior-bearing change, add a task to update the matching
   `.knowledge/` node selected by `appliesTo`, or create a typed node when durable new behavior has no
   owner. Add affected test tasks in the same story or phase. Do not generate feature, requirement,
   or task nodes under `.knowledge/`; traceability remains only in this temporary task list. The
   completed task's `code_ref` MUST list every affected production-code and test file, while
   `knowledge_ref` MUST list every affected current `.knowledge/` file. Use `n/a` with a brief reason
   only for a category that was genuinely not changed. This temporary task record is the required
   traceability map from spec/plan/tasks to the durable delta; neither durable output may point back
   to this task or its plan/spec.

6. **Report**: Output path to generated tasks.md and summary:
   - Total task count
   - Task count per user story
   - Parallel opportunities identified
   - Independent test criteria for each story
   - Suggested MVP scope (typically just User Story 1)
   - Format validation: Confirm ALL tasks follow the checklist format (checkbox, ID, labels, file paths)

Context for task generation: {ARGS}

The tasks.md should be immediately executable - each task must be specific enough that an LLM can complete it without additional context.

## Constraints

**CRITICAL**: Tasks MUST be organized by user story to enable independent implementation and testing.

**Tests are OPTIONAL**: Only generate test tasks if explicitly requested in the feature specification or if user requests TDD approach.

### Checklist Format (REQUIRED)

Every task MUST strictly follow this format:

```text
- [ ] [TaskID] [P?] [Story?] Description with file path (Implements: FR-###[, FR-###])
```

**Format Components**:

1. **Checkbox**: ALWAYS start with `- [ ]` (markdown checkbox)
2. **Task ID**: Sequential number (T001, T002, T003...) in execution order
3. **[P] marker**: Include ONLY if task is parallelizable (different files, no dependencies on incomplete tasks)
4. **[Story] label**: REQUIRED for user story phase tasks only
   - Format: [US1], [US2], [US3], etc. (maps to user stories from spec.md)
   - Setup phase: NO story label
   - Foundational phase: NO story label
   - User Story phases: MUST have story label
   - Polish phase: NO story label
5. **Description**: Clear action with exact file path
6. **Implements directive**: For user-story implementation tasks, append `(Implements: FR-001, FR-003)` naming the functional requirement ID(s) from spec.md that the task satisfies. This makes spec↔task traceability explicit so `/devspark.analyze` can deterministically detect coverage gaps and traceability hallucinations. Omit for Setup/Foundational/Polish tasks that implement no specific requirement. Every `FR-###` in spec.md SHOULD be referenced by at least one task.
7. **Linkage placeholders**: Every task — including Setup/Foundational/Polish — carries a trailing `(code_ref: pending | knowledge_ref: pending)` marker. `/devspark.implement` overwrites `pending` with every real production-code and test path in `code_ref`, and every real current-knowledge path in `knowledge_ref`, as each task completes (or `n/a` with a one-line reason for a category that genuinely was not changed). Do not pre-fill real paths at generation time — they aren't known until implementation. Never add a reference from those durable files back to `spec.md`, `plan.md`, `tasks.md`, or any other temporary work product.

**Examples**:

- ✅ CORRECT: `- [ ] T001 Create project structure per implementation plan (code_ref: pending | knowledge_ref: pending)`
- ✅ CORRECT: `- [ ] T005 [P] Implement authentication middleware in src/middleware/auth.py (code_ref: pending | knowledge_ref: pending)`
- ✅ CORRECT: `- [ ] T012 [P] [US1] Create User model in src/models/user.py (Implements: FR-001) (code_ref: pending | knowledge_ref: pending)`
- ✅ CORRECT: `- [ ] T014 [US1] Implement UserService in src/services/user_service.py (Implements: FR-001, FR-003) (code_ref: pending | knowledge_ref: pending)`
- ❌ WRONG: `- [ ] Create User model` (missing ID and Story label)
- ❌ WRONG: `T001 [US1] Create model` (missing checkbox)
- ❌ WRONG: `- [ ] [US1] Create User model` (missing Task ID)
- ❌ WRONG: `- [ ] T001 [US1] Create model` (missing file path)
- ❌ WRONG: `- [ ] T001 Create User model in src/models/user.py` (missing `code_ref`/`knowledge_ref` placeholder)

### Task Organization

1. **From User Stories (spec.md)** - PRIMARY ORGANIZATION:
   - Each user story (P1, P2, P3...) gets its own phase
   - Map all related components to their story:
     - Models needed for that story
     - Services needed for that story
     - Interfaces/UI needed for that story
     - If tests requested: Tests specific to that story
   - Mark story dependencies (most stories should be independent)

2. **From Contracts**:
   - Map each interface contract → to the user story it serves
   - If tests requested: Each interface contract → contract test task [P] before implementation in that story's phase

3. **From Data Model**:
   - Map each entity to the user story(ies) that need it
   - If entity serves multiple stories: Put in earliest story or Setup phase
   - Relationships → service layer tasks in appropriate story phase

4. **From Setup/Infrastructure**:
   - Shared infrastructure → Setup phase (Phase 1)
   - Foundational/blocking tasks → Foundational phase (Phase 2)
   - Story-specific setup → within that story's phase

### Phase Structure

- **Phase 1**: Setup (project initialization)
- **Phase 2**: Foundational (blocking prerequisites - MUST complete before user stories)
- **Phase 3+**: User Stories in priority order (P1, P2, P3...)
  - Within each story: Tests (if requested) → Models → Services → Endpoints → Integration
  - Each phase should be a complete, independently testable increment
- **Final Phase**: Polish & Cross-Cutting Concerns
