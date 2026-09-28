extends SceneTree
## Real-project presentation checks; launch with isolated user data.

var failures: int = 0

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func _initialize() -> void:
	call_deferred("_run")

func _check_geometry() -> void:
	var definition := PuzzleDefinition.create_fixed()
	var before: Dictionary = definition.get_cell_owners()
	for extent in [96.0, 144.0]:
		for direction in PuzzleDefinition.Direction.values():
			var forward := Vector2(PuzzleDefinition.direction_vector(direction))
			for length in [1, 2, 5]:
				var cells: Array[Vector2i] = []
				var head := Vector2i(5, 5)
				for i in range(length):
					cells.append(head - Vector2i(forward) * i)
				var view := ArrowView.new()
				root.add_child(view)
				view.set_shape(head, cells, direction)
				view.set_cell_extent(extent)
				var body := view.get_node_or_null("Body") as Line2D
				var tip := view.get_node_or_null("Head") as Polygon2D
				check(body != null and tip != null, "arrow uses connected body and head children")
				if body != null and tip != null:
					var center: Vector2 = (Vector2(head) + Vector2(0.5, 0.5)) * extent
					check(body.points.size() == maxi(2, length), "body keeps only ordered path points")
					check((tip.polygon[0] - center).normalized().is_equal_approx(forward), "head points in requested direction")
					check(Geometry2D.is_point_in_polygon(body.points[-1], tip.polygon), "shaft endpoint overlaps filled head")
					check(body.begin_cap_mode == Line2D.LINE_CAP_ROUND and body.joint_mode == Line2D.LINE_JOINT_ROUND, "tail and orthogonal joins are rounded")
					check(view.mouse_filter == Control.MOUSE_FILTER_IGNORE, "whole view stays passive for cell input")
					if length == 1:
						var cell_rect := Rect2(Vector2(head) * extent, Vector2.ONE * extent)
						for point in body.points + tip.polygon:
							check(cell_rect.has_point(point), "single-cell geometry stays inside owned cell")
				view.free()
		for head in definition.arrows:
			var cells: Array[Vector2i] = definition.get_arrow_cells(head)
			var view := ArrowView.new()
			root.add_child(view)
			view.set_shape(head, cells, definition.arrows[head])
			view.set_cell_extent(extent)
			var body := view.get_node_or_null("Body") as Line2D
			if body:
				for i in range(cells.size() - 1):
					check(body.points[i].is_equal_approx((Vector2(cells[-1 - i]) + Vector2(0.5, 0.5)) * extent), "bends follow consecutive cells without closing neighboring endpoints")
				var original: PackedVector2Array = body.points.duplicate()
				cells.clear()
				view.set_cell_extent(extent * 0.5)
				check(body.points.size() == original.size(), "view defensively copies shape offsets")
				for i in range(original.size()):
					check(body.points[i].is_equal_approx(original[i] * 0.5), "extent rebuild scales geometry without scaling parent")
				check(view.scale == Vector2.ONE, "layout preserves unit parent scale")
			view.free()
	check(definition.get_cell_owners() == before, "decorative geometry never changes domain occupancy")

func _run() -> void:
	_check_geometry()
	_check_effects()
	_check_departure_geometry()
	var puzzle: Control = load("res://scenes/puzzle/arrow_puzzle.tscn").instantiate()
	root.add_child(puzzle)
	await process_frame
	# These presentation checks assert exact cell positions/relationships
	# (a tail cell sharing an owner with its head, a blocked tail cell, an
	# owned-but-empty cell) authored against the fixed board's specific
	## geometry; explicitly load it here rather than whichever catalog entry
	# PuzzleSession currently defaults to, keeping this suite's assertions
	# independent of the authored catalog content (see tests/puzzle_regression.gd
	# for the same create_fixed()-direct precedent).
	var fixed_definition := PuzzleDefinition.create_fixed()
	puzzle._state = PuzzleState.new(fixed_definition)
	puzzle.get_node("%PuzzleBoard").setup(fixed_definition)
	check(puzzle.get_node("%PuzzleBoard")._views.size() == 8, "real puzzle instantiates all eight views")
	await _check_theme(puzzle)
	await _check_overlay(puzzle)
	_check_hover_and_input(puzzle)
	var numeric: FontVariation = load("res://resources/fonts/inter_tight_numeric.tres")
	var features: Dictionary = numeric.base_font.get_supported_feature_list()
	var tag: int = TextServerManager.get_primary_interface().name_to_tag("tnum")
	check(features.has(tag), "bundled Inter Tight supports tabular figures")
	var width: float = numeric.get_string_size("0", HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x
	for digit in "0123456789":
		check(is_equal_approx(numeric.get_string_size(digit, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x, width), "numeric digit %s has tabular advance" % digit)
	puzzle.queue_free()
	await process_frame
	print("PUZZLE_PRESENTATION_FAILURES=", failures)
	quit(1 if failures else 0)

func _motion(board: PuzzleBoard, cell: Vector2i) -> void:
	var event := InputEventMouseMotion.new()
	event.position = board.view_transform.logical_to_local(Vector2(cell) + Vector2(0.15, 0.15))
	board._gui_input(event)

func _press(board: PuzzleBoard, cell: Vector2i, pressed: bool = true) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = board.view_transform.logical_to_local(Vector2(cell) + Vector2(0.15, 0.15))
	board._gui_input(event)

func _check_hover_and_input(puzzle) -> void:
	var board: PuzzleBoard = puzzle.get_node("%PuzzleBoard")
	check(board.has_method("set_hovered_head"), "board provides canonical-owner hover routing")
	if not board.has_method("set_hovered_head"):
		return
	var state: PuzzleState = puzzle._state
	var remaining: int = state.remaining()
	var view: ArrowView = board._views[Vector2i(0, 0)]
	_motion(board, Vector2i(0, 0))
	check(view._hovered, "head motion hovers whole owner")
	var tween: Tween = view._hover_tween
	_motion(board, Vector2i(1, 1))
	check(view._hovered and view._hover_tween == tween, "moving within owner does not restart transition")
	_motion(board, Vector2i(2, 0))
	check(not view._hovered and board._views[Vector2i(2, 0)]._hovered, "owner change clears previous hover")
	_motion(board, Vector2i(4, 2))
	check(board._hovered_head == null, "empty cell clears hover")
	_motion(board, Vector2i(0, 0))
	board.notification(Node.NOTIFICATION_PAUSED)
	check(not view._hovered and board._last_hover_cell == Vector2i(-1, -1), "pause clears hover and invalidates cell cache")
	_motion(board, Vector2i(0, 0))
	board.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(not view._hovered, "focus loss clears hover")
	_motion(board, Vector2i(0, 0))
	board.mouse_exited.emit()
	check(not view._hovered, "pointer exit clears hover")
	_motion(board, Vector2i(-1, -1))
	check(board._hovered_head == null, "outside cell clears hover")
	check(state.total_taps == 0 and state.remaining() == remaining, "hover never changes taps or active arrows")
	_press(board, Vector2i(3, 0), false)
	check(state.total_taps == 0, "button release never selects")
	_press(board, Vector2i(3, 0))
	check(state.total_taps == 1 and state.mistakes == 1, "blank space in occupied tail cell selects once")
	_motion(board, Vector2i(0, 0))
	_press(board, Vector2i(1, 1))
	check(board._hovered_head == null and not board._views.has(Vector2i(0, 0)), "logical removal immediately clears owner hover")
	_press(board, Vector2i(1, 1))
	_motion(board, Vector2i(0, 0))
	check(state.total_taps == 2 and board._hovered_head == null, "departed cells cannot select or hover visible departure")

func _check_effects() -> void:
	for phase in [0.02, 0.075, 0.11]:
		var view := ArrowView.new()
		root.add_child(view)
		view.size = Vector2(200, 100)
		view.set_cell_extent(100)
		view.set_hovered(true)
		view.play_blocked_feedback()
		check(view._body.default_color == GameVisualStyle.CRITICAL and view._head.color == GameVisualStyle.CRITICAL, "blocked feedback colors whole arrow red")
		view._tween.custom_step(phase)
		check(view.scale.x >= 1.0 and view.scale.x <= 1.12, "pulse stays restrained")
		view.play_blocked_feedback()
		check(view.scale == Vector2.ONE, "repeated blocked cue restarts at baseline")
		view._tween.custom_step(phase)
		var completions := [0]
		view.exit_finished.connect(func(): completions[0] += 1)
		view.start_departure(Vector2i.ZERO, Vector2i(50, 50))
		check(view.scale == Vector2.ONE and view._body.default_color == GameVisualStyle.ARROW_NORMAL and view._head.color == GameVisualStyle.ARROW_NORMAL, "departure synchronously normalizes every pulse phase")
		var geometry_before_duplicate: ArrowDepartureGeometry = view._geometry
		var distance_before_duplicate: float = view._departure_distance
		view.set_hovered(true)
		view.play_blocked_feedback()
		view.start_departure(Vector2i.ZERO, Vector2i(50, 50))
		check(view._geometry == geometry_before_duplicate and view._departure_distance == distance_before_duplicate \
				and view.scale == Vector2.ONE and view._head.color == GameVisualStyle.ARROW_NORMAL,
			"terminal departure ignores stale effects and duplicate starts")
		view.advance_departure(0.3)
		view.advance_departure(0.3)
		check(completions[0] == 1, "departure emits completion exactly once")
		view.free()
	var view := ArrowView.new()
	root.add_child(view)
	view.set_cell_extent(100)
	view.set_hovered(true)
	view.play_blocked_feedback()
	view.set_hovered(false)
	check(view._head.color == GameVisualStyle.CRITICAL, "hover exit cannot overwrite active red feedback")
	view.set_hovered(true)
	view._tween.custom_step(PuzzleFeedback.BLOCKED_CUE_DURATION_SECONDS + 0.05)
	check(view.scale == Vector2.ONE and view._head.color == GameVisualStyle.ARROW_HOVER, "blocked completion immediately restores eligible ember")
	view.play_blocked_feedback()
	view.set_hovered(false)
	view._tween.custom_step(PuzzleFeedback.BLOCKED_CUE_DURATION_SECONDS + 0.05)
	check(view.scale == Vector2.ONE and view._head.color == GameVisualStyle.ARROW_NORMAL, "blocked completion without hover restores ink")
	view.set_hovered(true)
	view._hover_tween.custom_step(0.03)
	view.start_departure(Vector2i.ZERO, Vector2i(50, 50))
	check(view._head.color == GameVisualStyle.ARROW_NORMAL and view.scale == Vector2.ONE, "departure cancels in-progress hover before next frame")
	view.free()

func _points_approx_equal(a: PackedVector2Array, b: PackedVector2Array) -> bool:
	if a.size() != b.size():
		return false
	for i in range(a.size()):
		if not a[i].is_equal_approx(b[i]):
			return false
	return true

## Initial silhouette equivalence, head/body overlap, cardinal orientation in
## all four directions, equal-delta-partition speed and full-tail finish
## (never early, always exactly once) for the path-following departure.
func _check_departure_geometry() -> void:
	for direction in PuzzleDefinition.Direction.values():
		var forward := Vector2(PuzzleDefinition.direction_vector(direction))
		var head := Vector2i(4, 4)
		var cells: Array[Vector2i] = [head, head - Vector2i(forward), head - Vector2i(forward) * 2]
		var view := ArrowView.new()
		root.add_child(view)
		view.set_shape(head, cells, direction)
		view.set_cell_extent(50.0)
		var static_body: PackedVector2Array = view._body.points.duplicate()
		var static_head: PackedVector2Array = view._head.polygon.duplicate()
		view.start_departure(head, Vector2i(9, 9))
		check(_points_approx_equal(view._body.points, static_body) and _points_approx_equal(view._head.polygon, static_head),
			"departure begins with the identical static silhouette, no first-frame geometry jump, for direction %s" % [direction])
		check(Geometry2D.is_point_in_polygon(view._body.points[-1], view._head.polygon),
			"head/body overlap is preserved once departing for direction %s" % [direction])
		var head_base: Vector2 = (view._head.polygon[1] + view._head.polygon[2]) / 2.0
		check((view._head.polygon[0] - head_base).normalized().is_equal_approx(forward),
			"head keeps its cardinal orientation while departing for direction %s" % [direction])
		view.free()

	var one_step := ArrowView.new()
	root.add_child(one_step)
	one_step.set_shape(Vector2i(4, 4), [Vector2i(4, 4)], PuzzleDefinition.Direction.RIGHT)
	one_step.set_cell_extent(50.0)
	one_step.start_departure(Vector2i(4, 4), Vector2i(20, 20))
	one_step.advance_departure(0.2)
	var many_steps := ArrowView.new()
	root.add_child(many_steps)
	many_steps.set_shape(Vector2i(4, 4), [Vector2i(4, 4)], PuzzleDefinition.Direction.RIGHT)
	many_steps.set_cell_extent(50.0)
	many_steps.start_departure(Vector2i(4, 4), Vector2i(20, 20))
	for i in range(20):
		many_steps.advance_departure(0.01)
	check(is_equal_approx(one_step._departure_distance, many_steps._departure_distance),
		"equal elapsed time partitioned into more/smaller steps advances the same total cell distance")
	one_step.free()
	many_steps.free()

	var short_view := ArrowView.new()
	root.add_child(short_view)
	short_view.set_shape(Vector2i(4, 4), [Vector2i(4, 4)], PuzzleDefinition.Direction.RIGHT)
	short_view.set_cell_extent(50.0)
	var long_view := ArrowView.new()
	root.add_child(long_view)
	long_view.set_shape(Vector2i(4, 4), [Vector2i(4, 4), Vector2i(3, 4), Vector2i(2, 4)], PuzzleDefinition.Direction.RIGHT)
	long_view.set_cell_extent(50.0)
	var short_completions := [0]
	var long_completions := [0]
	short_view.exit_finished.connect(func(): short_completions[0] += 1)
	long_view.exit_finished.connect(func(): long_completions[0] += 1)
	short_view.start_departure(Vector2i(4, 4), Vector2i(6, 6))
	long_view.start_departure(Vector2i(4, 4), Vector2i(6, 6))
	check(long_view._finish_distance > short_view._finish_distance,
		"a longer route requires strictly more cell-distance to fully clear than a shorter one")
	for i in range(30):
		short_view.advance_departure(0.05)
		long_view.advance_departure(0.05)
		if short_completions[0] > 0:
			check(short_view._departure_distance >= short_view._finish_distance - ArrowDepartureGeometry.GEOMETRY_TOLERANCE,
				"the short route never signals completion before its own full-tail clearance")
	check(short_completions[0] == 1 and long_completions[0] == 1,
		"both routes eventually finish exactly once via repeated per-frame advancement")
	short_view.free()
	long_view.free()

func _check_theme(puzzle: Control) -> void:
	check(puzzle.theme == null and puzzle.get_node("Layout").theme != null, "theme is scoped to Layout, leaving root overlays unchanged")
	var background := puzzle.get_node_or_null("Background") as ColorRect
	check(background != null, "gameplay has a local background")
	if background:
		check(background.color == GameVisualStyle.GAME_BACKGROUND and background.mouse_filter == Control.MOUSE_FILTER_IGNORE, "light background never intercepts input")
	check(GameVisualStyle.HEADING_FONT.get_font_name() == "Be Vietnam Pro ExtraBold", "major heading uses bundled Be Vietnam Pro ExtraBold")
	# Static ExtraBold uses a legacy family name; Godot reports a bold style
	# weight of 700. Check the actual binary's OS/2 weight, not that heuristic.
	check(_font_file_weight(GameVisualStyle.HEADING_FONT.resource_path) == 800 and _font_file_weight(GameVisualStyle.SECONDARY_HEADING_FONT.resource_path) == 700, "heading binaries carry required weights")
	check(GameVisualStyle.UI_FONT.get_font_name() == "Inter Tight" and GameVisualStyle.UI_FONT.variation_opentype.get("wght") == 600.0, "UI uses bundled Inter Tight 600")
	check(GameVisualStyle.SUPPORTING_FONT.variation_opentype.get("wght") == 400.0, "supporting role uses weight 400")
	var results: Control = puzzle.get_node("%PuzzleResults")
	results.show_results({"total_arrows": 8, "mistakes": 3, "open_move_assists": 1, "score": 5, "accuracy": 8.0 / 11.0}, PuzzleCatalog.id_at(0), false, "established", 5)
	check(results.get_node("%AccuracyLabel").text == "Accuracy: 72.7%" and results.get_node("%ScoreLabel").text == "Score: 5", "results retain numeric behavior")
	check(results.get_node("%OpenMoveAssistsLabel").text == "Open Move Assists: 1", "results display the open-move-assist count as its own value")
	check(results.get_node("%SessionComparisonLabel").text == "New session best: 5", "results display the session-best comparison outcome")
	check(results.get_node("%OverallSessionScoreLabel").text == "Overall Session Score: 5", "results display the overall session score")
	check(results.get_node("%ScoreLabel").get_theme_color("font_color") == GameVisualStyle.GAME_SUCCESS, "existing score supplies success cue")
	var replay: Button = results.get_node("%ReplayButton")
	check(replay.has_focus(), "results preserve Replay focus")
	var focus: StyleBox = replay.get_theme_stylebox("focus")
	check(focus is StyleBoxFlat and focus.border_width_left > 0, "button focus has a visible border")
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540)]:
		root.size = dimensions
		await process_frame
		await process_frame
		for node in [puzzle.get_node("%RemainingLabel"), puzzle.get_node("%MistakesLabel"), results.get_node("%TotalLabel"), results.get_node("%MistakesLabel"), results.get_node("%OpenMoveAssistsLabel"), results.get_node("%ScoreLabel"), results.get_node("%AccuracyLabel"), results.get_node("%SessionComparisonLabel"), results.get_node("%OverallSessionScoreLabel"), replay, results.get_node("%MainMenuButton")]:
			check(node.size.x >= node.get_minimum_size().x and node.size.y >= node.get_minimum_size().y, "text/control fits minimum at %s" % dimensions)
			check(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(node.get_global_rect()), "required content stays onscreen at %s" % dimensions)
			check(node.get_theme_font_size("font_size") >= 16, "text stays readable without shrinking with cells")
	results.hide()

func _font_file_weight(path: String) -> int:
	var file := FileAccess.open(path, FileAccess.READ)
	file.big_endian = true
	file.seek(4)
	var tables: int = file.get_16()
	for i in range(tables):
		file.seek(12 + i * 16)
		var tag: String = file.get_buffer(4).get_string_from_ascii()
		file.get_32() # checksum
		var offset: int = file.get_32()
		if tag == "OS/2":
			file.seek(offset + 4)
			return file.get_16()
	return -1

func _check_overlay(puzzle: Control) -> void:
	var board: PuzzleBoard = puzzle.get_node("%PuzzleBoard")
	var event := InputEventMouseMotion.new()
	event.position = board.global_position + board.view_transform.logical_to_local(Vector2(0.5, 0.5))
	root.push_input(event)
	board.set_hovered_head(Vector2i(0, 0))
	var cover := ColorRect.new()
	root.add_child(cover)
	cover.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await process_frame
	board._process(0.0)
	check(board._hovered_head == null, "new overlay clears stationary owner hover without mouse motion")
	check(root.gui_get_hovered_control() != board, "viewport cursor target refresh does not retain covered board")
	cover.free()
	await process_frame
