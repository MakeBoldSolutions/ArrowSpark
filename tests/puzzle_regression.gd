extends SceneTree
## Headless rule regression suite for the arrow puzzle core (FR-001, FR-003,
## FR-004, FR-005, FR-006, FR-008, FR-009, FR-010, FR-011, FR-012). No scene,
## input or rendering dependency; run via tests/run_puzzle_regressions.py.

var failures: int = 0

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func _new_state() -> PuzzleState:
	return PuzzleState.new(PuzzleDefinition.create_fixed())

## Full witness solution order per data-model.md: A, B, D, C, E, F, G, H.
const WITNESS_ORDER: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(2, 0), Vector2i(4, 3), Vector2i(4, 0),
	Vector2i(0, 3), Vector2i(2, 3), Vector2i(2, 1), Vector2i(3, 2),
]

# --- User Story 1: Start and Clear the Puzzle -------------------------------

func _test_definition_validation() -> void:
	check(PuzzleDefinition.create_fixed().is_valid(), "fixed definition is structurally valid")
	check(not PuzzleDefinition.new(0, 4, {Vector2i(0, 0): PuzzleDefinition.Direction.UP}).is_valid(),
		"zero width is invalid")
	check(not PuzzleDefinition.new(5, 4, {}).is_valid(), "empty arrow map is invalid")
	check(not PuzzleDefinition.new(5, 4, {Vector2i(5, 0): PuzzleDefinition.Direction.UP}).is_valid(),
		"out-of-bounds cell is invalid")
	check(not PuzzleDefinition.new(5, 4, {Vector2i(0, 0): 99}).is_valid(),
		"non-cardinal direction is invalid")

	var fixed := PuzzleDefinition.create_fixed()
	var directions_present := {}
	for cell in fixed.arrows.keys():
		directions_present[fixed.arrows[cell]] = true
	check(directions_present.size() == 4, "fixed board includes all four cardinal directions")

func _test_blocking_matrix() -> void:
	var state := _new_state()
	check(not state.is_blocked(Vector2i(0, 0)), "A (LEFT) has nothing ahead: clear")
	check(state.is_blocked(Vector2i(2, 0)), "B (LEFT) is blocked by distant A across an empty gap")
	check(state.is_blocked(Vector2i(4, 0)), "C (DOWN) is blocked by D regardless of D's own direction")
	check(not state.is_blocked(Vector2i(4, 3)), "D (RIGHT) points outward from the edge: clear")
	check(state.is_blocked(Vector2i(0, 3)), "E (UP) is blocked by A ahead on the same column")
	check(state.is_blocked(Vector2i(2, 3)), "F (LEFT) is blocked by E ahead on the same row")
	check(state.is_blocked(Vector2i(2, 1)), "G (UP) is blocked by B ahead on the same column")
	check(not state.is_blocked(Vector2i(3, 2)), "H (RIGHT) has nothing ahead before the edge: clear")
	check(not state.is_blocked(Vector2i(0, 0)), "A is not blocked by arrows behind it along its own axis")

func _test_off_axis_and_behind_do_not_block() -> void:
	var arrows := {
		Vector2i(2, 2): PuzzleDefinition.Direction.UP,
		Vector2i(2, 3): PuzzleDefinition.Direction.DOWN, # same column, behind (wrong side)
		Vector2i(1, 1): PuzzleDefinition.Direction.RIGHT, # diagonal
		Vector2i(3, 0): PuzzleDefinition.Direction.LEFT, # different parallel line
	}
	var state := PuzzleState.new(PuzzleDefinition.new(5, 5, arrows))
	check(not state.is_blocked(Vector2i(2, 2)),
		"behind, diagonal and different-parallel-line arrows do not block a clear arrow")

func _test_witness_solution() -> void:
	var state := _new_state()
	var expected_remaining := state.total_arrows
	for cell in WITNESS_ORDER:
		var outcome := state.select_arrow(cell)
		check(outcome == PuzzleState.SelectOutcome.REMOVED, "witness selection at %s is clear" % [cell])
		expected_remaining -= 1
		check(state.remaining() == expected_remaining, "remaining decreases by exactly one per clear removal")
	check(state.completed, "puzzle completes once all arrows are removed")
	check(state.mistakes == 0, "witness solution records no mistakes")
	check(state.total_taps == state.total_arrows, "total taps equal successful removals with no mistakes")

func _test_ignored_and_inactive_selection() -> void:
	var state := _new_state()
	var taps_before := state.total_taps
	check(state.select_arrow(Vector2i(1, 1)) == PuzzleState.SelectOutcome.IGNORED, "empty cell selection is ignored")
	check(state.total_taps == taps_before, "ignored empty-cell selection does not tap")
	check(state.select_arrow(Vector2i(0, 0)) == PuzzleState.SelectOutcome.REMOVED, "A is clear and removed")
	check(state.select_arrow(Vector2i(0, 0)) == PuzzleState.SelectOutcome.IGNORED,
		"re-selecting a departed arrow is ignored, so it cannot be removed twice")
	check(state.total_taps == taps_before + 1, "ignored reselection does not add a duplicate tap")
	check(not state.is_blocked(Vector2i(0, 0)), "querying blocking on an absent cell returns false")

func _test_counter_invariants_clear_and_ignored_only() -> void:
	# US1 scope only: clear and ignored selections. Blocked-selection accounting
	# is verified by US2 tests below (analyze-F1: a test task must not assert
	# behavior a later phase is responsible for implementing).
	var state := _new_state()
	for cell in [Vector2i(9, 9), Vector2i(0, 0), Vector2i(9, 9), Vector2i(4, 3)]:
		state.select_arrow(cell)
	check(state.total_taps == state.successful_removals + state.mistakes,
		"total-taps invariant holds for a clear/ignored-only sequence")
	check(state.total_arrows == state.remaining() + state.successful_removals,
		"total-arrows invariant holds for a clear/ignored-only sequence")

# --- User Story 2: Learn Through Unlimited Mistakes -------------------------

func _test_unlimited_blocked_selections() -> void:
	var state := _new_state()
	var ignored_before := state.total_taps
	state.select_arrow(Vector2i(9, 9)) # empty cell: never a mistake
	check(state.mistakes == 0 and state.total_taps == ignored_before,
		"an ignored empty-cell selection is never counted as a mistake")

	for i in range(100):
		var outcome := state.select_arrow(Vector2i(2, 0)) # B, blocked while A remains active
		check(outcome == PuzzleState.SelectOutcome.BLOCKED, "B stays blocked on repeated selection %d" % i)
	check(state.mistakes == 100, "100 consecutive blocked selections add exactly 100 mistakes")
	check(state.remaining() == state.total_arrows, "the board is unchanged after 100 blocked selections")
	check(state.total_taps == 100, "all 100 blocked selections count once each")

	check(state.select_arrow(Vector2i(0, 0)) == PuzzleState.SelectOutcome.REMOVED, "removing A unblocks B")
	check(state.select_arrow(Vector2i(2, 0)) == PuzzleState.SelectOutcome.REMOVED,
		"B is clear immediately once its blocker departs; play continues without interruption")
	check(state.total_taps == 102, "tap total reflects exactly 102 accepted selections")
	check(state.mistakes == 100, "mistakes remain exactly 100 after B is finally cleared")
	check(state.successful_removals == 2, "two successful removals recorded (A, then B)")

func _test_blocked_feedback_duration_constant() -> void:
	check(PuzzleFeedback.BLOCKED_CUE_DURATION_SECONDS <= PuzzleFeedback.BLOCKED_CUE_DURATION_CAP_SECONDS,
		"the coded blocked-feedback cue duration constant does not exceed the FR-005 0.3-second cap")
	check(PuzzleFeedback.BLOCKED_CUE_DURATION_SECONDS > 0.0,
		"the blocked-feedback cue has a positive, visible duration")

# --- User Story 3: Review Results and Replay --------------------------------

func _complete_with_mistakes(mistake_count: int) -> PuzzleState:
	var state := _new_state()
	for i in range(mistake_count):
		state.select_arrow(Vector2i(2, 0)) # B stays blocked by A until A departs in WITNESS_ORDER
	for cell in WITNESS_ORDER:
		state.select_arrow(cell)
	return state

func _test_results_arithmetic_and_rounding() -> void:
	var cases := [
		{"mistakes": 0, "score": 8, "percent": "100.0%"},
		{"mistakes": 3, "score": 5, "percent": "72.7%"},
		{"mistakes": 8, "score": 0, "percent": "50.0%"},
		{"mistakes": 9, "score": 0, "percent": "47.1%"},
		{"mistakes": 120, "score": 0, "percent": "6.3%"}, # exact 6.25% tie rounds half away from zero
	]
	for case in cases:
		var state := _complete_with_mistakes(case["mistakes"])
		check(state.completed, "state completes for %d mistakes" % case["mistakes"])
		var results := state.get_results()
		check(results["mistakes"] == case["mistakes"], "recorded mistakes match for %d mistakes" % case["mistakes"])
		check(results["score"] == case["score"], "score matches max(total-mistakes,0) for %d mistakes" % case["mistakes"])
		var formatted := PuzzleResultsFormat.format_accuracy_percent(results["accuracy"])
		check(formatted == case["percent"],
			"accuracy display '%s' matches expected '%s' for %d mistakes" % [formatted, case["percent"], case["mistakes"]])

func _test_zero_tap_accuracy() -> void:
	var state := _new_state()
	var results := state.get_results()
	check(results["accuracy"] == 0.0, "zero accepted taps yields zero accuracy, avoiding division by zero")

func _test_completed_state_ignores_further_selections() -> void:
	var state := _complete_with_mistakes(0)
	var taps_before := state.total_taps
	var removals_before := state.successful_removals
	check(state.select_arrow(Vector2i(0, 0)) == PuzzleState.SelectOutcome.IGNORED,
		"a completed attempt ignores further board selections")
	check(state.total_taps == taps_before, "completed state does not add taps")
	check(state.successful_removals == removals_before, "completed state does not add removals")

func _test_fresh_state_reset_via_replay() -> void:
	var definition := PuzzleDefinition.create_fixed()
	var played := PuzzleState.new(definition)
	played.select_arrow(Vector2i(2, 0)) # a mistake, to prove it does not leak into the fresh state
	played.select_arrow(Vector2i(0, 0))

	var fresh := PuzzleState.new(definition)
	check(fresh.total_taps == 0 and fresh.mistakes == 0 and fresh.successful_removals == 0,
		"a fresh state built from the same definition (Replay) starts with zero counters")
	check(fresh.remaining() == fresh.total_arrows, "a fresh state restores the full remaining count")
	check(not fresh.completed, "a fresh state is not completed")
	check(played.mistakes == 1 and played.successful_removals == 1,
		"the prior attempt's counters are independent of the fresh Replay state")

# -----------------------------------------------------------------------------

func _initialize() -> void:
	_test_definition_validation()
	_test_blocking_matrix()
	_test_off_axis_and_behind_do_not_block()
	_test_witness_solution()
	_test_ignored_and_inactive_selection()
	_test_counter_invariants_clear_and_ignored_only()
	_test_unlimited_blocked_selections()
	_test_blocked_feedback_duration_constant()
	_test_results_arithmetic_and_rounding()
	_test_zero_tap_accuracy()
	_test_completed_state_ignores_further_selections()
	_test_fresh_state_reset_via_replay()
	print("PUZZLE_FAILURES=", failures)
	quit(1 if failures else 0)
