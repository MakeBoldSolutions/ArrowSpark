extends SceneTree
## Headless scene-based check for the arrow puzzle's HUD/board layout,
## multi-cell shape bounds, departure/completion lifecycle and
## feedback-cue duration. Runs against the real project so the full
## scene/addon dependency graph is available; run_puzzle_regressions.py
## redirects APPDATA/XDG_DATA_HOME so no player save/settings data is touched.

## Head order that fully clears the fixed board with no blocked step.
const CLEAR_ORDER: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(2, 0), Vector2i(4, 3), Vector2i(4, 0),
	Vector2i(0, 3), Vector2i(2, 3), Vector2i(2, 1), Vector2i(3, 2),
]

var failures: int = 0

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

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
	# Shape bounding box spans x in [1,2], y in [0,2]: 2 cells wide, 3 cells tall.
	check(is_equal_approx(view.size.x, board._cell_size.x * 2.0) and is_equal_approx(view.size.y, board._cell_size.y * 3.0),
		"a bent tail's view bounding box covers its full 2x3 cell extent at 1280x720")

	var tail_tip_local: Vector2 = view.position + Vector2(0.5, 0.5) * board._cell_size.x
	check(board._cell_from_local(tail_tip_local) == Vector2i(1, 0),
		"a click inside the tail-tip cell resolves to that tail cell's board coordinate")

	board.size = Vector2(960, 540)
	await process_frame
	check(is_equal_approx(view.size.x, board._cell_size.x * 2.0) and is_equal_approx(view.size.y, board._cell_size.y * 3.0),
		"the same bounding box relationship holds after a resize to 960x540")

	board.queue_free()

## Computed bounded deadline (not a fixed guess): the largest possible
## finish distance on the fixed 5x4 board is its longest cell-unit route (the
## longest tail plus one) plus its largest edge clearance plus rear-support
## and margin; dividing by the configured speed and adding slack gives a
## ceiling that never assumes a specific fixed animation duration.
const _WORST_CASE_FINISH_DISTANCE_CELLS: float = 5.0 + 4.0 + PuzzleFeedback.EXIT_CLEARANCE_MARGIN_CELLS + 0.1
const _WORST_CASE_DEPARTURE_SECONDS: float = _WORST_CASE_FINISH_DISTANCE_CELLS / PuzzleFeedback.EXIT_SPEED_CELLS_PER_SECOND + 1.0

func _await_departures_complete(puzzle, max_seconds: float) -> void:
	var elapsed := 0.0
	while puzzle._pending_departures > 0 and elapsed < max_seconds:
		await create_timer(0.02).timeout
		elapsed += 0.02

## Clicking every head in CLEAR_ORDER completes the puzzle; results must
## await every queued departure, not just the last click.
func _check_multiple_departures_and_completion(puzzle) -> void:
	var board = puzzle.get_node("%PuzzleBoard")
	var results = puzzle.get_node("%PuzzleResults")
	var first_view: ArrowView = board._views[CLEAR_ORDER[0]]
	for head in CLEAR_ORDER:
		board.cell_clicked.emit(head)
		if head == CLEAR_ORDER[0]:
			await create_timer(0.04).timeout
	var taps: int = puzzle._state.total_taps
	board.cell_clicked.emit(CLEAR_ORDER[-1])
	check(puzzle._state.total_taps == taps, "completed input does not add taps while departures drain")
	var distance_before_resize: float = first_view._departure_distance
	var extent_before_resize: float = board._cell_size.x
	var body_before_resize: PackedVector2Array = first_view._body.points.duplicate()
	get_root().size = Vector2i(1280, 720)
	await process_frame
	check(is_equal_approx(first_view._departure_distance, distance_before_resize),
		"resize preserves departure cell-distance progress without restarting")
	if extent_before_resize > 0.0 and board._cell_size.x > 0.0 and body_before_resize.size() > 0 \
			and first_view._body.points.size() == body_before_resize.size():
		var ratio: float = board._cell_size.x / extent_before_resize
		check(first_view._body.points[0].is_equal_approx(body_before_resize[0] * ratio),
			"resize rescales departing geometry to the new pixel extent at the same cell-distance progress")
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
		var extent: float = board._cell_size.x
		check(is_equal_approx(board._departure_clip.size.x, extent * definition.width) \
				and is_equal_approx(board._departure_clip.size.y, extent * definition.height),
			"the departure clip rect recalculates to the occupied grid at %s" % [size])
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
## pulse is still playing, since B's tail (3,0) is blocked by A on the
## shipped board until A departs.
func _check_fresh_instance_starts_clean_and_rapid_tail_clicks() -> void:
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
		board.cell_clicked.emit(Vector2i(3, 0)) # B's tail cell; A still blocks B
	check(mistakes_label.text.ends_with("20"),
		"20 rapid selections on a blocked tail cell, interrupting its own pulse each time, count exactly once each")
	check(not results.visible, "rapid blocked tail-cell clicks never complete or otherwise disturb the attempt")

	fresh.queue_free()

func _initialize() -> void:
	check(PuzzleFeedback.BLOCKED_CUE_DURATION_SECONDS <= PuzzleFeedback.BLOCKED_CUE_DURATION_CAP_SECONDS,
		"the coded blocked-feedback cue duration constant does not exceed its coded 0.3-second cap")

	await _check_multi_cell_board_bounds()

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

	puzzle.queue_free()
	print("PUZZLE_LAYOUT_FAILURES=", failures)
	quit(1 if failures else 0)
