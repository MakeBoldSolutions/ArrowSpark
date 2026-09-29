extends SceneTree
## Headless scene-based check for the zoomable puzzle canvas: fit, zoom, pan,
## input eligibility and arbitration, transformed selection, Open Move reveal,
## departures under navigation and resize, and per-attempt view reset. Runs
## against the real project; run_puzzle_regressions.py redirects the
## platform application-data root so no player data is touched.

const LARGE_ID := "canvas_validation"
const _WORST_CASE_SLACK_SECONDS := 2.0

var failures: int = 0

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

# --- Helpers ------------------------------------------------------------------

func _spawn(id: String, window: Vector2i = Vector2i(1280, 720)) -> Control:
	PuzzleSession.set_current_id(id)
	# The very first size request of a headless run can be overridden by the
	# window's own initialization, so apply it until it sticks.
	for attempt in range(3):
		get_root().size = window
		await process_frame
		if get_root().size == window:
			break
	var puzzle: Control = load("res://scenes/puzzle/arrow_puzzle.tscn").instantiate()
	get_root().add_child(puzzle)
	await process_frame
	await process_frame
	return puzzle

func _dispose(puzzle: Control) -> void:
	puzzle.queue_free()
	await process_frame

func _board(puzzle: Control) -> PuzzleBoard:
	return puzzle.get_node("%PuzzleBoard")

func _local_of(board: PuzzleBoard, logical: Vector2) -> Vector2:
	return board.view_transform.logical_to_local(logical)

func _mouse_button(board: PuzzleBoard, index: int, pressed: bool, position: Vector2, factor: float = 1.0) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = index
	event.pressed = pressed
	event.position = position
	event.factor = factor
	var mask := 0
	if pressed:
		match index:
			MOUSE_BUTTON_LEFT: mask = MOUSE_BUTTON_MASK_LEFT
			MOUSE_BUTTON_MIDDLE: mask = MOUSE_BUTTON_MASK_MIDDLE
	event.button_mask = mask
	board._gui_input(event)
	return event

func _mouse_motion(board: PuzzleBoard, position: Vector2, relative: Vector2, mask: int) -> void:
	var event := InputEventMouseMotion.new()
	event.position = position
	event.relative = relative
	event.button_mask = mask
	board._gui_input(event)

func _drag(board: PuzzleBoard, button: int, delta: Vector2, start: Vector2 = Vector2(300, 300)) -> void:
	var mask := MOUSE_BUTTON_MASK_MIDDLE if button == MOUSE_BUTTON_MIDDLE else MOUSE_BUTTON_MASK_LEFT
	_mouse_button(board, button, true, start)
	_mouse_motion(board, start + delta, delta, mask)
	_mouse_button(board, button, false, start + delta)

func _action_event(action: StringName, pressed: bool = true) -> InputEventAction:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = pressed
	return event

## A logical scale close to the working scale (64 pixels per cell), reached
## through the real wheel path.
func _zoom_to_working_scale(board: PuzzleBoard) -> void:
	var center := board.size / 2.0
	var guard := 0
	while board.view_transform.cell_pixels < 64.0 - 0.01 and guard < 100:
		var before := board.view_transform.cell_pixels
		_mouse_button(board, MOUSE_BUTTON_WHEEL_UP, true, center)
		if board.view_transform.cell_pixels == before:
			break
		guard += 1

func _pan_to_logical_corner(board: PuzzleBoard, corner: Vector2) -> void:
	# Drag content until the requested logical corner reaches the viewport
	# corner region (each drag is bounded by the transform's clamps).
	var far := Vector2(1.0e5, 1.0e5)
	var direction := Vector2(-1.0 if corner.x > 0.0 else 1.0, -1.0 if corner.y > 0.0 else 1.0)
	_drag(board, MOUSE_BUTTON_MIDDLE, far * direction)

func _snapshot(puzzle: Control) -> Dictionary:
	return puzzle._state.get_snapshot()

func _view_identities(board: PuzzleBoard) -> Dictionary:
	var identities := {}
	for head in board._views.keys():
		identities[head] = board._views[head].get_instance_id()
	return identities

func _canonical_views_unchanged(board: PuzzleBoard) -> bool:
	for head in board._views.keys():
		var view: ArrowView = board._views[head]
		var cells: Array[Vector2i] = board.definition.get_arrow_cells(head)
		var lo := PuzzleBoard._bounding_min(cells)
		var hi := PuzzleBoard._bounding_max(cells)
		var expected_size := Vector2(hi - lo + Vector2i.ONE) * PuzzleViewportTransform.CANONICAL_CELL_PIXELS
		if not view.position.is_equal_approx(Vector2(lo) * PuzzleViewportTransform.CANONICAL_CELL_PIXELS) \
				or not view.size.is_equal_approx(expected_size) or view._cell_extent != PuzzleViewportTransform.CANONICAL_CELL_PIXELS:
			return false
	return true

func _clear_order(definition: PuzzleDefinition) -> Array[Vector2i]:
	var order: Array[Vector2i] = []
	for head in PuzzleSolver.analyze(definition).witness:
		order.append(head)
	return order

func _worst_case_seconds(definition: PuzzleDefinition) -> float:
	var longest := 1
	for head in definition.arrows.keys():
		longest = maxi(longest, definition.get_arrow_cells(head).size())
	return float(longest + definition.width + definition.height + 1) / PuzzleFeedback.EXIT_SPEED_CELLS_PER_SECOND \
		+ _WORST_CASE_SLACK_SECONDS

func _await_departures(puzzle: Control, max_seconds: float) -> void:
	var elapsed := 0.0
	while puzzle._pending_departures > 0 and elapsed < max_seconds:
		await create_timer(0.02).timeout
		elapsed += 0.02

func _rect_of(board: PuzzleBoard, cell: Vector2i) -> Rect2:
	var top_left := _local_of(board, Vector2(cell))
	return Rect2(top_left, Vector2.ONE * board.view_transform.cell_pixels)

# --- Fit, zoom and pan of the large board --------------------------------------

func _check_initial_fit_and_large_board() -> void:
	var puzzle := await _spawn(LARGE_ID)
	var board := _board(puzzle)
	var transform := board.view_transform
	check(transform.layout_valid and transform.fit_mode, "a new attempt starts fitted with a valid layout")
	check(is_equal_approx(transform.cell_pixels, transform.fit_cell_pixels()), "the initial scale is the fit scale")
	check(transform.cell_pixels < PuzzleViewportTransform.COMFORTABLE_CELL_PIXELS,
		"the 40x30 fixture is below the comfortable selection scale at overview")
	var world_scale: float = board._world.scale.x
	check(is_equal_approx(world_scale, transform.cell_pixels / PuzzleViewportTransform.CANONICAL_CELL_PIXELS),
		"World scale is the displayed cell size over the canonical extent")
	var board_rect := Rect2(Vector2.ZERO, board.size)
	var world_rect := Rect2(board._world.position, board._world.size * board._world.scale)
	check(board_rect.encloses(world_rect), "the fitted world lies entirely inside the board area")
	check(is_equal_approx(world_rect.get_center().x, board_rect.get_center().x) \
			and is_equal_approx(world_rect.get_center().y, board_rect.get_center().y),
		"the fitted world is centered in the board area")
	check(board.clip_contents, "the board clips its contents to the viewport")
	check(board._world.get_parent() == board and board._departure_clip.get_parent() == board._world,
		"World is a child of the board and owns the departure clip")
	check(board._world.mouse_filter == Control.MOUSE_FILTER_IGNORE \
			and board._departure_clip.mouse_filter == Control.MOUSE_FILTER_IGNORE,
		"World and the departure clip ignore mouse input")
	var all_ignore := true
	for view in board._views.values():
		if view.mouse_filter != Control.MOUSE_FILTER_IGNORE or view.get_parent() != board._world:
			all_ignore = false
	check(all_ignore, "every active view is a passive child of World")
	check(_canonical_views_unchanged(board), "every view is built once at the canonical 64-pixel extent")
	await _dispose(puzzle)

func _check_zoom_pan_corners_and_invariants() -> void:
	var puzzle := await _spawn(LARGE_ID)
	var board := _board(puzzle)
	var transform := board.view_transform
	var state_before := _snapshot(puzzle)
	var identities_before := _view_identities(board)

	for i in range(3):
		board.zoom_in()
	check(not transform.fit_mode, "button zoom leaves fit mode")
	var anchor := board.size / 2.0 + Vector2(120, 70)
	var logical_before := transform.local_to_logical(anchor)
	_mouse_button(board, MOUSE_BUTTON_WHEEL_UP, true, anchor)
	check(transform.local_to_logical(anchor).distance_to(logical_before) < 0.01,
		"wheel zoom keeps the point under the pointer fixed")
	_zoom_to_working_scale(board)
	check(absf(transform.cell_pixels - 64.0) < 64.0 * (PuzzleViewportTransform.ZOOM_STEP - 1.0),
		"wheel zoom reaches the 64-pixel working scale")

	var reached := {}
	for corner_cell in [Vector2i(0, 0), Vector2i(39, 0), Vector2i(0, 29), Vector2i(39, 29)]:
		_pan_to_logical_corner(board, Vector2(corner_cell))
		var rect := _rect_of(board, corner_cell)
		reached[corner_cell] = Rect2(Vector2.ZERO, board.size).encloses(rect)
		check(reached[corner_cell], "corner cell %s can be brought fully into view at the working scale" % [corner_cell])
		var hit := board.view_transform.cell_at(rect.get_center())
		check(hit == corner_cell, "corner cell %s resolves under its own center after panning" % [corner_cell])

	check(state_before == _snapshot(puzzle), "navigation leaves the rule state untouched")
	check(identities_before == _view_identities(board), "navigation keeps every arrow view instance")
	check(_canonical_views_unchanged(board), "navigation never rebuilds or resizes canonical view geometry")

	board.fit_puzzle()
	check(transform.fit_mode and is_equal_approx(transform.cell_pixels, transform.fit_cell_pixels()),
		"Fit Puzzle restores the overview in one action")
	check(state_before == _snapshot(puzzle), "Fit Puzzle leaves the rule state untouched")
	await _dispose(puzzle)

func _check_limit_saturation() -> void:
	var puzzle := await _spawn(LARGE_ID)
	var board := _board(puzzle)
	var transform := board.view_transform
	var fit_scale := transform.cell_pixels
	for i in range(80):
		board.zoom_in()
	check(is_equal_approx(transform.cell_pixels, PuzzleViewportTransform.MAX_CELL_PIXELS),
		"repeated zoom in saturates at the maximum scale")
	var saturated_center := transform.center_cells
	board.zoom_in()
	check(transform.center_cells.is_equal_approx(saturated_center) and is_equal_approx(transform.cell_pixels, 192.0),
		"zooming in at the maximum changes nothing")
	for i in range(80):
		board.zoom_out()
	check(is_equal_approx(transform.cell_pixels, fit_scale), "repeated zoom out saturates at the fit scale")
	await _dispose(puzzle)

func _check_wheel_step_scaling_and_clamp() -> void:
	var puzzle := await _spawn(LARGE_ID)
	var board := _board(puzzle)
	var transform := board.view_transform
	var center := board.size / 2.0
	var start := transform.cell_pixels
	_mouse_button(board, MOUSE_BUTTON_WHEEL_UP, true, center, 1.0)
	check(is_equal_approx(transform.cell_pixels, start * PuzzleViewportTransform.ZOOM_STEP),
		"a full wheel notch zooms by exactly one 1.2x step")
	var after_notch := transform.cell_pixels
	_mouse_button(board, MOUSE_BUTTON_WHEEL_UP, true, center, 0.25)
	var partial := transform.cell_pixels / after_notch
	check(partial > 1.0 and partial < PuzzleViewportTransform.ZOOM_STEP,
		"a fractional (trackpad) event zooms by less than a full step")
	var before_burst := transform.cell_pixels
	_mouse_button(board, MOUSE_BUTTON_WHEEL_UP, true, center, 50.0)
	check(transform.cell_pixels / before_burst <= PuzzleViewportTransform.ZOOM_STEP + 0.0001,
		"a huge event factor is clamped to one step and cannot overshoot")
	_mouse_button(board, MOUSE_BUTTON_WHEEL_DOWN, true, center, 1.0)
	check(transform.cell_pixels < before_burst * PuzzleViewportTransform.ZOOM_STEP,
		"wheel down zooms back out")
	await _dispose(puzzle)

func _check_original_puzzles_fit_without_navigation() -> void:
	for window in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(800, 800), Vector2i(1920, 1080)]:
		var checked := 0
		for i in range(14):
			var id := PuzzleCatalog.id_at(i)
			var puzzle := await _spawn(id, window)
			var board := _board(puzzle)
			var transform := board.view_transform
			var definition := board.definition
			var readable: bool = transform.cell_pixels >= PuzzleViewportTransform.COMFORTABLE_CELL_PIXELS - 0.001
			if not readable:
				check(false, "original puzzle '%s' is comfortable without navigation at %s (%.1f px/cell)" % [id, window, transform.cell_pixels])
			var hud: Control = puzzle.get_node("%HUD")
			var toolbar: Control = puzzle.get_node("%Toolbar")
			var help: Control = puzzle.get_node("%HelpLabel")
			var overlaps := Rect2(hud.global_position, hud.size).intersects(Rect2(board.global_position, board.size)) \
				or Rect2(toolbar.global_position, toolbar.size).intersects(Rect2(board.global_position, board.size)) \
				or Rect2(help.global_position, help.size).intersects(Rect2(board.global_position, board.size))
			if overlaps:
				check(false, "HUD/toolbar/help overlap the board for '%s' at %s" % [id, window])
			var world_rect := Rect2(board._world.position, Vector2(definition.width, definition.height) \
				* PuzzleViewportTransform.CANONICAL_CELL_PIXELS * board._world.scale)
			if not Rect2(Vector2.ZERO, board.size).grow(0.5).encloses(world_rect):
				check(false, "'%s' does not fit inside the board area at %s" % [id, window])
			if transform.fit_mode == false:
				check(false, "'%s' starts fitted at %s" % [id, window])
			checked += 1
			await _dispose(puzzle)
		check(checked == 14, "all 14 original puzzles were laid out at %s" % [window])
	get_root().size = Vector2i(1280, 720)

func _check_fit_uses_original_bounds_after_removal() -> void:
	var puzzle := await _spawn("dependency_chain")
	var board := _board(puzzle)
	var transform := board.view_transform
	var size_before := transform.board_size
	var scale_before := transform.cell_pixels
	var order := _clear_order(board.definition)
	board.cell_clicked.emit(order[0])
	board.cell_clicked.emit(order[1])
	check(transform.board_size == size_before and is_equal_approx(transform.cell_pixels, scale_before),
		"removing arrows never refits to the remaining geometry")
	board.zoom_in()
	board.fit_puzzle()
	check(is_equal_approx(transform.cell_pixels, scale_before) and transform.center_cells.is_equal_approx(Vector2(size_before) / 2.0),
		"Fit after removals is centered on the original board dimensions")
	await _await_departures_for(puzzle)
	await _dispose(puzzle)

func _await_departures_for(puzzle: Control) -> void:
	await _await_departures(puzzle, _worst_case_seconds(_board(puzzle).definition))

# --- Navigation without a pointing device --------------------------------------

func _check_focus_loop_and_neighbors() -> void:
	var puzzle := await _spawn(LARGE_ID)
	var board := _board(puzzle)
	var open_move: Control = puzzle.get_node("%OpenMoveButton")
	var zoom_out: Control = puzzle.get_node("%ZoomOutButton")
	var zoom_in: Control = puzzle.get_node("%ZoomInButton")
	var fit: Control = puzzle.get_node("%FitButton")
	var pan: Control = puzzle.get_node("%PanButton")
	var cycle: Array[Control] = [open_move, zoom_out, zoom_in, fit, pan, board]
	var all_focusable := true
	for control in cycle:
		if control.focus_mode != Control.FOCUS_ALL:
			all_focusable = false
	check(all_focusable, "the Open Move button, toolbar controls and board are all keyboard/gamepad focusable")
	var tab_ok := true
	for i in range(cycle.size()):
		if cycle[i].find_next_valid_focus() != cycle[(i + 1) % cycle.size()]:
			tab_ok = false
		if cycle[i].find_prev_valid_focus() != cycle[(i - 1 + cycle.size()) % cycle.size()]:
			tab_ok = false
	check(tab_ok, "Tab and Shift+Tab cycle Open Move, Zoom Out, Zoom In, Fit, Pan, board and back")
	check(board.find_valid_focus_neighbor(SIDE_TOP) == pan, "D-pad up from the board returns to Pan")
	check(board.find_valid_focus_neighbor(SIDE_LEFT) == board and board.find_valid_focus_neighbor(SIDE_BOTTOM) == board,
		"the board keeps directional focus on itself for other directions")
	var exits_ok := true
	for button in [zoom_out, zoom_in, fit, pan]:
		if button.find_valid_focus_neighbor(SIDE_BOTTOM) != board or button.find_valid_focus_neighbor(SIDE_TOP) != open_move:
			exits_ok = false
	check(exits_ok, "every toolbar control has directional neighbors that leave the toolbar")
	check(zoom_out.find_valid_focus_neighbor(SIDE_RIGHT) == zoom_in and fit.find_valid_focus_neighbor(SIDE_LEFT) == zoom_in \
			and fit.find_valid_focus_neighbor(SIDE_RIGHT) == pan, "directional focus walks the toolbar in order")

	# Buttons work through their real pressed signals and never disable themselves.
	var state_before := _snapshot(puzzle)
	zoom_in.pressed.emit()
	check(not board.view_transform.fit_mode, "Zoom In (button) changes the view")
	zoom_out.pressed.emit()
	zoom_in.pressed.emit()
	fit.pressed.emit()
	check(board.view_transform.fit_mode, "Fit Puzzle (button) restores the overview")
	check(not zoom_out.disabled and not zoom_in.disabled and not fit.disabled and not pan.disabled,
		"toolbar controls stay enabled so a focused control is never lost")
	pan.toggled.emit(true)
	check(board.is_pan_mode(), "the Pan toggle enables Pan mode")
	pan.toggled.emit(false)
	check(state_before == _snapshot(puzzle), "toolbar navigation leaves the rule state untouched")
	await _dispose(puzzle)

func _check_focused_actions() -> void:
	var puzzle := await _spawn(LARGE_ID)
	var board := _board(puzzle)
	var transform := board.view_transform
	board.grab_focus()
	await process_frame
	check(board.has_focus(), "the board can take keyboard/gamepad focus")
	var fit_scale := transform.cell_pixels
	board._gui_input(_action_event(&"canvas_zoom_in"))
	check(is_equal_approx(transform.cell_pixels, fit_scale * PuzzleViewportTransform.ZOOM_STEP),
		"canvas_zoom_in zooms one step about the view center")
	board._gui_input(_action_event(&"canvas_zoom_out"))
	check(is_equal_approx(transform.cell_pixels, fit_scale), "canvas_zoom_out zooms back one step")
	board._gui_input(_action_event(&"canvas_zoom_in"))
	board._gui_input(_action_event(&"canvas_zoom_in"))
	board._gui_input(_action_event(&"canvas_fit"))
	check(transform.fit_mode and is_equal_approx(transform.cell_pixels, fit_scale), "canvas_fit restores the overview")
	board._gui_input(_action_event(&"canvas_zoom_in", false))
	check(is_equal_approx(transform.cell_pixels, fit_scale), "a released action does nothing")

	# Focused keyboard/stick pan is polled per frame and normalized. Zoom far
	# enough that both axes overflow the viewport, or an axis cannot pan.
	for i in range(7):
		board._gui_input(_action_event(&"canvas_zoom_in"))
	var center_before := transform.center_cells
	var scale := transform.cell_pixels
	Input.action_press(&"move_right")
	board._process(0.1)
	Input.action_release(&"move_right")
	check(transform.center_cells.x > center_before.x and is_equal_approx(transform.center_cells.y, center_before.y),
		"focused move_right pans the camera toward +x only")
	check(absf((transform.center_cells.x - center_before.x) * scale - PuzzleBoard.KEY_PAN_SPEED * 0.1) < 0.5,
		"focused pan moves 600 screen pixels per second independent of zoom")
	center_before = transform.center_cells
	Input.action_press(&"move_down")
	Input.action_press(&"move_right")
	board._process(0.1)
	Input.action_release(&"move_down")
	Input.action_release(&"move_right")
	var diagonal := (transform.center_cells - center_before) * scale
	check(absf(diagonal.length() - PuzzleBoard.KEY_PAN_SPEED * 0.1) < 0.5,
		"diagonal pan is normalized to the same speed as a straight pan")

	# Focus transfer: another focused control never lets the camera keep moving.
	var pan_button: Button = puzzle.get_node("%PanButton")
	pan_button.grab_focus()
	await process_frame
	check(not board.has_focus(), "focus can leave the board for the toolbar")
	center_before = transform.center_cells
	Input.action_press(&"move_left")
	board._process(0.1)
	Input.action_release(&"move_left")
	check(transform.center_cells == center_before, "without board focus the pan actions never move the camera")

	# Events matching the pan actions are consumed by a focused board; unrelated events are not.
	board.grab_focus()
	await process_frame
	var w_event := InputEventKey.new()
	w_event.physical_keycode = KEY_W
	w_event.pressed = true
	check(board._is_canvas_action_event(w_event), "the default move_up key is treated as a canvas action while focused")
	var tab_event := InputEventKey.new()
	tab_event.keycode = KEY_TAB
	tab_event.pressed = true
	check(not board._is_canvas_action_event(tab_event), "Tab is never consumed by the board")
	var stick := InputEventJoypadMotion.new()
	stick.axis = JOY_AXIS_LEFT_X
	stick.axis_value = 1.0
	check(board._is_canvas_action_event(stick), "the left stick is consumed so it cannot also move GUI focus")
	var dpad := InputEventJoypadButton.new()
	dpad.button_index = JOY_BUTTON_DPAD_UP
	dpad.pressed = true
	check(not board._is_canvas_action_event(dpad), "D-pad buttons still navigate focus")
	await _dispose(puzzle)

func _check_remapped_movement_cannot_trap_focus() -> void:
	var puzzle := await _spawn(LARGE_ID)
	var board := _board(puzzle)
	board.grab_focus()
	await process_frame
	var saved: Dictionary = {}
	for action in [&"move_up", &"move_down", &"move_left", &"move_right"]:
		saved[action] = InputMap.action_get_events(action)
	# Remap movement onto inputs that GUI focus navigation also uses.
	var tab := InputEventKey.new()
	tab.keycode = KEY_TAB
	var dpad := InputEventJoypadButton.new()
	dpad.button_index = JOY_BUTTON_DPAD_LEFT
	for action in saved.keys():
		InputMap.action_erase_events(action)
	InputMap.action_add_event(&"move_up", tab)
	InputMap.action_add_event(&"move_left", dpad)
	var tab_press := InputEventKey.new()
	tab_press.keycode = KEY_TAB
	tab_press.pressed = true
	check(not board._is_canvas_action_event(tab_press), "a movement action remapped to Tab is never consumed, so Tab always leaves the board")
	var dpad_press := InputEventJoypadButton.new()
	dpad_press.button_index = JOY_BUTTON_DPAD_LEFT
	dpad_press.pressed = true
	check(not board._is_canvas_action_event(dpad_press), "a movement action remapped to a D-pad button is never consumed")
	check(board.find_next_valid_focus() != board and board.find_valid_focus_neighbor(SIDE_TOP) != board,
		"focus can still leave the board by Tab order and by D-pad up")
	var i_key := InputEventKey.new()
	i_key.physical_keycode = KEY_I
	InputMap.action_add_event(&"move_down", i_key)
	var i_press := InputEventKey.new()
	i_press.physical_keycode = KEY_I
	i_press.pressed = true
	check(board._is_canvas_action_event(i_press), "an ordinary remapped movement key is honored")
	for action in saved.keys():
		InputMap.action_erase_events(action)
		for event in saved[action]:
			InputMap.action_add_event(action, event)
	await _dispose(puzzle)

func _check_eligibility_overlays_and_window_loss() -> void:
	var puzzle := await _spawn(LARGE_ID)
	var board := _board(puzzle)
	var transform := board.view_transform
	board.grab_focus()
	await process_frame
	# An active drag is cancelled by pause, and paused navigation does nothing.
	_mouse_button(board, MOUSE_BUTTON_MIDDLE, true, Vector2(300, 300))
	check(board._drag_button == MOUSE_BUTTON_MIDDLE, "a middle press captures a navigation drag")
	board.notification(Node.NOTIFICATION_PAUSED)
	check(board._drag_button == 0, "pause cancels a captured drag")
	var scale_before := transform.cell_pixels
	paused = true
	board.zoom_in()
	_mouse_button(board, MOUSE_BUTTON_WHEEL_UP, true, board.size / 2.0)
	check(is_equal_approx(transform.cell_pixels, scale_before), "navigation is ignored while the tree is paused")
	paused = false

	# Window focus loss and hiding cancel a drag as well.
	_mouse_button(board, MOUSE_BUTTON_MIDDLE, true, Vector2(300, 300))
	board.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(board._drag_button == 0, "window focus loss cancels a captured drag")
	_mouse_button(board, MOUSE_BUTTON_MIDDLE, true, Vector2(300, 300))
	board.hide()
	check(board._drag_button == 0, "hiding the board cancels a captured drag")
	board.show()
	_mouse_button(board, MOUSE_BUTTON_MIDDLE, true, Vector2(300, 300))
	board._on_window_focus_exited()
	check(board._drag_button == 0, "the window losing focus cancels a captured drag")

	# Results cover the board: navigation is disabled and its input ignored.
	board.set_navigation_enabled(false)
	scale_before = transform.cell_pixels
	board.zoom_in()
	_mouse_button(board, MOUSE_BUTTON_WHEEL_UP, true, board.size / 2.0)
	_mouse_button(board, MOUSE_BUTTON_MIDDLE, true, Vector2(300, 300))
	check(board._drag_button == 0 and is_equal_approx(transform.cell_pixels, scale_before),
		"disabled navigation ignores zoom and drag input")
	board.set_navigation_enabled(true)
	board.zoom_in()
	check(transform.cell_pixels > scale_before, "re-enabled navigation works again")
	await _dispose(puzzle)

func _check_input_actions_and_help() -> void:
	for action in [&"canvas_zoom_in", &"canvas_zoom_out", &"canvas_fit"]:
		check(InputMap.has_action(action) and not InputMap.action_get_events(action).is_empty(),
			"%s exists with default bindings" % action)
	var keyboard_zoom_in := false
	var pad_zoom_in := false
	for event in InputMap.action_get_events(&"canvas_zoom_in"):
		keyboard_zoom_in = keyboard_zoom_in or event is InputEventKey
		pad_zoom_in = pad_zoom_in or (event is InputEventJoypadButton and event.button_index == JOY_BUTTON_RIGHT_SHOULDER)
	check(keyboard_zoom_in and pad_zoom_in, "zoom in has keyboard keys and the right shoulder by default")
	var fit_pad := false
	for event in InputMap.action_get_events(&"canvas_fit"):
		fit_pad = fit_pad or (event is InputEventJoypadButton and event.button_index == JOY_BUTTON_Y)
	check(fit_pad, "Fit is on gamepad Y by default")
	var puzzle := await _spawn(LARGE_ID)
	var help: Label = puzzle.get_node("%HelpLabel")
	check(help.text.contains("Middle-drag") and help.text.contains("fit"), "the help line describes navigation")
	check(help.text.contains(InputMap.action_get_events(&"canvas_fit")[0].as_text_physical_keycode()),
		"the help line is derived from the live InputMap")
	var board := _board(puzzle)
	board.set_pan_mode(true)
	await process_frame
	check(help.text.begins_with("Pan mode"), "the help line reflects Pan mode")
	check((puzzle.get_node("%PanButton") as Button).button_pressed, "the Pan toggle shows its pressed state")
	await _dispose(puzzle)

# --- Selection and Open Move help under a transformed view ---------------------

## Moves the view (by real middle-drag events) so a logical point sits at the
## board's center, as far as the pan bounds allow.
func _center_on(board: PuzzleBoard, logical: Vector2) -> void:
	var delta := board.size / 2.0 - _local_of(board, logical)
	_drag(board, MOUSE_BUTTON_MIDDLE, delta)

func _click_at(board: PuzzleBoard, local: Vector2) -> void:
	_mouse_button(board, MOUSE_BUTTON_LEFT, true, local)
	_mouse_button(board, MOUSE_BUTTON_LEFT, false, local)

func _cell_center(board: PuzzleBoard, cell: Vector2i) -> Vector2:
	return _local_of(board, Vector2(cell) + Vector2(0.5, 0.5))

func _working_view_at(board: PuzzleBoard, logical: Vector2) -> void:
	for i in range(40):
		if board.view_transform.cell_pixels >= 64.0 - 0.01:
			break
		board.zoom_in()
	_center_on(board, logical)

func _check_transformed_hits() -> void:
	var puzzle := await _spawn(LARGE_ID)
	var board := _board(puzzle)
	var clicked: Array[Vector2i] = []
	board.cell_clicked.connect(func(cell: Vector2i): clicked.append(cell))
	var hovered: Array[Vector2i] = []
	board.hover_cell_changed.connect(func(cell: Vector2i): hovered.append(cell))
	_working_view_at(board, Vector2(8, 4))
	var head := Vector2i(4, 1)
	var tail_cell := Vector2i(4, 5)
	var empty_cell := Vector2i(1, 1)
	check(board.view_transform.cell_at(_cell_center(board, head)) == head, "the head cell resolves through the inverse transform")

	var snapshot_before := _snapshot(puzzle)
	_click_at(board, _cell_center(board, empty_cell))
	check(clicked == [empty_cell], "a press on an empty cell emits exactly that cell")
	check(_snapshot(puzzle) == snapshot_before, "an empty-cell press changes no rule state, counter or assist")
	clicked.clear()

	_mouse_motion(board, _cell_center(board, tail_cell), Vector2.ZERO, 0)
	check(hovered.has(tail_cell), "pointer motion over a tail cell samples that cell through the inverse transform")
	_click_at(board, _cell_center(board, tail_cell))
	check(clicked == [tail_cell], "a press on a tail cell emits the tail cell (the controller resolves the owner)")
	check(puzzle._state.get_arrow_head(tail_cell) == null or puzzle._state.get_arrow_head(tail_cell) == head,
		"the controller maps the tail cell to its canonical head")
	clicked.clear()

	# Outside the board's own bounds (the margin) resolves to nothing at overview.
	board.fit_puzzle()
	var margin_point := _local_of(board, Vector2(-0.25, -0.25))
	if Rect2(Vector2.ZERO, board.size).has_point(margin_point):
		_click_at(board, margin_point)
	check(clicked.is_empty(), "a press outside the authored board emits no cell")
	await _dispose(puzzle)

func _check_blocked_and_removed_selection_after_navigation() -> void:
	var puzzle := await _spawn(LARGE_ID)
	var board := _board(puzzle)
	# A2's tail cell (26,8) is on a long bent tail, blocked by A3 at the start.
	var blocked_tail := Vector2i(26, 8)
	check(puzzle._state.get_arrow_head(blocked_tail) == Vector2i(35, 3), "the fixture's blocked long arrow owns its tail cell")
	_working_view_at(board, Vector2(blocked_tail) + Vector2(0.5, 0.5))
	var before := _snapshot(puzzle)
	_click_at(board, _cell_center(board, blocked_tail))
	var after := _snapshot(puzzle)
	check(after["mistakes"] == before["mistakes"] + 1 and after["total_taps"] == before["total_taps"] + 1 \
			and after["successful_removals"] == 0 and after["remaining"] == before["remaining"],
		"a zoomed, panned tail-cell press on a blocked arrow counts exactly one mistake and one tap")
	check(board._views.has(Vector2i(35, 3)), "the blocked arrow's view remains active")

	# A legal head elsewhere: pan there and remove it.
	_working_view_at(board, Vector2(4.5, 1.5))
	var taps: int = puzzle._state.total_taps
	_click_at(board, _cell_center(board, Vector2i(4, 1)))
	check(puzzle._state.remaining() == board.definition.arrows.size() - 1 and puzzle._state.total_taps == taps + 1,
		"selecting the open head after panning removes exactly that arrow")
	check(board._departing_views.has(Vector2i(4, 1)) and not board._views.has(Vector2i(4, 1)),
		"the removed arrow's view moves to the departing collection")
	var after_removal := _snapshot(puzzle)
	_click_at(board, _cell_center(board, Vector2i(4, 4)))
	check(_snapshot(puzzle) == after_removal, "departed cells cannot be selected again")
	await _await_departures_for(puzzle)
	await _dispose(puzzle)

func _check_pan_gestures_never_select() -> void:
	var puzzle := await _spawn(LARGE_ID)
	var board := _board(puzzle)
	var clicked: Array[Vector2i] = []
	board.cell_clicked.connect(func(cell: Vector2i): clicked.append(cell))
	_working_view_at(board, Vector2(8, 4))
	var snapshot_before := _snapshot(puzzle)
	# An empty cell keeps the rule state untouched, so any selection would show.
	var start := _cell_center(board, Vector2i(1, 1))

	# Select mode: a press selects once, motion afterwards never pans.
	var center_before := board.view_transform.center_cells
	_mouse_button(board, MOUSE_BUTTON_LEFT, true, start)
	_mouse_motion(board, start + Vector2(50, 50), Vector2(50, 50), MOUSE_BUTTON_MASK_LEFT)
	_mouse_button(board, MOUSE_BUTTON_LEFT, false, start + Vector2(50, 50))
	check(clicked.size() == 1 and board.view_transform.center_cells == center_before,
		"in Select mode an unmodified primary press selects once and a drag never pans")
	clicked.clear()

	# Middle drag pans without any selection.
	center_before = board.view_transform.center_cells
	_drag(board, MOUSE_BUTTON_MIDDLE, Vector2(-120, -80), start)
	check(clicked.is_empty() and board.view_transform.center_cells != center_before, "a middle drag pans and never emits a selection")

	# A primary press while a middle drag is captured never selects.
	_mouse_button(board, MOUSE_BUTTON_MIDDLE, true, start)
	_mouse_button(board, MOUSE_BUTTON_LEFT, true, start)
	_mouse_button(board, MOUSE_BUTTON_LEFT, false, start)
	_mouse_button(board, MOUSE_BUTTON_MIDDLE, false, start)
	check(clicked.is_empty(), "a simultaneous primary press during a middle drag emits no selection")

	# Pan mode: primary drag pans and never selects, even on a head.
	board.set_pan_mode(true)
	check(board.is_pan_mode(), "Pan mode can be enabled")
	center_before = board.view_transform.center_cells
	_drag(board, MOUSE_BUTTON_LEFT, Vector2(60, 40), start)
	check(clicked.is_empty() and board.view_transform.center_cells != center_before,
		"in Pan mode a primary drag pans and emits no selection")
	# Release outside the board ends the gesture without a selection.
	_mouse_button(board, MOUSE_BUTTON_LEFT, true, start)
	_mouse_motion(board, Vector2(-500, -500), Vector2(-100, -100), MOUSE_BUTTON_MASK_LEFT)
	_mouse_button(board, MOUSE_BUTTON_LEFT, false, Vector2(-500, -500))
	check(board._drag_button == 0 and clicked.is_empty(), "releasing outside the board ends the drag with no selection")
	# A lost button (mask says released) cancels the capture.
	_mouse_button(board, MOUSE_BUTTON_LEFT, true, start)
	_mouse_motion(board, start + Vector2(10, 10), Vector2(10, 10), 0)
	check(board._drag_button == 0, "motion reporting no held button cancels the drag")
	# Leaving Pan mode mid-drag cancels it.
	_mouse_button(board, MOUSE_BUTTON_LEFT, true, start)
	board.set_pan_mode(false)
	check(board._drag_button == 0 and clicked.is_empty(), "leaving Pan mode mid-gesture cancels it without a selection")
	board.set_pan_mode(false)
	check(_snapshot(puzzle) == snapshot_before, "no gesture changed the rule state (the only presses landed on empty cells)")
	_click_at(board, board.size / 2.0)
	check(clicked.size() == 1, "selection works again in Select mode after all gestures")
	await _dispose(puzzle)

func _check_off_screen_open_move_reveal() -> void:
	var puzzle := await _spawn(LARGE_ID)
	var board := _board(puzzle)
	var transform := board.view_transform
	var open_move: Button = puzzle.get_node("%OpenMoveButton")
	var head := Vector2i(4, 1)
	var viewport_rect := Rect2(Vector2.ZERO, board.size)

	# From the overview (below the readable scale): reveal raises the scale.
	check(transform.cell_pixels < 48.0, "the overview is below the readable scale")
	open_move.pressed.emit()
	check(puzzle._state.open_move_assists == 1, "one request charges exactly one assist")
	check(transform.cell_pixels >= 48.0 - 0.01, "revealing from the overview raises the scale to at least 48 px per cell")
	check(viewport_rect.grow(-8.0 + 0.01).encloses(_rect_of(board, head)), "the head cell is fully visible with 8 px padding")
	check(board._views[head]._suggested, "the revealed head pulses through the existing suggestion feedback")

	# Already readable and visible: a repeat request moves nothing but still charges once.
	var center_before := transform.center_cells
	var scale_before := transform.cell_pixels
	open_move.pressed.emit()
	check(puzzle._state.open_move_assists == 2, "a repeated request is charged once more")
	check(transform.center_cells == center_before and is_equal_approx(transform.cell_pixels, scale_before),
		"a target that is already readable and visible does not move the view")

	# Off-screen at the working scale, panned far away.
	_drag(board, MOUSE_BUTTON_MIDDLE, Vector2(-1.0e5, -1.0e5))
	check(not viewport_rect.encloses(_rect_of(board, head)), "the open head is off-screen after panning away")
	var scale_off := transform.cell_pixels
	open_move.pressed.emit()
	check(puzzle._state.open_move_assists == 3, "an off-screen request is charged exactly once")
	check(viewport_rect.grow(-8.0 + 0.01).encloses(_rect_of(board, head)), "the off-screen head is revealed with padding")
	check(transform.cell_pixels >= scale_off - 0.001, "reveal never lowers the working scale")

	# A long arrow: at maximum zoom only part of the 27-cell arrow can be visible.
	for i in range(60):
		board.zoom_in()
	_drag(board, MOUSE_BUTTON_MIDDLE, Vector2(-1.0e5, -1.0e5))
	open_move.pressed.emit()
	check(viewport_rect.grow(-8.0 + 0.01).encloses(_rect_of(board, head)),
		"a long arrow's head is revealed at maximum zoom even though its tail cannot fit")
	check(is_equal_approx(transform.cell_pixels, PuzzleViewportTransform.MAX_CELL_PIXELS), "reveal keeps the current larger scale")
	check(puzzle._state.open_move_assists == 4, "each request charged once (four so far)")
	# Rule outcome is still the one deterministic legal head.
	check(puzzle._state.find_open_move() == head, "the revealed head is the rule authority's open move")
	await _dispose(puzzle)

func _check_completed_open_move_is_noop() -> void:
	var puzzle := await _spawn("intro")
	var board := _board(puzzle)
	var open_move: Button = puzzle.get_node("%OpenMoveButton")
	for head in _clear_order(board.definition):
		board.cell_clicked.emit(head)
	await _await_departures_for(puzzle)
	var assists: int = puzzle._state.open_move_assists
	var center_before := board.view_transform.center_cells
	open_move.pressed.emit()
	check(puzzle._state.completed and puzzle._state.open_move_assists == assists,
		"an Open Move request after completion is a no-op with no assist charge")
	check(board.view_transform.center_cells == center_before, "a completed request leaves the view unchanged")
	await _dispose(puzzle)

func _check_pending_reveal_after_invalid_area() -> void:
	var board := PuzzleBoard.new()
	get_root().add_child(board)
	board.size = Vector2(1280, 720)
	var definition := PuzzleCatalog.get_definition(LARGE_ID)
	board.setup(definition)
	await process_frame
	board.size = Vector2.ZERO
	await process_frame
	check(not board.view_transform.layout_valid, "a zero-size board has an invalid layout")
	var head := Vector2i(4, 1)
	board.suggest_open_move(head)
	check(board._suggested_head == head and board._pending_reveal, "an invalid area keeps the reveal pending")
	check(board.view_transform.cell_pixels < 48.0, "nothing is revealed while the area is invalid")
	board.size = Vector2(1280, 720)
	await process_frame
	check(not board._pending_reveal and board.view_transform.cell_pixels >= 48.0 - 0.01,
		"valid recovery applies the pending reveal exactly once")
	check(Rect2(Vector2.ZERO, board.size).encloses(Rect2(board.view_transform.logical_to_local(Vector2(head)),
			Vector2.ONE * board.view_transform.cell_pixels)), "the recovered reveal shows the head cell")
	check(board._views[head]._suggested, "the suggestion pulse stays active through the invalid interval")

	# A replaced or cleared suggestion cancels the pending reveal.
	board.size = Vector2.ZERO
	await process_frame
	var scale_kept := board.view_transform.cell_pixels
	var center_kept := board.view_transform.center_cells
	board.suggest_open_move(Vector2i(18, 8))
	board.clear_suggestion()
	check(not board._pending_reveal and board._suggested_head == null, "clearing a suggestion cancels its pending reveal")
	board.size = Vector2(1280, 720)
	await process_frame
	check(is_equal_approx(board.view_transform.cell_pixels, scale_kept) and board.view_transform.center_cells.is_equal_approx(center_kept),
		"a cancelled reveal never moves the view after recovery")
	board.queue_free()
	await process_frame

func _check_state_parity_across_navigation() -> void:
	var definition := PuzzleCatalog.get_definition(LARGE_ID)
	var analysis_before := PuzzleAnalyzer.analyze(definition)
	var solver_before := PuzzleSolver.analyze(definition)
	var reference := PuzzleState.new(definition)
	for head in solver_before.witness:
		reference.select_arrow(head)
	var expected: Dictionary = reference.get_results()

	var puzzle := await _spawn(LARGE_ID)
	var board := _board(puzzle)
	var order := _clear_order(board.definition)
	var step := 0
	for head in order:
		# Interleave navigation of every kind between the selections.
		match step % 4:
			0: _working_view_at(board, Vector2(head) + Vector2(0.5, 0.5))
			1: board.fit_puzzle()
			2: board.zoom_out()
			3: _drag(board, MOUSE_BUTTON_MIDDLE, Vector2(90, -60))
		var local := _cell_center(board, head)
		if Rect2(Vector2.ZERO, board.size).has_point(local) and board.view_transform.cell_at(local) == head:
			_click_at(board, local)
		else:
			board.cell_clicked.emit(head)
		step += 1
	await _await_departures_for(puzzle)
	check(puzzle._state.completed, "the witness completes the board while navigating between selections")
	var results: Dictionary = puzzle._state.get_results()
	check(results == expected, "results with navigation match a pure-state replay exactly")
	check(results["mistakes"] == 0 and results["open_move_assists"] == 0 and results["score"] == results["total_arrows"],
		"navigation adds no mistake, assist or score change")
	var stored = PuzzleScoreboard.get_best(LARGE_ID)
	check(stored != null and stored["score"] == expected["score"], "the session best equals the pure-state result")
	check(PuzzleAnalyzer.analyze(definition) == analysis_before and PuzzleSolver.analyze(definition).witness == solver_before.witness,
		"solver and analyzer outputs are identical before and after navigation flows")
	check(board.view_transform.board_size == Vector2i(40, 30), "the transform still describes the original board after completion")
	await _dispose(puzzle)

# --- Departures and attempts under navigation ------------------------------------

## First five heads of the fixture's solver witness: legal to remove in this
## order, so several long departures overlap.
var _long_heads: Array[Vector2i] = []

func _departure_signature(board: PuzzleBoard) -> Dictionary:
	var signature := {}
	for head in board._departing_views.keys():
		var view: ArrowView = board._departing_views[head]
		signature[head] = {
			"distance": view._departure_distance,
			"points": view._body.points.duplicate(),
			"position": view.position,
			"size": view.size,
			"extent": view._cell_extent,
			"parent": view.get_parent(),
		}
	return signature

func _distances(board: PuzzleBoard) -> Dictionary:
	var result := {}
	for head in board._departing_views.keys():
		result[head] = board._departing_views[head]._departure_distance
	return result

func _check_concurrent_long_departures_under_navigation() -> void:
	var puzzle := await _spawn(LARGE_ID)
	var board := _board(puzzle)
	var finished := {}
	board.departure_finished.connect(func(): finished["count"] = finished.get("count", 0) + 1)
	for head in _long_heads:
		board.cell_clicked.emit(head)
	check(board._departing_views.size() == _long_heads.size() and puzzle._pending_departures == _long_heads.size(),
		"five arrows depart concurrently with five pending departures")
	var exit_counts := {}
	for head in board._departing_views.keys():
		exit_counts[head] = 0
		board._departing_views[head].exit_finished.connect(func(): exit_counts[head] += 1)

	# Navigation events between two frames change only the parent projection.
	var before := _departure_signature(board)
	board.zoom_in()
	board.zoom_in()
	_drag(board, MOUSE_BUTTON_MIDDLE, Vector2(-200, -120))
	board.fit_puzzle()
	board.zoom_in()
	_drag(board, MOUSE_BUTTON_MIDDLE, Vector2(1.0e5, 1.0e5))
	var after := _departure_signature(board)
	check(before == after, "zoom, pan and fit leave every departing view's route, progress and canonical geometry untouched")
	check(board._departure_clip.size == Vector2(40, 30) * 64.0 and board._departure_clip.get_parent() == board._world,
		"the departure clip keeps the full logical board extent under World")

	# Off-screen departures keep advancing and finish exactly once.
	_drag(board, MOUSE_BUTTON_MIDDLE, Vector2(-1.0e5, -1.0e5))
	var distances := _distances(board)
	await create_timer(0.25).timeout
	var advanced := true
	for head in distances.keys():
		if board._departing_views.has(head) and board._departing_views[head]._departure_distance <= distances[head]:
			advanced = false
	check(advanced, "off-screen departures keep advancing while their view is not visible")
	var partial := _departure_signature(board)
	for head in partial.keys():
		var view: ArrowView = board._departing_views[head]
		check(view._body.points.size() >= 2 and view._cell_extent == 64.0,
			"a long departing view at %s keeps canonical route geometry mid-flight" % [head])
	await _await_departures_for(puzzle)
	check(finished.get("count", 0) == _long_heads.size(), "each concurrent departure reports completion exactly once")
	var once := true
	for head in exit_counts.keys():
		if exit_counts[head] != 1:
			once = false
	check(once, "every departing view emitted exit_finished exactly once")
	check(puzzle._pending_departures == 0 and board._departing_views.is_empty(), "the departure barrier drains fully")
	await _dispose(puzzle)

func _check_departure_full_clearance_is_logical() -> void:
	var puzzle := await _spawn(LARGE_ID)
	var board := _board(puzzle)
	board.cell_clicked.emit(Vector2i(4, 1))
	var view: ArrowView = board._departing_views[Vector2i(4, 1)]
	var cells := board.definition.get_arrow_cells(Vector2i(4, 1)).size()
	check(view._finish_distance > float(cells - 1), "a long arrow's finish distance covers its whole route plus edge clearance")
	# Zoomed way in and panned to the opposite corner, the same finish distance applies.
	for i in range(60):
		board.zoom_in()
	_drag(board, MOUSE_BUTTON_MIDDLE, Vector2(-1.0e5, -1.0e5))
	var finish_before := view._finish_distance
	view.advance_departure(0.05)
	check(is_equal_approx(view._finish_distance, finish_before), "the finish distance is independent of the current zoom")
	await _await_departures_for(puzzle)
	check(puzzle._pending_departures == 0, "a departure watched at maximum zoom still clears the full board")
	await _dispose(puzzle)

func _check_resize_policy_with_departures() -> void:
	var puzzle := await _spawn(LARGE_ID)
	var board := _board(puzzle)
	var transform := board.view_transform
	board.cell_clicked.emit(Vector2i(4, 1))
	var view: ArrowView = board._departing_views[Vector2i(4, 1)]
	var fit_before := transform.cell_pixels
	get_root().size = Vector2i(960, 540)
	await process_frame
	await process_frame
	check(transform.fit_mode and not is_equal_approx(transform.cell_pixels, fit_before) \
			and is_equal_approx(transform.cell_pixels, transform.fit_cell_pixels()),
		"a fit view refits to the new area on resize")
	check(view._cell_extent == 64.0 and view.get_parent() == board._departure_clip,
		"a resize leaves the departing view's canonical extent and parent alone")
	# Manual view: absolute scale is kept.
	for i in range(4):
		board.zoom_in()
	var manual_scale := transform.cell_pixels
	get_root().size = Vector2i(1280, 720)
	await process_frame
	await process_frame
	check(not transform.fit_mode and is_equal_approx(transform.cell_pixels, manual_scale),
		"a manual view keeps its absolute scale across a resize")
	# Results navigation gating after the barrier.
	await _await_departures_for(puzzle)
	await _dispose(puzzle)

func _check_zero_area_pause_and_replacement() -> void:
	var board := PuzzleBoard.new()
	get_root().add_child(board)
	board.size = Vector2(1280, 720)
	var definition := PuzzleCatalog.get_definition(LARGE_ID)
	board.setup(definition)
	await process_frame
	var completions := {}
	board.departure_finished.connect(func(): completions["count"] = completions.get("count", 0) + 1)
	for head in _long_heads:
		board.play_removed(head)
	var per_view := {}
	for head in board._departing_views.keys():
		per_view[head] = 0
		board._departing_views[head].exit_finished.connect(func(): per_view[head] += 1)

	for view in board._departing_views.values():
		view.advance_departure(0.1)
	var frozen := _distances(board)
	board.size = Vector2.ZERO
	await process_frame
	await process_frame
	check(not board.view_transform.layout_valid, "the board reports an invalid layout at zero area")
	check(_distances(board) == frozen, "departures do not advance while the area is invalid")
	var still_canonical := true
	for view in board._departing_views.values():
		if view._cell_extent != 64.0 or view.size.x <= 0.0:
			still_canonical = false
	check(still_canonical, "the canonical extent and route survive an invalid area")
	for view in board._departing_views.values():
		view.advance_departure(0.1) # direct calls obey the same validity flag
	check(_distances(board) == frozen, "direct advance calls are also refused while the layout is invalid")
	check(board.view_transform.cell_at(Vector2(10, 10)) == Vector2i(-1, -1), "hit testing is suspended while invalid")

	board.size = Vector2(1280, 720)
	await process_frame
	check(board.view_transform.layout_valid, "a usable area restores the layout")
	for view in board._departing_views.values():
		view.advance_departure(0.1)
	var resumed := _distances(board)
	var resumed_ok := true
	for head in frozen.keys():
		if resumed[head] <= frozen[head]:
			resumed_ok = false
	check(resumed_ok, "departures resume from their frozen progress after recovery")

	# Pause freezes them too.
	paused = true
	await process_frame
	var paused_before := _distances(board)
	for view in board._departing_views.values():
		view.advance_departure(0.2)
	check(_distances(board) == paused_before, "paused departures do not advance")
	paused = false

	# Run everything to completion off-screen.
	board.zoom_in()
	_drag(board, MOUSE_BUTTON_MIDDLE, Vector2(-1.0e5, -1.0e5))
	var guard := 0
	while board._departing_views.size() > 0 and guard < 4000:
		for head in board._departing_views.keys().duplicate():
			board._departing_views[head].advance_departure(0.05)
		guard += 1
	check(completions.get("count", 0) == _long_heads.size(), "all departures completed exactly once after pause, zero-area and recovery")
	var exactly_once := true
	for head in per_view.keys():
		if per_view[head] != 1:
			exactly_once = false
	check(exactly_once, "no departing view completed twice")

	# Replacement cancels any in-flight departure without a stale completion.
	board.setup(definition)
	for head in _long_heads:
		board.play_removed(head)
	var stale := [0]
	board.departure_finished.connect(func(): stale[0] += 1)
	var old_views := board._departing_views.values().duplicate()
	board.zoom_in()
	board.setup(definition)
	check(board._departing_views.is_empty(), "replacing the puzzle clears the departing collection")
	check(board.view_transform.fit_mode, "a replacement puzzle starts at a fresh overview")
	for view in old_views:
		if is_instance_valid(view):
			view.advance_departure(5.0)
	check(stale[0] == 0, "a replaced attempt's departures never signal completion")
	board.queue_free()
	await process_frame

func _check_results_barrier_and_navigation_gating() -> void:
	var puzzle := await _spawn("dependency_chain")
	var board := _board(puzzle)
	var results = puzzle.get_node("%PuzzleResults")
	for head in _clear_order(board.definition):
		board.cell_clicked.emit(head)
	# Navigation is still allowed while the last departures drain.
	var scale_before := board.view_transform.cell_pixels
	board.zoom_in()
	check(board.view_transform.cell_pixels > scale_before and not results.visible,
		"navigation remains available while departures drain before the results appear")
	await _await_departures_for(puzzle)
	await process_frame
	check(results.visible, "results appear once every departure clears")
	check(not board.is_navigation_enabled(), "showing results disables board navigation")
	var scale_at_results := board.view_transform.cell_pixels
	board.zoom_in()
	_mouse_button(board, MOUSE_BUTTON_WHEEL_UP, true, board.size / 2.0)
	_mouse_button(board, MOUSE_BUTTON_MIDDLE, true, board.size / 2.0)
	check(is_equal_approx(board.view_transform.cell_pixels, scale_at_results) and board._drag_button == 0,
		"zoom and drag are ignored while the results cover the board")
	await _dispose(puzzle)

func _file_bytes(path: String) -> PackedByteArray:
	return FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else PackedByteArray()

func _check_fresh_views_per_attempt_and_no_persistence() -> void:
	var save_path := "user://global_state.tres"
	var settings_path: String = Config.CONFIG_FILE_LOCATION
	var save_before := _file_bytes(save_path)
	var settings_before := _file_bytes(settings_path)

	var first := await _spawn(LARGE_ID)
	var first_board := _board(first)
	for i in range(5):
		first_board.zoom_in()
	_drag(first_board, MOUSE_BUTTON_MIDDLE, Vector2(-300, -200))
	first_board.set_pan_mode(true)
	check(not first_board.view_transform.fit_mode and first_board.is_pan_mode(), "the first attempt is navigated and in Pan mode")
	var state_before_reload := _snapshot(first)
	await _dispose(first)

	# Replay / pause-menu Restart / Next all rebuild the scene: model that with a fresh instance.
	var replay := await _spawn(LARGE_ID)
	var replay_board := _board(replay)
	check(replay_board.view_transform.fit_mode and is_equal_approx(replay_board.view_transform.cell_pixels,
			replay_board.view_transform.fit_cell_pixels()), "a replayed attempt starts with a fresh complete-board overview")
	check(not replay_board.is_pan_mode() and replay_board.is_navigation_enabled(), "a replayed attempt starts in Select mode with navigation enabled")
	check(replay._state.remaining() == replay_board.definition.arrows.size(),
		"a replayed attempt has fresh rule state")
	check(not (replay.get_node("%PanButton") as Button).button_pressed, "the Pan toggle is reset for the new attempt")
	await _dispose(replay)

	PuzzleSession.set_current_id(PuzzleCatalog.id_at(12))
	check(PuzzleSession.advance_to_next(), "Next from an earlier puzzle advances the session")
	var next_puzzle := await _spawn(PuzzleSession.get_current_id())
	var next_board := _board(next_puzzle)
	check(next_board.view_transform.fit_mode and next_board.view_transform.board_size == Vector2i(7, 7),
		"the next catalog entry starts fitted at its own dimensions")
	await _dispose(next_puzzle)

	var new_entry := await _spawn("intro")
	check(_board(new_entry).view_transform.fit_mode, "a newly selected puzzle starts fitted")
	await _dispose(new_entry)

	check(_file_bytes(save_path) == save_before, "navigation, replay and puzzle changes never write the save file")
	check(_file_bytes(settings_path) == settings_before, "navigation, replay and puzzle changes never write the settings file")
	var settings_text := _file_bytes(settings_path).get_string_from_utf8().to_lower()
	check(not settings_text.contains("viewport") and not settings_text.contains("camera") \
			and not settings_text.contains("pan_mode") and not settings_text.contains("cell_pixels"),
		"no viewport field is persisted in settings")

# --- Level Select with the full catalog --------------------------------

func _apply_window(window: Vector2i) -> void:
	for attempt in range(3):
		get_root().size = window
		await process_frame
		if get_root().size == window:
			return

func _check_level_select_reaches_every_entry_at_supported_windows() -> void:
	for window in [Vector2i(960, 540), Vector2i(800, 800), Vector2i(1280, 720)]:
		await _apply_window(window)
		var menu = load("res://scenes/menus/main_menu/main_menu_with_animations.tscn").instantiate()
		get_root().add_child(menu)
		await process_frame
		await process_frame
		menu._on_level_select_button_pressed()
		await process_frame
		await process_frame
		var list: VBoxContainer = menu.level_select_scene.get_node("%PuzzleListContainer")
		var scroll: ScrollContainer = menu.level_select_scene.get_node("%ScrollContainer")
		check(list.get_child_count() == PuzzleCatalog.count(), "Level Select lists the full catalog at %s" % [window])
		check(scroll.follow_focus and scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED,
			"Level Select scrolls vertically and follows keyboard/gamepad focus at %s" % [window])
		var all_reachable := true
		for i in range(list.get_child_count()):
			var button: Button = list.get_child(i)
			button.grab_focus()
			await process_frame
			await process_frame
			var visible_rect := scroll.get_global_rect().grow(1.0)
			if not visible_rect.encloses(button.get_global_rect()):
				all_reachable = false
		check(all_reachable, "every Level Select entry can be focused fully into view at %s" % [window])
		menu.queue_free()
		await process_frame
	await _apply_window(Vector2i(1280, 720))

func _check_new_experiments_navigate_and_select() -> void:
	var windows := [Vector2i(960, 540), Vector2i(800, 800), Vector2i(1280, 720)]
	for offset in range(6):
		var id := PuzzleCatalog.id_at(15 + offset)
		var puzzle := await _spawn(id, windows[offset % windows.size()])
		var board := _board(puzzle)
		var definition := board.definition
		board.fit_puzzle()
		var viewport := Rect2(Vector2.ZERO, board.size)
		check(viewport.encloses(_rect_of(board, Vector2i.ZERO)) 			and viewport.encloses(_rect_of(board, Vector2i(definition.width - 1, definition.height - 1))),
			"experiment '%s' fits its full authored canvas" % id)
		var witness: Array = PuzzleSolver.analyze(definition).witness
		check(witness.size() == definition.arrows.size(), "experiment '%s' has a complete witness" % id)
		if witness.is_empty():
			await _dispose(puzzle)
			continue
		var first: Vector2i = witness[0]
		var before := _snapshot(puzzle)
		_working_view_at(board, Vector2(first) + Vector2(0.5, 0.5))
		check(viewport.has_point(_cell_center(board, first)) 			and board.view_transform.cell_at(_cell_center(board, first)) == first,
			"experiment '%s' keeps a zoomed legal head selectable" % id)
		check(_snapshot(puzzle) == before, "experiment '%s' navigation does not change rule state" % id)
		_click_at(board, _cell_center(board, first))
		check(puzzle._state.remaining() == definition.arrows.size() - 1 			and puzzle._state.mistakes == 0,
			"experiment '%s' accepts a transformed legal selection" % id)
		await _dispose(puzzle)

# --- Runner -------------------------------------------------------------------

func _initialize() -> void:
	for head in PuzzleSolver.analyze(PuzzleCatalog.get_definition(LARGE_ID)).witness.slice(0, 5):
		_long_heads.append(head)
	await _check_initial_fit_and_large_board()
	await _check_zoom_pan_corners_and_invariants()
	await _check_limit_saturation()
	await _check_wheel_step_scaling_and_clamp()
	await _check_original_puzzles_fit_without_navigation()
	await _check_fit_uses_original_bounds_after_removal()
	await _check_focus_loop_and_neighbors()
	await _check_focused_actions()
	await _check_remapped_movement_cannot_trap_focus()
	await _check_eligibility_overlays_and_window_loss()
	await _check_input_actions_and_help()
	await _check_transformed_hits()
	await _check_blocked_and_removed_selection_after_navigation()
	await _check_pan_gestures_never_select()
	await _check_off_screen_open_move_reveal()
	await _check_completed_open_move_is_noop()
	await _check_pending_reveal_after_invalid_area()
	await _check_state_parity_across_navigation()
	await _check_concurrent_long_departures_under_navigation()
	await _check_departure_full_clearance_is_logical()
	await _check_resize_policy_with_departures()
	await _check_zero_area_pause_and_replacement()
	await _check_results_barrier_and_navigation_gating()
	await _check_fresh_views_per_attempt_and_no_persistence()
	await _check_level_select_reaches_every_entry_at_supported_windows()
	await _check_new_experiments_navigate_and_select()
	PuzzleSession.set_current_id(PuzzleCatalog.id_at(0))
	print("PUZZLE_CANVAS_FAILURES=", failures)
	quit(1 if failures else 0)
