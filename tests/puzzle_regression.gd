extends SceneTree
## Headless rule regression suite for the arrow puzzle core: shape geometry
## validation, blocking, atomic removal, and solvability analysis. No scene,
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

## Full witness solution order for the fixed board's heads: A, B, D, C, E, F, G, H.
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

func _test_shape_geometry_validation() -> void:
	var d := PuzzleDefinition.Direction

	# Valid: straight, multi-turn and empty tails.
	check(PuzzleDefinition.new(4, 4, {Vector2i(2, 2): d.DOWN}, {Vector2i(2, 2): [Vector2i(2, 1), Vector2i(2, 0)]}).is_valid(),
		"a straight two-cell tail behind the head is valid")
	check(PuzzleDefinition.new(4, 4, {Vector2i(2, 2): d.DOWN}, {Vector2i(2, 2): [Vector2i(2, 1), Vector2i(1, 1), Vector2i(1, 0)]}).is_valid(),
		"a tail with more than one right-angle turn is valid")
	check(PuzzleDefinition.new(4, 4, {Vector2i(2, 2): d.DOWN}, {}).is_valid(),
		"an omitted tail (single-cell arrow) is valid")

	# Invalid: first tail cell not immediately behind the head.
	check(not PuzzleDefinition.new(4, 4, {Vector2i(2, 2): d.DOWN}, {Vector2i(2, 2): [Vector2i(3, 2)]}).is_valid(),
		"a first tail cell beside (not behind) the head is invalid")

	# Invalid: non-adjacent gap and diagonal step.
	check(not PuzzleDefinition.new(4, 4, {Vector2i(2, 2): d.DOWN}, {Vector2i(2, 2): [Vector2i(2, 1), Vector2i(0, 1)]}).is_valid(),
		"a tail with a non-adjacent gap is invalid")
	check(not PuzzleDefinition.new(4, 4, {Vector2i(2, 2): d.DOWN}, {Vector2i(2, 2): [Vector2i(2, 1), Vector2i(1, 0)]}).is_valid(),
		"a tail with a diagonal step is invalid")

	# Invalid: repeated cell (a reversal back onto an earlier tail cell).
	check(not PuzzleDefinition.new(4, 4, {Vector2i(2, 2): d.DOWN}, {Vector2i(2, 2): [Vector2i(2, 1), Vector2i(1, 1), Vector2i(2, 1)]}).is_valid(),
		"a tail that reverses onto an earlier cell is invalid")

	# Invalid: out-of-bounds tail cell.
	check(not PuzzleDefinition.new(4, 4, {Vector2i(0, 0): d.RIGHT}, {Vector2i(0, 0): [Vector2i(-1, 0)]}).is_valid(),
		"a tail cell outside board bounds is invalid")

	# Invalid: own tail cell on the arrow's own forward escape ray.
	check(not PuzzleDefinition.new(4, 4, {Vector2i(2, 2): d.DOWN},
			{Vector2i(2, 2): [Vector2i(2, 1), Vector2i(3, 1), Vector2i(3, 2), Vector2i(3, 3), Vector2i(2, 3)]}).is_valid(),
		"a tail cell landing on the arrow's own forward escape ray is invalid")

	# Invalid: two arrows' shapes sharing a cell.
	check(not PuzzleDefinition.new(2, 2, {Vector2i(0, 0): d.RIGHT, Vector2i(0, 1): d.DOWN}, {Vector2i(0, 1): [Vector2i(0, 0)]}).is_valid(),
		"two arrows whose shapes share a cell is invalid")

	# Valid: different arrows' cells orthogonally adjacent without overlap.
	check(PuzzleDefinition.new(2, 2, {Vector2i(0, 0): d.RIGHT, Vector2i(0, 1): d.RIGHT}, {}).is_valid(),
		"different arrows' cells may be orthogonally adjacent without overlap")

func _test_definition_mutation_isolation() -> void:
	var d := PuzzleDefinition.Direction
	var arrows := {Vector2i(1, 1): d.DOWN}
	var tails := {Vector2i(1, 1): [Vector2i(1, 0)]}
	var definition := PuzzleDefinition.new(3, 3, arrows, tails)

	arrows[Vector2i(1, 1)] = d.UP
	tails[Vector2i(1, 1)].append(Vector2i(9, 9))
	check(definition.arrows[Vector2i(1, 1)] == d.DOWN,
		"mutating the caller's arrows dictionary after construction does not affect the definition")
	check(definition.get_arrow_cells(Vector2i(1, 1)).size() == 2,
		"mutating the caller's tails dictionary after construction does not affect the definition")

	var cells := definition.get_arrow_cells(Vector2i(1, 1))
	cells.append(Vector2i(9, 9))
	check(definition.get_arrow_cells(Vector2i(1, 1)).size() == 2,
		"get_arrow_cells returns an independent copy on every call")

	var owners := definition.get_cell_owners()
	owners[Vector2i(9, 9)] = Vector2i(9, 9)
	check(not definition.get_cell_owners().has(Vector2i(9, 9)),
		"get_cell_owners returns an independent copy on every call")

func _test_whole_shape_atomic_selection() -> void:
	var d := PuzzleDefinition.Direction
	var definition := PuzzleDefinition.new(3, 3, {Vector2i(1, 1): d.DOWN}, {Vector2i(1, 1): [Vector2i(1, 0)]})

	var state_via_tail := PuzzleState.new(definition)
	check(state_via_tail.select_arrow(Vector2i(1, 0)) == PuzzleState.SelectOutcome.REMOVED,
		"selecting a tail cell removes the whole shape")
	check(state_via_tail.get_arrow_head(Vector2i(1, 1)) == null and state_via_tail.get_arrow_head(Vector2i(1, 0)) == null,
		"both head and tail cells are gone after a tail-cell selection")
	check(state_via_tail.remaining() == 0 and state_via_tail.successful_removals == 1,
		"a two-cell shape counts as exactly one removal")
	check(state_via_tail.select_arrow(Vector2i(1, 1)) == PuzzleState.SelectOutcome.IGNORED,
		"reselecting the departed head after a tail-cell removal is ignored")

	var state_via_head := PuzzleState.new(definition)
	check(state_via_head.select_arrow(Vector2i(1, 1)) == PuzzleState.SelectOutcome.REMOVED,
		"selecting the head cell also removes the whole shape")
	check(state_via_head.get_arrow_head(Vector2i(1, 0)) == null,
		"the tail cell is gone after a head-cell removal")

func _test_blocking_matrix() -> void:
	var state := _new_state()
	check(not state.is_blocked(Vector2i(0, 0)), "A (LEFT) has nothing ahead: clear")
	check(state.is_blocked(Vector2i(2, 0)), "B (LEFT) is blocked by A's tail cell at (1,0), then A's head at (0,0)")
	check(state.is_blocked(Vector2i(4, 0)), "C (DOWN) is blocked by D regardless of D's own direction")
	check(not state.is_blocked(Vector2i(4, 3)), "D (RIGHT) points outward from the edge: clear")
	check(state.is_blocked(Vector2i(0, 3)), "E (UP) is blocked by A's tail cell at (0,1), then A's head at (0,0)")
	check(state.is_blocked(Vector2i(2, 3)), "F (LEFT) is blocked by E ahead on the same row")
	check(state.is_blocked(Vector2i(2, 1)), "G (UP) is blocked by B ahead on the same column")
	check(not state.is_blocked(Vector2i(3, 2)), "H (RIGHT) has nothing ahead before the edge: clear")
	check(not state.is_blocked(Vector2i(0, 0)), "A is not blocked by arrows behind it along its own axis")

## For each of the four directions, a two-arrow board where the blocker's
## HEAD sits off X's forward ray and only a TAIL cell lands on it, proving
## tails block exactly like heads without X ever seeing the blocker's head
## in its path.
func _test_tail_only_blocking_all_directions() -> void:
	var d := PuzzleDefinition.Direction

	# LEFT: blocker head one row above the shared target cell, straight tail down onto the ray.
	var left_state := PuzzleState.new(PuzzleDefinition.new(5, 5, {Vector2i(4, 2): d.LEFT, Vector2i(2, 1): d.UP}, {Vector2i(2, 1): [Vector2i(2, 2)]}))
	check(left_state.is_blocked(Vector2i(4, 2)), "LEFT-facing arrow is blocked by a straight tail cell on its ray")
	check(left_state.get_arrow_head(Vector2i(2, 1)) != Vector2i(4, 2), "the LEFT blocker's own head is a different arrow than the blocked one")
	for i in range(100):
		check(left_state.select_arrow(Vector2i(4, 2)) == PuzzleState.SelectOutcome.BLOCKED,
			"LEFT-facing arrow stays tail-blocked on repeated selection %d" % i)
	check(left_state.mistakes == 100, "100 repeated tail-caused blocks add exactly 100 mistakes")
	check(left_state.select_arrow(Vector2i(2, 1)) == PuzzleState.SelectOutcome.REMOVED, "removing the tail blocker succeeds")
	check(left_state.select_arrow(Vector2i(4, 2)) == PuzzleState.SelectOutcome.REMOVED,
		"the LEFT-facing arrow becomes a newly legal dependent once its tail blocker departs")

	# RIGHT: same blocker shape, target arrow facing the opposite way across the same row.
	var right_state := PuzzleState.new(PuzzleDefinition.new(5, 5, {Vector2i(0, 2): d.RIGHT, Vector2i(2, 1): d.UP}, {Vector2i(2, 1): [Vector2i(2, 2)]}))
	check(right_state.is_blocked(Vector2i(0, 2)), "RIGHT-facing arrow is blocked by a straight tail cell on its ray")

	# UP: blocker head one column to the side, straight tail sideways onto the ray column.
	var up_state := PuzzleState.new(PuzzleDefinition.new(5, 5, {Vector2i(2, 4): d.UP, Vector2i(1, 2): d.LEFT}, {Vector2i(1, 2): [Vector2i(2, 2)]}))
	check(up_state.is_blocked(Vector2i(2, 4)), "UP-facing arrow is blocked by a straight tail cell on its ray")
	check(up_state.get_arrow_head(Vector2i(1, 2)) != Vector2i(2, 4), "the UP blocker's own head is a different arrow than the blocked one")

	# DOWN: same blocker shape, target arrow facing the opposite way down the same column.
	var down_state := PuzzleState.new(PuzzleDefinition.new(5, 5, {Vector2i(2, 0): d.DOWN, Vector2i(1, 2): d.LEFT}, {Vector2i(1, 2): [Vector2i(2, 2)]}))
	check(down_state.is_blocked(Vector2i(2, 0)), "DOWN-facing arrow is blocked by a straight tail cell on its ray")

func _test_bent_tail_blocks() -> void:
	var d := PuzzleDefinition.Direction
	# A two-turn tail approaches the same blocking cell from a different column,
	# proving a bent (not just straight) tail blocks exactly like a straight one.
	var state := PuzzleState.new(PuzzleDefinition.new(5, 5, {Vector2i(2, 4): d.UP, Vector2i(0, 3): d.DOWN},
		{Vector2i(0, 3): [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)]}))
	check(state.is_blocked(Vector2i(2, 4)), "UP-facing arrow is blocked by a two-turn bent tail's final cell")

func _test_own_tail_never_blocks_self() -> void:
	var d := PuzzleDefinition.Direction
	# A four-cell shape (head plus a three-turn tail) with nothing else on the
	# board: every one of its own cells sits behind the head, and none of
	# them may ever count as blocking against itself.
	var definition := PuzzleDefinition.new(5, 5, {Vector2i(2, 2): d.UP},
		{Vector2i(2, 2): [Vector2i(2, 3), Vector2i(1, 3), Vector2i(1, 4)]})
	var state := PuzzleState.new(definition)
	check(not state.is_blocked(Vector2i(2, 2)), "an arrow with a long bent tail is never blocked by its own cells")
	check(state.select_arrow(Vector2i(2, 2)) == PuzzleState.SelectOutcome.REMOVED,
		"an arrow with a long bent tail and a clear path removes successfully")

func _test_edge_facing_arrow_with_tail_is_clear() -> void:
	var d := PuzzleDefinition.Direction
	# The head is already at the board edge in its own direction of travel;
	# owning a tail behind it must not affect that empty forward ray.
	var definition := PuzzleDefinition.new(3, 3, {Vector2i(0, 1): d.LEFT}, {Vector2i(0, 1): [Vector2i(1, 1)]})
	var state := PuzzleState.new(definition)
	check(not state.is_blocked(Vector2i(0, 1)), "an edge-facing arrow with a tail behind it is still immediately clear")

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

## Confirms the actual shipped content (not a synthetic fixture) genuinely
## contains a straight tail, a multi-turn tail, at least one tail cell
## blocking another arrow, and a dependent that clears once its blocker
## departs.
func _test_shipped_content_demonstrates_required_properties() -> void:
	var fixed := PuzzleDefinition.create_fixed()

	var has_straight_tail := false
	var has_bent_tail := false
	for head in fixed.tails.keys():
		var tail: Array = fixed.tails[head]
		if tail.size() == 1:
			has_straight_tail = true
		elif tail.size() > 1:
			has_bent_tail = true
	check(has_straight_tail, "the shipped board includes at least one straight tail")
	check(has_bent_tail, "the shipped board includes at least one multi-turn tail")

	var owners: Dictionary = fixed.get_cell_owners()
	var tail_caused_block := false
	for head in fixed.arrows.keys():
		for ray_cell in fixed.forward_ray_cells(head, fixed.arrows[head]):
			var owner = owners.get(ray_cell)
			if owner != null and owner != head and ray_cell != owner:
				tail_caused_block = true
	check(tail_caused_block, "the shipped board includes at least one tail cell blocking another arrow")

	var state := _new_state()
	check(state.is_blocked(Vector2i(2, 0)), "B starts blocked by A on the shipped board")
	check(state.select_arrow(Vector2i(0, 0)) == PuzzleState.SelectOutcome.REMOVED, "removing A succeeds")
	check(not state.is_blocked(Vector2i(2, 0)), "B becomes a newly legal dependent once A departs")
	check(state.select_arrow(Vector2i(2, 0)) == PuzzleState.SelectOutcome.REMOVED, "B removes successfully once clear")

func _test_ignored_and_inactive_selection() -> void:
	var state := _new_state()
	var taps_before := state.total_taps
	check(state.select_arrow(Vector2i(3, 1)) == PuzzleState.SelectOutcome.IGNORED, "empty cell selection is ignored")
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

	# A long run of mistakes never limits how much further play can happen:
	# finish clearing every remaining arrow after the 100-mistake run above.
	for cell in WITNESS_ORDER:
		if state.get_arrow_head(cell) != null:
			state.select_arrow(cell)
	check(state.completed, "the whole board still completes normally after a long run of mistakes")
	check(state.mistakes == 100, "the mistake count from before the completing moves is unaffected by finishing the board")

func _test_blocked_feedback_duration_constant() -> void:
	check(PuzzleFeedback.BLOCKED_CUE_DURATION_SECONDS <= PuzzleFeedback.BLOCKED_CUE_DURATION_CAP_SECONDS,
		"the coded blocked-feedback cue duration constant does not exceed its coded 0.3-second cap")
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

func _complete_with_mistakes_and_assists(mistake_count: int, assist_count: int) -> PuzzleState:
	var state := _new_state()
	for i in range(mistake_count):
		state.select_arrow(Vector2i(2, 0)) # B stays blocked by A until A departs in WITNESS_ORDER
	for i in range(assist_count):
		state.request_open_move() # never removes an arrow or affects mistakes/total_taps
	for cell in WITNESS_ORDER:
		state.select_arrow(cell)
	return state

## Score = max(total_arrows - (mistakes + open_move_assists * 5), 0),
## and open_move_assists is exposed in get_results() alongside the existing
## fields. Covers the zero-mistake/zero-assist perfect case (score equals
## total_arrows), assists alone driving the score to its zero floor, and a
## mixed mistakes+assists case.
func _test_results_arithmetic_with_open_move_assists() -> void:
	var cases := [
		{"mistakes": 0, "assists": 0, "score": 8},
		{"mistakes": 0, "assists": 1, "score": 3},
		{"mistakes": 0, "assists": 2, "score": 0}, # assists alone reach the zero floor
		{"mistakes": 1, "assists": 1, "score": 2},
		{"mistakes": 3, "assists": 1, "score": 0},
	]
	for case in cases:
		var state := _complete_with_mistakes_and_assists(case["mistakes"], case["assists"])
		check(state.completed, "state completes for %d mistakes / %d assists" % [case["mistakes"], case["assists"]])
		var results := state.get_results()
		check(results["mistakes"] == case["mistakes"],
			"recorded mistakes match for %d mistakes / %d assists" % [case["mistakes"], case["assists"]])
		check(results["open_move_assists"] == case["assists"],
			"recorded open_move_assists match for %d mistakes / %d assists" % [case["mistakes"], case["assists"]])
		check(results["score"] == case["score"],
			"score matches max(total_arrows - (mistakes + assists*5), 0) = %d for %d mistakes / %d assists" %
			[case["score"], case["mistakes"], case["assists"]])
	var perfect := _complete_with_mistakes_and_assists(0, 0)
	var perfect_results := perfect.get_results()
	check(perfect_results["score"] == perfect.total_arrows,
		"a zero-mistake, zero-assist attempt always scores the puzzle's full total_arrows")

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

# --- Show Me an Open Move ----------------------------------------------------

func _test_open_move_deterministic_repeat_and_forced_state() -> void:
	# Deterministic repeat, no intervening move, on the shipped board.
	var state := _new_state()
	var first_find = state.find_open_move()
	check(first_find == Vector2i(0, 0),
		"find_open_move() on the fresh shipped board returns A, the (y,x)-ascending-first legal head")
	check(state.find_open_move() == first_find,
		"repeated find_open_move() with no intervening move returns the same arrow (deterministic)")

	var first_request = state.request_open_move()
	check(first_request == first_find, "request_open_move() returns the same head find_open_move() would")
	check(state.open_move_assists == 1, "the first valid request increments open_move_assists to 1")
	var second_request = state.request_open_move()
	check(second_request == first_request,
		"a repeated request before playing the shown arrow identifies the same arrow again")
	check(state.open_move_assists == 2,
		"each repeated valid request increments open_move_assists independently, even for the same arrow")
	check(state.mistakes == 0 and state.total_taps == 0, "Open Move requests never affect mistakes or total_taps")

	# Forced state: exactly one legal arrow (B's head blocks A; A's own ray is
	# clear, so only B is legal until it departs).
	var d := PuzzleDefinition.Direction
	var forced_definition := PuzzleDefinition.new(2, 2, {Vector2i(0, 0): d.RIGHT, Vector2i(1, 0): d.DOWN})
	var forced_state := PuzzleState.new(forced_definition)
	check(forced_state.is_blocked(Vector2i(0, 0)) and not forced_state.is_blocked(Vector2i(1, 0)),
		"the forced-state fixture has exactly one legal arrow")
	check(forced_state.find_open_move() == Vector2i(1, 0),
		"find_open_move() identifies the sole legal arrow in a forced state")
	check(forced_state.request_open_move() == Vector2i(1, 0),
		"request_open_move() identifies the same sole legal arrow")
	check(forced_state.open_move_assists == 1, "a forced-state request still counts as one valid assist")

func _test_open_move_independent_counters_and_perfect_accuracy_with_assists() -> void:
	# Independent counters: a mistake never affects open_move_assists, and an
	# assist request never affects mistakes.
	var state := _new_state()
	check(state.select_arrow(Vector2i(2, 0)) == PuzzleState.SelectOutcome.BLOCKED,
		"B is blocked while A remains active")
	check(state.mistakes == 1 and state.open_move_assists == 0, "a mistake does not affect open_move_assists")
	state.request_open_move()
	check(state.mistakes == 1 and state.open_move_assists == 1,
		"an Open Move request does not affect mistakes; the two counters remain independent")

	# 100% accuracy alongside a nonzero assist count: use request_open_move()
	# to discover and play every move, so every tap succeeds and no move is
	# ever a mistake.
	var perfect_state := _new_state()
	while not perfect_state.completed:
		var head = perfect_state.request_open_move()
		check(head != null, "request_open_move() always identifies a legal arrow until the board clears")
		check(perfect_state.select_arrow(head) == PuzzleState.SelectOutcome.REMOVED,
			"playing the Open Move-identified arrow always succeeds")
	var results := perfect_state.get_results()
	check(results["accuracy"] == 1.0, "playing only Open Move-identified arrows yields 100% accuracy")
	check(results["open_move_assists"] == perfect_state.total_arrows,
		"one assist was used per arrow here, so open_move_assists equals total_arrows")
	check(results["open_move_assists"] > 0, "the assist count is nonzero alongside 100% accuracy")

func _test_open_move_completed_state_guard() -> void:
	var state := _complete_with_mistakes(0)
	var assists_before := state.open_move_assists
	check(state.find_open_move() == null, "find_open_move() returns null once the attempt is completed")
	check(state.request_open_move() == null, "request_open_move() returns null once the attempt is completed")
	check(state.open_move_assists == assists_before,
		"a request after completion never increments open_move_assists (mirrors select_arrow()'s completed guard)")

# --- User Story 3: Prove the Puzzle Is Solvable Before It Ships -------------

func _test_solver_shipped_witness() -> void:
	var fixed := PuzzleDefinition.create_fixed()
	var result: Dictionary = PuzzleSolver.analyze(fixed)
	check(result.valid and result.solvable, "the shipped puzzle definition is valid and solvable")
	check(result.validation_errors.is_empty(), "a solvable definition has no validation errors")

	var witness: Array = result.witness
	check(witness.size() == fixed.arrows.size(), "the witness is complete: one entry per arrow")
	var seen: Dictionary = {}
	for head in witness:
		seen[head] = true
	check(seen.size() == witness.size(), "the witness has no duplicate heads (uniqueness)")

	var replay := PuzzleState.new(fixed)
	for head in witness:
		check(replay.select_arrow(head) == PuzzleState.SelectOutcome.REMOVED,
			"replaying the witness head %s against a fresh state is never blocked" % [head])
	check(replay.completed and replay.mistakes == 0,
		"executing the exact witness sequence against the rule layer clears the board with zero mistakes")

func _test_solver_invalid_input() -> void:
	var invalid := PuzzleDefinition.new(2, 2, {Vector2i(0, 0): PuzzleDefinition.Direction.RIGHT, Vector2i(0, 1): PuzzleDefinition.Direction.DOWN},
		{Vector2i(0, 1): [Vector2i(0, 0)]})
	var result: Dictionary = PuzzleSolver.analyze(invalid)
	check(not result.valid and not result.solvable, "analyzing an invalid definition reports invalid, not unsolvable")
	check(result.witness.is_empty(), "an invalid definition never returns a witness")
	check(not result.validation_errors.is_empty(), "an invalid definition reports at least one diagnostic")
	for key in ["states_examined", "active_choices_encountered", "legal_choices_encountered", "forced_states", "branching_states", "no_move_states"]:
		check(result.metrics[key] == 0, "invalid input yields a zero %s metric" % [key])

func _test_solver_two_arrow_cycle_is_unsolvable() -> void:
	var d := PuzzleDefinition.Direction
	var cycle := PuzzleDefinition.new(2, 1, {Vector2i(0, 0): d.RIGHT, Vector2i(1, 0): d.LEFT})
	check(cycle.is_valid(), "a two-arrow facing cycle is a structurally valid definition")
	var result: Dictionary = PuzzleSolver.analyze(cycle)
	check(result.valid and not result.solvable, "a two-arrow facing cycle is valid but unsolvable")
	check(result.witness.is_empty(), "an unsolvable definition never returns a partial sequence as a witness")

func _test_solver_removable_prefix_then_residual_cycle() -> void:
	var d := PuzzleDefinition.Direction
	# A is immediately removable (its ray points past the edge); B and C then
	# form a permanent facing cycle with no legal move ever available to either.
	var mixed := PuzzleDefinition.new(3, 2, {Vector2i(2, 0): d.RIGHT, Vector2i(0, 0): d.RIGHT, Vector2i(1, 0): d.LEFT})
	var result: Dictionary = PuzzleSolver.analyze(mixed)
	check(result.valid and not result.solvable,
		"a removable prefix followed by a residual cycle is still reported unsolvable, not a false success")
	check(result.witness.is_empty(), "a residual cycle after a removable prefix never returns a partial witness")

func _test_solver_deterministic_repeated_calls() -> void:
	var fixed := PuzzleDefinition.create_fixed()
	var first: Dictionary = PuzzleSolver.analyze(fixed)
	var second: Dictionary = PuzzleSolver.analyze(fixed)
	check(first.solvable == second.solvable and first.witness == second.witness,
		"repeated analyze() calls on the same definition return identical outcomes and witnesses")

func _test_solver_does_not_mutate_input_or_live_attempt() -> void:
	var fixed := PuzzleDefinition.create_fixed()
	var arrows_before: int = fixed.arrows.size()
	var tails_before: int = fixed.tails.size()

	var live := PuzzleState.new(fixed)
	live.select_arrow(Vector2i(0, 0)) # a live, in-progress attempt sharing the same definition

	PuzzleSolver.analyze(fixed)

	check(fixed.arrows.size() == arrows_before and fixed.tails.size() == tails_before,
		"analyze() never mutates the caller's definition")
	check(live.successful_removals == 1 and live.remaining() == arrows_before - 1,
		"analyze() never affects a separately live attempt built from the same definition")

## Directly exercises the exchange-lemma claim the solver's no-backtracking
## design depends on: for a genuinely branching state (here, two fully
## independent arrows, both legal from the start), completion must not
## depend on which of the simultaneously legal choices is taken first. This
## drives PuzzleState directly (not PuzzleSolver.analyze, which only ever
## takes its own canonical first choice) so both orders are actually forced.
func _test_solver_order_independence_on_branching_state() -> void:
	var d := PuzzleDefinition.Direction
	var definition := PuzzleDefinition.new(2, 2, {Vector2i(0, 0): d.DOWN, Vector2i(1, 0): d.DOWN})

	var start_with_x := PuzzleState.new(definition)
	check(not start_with_x.is_blocked(Vector2i(0, 0)) and not start_with_x.is_blocked(Vector2i(1, 0)),
		"both independent arrows are simultaneously legal at the start (a genuine branching state)")
	check(start_with_x.select_arrow(Vector2i(0, 0)) == PuzzleState.SelectOutcome.REMOVED, "forcing X first succeeds")
	check(start_with_x.select_arrow(Vector2i(1, 0)) == PuzzleState.SelectOutcome.REMOVED, "Y then completes the board")
	check(start_with_x.completed and start_with_x.mistakes == 0, "forcing X before Y still reaches a complete, mistake-free solution")

	var start_with_y := PuzzleState.new(definition)
	check(start_with_y.select_arrow(Vector2i(1, 0)) == PuzzleState.SelectOutcome.REMOVED, "forcing Y first succeeds")
	check(start_with_y.select_arrow(Vector2i(0, 0)) == PuzzleState.SelectOutcome.REMOVED, "X then completes the board")
	check(start_with_y.completed and start_with_y.mistakes == 0, "forcing Y before X still reaches a complete, mistake-free solution")

## The (y, x)-ascending-first legal head among a live state's still-active
## arrows, or null if none is legal. Calls only get_snapshot()/is_blocked() --
## the real rule authority -- never a duplicated blocking check.
func _first_legal_head(state: PuzzleState) -> Variant:
	var active_heads: Array = state.get_snapshot()["active_arrows"].keys()
	active_heads.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return a.y < b.y or (a.y == b.y and a.x < b.x)
	)
	for head in active_heads:
		if not state.is_blocked(head):
			return head
	return null

## Every currently-legal head of a live state, (y, x)-ascending.
func _legal_heads(state: PuzzleState) -> Array:
	var active_heads: Array = state.get_snapshot()["active_arrows"].keys()
	active_heads.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return a.y < b.y or (a.y == b.y and a.x < b.x)
	)
	var legal: Array = []
	for head in active_heads:
		if not state.is_blocked(head):
			legal.append(head)
	return legal

## Drives a live state to completion greedily (same deterministic
## (y, x)-ascending-first strategy PuzzleSolver.analyze() uses), calling only
## select_arrow() -- the real rule authority. Returns true iff it reaches a
## complete, mistake-free clearance; false if it gets stuck first.
func _greedy_complete(state: PuzzleState) -> bool:
	while not state.completed:
		var head = _first_legal_head(state)
		if head == null:
			return false
		if state.select_arrow(head) != PuzzleState.SelectOutcome.REMOVED:
			return false
	return true

## Extends order-independence beyond the puzzle's very first state: walks
## PuzzleSolver's own witness for definition, and at every branching state
## the witness passes through (more than one legal head available), replays
## the same prefix on a fresh state, forces each *other* legal alternative
## next instead of the witness's own choice, then greedily completes from
## there. Confirms the monotonicity exchange property -- "any currently
## legal arrow is safe to take" -- holds at every branch actually visited by
## the witness, not only at the puzzle's opening move. Bounded: one greedy
## completion per alternative per branching state along the one witness
## walk, never a full reachable-state enumeration (see .knowledge/architecture/arrow-puzzle.md's
## Solvability Analysis for the rationale).
func _check_order_independence_at_every_branch(definition: PuzzleDefinition, label: String) -> void:
	var result: Dictionary = PuzzleSolver.analyze(definition)
	check(result.solvable, "%s is solver-confirmed solvable (prerequisite for its branch check)" % label)
	if not result.solvable:
		return
	var witness: Array = result.witness
	var prefix: Array = []
	var live_state := PuzzleState.new(definition)
	for step_index in range(witness.size()):
		var chosen_head: Vector2i = witness[step_index]
		var legal_here: Array = _legal_heads(live_state)
		if legal_here.size() > 1:
			for alt_head in legal_here:
				if alt_head == chosen_head:
					continue
				var branch_state := PuzzleState.new(definition)
				for prefix_head in prefix:
					branch_state.select_arrow(prefix_head)
				var branch_outcome: PuzzleState.SelectOutcome = branch_state.select_arrow(alt_head)
				check(branch_outcome == PuzzleState.SelectOutcome.REMOVED,
					"%s: forcing alternative legal head %s instead of the witness's %s at step %d is itself legal" %
					[label, alt_head, chosen_head, step_index])
				check(_greedy_complete(branch_state),
					"%s: forcing alternative legal head %s instead of the witness's %s at step %d still reaches a complete, mistake-free solution" %
					[label, alt_head, chosen_head, step_index])
		live_state.select_arrow(chosen_head)
		prefix.append(chosen_head)

func _test_order_independence_at_every_branch_shipped_board() -> void:
	_check_order_independence_at_every_branch(PuzzleDefinition.create_fixed(), "the shipped create_fixed() board")

# --- User Story 4: Retain Structural Counts for Future Difficulty Work ------

const DIFFICULTY_LABEL_KEYS: Array[String] = ["difficulty", "difficulty_score", "difficulty_level", "level", "easy_medium_hard"]

func _check_no_difficulty_labels(result: Dictionary) -> void:
	for key in DIFFICULTY_LABEL_KEYS:
		check(not result.has(key), "the result has no top-level '%s' field" % [key])
		check(not result.metrics.has(key), "metrics has no '%s' field" % [key])

func _check_nonnegative_metrics(metrics: Dictionary) -> void:
	for key in metrics.keys():
		check(metrics[key] >= 0, "metric '%s' is nonnegative" % [key])

func _test_solver_metrics_single_arrow() -> void:
	var definition := PuzzleDefinition.new(2, 1, {Vector2i(0, 0): PuzzleDefinition.Direction.RIGHT})
	var result: Dictionary = PuzzleSolver.analyze(definition)
	check(result.solvable, "a single clear arrow is solvable")
	var m: Dictionary = result.metrics
	check(m.states_examined == 1, "one-arrow board examines exactly one state")
	check(m.active_choices_encountered == 1 and m.legal_choices_encountered == 1,
		"one-arrow board: active=1, legal=1")
	check(m.forced_states == 1 and m.branching_states == 0 and m.no_move_states == 0,
		"one-arrow board: forced=1, branching=0, no_move=0")
	check(m.states_examined == m.forced_states + m.branching_states + m.no_move_states,
		"states_examined equals the sum of forced, branching and no_move states")
	_check_nonnegative_metrics(m)
	_check_no_difficulty_labels(result)

	var repeat: Dictionary = PuzzleSolver.analyze(definition)
	check(repeat.witness == result.witness and repeat.metrics == result.metrics,
		"repeated analyze() calls on the single-arrow board are stable")

func _test_solver_metrics_two_independent_arrows() -> void:
	var d := PuzzleDefinition.Direction
	var definition := PuzzleDefinition.new(2, 2, {Vector2i(0, 0): d.DOWN, Vector2i(1, 0): d.DOWN})
	var result: Dictionary = PuzzleSolver.analyze(definition)
	check(result.solvable, "two independent arrows are solvable")
	var m: Dictionary = result.metrics
	check(m.states_examined == 2, "two independent arrows examine exactly two states")
	check(m.active_choices_encountered == 3 and m.legal_choices_encountered == 3,
		"two independent arrows: active=3, legal=3 (2 then 1 remaining, both fully legal)")
	check(m.branching_states == 1 and m.forced_states == 1 and m.no_move_states == 0,
		"two independent arrows: branching=1 (both legal at once), forced=1 (one left), no_move=0")
	check(m.states_examined == m.forced_states + m.branching_states + m.no_move_states,
		"states_examined equals the sum of forced, branching and no_move states")
	_check_nonnegative_metrics(m)
	_check_no_difficulty_labels(result)

	var repeat: Dictionary = PuzzleSolver.analyze(definition)
	check(repeat.witness == result.witness and repeat.metrics == result.metrics,
		"repeated analyze() calls on the two-independent-arrow board are stable")

func _test_solver_metrics_two_arrow_cycle() -> void:
	var d := PuzzleDefinition.Direction
	var definition := PuzzleDefinition.new(2, 1, {Vector2i(0, 0): d.RIGHT, Vector2i(1, 0): d.LEFT})
	var result: Dictionary = PuzzleSolver.analyze(definition)
	check(not result.solvable, "a two-arrow facing cycle is unsolvable")
	var m: Dictionary = result.metrics
	check(m.states_examined == 1, "a two-arrow cycle examines exactly one (stuck) state")
	check(m.active_choices_encountered == 2 and m.legal_choices_encountered == 0,
		"a two-arrow cycle: active=2, legal=0")
	check(m.no_move_states == 1 and m.forced_states == 0 and m.branching_states == 0,
		"a two-arrow cycle: no_move=1, forced=0, branching=0")
	check(m.states_examined == m.forced_states + m.branching_states + m.no_move_states,
		"states_examined equals the sum of forced, branching and no_move states")
	_check_nonnegative_metrics(m)
	_check_no_difficulty_labels(result)

	var repeat: Dictionary = PuzzleSolver.analyze(definition)
	check(repeat.solvable == result.solvable and repeat.metrics == result.metrics,
		"repeated analyze() calls on the two-arrow cycle are stable")

# -----------------------------------------------------------------------------

func _initialize() -> void:
	_test_definition_validation()
	_test_shape_geometry_validation()
	_test_definition_mutation_isolation()
	_test_whole_shape_atomic_selection()
	_test_tail_only_blocking_all_directions()
	_test_bent_tail_blocks()
	_test_own_tail_never_blocks_self()
	_test_edge_facing_arrow_with_tail_is_clear()
	_test_blocking_matrix()
	_test_off_axis_and_behind_do_not_block()
	_test_witness_solution()
	_test_shipped_content_demonstrates_required_properties()
	_test_ignored_and_inactive_selection()
	_test_counter_invariants_clear_and_ignored_only()
	_test_unlimited_blocked_selections()
	_test_blocked_feedback_duration_constant()
	_test_results_arithmetic_and_rounding()
	_test_results_arithmetic_with_open_move_assists()
	_test_zero_tap_accuracy()
	_test_completed_state_ignores_further_selections()
	_test_fresh_state_reset_via_replay()
	_test_open_move_deterministic_repeat_and_forced_state()
	_test_open_move_independent_counters_and_perfect_accuracy_with_assists()
	_test_open_move_completed_state_guard()
	_test_solver_shipped_witness()
	_test_solver_invalid_input()
	_test_solver_two_arrow_cycle_is_unsolvable()
	_test_solver_removable_prefix_then_residual_cycle()
	_test_solver_deterministic_repeated_calls()
	_test_solver_does_not_mutate_input_or_live_attempt()
	_test_solver_order_independence_on_branching_state()
	_test_order_independence_at_every_branch_shipped_board()
	_test_solver_metrics_single_arrow()
	_test_solver_metrics_two_independent_arrows()
	_test_solver_metrics_two_arrow_cycle()
	print("PUZZLE_FAILURES=", failures)
	quit(1 if failures else 0)
