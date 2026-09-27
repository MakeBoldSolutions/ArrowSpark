extends SceneTree
## Headless isolated-project check for PuzzleAnalyzer: no scene, font or
## GameVisualStyle dependency, since PuzzleAnalyzer depends only on
## PuzzleDefinition/PuzzleState/PuzzleSolver -- the same footprint
## PuzzleCatalog already has. Run via tests/run_puzzle_regressions.py in the
## same bare temp project as tests/puzzle_regression.gd/puzzle_catalog_check.gd.
##
## Every fixture below is a small, hand-constructed synthetic PuzzleDefinition
## whose expected PuzzleAnalyzer.analyze() values were derived by hand and are
## asserted exactly -- not "does not crash" but "returns precisely this."

var failures: int = 0

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func check_float(actual: float, expected: float, description: String) -> void:
	check(is_equal_approx(actual, expected) or (actual == 0.0 and expected == 0.0),
		"%s (expected %s, got %s)" % [description, expected, actual])

## Two fully independent single-cell arrows: zero dependency edges, each its
## own singleton component.
func _check_independent_pair() -> void:
	var d := PuzzleDefinition.Direction
	var definition := PuzzleDefinition.new(2, 1, {
		Vector2i(0, 0): d.LEFT,
		Vector2i(1, 0): d.RIGHT,
	})
	check(definition.is_valid(), "independent-pair fixture is structurally valid")
	var result: Dictionary = PuzzleAnalyzer.analyze(definition)

	check(result.valid and result.solvable, "independent pair: valid and solvable")
	check(result.board.width == 2 and result.board.height == 1, "independent pair: board dims")
	check(result.board.total_cells == 2 and result.board.arrow_count == 2 and result.board.occupied_cell_count == 2,
		"independent pair: board counts")
	check_float(result.board.density, 1.0, "independent pair: density")

	check(result.geometry.single_cell_count == 2 and result.geometry.multi_cell_count == 0,
		"independent pair: geometry cell counts")
	check(result.geometry.bent_arrow_count == 0 and result.geometry.total_bends == 0,
		"independent pair: no bends")

	var g: Dictionary = result.dependency_graph
	check(g.edge_count == 0 and g.depth == 0 and (g.longest_chain as Array).is_empty(),
		"independent pair: no dependency edges")
	check(g.max_in_degree == 0 and g.max_out_degree == 0, "independent pair: zero degrees")
	check(g.component_count == 2, "independent pair: two singleton components")
	check(g.max_unlock_fan_out == 0, "independent pair: no cascade")

	check(result.witness == [Vector2i(0, 0), Vector2i(1, 0)], "independent pair: witness order")
	check(result.legal_move_structure.legal_choice_sequence == ([2, 1] as Array[int]),
		"independent pair: legal-choice sequence")
	check(result.legal_move_structure.initial_legal_count == 2, "independent pair: initial legal count")
	check_float(result.legal_move_structure.initial_legal_ratio, 1.0, "independent pair: initial legal ratio")
	check(result.legal_move_structure.forced_state_count == 1 and result.legal_move_structure.branching_state_count == 1,
		"independent pair: forced/branching split")
	check(result.unlock_sequence == ([0, 0] as Array[int]), "independent pair: unlock sequence")

	check(result.blocker_distance.max_distance == 0 and (result.blocker_distance.edges as Array).is_empty(),
		"independent pair: no blocker-distance edges")

## A clean A blocks B blocks C chain (depth 2), the same archetype
## PuzzleCatalog's own dependency_chain puzzle already uses.
func _check_simple_three_arrow_chain() -> void:
	var d := PuzzleDefinition.Direction
	var a := Vector2i(2, 0)
	var b := Vector2i(2, 1)
	var c := Vector2i(0, 1)
	var definition := PuzzleDefinition.new(5, 3, {
		a: d.LEFT,
		b: d.UP,
		c: d.RIGHT,
	})
	check(definition.is_valid(), "simple chain fixture is structurally valid")
	var result: Dictionary = PuzzleAnalyzer.analyze(definition)

	var g: Dictionary = result.dependency_graph
	check(g.edge_count == 2, "simple chain: edge_count")
	check(g.depth == 2, "simple chain: depth")
	check(g.longest_chain == [a, b, c], "simple chain: longest_chain order")
	check(g.max_in_degree == 1 and g.max_out_degree == 1, "simple chain: single-link degrees")
	check(g.component_count == 1, "simple chain: one component")

	check(result.witness == [a, b, c], "simple chain: witness order")
	check(result.legal_move_structure.legal_choice_sequence == ([1, 1, 1] as Array[int]),
		"simple chain: fully forced sequence")
	check(result.legal_move_structure.forced_state_count == 3 and result.legal_move_structure.branching_state_count == 0,
		"simple chain: 100% forced")
	check(result.unlock_sequence == ([1, 1, 0] as Array[int]), "simple chain: unlock sequence")
	check(g.max_unlock_fan_out == 1, "simple chain: no cascade (fan-out 1)")

## A deep total-order chain realized positionally (each arrow blocked by
## every arrow already above it) -- the same archetype PuzzleCatalog's
## forced_sequence puzzle already uses, extended to depth 3.
func _check_deep_chain() -> void:
	var d := PuzzleDefinition.Direction
	var heads: Array[Vector2i] = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3)]
	var arrows: Dictionary = {}
	for head in heads:
		arrows[head] = d.UP
	var definition := PuzzleDefinition.new(1, 4, arrows)
	check(definition.is_valid(), "deep chain fixture is structurally valid")
	var result: Dictionary = PuzzleAnalyzer.analyze(definition)

	var g: Dictionary = result.dependency_graph
	check(g.edge_count == 6, "deep chain: complete-DAG edge_count over 4 nodes")
	check(g.depth == 3, "deep chain: depth 3")
	check(g.longest_chain == heads, "deep chain: longest_chain visits all 4 in order")
	check(g.max_in_degree == 3 and g.max_out_degree == 3, "deep chain: max degrees at the ends")
	check(g.component_count == 1, "deep chain: one component")

	check(result.witness == heads, "deep chain: witness matches topological order")
	check(result.legal_move_structure.legal_choice_sequence == ([1, 1, 1, 1] as Array[int]),
		"deep chain: fully forced")
	check(result.legal_move_structure.forced_state_count == 4 and result.legal_move_structure.longest_forced_run == 4,
		"deep chain: longest forced run spans the whole witness")
	check_float(result.legal_move_structure.initial_legal_ratio, 0.25, "deep chain: initial legal ratio")
	check(result.unlock_sequence == ([1, 1, 1, 0] as Array[int]), "deep chain: unlock sequence")
	check(g.max_unlock_fan_out == 1, "deep chain: no cascade")
	check(result.blocker_distance.max_distance == 3, "deep chain: max blocker distance")
	check_float(result.blocker_distance.average_distance, 10.0 / 6.0, "deep chain: average blocker distance")
	check((result.blocker_distance.edges as Array).size() == 6, "deep chain: one blocker-distance edge per ordered pair")

## Three fully independent arrows -- a genuine multi-state branching/open
## puzzle, distinct from the two-arrow independent case above by sustaining
## branching_state_count >= 2 across more than one state.
func _check_branching_open() -> void:
	var d := PuzzleDefinition.Direction
	var a := Vector2i(0, 0)
	var b := Vector2i(1, 0)
	var c := Vector2i(2, 0)
	var definition := PuzzleDefinition.new(3, 1, {a: d.LEFT, b: d.UP, c: d.RIGHT})
	check(definition.is_valid(), "branching/open fixture is structurally valid")
	var result: Dictionary = PuzzleAnalyzer.analyze(definition)

	check(result.dependency_graph.edge_count == 0, "branching/open: no edges")
	check(result.dependency_graph.component_count == 3, "branching/open: three singleton components")
	check(result.witness == [a, b, c], "branching/open: witness order")
	check(result.legal_move_structure.legal_choice_sequence == ([3, 2, 1] as Array[int]),
		"branching/open: sustained branching then forced tail")
	check(result.legal_move_structure.branching_state_count == 2 and result.legal_move_structure.forced_state_count == 1,
		"branching/open: two branching states, one forced")
	check(result.unlock_sequence == ([0, 0, 0] as Array[int]), "branching/open: nothing ever blocked")

## A single key arrow (K) whose removal simultaneously unblocks two others
## (X, Y) -- the "cascade" primitive absent from the baseline catalog. Proves
## max_unlock_fan_out is measured empirically (from unlock_sequence), not
## derived from K's static out-degree.
func _check_cascade() -> void:
	var d := PuzzleDefinition.Direction
	var k := Vector2i(1, 1)
	var x := Vector2i(1, 0)
	var y := Vector2i(0, 1)
	var definition := PuzzleDefinition.new(2, 2, {k: d.RIGHT, x: d.DOWN, y: d.RIGHT})
	check(definition.is_valid(), "cascade fixture is structurally valid")
	var result: Dictionary = PuzzleAnalyzer.analyze(definition)

	var g: Dictionary = result.dependency_graph
	check(g.edge_count == 2, "cascade: K blocks both X and Y")
	check(g.max_out_degree == 2 and g.max_in_degree == 1, "cascade: K's out-degree 2, X/Y's in-degree 1")
	check(g.depth == 1, "cascade: depth 1 (no chain beyond the key arrow)")
	check(g.longest_chain == [k, x], "cascade: deterministic tie-break picks [K, X] over [K, Y]")
	check(g.component_count == 1, "cascade: one component")

	check(result.witness == [k, x, y], "cascade: witness removes the key arrow first")
	check(result.legal_move_structure.legal_choice_sequence == ([1, 2, 1] as Array[int]),
		"cascade: forced -> branching -> forced rhythm")
	check(result.unlock_sequence == ([2, 0, 0] as Array[int]),
		"cascade: removing K unlocks exactly 2 arrows in the same step")
	check(g.max_unlock_fan_out == 2, "cascade: max_unlock_fan_out is 2, matching the empirical unlock, not out-degree misuse")

## One arrow (Z) blocked by two distinct blockers (P, Q) -- proves
## max_in_degree and contrasts directly with the cascade fixture: removing
## only one blocker must NOT unlock Z (fan-out stays 1, never a cascade).
func _check_multiple_blockers_on_one_arrow() -> void:
	var d := PuzzleDefinition.Direction
	var p := Vector2i(0, 1)
	var q := Vector2i(1, 1)
	var z := Vector2i(2, 1)
	var definition := PuzzleDefinition.new(3, 2, {p: d.UP, q: d.UP, z: d.LEFT})
	check(definition.is_valid(), "multi-blocker fixture is structurally valid")
	var result: Dictionary = PuzzleAnalyzer.analyze(definition)

	var g: Dictionary = result.dependency_graph
	check(g.edge_count == 2, "multi-blocker: both P and Q block Z")
	check(g.max_in_degree == 2, "multi-blocker: Z has two distinct blockers")
	check(g.max_out_degree == 1, "multi-blocker: P and Q each block only Z")
	check(g.longest_chain == [p, z], "multi-blocker: deterministic tie-break picks [P, Z] over [Q, Z]")

	check(result.witness == [p, q, z], "multi-blocker: witness order")
	check(result.legal_move_structure.legal_choice_sequence == ([2, 1, 1] as Array[int]),
		"multi-blocker: P and Q both legal initially")
	check(result.unlock_sequence == ([0, 1, 0] as Array[int]),
		"multi-blocker: removing only one blocker never unlocks Z (0), only removing the second does")
	check(g.max_unlock_fan_out == 1, "multi-blocker: never a cascade")

## A bent arrow (M) whose TAIL cell -- not its head -- is what blocks another
## arrow (N), at a non-adjacent ray distance. Proves dependency edges and
## blocker_distance both correctly attribute a tail cell.
func _check_bent_arrow_dependency() -> void:
	var d := PuzzleDefinition.Direction
	var m := Vector2i(1, 0)
	var n := Vector2i(2, 1)
	var definition := PuzzleDefinition.new(3, 2, {m: d.RIGHT, n: d.LEFT}, {m: [Vector2i(0, 0), Vector2i(0, 1)]})
	check(definition.is_valid(), "bent-arrow fixture is structurally valid")
	check(definition.get_arrow_cells(m).size() == 3, "bent-arrow fixture: M has a 2-cell bent tail")
	var result: Dictionary = PuzzleAnalyzer.analyze(definition)

	check(result.geometry.bent_arrow_count == 1 and result.geometry.total_bends == 1,
		"bent-arrow: exactly one bend on M")
	check(result.dependency_graph.edge_count == 1, "bent-arrow: single M->N edge")
	check(result.dependency_graph.longest_chain == [m, n], "bent-arrow: longest_chain is [M, N]")

	var edges: Array = result.blocker_distance.edges
	check(edges.size() == 1, "bent-arrow: exactly one blocker-distance edge")
	check(edges[0]["blocked"] == n and edges[0]["blocker"] == m and edges[0]["distance"] == 2,
		"bent-arrow: N is blocked by M's tail cell at ray distance 2 (not the adjacent cell)")

	check(result.witness == [m, n], "bent-arrow: witness order")
	check(result.unlock_sequence == ([1, 0] as Array[int]), "bent-arrow: removing M unlocks N")

## An arrow blocked by a cell far along its forward ray (distance 5, nowhere
## near the immediately adjacent cell), on a board wide enough for that
## distance to be real.
func _check_long_range_blocker() -> void:
	var d := PuzzleDefinition.Direction
	var target := Vector2i(0, 0)
	var blocker := Vector2i(5, 0)
	var definition := PuzzleDefinition.new(6, 1, {target: d.RIGHT, blocker: d.UP})
	check(definition.is_valid(), "long-range-blocker fixture is structurally valid")
	var result: Dictionary = PuzzleAnalyzer.analyze(definition)

	check(result.dependency_graph.edge_count == 1, "long-range: single edge")
	check(result.dependency_graph.longest_chain == [blocker, target], "long-range: longest_chain is [Blocker, Target]")

	var edges: Array = result.blocker_distance.edges
	check(edges.size() == 1 and edges[0]["distance"] == 5,
		"long-range: blocker sits at ray distance 5, far past the adjacent cell")
	check(result.blocker_distance.max_distance == 5, "long-range: max_distance is 5")

	check(result.witness == [blocker, target], "long-range: witness removes the blocker first")
	check(result.unlock_sequence == ([1, 0] as Array[int]), "long-range: removing the blocker unlocks the target")

## A structurally invalid definition (two arrows whose shapes overlap) must
## report every field as zero/empty except board/geometry, which are still
## computed from raw structural data -- consistent with
## PuzzleSolver.analyze()'s own "invalid input yields every metric at zero."
func _check_invalid_input() -> void:
	var d := PuzzleDefinition.Direction
	var invalid := PuzzleDefinition.new(2, 2,
		{Vector2i(0, 0): d.RIGHT, Vector2i(0, 1): d.DOWN},
		{Vector2i(0, 1): [Vector2i(0, 0)]})
	check(not invalid.is_valid(), "invalid-input fixture is indeed structurally invalid")
	var result: Dictionary = PuzzleAnalyzer.analyze(invalid)

	check(not result.valid and not result.solvable, "invalid input: reported invalid, not unsolvable")
	check(result.board.width == 2 and result.board.height == 2 and result.board.total_cells == 4,
		"invalid input: board dimensions still computed from raw fields")
	check(result.board.arrow_count == 2, "invalid input: arrow_count still computed")
	check(result.board.occupied_cell_count == 2, "invalid input: occupied_cell_count still computed despite the overlap")

	check(result.legal_move_structure.initial_legal_count == 0, "invalid input: legal_move_structure zeroed")
	check((result.witness as Array).is_empty(), "invalid input: witness empty")
	check((result.unlock_sequence as Array).is_empty(), "invalid input: unlock_sequence empty")
	check(result.dependency_graph.edge_count == 0, "invalid input: dependency_graph entirely zeroed, not computed over ill-formed ownership")
	check((result.blocker_distance.edges as Array).is_empty(), "invalid input: blocker_distance entirely zeroed")

## Edge case: a valid but unsolvable two-arrow facing cycle. Cell ownership
## is well-formed here (unlike the invalid case above), so
## dependency_graph/blocker_distance ARE computed, while
## legal_move_structure/witness/unlock_sequence stay empty since no complete
## witness exists.
func _check_unsolvable_cycle() -> void:
	var d := PuzzleDefinition.Direction
	var a := Vector2i(0, 0)
	var b := Vector2i(1, 0)
	var cycle := PuzzleDefinition.new(2, 1, {a: d.RIGHT, b: d.LEFT})
	check(cycle.is_valid(), "two-arrow facing cycle is a structurally valid definition")
	var result: Dictionary = PuzzleAnalyzer.analyze(cycle)

	check(result.valid and not result.solvable, "unsolvable cycle: valid but unsolvable")
	var g: Dictionary = result.dependency_graph
	check(g.edge_count == 2, "unsolvable cycle: two directed edges (A->B and B->A)")
	check(g.max_in_degree == 1 and g.max_out_degree == 1, "unsolvable cycle: mutual single-edge degrees")
	check(g.depth == 1, "unsolvable cycle: longest SIMPLE path has length 1 (cannot revisit a node)")
	check(g.longest_chain == [a, b], "unsolvable cycle: deterministic tie-break picks [A, B] over [B, A]")
	check(g.component_count == 1, "unsolvable cycle: one component")

	check(result.blocker_distance.max_distance == 1, "unsolvable cycle: adjacent mutual block, distance 1")
	check((result.blocker_distance.edges as Array).size() == 2, "unsolvable cycle: one blocker-distance edge per direction")

	check(result.legal_move_structure.initial_legal_count == 0, "unsolvable cycle: legal_move_structure zeroed")
	check((result.witness as Array).is_empty(), "unsolvable cycle: witness empty (never partial)")
	check((result.unlock_sequence as Array).is_empty(), "unsolvable cycle: unlock_sequence empty")

## A mixed graph -- a clean 3-arrow simple chain plus a fully disconnected
## 2-arrow cycle -- proving both that the longest-simple-path search
## terminates for a cyclic component and that its documented semantic (see
## PuzzleAnalyzer's own "longest simple directed path" doc comment) produces
## this EXACT value, not merely "does not hang."
func _check_mixed_acyclic_and_cyclic_components() -> void:
	var d := PuzzleDefinition.Direction
	var a := Vector2i(0, 0)
	var b := Vector2i(0, 1)
	var c := Vector2i(0, 2)
	# Chain lives in column x=0 (rows 0-2, facing UP, same construction as
	# _check_deep_chain but only 3 deep here) -- its rays only ever move along
	# y, staying in column 0. The cycle lives in a fully separate column
	# (x=2), facing DOWN/UP so its rays only ever move along y too, staying in
	# column 2 -- neither ray set ever crosses into the other's column, so the
	# two groups are genuinely disconnected (unlike a horizontal LEFT/RIGHT
	# facing pair here, whose ray would run the full row and reach column 0).
	var cycle_d := Vector2i(2, 0)
	var cycle_e := Vector2i(2, 1)
	var definition := PuzzleDefinition.new(3, 3, {
		a: d.UP, b: d.UP, c: d.UP,
		cycle_d: d.DOWN, cycle_e: d.UP,
	})
	check(definition.is_valid(), "mixed acyclic+cyclic fixture is structurally valid")
	var result: Dictionary = PuzzleAnalyzer.analyze(definition)

	check(not result.solvable, "mixed fixture: the D/E cycle makes the whole board unsolvable")
	var g: Dictionary = result.dependency_graph
	check(g.depth == 2, "mixed fixture: depth is realized by the acyclic A->B->C chain, not the cycle")
	check(g.longest_chain == [a, b, c], "mixed fixture: longest_chain is exactly [A, B, C]")
	check(g.component_count == 2, "mixed fixture: the chain and the cycle are separate components")

## Repeated calls against the same definition are deterministic (deep-equal),
## and analysis never mutates the supplied definition.
func _check_determinism_and_non_mutation() -> void:
	var d := PuzzleDefinition.Direction
	var a := Vector2i(2, 0)
	var b := Vector2i(2, 1)
	var c := Vector2i(0, 1)
	var definition := PuzzleDefinition.new(5, 3, {a: d.LEFT, b: d.UP, c: d.RIGHT})
	var arrows_before: Dictionary = definition.duplicate_arrows()
	var tails_before: Dictionary = definition.duplicate_tails()
	var width_before: int = definition.width
	var height_before: int = definition.height

	var first: Dictionary = PuzzleAnalyzer.analyze(definition)
	var second: Dictionary = PuzzleAnalyzer.analyze(definition)
	check(first == second, "determinism: repeated analyze() calls are deep-equal")

	check(definition.duplicate_arrows() == arrows_before and definition.duplicate_tails() == tails_before,
		"non-mutation: definition's arrows/tails are unchanged after analysis")
	check(definition.width == width_before and definition.height == height_before,
		"non-mutation: definition's dimensions are unchanged after analysis")

	# Interleave analysis with a real, separate, live gameplay attempt on the
	# same definition: analysis must not read or be affected by it, and vice
	# versa (live-PuzzleState isolation).
	var live_state := PuzzleState.new(definition)
	live_state.select_arrow(a)
	var third: Dictionary = PuzzleAnalyzer.analyze(definition)
	check(third == first, "non-mutation: a live gameplay PuzzleState built from the same definition does not affect analysis")
	check(live_state.remaining() == 2, "non-mutation: the live attempt's own state is unaffected by analysis")

## A null definition is a caller programming error. Empirically verified: the
## failed assert aborts analyze() before its `return` statement, so the
## statically-typed function yields an empty Dictionary rather than a
## well-formed result or a crash.
func _check_null_definition_precondition() -> void:
	var result: Dictionary = PuzzleAnalyzer.analyze(null)
	check(not result.has("valid"),
		"null definition: the documented assert() precondition fires, yielding an empty result rather than a normal analysis")

func _check_occupancy_grid() -> void:
	var d := PuzzleDefinition.Direction
	var definition := PuzzleDefinition.new(3, 2, {Vector2i(0, 0): d.RIGHT, Vector2i(2, 1): d.LEFT})
	var grid: Array[String] = PuzzleAnalyzer.occupancy_grid(definition)
	check(grid.size() == 2, "occupancy grid: one row per board height")
	check(grid[0].length() == 3 and grid[1].length() == 3, "occupancy grid: one column per board width")
	check(grid[0] == "#.." and grid[1] == "..#", "occupancy grid: '#' marks occupied cells, '.' marks empty ones")

func _initialize() -> void:
	_check_independent_pair()
	_check_simple_three_arrow_chain()
	_check_deep_chain()
	_check_branching_open()
	_check_cascade()
	_check_multiple_blockers_on_one_arrow()
	_check_bent_arrow_dependency()
	_check_long_range_blocker()
	_check_invalid_input()
	_check_unsolvable_cycle()
	_check_mixed_acyclic_and_cyclic_components()
	_check_determinism_and_non_mutation()
	_check_null_definition_precondition()
	_check_occupancy_grid()
	print("PUZZLE_ANALYZER_FAILURES=", failures)
	quit(1 if failures else 0)
