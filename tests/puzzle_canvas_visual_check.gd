extends SceneTree
## Manual desktop fixture: measures navigation cost on the large canvas
## fixture and saves rendered captures. Launch it non-headless so a real
## renderer is used:
##
##   godot --path . --script res://tests/puzzle_canvas_visual_check.gd -- <output-dir>
##
## It waits 2 seconds (warmup), then drives 10 seconds of continuous zoom and
## pan through the board's real input handler at 1280x720 while eight
## departures overlap, recording navigation-handler time (p95 <= 2 ms budget),
## frame time (p95 <= 33.3 ms budget) and the longest frame (a stall of 100 ms
## or more fails the fixture's budget). A second, informational pass repeats the
## measurement on a synthetic dense board of several hundred short arrows that
## is never added to the catalog. Rendered captures at overview, working scale
## and maximum zoom are written for a human readability review. Results print
## as VISUAL_* lines and, when an output directory is given, are written to
## performance.md there. It writes no player save or settings data.

const WARMUP_SECONDS := 2.0
const CAPTURE_SECONDS := 10.0
const WINDOW := Vector2i(1280, 720)
const HANDLER_BUDGET_MS := 2.0
const FRAME_BUDGET_MS := 33.3
const STALL_MS := 100.0

var _output_dir := ""
var _report: PackedStringArray = []

func _percentile(values: Array, fraction: float) -> float:
	if values.is_empty():
		return 0.0
	var sorted := values.duplicate()
	sorted.sort()
	return float(sorted[mini(sorted.size() - 1, int(ceil(fraction * sorted.size())) - 1)])

func _log(line: String) -> void:
	print(line)
	_report.append(line)

func _wheel(board: PuzzleBoard, up: bool, position: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_WHEEL_UP if up else MOUSE_BUTTON_WHEEL_DOWN
	event.pressed = true
	event.position = position
	board._gui_input(event)

func _drag_step(board: PuzzleBoard, start: Vector2, relative: Vector2) -> void:
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_MIDDLE
	press.pressed = true
	press.position = start
	press.button_mask = MOUSE_BUTTON_MASK_MIDDLE
	board._gui_input(press)
	var motion := InputEventMouseMotion.new()
	motion.position = start + relative
	motion.relative = relative
	motion.button_mask = MOUSE_BUTTON_MASK_MIDDLE
	board._gui_input(motion)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_MIDDLE
	release.pressed = false
	release.position = start + relative
	board._gui_input(release)

## Runs `seconds` of alternating zoom and pan, one navigation step per frame,
## returning handler and frame times in milliseconds.
func _measure(board: PuzzleBoard, seconds: float) -> Dictionary:
	var handler_ms: Array = []
	var frame_ms: Array = []
	var elapsed := 0.0
	var step := 0
	var last := Time.get_ticks_usec()
	var center := board.size / 2.0
	while elapsed < seconds:
		await process_frame
		var now := Time.get_ticks_usec()
		var frame := float(now - last) / 1000.0
		last = now
		elapsed += frame / 1000.0
		frame_ms.append(frame)
		var before := Time.get_ticks_usec()
		match step % 6:
			0, 1: _wheel(board, true, center + Vector2(200, 100))
			2: _drag_step(board, center, Vector2(-160, -90))
			3, 4: _wheel(board, false, center - Vector2(150, 80))
			5: _drag_step(board, center, Vector2(220, 120))
		handler_ms.append(float(Time.get_ticks_usec() - before) / 1000.0)
		step += 1
	return {"handler": handler_ms, "frame": frame_ms}

func _summarize(label: String, result: Dictionary, gated: bool) -> void:
	var handler_p95 := _percentile(result["handler"], 0.95)
	var frame_p95 := _percentile(result["frame"], 0.95)
	var longest: float = (result["frame"] as Array).max() if not (result["frame"] as Array).is_empty() else 0.0
	_log("VISUAL_%s samples=%d handler_p95_ms=%.3f frame_p95_ms=%.2f longest_frame_ms=%.1f" % [
		label, (result["frame"] as Array).size(), handler_p95, frame_p95, longest])
	if gated:
		var ok := handler_p95 <= HANDLER_BUDGET_MS and frame_p95 <= FRAME_BUDGET_MS and longest < STALL_MS
		_log("VISUAL_%s_WITHIN_BUDGET=%s (handler <= %.1f ms, frame p95 <= %.1f ms, no frame >= %.0f ms)" % [
			label, str(ok), HANDLER_BUDGET_MS, FRAME_BUDGET_MS, STALL_MS])

func _capture(name: String) -> void:
	await process_frame
	await process_frame
	if _output_dir.is_empty():
		return
	var image := get_root().get_texture().get_image()
	var path := "%s/%s.png" % [_output_dir, name]
	image.save_png(path)
	_log("VISUAL_CAPTURE %s (%dx%d)" % [path, image.get_width(), image.get_height()])

func _dense_definition() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var arrows := {}
	var directions := [d.UP, d.RIGHT, d.DOWN, d.LEFT]
	for x in range(0, 60, 2):
		for y in range(0, 40, 2):
			arrows[Vector2i(x, y)] = directions[(x / 2 + y / 2) % 4]
	return PuzzleDefinition.new(60, 40, arrows)

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		_output_dir = args[0]
		DirAccess.make_dir_recursive_absolute(_output_dir)
	DisplayServer.window_set_size(WINDOW)
	get_root().size = WINDOW
	await process_frame
	await process_frame
	_log("VISUAL_ENV engine=%s renderer=%s cpu=%s gpu=%s window=%s" % [
		Engine.get_version_info()["string"], RenderingServer.get_current_rendering_driver_name(),
		OS.get_processor_name(), RenderingServer.get_video_adapter_name(), get_root().size])

	PuzzleSession.set_current_id("canvas_validation")
	var puzzle: Control = load("res://scenes/puzzle/arrow_puzzle.tscn").instantiate()
	get_root().add_child(puzzle)
	await process_frame
	await process_frame
	var board: PuzzleBoard = puzzle.get_node("%PuzzleBoard")
	_log("VISUAL_BOARD size=%s fit_cell_pixels=%.2f" % [board.size, board.view_transform.cell_pixels])
	await _capture("overview")
	for i in range(40):
		if board.view_transform.cell_pixels >= 64.0:
			break
		board.zoom_in()
	await _capture("working_scale")
	for i in range(60):
		board.zoom_in()
	await _capture("maximum_zoom")
	board.fit_puzzle()

	# Start eight overlapping departures, warm up, then measure.
	for head in PuzzleSolver.analyze(board.definition).witness.slice(0, 8):
		board.cell_clicked.emit(head)
	await _measure(board, WARMUP_SECONDS)
	var result := await _measure(board, CAPTURE_SECONDS)
	_summarize("FIXTURE", result, true)
	_log("VISUAL_FIXTURE_DEPARTURES_REMAINING=%d" % board._departing_views.size())

	# Informational: a synthetic dense board, never part of the catalog.
	puzzle.queue_free()
	await process_frame
	var dense := PuzzleBoard.new()
	dense.size = Vector2(WINDOW)
	get_root().add_child(dense)
	dense.setup(_dense_definition())
	await process_frame
	await process_frame
	_log("VISUAL_DENSE arrows=%d" % dense._views.size())
	await _measure(dense, WARMUP_SECONDS)
	var dense_result := await _measure(dense, CAPTURE_SECONDS)
	_summarize("DENSE_INFORMATIONAL", dense_result, false)
	for i in range(40):
		if dense.view_transform.cell_pixels >= 64.0:
			break
		dense.zoom_in()
	await _capture("dense_working_scale")

	if not _output_dir.is_empty():
		var file := FileAccess.open(_output_dir + "/performance_raw.txt", FileAccess.WRITE)
		file.store_string("\n".join(_report) + "\n")
		file.close()
	quit()
