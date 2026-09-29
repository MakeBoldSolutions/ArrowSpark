extends SceneTree
## Deterministic, non-gating developer structural report. Not a regression
## gate: no check()/failure counter, no PUZZLE_*_FAILURES=0 marker. Enumerates
## PuzzleCatalog and PuzzleAnalyzer.analyze() output only -- prints facts,
## never a composite score, difficulty label, or ranking beyond the nine
## explicit superlative comparisons below. Run via
## tests/run_puzzle_structural_report.py.

func _fmt2(value: float) -> String:
	return "%.2f" % value

func _print_entry(id: String, title: String, r: Dictionary) -> void:
	var board: Dictionary = r.board
	var geometry: Dictionary = r.geometry
	var legal: Dictionary = r.legal_move_structure
	var g: Dictionary = r.dependency_graph
	var blocker: Dictionary = r.blocker_distance

	print("[", id, "] ", title)
	print("  status: valid=", r.valid, " solvable=", r.solvable)
	print("  board: ", board.width, "x", board.height, "  density=", _fmt2(board.density), "  arrows=", board.arrow_count,
		" occupied=", board.occupied_cell_count)
	print("  geometry: single=", geometry.single_cell_count, " multi=", geometry.multi_cell_count,
		" bends_total=", geometry.total_bends, " max_bends=", geometry.max_bends_on_one_arrow,
		" max_length=", geometry.max_length, " avg_length=", _fmt2(geometry.average_length))
	print("  legal: initial=", legal.initial_legal_count, "/", board.arrow_count,
		" (", _fmt2(legal.initial_legal_ratio), ") forced=", legal.forced_state_count,
		" branching=", legal.branching_state_count, " longest_forced_run=", legal.longest_forced_run)
	print("  legal_choice_sequence: ", ",".join((legal.legal_choice_sequence as Array).map(func(x): return str(x))))
	print("  dependency: edges=", g.edge_count, " depth=", g.depth, " max_in_degree=", g.max_in_degree,
		" components=", g.component_count)
	print("  cascade: max_unlock_fan_out=", g.max_unlock_fan_out, " unlock_sequence: ",
		",".join((r.unlock_sequence as Array).map(func(x): return str(x))))
	print("  blocker_distance: max=", blocker.max_distance, " avg=", _fmt2(blocker.average_distance))
	print("  witness_xy: ", ";".join((r.witness as Array).map(func(head): return "%d,%d" % [head.x, head.y])))

func _winner(entries: Array, value_fn: Callable, higher_is_better: bool = true) -> Dictionary:
	var best_id: String = ""
	var best_title: String = ""
	var best_value = null
	var tied := false
	for entry in entries:
		var value = value_fn.call(entry)
		if best_value == null or (higher_is_better and value > best_value) or (not higher_is_better and value < best_value):
			best_value = value
			best_id = entry.id
			best_title = entry.title
			tied = false
		elif value == best_value:
			tied = true
	return {"id": best_id, "title": best_title, "value": best_value, "tied": tied}

func _initialize() -> void:
	var count: int = PuzzleCatalog.count()
	var entries: Array = []
	for i in range(count):
		var id: String = PuzzleCatalog.id_at(i)
		var title: String = PuzzleCatalog.title_at(i)
		var definition: PuzzleDefinition = PuzzleCatalog.get_definition(id)
		var result: Dictionary = PuzzleAnalyzer.analyze(definition)
		entries.append({"id": id, "title": title, "result": result})
		_print_entry(id, title, result)

	print("=== Catalog Comparison ===")

	var deepest: Dictionary = _winner(entries, func(e): return e.result.dependency_graph.depth)
	print("deepest dependency chain: ", deepest.id, " (depth=", deepest.value, ")",
		" (tie, first: " + deepest.id + ")" if deepest.tied else "")

	var fewest_legal: Dictionary = _winner(entries, func(e): return e.result.legal_move_structure.initial_legal_count, false)
	var fewest_legal_entry
	for entry in entries:
		if entry.id == fewest_legal.id:
			fewest_legal_entry = entry
	print("fewest initial legal arrows: ", fewest_legal.id, " (", fewest_legal.value, "/",
		fewest_legal_entry.result.board.arrow_count, ")")

	var widest_branching: Dictionary = _winner(entries, func(e): return e.result.legal_move_structure.max_legal)
	print("widest branching: ", widest_branching.id, " (", widest_branching.value, ")")

	var largest_cascade: Dictionary = _winner(entries, func(e): return e.result.dependency_graph.max_unlock_fan_out)
	print("largest cascade: ", largest_cascade.id, " (max_unlock_fan_out=", largest_cascade.value, ")")

	var longest_forced: Dictionary = _winner(entries, func(e): return e.result.legal_move_structure.longest_forced_run)
	print("longest forced run: ", longest_forced.id, " (", longest_forced.value, ")")

	var highest_density: Dictionary = _winner(entries, func(e): return e.result.board.density)
	print("highest density: ", highest_density.id, " (", _fmt2(highest_density.value), ")")

	var most_bends: Dictionary = _winner(entries, func(e): return e.result.geometry.total_bends)
	print("most bends: ", most_bends.id, " (", most_bends.value, ")")

	var longest_blocker: Dictionary = _winner(entries, func(e): return e.result.blocker_distance.max_distance)
	print("longest blocker distance: ", longest_blocker.id, " (", longest_blocker.value, ")")

	var largest_board: Dictionary = _winner(entries, func(e): return e.result.board.total_cells)
	var largest_entry
	for entry in entries:
		if entry.id == largest_board.id:
			largest_entry = entry
	print("largest board: ", largest_board.id, " (", largest_entry.result.board.width, "x",
		largest_entry.result.board.height, ", ", largest_board.value, " cells)")

	quit(0)
