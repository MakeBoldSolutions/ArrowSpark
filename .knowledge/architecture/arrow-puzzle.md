---
id: arrow-puzzle
type: architecture
title: Arrow Puzzle Rules, Presentation and Menu Integration
appliesTo:
  - scripts/puzzle/puzzle_definition.gd
  - scripts/puzzle/puzzle_state.gd
  - scripts/puzzle/puzzle_solver.gd
  - scripts/puzzle/puzzle_feedback.gd
  - scripts/puzzle/puzzle_results_format.gd
  - scripts/puzzle/puzzle_catalog.gd
  - scripts/puzzle_session.gd
  - scripts/presentation/arrow_departure_geometry.gd
  - scenes/puzzle/arrow_puzzle.tscn
  - scenes/puzzle/arrow_puzzle.gd
  - scenes/puzzle/puzzle_board.gd
  - scenes/puzzle/arrow_view.gd
  - scenes/puzzle/puzzle_results.tscn
  - scenes/puzzle/puzzle_results.gd
  - scenes/menus/main_menu/main_menu.tscn
  - scenes/menus/main_menu/main_menu_with_animations.tscn
  - scenes/menus/main_menu/main_menu_with_animations.gd
  - tests/puzzle_regression.gd
  - tests/puzzle_catalog_check.gd
  - tests/run_puzzle_regressions.py
  - tests/arrow_departure_geometry_check.gd
  - tests/puzzle_layout_check.gd
  - tests/puzzle_presentation_check.gd
  - tests/arrow_departure_visual_check.gd
  - tests/scene_loader_stub.gd
---

# Arrow Puzzle Rules, Presentation and Menu Integration

## Rule Layer (Core Boundary)

`PuzzleDefinition` (scripts/puzzle/puzzle_definition.gd) is an immutable
RefCounted holding fixed dimensions, a head-to-direction map (`arrows`) and
an optional head-to-ordered-tail-cell-path map (`tails`); an omitted tail
means a single-cell arrow. `direction_vector(direction)` is the one static
mapping from a cardinal direction to its unit step, shared by every geometry
computation. `forward_ray_cells(head, direction)` returns the cells strictly
between a head and the board edge along its own direction of travel — this
is the single definition of "ahead" used by both validation (an arrow's own
tail may never occupy it) and runtime blocking (`PuzzleState` scans exactly
this set). `get_arrow_cells(head)` returns a head's full shape (head plus
tail, as an independent copy); `get_cell_owners()` returns every occupied
cell mapped to its owning head, also as an independent copy.

`get_validation_errors()` (and `is_valid()`, its emptiness check) enforce:
positive dimensions; a nonempty arrow map; in-bounds cells; cardinal
directions; a tail's first cell immediately behind its head, opposite the
head's direction of travel; each later tail cell orthogonally adjacent to
the previous one (straight or any number of right-angle turns, never
diagonal, never a gap, never a repeated cell); no arrow's own tail cell on
its own forward escape ray (`forward_ray_cells`) — this makes an arrow's own
cells self-excluding by construction, so the blocking check below never has
to resolve a self-block as a special case; and no cell shared between two
arrows. Adjacency between two *different* arrows' cells is never a
validation concern. The one authored board is
`PuzzleDefinition.create_fixed()`, a 5x4 grid with eight arrows: A (head
`(0,0)`, LEFT, a twice-bent tail `[(1,0),(1,1),(0,1)]`), B (head `(2,0)`,
LEFT, a straight tail `[(3,0)]`), C (head `(4,0)`, DOWN, no tail), D (head
`(4,3)`, RIGHT, a straight tail `[(3,3)]`), E (head `(0,3)`, UP, no tail), F
(head `(2,3)`, LEFT, no tail), G (head `(2,1)`, UP, no tail), and H (head
`(3,2)`, RIGHT, no tail). A's tail blocks both B and E; D blocks C; B blocks
G — demonstrating all four cardinal directions, a straight tail, a
multi-turn tail, tail-caused blocking, and an arrow (B) removable only after
another (A) departs, all within the one shipped layout.

`PuzzleState` (scripts/puzzle/puzzle_state.gd) is a RefCounted rule/state
authority with no Node, mouse, tween or persistence dependency. It owns a
private copy of the active arrows (head-to-direction, for still-active
arrows only) and a fixed copy of every cell's owning head for the whole
attempt, plus four counters: `total_arrows`, `successful_removals`,
`mistakes`, `total_taps`. `get_arrow_head(cell)` resolves any cell — head or
tail — to its owning head, or `null` if the cell belongs to no arrow or to
one that has already departed. `select_arrow(cell)`:

- Returns `IGNORED` without changing any counter once `completed` is true,
  or when the cell resolves to no active arrow (an absent cell, or one whose
  owner has already departed).
- Otherwise increments `total_taps` exactly once, then either increments
  `mistakes` and returns `BLOCKED`, or removes every cell of that arrow's
  whole shape atomically in the same accepted selection, increments
  `successful_removals` (once per arrow, never per cell), returns `REMOVED`,
  and sets `completed` once no active arrow remains.

`is_blocked(cell)` returns false for any cell with no active owner (absent,
or already departed). For an active cell, it resolves the owning head and
scans `PuzzleDefinition.forward_ray_cells(head, direction)`: any cell there
still owned by a *different* active arrow blocks, regardless of that other
arrow's own direction. An arrow's own head and every one of its own tail
cells are excluded unconditionally by ownership, not by position — a valid
definition never places one of an arrow's own cells on its own forward ray,
so this is a self-ownership guarantee the blocking check states directly
rather than a conflict it resolves. Arrows behind, diagonal, or on a
different row/column never block; adjacency between different arrows' cells
carries no meaning at all. Invariants: `total_arrows = remaining +
successful_removals` and `total_taps = successful_removals + mistakes` hold
at every step, counting arrows, never cells.

`get_results()` returns `score = max(total_arrows - mistakes, 0)` and
`accuracy = successful_removals / total_taps` (0.0 at zero taps).
`PuzzleResultsFormat.format_accuracy_percent()` (puzzle_results_format.gd)
renders that ratio as a one-decimal percentage, rounding an exact tie half
away from zero (e.g. 6.25% -> "6.3%").

`PuzzleFeedback` (puzzle_feedback.gd) holds the named animation-duration and
departure-speed constants shared by the view layer and headless tests:
`BLOCKED_CUE_DURATION_SECONDS` (0.15s, capped at `BLOCKED_CUE_DURATION_CAP_SECONDS`
= 0.3s), `EXIT_SPEED_CELLS_PER_SECOND` (10.0, the shared cell-distance
departure speed) and `EXIT_CLEARANCE_MARGIN_CELLS` (0.001, the tolerance
margin added beyond exact edge contact so full-tail finish never completes
early from floating-point boundary equality).

### Solvability Analysis

`PuzzleSolver.analyze(definition)` (scripts/puzzle/puzzle_solver.gd) is a
static, presentation-independent function returning a `Dictionary` with
`valid`, `solvable`, `witness` (`Array[Vector2i]` of heads),
`validation_errors`, and `metrics`. It validates the definition first
(`get_validation_errors()`); an invalid definition returns `valid: false`
with zero metrics and never constructs a state. For a valid definition, it
builds one fresh `PuzzleState` and repeatedly removes the (y, x)-ascending
first currently-legal head (via the same `is_blocked`/`select_arrow` every
attempt uses — the solver never has its own copy of the blocking rule) until
either no arrow remains (`solvable: true`, `witness` complete) or no legal
head remains among the rest (`solvable: false`, `witness` empty — never a
partial sequence). It never mutates the caller's definition or any other
live attempt built from it.

**Why no backtracking is needed (monotonicity):** a removal only deletes
occupied cells, never adds any, and an arrow's legality is a monotone
function of the active occupancy set. This gives an exchange property: if a
complete removal order exists from some state, then removing *any*
currently-legal arrow first still leaves a solvable residual state — every
later step in the original order only required certain cells absent, and
removing something else first can only have removed more, never less. By
induction, a state is solvable if and only if this single deterministic
greedy walk (pick any legal head, remove it, repeat) never gets stuck before
the board is empty; no legal choice can ever strand the search into a dead
end that a different choice would have avoided. This is why one traversal
with no backtracking is sufficient, and it is the reasoning
tests/puzzle_regression.gd's order-independence check exercises directly
(forcing each of two simultaneously-legal arrows first and confirming both
orders still complete). This proof depends on removal staying strictly
monotonic; a future rule that lets removal re-occupy a cell or otherwise
change another arrow's blocking geometry would invalidate it and require
re-deriving the solver's approach, not just re-tuning it.

**Metrics.** `result.metrics` is a `Dictionary` of six nonnegative integers,
all counted along the *one* deterministic greedy trajectory `analyze()`
actually walks — never a full-tree or exhaustive-search statistic across
every possible order: `states_examined` (every nonempty state visited,
excluding the cleared terminal); `active_choices_encountered` (sum, across
those states, of how many arrows were still active); `legal_choices_encountered`
(sum, across those states, of how many of those arrows were legal at that
moment); `forced_states` (states with exactly one legal head);
`branching_states` (states with more than one); and `no_move_states`
(nonempty states with zero legal heads — the stuck terminal on an unsolvable
board, still counted). `states_examined` always equals `forced_states +
branching_states + no_move_states`. Invalid input yields every metric at
zero without constructing a state. The dictionary carries no difficulty
score, level, or classification field, and adding a new metric key later
never changes the meaning of these six — the contract only ever grows.
Because the counts are single-path, a future difficulty feature that needs
whole-solution-space statistics (e.g. how many *distinct* orders exist, or
branching factor averaged over every order rather than the one path taken)
would need new fields alongside these, not a reinterpretation of them.

Source of truth: tests/puzzle_regression.gd (shape geometry validation —
straight/multi-turn/empty tails, tail-origin and own-forward-ray rejection,
repeated/disconnected/diagonal/out-of-bounds cells, cross-shape overlap,
adjacency-without-overlap; definition mutation isolation; whole-shape atomic
selection via either head or tail cell; tail-only blocking in all four
directions including a two-turn bent tail, with the blocker's own head
verified off the target's ray; an arrow's own long bent tail never blocking
itself; an edge-facing arrow with a tail still immediately clear; the
single-cell blocking matrix in all four directions; off-axis/behind
non-blocking; the full A,B,D,C,E,F,G,H witness solution; a direct assertion
that the shipped `create_fixed()` content actually contains a straight tail,
a multi-turn tail, a tail-caused block, and a dependent arrow that clears
once its blocker departs; ignored/inactive selections; counter invariants;
100 consecutive blocked selections (both a single-cell and a tail-caused
case); the blocked-cue duration cap; results arithmetic and rounding for
five mistake counts including the 120-mistake exact tie; zero-tap accuracy;
completed-state ignoring; fresh-state Replay reset; and, for
`PuzzleSolver.analyze()`: the shipped board's witness is complete, has no
duplicate heads, and replays against a fresh state with zero mistakes;
invalid input reports `valid: false` with zero metrics and no witness; a
two-arrow facing cycle and a removable-prefix-then-residual-cycle board both
report unsolvable with an empty (never partial) witness; repeated calls on
the same definition are deterministic; `analyze()` never mutates its input
definition or a separately live attempt built from it; and forcing either of
two simultaneously-legal arrows first on a genuine branching state still
reaches a complete, mistake-free solution either way (the order-independence
property the no-backtracking design depends on); and exact metric values for
a single arrow (`active=legal=1, forced=1`), two independent arrows
(`active=legal=3, branching=1, forced=1`), and a two-arrow cycle
(`active=2, legal=0, no_move=1`), each also checked for the
`states_examined` identity, nonnegative fields, call-to-call stability, and
the absence of any difficulty-labeled field. Run via
`python tests/run_puzzle_regressions.py --godot <godot>`; requires exit zero
and `PUZZLE_FAILURES=0`.

## Puzzle Catalog and Session-Scoped Selection

`PuzzleCatalog` (scripts/puzzle/puzzle_catalog.gd) is a static-registry
`RefCounted` class, never instantiated, sitting between the domain
(`PuzzleDefinition`) and presentation. It holds an ordered array of eight
entries (`{id, title, build}`), each `build` a zero-argument static function
constructing a fresh `PuzzleDefinition` exactly like `create_fixed()`'s own
literal-construction style. `count()`, `id_at(index)`, `title_at(index)`,
`index_of(id)` (`-1` if unknown), `ids()` (an independent ordered copy) and
`get_title(id)` (`""` if unknown) expose ordering and identity as two
separate concepts — a stable string id is never derived from array position,
title, or any filesystem path. `get_definition(id)` (`null` if unknown)
rebuilds and returns a fresh `PuzzleDefinition` on every call — no caching,
no shared instance — so two calls for the same id are structurally equal but
never share mutable substructure, the same isolation guarantee
`create_fixed()` already had. `PuzzleDefinition` itself gained no
catalog/progression fields; it remains anonymous structural data.

`PuzzleSession` (scripts/puzzle_session.gd) is a process-lifetime,
in-memory-only `RefCounted` class holding a single private `static var
_current_id`, matching the same static-var precedent `GameVisualStyle._theme`
already established for process-lifetime state with no scene-tree
involvement. `get_current_id()` defaults to `PuzzleCatalog.id_at(0)` whenever
unset or no longer a valid catalog id; `set_current_id(id)` is a direct
setter (the caller is responsible for passing a valid id);
`advance_to_next()` moves to the next catalog entry and returns `true`, or
leaves the id unchanged and returns `false` at the last entry; `has_next()`
reports whether a next entry exists. It never reads or writes `GlobalState`,
`GameState`, `LevelState`, or `user://global_state.tres`, and is reset only
by a fresh engine process — a scene reload (Replay, pause-menu Restart, Next
Puzzle) leaves it unchanged, since a GDScript static var is bound to the
running process, not to any node or scene.

Source of truth: tests/puzzle_catalog_check.gd (unique/valid stable ids
independent of position, deterministic `id_at`/`index_of`/`ids` ordering,
fresh-and-isolated `get_definition` per call including cross-id
independence, every entry structurally valid and solver-confirmed solvable
with a replayed zero-mistake witness, no difficulty-labeled title wording,
`PuzzleSession` default/set/advance/has-next behavior including the
last-entry no-op and the invalid-id fallback), run via the same
`run_puzzle_regressions.py` launcher in the same bare isolated temp project
as tests/puzzle_regression.gd (PuzzleCatalog depends only on
PuzzleDefinition); requires `PUZZLE_CATALOG_FAILURES=0`.

## Presentation Layer

`ArrowView` (scenes/puzzle/arrow_view.gd) renders one continuous ink arrow
with a passive Line2D body and Polygon2D head. Copied ordered cell offsets
become consecutive tail-to-head center points; adjacency never adds a
connection. Round stroke joins and a round tail cap retain orthogonal
centerlines. Single-cell arrows have an in-cell decorative shaft. Geometry
rebuilds at the board's cell extent, without scaling the parent for layout.
No occupied-cell tiles or grid lines are drawn. It holds no rule state and
retains MOUSE_FILTER_IGNORE. Departure feeds this same shape through its own
stationary route via `ArrowDepartureGeometry` (see
.knowledge/architecture/game-visual-system.md for the route math and
completion contract) and emits `exit_finished` exactly once on full-tail
clearance.

Source of truth: tests/puzzle_presentation_check.gd covers cardinal shapes,
ordered multi-bend points, head overlap, copied inputs and extent rebuilds.
See .knowledge/architecture/game-visual-system.md for shared proportions.

`PuzzleBoard` (scenes/puzzle/puzzle_board.gd) creates one `ArrowView` per
head, keyed by head, sized and positioned to each shape's own bounding box
(computed from `PuzzleDefinition.get_arrow_cells(head)`) in a centered,
uniformly scaled grid recomputed on `NOTIFICATION_RESIZED`. It maps a
primary mouse-button press (not release, and `not event.is_echo()`, so a
held button cannot repeat) to a raw cell via `_gui_input`, and emits
`cell_clicked` with that cell as-is — head or tail, or even one belonging to
no arrow. It has no rule dependency: the controller resolves ownership and
decides the outcome. `play_removed(head)`/`play_blocked(head)` always take
the canonical head, never a raw clicked cell. `departure_finished` fires
once each departing view fully clears the grid edge (see Feedback
precedence and departures below for the `DepartureClip`/`_departing_views`
mechanics).

`ArrowPuzzle` (scenes/puzzle/arrow_puzzle.gd) owns the `PuzzleState`.
`_start_new_attempt()` resolves its definition via
`PuzzleCatalog.get_definition(PuzzleSession.get_current_id())` — never
`PuzzleDefinition.create_fixed()` directly — and sets a `%PuzzleLabel` HUD
entry (a single line no taller than the existing `RemainingLabel`/
`MistakesLabel` row) from the same resolved id/title pair used to build the
definition, so the displayed identity always matches what actually loaded.
On `cell_clicked`, it resolves the owning head via `PuzzleState.get_arrow_head`
first — so any cell of a multi-cell shape selects the same owner — then
applies state before starting any visual effect, and updates the HUD
(`RemainingLabel`, `MistakesLabel`) immediately after every accepted
selection. It tracks `_pending_departures` and only shows results once
`_state.completed` is true AND every pending departure tween has finished
(`_awaiting_completion` + `_on_departure_finished`), so multiple in-flight
departures are all awaited, not just the most recently clicked arrow.
Showing results disables the `PauseMenuController`'s unhandled input
(`set_process_unhandled_input(false)`) so a pause overlay cannot appear
behind the results panel; a fresh attempt re-enables it.

`arrow_puzzle.tscn`'s `Layout` is a `VBoxContainer` with the HUD
(`HUDMargin`) stacked above `BoardArea`/`PuzzleBoard`; a container stack
cannot overlap its children by construction at every window size. `PuzzleResults` is `mouse_filter = MOUSE_FILTER_STOP` and covers the
full rect as the last child (so it draws above the board), absorbing
background input while shown.

**Replay and pause-menu Restart both call `SceneLoader.reload_current_scene()`**
rather than resetting counters in place: reloading the scene reconstructs a
fresh `PuzzleState`, fresh views and fresh tweens from `_ready()`, which
trivially guarantees no stale callback or pending tween from the finished
attempt can affect the next one. Because `PuzzleSession`'s `_current_id` is
a process-lifetime static var, neither reload resets it — the freshly
reconstructed `_start_new_attempt()` reads the same `PuzzleSession.get_current_id()`
and naturally reproduces the currently selected puzzle, never silently
falling back to catalog position 0. This requires **zero new code** for
either entry point: `arrow_puzzle.gd::_on_results_replay_requested()` and
the addon `PauseMenu`'s `_on_confirm_restart_confirmed()` both call the
identical `SceneLoader.reload_current_scene()`, so the guarantee is
structural, not duplicated logic. Cancelling Restart leaves the current
attempt unchanged (unmodified addon behavior). Options/back and Main Menu
reuse the existing `scenes/overlaid_menus/pause_menu.tscn` and background
music player unmodified.

A new `_on_results_next_puzzle_requested()` handler calls
`PuzzleSession.advance_to_next()` then the same
`SceneLoader.reload_current_scene()` — one extra call before the identical
reload Replay already relies on, so Next Puzzle inherits the same
fresh-attempt guarantee (no carried-over mistakes, score, active state, or
departure state) with no separate reset logic. `puzzle_results.gd` gains a
`next_puzzle_requested` signal and a `%NextPuzzleButton`, shown/enabled only
when the controller passes `has_next = true` (from
`PuzzleSession.has_next()`) into `show_results()`; on the last catalog
puzzle it is hidden, while Replay, Level Select (via Main Menu) and Main
Menu remain available. `show_results()` also takes the completed puzzle's
id, rendering a `%PuzzleLabel` identity line from the same
`PuzzleCatalog`/`PuzzleSession` pair the controller used for that attempt,
alongside the unchanged total-arrows/mistakes/score/accuracy metrics.
Switching puzzles via Replay, pause-menu Restart, Next Puzzle, or Level
Select all go through a full scene reconstruction, so any prior attempt's
departing views/callbacks are disposed exactly as `setup()` replacement
already guarantees within one attempt (see Feedback precedence and
departures below) — no stale completion signal from a finished attempt can
reach the next one.

Source of truth: tests/puzzle_layout_check.gd (a multi-cell shape's view
bounding box and tail-cell click resolution against a standalone
`PuzzleBoard`, checked at both window sizes; HUD/board rect non-overlap and
nonzero visibility at 1280x720 and 960x540; results awaiting every queued
departure across a full multi-arrow clear; resize preserving departure
cell-distance progress and rescaling pixel geometry to the new extent;
resize at 960x540/1280x720/800x800, resize while paused and zero-extent
recovery; a combined scenario with two concurrent departures of different
route lengths paused mid-flight, resized while paused, then resumed, each
finishing exactly once; `setup()` replacement canceling and disposing any
in-flight departure so no stale completion reaches a replaced attempt; a
post-completion selection being ignored; a freshly instantiated scene
starting clean; 20 rapid repeated selections on a blocked tail cell counting
exactly once each without disturbing the attempt; the blocked-cue duration
cap; and, for every one of the eight `PuzzleCatalog` entries in turn: the
board's active view count matches the definition's arrow count, the HUD
puzzle label matches the catalog title, and the same solver-derived
zero-mistake witness clears through the real scene with unchanged
scoring/mistakes/accuracy — proving engine-generality end-to-end, not only
via the pure `puzzle_catalog_check.gd` solver gate), run via the same
`run_puzzle_regressions.py` launcher against the real project with
APPDATA/XDG_DATA_HOME redirected so no player save data is touched;
requires `PUZZLE_LAYOUT_FAILURES=0`. A puzzle-specific check resolves its
own clear order from `PuzzleSolver.analyze()` against whichever definition
is actually loaded rather than a hardcoded witness, so it never assumes one
specific board's geometry. A further check drives the real
`SceneLoader.reload_current_scene()`/`get_tree().change_scene_to_packed()`
path directly (not just repeated `instantiate()` calls) to prove a non-first
selected puzzle survives that exact reload, that Next Puzzle advances to
the following catalog entry with fresh state, and that the last catalog
puzzle's results omit `%NextPuzzleButton`. Interactive desktop smoke testing
(resize, rapid clicks, pause mid-feedback, restart) remains a separate
manual verification step; the headless checks above are not a replacement
for it.

## Menu Integration and the No-Reset Guarantee

`scenes/menus/main_menu/main_menu.tscn` and `main_menu_with_animations.tscn`
both point `game_scene_path` at `res://scenes/puzzle/arrow_puzzle.tscn`.
`main_menu_with_animations.gd` no longer overrides `new_game()` or
`load_game_scene()`; both now use the addon base `MainMenu`'s
default implementation (`SceneLoader.load_scene(game_scene_path)` only), so
opening the puzzle from Play/New Game never calls `GlobalState.reset()` or
`GameState.start_game()`. Continue and Level Select stay hidden (the scene's
default `visible = false`, no longer overridden to conditionally show them);
their scenes/scripts remain in source, unreachable from this menu, so they
can be restored later. The `NewGameButton` carries a tooltip
("Existing level progress is preserved even though it's hidden here.")
stating this. Intro, options and credits are unaffected.

Source of truth: tests/save_input_regression.gd's
`_test_no_reset_on_puzzle_entry()` (run via `tests/run_regressions.py`),
which loads the real `main_menu_with_animations.gd`, seeds a `GameState`
with known `times_played`/`max_level_reached`/`level_states`, calls
`new_game()` then `load_game_scene()` directly, and asserts none of those
values changed while `SceneLoader.load_scene` was still invoked. The
isolated test project registers `tests/scene_loader_stub.gd` as the
`SceneLoader` autoload so the check needs no real scene-loading pipeline;
`game_state.gd` is copied to `scripts/game_state.gd` in that isolated
project because `GlobalState.get_state()` loads it by that hardcoded path.
Requires exit zero and `REGRESSION_FAILURES=0`.

## Whole-arrow hover

PuzzleBoard samples a board-local cell through mouse motion and stationary
pointer refresh. The controller resolves only PuzzleState.get_arrow_head,
then returns the active canonical owner to set_hovered_head. Same-owner
cell changes do not restart the 120ms ease-out color tween. Body and head
share ember #C6620C while hovered. Logical whole-cell targets, including
blank space beside the shaft, remain unchanged; hover never selects.

Pause, pointer/window exit, focus loss, hiding, setup and removal clear
hover and invalidate the sampled cell. Per-frame cursor-target refresh prevents cached GUI hover from surviving a
new overlay beneath a stationary pointer. Eligibility requires the
board to be the viewport's actual hovered Control in a focused, unpaused
window. Overlays therefore suppress underlying hover; resume and resize
resample even a stationary pointer. Source of truth:
tests/puzzle_presentation_check.gd (GUI motion/press/release, ownership,
cache invalidation, counters, removal) and scenes/puzzle/puzzle_board.gd.
Its real-scene hover/input check explicitly loads
`PuzzleDefinition.create_fixed()` into the instantiated puzzle's board and
state (rather than whichever catalog entry `PuzzleSession` defaults to), so
its assertions about specific cell positions/relationships stay independent
of the authored catalog content; tests/puzzle_layout_check.gd is the
catalog-generality coverage instead. Code-only for OS pointer eligibility:
actual focus/window behavior requires rendered desktop input and cannot be
established by direct headless events.

## Feedback precedence and departures

ArrowView orders presentation as departing > blocked > hover > normal.
Blocked presses cancel both existing writers, set the entire arrow to
critical #A8321A, and restart a 1.00 -> 1.10 -> 1.00 pulse over 150ms.
Hover eligibility can change during red feedback without recoloring it.
Completion restores unit scale and immediately assigns ember if eligible,
otherwise ink; there is no extra hover-duration delay. No input lock or
persistent disabled appearance is introduced.

Departure first marks terminal state, kills color/effect tweens, resets
scale/modulation/visibility and ink synchronously, then feeds the whole
shape through its own stationary route at a shared cell-distance speed and
clips it at the occupied grid edge — see
.knowledge/architecture/game-visual-system.md for the full route-math,
speed and clearance contract. Later hover/block/exit requests are ignored,
and repeated start requests are ignored once departing.

`PuzzleBoard` owns two presentation-only collections: `_views` (canonical
head -> active view, ownership-routing) and `_departing_views` (original
head -> departing view, layout/tracking only, never selection/hover
routing). `play_removed(head)` erases the active entry, reparents the view
into a passive `DepartureClip` child `Control` (clip_contents, mouse-filter
ignore, sized to the occupied grid) at its own bbox-relative position, and
connects the one-shot completion before starting movement, so a same-frame
full-clearance advance cannot race the callback. `_layout_views()` relayouts
both collections from the same board cell extent on every resize; a
departing view's cell-distance progress never changes from a layout update
alone, only its pixel projection. `setup()` cancels and disposes any
in-flight departures (via `cancel_departure()`, which guarantees no later
completion signal) before clearing both collections, so a replaced attempt
never receives a stale callback. The controller retains immediate logical
removal and the pending-departure barrier, decrementing `_pending_departures`
only from `departure_finished`. Pause suspends effects with the tree, also
enforced by an explicit paused check inside `advance_departure` so direct
test calls cannot bypass it; restart/replay reconstruction creates fresh
state. PuzzleFeedback remains the speed/clearance-margin authority, with no
font or style dependency. GameVisualStyle owns pulse amplitude, hover time
and the geometry ratios the route math is built from.

Source of truth: tests/puzzle_presentation_check.gd checks rising/peak/falling
interruption, immediate properties, repeated pulses, hover precedence,
initial silhouette equivalence, head/body overlap, cardinal orientation,
equal-delta-partition speed and exactly-once full-tail completion;
tests/puzzle_layout_check.gd checks staggered departures, pause, resize
(including while paused and to zero extent), the combined concurrent-
departure/pause/resize/resume scenario, setup-replacement disposal,
completed-input ignoring and fresh attempts; tests/arrow_departure_geometry_check.gd
covers the pure route/clearance math in isolation (see
.knowledge/architecture/game-visual-system.md).

## Gameplay theme boundary

GameVisualStyle supplies the light background and local Layout/HUD and
PuzzleResults themes. Numeric labels use bundled Inter Tight 600 tabular
figures; the existing score uses success green. Four result fields, Replay,
Main Menu and focus behavior remain unchanged. No root/global theme reaches
inherited pause/options screens. Source of truth:
tests/puzzle_presentation_check.gd checks theme scope, fonts, result text,
focus styles and content bounds at both supported desktop sizes. Shared
roles and font/license evidence are in .knowledge/architecture/game-visual-system.md.
