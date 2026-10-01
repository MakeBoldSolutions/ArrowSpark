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
  - scripts/puzzle/puzzle_analyzer.gd
  - scripts/puzzle_session.gd
  - scripts/puzzle_scoreboard.gd
  - scripts/presentation/arrow_departure_geometry.gd
  - scripts/presentation/puzzle_viewport_transform.gd
  - scenes/puzzle/arrow_puzzle.tscn
  - scenes/puzzle/arrow_puzzle.gd
  - scenes/puzzle/puzzle_board.gd
  - scenes/puzzle/arrow_view.gd
  - scenes/puzzle/puzzle_results.tscn
  - scenes/puzzle/puzzle_results.gd
  - project.godot
  - scenes/menus/main_menu/main_menu.tscn
  - scenes/menus/main_menu/main_menu_with_animations.tscn
  - scenes/menus/main_menu/main_menu_with_animations.gd
  - tests/puzzle_regression.gd
  - tests/puzzle_catalog_check.gd
  - tests/puzzle_analyzer_check.gd
  - tests/puzzle_scoreboard_check.gd
  - tests/save_input_regression.gd
  - tests/run_regressions.py
  - tests/puzzle_structural_report.gd
  - tests/run_puzzle_regressions.py
  - tests/run_puzzle_structural_report.py
  - tests/arrow_departure_geometry_check.gd
  - tests/puzzle_layout_check.gd
  - tests/puzzle_canvas_check.gd
  - tests/puzzle_canvas_visual_check.gd
  - tests/puzzle_viewport_transform_check.gd
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

`PuzzleState` also holds `open_move_assists` (int, defaults 0) alongside
`mistakes`. `find_open_move()` returns one currently-legal active head,
chosen deterministically in the same (y, x)-ascending order
`PuzzleSolver.analyze()` walks, or `null` only if no active arrow remains; it
is a pure query reusing `_is_head_blocked` directly, never a second rules
engine, and it is callable at any time — including while a departure
animation from an earlier removal is still visually in progress, since it
only reads state the presentation layer never delays. `request_open_move()`
is the one player-facing "Show Me an Open Move" entry point: once `completed`
is already true it is a no-op returning `null` with `open_move_assists`
unchanged (mirroring `select_arrow()`'s own completed guard); otherwise it
increments `open_move_assists` by exactly one — every valid request counts
once, even a repeat before the shown arrow is played — then returns
`find_open_move()`'s result. It never touches `total_taps`, `mistakes`, or
`successful_removals`, so an Open Move request can never affect accuracy; the
player's subsequent selection of the identified arrow is counted for accuracy
exactly like any other selection, whether it succeeds or is blocked.

`get_results()` returns `score = max(total_arrows - (mistakes +
open_move_assists * 5), 0)` and `accuracy = successful_removals / total_taps`
(0.0 at zero taps), plus `open_move_assists` itself alongside `total_arrows`
and `mistakes` in the returned dictionary. A perfect attempt (zero mistakes,
zero assists) always scores `total_arrows`; reaching the zero floor after
heavy mistake/assist use is accepted product behavior (see
`.knowledge/product/gameplay-contract.md`), never a blocked/limited attempt.
`PuzzleResultsFormat.format_accuracy_percent()` (puzzle_results_format.gd)
renders that ratio as a one-decimal percentage, rounding an exact tie half
away from zero (e.g. 6.25% -> "6.3%").

`PuzzleFeedback` (puzzle_feedback.gd) holds the named animation-duration and
departure-speed constants shared by the view layer and headless tests:
`BLOCKED_PULSE_SECONDS` (0.15s, the scale pulse inside the cue),
`BLOCKED_CUE_DURATION_SECONDS` (0.6s, the whole bright-red cue, capped at
`BLOCKED_CUE_DURATION_CAP_SECONDS` = 0.75s), `EXIT_SPEED_CELLS_PER_SECOND` (10.0, the shared cell-distance
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
property the no-backtracking design depends on). Order-independence is
further checked at every branching state a witness actually passes through
(not only a puzzle's opening move): for the shipped `create_fixed()` board
here, and for all twenty-two `PuzzleCatalog` entries in
tests/puzzle_catalog_check.gd, forcing each *other* currently-legal
alternative next instead of the witness's own choice still reaches a
complete, mistake-free solution from there — the automated, catalog-wide
proof that "every unfinished state reached through legal play has a legal
move" (see `.knowledge/product/gameplay-contract.md`) holds without
enumerating the full reachable-state space, per the monotonicity exchange
property above. A long run of blocked selections (extending the existing
100-consecutive-blocked case) still allows the whole board to complete
afterward with the earlier mistake count unaffected. And exact metric values for
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
(`PuzzleDefinition`) and presentation. It holds an ordered array of twenty-two
entries (`{id, title, group, build}`) — the original eight baseline puzzles, six
experimental puzzles (`nested_chain`, `cascade_key_arrow`,
`dense_unravel`, `bent_network`, `long_range_blocker`, `composed_shaped`),
each deliberately authored to combine structural features (dependency depth,
cascade fan-out, density, bent-tail dependencies, long-range blocking,
macro-scale composition) the baseline eight never did in combination, one large-canvas validation board (`canvas_validation`, titled "Large Canvas
Validation"), and six newer geometric experiments (`knot_long_geometry`,
`knot_interwoven_paths`, `knot_dense_core`, `knot_regions`,
`knot_single_release`, `knot_boundary`) — each
`build` a zero-argument static function
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

`canvas_validation` is a plainly titled, player-visible entry (the seventh
Puzzle Lab entry, reached by Next from `composed_shaped`, listed in Level Select
and counted in the session score like any other). It is an authored 40x30 board packed with fifty-two arrows (about 87% of
the cells occupied): almost every arrow is long and bent (most 22-43 cells,
only three shorter than eight), all four directions appear, long tails cross
the rays of other arrows so most removals unlock several others, all four
corner regions are occupied, and the initial open move (the first legal head
in (y, x) order) is near the top-left. The layout is fixed literal data built
from orthogonal path vertices expanded deterministically by
`PuzzleCatalog._tail_along`; it was found once by a seeded offline search that
kept every step solvable and is not generated at runtime. It exists to
exercise large-board navigation, off-screen assistance and long departures;
its difficulty is deliberately untuned. The original fourteen entries' ids, order, dimensions and exact arrow/tail
content are pinned by fingerprints, as is the complete `canvas_validation`
geometry. The six geometric experiments follow it in the same registry.
They retain authored 32x24 to 48x36 canvases; their purpose and actual
structural measurements are documented in
`.knowledge/reference/gordian-knot-experiments.md`. They reuse the same
solver, assistance, scoring and session-only selection behavior.

### Level groups

Every catalog entry carries a `group` metadata key: `arrowspark_levels`
("ArrowSpark Levels": designed against the current player-experience
standard, currently the Reference Knot), `foundations` ("Foundations": the
eight baseline puzzles) or `puzzle_lab` ("Puzzle Lab": the structural
experiments, the large-canvas validation board and the knot experiments).
Groups describe why content exists, not a quality ranking, and have no effect
on rules, solver, analyzer, scoring, Open Move or the viewport. `PuzzleCatalog`
exposes `group_ids()` (presentation order: ArrowSpark Levels, Foundations,
Puzzle Lab), `group_title()`, `group_of()`, `ids_in_group()`, `group_position()`
(1-based within the group) and `next_in_group()` (no wrap, no cross-group,
empty for unknown ids). Level Select renders one non-focusable header per group
as a collapsible accordion: a focusable toggle header button per group (marked
`-` when expanded, `+` when collapsed, with the entry count) above that group's
entry buttons, numbered by group position. Every group starts expanded;
collapsing hides a group's entries so keyboard and gamepad focus skip them. The
in-game label and results title use the same group-relative number. The play
HUD has a Back button (first in the Tab order) that leaves the puzzle mid-play
for Level Select without recording a score or touching progress. Play / New
Game starts `reference_knot` without resetting progress.
Source of truth: tests/puzzle_catalog_check.gd (group sizes, membership,
position and next semantics, group-scoped session progression),
tests/puzzle_layout_check.gd (grouped Level Select, accordion collapse and
expand, Back button presence and wiring, group-end results buttons, Level
Select request), tests/puzzle_canvas_check.gd (HUD tab order including Back;
the live Back scene change itself is covered only by desktop smoke testing), tests/save_input_regression.gd (Play target, one-shot
request, no progress change).

`PuzzleSession` (scripts/puzzle_session.gd) is a process-lifetime,
in-memory-only `RefCounted` class holding a single private `static var
_current_id`, matching the same static-var precedent `GameVisualStyle._theme`
already established for process-lifetime state with no scene-tree
involvement. `get_current_id()` defaults to `PuzzleCatalog.id_at(0)` whenever
unset or no longer a valid catalog id; `set_current_id(id)` is a direct
setter (the caller is responsible for passing a valid id);
`advance_to_next()` moves to the next entry of the current puzzle's own group
and returns `true`, or leaves the id unchanged and returns `false` at the
group's end; `has_next()` reports whether a next entry exists in that group.
`request_level_select()` / `consume_level_select_request()` are a one-shot,
in-memory flag the main menu reads once on load to open Level Select. It never reads or writes `GlobalState`,
`GameState`, `LevelState`, or `user://global_state.tres`, and is reset only
by a fresh engine process — a scene reload (Replay, pause-menu Restart, Next
Puzzle) leaves it unchanged, since a GDScript static var is bound to the
running process, not to any node or scene.

Source of truth: tests/puzzle_catalog_check.gd (unique/valid stable ids
independent of position, deterministic `id_at`/`index_of`/`ids` ordering,
fresh-and-isolated `get_definition` per call including cross-id
independence, every one of the twenty-two entries structurally valid and
solver-confirmed solvable with a replayed zero-mistake witness, the original
fourteen entries' ids, order, dimensions and content unchanged, the
`canvas_validation` fixture's dimensions/arrow count/bent long arrows/four
directions/tail dependency/top-left open move/corner regions, `Next` from
`composed_shaped` reaching it and continuing into the knot experiments, `Next` being
absent at each group's last entry, no
difficulty-labeled title wording, each of the six experimental
entries confirmed against its exact `PuzzleAnalyzer`-derived threshold (see
below), the catalog-wide branching order-independence check (every one of
the twenty-two entries' witness, at every branching state it passes through,
still completes when any other legal alternative is forced instead — see the
Rule Layer's Solvability Analysis section above), `PuzzleSession` default/set/advance/has-next behavior including the
last-entry no-op and the invalid-id fallback), run via the same
`run_puzzle_regressions.py` launcher in the same bare isolated temp project
as tests/puzzle_regression.gd (PuzzleCatalog depends only on
PuzzleDefinition); requires `PUZZLE_CATALOG_FAILURES=0`.

## Open Move Assistance and Session Scoring

See `.knowledge/product/gameplay-contract.md` for the behavioral contract
this section implements: mistakes cost score not play, the session is the
sole gameplay-memory boundary, and replay exists to improve a puzzle's
session-best, never to recover from failure.

`PuzzleScoreboard` (scripts/puzzle_scoreboard.gd) is a session-lifetime,
in-memory-only `RefCounted` class holding one private `static var
_best_results` (`puzzle_id -> Completed Attempt Result Dictionary`, the
exact shape `PuzzleState.get_results()` returns) — the same static-var,
process-lifetime precedent `PuzzleSession`/`GameVisualStyle` already
establish. It is a deliberate sibling to `PuzzleSession`, never a merge with
it: `PuzzleSession` owns *which puzzle is currently selected*; `PuzzleScoreboard`
owns *how well each puzzle has been played this session*. Neither reads the
other's state, and neither reads or writes `GlobalState`, `GameState`,
`LevelState`, or `user://global_state.tres`; both are reset only by a fresh
engine process.

`record_attempt(puzzle_id, result)` records one completed attempt against
that puzzle's session-best and returns exactly one of `"established"` (no
prior best existed), `"improved"` (strictly greater score), `"tied"` (equal
score), or `"not_improved"` (lower score); only `"established"`/`"improved"`
replace the stored dictionary, so a worse or tied replay can never lower a
puzzle's session-best. It asserts `result` carries the five expected keys and
that `score` is a nonnegative int no greater than `total_arrows` — a
contract shape/range sanity check only, never a re-derivation of whether the
attempt is actually completed or a recomputation of the score formula;
`PuzzleState` remains the sole scoring/completion authority.
`get_best(puzzle_id)` returns the stored dictionary or `null` if that puzzle
has not been completed this session. `get_overall_score()` sums `["score"]`
across every stored session-best, so a puzzle never completed contributes
nothing, and improving one puzzle's best raises the sum by exactly the
improvement.

`PuzzleState` gained `open_move_assists` (an `int` counter alongside
`mistakes`), `find_open_move()` (a pure query returning the (y, x)-ascending-first
currently-legal head, or `null` if none remains — reusing `_is_head_blocked`
directly, never a second rules engine), and `request_open_move()` (the
player-facing "Show Me an Open Move" entry point: a no-op once `completed`
is already true, mirroring `select_arrow()`'s own completed guard;
otherwise increments `open_move_assists` by exactly one per valid request —
including a repeat before the shown arrow is played — then returns
`find_open_move()`'s result). Neither method touches `total_taps`,
`mistakes`, or `successful_removals`, so an Open Move request can never
affect accuracy. `get_results()` now computes `score = max(total_arrows -
(mistakes + open_move_assists * 5), 0)` and includes `open_move_assists`
alongside the existing fields.

In the scene, `arrow_puzzle.gd`'s `_show_results()` calls
`PuzzleScoreboard.record_attempt(PuzzleSession.get_current_id(),
_state.get_results())` exactly once per completed attempt, then passes its
outcome string and `PuzzleScoreboard.get_overall_score()` into
`puzzle_results.gd`'s `show_results()`. `puzzle_results.gd` renders two
additional short lines — a session-best comparison (`%SessionComparisonLabel`:
"New session best: N" / "Session best improved to N" / "Matched session
best: N" / "Session best unchanged") and `%OverallSessionScoreLabel`
("Overall Session Score: N") — alongside the existing four metric labels,
kept to one line each rather than a progression dashboard. The panel only
displays what it is given; it never calls `PuzzleScoreboard` itself, keeping
the "display component never mutates state" boundary intact.

The player-facing "Show Me an Open Move" control is `%OpenMoveButton`, an
ordinary focusable `Button` in the existing HUD row (`HUDMargin`) — not a
bespoke input-map action — so it inherits the addon's existing
keyboard/gamepad focus navigation for free. Its handler
(`_on_open_move_button_pressed()`) calls `_state.request_open_move()` and,
on a non-null result, passes the head to `PuzzleBoard.suggest_open_move(head)`;
it is never gated on `_pending_departures`, so the assist always reads the
puzzle's current logical state even while an earlier removal's departure
animation is still visually in flight elsewhere on the board (see Feedback
precedence and departures below for the "suggested" presentation tier this
introduces).

Source of truth: tests/puzzle_scoreboard_check.gd (established/improved/
tied/not_improved outcomes; overall-score summation including a
never-completed puzzle contributing nothing; the full result shape preserved
in the stored best, not score alone; independence from `PuzzleSession`),
tests/puzzle_regression.gd (`find_open_move()`/`request_open_move()`
determinism and forced-state cases, independent mistake/assist counters, a
100%-accuracy-with-nonzero-assists case, the post-completion no-op guard, and
the revised `get_results()` formula across representative mistake/assist
combinations including the zero-floor case), tests/puzzle_layout_check.gd
(the in-flight-departure case; keyboard/gamepad focus-reachability of
`%OpenMoveButton`; a real-scene Results-screen check of all five metric
values; the end-to-end controller -> `PuzzleScoreboard` -> Results wiring
across established/improved/tied/not_improved outcomes and the overall
score; a real replay resetting `mistakes`/`open_move_assists`/`score` to
zero), and tests/save_input_regression.gd (`PuzzleScoreboard` never reads or
writes `GlobalState`/`GameState`/the save file, and a freshly started
process begins with zero session-best entries and a zero overall score), run
via the same `run_puzzle_regressions.py`/`run_regressions.py` launchers;
requires `PUZZLE_SCOREBOARD_FAILURES=0` and `REGRESSION_FAILURES=0`
respectively alongside the existing markers.

## Structural Analysis (PuzzleAnalyzer)

`PuzzleAnalyzer` (scripts/puzzle/puzzle_analyzer.gd) is a headless,
deterministic, static `RefCounted` class sitting beside `PuzzleSolver` —
never an extension of it, and never a second rules engine. `analyze(definition)`
asserts `definition != null` as its first statement (a caller-programming-error
precondition, matching `PuzzleState._init()`'s own `assert(definition.is_valid(), ...)`
style; empirically, a failed assertion in this repo's headless test
environment aborts before `analyze()`'s `return`, so the caller receives an
empty `Dictionary` rather than a crash or a well-formed result — this is the
documented, tested outcome, never implementation-defined). For a non-null
definition it returns board-scale metrics (`width`, `height`, `total_cells`,
`arrow_count`, `occupied_cell_count`, `density`), arrow-geometry metrics
(single/multi-cell counts, average/max length, bend counts derived from
direction changes along each tail), legal-move-structure metrics reusing
`PuzzleSolver.analyze()`'s own witness (initial/min/max/average legal counts,
forced/branching state counts and ratios, longest forced run, and the full
per-step `legal_choice_sequence`), a dependency graph, per-step
`unlock_sequence`, and geometric `blocker_distance` proxies. Every blocking
fact is derived from `PuzzleState.is_blocked`/`get_arrow_head` (via a
disposable internal `PuzzleState` for the witness walk) or from
`PuzzleDefinition.forward_ray_cells`/`get_cell_owners` directly (for the
static graph) — never an independently reimplemented blocking rule.
`PuzzleSolver`'s existing `analyze()` return contract, metric semantics, and
correctness path are completely unchanged; `PuzzleDefinition` gained no new
fields. No composite difficulty score, formula, or player-facing rating
exists anywhere in this capability's output.

**Dependency graph orientation**: one node per active arrow; a directed edge
`A -> B` means "A currently occupies a cell on B's forward escape ray" (A
blocks B), read directly off `PuzzleState.is_blocked`'s own check. Under this
orientation an arrow's out-degree counts arrows it blocks and its in-degree
counts arrows currently blocking it. `depth`/`longest_chain` are precisely
defined as the graph's longest **simple** directed path (no repeated node),
which is always finite even when a geometric dependency cycle exists (a
per-path visited set forbids revisiting a node, so a cycle simply ends that
branch of the search rather than looping) — ties are broken deterministically
by the lexicographically smallest head sequence under `PuzzleSolver`'s own
existing (y, x)-ascending comparator. When the graph is acyclic (every solvable
definition) the chain is computed by dynamic programming in time linear in the
edge count, returning exactly what the exhaustive simple-path search returns;
only a graph containing a cycle runs that exhaustive search, which is
exponential and cannot finish on dense boards. tests/puzzle_analyzer_check.gd
asserts the two agree on random acyclic graphs and that a dense layered graph
resolves instantly. This is an analysis-only allowance over
a *candidate* definition; it never implies solvability or catalog eligibility
— `PuzzleSolver.analyze(definition).solvable` remains the sole authority on
completability, and the catalog regression gate remains the sole authority on
what may ship. A static out-degree is never reported or treated as "cascade
fan-out": because a blocked arrow may have more than one blocker, removing
one neighbor does not guarantee another becomes legal, so cascade/unlock
fan-out (`max_unlock_fan_out`) is measured empirically by diffing the legal
set immediately before/after each witness removal step, never derived from
static out-degree.

**Objective metrics vs. labeled perceptual hypotheses**: every metric above
(board scale, arrow geometry, legal-move structure, dependency-graph
properties, cascade/unlock fan-out, blocker distance) is objectively computed
from `PuzzleDefinition`/`PuzzleSolver` alone, with no human input. Several
related concepts remain explicitly-labeled **hypotheses** to be checked
against real play, never established product truth: *dependency
discoverability*, *false affordance*, *unlock rhythm* (as a felt experience,
distinct from the objectively-inspectable `legal_choice_sequence` it names),
*reasoning span* (as a full perceptual measure, distinct from the geometric
`blocker_distance` proxy), and *composition/shape as a source of memorability
or identity*. A lightweight human-calibration worksheet/record process exists
for checking these hypotheses against actual play, entirely separate from
this objective analysis capability. `blocker_distance` in particular is
documented as a geometric proxy for "how far away is this," not a validated
measurement of human perception.

Source of truth: tests/puzzle_analyzer_check.gd (fourteen hand-constructed
synthetic fixtures with hand-computed expected values, run in the same bare
isolated temp project as tests/puzzle_regression.gd/puzzle_catalog_check.gd:
an independent pair, a simple three-arrow chain, a deep four-arrow total-order
chain, a three-arrow branching/open puzzle, a three-arrow cascade with
fan-out 3, a two-blocker-on-one-arrow puzzle, a bent-tail dependency, a
long-range blocker at ray distance 5, a structurally invalid definition
(every field but board/geometry zeroed), a valid-but-unsolvable two-arrow
cycle (dependency_graph/blocker_distance still computed; witness/legal-move
fields empty), a mixed acyclic-chain-plus-cyclic-component graph proving
exact termination, determinism and non-mutation including interleaved live
gameplay, the null-definition precondition, and the occupancy-grid
visualization helper); requires `PUZZLE_ANALYZER_FAILURES=0`. Each of the six
experimental `PuzzleCatalog` entries is additionally checked against
its own exact numeric threshold in tests/puzzle_catalog_check.gd
(`_check_experimental_puzzle_properties`): `nested_chain` depth >= 3 with a
non-collinear longest chain; `cascade_key_arrow` max_unlock_fan_out >= 2 (in
fact 3); `dense_unravel` density >= 0.55 with initial_legal_ratio <= 0.50;
`bent_network` >= 2 bent arrows with a tail-sourced dependency edge;
`long_range_blocker` a blocker-distance edge >= 4 on a board >= 5 wide/tall;
`composed_shaped` >= 49 total cells with >= 1 genuine dependency edge, its
occupied cells forming a filled diamond.

A separate, deliberately **non-gating** developer report
(tests/puzzle_structural_report.gd, run via
tests/run_puzzle_structural_report.py in the same bare-isolated-project
pattern) enumerates the full catalog through `PuzzleAnalyzer` and prints a
deterministic per-puzzle block: validity and solvability, board size, occupied
cells and density, arrow counts, mean/maximum length and bends, legal-choice
sequence, dependency/unlock measures, blocker distance and the complete
ordered `(x,y)` solver witness. A fixed nine-question Catalog Comparison
section remains (deepest chain, fewest initial legal arrows, widest branching,
largest cascade, longest forced run, highest density, most bends, longest
blocker distance, largest board). The report's process exit only means it ran;
structural validity and solver witness replay are enforced by the catalog
regression gate. It carries no `check()`/failure counter and no
`PUZZLE_*_FAILURES=0` marker — it reports facts, never a pass/fail judgment
or a composite score. The objective facts for the six newer geometric
experiments and the human play evidence are kept separately in
`.knowledge/reference/gordian-knot-experiments.md`.

### Puzzle-design vocabulary (provisional)

These terms come from one aggregate author play session and are design
hypotheses, not gameplay rules, analyzer metrics or validated laws. Nothing in
the rule layer, `PuzzleAnalyzer` or scoring encodes them, and structural
metrics remain diagnostics that do not measure gameplay quality.

- **Meaningful Density**: density from substantial arrow geometry (long paths,
  bends, interweaving, tail-based dependencies) rather than many trivial or
  single-cell arrows.
- **Neighborhood**: a recognizable area where meaningful local progress can be
  made. **Cross-Neighborhood Dependency**: finishing one area depends on
  geometry associated with another. **Bridge Arrow**: a substantial arrow that
  connects otherwise recognizable neighborhoods.
- **Insight Chain**: a short sequence of upcoming consequences that becomes
  understandable together after a discovery.
- **Discovery Beat**: uncertainty, investigation, discovery, insight chain,
  execution, visible payoff, changed board, renewed uncertainty. A good level
  likely contains several.

Blocker distance is descriptive: a long blocker relationship matters only when
finding it requires meaningful tracing. The evidence and its limits are in
`.knowledge/reference/gordian-knot-experiments.md`. The open design question is
composing these ingredients into one excellent level, not generating levels.

## Presentation Layer

`ArrowView` (scenes/puzzle/arrow_view.gd) renders one continuous ink arrow
with a passive Line2D body and Polygon2D head. Copied ordered cell offsets
become consecutive tail-to-head center points; adjacency never adds a
connection. Round stroke joins and a round tail cap retain orthogonal
centerlines. Single-cell arrows have an in-cell decorative shaft. Geometry
is built at the board's fixed canonical 64-pixel cell extent; the board's World
parent scales it for display, and the view's own `scale` stays reserved for
feedback pulses.
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
head, keyed by head, sized and positioned once at the canonical 64-pixel cell
extent to each shape's own bounding box (computed from
`PuzzleDefinition.get_arrow_cells(head)`) under a passive `World` child. The
board Control itself is a fixed, clipped, focusable GUI target; it never
scales. `PuzzleViewportTransform` (see Canvas Navigation below) owns fitting,
zoom, pan and the board-local <-> logical mapping, and the board applies its
`world_position()`/`world_scale()` to `World` on every view or size change.
A primary mouse-button press (not release, and `not event.is_echo()`, so a
held button cannot repeat) is mapped through the inverse transform to a raw
cell via `_gui_input`, and `cell_clicked` is emitted with that cell as-is —
head or tail, or even a cell belonging to no arrow (but never one outside
the board or while the layout is invalid). It has no rule dependency: the
controller resolves ownership and decides the outcome.
`play_removed(head)`/`play_blocked(head)` always take the canonical head,
never a raw clicked cell. `departure_finished` fires once each departing view
fully clears the grid edge (see Feedback precedence and departures below for
the `DepartureClip`/`_departing_views` mechanics).

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
(`HUDMargin`) and a navigation toolbar row (`ToolbarMargin`/`Toolbar`, an
`HFlowContainer` holding Zoom Out, Zoom In, Fit Puzzle, a Pan toggle and a
one-line help label that wraps below the buttons when narrow) stacked above
`BoardArea`/`PuzzleBoard`; a container stack
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
`PuzzleSession.has_next()`) into `show_results()`; on the last puzzle of a
group it is hidden and a `%LevelSelectButton` (which returns to
the main menu with Level Select open) takes its place, while Replay and Main
Menu always remain available. `show_results()` also takes the completed puzzle's
id, rendering a `%PuzzleLabel` identity line from the same
`PuzzleCatalog`/`PuzzleSession` pair the controller used for that attempt,
alongside the total-arrows/mistakes/open-move-assists/score/accuracy metrics.
Switching puzzles via Replay, pause-menu Restart, Next Puzzle, or Level
Select all go through a full scene reconstruction, so any prior attempt's
departing views/callbacks are disposed exactly as `setup()` replacement
already guarantees within one attempt (see Feedback precedence and
departures below) — no stale completion signal from a finished attempt can
reach the next one.

Source of truth: tests/puzzle_layout_check.gd (a multi-cell shape's view
bounding box (canonical extent, and its projected size) and tail-cell click
resolution through the inverse transform against a standalone `PuzzleBoard`,
checked at both window sizes; HUD/board rect non-overlap and
nonzero visibility at 1280x720 and 960x540; results awaiting every queued
departure across a full multi-arrow clear; resize preserving departure
cell-distance progress and re-projecting the unchanged canonical geometry
through the World transform;
resize at 960x540/1280x720/800x800, resize while paused and zero-extent
recovery; a combined scenario with two concurrent departures of different
route lengths paused mid-flight, resized while paused, then resumed, each
finishing exactly once; `setup()` replacement canceling and disposing any
in-flight departure so no stale completion reaches a replaced attempt; a
post-completion selection being ignored; a freshly instantiated scene
starting clean; 20 rapid repeated selections on a blocked tail cell counting
exactly once each without disturbing the attempt; the blocked-cue duration
cap; and, for every one of the twenty-two `PuzzleCatalog` entries in turn: the
board's active view count matches the definition's arrow count, the HUD
puzzle label matches the catalog title, and the same solver-derived
zero-mistake witness clears through the real scene with unchanged
scoring/mistakes/accuracy — proving engine-generality end-to-end, not only
via the pure `puzzle_catalog_check.gd` solver gate; that triggering Show Me
an Open Move while an earlier removal's departure is still visually in
flight responds immediately against the current logical state (matching
`find_open_move()`), never suppressed or queued by the in-flight animation;
and that the Open Move control is visible, enabled, keyboard/gamepad
focusable, actually receives focus, and has its `pressed` signal genuinely
wired to the real handler — literal simulated hardware key/gamepad event
delivery through the headless GUI pipeline was found nondeterministic in
this environment and is intentionally not asserted here; it remains a manual
desktop smoke-test concern, the same class of limitation already noted below
for OS pointer eligibility), run via the same
`run_puzzle_regressions.py` launcher against the real project with
APPDATA/XDG_DATA_HOME redirected so no player save data is touched;
requires `PUZZLE_LAYOUT_FAILURES=0`. A puzzle-specific check resolves its
own clear order from `PuzzleSolver.analyze()` against whichever definition
is actually loaded rather than a hardcoded witness, so it never assumes one
specific board's geometry. A further check drives the real
`SceneLoader.reload_current_scene()`/`get_tree().change_scene_to_packed()`
path directly (not just repeated `instantiate()` calls) to prove a non-first
selected puzzle survives that exact reload, that Next Puzzle advances to
the following entry of its group with fresh state, and that a group-ending
puzzle's results omit `%NextPuzzleButton` and show `%LevelSelectButton`. Interactive desktop smoke testing
(resize, rapid clicks, pause mid-feedback, restart) remains a separate
manual verification step; the headless checks above are not a replacement
for it.

## Canvas Navigation

The puzzle is a world; the screen is a window onto it. Board size, zoom and
viewport are separate: authored dimensions define the board, the transform's
`cell_pixels` defines the visual scale, and the board Control's area defines
the visible region.

`PuzzleViewportTransform` (scripts/presentation/puzzle_viewport_transform.gd) is
a pure `RefCounted` presentation helper (no rule, scene or asset dependency)
owning all of it, one authority for projection and inverse mapping. A logical
point `q` (cells) appears at board-local pixel `p = viewport / 2 + (q -
center_cells) * cell_pixels`. `configure(grid_size)` resets dimensions and
fit/manual state; `resize_view(area)` applies the resize policy;
`fit_puzzle()` centers the original dimensions with a 16-pixel margin per edge
(`fit scale = min((V.x-32)/D.x, (V.y-32)/D.y)`); `zoom_at(factor, anchor)`
keeps the anchored logical point fixed except for the bounds clamp; `pan_pixels`
/`pan_camera_pixels` move the content/camera; `cell_at(local)` floors the
inverse and returns `(-1, -1)` for an invalid layout, a point outside the
viewport or outside the board; `reveal_cell(cell)` zooms up to at least 48
pixels per cell about the current center and pans minimally so the head cell
plus 8 pixels of padding is inside the viewport (a satisfied reveal changes
nothing). `world_position()`/`world_scale()` derive the World projection. Zoom
is bounded to `[fit scale, max(192, fit scale)]` pixels per cell in 1.2x steps;
each center axis is clamped to the interior half-extent (an axis whose board
fits stays centered). Setup and Fit set fit mode; an effective zoom/pan sets
manual mode (a no-op at a bound does not). A resize refits in fit mode and, in
manual mode, keeps the absolute scale and logical center (then clamps). An
unusable area (an axis <= 32 pixels or non-finite) marks the layout invalid:
conversions yield no coordinate, navigation is refused, the last valid
projection is retained, and a valid area re-applies the stored-mode policy.
Camera state is never serialized and resets with every attempt (Replay, Next,
Level Select and pause-menu Restart all rebuild the scene).

`PuzzleBoard` owns one transform. `World` (passive, mouse-ignore) holds the
active views and the `DepartureClip`, which clips departing views to the full
logical board extent; the board clips to the viewport. Navigation only moves
`World`. `ArrowView.set_presentation_layout_valid(bool)` suspends departure
advancement (also for direct `advance_departure` calls) while the area is
invalid without altering routes, progress or the canonical extent; the board
propagates it only on validity changes, and an off-screen view with a valid
layout keeps advancing. Public navigation API: `fit_puzzle()`, `zoom_in()`,
`zoom_out()`, `set_pan_mode(bool)`, `set_navigation_enabled(bool)`, plus
`view_changed` and `pan_mode_changed` signals.

Input arbitration (all through the one transform): wheel zoom anchors at the
pointer with the step scaled by `event.factor` and clamped to one 1.2x step per
event, so a trackpad burst cannot overshoot; middle-button drag pans; the
Pan toggle makes a primary drag pan instead of select. In Select mode a primary
press keeps its established select-once behavior and never doubles as a pan.
A middle press suppresses simultaneous primary presses; drags capture the
button, motion changes presentation only, release anywhere (including outside
the board) ends the gesture, and pause, hiding, window/board focus loss, results,
setup, leaving Pan mode and a motion event reporting no held button cancel it.
Navigation input is eligible only while navigation is enabled (the controller
disables it while results cover the board and re-enables it on a new attempt),
the layout is valid, the board is visible and the tree is not paused; the
controller does not gate it on pending departures, so the player may
navigate while the last departures drain.

Focused board actions: `canvas_zoom_in` (Equal / numpad plus / right shoulder),
`canvas_zoom_out` (Minus / numpad minus / left shoulder) and `canvas_fit` (F /
gamepad Y) are additive custom `InputMap` actions in project.godot, shown and
remappable by the inherited options list and restored by `AppSettings`. They
act about the view center only while the board has focus. The existing
`move_*` actions (WASD / left stick) pan the camera at 600 screen pixels per
second (normalized diagonals, board-focused and window-focused only, polled per
frame); events matching these actions are consumed by the focused board so a
stick push cannot also move GUI focus. Focus navigation is never consumed
whatever the remapping: Tab/Shift+Tab and D-pad buttons always keep a way off the
board. Tab order is Open Move, Zoom Out, Zoom In, Fit Puzzle, Pan, board, then
back; the board's D-pad up returns to Pan and every toolbar control has
directional neighbors that leave the toolbar. The board draws a visible focus
outline; toolbar controls are never disabled at a limit. The toolbar's help
line and tooltips derive their key names from the live `InputMap` (refreshed on
unpause after a remap). This adds navigation only — there is no new
keyboard/gamepad arrow-selection system; arrow selection remains a primary
mouse press.

Open Move reveal: the controller still calls `PuzzleState.request_open_move()`
exactly once. `suggest_open_move(head)` first reveals the head at >= 48 pixels
per cell with 8 pixels of padding (unchanged when already readable and visible;
a long arrow need not fit, only its head), then starts the existing pulse. During
an invalid area the reveal stays pending and applies once on valid recovery with
no extra rule call or assist; clearing or replacing the suggestion cancels it.

Source of truth: tests/puzzle_viewport_transform_check.gd (pure numeric fit,
inverse round trips, anchors, per-axis clamps, mode policy, resize, invalid area,
reveal, projection; run in an isolated project), tests/puzzle_canvas_check.gd
(scene-level fit and layout for the large board and all original puzzles at
four window sizes, wheel/drag/button navigation, limits, corner reachability,
state and view-identity invariance, focus loop and remapping safety, drag
eligibility and cancellation, transformed head/tail/empty/departed hits,
blocked counters, Open Move reveal and pending reveal, state/solver/analyzer/
scoreboard parity across navigation, concurrent long departures under
navigation/resize/pause/zero-area/replacement, results gating, per-attempt view
reset and no persisted viewport data) and tests/save_input_regression.gd
(additive action remapping and restore); run via
`python tests/run_puzzle_regressions.py` (requires `PUZZLE_VIEWPORT_FAILURES=0`
and `PUZZLE_CANVAS_FAILURES=0`) and `python tests/run_regressions.py`. Real
mouse/keyboard/gamepad feel, focus visuals, rendered antialiasing readability
and frame-time behavior need desktop review; headless events cannot establish
them.

## Menu Integration and the No-Reset Guarantee

`scenes/menus/main_menu/main_menu.tscn` and `main_menu_with_animations.tscn`
both point `game_scene_path` at `res://scenes/puzzle/arrow_puzzle.tscn`.
`main_menu_with_animations.gd` overrides `new_game()` only to select
`reference_knot` before delegating to the base `MainMenu`; `load_game_scene()`
uses the base default implementation (`SceneLoader.load_scene(game_scene_path)` only), so
opening the puzzle from Play/New Game never calls `GlobalState.reset()` or
`GameState.start_game()`. Continue stays hidden (the scene's default
`visible = false`, no longer overridden to conditionally show it); its
scene/script remain in source, unreachable from this menu, so it can be restored
later. Level Select is visible and opens the grouped puzzle list; the Results
Level Select button and the play HUD's Back button both return to it. The
`NewGameButton` carries a tooltip
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

ArrowView orders presentation as departing > blocked > suggested > hover >
normal. Blocked presses cancel both existing writers, set the entire arrow to
critical #E8221A, restart a 1.00 -> 1.10 -> 1.00 pulse over 150ms, and hold the
red for 600ms in total before returning to normal.
Hover eligibility can change during red feedback without recoloring it.
Completion restores unit scale and immediately assigns ember if eligible,
otherwise ink, and resumes any still-active suggested pulse first if one was
in progress; there is no extra hover-duration delay. No input lock or
persistent disabled appearance is introduced.

`set_suggested(true)` (the "Show Me an Open Move" indicator) starts the same
1.00 -> 1.10 -> 1.00 scale ratio blocked feedback uses, in the same ember
`#C6620C` accent hover already uses — no new palette entry — but looping
continuously rather than firing once, so the identified arrow stays
noticeable with no mouse hover present (the control is keyboard/gamepad
reachable). While suggested, a mere hover neither recolors nor stops the
pulse (suggested outranks hover in the precedence order above), though
`_hovered` is still tracked so hover's own color/tween resumes correctly once
the suggestion clears. `PuzzleBoard.suggest_open_move(head)` is presentation
routing only — it never decides which arrow is legal; the controller passes
it the head `PuzzleState.request_open_move()` already returned.
`PuzzleBoard.clear_suggestion()` is called on every accepted selection
(played or blocked) and on a fresh `setup()`, so a stale suggestion never
outlives the board state it was shown against; a repeated request before the
shown arrow is played simply re-suggests (clearing then re-showing) rather
than stacking two indicators.

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
figures; the existing score uses success green. `puzzle_results.gd`'s
`show_results()` displays five result fields: total arrows, mistakes, open
move assists (`%OpenMoveAssistsLabel`, alongside mistakes rather than folded
into it — see the Open Move Assistance and Session Scoring section below),
score and accuracy; plus Replay, Main Menu and focus behavior, all unchanged
in mechanism. No root/global theme reaches inherited pause/options screens.
Source of truth: tests/puzzle_presentation_check.gd checks theme scope,
fonts, all five result fields' text and content bounds at both supported
desktop sizes, and focus styles. Shared roles and font/license evidence are
in .knowledge/architecture/game-visual-system.md.
