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
  - tests/run_puzzle_regressions.py
  - tests/puzzle_layout_check.gd
  - tests/puzzle_presentation_check.gd
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

`PuzzleFeedback` (puzzle_feedback.gd) holds the named animation-duration
constants shared by the view layer and headless tests:
`BLOCKED_CUE_DURATION_SECONDS` (0.15s, capped at `BLOCKED_CUE_DURATION_CAP_SECONDS`
= 0.3s) and `EXIT_TWEEN_DURATION_SECONDS` (0.25s).

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

## Presentation Layer

`ArrowView` (scenes/puzzle/arrow_view.gd) renders one continuous ink arrow
with a passive Line2D body and Polygon2D head. Copied ordered cell offsets
become consecutive tail-to-head center points; adjacency never adds a
connection. Round stroke joins and a round tail cap retain orthogonal
centerlines. Single-cell arrows have an in-cell decorative shaft. Geometry
rebuilds at the board's cell extent, without scaling the parent for layout.
No occupied-cell tiles or grid lines are drawn. It holds no rule state and
retains MOUSE_FILTER_IGNORE. Whole-view feedback and rigid departure use
the existing PuzzleFeedback durations and one exit_finished signal.

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
once each queued exit tween completes.

`ArrowPuzzle` (scenes/puzzle/arrow_puzzle.gd) owns the `PuzzleState`. On
`cell_clicked`, it resolves the owning head via `PuzzleState.get_arrow_head`
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
attempt can affect the next one. Cancelling Restart leaves the current
attempt unchanged (unmodified addon behavior). Options/back and Main Menu
reuse the existing `scenes/overlaid_menus/pause_menu.tscn` and background
music player unmodified.

Source of truth: tests/puzzle_layout_check.gd (a multi-cell shape's view
bounding box and tail-cell click resolution against a standalone
`PuzzleBoard`, checked at both window sizes; HUD/board rect non-overlap and
nonzero visibility at 1280x720 and 960x540; results awaiting every queued
departure across a full multi-arrow clear; a post-completion selection being
ignored; a freshly instantiated scene starting clean; 20 rapid repeated
selections on a blocked tail cell counting exactly once each without
disturbing the attempt; the blocked-cue duration cap), run via the same
`run_puzzle_regressions.py` launcher against
the real project with APPDATA/XDG_DATA_HOME redirected so no player save
data is touched; requires `PUZZLE_LAYOUT_FAILURES=0`. Interactive desktop
smoke testing (resize, rapid clicks, pause mid-feedback, restart) remains a
separate manual verification step; the headless checks above are not a
replacement for it.

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
Code-only for OS pointer eligibility: actual focus/window behavior requires
rendered desktop input and cannot be established by direct headless events.

## Feedback precedence and departures

ArrowView orders presentation as departing > blocked > hover > normal.
Blocked presses cancel both existing writers, set the entire arrow to
critical #A8321A, and restart a 1.00 -> 1.10 -> 1.00 pulse over 150ms.
Hover eligibility can change during red feedback without recoloring it.
Completion restores unit scale and immediately assigns ember if eligible,
otherwise ink; there is no extra hover-duration delay. No input lock or
persistent disabled appearance is introduced.

Departure first marks terminal state, kills color/effect tweens, resets
scale/modulation/visibility and ink synchronously, then translates the whole
view for 250ms with quadratic ease-out. Later hover/block/exit requests are
ignored. Board erases active ownership and connects the one-shot completion
before starting movement. Active resizing does not touch departing views.
The controller retains immediate logical removal and the pending-departure
barrier. Pause suspends effects with the tree; restart/replay reconstruction
creates fresh state. PuzzleFeedback remains the duration authority, with no
font or style dependency. GameVisualStyle owns pulse amplitude and hover time.

Source of truth: tests/puzzle_presentation_check.gd checks rising/peak/falling
interruption, immediate properties, repeated pulses, hover precedence and
exactly-once exit; tests/puzzle_layout_check.gd checks staggered departures,
pause, resize, completed-input ignoring and fresh attempts.

## Gameplay theme boundary

GameVisualStyle supplies the light background and local Layout/HUD and
PuzzleResults themes. Numeric labels use bundled Inter Tight 600 tabular
figures; the existing score uses success green. Four result fields, Replay,
Main Menu and focus behavior remain unchanged. No root/global theme reaches
inherited pause/options screens. Source of truth:
tests/puzzle_presentation_check.gd checks theme scope, fonts, result text,
focus styles and content bounds at both supported desktop sizes. Shared
roles and font/license evidence are in .knowledge/architecture/game-visual-system.md.
