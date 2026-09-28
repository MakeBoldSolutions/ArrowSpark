class_name PuzzleScoreboard
extends RefCounted
## Session-lifetime, in-memory-only holder of the best Completed Attempt
## Result per puzzle and the derived overall session score. Same static-var,
## process-lifetime precedent as PuzzleSession/GameVisualStyle: a GDScript
## static var is bound to the running process, not to any node or scene, so
## it survives SceneLoader.reload_current_scene()/load_scene() identically to
## an autoload while needing no project.godot registration or _ready()
## lifecycle. Never reads or writes GlobalState, GameState, LevelState, or
## user://global_state.tres. Reset only by a fresh engine process.

## puzzle_id (String, PuzzleCatalog id) -> Completed Attempt Result Dictionary
## (the exact shape PuzzleState.get_results() returns).
static var _best_results: Dictionary = {}

## Records a completed attempt against its puzzle's session-best. Returns
## exactly one of: "established" (no prior best existed), "improved"
## (strictly greater score than the prior best), "tied" (equal score), or
## "not_improved" (lower score). Only "established"/"improved" replace the
## stored dictionary; "tied"/"not_improved" leave it unchanged.
##
## Asserts result has the five expected keys (total_arrows, mistakes,
## open_move_assists, score, accuracy) and that score is a nonnegative int no
## greater than total_arrows -- a contract shape/range sanity check only. It
## does NOT re-derive whether the attempt is actually completed, recompute
## the score formula, or otherwise duplicate PuzzleState's scoring/completion
## authority; PuzzleScoreboard trusts the meaning of a well-shaped result and
## only rejects an obviously malformed one.
static func record_attempt(puzzle_id: String, result: Dictionary) -> String:
	assert(result.has("total_arrows") and result.has("mistakes") and result.has("open_move_assists")
		and result.has("score") and result.has("accuracy"),
		"PuzzleScoreboard.record_attempt requires a PuzzleState.get_results()-shaped dictionary")
	assert(result["score"] is int and result["score"] >= 0 and result["score"] <= result["total_arrows"],
		"PuzzleScoreboard.record_attempt requires a nonnegative score no greater than total_arrows")

	var existing: Variant = _best_results.get(puzzle_id)
	if existing == null:
		_best_results[puzzle_id] = result.duplicate()
		return "established"
	if result["score"] > existing["score"]:
		_best_results[puzzle_id] = result.duplicate()
		return "improved"
	if result["score"] == existing["score"]:
		return "tied"
	return "not_improved"

## The stored Session-Best Result dictionary for puzzle_id, or null if that
## puzzle has not been completed this session.
static func get_best(puzzle_id: String) -> Variant:
	return _best_results.get(puzzle_id)

## Sum of ["score"] across every stored Session-Best Result. 0 if none.
static func get_overall_score() -> int:
	var total: int = 0
	for result in _best_results.values():
		total += result["score"]
	return total
