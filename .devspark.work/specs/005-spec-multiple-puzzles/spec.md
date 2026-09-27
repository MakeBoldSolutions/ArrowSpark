---
classification: full-spec
risk_level: medium
risk_profile: internal
change_type: brownfield
target_workflow: specify-full
required_artifacts: spec, plan, tasks
recommended_next_step: plan
required_gates: checklist, analyze, critic
route_intent: full-spec
depends_on: []
supersedes: []
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
status: Draft
---

# Feature Specification: Multiple Authored Puzzles and Session-Only Puzzle Selection

**Feature Branch**: `005-spec-multiple-puzzles`
**Created**: 2026-09-27
**Status**: Draft
**Input**: Expand ArrowGame from one hardcoded puzzle into a small catalog of eight handcrafted puzzles, selectable and played through the same reusable puzzle scene, entirely session-only.

## Product Owner TLDR

ArrowGame currently ships exactly one puzzle, hardcoded into the controller. This spec introduces a small catalog of eight handcrafted puzzles that a player can browse, select, replay, and advance through — all using the exact same puzzle engine, rendering, and departure behavior already proven in specs 001–004. Nothing here is persistent: no unlocks, no saved completion, no difficulty labels. The point is to prove the architecture supports real content before any of that is designed.

## Clarifications

### Session 2026-09-27

- Q: Does pause-menu Restart also need to reload the currently-selected puzzle (not always puzzle 1), given it likely shares the same scene-reload mechanism as Results Replay? → A: Yes — pause-menu Restart MUST also honor the currently-selected puzzle, with the same fresh-attempt guarantee as Results Replay.
- Q: Must the new Level Select screen and Results Next Puzzle action support full keyboard/gamepad navigation per constitution Principle III? → A: Yes — both are new interactive surfaces and MUST support full keyboard/gamepad navigation, matching existing menu conventions.

## Rationale Summary

### Core Problem

The puzzle domain, solver, rendering, and departure systems are already generic — `PuzzleDefinition` is plain structural data and `PuzzleSolver.analyze()` already accepts any definition — but the controller (`scenes/puzzle/arrow_puzzle.gd`) hardcodes `PuzzleDefinition.create_fixed()` as its only source of content. ArrowGame cannot demonstrate it is more than a one-puzzle prototype until that single coupling point is replaced with a real, if small, content model.

### Decision Summary

Introduce a small, ArrowGame-specific, plain-GDScript puzzle catalog (stable ID + display title + ordering + a way to construct a fresh `PuzzleDefinition`) that the controller selects from instead of calling `create_fixed()` directly. Track which puzzle is currently selected in a small session-only holder — never in the template's persistent `GameState`/`GlobalState`. Add a minimal Level Select screen and a Next Puzzle results action, both built directly against the catalog rather than the inherited scene-per-level template infrastructure.

### Key Drivers

- Prove the puzzle engine (domain, solver, rendering, path-following departure) generalizes to real content, not just one board.
- Preserve the deliberate session-only boundary established in spec 004 — no persistent writes to `user://global_state.tres`.
- Avoid the inherited template's scene-per-level, persistence-first Level system, which is architecturally mismatched with ArrowGame's reusable-scene/data-driven design.
- Produce genuinely varied handcrafted content (not eight trivial variations) as future evidence for puzzle-generation and difficulty-analysis work, without building either of those systems now.

### Source Inputs

- [User brief, preserved verbatim](source-brief.md), including explicit implementation preferences, the eight-puzzle design brief, and verification coverage.
- This session's own repository research (current content model, existing but unused template Level infrastructure, save/progression boundary, content-representation tradeoffs) confirming the recommended architecture before this spec was drafted.
- Completed specs 001–004: puzzle domain/solver (001, 002), continuous arrow rendering (003), and path-following departure (004) — all of which this spec reuses unchanged.
- Project constitution: simple project-level changes, preserved controls/settings, responsive gameplay, honest automated/manual verification.
- User explicitly confirmed full-spec route, medium risk, and branch creation.

### Tradeoffs Considered

- Reusing the addon's `LevelListManager`/`LevelListLoader`/`GameState` template infrastructure: rejected — it assumes one scene per level and writes to persistent save state on every selection, both incompatible with a session-only, single-reusable-scene, data-driven puzzle model.
- Converting `PuzzleDefinition` to a Godot `Resource` or authoring puzzles as `.tres`/JSON: rejected for this scale — eight handcrafted puzzles are more reviewable, testable, and deterministic as plain GDScript, matching the existing `create_fixed()` precedent; revisit only if content volume or non-programmer authoring becomes a real need.
- Adding identity/order fields directly onto `PuzzleDefinition`: rejected — keeps a domain-pure structural class free of presentation/catalog concerns, consistent with the existing rule/presentation boundary.
- Persisting current-puzzle/completion state now: rejected — out of scope by explicit user direction; a session-only holder is the smallest mechanism that satisfies Level Select, Replay, and Next Puzzle without touching save data.

### Architectural Impact

A new small content layer (the puzzle catalog) sits between the domain (`PuzzleDefinition`, `PuzzleSolver`, `PuzzleState`) and presentation (the reusable puzzle scene, Level Select, Results). The controller gains a session-scoped "which puzzle is selected" dependency instead of a hardcoded call. No existing domain, solver, rendering, or departure code changes behavior — this spec is additive at the selection boundary only. Level Select and the Results "Next Puzzle" action are new, small, catalog-driven UI pieces; no new gameplay scene is introduced, and no existing scene structure changes shape.

### Reviewer Guidance

Check that: `PuzzleDefinition` gained no identity/catalog fields; nothing writes to `GlobalState`/`GameState`/`user://global_state.tres`; Level Select and Next Puzzle are built against the catalog, not the addon's `LevelListManager`; every one of the eight puzzles is solver-validated by an automated gate rather than only played manually; Replay, pause-menu Restart, and Next Puzzle correctly reset attempt state while preserving/advancing puzzle identity; Level Select and Next Puzzle are fully keyboard/gamepad navigable; and path-following departure (spec 004) still behaves identically regardless of which puzzle is loaded.

### Assumptions and Defaults

- Exact catalog GDScript structure (single file vs. small module, entry shape) is a planning-level decision, not a spec-level one; this spec constrains it only to "small and explicit," plain GDScript, no large content-management framework.
- Exact stable IDs, display titles, and board geometry for the eight puzzles are chosen during implementation and then treated as stable; this spec constrains only the structural-variety goals (FR-005) and that every puzzle is solver-confirmed solvable.
- The session-scoped current-puzzle mechanism's exact form (autoload, static holder, or equivalent) is left to planning, constrained only to: session-only, never touching existing persistent save storage, and narrowly scoped to "which catalog puzzle should load" (FR-007).
- Godot 4.4 is the declared engine baseline (unchanged from prior specs); the same environment limitation noted in spec 004 (only a newer 4.7.x executable available for automated verification in some environments) may recur and, if so, is disclosed rather than silently skipped.
- The existing hidden `%LevelSelectContainer`/`_setup_level_select()` scaffolding in `main_menu_with_animations.gd` may be reused as a mounting point for the new Level Select UI, but its current wiring (which targets the addon's example `GameStateExample`-based script) is not reused as-is.

### Out of Scope

New puzzle mechanics, procedural generation, difficulty classification/scoring, persistent progression (completion, current level, unlocks, best score/accuracy, stars, achievements, campaign completion), daily/random puzzle selection, puzzle authoring tooling, JSON or Resource-file content formats, scene-per-level architecture, solver redesign, scoring-rule changes, audio/haptics, mobile deployment, broad Main Menu or Results redesign, and Level Select from the pause menu.

### Retention

This temporary bundle remains under `.devspark.work/` until release archival. Production code, tests, and durable knowledge must not reference its identifiers or paths. Implementation updates current durable knowledge where behavior changes; this authoring step does not modify runtime code or knowledge.

## User Scenarios & Testing

### User Story 1 - Play any authored puzzle through the same engine (Priority: P1)

As a player, I want every authored puzzle to play through the exact same rules, rendering, and departure behavior I already know, so the game feels consistent regardless of which puzzle I'm on.

**Why this priority**: This is the core architectural proof the spec exists to deliver — without it, nothing else (Level Select, Replay, Next Puzzle) has real content to operate on.

**Independent Test**: Select each of the eight catalog puzzles in turn (via a direct selection path, without necessarily going through the full Level Select UI) and confirm each one is playable start-to-finish with correct rules, scoring, and departure behavior.

**Acceptance Scenarios**:

1. **Given** the main menu, **When** the player selects New Game, **Then** the first puzzle in catalog order loads and is immediately playable, exactly as the single fixed puzzle is today.
2. **Given** any catalog puzzle is loaded, **When** the player plays it, **Then** blocking rules, atomic removal, scoring, mistakes, accuracy, hover/blocked feedback, continuous arrow rendering, and path-following departure all behave identically to the existing fixed puzzle.
3. **Given** the full catalog, **When** each entry's `PuzzleDefinition` is constructed and validated, **Then** every one is structurally valid and solver-confirmed solvable with a zero-mistake witness.
4. **Given** two different catalog puzzles, **When** one is played and mutated during an attempt, **Then** the other puzzle's definition and any future attempt built from it are unaffected.

---

### User Story 2 - Browse and choose a puzzle (Priority: P1)

As a player, I want to see all available puzzles and pick one directly, so I'm not limited to playing only in catalog order.

**Why this priority**: This is the player-facing capability that makes "multiple puzzles" a real experience rather than an internal data change; it's independently valuable even before Replay/Next Puzzle exist.

**Independent Test**: From the main menu, open Level Select, confirm all eight puzzles appear in deterministic order with distinguishing identity, select one that isn't first, and confirm that exact puzzle loads and its identity is visible in the gameplay HUD.

**Acceptance Scenarios**:

1. **Given** the main menu, **When** the player opens Level Select, **Then** all eight puzzles are listed in deterministic catalog order, each showing enough identity (e.g. number and short title) to distinguish it, with none locked or hidden.
2. **Given** Level Select is open, **When** the player picks a puzzle that is not first in order, **Then** that exact puzzle's board loads, and the gameplay HUD displays that puzzle's identity.
3. **Given** the player has not opened Level Select, **When** they select New Game, **Then** they are not forced through Level Select first.

---

### User Story 3 - Move between puzzles after completion (Priority: P2)

As a player, I want to replay the puzzle I just finished or move on to the next one without navigating back through menus, so finishing a puzzle flows naturally into what I do next.

**Why this priority**: This depends on User Stories 1 and 2 already working (a puzzle is loaded and selectable); it completes the minimal multi-puzzle loop but isn't required to prove the core architecture.

**Independent Test**: Complete a puzzle that is not last in catalog order; confirm Replay restarts that same puzzle with fully reset attempt state, and Next Puzzle advances to the following catalog entry with fully reset attempt state. Separately, complete the last catalog puzzle and confirm no Next Puzzle action is shown.

**Acceptance Scenarios**:

1. **Given** a completed puzzle's results, **When** the player selects Replay, **Then** the same puzzle restarts with a completely fresh `PuzzleState` (zero mistakes, full remaining count, no departing views left over) and the same puzzle identity shown.
2. **Given** a completed puzzle that is not the last in catalog order, **When** the player selects Next Puzzle, **Then** the next catalog entry loads as a fresh attempt with no carried-over mistakes, score, active state, or departure state.
3. **Given** the last catalog puzzle's results, **When** the player views the available actions, **Then** no Next Puzzle action is shown or enabled, while Replay, Level Select, and Main Menu remain available.
4. **Given** any completed puzzle's results, **When** the player views them, **Then** the results correspond to the puzzle actually played, with the existing total-arrows/mistakes/score/accuracy metrics unchanged.

### Edge Cases

- Selecting Next Puzzle must be impossible/absent on the final catalog puzzle; there is no wraparound to puzzle 1.
- Switching puzzles (via Replay, Next Puzzle, or Level Select) while a previous attempt still has in-flight departing arrows must dispose those views and cancel their callbacks cleanly, with no stale completion signal reaching the new attempt.
- Selecting the currently-loaded puzzle again from Level Select must still produce a fully fresh attempt, not a no-op or a stale one.
- A catalog entry's `PuzzleDefinition` must be freshly constructed per attempt request; repeatedly requesting the same ID must never return a definition mutated by a prior attempt.
- New Game, Level Select, Replay, and Next Puzzle must never write to `GlobalState`/`GameState`/`user://global_state.tres`, even across many puzzle switches in one session.
- Puzzle identity display in the HUD must not shrink or corrupt the existing responsive board layout at the supported window sizes.
- Pausing mid-puzzle on a non-first catalog puzzle and choosing pause-menu Restart (not Results Replay) must reload that same puzzle, not silently fall back to puzzle 1, since both actions share the same underlying scene-reload mechanism today.
- A player using only keyboard or only gamepad input must be able to open Level Select, select any of the eight puzzles, and (after completion) trigger Next Puzzle — none of this spec's new UI may be mouse-only.

## Requirements

### Functional Requirements

- **FR-001**: The system MUST provide a puzzle catalog of exactly eight handcrafted, structurally distinct puzzles, each exposing a stable string ID, a short display title, deterministic catalog order, and a way to construct a fresh `PuzzleDefinition`.
- **FR-002**: Catalog puzzle identity (stable ID) MUST be independent of array position, scene filenames, resource filenames, display title, and filesystem paths. Ordering and identity MUST be separate concepts, both exposed by the catalog.
- **FR-003**: `PuzzleDefinition` MUST NOT gain any catalog/progression fields (stable ID, display title, level number, unlocked state, completion state, best score, difficulty classification); it remains anonymous structural puzzle data (dimensions, arrow heads, directions, ordered tail geometry) as today.
- **FR-004**: The eight authored puzzles MUST be represented as plain GDScript-authored content (consistent with the existing `PuzzleDefinition.create_fixed()` precedent) — not as Godot `Resource`/`.tres` assets, JSON, or one `.tscn` per puzzle.
- **FR-005**: The eight puzzles MUST provide meaningfully different structures covering, in aggregate: a simple/obvious introduction, a first-bend shape, multi-turn bent shapes, a dependency chain (removing one arrow unlocks another), a forced-sequence state, a state with multiple legitimate legal choices, a denser/more-arrow board, and a board requiring subtler blocker reasoning. None of the eight may be labeled with a difficulty tier (Easy/Medium/Hard or equivalent).
- **FR-006**: The reusable puzzle scene/controller MUST replace its direct dependency on `PuzzleDefinition.create_fixed()` with selection of a definition from the puzzle catalog, resolved before a new attempt is constructed. The same scene MUST be able to play any valid catalog entry without scene changes or puzzle-specific presentation code.
- **FR-007**: The system MUST track which catalog puzzle is currently selected using a session-only mechanism (cleared each app launch) that is never written to `GlobalState`, `GameState`, `LevelState`, or `user://global_state.tres`, and never reuses inherited template progression state for this purpose.
- **FR-008**: Selecting New Game from the Main Menu MUST start the first puzzle in catalog order directly, without requiring the player to visit Level Select first, and MUST NOT reset or mutate inherited persistent save data (preserving the existing no-reset guarantee).
- **FR-009**: The system MUST provide a Level Select screen, reachable from the Main Menu, listing all eight catalog puzzles in deterministic order with sufficient per-puzzle identity (at minimum number and short title) for the player to distinguish them. All eight MUST be selectable immediately; the system MUST NOT introduce locked/unlocked states. Level Select MUST be built directly against the puzzle catalog and MUST NOT require one scene per puzzle, the addon's `GameState` level state, `level_won`/`level_lost` semantics, or writes to existing save storage. Level Select MUST NOT be added to the pause menu in this spec. Per constitution Principle III (Accessible, Configurable Controls), Level Select MUST support full keyboard/gamepad navigation and focus traversal, matching existing menu conventions (e.g. Results' Replay/Main Menu focus behavior).
- **FR-010**: Both Results Replay and the existing pause-menu Restart MUST restart the currently selected puzzle (never silently defaulting to puzzle 1) with a completely fresh `PuzzleState`, resetting active arrows, mistakes, score, accuracy counters, completion state, and presentation/departure state, while preserving the selected puzzle's identity. This applies uniformly because both already reload via the same scene-reload mechanism today.
- **FR-011**: The Results panel MUST offer a Next Puzzle action whenever a puzzle other than the last in catalog order was just completed; selecting it MUST select the next catalog entry and start a fresh attempt from its `PuzzleDefinition`, carrying over no mistakes, score, active state, or departure state from the prior puzzle. On the last catalog puzzle, Next Puzzle MUST NOT be shown or enabled; Replay, Level Select, and Main Menu MUST remain available. Per constitution Principle III, the Next Puzzle action MUST be reachable via keyboard/gamepad navigation alongside the existing Replay/Main Menu controls.
- **FR-012**: The Results panel MUST continue to report total arrows, mistakes, score, and accuracy exactly as today, with only the minimum addition necessary to make clear which puzzle was completed; no broader Results redesign is in scope.
- **FR-013**: The gameplay HUD MUST display a puzzle identity indicator (e.g. puzzle number and short title) reflecting the puzzle actually loaded, sized to a single line no taller than the existing RemainingLabel/MistakesLabel HUD row, without breaking the existing responsive layout at supported window sizes.
- **FR-014**: A permanent, automated content regression gate MUST enumerate the entire puzzle catalog (without loading presentation scenes) and, for every entry: verify its stable ID is present, verify all IDs are unique, construct a fresh `PuzzleDefinition`, verify structural validity via existing validation, run `PuzzleSolver.analyze()`, verify solvability, obtain the witness, replay it against a fresh `PuzzleState`, and verify it clears the puzzle with zero mistakes. This gate MUST use the existing domain/solver pipeline rather than duplicating validity logic in the catalog, and MUST fail if any authored puzzle is malformed or unsolvable.
- **FR-015**: Obtaining a `PuzzleDefinition` from the catalog MUST be safe for a fresh attempt: playing or mutating one attempt's runtime state MUST NOT corrupt the catalog definition, a subsequent attempt at the same puzzle, or any other puzzle's definition. Repeated requests for the same ID MUST behave deterministically.
- **FR-016**: Existing domain behavior MUST remain unchanged for every catalog puzzle: structural validation, blocking rules, immediate atomic removal, `PuzzleState` semantics, solver behavior, scoring, mistake counting, accuracy, unlimited attempts, whole-cell hit testing, head/tail input equivalence, and hover/blocked state behavior.
- **FR-017**: Existing spec-004 path-following departure behavior MUST remain unchanged regardless of which catalog puzzle is loaded: immediate logical removal independent of visual departure, bent arrows feeding through their existing paths, departing arrows excluded from blocking/interaction, independent concurrent departures, and the pending-departure completion barrier. Switching puzzles (Replay, Next Puzzle, Level Select) MUST cleanly dispose of any previous attempt's departing views and callbacks before the next attempt begins.
- **FR-018**: This spec MUST NOT introduce procedural puzzle generation, difficulty classification/scores/labels, persistent puzzle completion/current-level/unlock state, achievements, stars, best-score/accuracy persistence, campaign completion, daily/random puzzle selection, puzzle authoring tooling, a scene-per-level architecture, new puzzle mechanics, solver redesign, scoring changes, or broad Main Menu/Results redesign.
- **FR-019**: Verification MUST include the automated domain/content gate (FR-014), scene/integration tests covering the navigation flows in this spec (New Game, Level Select, Replay, pause-menu Restart, Next Puzzle, last-puzzle suppression, state isolation between puzzles, save-data non-interference), manual keyboard/gamepad navigation verification of Level Select and the Next Puzzle action (constitution Principle III), and manual play of all eight puzzles recording readability/completability and any subjective difficulty observations (which must not alter this spec's scope).
- **FR-020**: Implementation MUST update affected durable presentation/architecture knowledge to describe the puzzle catalog, the domain/catalog boundary, session-only current-puzzle tracking, and the future procedural-generation seam (`PuzzleDefinition` as the shared boundary for both authored and future generated content) — without durable backlinks to this temporary spec bundle.

### Key Entities

- **Puzzle Catalog Entry**: A presentation/content-layer record pairing a stable string ID, a short display title, a deterministic order position, and a means of constructing a fresh `PuzzleDefinition`. Owns no gameplay rules or mutable attempt state.
- **PuzzleDefinition** (existing, unchanged in shape): Anonymous structural puzzle data — board dimensions, arrow head positions, directions, ordered tail geometry. Continues to carry no identity, ordering, or progression concerns.
- **Session-Scoped Current Puzzle**: Ephemeral, in-memory-only state naming which catalog entry is currently selected for the reusable puzzle scene to load. Cleared on every app launch; never persisted.

## Success Criteria

### Measurable Outcomes

- **SC-001**: All eight catalog puzzles are structurally valid and solver-confirmed solvable via the existing domain/solver pipeline, each with a replayable witness that completes with zero mistakes, verified by an automated regression gate with zero manual steps.
- **SC-002**: A player can go from Main Menu to a fully playable puzzle in one action (New Game) or via Level Select in two actions (open Level Select, pick a puzzle), for every one of the eight puzzles.
- **SC-003**: After completing any non-final catalog puzzle, both Replay (same puzzle, fresh state) and Next Puzzle (following puzzle, fresh state) are available and behave correctly in 100% of tested transitions; after the final puzzle, Next Puzzle is absent/disabled in 100% of tested cases.
- **SC-004**: Across repeated puzzle switches (Replay, Next Puzzle, Level Select) in a single session, no attempt state (mistakes, score, active arrows, departing views) leaks between puzzles, and no write occurs to existing persistent save storage, verified by automated tests using isolated user data.
- **SC-005**: Every existing spec 001–004 behavior (domain rules, solver, scoring, continuous rendering, path-following departure, hover/blocked feedback) is unchanged when exercised through any of the eight catalog puzzles, verified by the existing regression suites continuing to pass alongside new coverage.
- **SC-006**: All required automated and manual verification for this spec is recorded, with any genuinely unavailable check (e.g. hardware-dependent manual play) disclosed honestly rather than reported as passed.
