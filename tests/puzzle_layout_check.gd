extends SceneTree
## Headless scene-based check for the arrow puzzle's HUD/board layout,
## multi-cell shape bounds, departure/completion lifecycle and
## feedback-cue duration. Runs against the real project so the full
## scene/addon dependency graph is available; run_puzzle_regressions.py
## redirects APPDATA/XDG_DATA_HOME so no player save/settings data is touched.

var failures: int = 0

## A head order that fully clears the given definition with zero mistakes,
## resolved via the same solver every attempt's legality already agrees
## with — never a hardcoded order tied to one specific board.
func _clear_order_for(definition: PuzzleDefinition) -> Array[Vector2i]:
	var result: Dictionary = PuzzleSolver.analyze(definition)
	var witness: Array[Vector2i] = []
	for head in result.witness:
		witness.append(head)
	return witness

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

## Session-best independent test: exercises the real controller -> PuzzleScoreboard ->
## Results wiring end-to-end (established/improved/tied/not_improved and the overall score).
## Uses Open Move assist count (never a puzzle-specific "known blocked cell")
## to make each attempt's score deterministically better/worse/tied, so this
## check works against any catalog id without assuming its geometry. Must
## run before any other check in this file completes PuzzleCatalog.id_at(0),
## since the "established" (first-ever completion) outcome can only be
## observed once per puzzle id per process.
func _check_session_best_and_overall_score_progression() -> void:
	# Runs before any other check has sized the root viewport; without a real
	# size here, PuzzleBoard's viewport transform stays invalid and departure
	# advancement stays suspended, so departure animations can never progress/complete.
	get_root().size = Vector2i(1280, 720)
	await process_frame
	var id := PuzzleCatalog.id_at(0)
	PuzzleSession.set_current_id(id)
	check(PuzzleScoreboard.get_best(id) == null,
		"this puzzle has no session-best entry before its first completion in this process")
	var baseline_overall: int = PuzzleScoreboard.get_overall_score()

	# First completion, imperfect (one assist), so a later perfect replay can
	# genuinely improve it -- a perfect run already scores the maximum
	# possible, so it could never itself be "improved" upon afterward.
	var puzzle_a: Control = await _complete_via_real_scene_with_assists(id, 1)
	var established_score: int = puzzle_a._state.get_results()["score"]
	check(puzzle_a.get_node("%PuzzleResults").get_node("%SessionComparisonLabel").text ==
		"New session best: %d" % established_score,
		"the first completion this session establishes the session best")
	check(PuzzleScoreboard.get_overall_score() == baseline_overall + established_score,
		"the overall session score increases by the newly-established best")
	check(puzzle_a.get_node("%PuzzleResults").get_node("%OverallSessionScoreLabel").text ==
		"Overall Session Score: %d" % PuzzleScoreboard.get_overall_score(),
		"the Results screen displays the correct overall session score after establishing")
	puzzle_a.queue_free()
	await process_frame

	# Worse replay (two assists): session best and overall score unchanged.
	var puzzle_b: Control = await _complete_via_real_scene_with_assists(id, 2)
	var worse_score: int = puzzle_b._state.get_results()["score"]
	check(worse_score < established_score, "the two-assist replay genuinely scores lower than the one-assist baseline")
	check(puzzle_b.get_node("%PuzzleResults").get_node("%SessionComparisonLabel").text == "Session best unchanged",
		"a worse replay is reported as not improving the session best")
	check(PuzzleScoreboard.get_overall_score() == baseline_overall + established_score,
		"a worse replay never lowers the overall session score")
	puzzle_b.queue_free()
	await process_frame

	# Tied replay (one assist again, same score as established): unchanged.
	var puzzle_c: Control = await _complete_via_real_scene_with_assists(id, 1)
	var tied_score: int = puzzle_c._state.get_results()["score"]
	check(tied_score == established_score, "repeating the same assist count reproduces the same score")
	check(puzzle_c.get_node("%PuzzleResults").get_node("%SessionComparisonLabel").text ==
		"Matched session best: %d" % tied_score,
		"a tied replay is reported as matching, not improving, the session best")
	check(PuzzleScoreboard.get_overall_score() == baseline_overall + established_score,
		"a tied replay never changes the overall session score")
	puzzle_c.queue_free()
	await process_frame

	# Better replay (perfect, zero assists): session best replaced, overall
	# score increases by exactly the improvement.
	var puzzle_d: Control = await _complete_via_real_scene_with_assists(id, 0)
	var perfect_score: int = puzzle_d._state.get_results()["score"]
	check(perfect_score > established_score, "the perfect replay genuinely scores higher than the one-assist baseline")
	check(puzzle_d.get_node("%PuzzleResults").get_node("%SessionComparisonLabel").text ==
		"Session best improved to %d" % perfect_score,
		"a better replay is reported as improving the session best")
	check(PuzzleScoreboard.get_overall_score() == baseline_overall + perfect_score,
		"the overall session score increases by exactly the improvement (%d -> %d)" % [established_score, perfect_score])
	puzzle_d.queue_free()
	await process_frame
	PuzzleSession.set_current_id(PuzzleCatalog.id_at(0))

## Instantiates a fresh real puzzle scene for the given catalog id, triggers
## assist_count Open Move requests (0 is valid: a perfect run), then plays
## the puzzle's own clear order to completion. Returns the completed scene
## instance so the caller can inspect its state/Results panel directly.
func _complete_via_real_scene_with_assists(id: String, assist_count: int) -> Control:
	PuzzleSession.set_current_id(id)
	var packed: PackedScene = load("res://scenes/puzzle/arrow_puzzle.tscn")
	var puzzle: Control = packed.instantiate()
	get_root().add_child(puzzle)
	await process_frame

	var board = puzzle.get_node("%PuzzleBoard")
	var open_move_button: Button = puzzle.get_node("%OpenMoveButton")
	for i in range(assist_count):
		open_move_button.emit_signal("pressed")
	var clear_order := _clear_order_for(board.definition)
	for head in clear_order:
		board.cell_clicked.emit(head)
	await _await_departures_complete(puzzle, _WORST_CASE_DEPARTURE_SECONDS)
	return puzzle

func _check_layout_at_size(puzzle, window_size: Vector2i) -> void:
	get_root().size = window_size
	# Let the container tree settle after the resize before reading rects.
	await process_frame
	await process_frame
	var hud: Control = puzzle.get_node("%HUD")
	var board: Control = puzzle.get_node("%PuzzleBoard")
	var hud_rect: Rect2 = Rect2(hud.global_position, hud.size)
	var board_rect: Rect2 = Rect2(board.global_position, board.size)
	check(not hud_rect.intersects(board_rect),
		"HUD and board rects do not overlap at %s" % [window_size])
	check(hud.size.x > 0.0 and hud.size.y > 0.0,
		"HUD remains visible (nonzero size) at %s" % [window_size])
	check(board.size.x > 0.0 and board.size.y > 0.0,
		"board remains visible (nonzero size) at %s" % [window_size])

## A bare PuzzleBoard with a custom tailed definition, independent of the
## shipped single-arrow-per-cell fixed board, so shape-bounding-box layout
## and tail-cell click resolution can be checked at both window sizes.
func _check_multi_cell_board_bounds() -> void:
	var d := PuzzleDefinition.Direction
	var definition := PuzzleDefinition.new(4, 4, {Vector2i(2, 2): d.DOWN}, {Vector2i(2, 2): [Vector2i(2, 1), Vector2i(1, 1), Vector2i(1, 0)]})
	var board := PuzzleBoard.new()
	get_root().add_child(board)
	board.size = Vector2(1280, 720)
	board.setup(definition)
	await process_frame

	var view: ArrowView = board._views[Vector2i(2, 2)]
	var canonical: float = PuzzleViewportTransform.CANONICAL_CELL_PIXELS
	# Shape bounding box spans x in [1,2], y in [0,2]: 2 cells wide, 3 cells tall.
	check(is_equal_approx(view.size.x, canonical * 2.0) and is_equal_approx(view.size.y, canonical * 3.0),
		"a bent tail's view bounding box covers its full 2x3 canonical cell extent")
	var projected: Vector2 = view.size * board._world.scale
	var cell_pixels: float = board.view_transform.cell_pixels
	check(is_equal_approx(projected.x, cell_pixels * 2.0) and is_equal_approx(projected.y, cell_pixels * 3.0),
		"the projected bounding box covers 2x3 displayed cells at 1280x720")

	var tail_tip_local: Vector2 = board.view_transform.logical_to_local(Vector2(1.5, 0.5))
	check(board._cell_from_local(tail_tip_local) == Vector2i(1, 0),
		"a click inside the tail-tip cell resolves to that tail cell's board coordinate")

	board.size = Vector2(960, 540)
	await process_frame
	projected = view.size * board._world.scale
	cell_pixels = board.view_transform.cell_pixels
	check(is_equal_approx(view.size.x, canonical * 2.0) and is_equal_approx(view.size.y, canonical * 3.0),
		"the canonical view extent is unchanged after a resize to 960x540")
	check(is_equal_approx(projected.x, cell_pixels * 2.0) and is_equal_approx(projected.y, cell_pixels * 3.0),
		"the projected bounding box relationship holds after a resize to 960x540")
	tail_tip_local = board.view_transform.logical_to_local(Vector2(1.5, 0.5))
	check(board._cell_from_local(tail_tip_local) == Vector2i(1, 0),
		"the tail-tip cell still resolves through the inverse transform after the resize")

	board.queue_free()

## Computed bounded deadline (not a fixed guess): the largest possible
## finish distance on the fixed 5x4 board is its longest cell-unit route (the
## longest tail plus one) plus its largest edge clearance plus rear-support
## and margin; dividing by the configured speed and adding slack gives a
## ceiling that never assumes a specific fixed animation duration.
const _WORST_CASE_FINISH_DISTANCE_CELLS: float = 5.0 + 4.0 + PuzzleFeedback.EXIT_CLEARANCE_MARGIN_CELLS + 0.1
const _WORST_CASE_DEPARTURE_SECONDS: float = _WORST_CASE_FINISH_DISTANCE_CELLS / PuzzleFeedback.EXIT_SPEED_CELLS_PER_SECOND + 1.0

## Bounded deadline for a definition of any size: the longest possible finish
## distance is its longest route plus a full board crossing.
func _worst_case_seconds_for(definition: PuzzleDefinition) -> float:
	var longest_route := 1
	for head in definition.arrows.keys():
		longest_route = maxi(longest_route, definition.get_arrow_cells(head).size())
	var distance_cells: float = float(longest_route + definition.width + definition.height) + 1.0
	return distance_cells / PuzzleFeedback.EXIT_SPEED_CELLS_PER_SECOND + 1.0

func _await_departures_complete(puzzle, max_seconds: float) -> void:
	var elapsed := 0.0
	while puzzle._pending_departures > 0 and elapsed < max_seconds:
		await create_timer(0.02).timeout
		elapsed += 0.02

## Clicking every head in the puzzle's own clear order completes it; results
## must await every queued departure, not just the last click.
func _check_multiple_departures_and_completion(puzzle) -> void:
	var board = puzzle.get_node("%PuzzleBoard")
	var results = puzzle.get_node("%PuzzleResults")
	var clear_order := _clear_order_for(board.definition)
	var first_view: ArrowView = board._views[clear_order[0]]
	for head in clear_order:
		board.cell_clicked.emit(head)
		if head == clear_order[0]:
			await create_timer(0.04).timeout
	var taps: int = puzzle._state.total_taps
	board.cell_clicked.emit(clear_order[-1])
	check(puzzle._state.total_taps == taps, "completed input does not add taps while departures drain")
	var distance_before_resize: float = first_view._departure_distance
	var extent_before_resize: float = board.view_transform.cell_pixels
	var body_before_resize: PackedVector2Array = first_view._body.points.duplicate()
	get_root().size = Vector2i(1280, 720)
	await process_frame
	check(is_equal_approx(first_view._departure_distance, distance_before_resize),
		"resize preserves departure cell-distance progress without restarting")
	if extent_before_resize > 0.0 and board.view_transform.cell_pixels > 0.0 and body_before_resize.size() > 0 \
			and first_view._body.points.size() == body_before_resize.size():
		check(first_view._body.points[0].is_equal_approx(body_before_resize[0]),
			"resize keeps departing geometry canonical at the same cell-distance progress")
		check(is_equal_approx(board._world.scale.x, board.view_transform.cell_pixels / PuzzleViewportTransform.CANONICAL_CELL_PIXELS),
			"resize only rescales the parent projection of the departing geometry")
	paused = true
	var pending: int = puzzle._pending_departures
	await create_timer(0.1).timeout
	check(puzzle._pending_departures == pending and not results.visible, "pause preserves pending departures and completion barrier")
	paused = false
	check(not results.visible,
		"results stay hidden immediately after the last of several queued removals")
	await _await_departures_complete(puzzle, _WORST_CASE_DEPARTURE_SECONDS)
	check(results.visible,
		"results appear once every queued departure has fully cleared the grid edge")
	check(puzzle._pending_departures == 0, "each staggered exit decrements barrier exactly once")

## Once completed, further selections are ignored: no additional departure,
## no error, results remain shown.
func _check_completed_input_ignored(puzzle) -> void:
	var board = puzzle.get_node("%PuzzleBoard")
	var results = puzzle.get_node("%PuzzleResults")
	board.cell_clicked.emit(Vector2i(0, 0))
	await process_frame
	check(results.visible,
		"a selection after completion is ignored and results remain shown")

## Resize (960x540/1280x720/800x800), resize while paused, zero-extent
## recovery, and one combined scenario: two concurrent departures of
## different route lengths, paused mid-flight, resized while paused
## (including to zero extent), then resumed. Every departure must finish
## exactly once with correct final geometry, cell-distance progress must
## never change from a layout update alone, and no completion may be
## emitted from inside a layout callback.
func _check_departure_resize_and_pause_lifecycle() -> void:
	var d := PuzzleDefinition.Direction
	var definition := PuzzleDefinition.new(6, 6, {
		Vector2i(5, 0): d.RIGHT,
		Vector2i(5, 5): d.RIGHT,
	}, {
		Vector2i(5, 5): [Vector2i(4, 5), Vector2i(3, 5)],
	})
	var board := PuzzleBoard.new()
	get_root().add_child(board)
	board.size = Vector2(1280, 720)
	board.setup(definition)
	await process_frame

	var short_head := Vector2i(5, 0)
	var long_head := Vector2i(5, 5)
	board.play_removed(short_head)
	board.play_removed(long_head)
	check(board._departing_views.size() == 2, "both selected shapes are tracked as departing, distinct from active ownership")

	var completions := {short_head: 0, long_head: 0}
	for head in completions.keys():
		board._departing_views[head].exit_finished.connect(func(): completions[head] += 1)

	for size in [Vector2(960, 540), Vector2(1280, 720), Vector2(800, 800)]:
		board.size = size
		await process_frame
		var canonical: float = PuzzleViewportTransform.CANONICAL_CELL_PIXELS
		var extent: float = board.view_transform.cell_pixels
		check(is_equal_approx(board._departure_clip.size.x, canonical * definition.width) \
				and is_equal_approx(board._departure_clip.size.y, canonical * definition.height),
			"the departure clip keeps the canonical occupied grid extent at %s" % [size])
		check(is_equal_approx(board._departure_clip.size.x * board._world.scale.x, extent * definition.width) \
				and is_equal_approx(board._departure_clip.size.y * board._world.scale.y, extent * definition.height),
			"the projected departure clip covers the occupied grid at %s" % [size])
		check(completions[short_head] == 0 and completions[long_head] == 0,
			"resizing alone never completes a departure at %s" % [size])

	board._departing_views[short_head].advance_departure(0.05)
	board._departing_views[long_head].advance_departure(0.05)
	var short_distance_before_pause: float = board._departing_views[short_head]._departure_distance
	var long_distance_before_pause: float = board._departing_views[long_head]._departure_distance

	paused = true
	board.size = Vector2.ZERO
	await process_frame
	check(board._departing_views[short_head]._departure_distance == short_distance_before_pause \
			and board._departing_views[long_head]._departure_distance == long_distance_before_pause,
		"resize to zero extent while paused does not advance or corrupt frozen departure distance")
	check(completions[short_head] == 0 and completions[long_head] == 0,
		"no completion is emitted from inside a layout callback, even at zero extent")

	board.size = Vector2(1280, 720)
	await process_frame
	check(board._departing_views[short_head]._departure_distance == short_distance_before_pause \
			and board._departing_views[long_head]._departure_distance == long_distance_before_pause,
		"recovering a valid layout while still paused leaves frozen distance unchanged")
	paused = false

	var elapsed := 0.0
	while board._departing_views.size() > 0 and elapsed < _WORST_CASE_DEPARTURE_SECONDS:
		for head in board._departing_views.keys().duplicate():
			board._departing_views[head].advance_departure(0.05)
		elapsed += 0.05
		await process_frame

	check(completions[short_head] == 1 and completions[long_head] == 1,
		"both concurrent departures of different route lengths finish exactly once after pause/resize/resume")
	check(board._departing_views.is_empty(), "finished departing views are cleared from tracking")

	board.queue_free()

## setup() replacement must cancel/dispose any in-flight departures rather
## than let a stale completion signal reach a fresh attempt.
func _check_setup_replacement_disposes_departures() -> void:
	var d := PuzzleDefinition.Direction
	var definition := PuzzleDefinition.new(4, 4, {Vector2i(3, 0): d.RIGHT})
	var board := PuzzleBoard.new()
	get_root().add_child(board)
	board.size = Vector2(400, 400)
	board.setup(definition)
	await process_frame
	board.play_removed(Vector2i(3, 0))
	var view: ArrowView = board._departing_views[Vector2i(3, 0)]
	var stale_completions := [0]
	board.departure_finished.connect(func(): stale_completions[0] += 1)
	board.setup(definition)
	check(board._departing_views.is_empty(), "setup replacement clears the departing collection")
	view.advance_departure(1.0)
	check(stale_completions[0] == 0, "a canceled departure never emits a stale completion into a replaced attempt")
	board.queue_free()

## A second, independent instance of the puzzle scene starts fully fresh —
## the same guarantee Replay/Restart rely on by reloading the scene. Reused
## below to exercise rapid repeated clicks on a TAIL cell while its blocked
## pulse is still playing: catalog entry "multi_bend"'s multi-bend arrow is
## blocked by another arrow's head until that blocker departs, so its tail
## cell (3, 2) stays legitimately blocked for the whole check.
func _check_fresh_instance_starts_clean_and_rapid_tail_clicks() -> void:
	PuzzleSession.set_current_id("multi_bend")
	var packed: PackedScene = load("res://scenes/puzzle/arrow_puzzle.tscn")
	var fresh: Control = packed.instantiate()
	get_root().add_child(fresh)
	await process_frame
	var remaining_label: Label = fresh.get_node("%RemainingLabel")
	var mistakes_label: Label = fresh.get_node("%MistakesLabel")
	var results = fresh.get_node("%PuzzleResults")
	var board = fresh.get_node("%PuzzleBoard")
	check(not results.visible, "a freshly instantiated puzzle scene starts with results hidden")
	check(remaining_label.text.ends_with(str(board.definition.arrows.size())),
		"a freshly instantiated puzzle scene starts with the full remaining count")

	for i in range(20):
		board.cell_clicked.emit(Vector2i(3, 2)) # multi_bend's bent arrow's tail cell; its blocker is still active
	check(mistakes_label.text.ends_with("20"),
		"20 rapid selections on a blocked tail cell, interrupting its own pulse each time, count exactly once each")
	check(not results.visible, "rapid blocked tail-cell clicks never complete or otherwise disturb the attempt")

	fresh.queue_free()
	PuzzleSession.set_current_id(PuzzleCatalog.id_at(0))

## US1 independent test: every one of the fifteen catalog puzzles is playable
## start-to-finish through the real, unmodified scene — proving engine
## generality end-to-end, not only via the pure solver gate. For each: the
## board's active view count matches the definition's arrow count, the HUD
## puzzle label matches the catalog title, and the same witness-replay
## sequence the catalog gate already confirmed solver-side completes
## through the real scene with unchanged scoring/mistakes/accuracy.
func _check_all_catalog_puzzles_play_through_real_scene() -> void:
	for i in range(PuzzleCatalog.count()):
		var id := PuzzleCatalog.id_at(i)
		PuzzleSession.set_current_id(id)
		var packed: PackedScene = load("res://scenes/puzzle/arrow_puzzle.tscn")
		var puzzle: Control = packed.instantiate()
		get_root().add_child(puzzle)
		await process_frame

		var board = puzzle.get_node("%PuzzleBoard")
		var puzzle_label: Label = puzzle.get_node("%PuzzleLabel")
		var results = puzzle.get_node("%PuzzleResults")
		check(board._views.size() == board.definition.arrows.size(),
			"catalog entry '%s': board active view count matches the definition's arrow count" % id)
		check(puzzle_label.text == "%d. %s" % [i + 1, PuzzleCatalog.get_title(id)],
			"catalog entry '%s': HUD puzzle label matches the catalog title" % id)

		var clear_order := _clear_order_for(board.definition)
		for head in clear_order:
			board.cell_clicked.emit(head)
		await _await_departures_complete(puzzle, _worst_case_seconds_for(board.definition))
		check(results.visible, "catalog entry '%s': results appear once every queued departure clears" % id)
		var final_results: Dictionary = puzzle._state.get_results()
		check(final_results["mistakes"] == 0, "catalog entry '%s': the witness clears with zero mistakes" % id)
		check(final_results["score"] == final_results["total_arrows"],
			"catalog entry '%s': a zero-mistake clear scores every arrow" % id)
		check(is_equal_approx(final_results["accuracy"], 1.0),
			"catalog entry '%s': a zero-mistake clear has 100%% accuracy" % id)

		puzzle.queue_free()
		await process_frame
	PuzzleSession.set_current_id(PuzzleCatalog.id_at(0))

## Results independent test: after completing a puzzle with a mix of mistakes and
## Open Move uses, the Results screen displays total arrows, mistakes,
## open-move assists, score and accuracy as five distinct values consistent
## with PuzzleState.get_results(). Reuses "multi_bend"'s known-blocked tail
## cell (3, 2) (see _check_fresh_instance_starts_clean_and_rapid_tail_clicks
## above) to induce mistakes reliably, rather than assuming a specific cell
## is blocked on the default catalog entry.
func _check_results_screen_shows_open_move_assists() -> void:
	PuzzleSession.set_current_id("multi_bend")
	var packed: PackedScene = load("res://scenes/puzzle/arrow_puzzle.tscn")
	var puzzle: Control = packed.instantiate()
	get_root().add_child(puzzle)
	await process_frame

	var board = puzzle.get_node("%PuzzleBoard")
	var open_move_button: Button = puzzle.get_node("%OpenMoveButton")
	var results = puzzle.get_node("%PuzzleResults")

	board.cell_clicked.emit(Vector2i(3, 2)) # blocked tail cell: a reliable mistake
	board.cell_clicked.emit(Vector2i(3, 2)) # a second mistake
	open_move_button.emit_signal("pressed") # one Open Move assist

	var clear_order := _clear_order_for(board.definition)
	for head in clear_order:
		board.cell_clicked.emit(head)
	await _await_departures_complete(puzzle, _WORST_CASE_DEPARTURE_SECONDS)
	check(results.visible, "results appear once every queued departure clears")

	var expected: Dictionary = puzzle._state.get_results()
	check(expected["mistakes"] == 2, "the attempt recorded exactly the two induced mistakes")
	check(expected["open_move_assists"] == 1, "the attempt recorded exactly the one Open Move assist")

	var total_label: Label = results.get_node("%TotalLabel")
	var mistakes_label: Label = results.get_node("%MistakesLabel")
	var assists_label: Label = results.get_node("%OpenMoveAssistsLabel")
	var score_label: Label = results.get_node("%ScoreLabel")
	var accuracy_label: Label = results.get_node("%AccuracyLabel")
	check(total_label.text == "Total Arrows: %d" % expected["total_arrows"],
		"Results screen shows the correct total arrows")
	check(mistakes_label.text == "Mistakes: %d" % expected["mistakes"],
		"Results screen shows the correct mistakes")
	check(assists_label.text == "Open Move Assists: %d" % expected["open_move_assists"],
		"Results screen shows the open-move-assist count as a value distinct from mistakes")
	check(score_label.text == "Score: %d" % expected["score"],
		"Results screen shows the correct score, reflecting both mistakes and assists")
	check(accuracy_label.text == "Accuracy: %s" % PuzzleResultsFormat.format_accuracy_percent(expected["accuracy"]),
		"Results screen shows the correct accuracy, unaffected by the Open Move assist")

	puzzle.queue_free()
	await process_frame
	PuzzleSession.set_current_id(PuzzleCatalog.id_at(0))

## Open Move independent test: triggering Show Me an Open Move while an earlier
## removal's departure animation is still visually in flight responds
## immediately against the current logical state, with no suppression or
## queuing tied to the in-flight animation.
func _check_open_move_during_in_flight_departure() -> void:
	var packed: PackedScene = load("res://scenes/puzzle/arrow_puzzle.tscn")
	var puzzle: Control = packed.instantiate()
	get_root().add_child(puzzle)
	await process_frame

	var board = puzzle.get_node("%PuzzleBoard")
	var open_move_button: Button = puzzle.get_node("%OpenMoveButton")
	var clear_order := _clear_order_for(board.definition)

	board.cell_clicked.emit(clear_order[0])
	check(board._departing_views.size() > 0,
		"an in-flight departure exists immediately after the first clear-order removal")

	var expected_head = puzzle._state.find_open_move()
	check(expected_head != null,
		"the puzzle's current logical state (post-removal) still has a legal arrow to identify")
	open_move_button.emit_signal("pressed")
	check(board._suggested_head == expected_head,
		"Show Me an Open Move responds immediately against the current logical state while a departure is still in flight, matching find_open_move()'s result -- no suppression or queuing")

	await _await_departures_complete(puzzle, _WORST_CASE_DEPARTURE_SECONDS)
	puzzle.queue_free()
	await process_frame

## Open Move independent test: the Open Move control is reachable via
## keyboard/gamepad focus navigation, not only by mouse -- constitution
## Principle III. Godot's Button/BaseButton already guarantees that any
## visible, enabled, FOCUS_ALL-focused button activates from the built-in
## ui_accept action (keyboard Enter/Space, gamepad face button) -- engine
## behavior this project consumes but does not implement or risk breaking.
## What this project's own wiring can break, and what this check verifies
## deterministically, is: (1) the control is actually in the focus-eligible
## state a keyboard/gamepad user depends on, and (2) its "pressed" signal is
## actually connected to the real Open Move handler, so activating it by any
## input method reaches PuzzleState.request_open_move() and shows a
## suggestion. Simulating literal InputEventKey/InputEventJoypadButton
## delivery through the headless GUI input pipeline was tried and found
## nondeterministic run-to-run in this environment (no rendered display
## backs the event/frame timing here) -- the same class of headless
## limitation already documented for OS pointer eligibility elsewhere in
## .knowledge/architecture/arrow-puzzle.md. Literal hardware key/gamepad
## activation is exercised by quickstart.md's manual desktop smoke test.
func _check_open_move_keyboard_and_gamepad_reachable() -> void:
	var packed: PackedScene = load("res://scenes/puzzle/arrow_puzzle.tscn")
	var puzzle: Control = packed.instantiate()
	get_root().add_child(puzzle)
	await process_frame

	var board = puzzle.get_node("%PuzzleBoard")
	var open_move_button: Button = puzzle.get_node("%OpenMoveButton")
	check(open_move_button.visible and not open_move_button.disabled
			and open_move_button.focus_mode == Control.FOCUS_ALL,
		"the Open Move control is visible, enabled and keyboard/gamepad focusable")

	open_move_button.grab_focus()
	await process_frame
	check(get_root().gui_get_focus_owner() == open_move_button,
		"the Open Move control can actually receive keyboard/gamepad focus")
	check(open_move_button.get_signal_connection_list("pressed").size() > 0,
		"the Open Move control's pressed signal is connected to a handler (Godot activates it from ui_accept on any input device once focused)")

	var assists_before: int = puzzle._state.open_move_assists
	open_move_button.emit_signal("pressed")
	check(board._suggested_head != null,
		"activating the focused Open Move control (as ui_accept would, from keyboard or gamepad) identifies a legal arrow")
	check(puzzle._state.open_move_assists == assists_before + 1,
		"activating it counts as exactly one valid Open Move request")

	puzzle.queue_free()
	await process_frame

## Level Select lists every catalog puzzle in
## deterministic order with distinguishing identity, none locked/hidden, and
## opens with keyboard/gamepad focus already placed on the first entry
## (the inherited _open_sub_menu mechanism does not grab focus
## by itself). Selecting a non-first entry is exercised at the
## PuzzleSession/PuzzleCatalog level (matching what the real handler does)
## rather than through the live SceneLoader, so this real-project check
## never triggers an actual scene change; tests/save_input_regression.gd
## covers the full menu-handler wiring against a stubbed SceneLoader.
func _check_level_select_menu() -> void:
	var packed: PackedScene = load("res://scenes/menus/main_menu/main_menu_with_animations.tscn")
	var menu = packed.instantiate()
	get_root().add_child(menu)
	await process_frame
	await process_frame # let %LevelSelectContainer's call_deferred add_child land

	var level_select = menu.level_select_scene
	check(level_select != null, "Level Select sub-menu is instantiated by _setup_level_select()")
	check(level_select.get_signal_connection_list("puzzle_selected").size() > 0,
		"Level Select's puzzle_selected signal is connected to the main menu's handler")

	var list_container: VBoxContainer = level_select.get_node("%PuzzleListContainer")
	check(list_container.get_child_count() == PuzzleCatalog.count(),
		"Level Select lists exactly one entry per catalog puzzle")
	for i in range(list_container.get_child_count()):
		var entry_button: Button = list_container.get_child(i)
		check(entry_button.visible and not entry_button.disabled,
			"Level Select entry %d is neither locked nor hidden" % i)
		check(entry_button.text == "%d. %s" % [i + 1, PuzzleCatalog.title_at(i)],
			"Level Select entry %d shows its 1-based number and title in catalog order" % i)

	menu._on_level_select_button_pressed()
	await process_frame
	await process_frame # NOTIFICATION_VISIBILITY_CHANGED's call_deferred focus grab

	var focus_owner := get_root().gui_get_focus_owner()
	check(focus_owner != null and focus_owner.is_visible_in_tree() and focus_owner.focus_mode == Control.FOCUS_ALL,
		"opening Level Select places a visible, actionable keyboard/gamepad focus owner")
	check(focus_owner == list_container.get_child(0),
		"opening Level Select places initial focus on PuzzleCatalog.id_at(0)'s entry, not a hidden main-menu button")

	PuzzleSession.set_current_id(PuzzleCatalog.id_at(3))
	var selected_puzzle: Control = load("res://scenes/puzzle/arrow_puzzle.tscn").instantiate()
	get_root().add_child(selected_puzzle)
	await process_frame
	check(selected_puzzle.get_node("%PuzzleLabel").text == "%d. %s" % [4, PuzzleCatalog.title_at(3)],
		"selecting a non-first catalog id loads that exact puzzle, reflected in the gameplay HUD")
	selected_puzzle.queue_free()
	await process_frame
	PuzzleSession.set_current_id(PuzzleCatalog.id_at(0))

	menu.queue_free()
	await process_frame

## US3 independent test: Replay and pause-menu Restart both reload the
## currently selected non-first puzzle (never silently falling back to
## puzzle 1); Next Puzzle advances to the following catalog entry with a
## fresh attempt; the last catalog puzzle's results omit Next Puzzle; and
## switching puzzles disposes any prior attempt's departing views. Replay
## (arrow_puzzle.gd::_on_results_replay_requested) and the addon PauseMenu's
## _on_confirm_restart_confirmed both call SceneLoader.reload_current_scene()
## with no other code (see addons/.../pause_menu.gd), so exercising that one
## call here proves PuzzleSession survives the reload for both entry points.
func _check_replay_restart_and_next_puzzle() -> void:
	var non_first_index := 2
	PuzzleSession.set_current_id(PuzzleCatalog.id_at(non_first_index))
	change_scene_to_packed(load("res://scenes/puzzle/arrow_puzzle.tscn"))
	await process_frame
	await process_frame
	var puzzle = current_scene
	check(puzzle.get_node("%PuzzleLabel").text == "%d. %s" % [non_first_index + 1, PuzzleCatalog.title_at(non_first_index)],
		"a non-first catalog puzzle loads correctly before any reload")

	var board = puzzle.get_node("%PuzzleBoard")
	var clear_order := _clear_order_for(board.definition)
	board.cell_clicked.emit(clear_order[0])
	check(board._departing_views.size() > 0,
		"an in-flight departure exists on the attempt about to be reloaded")

	get_root().get_node("SceneLoader").reload_current_scene()
	await process_frame
	await process_frame
	var reloaded = current_scene
	check(reloaded != puzzle, "reload_current_scene() constructs a fresh scene instance")
	check(reloaded.get_node("%PuzzleLabel").text == "%d. %s" % [non_first_index + 1, PuzzleCatalog.title_at(non_first_index)],
		"Replay/pause-menu Restart reload the currently selected puzzle, not puzzle 1 (PuzzleSession survives the reload)")
	check(reloaded._state.mistakes == 0 and reloaded._state.successful_removals == 0,
		"the reloaded attempt starts with a completely fresh PuzzleState")
	check(reloaded.get_node("%PuzzleBoard")._departing_views.is_empty(),
		"the reloaded attempt carries over no departing views from the previous attempt")

	reloaded._on_results_next_puzzle_requested()
	await process_frame
	await process_frame
	var advanced = current_scene
	check(advanced.get_node("%PuzzleLabel").text == "%d. %s" % [non_first_index + 2, PuzzleCatalog.title_at(non_first_index + 1)],
		"Next Puzzle advances to the following catalog entry")
	check(advanced._state.mistakes == 0 and advanced._state.successful_removals == 0,
		"Next Puzzle starts a fresh attempt with no carried-over mistakes or removals")

	PuzzleSession.set_current_id(PuzzleCatalog.id_at(PuzzleCatalog.count() - 1))
	change_scene_to_packed(load("res://scenes/puzzle/arrow_puzzle.tscn"))
	await process_frame
	await process_frame
	var last_puzzle = current_scene
	var last_board = last_puzzle.get_node("%PuzzleBoard")
	var last_order := _clear_order_for(last_board.definition)
	for head in last_order:
		last_board.cell_clicked.emit(head)
	await _await_departures_complete(last_puzzle, _worst_case_seconds_for(last_board.definition))
	var last_results = last_puzzle.get_node("%PuzzleResults")
	check(last_results.visible, "the last catalog puzzle's results appear once every departure clears")
	check(not last_results.get_node("%NextPuzzleButton").visible,
		"Next Puzzle is not shown on the last catalog puzzle's results")

	PuzzleSession.set_current_id(PuzzleCatalog.id_at(0))

## Replay independent test: a replay begins a completely fresh attempt
## -- mistakes, open_move_assists and score all reset to zero -- regardless
## of how non-trivial the prior attempt's values were. Reuses "multi_bend"'s
## known-blocked tail cell to induce a real mistake before completing, plus
## one Open Move assist, so the prior attempt is genuinely non-fresh before
## reloading.
func _check_replay_resets_open_move_fields() -> void:
	PuzzleSession.set_current_id("multi_bend")
	change_scene_to_packed(load("res://scenes/puzzle/arrow_puzzle.tscn"))
	await process_frame
	await process_frame
	var puzzle = current_scene
	var board = puzzle.get_node("%PuzzleBoard")
	var open_move_button: Button = puzzle.get_node("%OpenMoveButton")

	board.cell_clicked.emit(Vector2i(3, 2)) # a real mistake
	open_move_button.emit_signal("pressed") # a real Open Move assist
	var clear_order := _clear_order_for(board.definition)
	for head in clear_order:
		board.cell_clicked.emit(head)
	await _await_departures_complete(puzzle, _WORST_CASE_DEPARTURE_SECONDS)
	check(puzzle._state.mistakes > 0 and puzzle._state.open_move_assists > 0,
		"the attempt about to be replayed genuinely has nonzero mistakes and assists")

	puzzle._on_results_replay_requested()
	await process_frame
	await process_frame
	var reloaded = current_scene
	check(reloaded != puzzle, "Replay constructs a fresh scene instance")
	check(reloaded._state.mistakes == 0, "the replayed attempt's mistake count resets to zero")
	check(reloaded._state.open_move_assists == 0, "the replayed attempt's open_move_assists resets to zero")
	check(reloaded._state.get_results()["score"] == reloaded._state.total_arrows,
		"the replayed attempt's score reflects a completely fresh start, not the prior attempt's penalties")

	PuzzleSession.set_current_id(PuzzleCatalog.id_at(0))

func _initialize() -> void:
	check(PuzzleFeedback.BLOCKED_CUE_DURATION_SECONDS <= PuzzleFeedback.BLOCKED_CUE_DURATION_CAP_SECONDS,
		"the coded blocked-feedback cue duration constant does not exceed its coded cap")

	await _check_multi_cell_board_bounds()
	await _check_session_best_and_overall_score_progression()

	var packed: PackedScene = load("res://scenes/puzzle/arrow_puzzle.tscn")
	var puzzle: Control = packed.instantiate()
	get_root().add_child(puzzle)
	await process_frame

	await _check_layout_at_size(puzzle, Vector2i(1280, 720))
	await _check_layout_at_size(puzzle, Vector2i(960, 540))
	await _check_multiple_departures_and_completion(puzzle)
	await _check_completed_input_ignored(puzzle)
	await _check_departure_resize_and_pause_lifecycle()
	await _check_setup_replacement_disposes_departures()
	await _check_fresh_instance_starts_clean_and_rapid_tail_clicks()
	await _check_all_catalog_puzzles_play_through_real_scene()
	await _check_open_move_during_in_flight_departure()
	await _check_open_move_keyboard_and_gamepad_reachable()
	await _check_results_screen_shows_open_move_assists()
	await _check_level_select_menu()
	await _check_replay_restart_and_next_puzzle()
	await _check_replay_resets_open_move_fields()

	puzzle.queue_free()
	print("PUZZLE_LAYOUT_FAILURES=", failures)
	quit(1 if failures else 0)
