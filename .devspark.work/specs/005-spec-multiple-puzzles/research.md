# Phase 0 Research: Multiple Authored Puzzles and Session-Only Puzzle Selection

No `[NEEDS CLARIFICATION]` markers remain in spec.md or the Technical Context below; this
research resolves the implementation-level decisions the spec explicitly deferred to planning.

## Decision: Puzzle catalog as a static-registry RefCounted class, not a Resource/JSON/scene-per-puzzle

**Decision**: `scripts/puzzle/puzzle_catalog.gd`, `class_name PuzzleCatalog extends RefCounted`,
holding an ordered `Array[Dictionary]` of `{id: String, title: String, build: Callable}` built
once by a private static function, mirroring `PuzzleDefinition.create_fixed()`'s existing
literal-construction style. Each `build` Callable is a static per-puzzle function
(`_build_intro()`, `_build_first_bend()`, …) that constructs and returns a fresh
`PuzzleDefinition`, exactly like `create_fixed()` does today — no caching, no shared mutable
state, so isolation (FR-015) falls out for free from the existing construction pattern rather
than requiring new defensive-copy logic.

**Rationale**: FR-004 explicitly requires plain GDScript content, ruling out `Resource`/`.tres`
and JSON. `PuzzleDefinition` itself stays `RefCounted` and gains no fields (FR-003), so the
catalog must be a separate layer. A static registry class needs no scene tree, no autoload
registration, and no serialization — the smallest mechanism that satisfies "stable ID +
ordering + title + definition access" (spec's Puzzle Catalog section).

**Alternatives considered**:
- One `.tres` `PuzzleDefinition`-as-`Resource` per puzzle: rejected by FR-004/spec's Content
  Representation section outright.
- A `Dictionary[String, PuzzleDefinition]` built once and reused: rejected — a single shared
  `PuzzleDefinition` instance per ID would violate FR-015 (a definition mutated by attempt A
  must not affect attempt B) unless deep-copied on every access, which is strictly more
  machinery than just rebuilding it fresh from a literal, as `create_fixed()` already does.
- A dedicated `PuzzleCatalogEntry` class (`extends RefCounted`) instead of a `Dictionary`:
  viable and slightly more type-safe, but the codebase's own domain layer already favors plain
  `Dictionary`/`Array` for structured data (`PuzzleDefinition.arrows`/`tails`), so a `Dictionary`
  entry shape is the more consistent choice and avoids introducing a new public type for three
  fields.

## Decision: Session-scoped current puzzle as a static var on a plain class, not an autoload

**Decision**: `scripts/puzzle_session.gd`, `class_name PuzzleSession extends RefCounted`, with a
single `static var _current_id: String = ""` and static accessor functions
(`get_current_id()`, `set_current_id()`, `advance_to_next()`, `has_next()`). `get_current_id()`
lazily defaults to `PuzzleCatalog.id_at(0)` whenever `_current_id` is empty or no longer a valid
catalog ID, so the very first read (before any New Game/Level Select action) is still safe.

**Rationale**: `GameVisualStyle` already establishes the precedent of a `static var` cache
(`_theme`) on a plain `RefCounted class_name` script for state that should persist for the
running process's lifetime without scene-tree involvement — exactly the "session-only, cleared
each app launch" requirement (FR-007). A GDScript static var is bound to the running process, not
to any node or scene, so it survives `SceneLoader.reload_current_scene()`/`load_scene()` calls
identically to an autoload, but needs no `project.godot` autoload registration and no `_ready()`
lifecycle to reason about.

**Alternatives considered**:
- A new autoload singleton (`Node`, registered in `project.godot`): functionally equivalent for
  "survives scene reloads, resets on relaunch," but heavier than needed — it would be the only
  autoload in the project whose entire job is one string field, and the constitution's Principle
  I ("keep changes small... justify new abstractions with a concrete need") favors the smaller
  static-var mechanism given the existing `GameVisualStyle` precedent already proves it works for
  this codebase's process-lifetime-state need.
- Storing current-puzzle-id on the `PuzzleBoard`/`ArrowPuzzle` node itself: rejected — it would
  not survive `SceneLoader.reload_current_scene()` (a full scene reconstruction), so Replay and
  pause-menu Restart could not read it back.

## Decision: Replay and pause-menu Restart require zero new code (confirmed, not assumed)

**Decision**: No new wiring is needed for either. Both already call
`SceneLoader.reload_current_scene()` (confirmed in `.knowledge/architecture/arrow-puzzle.md`:
"Replay and pause-menu Restart both call `SceneLoader.reload_current_scene()`"). Because
`PuzzleSession`'s `_current_id` is a process-lifetime static var, a scene reload does not reset
it — `arrow_puzzle.gd::_start_new_attempt()` reading `PuzzleSession.get_current_id()` on the
freshly reloaded scene naturally reproduces the same puzzle. This directly satisfies the
Clarifications session's answer that pause-menu Restart must honor the currently selected
puzzle, with no separate code path.

**Rationale**: Verified by reading `scenes/puzzle/arrow_puzzle.gd` (`_on_results_replay_requested`
calls `SceneLoader.reload_current_scene()`) and the addon's pause menu controller wiring
documented in the same knowledge node. This is a genuine repository fact, not an assumption.

**Alternatives considered**: Explicitly passing the current puzzle ID through a reload parameter
— unnecessary; `SceneLoader.reload_current_scene()` takes no such parameter and none is needed
given the static-var mechanism already carries the value across the reload.

## Decision: Next Puzzle reuses the same reload mechanism

**Decision**: `_on_results_next_puzzle_requested()` on the controller calls
`PuzzleSession.advance_to_next()` then `SceneLoader.reload_current_scene()` — identical shape to
the existing Replay handler, with one extra call before the reload.

**Rationale**: Reuses the exact same fresh-attempt guarantee Replay already has (a full scene
reconstruction), so FR-011's "carry over no mistakes, score, active state, or departure state"
requirement is satisfied by the same mechanism that already gives Replay its fresh-state
guarantee — no new attempt-reset logic needs to be written or tested separately.

**Alternatives considered**: Calling `_start_new_attempt()` directly without a scene reload
(in-place reset): rejected — this would require manually re-verifying every piece of state
`_ready()`/scene reconstruction currently resets for free (tweens, departing views, pause menu
controller re-enable, etc.), duplicating guarantees the existing reload path already provides.

## Decision: Level Select reuses the existing hidden scaffolding's mounting point, not its script

**Decision**: Reuse `main_menu_with_animations.tscn`'s existing `%LevelSelectContainer` mount
point and `LevelSelectButton` (currently `visible = false`, `level_select_packed_scene = null`
per direct inspection of the `.tscn`). Set the button `visible = true`, point
`level_select_packed_scene` at a new `scenes/menus/main_menu/puzzle_select_menu.tscn` (new script
`puzzle_select_menu.gd`) built directly against `PuzzleCatalog`, and change
`_setup_level_select()`'s signal wiring from the addon example's `level_selected` (no-arg,
`GameStateExample`-backed) to a new `puzzle_selected(id: String)` signal that sets
`PuzzleSession` before loading the game scene.

**Rationale**: The button, sub-menu open/close mechanics (`_open_sub_menu`/`_close_sub_menu`,
keyboard/gamepad-navigable per the base `MainMenu`'s existing `_input` focus handling), and
container are already present and already keyboard/gamepad accessible via the same mechanism
every other sub-menu (Options, Credits) uses — reusing them satisfies the Clarifications
session's keyboard/gamepad requirement for free. Only the *content* (an `ItemList`/button list
bound to `PuzzleCatalog` instead of `GameStateExample`'s scene-file list) is new.

**Alternatives considered**: Building an entirely new sub-menu mount point: rejected — duplicates
existing, already-accessible menu infrastructure for no benefit.

## Decision: Catalog validation as a third pure-isolation script in the existing bare temp project

**Decision**: Add `tests/puzzle_catalog_check.gd` (new) to the same isolated temporary project
`tests/run_puzzle_regressions.py::run_rule_regressions()` already builds for
`puzzle_regression.gd` — copy `puzzle_catalog.gd` alongside the existing
`puzzle_definition.gd`/`puzzle_state.gd`/`puzzle_solver.gd`/`puzzle_feedback.gd`/
`puzzle_results_format.gd`, then run `puzzle_catalog_check.gd` as a second `--script` invocation
in that same temp project, with its own marker `PUZZLE_CATALOG_FAILURES=0`.

**Rationale**: `puzzle_catalog.gd` depends only on `PuzzleDefinition` (and, transitively for
`PuzzleSolver`/`PuzzleState` in the test itself) — no `GameVisualStyle`, no font/resource
preloads — so, unlike `arrow_departure_geometry.gd` in spec 004 (which needed style-ratio
constants and therefore stayed out of the bare-project copy list), it is safe to add directly to
the existing pure-rule-isolation project rather than spinning up a fourth temporary project.

**Alternatives considered**: A brand-new isolated temp project (matching spec 004's
`run_geometry_regressions` pattern): unnecessary extra process/timeout overhead given no
resource-loading conflict exists here.

## Decision: Eight puzzle design brief (IDs, titles, structural intent)

Exact board geometry is an implementation-time task per spec's own Assumptions and Defaults
section; this fixes the stable IDs, titles, and structural intent so tasks.md can enumerate
concrete geometry deterministically without re-deciding scope mid-implementation.

| # | ID | Title | Structural intent |
|---|---|---|---|
| 1 | `intro` | Simple Introduction | All single-cell or short straight arrows, every arrow legal from the start; the "obvious" first puzzle. |
| 2 | `first_bend` | First Bend | Mostly straight arrows plus exactly one single-bend tail, introducing bent-arrow reasoning without complexity. |
| 3 | `multi_bend` | Multiple Bends | Includes at least one long, multi-turn tail exercising the existing multi-bend geometry path. |
| 4 | `dependency_chain` | Dependency Chain | A clear A-blocks-B(-blocks-C) chain where removing one arrow visibly unlocks the next. |
| 5 | `forced_sequence` | Forced Sequence | At most one legal choice at each step for most of the solve (a `forced_states`-heavy witness per the solver's own metrics). |
| 6 | `multiple_choices` | Multiple Choices | At least one state with 2+ simultaneously legal arrows (a genuine `branching_states` moment). |
| 7 | `dense_board` | Dense Board | A larger grid (e.g. 6x6+) with more arrows than the shipped fixed board, exercising ownership/readability at higher density. |
| 8 | `subtle_blockers` | Subtle Blockers | Blockers positioned so the blocking relationship isn't visually obvious at a glance (e.g. a short tail cell sitting just inside another arrow's forward escape ray). |

Every entry MUST pass `PuzzleDefinition.is_valid()` and `PuzzleSolver.analyze().solvable == true`
with a zero-mistake witness (FR-014) — enforced by the new automated gate, not by design
inspection alone.

## Resolved Technical Context

See `plan.md`'s Technical Context section for the consolidated, resolved values (language,
dependencies, storage, testing, platform, constraints, scale) — no unknowns remain.
