extends SceneTree
## Throwaway gameplay smoke: plays first_knot and reference_knot through the real puzzle
## scene with a fixed sequence (one blocked tap, then the solver witness) and prints the
## results, so main and the branch can be compared. Optionally saves a mid-game capture.
## Usage: <godot> --path <project> --script <this file> -- <width> <height> [capture_dir]

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var window_size := Vector2i(int(args[0]), int(args[1]))
	var capture_dir: String = args[2] if args.size() > 2 else ""
	for attempt in range(5):
		DisplayServer.window_set_size(window_size)
		await create_timer(0.2).timeout
		if DisplayServer.window_get_size() == window_size:
			break
	for id in ["first_knot", "reference_knot"]:
		PuzzleSession.set_current_id(id)
		var definition := PuzzleCatalog.get_definition(id)
		var witness: Array = PuzzleSolver.analyze(definition)["witness"]
		var puzzle: Control = load("res://scenes/puzzle/arrow_puzzle.tscn").instantiate()
		root.add_child(puzzle)
		await create_timer(0.5).timeout
		var board = puzzle.get("_board")
		var state = puzzle.get("_state")
		# One deliberately blocked tap: the first witness head that is currently blocked.
		var blocked_tap := Vector2i(-1, -1)
		for head in witness:
			if state.is_blocked(head):
				blocked_tap = head
				break
		if blocked_tap != Vector2i(-1, -1):
			board.cell_clicked.emit(blocked_tap)
		var half := witness.size() / 2
		for i in range(witness.size()):
			board.cell_clicked.emit(witness[i])
			if i == half and capture_dir != "":
				await create_timer(0.4).timeout
				var path := "%s/puzzle_%s_%dx%d.png" % [capture_dir, id, window_size.x, window_size.y]
				root.get_texture().get_image().save_png(path)
				print("SAVED ", path)
		await create_timer(0.2).timeout
		var results: Dictionary = state.get_results()
		print("RESULT %s blocked_tap=%s %s" % [id, blocked_tap, JSON.stringify(results)])
		puzzle.queue_free()
		await process_frame
	quit()
