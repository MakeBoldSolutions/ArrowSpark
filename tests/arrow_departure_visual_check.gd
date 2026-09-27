extends SceneTree
## Manual visual fixture for path-following arrow departure. Launch
## non-headless (see tests/README.md) to watch every shape category and
## direction feed through its route and clip at the grid edge; this never
## changes shipped PuzzleDefinition content (PuzzleDefinition.create_fixed())
## and writes no player save/settings data.
##
## Covers, all at once: a single-cell arrow, a straight arrow, a one-bend
## arrow and a long multi-bend arrow, one of each cardinal direction, sized
## so every route is visible without leaving the grid before departing.

func _build_definition() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var arrows := {
		Vector2i(1, 1): d.RIGHT,   # single-cell
		Vector2i(6, 1): d.LEFT,    # straight, 2 cells
		Vector2i(1, 4): d.DOWN,    # one bend
		Vector2i(7, 6): d.UP,      # long multi-bend
	}
	var tails := {
		Vector2i(6, 1): [Vector2i(7, 1)],
		Vector2i(1, 4): [Vector2i(1, 3), Vector2i(2, 3)],
		Vector2i(7, 6): [Vector2i(7, 7), Vector2i(6, 7), Vector2i(6, 6), Vector2i(6, 5), Vector2i(5, 5)],
	}
	var definition := PuzzleDefinition.new(9, 9, arrows, tails)
	assert(definition.is_valid(), "visual fixture definition must be structurally valid")
	return definition

func _stagger_departures(board: PuzzleBoard, heads: Array[Vector2i]) -> void:
	for i in range(heads.size()):
		await create_timer(0.5).timeout
		print("Departing fixture arrow at ", heads[i])
		board.play_removed(heads[i])

func _initialize() -> void:
	get_root().size = Vector2i(900, 900)
	get_root().title = "Arrow Departure Visual Fixture (manual review only)"
	get_root().close_requested.connect(quit)
	var background := ColorRect.new()
	background.color = GameVisualStyle.GAME_BACKGROUND
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	get_root().add_child(background)
	var board := PuzzleBoard.new()
	board.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	get_root().add_child(board)
	var definition := _build_definition()
	board.setup(definition)
	var heads: Array[Vector2i] = []
	for head in definition.arrows.keys():
		heads.append(head)
	print("Loaded fixture: single-cell, straight, one-bend and long multi-bend shapes, all four directions.")
	print("Watching each depart in sequence over the next few seconds; close the window when done.")
	await _stagger_departures(board, heads)
	# A bare `--script` SceneTree exits once _initialize()'s coroutine chain
	# fully completes; without this, the window would vanish right after the
	# last departure instead of staying open for review. close_requested
	# above lets the window's own close button end the process normally.
	while true:
		await create_timer(1.0).timeout
