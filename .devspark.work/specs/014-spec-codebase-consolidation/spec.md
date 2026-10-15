---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
classification: full-spec
risk_level: medium
target_workflow: specify-full
required_artifacts: spec, plan, tasks
recommended_next_step: plan
required_gates: checklist, analyze, critic, verify:snapshot-neutral
route_intent: refactor
depends_on: []
supersedes: []
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Feature Specification: Codebase Organization and Consolidation

**Feature Branch**: `014-spec-codebase-consolidation`
**Created**: 2026-10-15
**Status**: In Progress <!-- Valid: Draft | In Progress | Complete -->
**Input**: User description: "Organize the existing codebase into a coherent, maintainable structure, identify unnecessary complexity and duplication, and selectively consolidate code without changing game behavior."

> This spec is temporary working state under `.devspark.work/specs/`. It remains there until
> release archival and must not be referenced by durable code or `.knowledge/` content.

## Product Owner TLDR

ArrowSpark has grown through thirteen feature specs that mostly added code and rarely tidied it.
That has not hurt yet, but a few things already make the next change more expensive than it needs
to be. Some rules are copied in several places. Some puzzle boards have no safety net that would
catch an accidental change. Unused starter-template examples suggest systems the game doesn't have.
This spec fixes those specific problems, writes down who owns what in the code, and records the
larger ideas (puzzle data files, a puzzle generator, splitting the input code) as separate future
work. Players see no difference: every puzzle, rule, score and control behaves exactly as before.

## Rationale Summary

### Core Problem

The cost of the next change is rising in a few specific places. Behavior-defining rules are
duplicated, so they can drift apart. Six puzzle boards could change shape without any test
noticing. The code has no current written map of responsibilities, so a newcomer can't tell live
code from template leftovers.

### Decision Summary

- **Evidence over tidiness.** Every change below fixes one observed maintenance problem. Large
  files that already hold a single responsibility are left alone.
- **Pin before touching.** Before anything that builds puzzle boards is changed, every catalog
  board's exact geometry is pinned by one automated check. The pin is the behavior-preservation
  proof for all catalog work.
- **The catalog stays in GDScript for this spec.** The authoring effort recorded in the previous
  spec came from offline search and placing boards by coordinates, not from the boards being
  written in GDScript. A data-file format mainly serves a future generator, so it is deferred to
  its own spec. This spec only removes the duplication inside the catalog.
- **Saved data is untouchable.** The template's saved-game classes look unused but are referenced
  by players' existing save files, so they stay.
- **No new gates and no reporting infrastructure.** The before/after evidence is a one-time record
  for this spec.

### Key Drivers

- Production code churn so far is about +4,828 / −401 lines; there has been no consolidation pass
  yet.
- The head-ordering rule decides which arrow "Show Me an Open Move" picks, the solver's witness
  order and the puzzle content-version hash. It is written out separately in four places.
- The previous spec found dense-board authoring slow. Any future authoring or generation work needs
  a clean, safe seam to build on.

### Source Inputs

**Evidence baseline (measured 2026-10-15 on `main` @ 58a8bec):**

| Measure | Value |
|---|---|
| Production GDScript (scripts/ + scenes/) | 48 files, 4,427 lines |
| Test GDScript | 14 files, 5,727 lines, two headless gates plus Godot validation |
| Largest files | catalog 1,145 · board 548 · analyzer 513 · arrow view 315 · puzzle scene controller 250 |
| Catalog composition | ~150 lines of lookup/grouping logic; ~1,000 lines of board literals for 30 entries; three authoring styles (literal dictionaries, computed loops, vertex-path shapes) |
| Catalog duplication | A shared shape-to-board helper exists, but 8 builders repeat its loop inline |
| Head-ordering duplication | 4 production copies (rule state, solver, content version, analyzer); more in tests |
| Direction-vector duplication | 2 production copies (puzzle definition; arrow view) |
| Catalog geometry pins | 14 entries by fingerprint, 1 by a separate fingerprint, 9 by content version; **6 `knot_*` experiments pinned by size and arrow count only** |
| Unreachable template example content | Example game scene, three example levels, template level-select menu, won/lost/game-won overlays, end credits, level loading screen, shader-caching loading screen, level-list state manager and their helpers; none is reachable from the shipped entry scene |
| Saved-data classes | Template GameState/LevelState: no live gameplay use, but referenced by saved files and by the save-preservation regression |
| Stale documentation in code | The test runner describes "all 22 catalog entries"; there are 30 |
| Churn hot spots (commits / lines added) | puzzle scene controller 10 / +306 · board 8 / +625 · catalog 7 / +1,228 · arrow view 6 / +364 |

Other inputs: the constitution (Principles I, II, V, VI); the architecture and progression-design
knowledge documents; the previous spec's progression-design learning (offline seeded search, slow
placement by coordinates).

### Reviewer Guidance

Check that each "Consolidate now" item fixes a stated problem and not a matter of taste. Check that
the geometry pin is in place and passing **before** any board-building code changes. Check that
nothing on the Defer list has crept into implementation.

## Minimum Sufficient Change

```yaml
minimum_sufficient_change:
  minimum_valuable_outcome: "Every catalog board's geometry is pinned; the duplicated head-ordering rule, direction mapping and catalog shape loop each have one definition; a current responsibility map exists; deferred work is recorded. All gates pass with no observable behavior change."
  explicitly_not_required:
    - "Moving puzzle content into data files or Godot resources"
    - "A puzzle generator or authoring tool"
    - "Splitting the board's input handling into a separate component"
    - "Renaming or moving files to make the directory tree look tidier"
    - "Rewriting or restructuring the test suite"
    - "Changes to the web showcase site"
    - "Raising the Godot version"
  acceptable_manual_operations:
    - "The desktop smoke test and the browser smoke test are performed by hand"
    - "The before/after measurements are gathered once by hand or with throwaway commands, not kept tooling"
```

## User Scenarios & Testing *(mandatory)*

The users of this spec are the developers and AI agents who make the next change. Players are
protected by the rule that nothing they can observe changes.

### User Story 1 - Catalog changes are caught before they ship (Priority: P1) ✅ Complete

A developer edits puzzle-building code, by refactoring it or adding a board. Any change to an
existing board's geometry, identity, title, group or position fails an automated check that names
the board.

**Why this priority**: It is the safety net for every other catalog change in this spec and for any
future authoring or generation work. Six boards have no such net today.

**Independent Test**: Change one cell of any `knot_*` board's tail and run the puzzle regression
gate; it fails and names that board. Revert the change and it passes.

**Acceptance Scenarios**:

1. **Given** the current catalog, **When** the puzzle regression gate runs, **Then** every one of
   the 30 entries is checked against a recorded exact-geometry identity, its id, title, group and
   catalog position.
2. **Given** a one-cell change to any entry's geometry, **When** the gate runs, **Then** it fails
   and names the changed entry.
3. **Given** an intentional new board appended to a group, **When** the gate runs, **Then** the
   failure says the new entry needs a recorded identity, and existing entries still pass.

---

### User Story 2 - One definition for each behavior-defining rule (Priority: P2)

A developer who needs to change how arrows are ordered, how a direction maps to a step, or how
vertex-path shapes become boards changes it in one place, and every user of that rule follows.

**Why this priority**: These duplicates decide observable behavior: which Open Move is shown, the
solver witness order and puzzle content versions. A partial edit would put the hint, solver and
content identity quietly out of step.

**Independent Test**: The puzzle regression gate, the save/input regression gate, Godot validation
and the geometry pin from Story 1 all pass unchanged. Each consolidated rule has exactly one
definition in production code.

**Acceptance Scenarios**:

1. **Given** any catalog board in any state, **When** an Open Move is requested, **Then** the same
   arrow is suggested as before the change.
2. **Given** any catalog board, **When** the solver runs, **Then** its witness order and metrics
   match the pre-change baseline exactly.
3. **Given** any catalog board, **When** its content version is computed, **Then** it matches the
   pinned value.
4. **Given** any arrow, **When** it is drawn or departs, **Then** its direction, path and departure
   travel match the pre-change behavior.

---

### User Story 3 - A newcomer can tell what each part of the code is for (Priority: P3)

A developer or agent new to the repository reads one current document. It shows which part of the
code owns puzzle rules, puzzle content, session state, presentation, input and template
integration. It also says which code is template example content and what is deliberately kept for
saved-data compatibility.

**Why this priority**: It meets acceptance criterion 1 and stops newcomers wasting time on dead or
unrelated systems. It is also cheap.

**Independent Test**: Give a reviewer the responsibility map. They can name the owner of each of
these: the blocking rule, the Open Move choice, the score formula, the group-scoped Next Puzzle,
pinch zoom, and the persisted saved-game state. They can also say which scenes are unreachable from
the shipped entry scene.

**Acceptance Scenarios**:

1. **Given** the responsibility map, **When** a reader looks up any production script, **Then** it
   is listed under exactly one responsibility, or under "template integration" or "template
   example".
2. **Given** the responsibility map, **When** a reader looks for the saved-data classes, **Then**
   the map explains why they are kept although gameplay does not use them.

---

### User Story 4 - Template example content no longer misleads (Priority: P3)

A developer browsing the scenes no longer finds a parallel "levels" system that the game never
uses.

**Why this priority**: It is a discoverability cost, not a defect, so it ranks below the rule
consolidation.

**Independent Test**: Every scene and script handled under this story is shown to be unreachable
from the shipped entry scene and the web build, saves made before the change still load, and all
gates pass.

**Acceptance Scenarios**:

1. **Given** the unreachable template example content, **When** this story is complete, **Then**
   it is gone from the project, and the responsibility map says where it came from and how to
   restore it.
2. **Given** a save file written before the change, **When** the game starts, **Then** progress and
   settings load unchanged.

---

### User Story 5 - Larger improvements are queued, not lost (Priority: P4)

The project owner can see which larger refactorings were considered, why each was deferred, and
what seam the future work would build on. None of it is implemented here.

**Why this priority**: It keeps this spec bounded (acceptance criteria 8 and 9) without losing the
analysis.

**Independent Test**: The deferred-work record lists each deferred item with its evidence, the
reason it was deferred, and the prerequisite this spec leaves in place.

**Acceptance Scenarios**:

1. **Given** the deferred-work record, **When** the owner reviews it, **Then** puzzle data
   extraction, puzzle generation and board input separation each appear as a separately bounded
   candidate with its trigger condition.

---

### Edge Cases

- A consolidated ordering rule could tie-break differently on equal keys. The geometry pins and
  the pre/post solver-witness and Open Move comparison over all 30 boards must catch this.
- The content-version hash depends on head ordering. If that changed, every pin would fail at once;
  that must be treated as a behavior change, never "fixed" by re-recording the pins.
- Re-recording a pinned value is allowed only for an intended content change, and this spec makes
  none. Any re-record during this spec is a defect.
- A template example scene might still be referenced indirectly, through an exported scene path, a
  shader-caching list, or an addon default. Reachability must be shown, not assumed, before removal.
- A save file can hold template saved-data objects. Removing those classes would break loading
  (Principle VI), so they are out of bounds whatever their apparent use.
- Moving or deleting a script with a class name or a uid file can break scene references and the
  headless runners that copy scripts by path. Every gate must be re-run after any such change.
- Touch behavior has been verified on one real phone only. This spec must not change the board's
  input code, so no new real-device verification is needed. If the plan finds it must, that change
  is out of scope.

## Clarifications

### Session 2026-10-15

- Q: What should happen to the unreachable template example content? → A: Remove it once
  reachability is proven, and record in the responsibility map how to restore it from the template.
  The saved-data classes stay.

## Requirements *(mandatory)*

### Functional Requirements

**Stage 1: Organization**

- **FR-001**: The project MUST have one current responsibility map in the existing architecture
  knowledge. It assigns every production script to one responsibility: puzzle rules and model,
  puzzle content, session state, presentation, input, scene flow, template integration, template
  example, or saved-data compatibility. It names the ownership boundaries players rely on (rules
  never depend on scenes or input). It updates existing knowledge rather than adding a parallel
  document.
- **FR-002**: Documentation inside the code and tests that contradicts current facts (for example,
  the test runner's catalog-entry count) MUST be corrected. Comments that are true but long MUST
  NOT be rewritten for style.
- **FR-003**: Files MUST NOT be moved or renamed only to improve directory appearance. A move is
  allowed only when the plan names the maintenance problem it fixes and shows every gate passing
  after the move.

**Stage 2: Targeted consolidation**

- **FR-004**: Before any change to code that builds catalog boards, the puzzle regression gate MUST
  check every catalog entry against a recorded exact-geometry identity, its id, title, group and
  catalog position, in one table covering all 30 entries. The existing per-subset fingerprints MAY
  be folded into it only if the stricter check stays in place. The pinned values MUST be recorded
  from the unmodified catalog.
- **FR-005**: The arrow head-ordering rule (row, then column) MUST have exactly one definition in
  production code, used by rule state (Open Move choice), the solver, the content version and the
  analyzer.
- **FR-006**: The mapping from an arrow direction to its unit step MUST have exactly one definition
  in production code, used by both the rules model and arrow presentation.
- **FR-007**: Every catalog builder that turns vertex-path shapes into a board MUST use the single
  existing shape-to-board helper rather than repeating its loop. Board literals, their order inside
  each builder, and the builder comments MUST stay exactly as they are.
- **FR-008**: Consolidation MUST NOT change the shape of any result a caller reads (solver result,
  analyzer report, rule-state snapshot, attempt results, web attempt payload, content version
  format).
- **FR-009**: Code shown to be unused by any shipped scene, test, or saved-data path MAY be
  removed. Each removal MUST be backed by reachability evidence in the plan.
- **FR-010**: Saved-data classes and anything a save file can reference MUST be kept unchanged
  (Principle VI).
- **FR-011**: Unreachable template example content (example game scene, example levels, template
  level select, example won/lost overlays, end credits, level loading screens, level-list state
  manager and their helpers) MUST be removed from the project once the plan shows each item is
  unreachable from the shipped entry scene, every scene the shipped flow loads, the web export and
  the tests. The responsibility map MUST record that this content came from the template and can be
  restored from the template addon if a level system is ever wanted. The saved-data classes are
  excluded from removal (FR-010). Any item whose reachability cannot be ruled out stays and is
  labelled "template example" in the map.

**Stage 3: Future readiness**

- **FR-012**: A deferred-work record MUST list, each with its supporting evidence, the reason it was
  deferred, the trigger that would justify a dedicated spec, and the seam this spec leaves:
  - puzzle content as data files or resources (seam: the single shape-to-board path plus the
    all-entry geometry pin);
  - programmatic puzzle generation (seam: the solver and analyzer as acceptance oracles; the
    progression-design learning; the uncommitted offline search noted there);
  - separating the board's input handling from its view management (evidence: board size and churn;
    trigger: the next input-method change; prerequisite: real-device re-verification);
  - unifying the three catalog authoring styles into one (the computed and literal-dictionary boards
    would have to be rewritten as literal data under the geometry pin).
- **FR-013**: The record MUST also list what was deliberately left alone, with the reason, so later
  reviews don't reopen it. At minimum: the analyzer (513 lines, one responsibility, two commits);
  the rule state and solver; the viewport transform; the per-test-file check helpers (each runner
  isolates its scripts in a temporary project, so sharing them would complicate the runners); the
  one-line scripts that extend template scenes (Principle II); the static session and scoreboard
  holders; and the two-line duplicated navigation handlers in the puzzle scene controller.

**Behavior preservation**

- **FR-014**: The pre-change baseline MUST be captured before the first consolidation change and
  compared after the last one, covering for every catalog entry: geometry identity, solver
  validity, solvability, witness order and metrics; Open Move suggestion at every state along the
  witness; analyzer report. The comparison MUST show no difference.
- **FR-015**: Both headless regression gates and Godot editor validation MUST pass after the
  change. A desktop smoke test MUST cover a Foundations puzzle, a Puzzle Lab large-canvas puzzle
  and the Reference Knot: select, blocked feedback, departure, Open Move, zoom, pan, fit, results,
  Next Puzzle, Replay, Level Select and pause. A browser smoke test of the web build MUST be
  recorded (Principle V). Untested browsers and devices are recorded as not tested.
- **FR-016**: The work MUST NOT add gameplay features, change UI, change any puzzle, add external
  dependencies, add mandatory development gates, or add permanent metrics or reporting tooling.

### Key Entities

- **Catalog entry**: a puzzle's stable id, display title, purpose group, position in the catalog,
  and board geometry.
  Domain invariant: every existing entry's id, title, group, catalog order and exact geometry
  (board size, every head, direction and ordered tail cell) is identical before and after this
  spec. Its content version, which is a pure function of geometry, therefore never changes.
- **Head ordering**: the deterministic row-then-column order of arrow heads.
  Domain invariant: the order, including its tie-break, is identical before and after. It decides
  the Open Move suggestion, the solver witness and the content-version text.
- **Saved progress and settings**: player data persisted between runs.
  Architectural constraint: data written before this spec loads unchanged after it.
- **Rules boundary**: puzzle rules and state stay independent of scenes, input and presentation.
  Architectural constraint: consolidation may move shared definitions toward the rules model, never
  rules logic toward presentation.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 30 of 30 catalog entries are protected by an exact-geometry check (baseline: 24 of
  30), shown by a deliberate one-cell change in a `knot_*` board failing the gate.
- **SC-002**: Each consolidated rule (head ordering, direction step, shape-to-board) has exactly one
  definition in production code (baseline: 4, 2 and 9 respectively).
- **SC-003**: The pre/post comparison in FR-014 shows zero differences across all 30 entries.
- **SC-004**: Both headless gates and Godot validation pass. The desktop and browser smoke tests are
  recorded as passed, with untested environments listed.
- **SC-005**: A reviewer using only the responsibility map correctly answers all six ownership
  questions in User Story 3.
- **SC-006**: The before/after record reports the measures from the evidence baseline (file count,
  lines, largest files, duplication counts, pin coverage, unreachable content), so the improvement
  can be read from the record itself.
- **SC-007**: Every deferred and left-alone item in FR-012 and FR-013 is recorded with its reason,
  and none of them was implemented.

## Assumptions

- The project targets Godot 4.4, per the project settings and the constitution. The request
  mentions Godot 4.7; this spec does not change the engine version.
- Context gathered: constitution 2.3.0, architecture and reference knowledge, all prior specs'
  directory names, catalog and test sources, and git history. The write-spec context script was
  not run; the context was gathered directly from the repository instead.
- "Production code" means project GDScript under the scripts and scenes folders. The addon, tests,
  web site and temporary planning files are excluded from the measures.
- The web showcase site (TypeScript) is out of scope. The web build is in scope only for the
  browser smoke test, because the game it embeds is rebuilt.
- The geometry identity used for pins is the existing content-version scheme, or something
  stronger. No new identity scheme is introduced.
- The before/after record and the deferred-work record live with this spec, and the responsibility
  map lives in durable knowledge. The responsibility map must not refer back to this spec.

## Out of Scope

- Converting the catalog to data files, Godot resources or any external format.
- A puzzle generator, authoring tool, or committed offline search script.
- Splitting, rewriting or retuning the board's mouse, keyboard, gamepad or touch handling.
- Rewriting the test suite or adding shared test infrastructure.
- Any change to puzzle content, rules, scoring, hints, progression, visuals or menus.
- Changes to the template addon or to DevSpark.
