extends SceneTree

var puzzle: Control
var output: String

func _initialize() -> void:
	call_deferred("_run")

func capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var result := image.save_png(output.path_join(label + ".png"))
	print("CAPTURE ", label, " ", result)

func pointer(cell: Vector2i) -> void:
	var board: PuzzleBoard = puzzle.get_node("%PuzzleBoard")
	var point: Vector2 = board.global_position + board._origin + (Vector2(cell) + Vector2(0.15, 0.15)) * board._cell_size
	Input.warp_mouse(point)
	var motion := InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion)

func click(cell: Vector2i) -> void:
	pointer(cell)
	var board: PuzzleBoard = puzzle.get_node("%PuzzleBoard")
	var event := InputEventMouseButton.new()
	event.position = board.global_position + board._origin + (Vector2(cell) + Vector2(0.15, 0.15)) * board._cell_size
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	root.push_input(event)
	event.pressed = false
	root.push_input(event)

func _run() -> void:
	output = OS.get_cmdline_user_args()[0]
	print("JOYPADS=", Input.get_connected_joypads())
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540)]:
		root.size = dimensions
		puzzle = load("res://scenes/puzzle/arrow_puzzle.tscn").instantiate()
		root.add_child(puzzle)
		current_scene = puzzle
		await create_timer(0.3).timeout
		var prefix: String = "%dx%d-" % [dimensions.x, dimensions.y]
		await capture(prefix + "gameplay")
		pointer(Vector2i(1, 1))
		await create_timer(0.15).timeout
		print("HOVER=", puzzle.get_node("%PuzzleBoard")._hovered_head)
		await capture(prefix + "hover")
		var cover := ColorRect.new()
		root.add_child(cover)
		cover.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		await create_timer(0.16).timeout
		print("OVERLAY_CLEAR=", puzzle.get_node("%PuzzleBoard")._hovered_head == null)
		cover.queue_free()
		await create_timer(0.16).timeout
		print("STATIONARY_RESTORE=", puzzle.get_node("%PuzzleBoard")._hovered_head)

		click(Vector2i(3, 0))
		await create_timer(0.04).timeout
		await capture(prefix + "blocked")
		await create_timer(0.2).timeout
		await capture(prefix + "hover-restored")
		click(Vector2i(3, 0))
		click(Vector2i(0, 0))
		click(Vector2i(2, 0))
		await capture(prefix + "departure")
		for head in [Vector2i(4, 3), Vector2i(4, 0), Vector2i(0, 3), Vector2i(2, 3), Vector2i(2, 1), Vector2i(3, 2)]:
			click(head)
		await create_timer(0.4).timeout
		await capture(prefix + "results")
		print("RESULTS=", puzzle._state.get_results(), " pending=", puzzle._pending_departures)
		puzzle.queue_free()
		await process_frame
	await fixtures()
	quit()

func fixtures() -> void:
	var fixture := Control.new()
	root.add_child(fixture)
	var background := ColorRect.new()
	background.color = GameVisualStyle.GAME_BACKGROUND
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fixture.add_child(background)
	fixture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540)]:
		root.size = dimensions
		var rows := Control.new()
		fixture.add_child(rows)
		for direction in range(4):
			for shape in range(3):
				var view := ArrowView.new()
				rows.add_child(view)
				var forward := PuzzleDefinition.direction_vector(direction)
				var right := Vector2i(-forward.y, forward.x)
				var cells: Array[Vector2i] = [Vector2i.ZERO]
				if shape >= 1:
					cells.append(-forward)
					cells.append(-forward * 2)
				if shape == 2:
					cells.append(-forward * 2 + right)
					cells.append(-forward + right)
				var origin := PuzzleBoard._bounding_min(cells)
				var offsets: Array[Vector2i] = []
				for cell in cells:
					offsets.append(cell - origin)
				view.set_shape(-origin, offsets, direction)
				view.set_cell_extent(dimensions.y / 14.0)
				view.position = Vector2(dimensions.x * (direction + 0.25) / 4.0, dimensions.y * (shape + 0.18) / 3.0)
		await capture("%dx%d-fixtures" % [dimensions.x, dimensions.y])
		rows.free()
	fixture.free()
