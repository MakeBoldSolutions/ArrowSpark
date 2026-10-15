extends SceneTree
## Temporary behavior-preservation probe for this spec bundle (not project code).
## Prints, for every catalog entry, identity, geometry version, solver result,
## the Open Move suggestion before every witness move, and the analyzer report.
## Run: <godot> --headless --path . --script <absolute path to this file>

func _initialize() -> void:
	print("PROBE_BEGIN entries=%d" % PuzzleCatalog.count())
	for index in range(PuzzleCatalog.count()):
		var id := PuzzleCatalog.id_at(index)
		var definition := PuzzleCatalog.get_definition(id)
		print("== entry %d" % index)
		print("id=%s title=%s group=%s group_position=%d" % [id, PuzzleCatalog.title_at(index),
			PuzzleCatalog.group_of(id), PuzzleCatalog.group_position(id)])
		print("size=%dx%d arrows=%d version=%s" % [definition.width, definition.height,
			definition.arrows.size(), PuzzleContentVersion.of(definition)])
		var solved: Dictionary = PuzzleSolver.analyze(definition)
		print("valid=%s solvable=%s" % [solved["valid"], solved["solvable"]])
		print("witness=%s" % var_to_str(solved["witness"]))
		print("metrics=%s" % var_to_str(solved["metrics"]))
		var state := PuzzleState.new(definition)
		var trail: Array = []
		for head in solved["witness"]:
			trail.append(state.find_open_move())
			state.select_arrow(head)
		trail.append(state.find_open_move())
		print("open_move_trail=%s completed=%s" % [var_to_str(trail), state.completed])
		print("analyzer=%s" % var_to_str(PuzzleAnalyzer.analyze(definition)))
	print("PROBE_END")
	quit(0)
