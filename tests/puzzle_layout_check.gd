extends SceneTree
## Headless scene-based check for the arrow puzzle's HUD/board layout and
## feedback-cue duration (FR-005, FR-007). Runs against the real project so
## the full scene/addon dependency graph is available; run_puzzle_regressions.py
## redirects APPDATA/XDG_DATA_HOME so no player save/settings data is touched.

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

func _initialize() -> void:
	check(PuzzleFeedback.BLOCKED_CUE_DURATION_SECONDS <= PuzzleFeedback.BLOCKED_CUE_DURATION_CAP_SECONDS,
		"the coded blocked-feedback cue duration constant does not exceed the FR-005 0.3-second cap")

	var packed: PackedScene = load("res://scenes/puzzle/arrow_puzzle.tscn")
	var puzzle: Control = packed.instantiate()
	get_root().add_child(puzzle)
	await process_frame

	await _check_layout_at_size(puzzle, Vector2i(1280, 720))
	await _check_layout_at_size(puzzle, Vector2i(960, 540))

	puzzle.queue_free()
	print("PUZZLE_LAYOUT_FAILURES=", failures)
	quit(1 if failures else 0)
