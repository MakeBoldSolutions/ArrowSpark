extends SceneTree
## Headless isolated-project unit checks for PuzzleScoreboard: no scene, font
## or PuzzleCatalog/PuzzleState dependency, since PuzzleScoreboard operates
## purely on plain result Dictionaries. Run via tests/run_puzzle_regressions.py
## in the same bare isolated temp project as tests/puzzle_regression.gd.

var failures: int = 0

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

## A minimal PuzzleState.get_results()-shaped dictionary for a given score.
## total_arrows is fixed at 10 so any score in [0, 10] is a valid fixture.
func _result(score: int, mistakes: int = 0, assists: int = 0) -> Dictionary:
	return {
		"total_arrows": 10,
		"mistakes": mistakes,
		"open_move_assists": assists,
		"score": score,
		"accuracy": 1.0,
	}

## First completion establishes the session best; a strictly
## higher score replaces it; equal or lower scores never do. Each test case
## uses its own distinct, synthetic puzzle_id (never a real PuzzleCatalog id)
## because PuzzleScoreboard's static state persists across every check in
## this one process run and exposes no reset method by design -- distinct
## ids are how each case stays isolated from every other.
func _test_established_improved_tied_not_improved() -> void:
	var id := "scoreboard_test_puzzle_a"
	check(PuzzleScoreboard.get_best(id) == null, "a never-completed puzzle has no session-best result")

	check(PuzzleScoreboard.record_attempt(id, _result(6)) == "established",
		"the first completed attempt establishes the session best")
	check(PuzzleScoreboard.get_best(id)["score"] == 6, "the established best reflects the first attempt's score")

	check(PuzzleScoreboard.record_attempt(id, _result(4)) == "not_improved",
		"a strictly lower score is reported not_improved")
	check(PuzzleScoreboard.get_best(id)["score"] == 6, "a worse replay never lowers the session best")

	check(PuzzleScoreboard.record_attempt(id, _result(6)) == "tied",
		"an equal score is reported tied")
	check(PuzzleScoreboard.get_best(id)["score"] == 6, "a tied replay never changes the session best")

	check(PuzzleScoreboard.record_attempt(id, _result(9)) == "improved",
		"a strictly higher score is reported improved")
	check(PuzzleScoreboard.get_best(id)["score"] == 9, "a better replay replaces the session best with the new score")

	check(PuzzleScoreboard.record_attempt(id, _result(9)) == "tied",
		"repeating the new best again is reported tied, not improved")
	check(PuzzleScoreboard.get_best(id)["score"] == 9, "the session best remains at the improved value")

## Full result fields are preserved (not score-only), so the
## stored best can explain more than just the number if ever displayed.
func _test_stored_result_preserves_full_shape() -> void:
	var id := "scoreboard_test_puzzle_b"
	PuzzleScoreboard.record_attempt(id, _result(7, 2, 1))
	var best: Dictionary = PuzzleScoreboard.get_best(id)
	check(best["total_arrows"] == 10 and best["mistakes"] == 2 and best["open_move_assists"] == 1
		and best["score"] == 7 and best["accuracy"] == 1.0,
		"the stored session-best result preserves every field of the completed attempt, not just its score")

## Overall session score sums every stored session-best score;
## improving one level increases the overall score by exactly the
## improvement; a puzzle never completed contributes nothing.
func _test_overall_session_score_summation() -> void:
	var id1 := "scoreboard_test_puzzle_c1"
	var id2 := "scoreboard_test_puzzle_c2"
	var id_never_completed := "scoreboard_test_puzzle_c3"
	var baseline: int = PuzzleScoreboard.get_overall_score()

	PuzzleScoreboard.record_attempt(id1, _result(5))
	PuzzleScoreboard.record_attempt(id2, _result(8))
	check(PuzzleScoreboard.get_overall_score() == baseline + 13,
		"overall session score is the sum of every completed puzzle's session-best score")

	PuzzleScoreboard.record_attempt(id1, _result(9)) # improves id1 by 4
	check(PuzzleScoreboard.get_overall_score() == baseline + 17,
		"improving one level's session best increases the overall score by exactly the improvement (4, from 5 to 9)")

	PuzzleScoreboard.record_attempt(id1, _result(3)) # worse replay of id1
	check(PuzzleScoreboard.get_overall_score() == baseline + 17,
		"a worse replay of one level never lowers the overall session score")

	check(PuzzleScoreboard.get_best(id_never_completed) == null,
		"a puzzle never completed this session has no session-best entry")
	# id_never_completed's absence (not a zero-score entry) is what keeps it
	# out of the sum above -- already implicitly proven by the totals matching
	# exactly id1 + id2 with no third contribution.

## Confirms PuzzleScoreboard has no dependency on, or interaction with,
## PuzzleSession -- the two are independent static-var classes with
## different single responsibilities.
func _test_independent_of_puzzle_session() -> void:
	var id := "scoreboard_test_puzzle_d"
	var session_id_before := PuzzleSession.get_current_id()
	PuzzleScoreboard.record_attempt(id, _result(5))
	check(PuzzleSession.get_current_id() == session_id_before,
		"recording a completed attempt never changes PuzzleSession's current selection")

func _initialize() -> void:
	_test_established_improved_tied_not_improved()
	_test_stored_result_preserves_full_shape()
	_test_overall_session_score_summation()
	_test_independent_of_puzzle_session()
	print("PUZZLE_SCOREBOARD_FAILURES=", failures)
	quit(1 if failures else 0)
