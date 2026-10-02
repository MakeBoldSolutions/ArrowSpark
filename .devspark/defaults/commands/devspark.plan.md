---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
description: Execute the implementation planning workflow using the plan template to generate design artifacts.
handoffs:
  - label: Create Tasks
    agent: devspark.tasks
    prompt: Break the plan into tasks
    send: true
  - label: Create Checklist
    agent: devspark.checklist
    prompt: Create a checklist for the following domain...
scripts:
  sh: .devspark/scripts/bash/setup-plan.sh --json
  ps: .devspark/scripts/powershell/setup-plan.ps1 -Json
agent_scripts:
  sh: .devspark/scripts/bash/update-agent-context.sh __AGENT__
  ps: .devspark/scripts/powershell/update-agent-context.ps1 -AgentType __AGENT__
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Workflow Position

**Step 3 of 4** in the authoring chain (`specify → clarify → plan → tasks`).

- **Owns**: technical context (stack, libraries, project structure), Constitution Check gate, research consolidation, data model, interface contracts, per-agent context update, and **context resolution** — the bounded `.knowledge/` traversal for this delta (2 hops maximum from the lexical seeds), pinned down as `context_resolved` so `/devspark.implement` never has to traverse more than one additional hop itself.
- **Does NOT own**: re-litigating WHAT/WHY (spec is authoritative); resolving open functional ambiguities (→ `/devspark.clarify`); the executable task list (→ `/devspark.tasks`); adversarial review (→ `/devspark.critic`, `/devspark.analyze`).
- **Pre-flight**: if the loaded spec still contains `[NEEDS CLARIFICATION: …]` markers, halt and route to `/devspark.clarify`. Do not silently default open questions into planning decisions.

## Definition of Done

Done when: research.md has zero `NEEDS CLARIFICATION` markers, data-model.md/contracts//quickstart.md exist where applicable to the project type, the agent-context script has run, `plan.md`'s `## Context Resolution` section is populated with the traversal's `context_resolved` entries, and the Constitution Check is re-evaluated post-design with no unresolved violations. This command stops after Phase 1 (step 4) — it does not generate tasks or write code. Chat output: report only the branch, IMPL_PLAN path, and generated artifact list — full design detail lives in the files.

## Constitution Authority

`/.knowledge/governance/constitution.md` is **non-negotiable** for planning. Violations may not be carried forward as `NEEDS CLARIFICATION`; they must be resolved before exiting the Constitution Check gate. Justified deviations require an explicit `## Constitution Waivers` block in `plan.md` citing the principle, deviation, reason, and compensating control.

## Outline

Load and obey the shared preamble contract at `/.devspark/templates/command-preamble-contract.md` (installed repos) or `templates/command-preamble-contract.md` (source repos) before step 1 — it covers multi-app scope resolution and the 2-tier override check for both `{SCRIPT}` and `{AGENT_SCRIPT}`.

1. **Setup**: Run `{SCRIPT}` from repo root and parse JSON for FEATURE_SPEC, IMPL_PLAN, SPECS_DIR, BRANCH. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Load context**: Read FEATURE_SPEC and `/.knowledge/governance/constitution.md`. Load IMPL_PLAN template (already copied).
   - Read the YAML frontmatter in FEATURE_SPEC before planning.
   - Treat frontmatter as authoritative for `classification`, `risk_level`, `recommended_next_step`, and `required_gates`.
   - If the body text appears to conflict with the frontmatter, flag the inconsistency to the user instead of overriding the metadata.

3. **Execute plan workflow**: Follow the structure in IMPL_PLAN template to:
   - Fill Technical Context (mark unknowns as "NEEDS CLARIFICATION")
   - Fill Constitution Check section from constitution
   - Evaluate gates (ERROR if violations unjustified)
   - Phase 0: Generate research.md (resolve all NEEDS CLARIFICATION)
   - Phase 1: Generate data-model.md, contracts/, quickstart.md
   - Phase 1: Update agent context by running the agent script
   - Re-evaluate Constitution Check post-design

4. **Stop and report**: Command ends after Phase 2 planning. Report branch, IMPL_PLAN path, and generated artifacts.

## Phases

### Phase 0: Outline & Research

1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:

   ```text
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

### Phase 1: Design & Contracts

**Prerequisites:** `research.md` complete

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Define interface contracts** (if project has external interfaces) → `/contracts/`:
   - Identify what interfaces the project exposes to users or other systems
   - Document the contract format appropriate for the project type
   - Examples: public APIs for libraries, command schemas for CLI tools, endpoints for web services, grammars for parsers, UI contracts for applications
   - Skip if project is purely internal (build scripts, one-off tools, etc.)

3. **Agent context update**:
   - Run `{AGENT_SCRIPT}`
   - These scripts detect which AI agent is in use
   - Update the appropriate agent-specific context file
   - Add only new technology from current plan
   - Preserve manual additions between markers

4. **Context Resolution** — traverse `.knowledge/` (flat documents, entities, entity layer docs, `governance/decisions/`) starting from the content this delta touches:
   - Seed the traversal from lexically discovered current-knowledge (the same matching `/devspark.explain` uses for `MATCHED_KNOWLEDGE`/`MATCHED_ENTITIES`) for the entities/paths this delta touches.
   - Run Context Projection (`.devspark/scripts/bash/context-projection.sh --seed <id> [--seed <id> ...] --max-hops 2 --json` / `.devspark/scripts/powershell/context-projection.ps1 --seed <id> [--seed <id> ...] --max-hops 2 -Json`, one `--seed` per lexical hit) to deterministically expand those seeds across accepted `.knowledge` relationships (entity `relations[]`, `constrains`/`constrained_by`, `links.references`) — never a second lexical/semantic search, never an unaccepted `/devspark.discover-knowledge` finding.
   - Evaluate every returned candidate for relevance to this delta; you are not required to include every candidate, but you MUST preserve the projection's provenance (seed, relation, hop distance) for whichever candidates you do keep, distinct from any purely-lexical (hop 0) seeds.
   - **Candidate context is not resolved context.** Projection is deliberately generous — it returns everything structurally reachable so nothing relevant is silently unreachable. Selecting from it is your job, and it is a narrowing one: `context_resolved` is the **smallest** set that lets the work be done safely, not the candidate list with provenance attached. Retaining a candidate because it is plausibly related, rather than because this delta needs it, is the failure mode this step exists to prevent. A resolved set materially smaller than the candidate set is the expected outcome; one that equals it means no selection happened.
   - Sibling layers of a matched entity, and governance documents reached through a shared hub rather than through a constraint that actually binds this delta, are the two candidate classes most often reachable but not needed. Drop them unless they inform the change.
   - Budget: **2 hops maximum** from the lexical seeds. Stop earlier when the traversal stops finding anything that can materially affect this delta — adjacency is not relevance. Design time is where retrieval complexity gets worked out so `/devspark.implement` never has to, but a wider set is not a better one.
   - Record each resolved item in `plan.md`'s `## Context Resolution` section as `context_resolved:` with its `id`, its `kind` (`knowledge` for a flat document, `entity`, `entity-layer`, or `decision`), the `via` relation or match that reached it, its `hop` (0, 1, or 2), and a short `reason` it was retained. Omit items that don't inform the delta — this is a pinned working set, not an index dump.
   - **Flat Knowledge documents are first-class here.** A resolved set consisting entirely of flat documents is valid and complete; never promote a flat document into an entity just so it can be recorded. Equally, resolve the specific entity layer when only one layer informs the delta rather than pulling the whole entity in.
   - This list is read, not re-derived, by `/devspark.analyze` (validity) and `/devspark.critic` (sufficiency), and consumed as already-resolved by `/devspark.implement`.

**Output**: data-model.md, /contracts/\*, quickstart.md, agent-specific file, `## Context Resolution` in plan.md

## Constraints

- Use absolute paths
- ERROR on gate failures or unresolved clarifications
