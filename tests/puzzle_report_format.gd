class_name PuzzleReportFormat
extends RefCounted
## Shared printer for one level's structural-report entry, used by the
## developer structural report and the pack-build tool so both print the
## same facts the same way. Prints facts from PuzzleAnalyzer.analyze() only.

static func fmt2(value: float) -> String:
	return "%.2f" % value

static func print_entry(id: String, title: String, r: Dictionary) -> void:
	var board: Dictionary = r.board
	var geometry: Dictionary = r.geometry
	var legal: Dictionary = r.legal_move_structure
	var g: Dictionary = r.dependency_graph
	var blocker: Dictionary = r.blocker_distance

	print("[", id, "] ", title)
	print("  status: valid=", r.valid, " solvable=", r.solvable)
	print("  board: ", board.width, "x", board.height, "  density=", fmt2(board.density), "  arrows=", board.arrow_count,
		" occupied=", board.occupied_cell_count)
	print("  geometry: single=", geometry.single_cell_count, " multi=", geometry.multi_cell_count,
		" bends_total=", geometry.total_bends, " max_bends=", geometry.max_bends_on_one_arrow,
		" max_length=", geometry.max_length, " avg_length=", fmt2(geometry.average_length))
	print("  legal: initial=", legal.initial_legal_count, "/", board.arrow_count,
		" (", fmt2(legal.initial_legal_ratio), ") forced=", legal.forced_state_count,
		" branching=", legal.branching_state_count, " longest_forced_run=", legal.longest_forced_run)
	print("  legal_choice_sequence: ", ",".join((legal.legal_choice_sequence as Array).map(func(x): return str(x))))
	print("  dependency: edges=", g.edge_count, " depth=", g.depth, " max_in_degree=", g.max_in_degree,
		" components=", g.component_count)
	print("  cascade: max_unlock_fan_out=", g.max_unlock_fan_out, " unlock_sequence: ",
		",".join((r.unlock_sequence as Array).map(func(x): return str(x))))
	print("  blocker_distance: max=", blocker.max_distance, " avg=", fmt2(blocker.average_distance))
	print("  witness_xy: ", ";".join((r.witness as Array).map(func(head): return "%d,%d" % [head.x, head.y])))
