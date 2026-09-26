class_name PuzzleSolver
extends RefCounted
## Presentation-independent solvability analysis. Reuses PuzzleState's own
## rules (is_blocked/select_arrow) on a fresh state built from the given
## definition, so the solver can never consider a move legal that gameplay
## would reject, or vice versa; it never mutates the caller's definition or
## any live attempt.
##
## Monotonicity: removal only deletes occupied cells, never adds any, and an
## arrow's legality is a monotone function of the active occupancy set (fewer
## occupied cells never makes an arrow more blocked). Consequently, if a
## complete removal order exists, picking ANY currently-legal arrow first and
## recursing still reaches a complete order for the rest — a standard
## exchange argument for monotone removal systems, the same reasoning behind
## topological-sort-style algorithms. This is why one deterministic
## traversal that greedily removes a legal arrow at a time, with no
## backtracking, is sufficient: at every state, if a solution exists, every
## legal move leads to a still-solvable residual state, so no legal choice
## can strand the search. This proof depends on removal staying strictly
## monotonic; it would need reconsideration if a future rule ever let a
## removal re-occupy a cell or otherwise change another arrow's blocking
## geometry.

## Validates first; for a valid definition, walks a fresh PuzzleState,
## repeatedly removing the (y, x)-ascending-first legal head until either no
## arrow remains (a complete witness) or no legal head remains among the
## rest (no complete solution). Never enumerates more than one witness.
static func analyze(definition: PuzzleDefinition) -> Dictionary:
	var validation_errors: Array[String] = definition.get_validation_errors()
	var metrics: Dictionary = {
		"states_examined": 0,
		"active_choices_encountered": 0,
		"legal_choices_encountered": 0,
		"forced_states": 0,
		"branching_states": 0,
		"no_move_states": 0,
	}
	if not validation_errors.is_empty():
		return {
			"valid": false,
			"solvable": false,
			"witness": [] as Array[Vector2i],
			"validation_errors": validation_errors,
			"metrics": metrics,
		}

	var state := PuzzleState.new(definition)
	var witness: Array[Vector2i] = []

	while state.remaining() > 0:
		var active_heads: Array = state.get_snapshot()["active_arrows"].keys()
		active_heads.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
			return a.y < b.y or (a.y == b.y and a.x < b.x)
		)

		var legal_heads: Array = []
		for head in active_heads:
			if not state.is_blocked(head):
				legal_heads.append(head)

		# Every nonempty state visited is counted once, here, before the
		# selection below changes it — including the final stuck state on an
		# unsolvable board. The cleared (empty) terminal is never counted,
		# since the loop condition above simply stops visiting it.
		metrics["states_examined"] += 1
		metrics["active_choices_encountered"] += active_heads.size()
		metrics["legal_choices_encountered"] += legal_heads.size()
		if legal_heads.is_empty():
			metrics["no_move_states"] += 1
		elif legal_heads.size() == 1:
			metrics["forced_states"] += 1
		else:
			metrics["branching_states"] += 1

		if legal_heads.is_empty():
			return {
				"valid": true,
				"solvable": false,
				"witness": [] as Array[Vector2i],
				"validation_errors": [] as Array[String],
				"metrics": metrics,
			}

		state.select_arrow(legal_heads[0])
		witness.append(legal_heads[0])

	return {
		"valid": true,
		"solvable": true,
		"witness": witness,
		"validation_errors": [] as Array[String],
		"metrics": metrics,
	}
