class_name PuzzleAnalyzer
extends RefCounted
## Headless, deterministic structural-analysis capability over PuzzleDefinition,
## sibling to PuzzleSolver. Never a second rules engine: every blocking fact is
## derived from PuzzleDefinition.forward_ray_cells/get_cell_owners (for the
## static dependency graph) or from a disposable internal PuzzleState reusing
## PuzzleState.is_blocked/select_arrow directly (for the witness walk) -- the
## same authoritative rule evaluation PuzzleSolver.analyze() itself relies on.
##
## analyze() never mutates the supplied definition, never touches a live
## gameplay PuzzleState, and never reads/writes PuzzleSession. It does not
## depend on scenes, Nodes, Controls, or any presentation concept.

## definition MUST be non-null: a null definition is a caller programming
## error, not a data-quality case -- matches PuzzleState._init()'s own
## assert()-based precondition style rather than returning a "valid: false"
## result for a case that was never a real PuzzleDefinition at all.
static func analyze(definition: PuzzleDefinition) -> Dictionary:
	assert(definition != null, "PuzzleAnalyzer.analyze() requires a non-null PuzzleDefinition")

	var validation_errors: Array[String] = definition.get_validation_errors()
	var board: Dictionary = _compute_board(definition)
	var geometry: Dictionary = _compute_geometry(definition)

	if not validation_errors.is_empty():
		return {
			"valid": false,
			"solvable": false,
			"board": board,
			"geometry": geometry,
			"legal_move_structure": _empty_legal_move_structure(),
			"witness": [] as Array[Vector2i],
			"dependency_graph": _empty_dependency_graph(),
			"unlock_sequence": [] as Array[int],
			"blocker_distance": _empty_blocker_distance(),
		}

	var owners: Dictionary = definition.get_cell_owners()
	var dependency_graph: Dictionary = _compute_dependency_graph(definition, owners)
	var blocker_distance: Dictionary = _compute_blocker_distance(definition, owners)

	var solver_result: Dictionary = PuzzleSolver.analyze(definition)
	var solvable: bool = solver_result["solvable"]
	var witness: Array[Vector2i] = solver_result["witness"]

	var legal_move_structure: Dictionary
	var unlock_sequence: Array[int] = []
	if solvable:
		var walk: Dictionary = _walk_witness(definition, witness)
		legal_move_structure = walk["legal_move_structure"]
		unlock_sequence = walk["unlock_sequence"]
	else:
		legal_move_structure = _empty_legal_move_structure()

	dependency_graph["max_unlock_fan_out"] = 0 if unlock_sequence.is_empty() else unlock_sequence.max()

	return {
		"valid": true,
		"solvable": solvable,
		"board": board,
		"geometry": geometry,
		"legal_move_structure": legal_move_structure,
		"witness": witness,
		"dependency_graph": dependency_graph,
		"unlock_sequence": unlock_sequence,
		"blocker_distance": blocker_distance,
	}

## Developer-only occupancy/grid visualization: one string per board
## row, '#' for an occupied cell and '.' for empty. Never a second
## puzzle-authoring format -- purely a read-only view for shape inspection.
static func occupancy_grid(definition: PuzzleDefinition) -> Array[String]:
	var owners: Dictionary = definition.get_cell_owners()
	var rows: Array[String] = []
	for y in range(definition.height):
		var row := ""
		for x in range(definition.width):
			row += "#" if owners.has(Vector2i(x, y)) else "."
		rows.append(row)
	return rows

# --- Board / geometry (safe even for a structurally invalid definition) ----

static func _compute_board(definition: PuzzleDefinition) -> Dictionary:
	var width: int = definition.width
	var height: int = definition.height
	var total_cells: int = width * height
	var arrow_count: int = definition.arrows.size()
	var occupied_cell_count: int = definition.get_cell_owners().size()
	var density: float = 0.0
	if total_cells > 0:
		density = float(occupied_cell_count) / float(total_cells)
	return {
		"width": width,
		"height": height,
		"total_cells": total_cells,
		"arrow_count": arrow_count,
		"occupied_cell_count": occupied_cell_count,
		"density": density,
	}

static func _compute_geometry(definition: PuzzleDefinition) -> Dictionary:
	var single_cell_count := 0
	var multi_cell_count := 0
	var total_length := 0
	var max_length := 0
	var bent_arrow_count := 0
	var total_bends := 0
	var max_bends := 0
	var arrow_count: int = definition.arrows.size()

	for head in definition.arrows.keys():
		var tail: Array = definition.tails.get(head, [])
		var length: int = 1 + tail.size()
		total_length += length
		if length > max_length:
			max_length = length
		if tail.is_empty():
			single_cell_count += 1
		else:
			multi_cell_count += 1
		var bends: int = _count_bends(head, tail)
		if bends > 0:
			bent_arrow_count += 1
		total_bends += bends
		if bends > max_bends:
			max_bends = bends

	var average_length: float = 0.0
	var average_bends: float = 0.0
	if arrow_count > 0:
		average_length = float(total_length) / float(arrow_count)
		average_bends = float(total_bends) / float(arrow_count)

	return {
		"single_cell_count": single_cell_count,
		"multi_cell_count": multi_cell_count,
		"average_length": average_length,
		"max_length": max_length,
		"bent_arrow_count": bent_arrow_count,
		"total_bends": total_bends,
		"average_bends_per_arrow": average_bends,
		"max_bends_on_one_arrow": max_bends,
	}

## A bend is any direction change along the tail path, starting from the
## head-to-tail[0] segment (itself fixed by validation to be opposite the
## arrow's own facing direction) through each subsequent tail-to-tail step.
## A straight or single-cell arrow has zero bends by construction.
static func _count_bends(head: Vector2i, tail: Array) -> int:
	if tail.size() < 2:
		return 0
	var previous_direction: Vector2i = tail[0] - head
	var previous: Vector2i = tail[0]
	var bends := 0
	for i in range(1, tail.size()):
		var current: Vector2i = tail[i]
		var segment: Vector2i = current - previous
		if segment != previous_direction:
			bends += 1
		previous_direction = segment
		previous = current
	return bends

# --- Dependency graph (static, geometric, initial-state only) --------------

## Orientation: edge A -> B means "A blocks B" (A occupies a cell on B's
## forward escape ray), matching PuzzleState._is_head_blocked exactly. Derived
## solely from PuzzleDefinition.forward_ray_cells/get_cell_owners -- this is
## the initial-state graph for ALL arrows, which is exactly what a fresh
## PuzzleState's active set already is, so no PuzzleState instance is needed
## for this part.
static func _compute_dependency_graph(definition: PuzzleDefinition, owners: Dictionary) -> Dictionary:
	var heads: Array = definition.arrows.keys()
	heads.sort_custom(_head_less_than)

	var out_neighbors: Dictionary = {}
	var in_degree: Dictionary = {}
	var out_degree: Dictionary = {}
	var undirected: Dictionary = {}
	for head in heads:
		out_neighbors[head] = []
		in_degree[head] = 0
		out_degree[head] = 0
		undirected[head] = []

	var edge_count := 0
	for head in heads:
		var direction = definition.arrows[head]
		for ray_cell in definition.forward_ray_cells(head, direction):
			var owner = owners.get(ray_cell)
			if owner != null and owner != head:
				var out_list: Array = out_neighbors[owner]
				if not out_list.has(head):
					out_list.append(head)
					out_degree[owner] += 1
					in_degree[head] += 1
					edge_count += 1
					(undirected[owner] as Array).append(head)
					(undirected[head] as Array).append(owner)

	var max_in_degree := 0
	var max_out_degree := 0
	for head in heads:
		if int(in_degree[head]) > max_in_degree:
			max_in_degree = in_degree[head]
		if int(out_degree[head]) > max_out_degree:
			max_out_degree = out_degree[head]

	var component_count: int = _count_components(heads, undirected)
	var longest: Dictionary = _longest_simple_path(heads, out_neighbors)

	return {
		"edge_count": edge_count,
		"depth": longest["depth"],
		"longest_chain": longest["chain"],
		"max_in_degree": max_in_degree,
		"max_out_degree": max_out_degree,
		"component_count": component_count,
		"max_unlock_fan_out": 0, # overwritten by analyze() from the empirical unlock_sequence
	}

static func _count_components(heads: Array, undirected: Dictionary) -> int:
	if heads.is_empty():
		return 0
	var parent: Dictionary = {}
	for head in heads:
		parent[head] = head
	for head in heads:
		for neighbor in (undirected[head] as Array):
			_union(parent, head, neighbor)
	var roots: Dictionary = {}
	for head in heads:
		roots[_find(parent, head)] = true
	return roots.size()

static func _find(parent: Dictionary, x: Vector2i) -> Vector2i:
	while parent[x] != x:
		x = parent[x]
	return x

static func _union(parent: Dictionary, a: Vector2i, b: Vector2i) -> void:
	var root_a: Vector2i = _find(parent, a)
	var root_b: Vector2i = _find(parent, b)
	if root_a != root_b:
		parent[root_a] = root_b

## depth/longest_chain semantics (see data-model.md "Depth / Longest-Chain
## Semantics"): the longest SIMPLE directed path (no repeated node) in the
## graph, always finite even when a geometric cycle exists, since a per-path
## visited set forbids revisiting a node already on the current path. Ties
## are broken deterministically by the lexicographically smallest head
## sequence under PuzzleSolver.analyze()'s own (y, x)-ascending comparator --
## this is an analysis-only capability over a *candidate* definition; it never
## implies the definition is solvable or catalog-eligible.
## Deepest dependency chain, ties broken by the (y, x) head ordering. When the
## dependency graph is acyclic (every solvable definition) the chain is found by
## dynamic programming in time linear in the number of edges, because the
## exhaustive simple-path search below grows exponentially with edge count and
## cannot finish on dense boards. A graph with a cycle keeps that exhaustive
## search, so its results are unchanged.
static func _longest_simple_path(heads: Array, out_neighbors: Dictionary) -> Dictionary:
	var order: Array = _topological_order(heads, out_neighbors)
	if order.size() != heads.size():
		return _longest_simple_path_search(heads, out_neighbors)
	var best_chain: Dictionary = {} # head -> deepest chain starting at that head
	for i in range(order.size() - 1, -1, -1):
		var head: Vector2i = order[i]
		var chain: Array[Vector2i] = [head]
		for neighbor in (out_neighbors[head] as Array):
			var candidate: Array[Vector2i] = [head]
			candidate.append_array(best_chain[neighbor])
			if candidate.size() > chain.size() or (candidate.size() == chain.size() and _chain_less_than(candidate, chain)):
				chain = candidate
		best_chain[head] = chain
	var result: Dictionary = {"depth": 0, "chain": [] as Array[Vector2i]}
	for head in heads:
		var chain: Array[Vector2i] = best_chain[head]
		var depth: int = chain.size() - 1
		if depth >= 1 and (depth > int(result["depth"]) or (depth == int(result["depth"]) and _chain_less_than(chain, result["chain"]))):
			result["depth"] = depth
			result["chain"] = chain
	return result

## Kahn's algorithm. Returns every head in dependency order, or fewer than all
## of them when the graph contains a cycle.
static func _topological_order(heads: Array, out_neighbors: Dictionary) -> Array:
	var remaining_in: Dictionary = {}
	for head in heads:
		remaining_in[head] = 0
	for head in heads:
		for neighbor in (out_neighbors[head] as Array):
			remaining_in[neighbor] += 1
	var queue: Array = []
	for head in heads:
		if int(remaining_in[head]) == 0:
			queue.append(head)
	var order: Array = []
	var index := 0
	while index < queue.size():
		var head: Vector2i = queue[index]
		index += 1
		order.append(head)
		for neighbor in (out_neighbors[head] as Array):
			remaining_in[neighbor] -= 1
			if int(remaining_in[neighbor]) == 0:
				queue.append(neighbor)
	return order

## Exhaustive longest simple directed path; exponential in general, kept for
## graphs with a cycle and as the reference the acyclic shortcut is checked
## against.
static func _longest_simple_path_search(heads: Array, out_neighbors: Dictionary) -> Dictionary:
	var result: Dictionary = {"depth": 0, "chain": [] as Array[Vector2i]}
	for start in heads:
		var visited: Dictionary = {start: true}
		var path: Array[Vector2i] = [start]
		_dfs_extend(start, out_neighbors, visited, path, result)
	return result

static func _dfs_extend(current: Vector2i, out_neighbors: Dictionary, visited: Dictionary, path: Array[Vector2i], result: Dictionary) -> void:
	var current_depth: int = path.size() - 1
	if current_depth >= 1:
		if current_depth > int(result["depth"]) or (current_depth == int(result["depth"]) and _chain_less_than(path, result["chain"])):
			result["depth"] = current_depth
			result["chain"] = path.duplicate()
	for neighbor in (out_neighbors[current] as Array):
		if not visited.has(neighbor):
			visited[neighbor] = true
			path.append(neighbor)
			_dfs_extend(neighbor, out_neighbors, visited, path, result)
			path.remove_at(path.size() - 1)
			visited.erase(neighbor)

static func _chain_less_than(a: Array, b: Array) -> bool:
	var n: int = min(a.size(), b.size())
	for i in range(n):
		var head_a: Vector2i = a[i]
		var head_b: Vector2i = b[i]
		if head_a == head_b:
			continue
		return _head_less_than(head_a, head_b)
	return a.size() < b.size()

## The same (y, x)-ascending comparator PuzzleSolver.analyze() already uses to
## pick a legal head deterministically -- reused here, not reinvented, so both
## the solver's witness and the analyzer's tie-break agree on one ordering.
static func _head_less_than(a: Vector2i, b: Vector2i) -> bool:
	return a.y < b.y or (a.y == b.y and a.x < b.x)

# --- Blocker distance (static, geometric, initial-state only) --------------

## One entry per directed blocking pair (matching dependency_graph.edge_count
## exactly): distance is the 1-based index of that specific blocker's NEAREST
## occupied cell within the blocked arrow's forward_ray_cells. An explicitly
## labeled geometric proxy for "how far away is this," never a validated
## measurement of human perception.
static func _compute_blocker_distance(definition: PuzzleDefinition, owners: Dictionary) -> Dictionary:
	var heads: Array = definition.arrows.keys()
	heads.sort_custom(_head_less_than)

	var edges: Array = []
	var max_distance := 0
	var total_distance := 0
	var count := 0

	for head in heads:
		var direction = definition.arrows[head]
		var ray: Array = definition.forward_ray_cells(head, direction)
		var nearest_by_blocker: Dictionary = {}
		for i in range(ray.size()):
			var cell: Vector2i = ray[i]
			var owner = owners.get(cell)
			if owner != null and owner != head and not nearest_by_blocker.has(owner):
				nearest_by_blocker[owner] = i + 1

		var blockers: Array = nearest_by_blocker.keys()
		blockers.sort_custom(_head_less_than)
		for blocker in blockers:
			var distance: int = nearest_by_blocker[blocker]
			edges.append({"blocked": head, "blocker": blocker, "distance": distance})
			total_distance += distance
			count += 1
			if distance > max_distance:
				max_distance = distance

	var average_distance: float = 0.0
	if count > 0:
		average_distance = float(total_distance) / float(count)

	return {"max_distance": max_distance, "average_distance": average_distance, "edges": edges}

# --- Legal-move structure + cascade/unlock (witness-derived) ---------------

## Walks a disposable internal PuzzleState step-by-step through the solver's
## own witness, querying is_blocked exactly as PuzzleSolver/gameplay already
## do -- never a reimplemented legality check. Measures, per step, how many
## arrows were legal before the removal (legal-choice sequence) and how many
## previously-blocked arrows become newly legal immediately after it
## (unlock_sequence / cascade detection).
static func _walk_witness(definition: PuzzleDefinition, witness: Array) -> Dictionary:
	var state := PuzzleState.new(definition)
	var arrow_count: int = definition.arrows.size()

	var legal_choice_sequence: Array[int] = []
	var unlock_sequence: Array[int] = []
	var forced_state_count := 0
	var branching_state_count := 0
	var sum_legal := 0
	var min_legal := -1
	var max_legal := 0
	var longest_forced_run := 0
	var current_forced_run := 0
	var initial_legal_count := 0
	var first := true

	for head in witness:
		var active_heads: Array = (state.get_snapshot()["active_arrows"] as Dictionary).keys()

		var legal_count := 0
		var previously_blocked: Dictionary = {}
		for h in active_heads:
			var blocked: bool = state.is_blocked(h)
			if not blocked:
				legal_count += 1
			elif h != head:
				previously_blocked[h] = true

		legal_choice_sequence.append(legal_count)
		sum_legal += legal_count
		if min_legal == -1 or legal_count < min_legal:
			min_legal = legal_count
		if legal_count > max_legal:
			max_legal = legal_count
		if legal_count == 1:
			forced_state_count += 1
			current_forced_run += 1
			if current_forced_run > longest_forced_run:
				longest_forced_run = current_forced_run
		else:
			branching_state_count += 1
			current_forced_run = 0
		if first:
			initial_legal_count = legal_count
			first = false

		state.select_arrow(head)

		var newly_legal := 0
		for h in previously_blocked.keys():
			if not state.is_blocked(h):
				newly_legal += 1
		unlock_sequence.append(newly_legal)

	var states_examined: int = witness.size()
	var average_legal: float = 0.0
	var forced_ratio: float = 0.0
	var branching_ratio: float = 0.0
	if states_examined > 0:
		average_legal = float(sum_legal) / float(states_examined)
		forced_ratio = float(forced_state_count) / float(states_examined)
		branching_ratio = float(branching_state_count) / float(states_examined)
	var initial_legal_ratio: float = 0.0
	if arrow_count > 0:
		initial_legal_ratio = float(initial_legal_count) / float(arrow_count)

	return {
		"legal_move_structure": {
			"initial_legal_count": initial_legal_count,
			"initial_legal_ratio": initial_legal_ratio,
			"min_legal": max(min_legal, 0),
			"max_legal": max_legal,
			"average_legal": average_legal,
			"forced_state_count": forced_state_count,
			"forced_state_ratio": forced_ratio,
			"branching_state_count": branching_state_count,
			"branching_state_ratio": branching_ratio,
			"longest_forced_run": longest_forced_run,
			"legal_choice_sequence": legal_choice_sequence,
		},
		"unlock_sequence": unlock_sequence,
	}

# --- Zeroed shapes for invalid / unsolvable input ---------------------------

static func _empty_legal_move_structure() -> Dictionary:
	return {
		"initial_legal_count": 0,
		"initial_legal_ratio": 0.0,
		"min_legal": 0,
		"max_legal": 0,
		"average_legal": 0.0,
		"forced_state_count": 0,
		"forced_state_ratio": 0.0,
		"branching_state_count": 0,
		"branching_state_ratio": 0.0,
		"longest_forced_run": 0,
		"legal_choice_sequence": [] as Array[int],
	}

static func _empty_dependency_graph() -> Dictionary:
	return {
		"edge_count": 0,
		"depth": 0,
		"longest_chain": [] as Array[Vector2i],
		"max_in_degree": 0,
		"max_out_degree": 0,
		"component_count": 0,
		"max_unlock_fan_out": 0,
	}

static func _empty_blocker_distance() -> Dictionary:
	return {"max_distance": 0, "average_distance": 0.0, "edges": []}
