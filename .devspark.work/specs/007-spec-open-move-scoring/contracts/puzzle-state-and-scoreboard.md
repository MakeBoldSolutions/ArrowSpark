# Interface Contracts: PuzzleState Additions and PuzzleScoreboard

**Spec**: [../spec.md](../spec.md) | **Data model**: [../data-model.md](../data-model.md)

ArrowGame is a single Godot desktop application with no external API surface;
the "interfaces" this feature exposes are the public GDScript methods the
presentation layer (scene controllers/views) consumes from the rules-authority
layer. This is the same style already used by
`.knowledge/architecture/arrow-puzzle.md` to describe `PuzzleState`'s existing
contract.

## `PuzzleState` (existing class, additions only)

```gdscript
## New field, alongside existing mistakes/total_taps/successful_removals.
var open_move_assists: int = 0

## Returns one currently-legal arrow's head, deterministically chosen
## ((y, x)-ascending among active arrows, same ordering PuzzleSolver.analyze()
## walks), or null only if no active arrow remains. Never mutates state.
## Never removes an arrow. Callable at any time, including while a departure
## animation from an earlier removal is still visually in progress elsewhere
## in the presentation layer (this method only reads active-arrow/blocking
## state, which the presentation layer never delays).
func find_open_move() -> Variant: # Vector2i | null

## Records one valid "Show Me an Open Move" request: increments
## open_move_assists by exactly one (skipped, returning null, only if
## completed is already true — mirrors select_arrow()'s completed guard),
## then returns find_open_move()'s result. Never increments total_taps,
## mistakes, or successful_removals. Repeated calls before any move is
## played each increment open_move_assists independently, per spec FR-006.
func request_open_move() -> Variant: # Vector2i | null

## get_results() dictionary shape — CHANGED to add open_move_assists and the
## new scoring formula; total_arrows/accuracy keys unchanged in meaning.
func get_results() -> Dictionary:
    # {
    #   "total_arrows": int,
    #   "mistakes": int,
    #   "open_move_assists": int,        # NEW
    #   "score": int,                    # CHANGED formula (see below)
    #   "accuracy": float,               # unchanged
    # }
    # score == max(total_arrows - (mistakes + open_move_assists * 5), 0)
```

Preconditions: none beyond the existing `_init()` precondition (a
structurally valid `PuzzleDefinition`). Postconditions: `find_open_move()` is
a pure query (no side effects); `request_open_move()`'s only side effect is
incrementing `open_move_assists`.

## `PuzzleScoreboard` (new class)

```gdscript
class_name PuzzleScoreboard
extends RefCounted
## Session-lifetime, in-memory-only holder of the best Completed Attempt
## Result per puzzle and the derived overall session score. Same static-var,
## process-lifetime precedent as PuzzleSession/GameVisualStyle. Never reads
## or writes GlobalState, GameState, LevelState, or user://global_state.tres.
## Reset only by a fresh engine process.

## puzzle_id (String, PuzzleCatalog id) -> Completed Attempt Result Dictionary
static var _best_results: Dictionary = {}

## Records a completed attempt against its puzzle's session-best. Returns
## exactly one of: "established" (no prior best existed), "improved"
## (strictly greater score than the prior best), "tied" (equal score),
## "not_improved" (lower score). Only "established"/"improved" replace the
## stored dictionary; "tied"/"not_improved" leave it unchanged (spec FR-012).
##
## Asserts result has the five expected keys (total_arrows, mistakes,
## open_move_assists, score, accuracy) and that score is a nonnegative int no
## greater than total_arrows -- a contract shape/range sanity check only. It
## does NOT re-derive whether the attempt is actually completed, recompute
## the score formula, or otherwise duplicate PuzzleState's scoring/completion
## authority; PuzzleScoreboard trusts the meaning of a well-shaped result and
## only rejects an obviously malformed one.
static func record_attempt(puzzle_id: String, result: Dictionary) -> String

## The stored Session-Best Result dictionary for puzzle_id, or null if that
## puzzle has not been completed this session.
static func get_best(puzzle_id: String) -> Variant: # Dictionary | null

## Sum of ["score"] across every stored Session-Best Result. 0 if none.
static func get_overall_score() -> int
```

Preconditions: `record_attempt` requires `result` to be a `PuzzleState.get_results()`
-shaped dictionary for a *completed* attempt (the caller — `arrow_puzzle.gd`
— only calls this once, from `_show_results()`, after `_state.completed` is
already known true). `PuzzleScoreboard` asserts the dictionary's shape and
score range (see above) but takes the caller's word for *completion itself*
and does not re-derive it — that remains `PuzzleState`'s sole authority.
Postconditions: `get_overall_score()` after any `record_attempt` call
reflects exactly the FR-014/FR-011/FR-012 rules — replacement never lowers
the sum, and improvement raises it by exactly the improvement.
