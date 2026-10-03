extends SceneTree
## Headless isolated-project check for PuzzleCatalog and PuzzleSession: no
## scene, font or GameVisualStyle dependency, since PuzzleCatalog depends
## only on PuzzleDefinition (and, here, PuzzleSolver/PuzzleState to replay
## each entry's witness). Run via tests/run_puzzle_regressions.py in the
## same bare temp project as tests/puzzle_regression.gd.

var failures: int = 0

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

## every catalog entry is enumerated without loading any
## presentation scene, and must be a unique-id, structurally valid,
## solver-confirmed-solvable, zero-mistake-witness entry, or the whole gate
## fails loudly rather than skipping the malformed one.
func _check_full_catalog_solvable() -> void:
	var count := PuzzleCatalog.count()
	check(count == 22, "the catalog contains 21 existing puzzles and the Reference Knot")

	var seen_ids: Dictionary = {}
	for i in range(count):
		var id := PuzzleCatalog.id_at(i)
		check(not id.is_empty(), "catalog entry %d has a non-empty stable id" % i)
		check(not seen_ids.has(id), "catalog entry %d's id '%s' is unique across the catalog" % [i, id])
		seen_ids[id] = true
		check(PuzzleCatalog.index_of(id) == i, "index_of('%s') matches its catalog position %d" % [id, i])

		var definition: PuzzleDefinition = PuzzleCatalog.get_definition(id)
		check(definition != null, "get_definition('%s') constructs without error" % id)
		check(definition.is_valid(), "catalog entry '%s' is structurally valid" % id)

		var result: Dictionary = PuzzleSolver.analyze(definition)
		check(result.solvable, "catalog entry '%s' is solver-confirmed solvable" % id)

		var witness: Array = result.witness
		var replay := PuzzleState.new(definition)
		for head in witness:
			check(replay.select_arrow(head) == PuzzleState.SelectOutcome.REMOVED,
				"catalog entry '%s' witness head %s replays clear against a fresh PuzzleState" % [id, head])
		check(replay.completed, "catalog entry '%s' witness clears the board" % id)
		check(replay.mistakes == 0, "catalog entry '%s' witness completes with zero mistakes" % id)

## The original fourteen entries keep their ids, order, dimensions, arrow
## counts and exact arrow/tail content: a change to any of them fails here
## rather than shipping silently alongside later catalog additions.
const ORIGINAL_ENTRIES: Array[Dictionary] = [
	{"id": "intro", "size": Vector2i(4, 4), "arrows": 6, "sha": "640fc3603a4ef038c37668e72024eac437ce194c80ba937516e661108dd2bbba"},
	{"id": "first_bend", "size": Vector2i(4, 3), "arrows": 4, "sha": "c6c81ebe1aba3966d596f27af907bdb6ededcbd320e2c15b0634fe5f5da1df43"},
	{"id": "multi_bend", "size": Vector2i(5, 5), "arrows": 4, "sha": "3c7028b5d6e4ab582e8696d9e09840eb57b0fea2937dbb8b74fcaf3307971a0a"},
	{"id": "dependency_chain", "size": Vector2i(5, 3), "arrows": 3, "sha": "3fdb2784f4323ed074cc118b976009970ade2f01a983de9a0300ea76bf02a745"},
	{"id": "forced_sequence", "size": Vector2i(5, 2), "arrows": 5, "sha": "ab6cf9cfa10f40348bb5d425832fc7076510397295911f180a8ed9b3ea72c6e3"},
	{"id": "multiple_choices", "size": Vector2i(4, 4), "arrows": 4, "sha": "0064c6e9c3785bfe5229cd8561dc6836400f0f24b2c6bdc86d85ecbcc29afc70"},
	{"id": "dense_board", "size": Vector2i(6, 6), "arrows": 10, "sha": "dfaadf54ab2a3dbbaba85c856818cec5fdee359f33beb39efd8361133bee9855"},
	{"id": "subtle_blockers", "size": Vector2i(5, 5), "arrows": 4, "sha": "a2d3af94606e1f6ca4e1f4bf1a4a7de3384c5018aafd59b24946b2468cd194d0"},
	{"id": "nested_chain", "size": Vector2i(5, 5), "arrows": 4, "sha": "62b34dae6617444cf40fc67ebac38425956a47b76e26aad1358f637a908b9b39"},
	{"id": "cascade_key_arrow", "size": Vector2i(5, 5), "arrows": 4, "sha": "e7d38347f2ab5ebaddd471fe326f11fc41c6ebccf8af58311d4e084afef32113"},
	{"id": "dense_unravel", "size": Vector2i(6, 6), "arrows": 24, "sha": "aba155d6ea40743c64a7dad82187232f8e01c71478e1c3e698fd8e21a484e42e"},
	{"id": "bent_network", "size": Vector2i(6, 4), "arrows": 4, "sha": "88f755458edb7d87caeee24b8f66d904617043315634f0b2e4475a4b0b4cdc7c"},
	{"id": "long_range_blocker", "size": Vector2i(8, 2), "arrows": 2, "sha": "6eff1107c26b25606532ed589f5af796d7de84dd7c0c72c5b829c6323d6243b1"},
	{"id": "composed_shaped", "size": Vector2i(7, 7), "arrows": 25, "sha": "5d07cb0bf5051824525c1ad1aecf92e25d7519ca8df7df366801251c84a19fce"},
]

const KNOT_ENTRIES: Array[Dictionary] = [
	{"id": "knot_long_geometry", "size": Vector2i(32, 24), "arrows": 8},
	{"id": "knot_interwoven_paths", "size": Vector2i(32, 24), "arrows": 8},
	{"id": "knot_dense_core", "size": Vector2i(36, 28), "arrows": 16},
	{"id": "knot_regions", "size": Vector2i(48, 32), "arrows": 13},
	{"id": "knot_single_release", "size": Vector2i(40, 30), "arrows": 8},
	{"id": "knot_boundary", "size": Vector2i(48, 36), "arrows": 28},
]

func _check_knot_entries() -> void:
	for offset in range(KNOT_ENTRIES.size()):
		var expected: Dictionary = KNOT_ENTRIES[offset]
		var id: String = expected["id"]
		check(PuzzleCatalog.id_at(15 + offset) == id, "new experiment '%s' follows the original catalog" % id)
		var definition: PuzzleDefinition = PuzzleCatalog.get_definition(id)
		check(Vector2i(definition.width, definition.height) == expected["size"],
			"new experiment '%s' retains its authored canvas" % id)
		check(definition.arrows.size() == expected["arrows"],
			"new experiment '%s' retains its authored arrow count" % id)
	var lab_ids := PuzzleCatalog.ids_in_group(PuzzleCatalog.GROUP_PUZZLE_LAB)
	check(lab_ids[lab_ids.size() - 1] == "knot_boundary",
		"the boundary experiment is the last Puzzle Lab entry")
	check(PuzzleCatalog.id_at(PuzzleCatalog.count() - 1) == "reference_knot",
		"the Reference Knot is the last catalog entry")

## Every entry belongs to exactly one valid group, groups keep their planned
## sizes, and the group queries never wrap, cross groups or fail on unknown ids.
func _check_groups() -> void:
	var group_ids := PuzzleCatalog.group_ids()
	check(group_ids == (["arrowspark_levels", "foundations", "puzzle_lab"] as Array[String]),
		"groups are presented in the planned order")
	var total := 0
	for group_id in group_ids:
		check(not PuzzleCatalog.group_title(group_id).is_empty(), "group '%s' has a display title" % group_id)
		total += PuzzleCatalog.ids_in_group(group_id).size()
	check(total == PuzzleCatalog.count(), "group membership covers every catalog entry exactly once")
	check(PuzzleCatalog.ids_in_group("foundations").size() == 8, "Foundations has 8 entries")
	check(PuzzleCatalog.ids_in_group("puzzle_lab").size() == 13, "Puzzle Lab has 13 entries")
	check(PuzzleCatalog.ids_in_group("arrowspark_levels").size() == 1, "ArrowSpark Levels has 1 entry")
	for i in range(PuzzleCatalog.count()):
		var id := PuzzleCatalog.id_at(i)
		check(group_ids.has(PuzzleCatalog.group_of(id)), "entry '%s' has a valid group" % id)
	check(PuzzleCatalog.group_of("canvas_validation") == "puzzle_lab", "canvas_validation is in Puzzle Lab")
	check(PuzzleCatalog.group_of("reference_knot") == "arrowspark_levels", "reference_knot is in ArrowSpark Levels")

	check(PuzzleCatalog.group_position("intro") == 1, "intro is first in Foundations")
	check(PuzzleCatalog.group_position("subtle_blockers") == 8, "subtle_blockers is eighth in Foundations")
	check(PuzzleCatalog.group_position("nested_chain") == 1, "nested_chain is first in Puzzle Lab")
	check(PuzzleCatalog.group_position("knot_boundary") == 13, "knot_boundary is thirteenth in Puzzle Lab")
	check(PuzzleCatalog.group_position("reference_knot") == 1, "reference_knot is first in ArrowSpark Levels")
	check(PuzzleCatalog.next_in_group("intro") == "first_bend", "next_in_group advances within a group")
	check(PuzzleCatalog.next_in_group("subtle_blockers") == "", "next_in_group ends at the last Foundations entry")
	check(PuzzleCatalog.next_in_group("knot_boundary") == "", "next_in_group ends at the last Puzzle Lab entry")
	check(PuzzleCatalog.next_in_group("reference_knot") == "", "next_in_group ends at the last ArrowSpark Levels entry")
	check(PuzzleCatalog.group_of("no_such_id") == "", "group_of an unknown id is empty")
	check(PuzzleCatalog.group_position("no_such_id") == 0, "group_position of an unknown id is 0")
	check(PuzzleCatalog.next_in_group("no_such_id") == "", "next_in_group of an unknown id is empty")
	check(PuzzleCatalog.group_title("no_such_group") == "", "group_title of an unknown group is empty")
	check(PuzzleCatalog.ids_in_group("no_such_group").is_empty(), "ids_in_group of an unknown group is empty")

## Order-independent text of a definition: dimensions, then every head in
## (y, x) order with its direction and ordered tail cells.
func _fingerprint(definition: PuzzleDefinition) -> String:
	var heads: Array = definition.arrows.keys()
	heads.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x))
	var parts: PackedStringArray = []
	for head in heads:
		var tail_text := ""
		if definition.tails.has(head):
			var cells: PackedStringArray = []
			for cell in definition.tails[head]:
				cells.append("%d,%d" % [cell.x, cell.y])
			tail_text = ";".join(cells)
		parts.append("%d,%d:%d[%s]" % [head.x, head.y, definition.arrows[head], tail_text])
	return "%dx%d|%s" % [definition.width, definition.height, "|".join(parts)]

func _check_original_entries_unchanged() -> void:
	check(PuzzleCatalog.count() >= ORIGINAL_ENTRIES.size(), "the catalog still contains every original entry")
	for i in range(ORIGINAL_ENTRIES.size()):
		var expected: Dictionary = ORIGINAL_ENTRIES[i]
		var id: String = expected["id"]
		check(PuzzleCatalog.id_at(i) == id, "original entry %d keeps id '%s' at its position" % [i, id])
		var definition: PuzzleDefinition = PuzzleCatalog.get_definition(id)
		check(Vector2i(definition.width, definition.height) == expected["size"],
			"original entry '%s' keeps its board dimensions" % id)
		check(definition.arrows.size() == expected["arrows"], "original entry '%s' keeps its arrow count" % id)
		check(_fingerprint(definition).sha256_text() == expected["sha"],
			"original entry '%s' keeps its exact arrow and tail content" % id)

## The original large-canvas fixture: a plainly titled, player-visible
## entry (puzzle 15) that is larger than a typical window at a comfortable
## arrow size, authored rather than generated, and solver-validated like every
## other entry.
const CANVAS_VALIDATION_SHA := "ccce768282c82848b925f672268842c8523a23a6d16cf612f8ae3083349bed9d"

func _check_canvas_validation_fixture() -> void:
	var id := "canvas_validation"
	check(PuzzleCatalog.index_of(id) == 14,
		"canvas_validation remains the fifteenth catalog entry")
	check(PuzzleCatalog.get_title(id) == "Large Canvas Validation", "canvas_validation carries its plain title")
	var definition: PuzzleDefinition = PuzzleCatalog.get_definition(id)
	check(definition.width == 40 and definition.height == 30, "canvas_validation is a 40x30 board")
	check(definition.arrows.size() == 52, "canvas_validation has exactly fifty-two arrows")
	check(_fingerprint(definition).sha256_text() == CANVAS_VALIDATION_SHA,
		"canvas_validation retains its exact authored content")

	var directions: Dictionary = {}
	var long_bent := 0
	for head in definition.arrows.keys():
		directions[definition.arrows[head]] = true
		var cells: Array[Vector2i] = definition.get_arrow_cells(head)
		var turns := 0
		for i in range(2, cells.size()):
			if cells[i] - cells[i - 1] != cells[i - 1] - cells[i - 2]:
				turns += 1
		if turns >= 1 and cells.size() >= 20 and cells.size() <= 60:
			long_bent += 1
	check(directions.size() == 4, "canvas_validation uses all four cardinal directions")
	check(long_bent >= 3, "canvas_validation has at least three bent arrows of 20-60 cells")

	var tail_dependency := _has_tail_caused_dependency(definition)
	check(tail_dependency, "canvas_validation contains a dependency caused by a tail cell")

	var state := PuzzleState.new(definition)
	var open_head = state.find_open_move()
	check(open_head != null and open_head.x < 10 and open_head.y < 10,
		"canvas_validation's initial open move is near the top-left corner")

	var owners: Dictionary = definition.get_cell_owners()
	var corners_occupied := 0
	for corner in [Vector2i(0, 0), Vector2i(39, 0), Vector2i(0, 29), Vector2i(39, 29)]:
		var region_hit := false
		for cell in owners.keys():
			if absi(cell.x - corner.x) <= 10 and absi(cell.y - corner.y) <= 10:
				region_hit = true
				break
		if region_hit:
			corners_occupied += 1
	check(corners_occupied == 4, "canvas_validation occupies a region near each of the four corners")

## True when some arrow's forward ray crosses a non-head cell of another arrow.
func _has_tail_caused_dependency(definition: PuzzleDefinition) -> bool:
	var owners: Dictionary = definition.get_cell_owners()
	for head in definition.arrows.keys():
		for cell in definition.forward_ray_cells(head, definition.arrows[head]):
			if owners.has(cell) and owners[cell] != head and cell != owners[cell]:
				return true
	return false

## identity (stable id) is independent of array position, title, or
## any filesystem path — ordering and identity are separate concepts.
func _check_id_independent_of_position() -> void:
	var ids := PuzzleCatalog.ids()
	check(ids.size() == PuzzleCatalog.count(), "ids() returns one entry per catalog position")
	for i in range(ids.size()):
		check(ids[i] == PuzzleCatalog.id_at(i), "ids()[%d] matches id_at(%d)" % [i, i])
	var ids_copy := PuzzleCatalog.ids()
	ids_copy.append("mutated_after_call")
	check(PuzzleCatalog.ids().size() == ids.size(), "ids() returns an independent copy on every call")

	check(PuzzleCatalog.index_of("no_such_id") == -1, "index_of an unknown id returns -1")
	check(PuzzleCatalog.get_definition("no_such_id") == null, "get_definition for an unknown id returns null")
	check(PuzzleCatalog.get_title("no_such_id") == "", "get_title for an unknown id returns an empty string")

## obtaining a definition is safe for a fresh attempt — playing or
## mutating one attempt's runtime state must not corrupt the catalog
## definition, a subsequent attempt at the same puzzle, or any other
## puzzle's definition. Repeated requests for the same id are deterministic.
func _check_fresh_and_isolated_definitions() -> void:
	var id := PuzzleCatalog.id_at(0)
	var first: PuzzleDefinition = PuzzleCatalog.get_definition(id)
	var second: PuzzleDefinition = PuzzleCatalog.get_definition(id)
	check(first != second, "two get_definition() calls for the same id return distinct instances")
	check(first.arrows == second.arrows and first.tails == second.tails,
		"two get_definition() calls for the same id are structurally equal")

	var played := PuzzleState.new(first)
	var analysis: Dictionary = PuzzleSolver.analyze(first)
	played.select_arrow(analysis.witness[0])
	check(second.arrows.size() == first.arrows.size(),
		"mutating one attempt's state does not affect a separately-requested definition for the same id")

	var other_id := PuzzleCatalog.id_at(1)
	var other_definition: PuzzleDefinition = PuzzleCatalog.get_definition(other_id)
	check(other_definition.arrows.keys() != first.arrows.keys() or other_id == id,
		"a different catalog id's definition is independent of the first")

## the eight puzzles provide meaningfully different structures, and
## none carries a difficulty label anywhere in the catalog's public surface.
const DIFFICULTY_LABEL_KEYS: Array[String] = ["difficulty", "difficulty_score", "difficulty_level", "level", "easy_medium_hard"]

func _check_no_difficulty_labels() -> void:
	for i in range(PuzzleCatalog.count()):
		var title := PuzzleCatalog.title_at(i)
		for key in DIFFICULTY_LABEL_KEYS:
			check(not title.to_lower().contains(key.to_lower().replace("_", " ")),
				"catalog title '%s' carries no difficulty-tier wording" % title)

## Each of the six experimental puzzles must continue to satisfy the exact
## numeric threshold its authoring comment documents in puzzle_catalog.gd --
## not merely "exists in the catalog." This is the automated, permanent
## backstop for a one-time manual check, so drift can never ship silently as
## a mislabeled experiment.
func _check_experimental_puzzle_properties() -> void:
	var nested_chain: Dictionary = PuzzleAnalyzer.analyze(PuzzleCatalog.get_definition("nested_chain"))
	check(nested_chain.dependency_graph.depth >= 3, "nested_chain: dependency depth is at least 3")
	var chain: Array = nested_chain.dependency_graph.longest_chain
	var all_same_row := true
	var all_same_col := true
	for i in range(1, chain.size()):
		if (chain[i] as Vector2i).y != (chain[0] as Vector2i).y:
			all_same_row = false
		if (chain[i] as Vector2i).x != (chain[0] as Vector2i).x:
			all_same_col = false
	check(not all_same_row and not all_same_col,
		"nested_chain: the longest dependency chain is not laid out in one row or column")

	var cascade: Dictionary = PuzzleAnalyzer.analyze(PuzzleCatalog.get_definition("cascade_key_arrow"))
	check(cascade.dependency_graph.max_unlock_fan_out >= 2,
		"cascade_key_arrow: at least one removal unlocks two or more arrows at once")

	var dense_unravel: Dictionary = PuzzleAnalyzer.analyze(PuzzleCatalog.get_definition("dense_unravel"))
	check(dense_unravel.board.density >= 0.55, "dense_unravel: occupied density is at least 0.55")
	check(dense_unravel.legal_move_structure.initial_legal_ratio <= 0.50,
		"dense_unravel: initial legal ratio is at most 0.50 (not an 'everything already legal' dense board)")

	var bent_network: Dictionary = PuzzleAnalyzer.analyze(PuzzleCatalog.get_definition("bent_network"))
	check(bent_network.geometry.bent_arrow_count >= 2, "bent_network: at least two bent arrows")
	var has_tail_sourced_edge := false
	for edge in (bent_network.blocker_distance.edges as Array):
		if edge["distance"] > 1:
			has_tail_sourced_edge = true
	check(has_tail_sourced_edge,
		"bent_network: at least one dependency edge's blocking cell is beyond the immediately adjacent cell (a tail cell, not a head)")

	var long_range: Dictionary = PuzzleAnalyzer.analyze(PuzzleCatalog.get_definition("long_range_blocker"))
	var long_range_ok := false
	for edge in (long_range.blocker_distance.edges as Array):
		if edge["distance"] >= 4:
			long_range_ok = true
	check(long_range_ok, "long_range_blocker: at least one blocker sits at ray distance >= 4")
	check(long_range.board.width >= 5 or long_range.board.height >= 5,
		"long_range_blocker: the board is large enough for that distance to be meaningful")

	var composed: Dictionary = PuzzleAnalyzer.analyze(PuzzleCatalog.get_definition("composed_shaped"))
	check(composed.board.total_cells >= 49, "composed_shaped: the board has at least 49 cells (7x7)")
	check(composed.dependency_graph.edge_count >= 1, "composed_shaped: the shape contains at least one genuine dependency edge")

## The (y, x)-ascending-first legal head among a live state's still-active
## arrows, or null if none is legal. Calls only get_snapshot()/is_blocked() --
## the real rule authority -- never a duplicated blocking check.
func _first_legal_head(state: PuzzleState) -> Variant:
	var active_heads: Array = state.get_snapshot()["active_arrows"].keys()
	active_heads.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return a.y < b.y or (a.y == b.y and a.x < b.x)
	)
	for head in active_heads:
		if not state.is_blocked(head):
			return head
	return null

## Every currently-legal head of a live state, (y, x)-ascending.
func _legal_heads(state: PuzzleState) -> Array:
	var active_heads: Array = state.get_snapshot()["active_arrows"].keys()
	active_heads.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return a.y < b.y or (a.y == b.y and a.x < b.x)
	)
	var legal: Array = []
	for head in active_heads:
		if not state.is_blocked(head):
			legal.append(head)
	return legal

## Drives a live state to completion greedily, calling only select_arrow() --
## the real rule authority. Returns true iff it reaches a complete,
## mistake-free clearance; false if it gets stuck first.
func _greedy_complete(state: PuzzleState) -> bool:
	while not state.completed:
		var head = _first_legal_head(state)
		if head == null:
			return false
		if state.select_arrow(head) != PuzzleState.SelectOutcome.REMOVED:
			return false
	return true

## Order independence: at every branching state PuzzleSolver's own witness passes
## through for this definition, force each *other* currently-legal
## alternative next (instead of the witness's own choice) and confirm the
## resulting state still greedily completes. This is the monotonicity
## exchange property -- "any currently legal arrow is safe to take" -- and it
## is what makes "every unfinished state reached through legal play has a
## legal move" hold without enumerating the full reachable-state space (see
## tests/puzzle_regression.gd's identical helper).
## branch_stride > 1 samples every stride-th branching state instead of all of
## them, for a board too large for the launcher's time limit; it is used only
## for the densest authored board, and every other entry keeps the full check.
func _check_order_independence_at_every_branch(definition: PuzzleDefinition, label: String, branch_stride: int = 1) -> void:
	var result: Dictionary = PuzzleSolver.analyze(definition)
	check(result.solvable, "%s is solver-confirmed solvable (prerequisite for its branch check)" % label)
	if not result.solvable:
		return
	var witness: Array = result.witness
	var prefix: Array = []
	var live_state := PuzzleState.new(definition)
	var branch_count := 0
	for step_index in range(witness.size()):
		var chosen_head: Vector2i = witness[step_index]
		var legal_here: Array = _legal_heads(live_state)
		if legal_here.size() > 1:
			branch_count += 1
		if legal_here.size() > 1 and (branch_count - 1) % branch_stride == 0:
			for alt_head in legal_here:
				if alt_head == chosen_head:
					continue
				var branch_state := PuzzleState.new(definition)
				for prefix_head in prefix:
					branch_state.select_arrow(prefix_head)
				var branch_outcome: PuzzleState.SelectOutcome = branch_state.select_arrow(alt_head)
				check(branch_outcome == PuzzleState.SelectOutcome.REMOVED,
					"%s: forcing alternative legal head %s instead of the witness's %s at step %d is itself legal" %
					[label, alt_head, chosen_head, step_index])
				check(_greedy_complete(branch_state),
					"%s: forcing alternative legal head %s instead of the witness's %s at step %d still reaches a complete, mistake-free solution" %
					[label, alt_head, chosen_head, step_index])
		live_state.select_arrow(chosen_head)
		prefix.append(chosen_head)

## Runs the branch check above across every catalog
## entries, giving the "always a legal move" invariant catalog-wide
## coverage rather than the single hand-built board tests/puzzle_regression.gd
## already covers.
const SAMPLED_BRANCH_ENTRY := "reference_knot"
const SAMPLED_BRANCH_STRIDE := 6

func _check_catalog_wide_order_independence() -> void:
	for i in range(PuzzleCatalog.count()):
		var id := PuzzleCatalog.id_at(i)
		var stride := SAMPLED_BRANCH_STRIDE if id == SAMPLED_BRANCH_ENTRY else 1
		_check_order_independence_at_every_branch(PuzzleCatalog.get_definition(id), "catalog entry '%s'" % id, stride)

## Next Puzzle is scoped to the current puzzle's own group: each group's last
## entry has no next, never crossing into another group and never wrapping.
func _check_group_scoped_progression() -> void:
	for group_id in PuzzleCatalog.group_ids():
		var members := PuzzleCatalog.ids_in_group(group_id)
		for i in range(members.size() - 1):
			PuzzleSession.set_current_id(members[i])
			check(PuzzleSession.has_next() and PuzzleSession.advance_to_next(),
				"'%s' advances within %s" % [members[i], group_id])
			check(PuzzleSession.get_current_id() == members[i + 1],
				"'%s' advances to the next entry of its own group" % members[i])
		var last: String = members.back()
		PuzzleSession.set_current_id(last)
		check(not PuzzleSession.has_next(), "'%s' ends %s with no next entry" % [last, group_id])
		check(not PuzzleSession.advance_to_next(), "advancing from '%s' at its group's end is a no-op" % last)
		check(PuzzleSession.get_current_id() == last, "the current id is unchanged at the end of %s" % group_id)
	PuzzleSession.set_current_id("")

func _check_next_from_fourteenth_reaches_canvas_validation() -> void:
	PuzzleSession.set_current_id(PuzzleCatalog.id_at(13))
	check(PuzzleSession.has_next(), "the fourteenth puzzle offers a next entry")
	check(PuzzleSession.advance_to_next(), "advancing from the fourteenth puzzle succeeds")
	check(PuzzleSession.get_current_id() == "canvas_validation", "Next from puzzle 14 reaches canvas_validation")
	check(PuzzleSession.has_next(), "canvas_validation offers the first new experiment next")
	check(PuzzleSession.advance_to_next(), "advancing from canvas_validation succeeds")
	check(PuzzleSession.get_current_id() == "knot_long_geometry", "Next reaches the first new experiment")
	PuzzleSession.set_current_id("")

func _check_puzzle_session_defaults_and_navigation() -> void:
	check(PuzzleSession.get_current_id() == PuzzleCatalog.id_at(0),
		"PuzzleSession defaults to the first catalog entry when unset")

	PuzzleSession.set_current_id(PuzzleCatalog.id_at(2))
	check(PuzzleSession.get_current_id() == PuzzleCatalog.id_at(2), "set_current_id() updates the current id")

	check(PuzzleSession.has_next(), "a mid-catalog puzzle has a next entry")
	check(PuzzleSession.advance_to_next(), "advance_to_next() succeeds mid-catalog")
	check(PuzzleSession.get_current_id() == PuzzleCatalog.id_at(3), "advance_to_next() moves forward exactly one position")

	PuzzleSession.set_current_id(PuzzleCatalog.id_at(PuzzleCatalog.count() - 1))
	check(not PuzzleSession.has_next(), "the last catalog entry has no next entry")
	check(not PuzzleSession.advance_to_next(), "advance_to_next() is a no-op at the last entry")
	check(PuzzleSession.get_current_id() == PuzzleCatalog.id_at(PuzzleCatalog.count() - 1),
		"advance_to_next() leaves the current id unchanged at the last entry")

	PuzzleSession.set_current_id("not_a_real_id")
	check(PuzzleSession.get_current_id() == PuzzleCatalog.id_at(0),
		"an invalid current id falls back to the first catalog entry on next read")

## The Reference Knot is the showcase level: every observed session and every
## reaction names this exact geometry. A change to its board must fail here.
const REFERENCE_KNOT_CONTENT_VERSION := "g1-7ce0942d4a5e"

func _check_reference_knot_content_version() -> void:
	var definition: PuzzleDefinition = PuzzleCatalog.get_definition("reference_knot")
	var version := PuzzleContentVersion.of(definition)
	print("Reference Knot content version: ", version)
	check(version == REFERENCE_KNOT_CONTENT_VERSION,
		"the Reference Knot's content version is pinned at %s (got %s)" % [REFERENCE_KNOT_CONTENT_VERSION, version])
	var pattern := RegEx.create_from_string("^g1-[0-9a-f]{12}$")
	check(pattern.search(version) != null, "a content version is 'g1-' plus 12 lowercase hex digits")
	check(PuzzleContentVersion.of(PuzzleCatalog.get_definition("reference_knot")) == version,
		"the content version is stable across calls and fresh definitions")

	# Same geometry rebuilt outside the catalog (no id, title or group): same value.
	var rebuilt := PuzzleDefinition.new(definition.width, definition.height,
		definition.duplicate_arrows(), definition.duplicate_tails())
	check(PuzzleContentVersion.of(rebuilt) == version,
		"the content version depends on geometry only, not on catalog id, title or group")

	# One tail cell moved in a synthetic copy: a different value.
	var tails := definition.duplicate_tails()
	var heads: Array = tails.keys()
	heads.sort()
	var altered_head: Vector2i = heads.filter(func(h: Vector2i) -> bool: return not tails[h].is_empty())[0]
	var cells: Array = tails[altered_head]
	cells[cells.size() - 1] = cells[cells.size() - 1] + Vector2i(1, 0)
	var moved_tail := PuzzleDefinition.new(definition.width, definition.height, definition.duplicate_arrows(), tails)
	check(PuzzleContentVersion.of(moved_tail) != version, "moving one tail cell changes the content version")

	# One direction changed: a different value.
	var arrows := definition.duplicate_arrows()
	var turned_head: Vector2i = arrows.keys()[0]
	arrows[turned_head] = (int(arrows[turned_head]) + 1) % 4
	var turned := PuzzleDefinition.new(definition.width, definition.height, arrows, definition.duplicate_tails())
	check(PuzzleContentVersion.of(turned) != version, "changing one arrow's direction changes the content version")

	var resized := PuzzleDefinition.new(definition.width + 1, definition.height,
		definition.duplicate_arrows(), definition.duplicate_tails())
	check(PuzzleContentVersion.of(resized) != version, "changing the board size changes the content version")

	var other: PuzzleDefinition = PuzzleCatalog.get_definition("intro")
	check(PuzzleContentVersion.of(other) != version, "a different puzzle has a different content version")

func _initialize() -> void:
	_check_full_catalog_solvable()
	_check_reference_knot_content_version()
	_check_original_entries_unchanged()
	_check_canvas_validation_fixture()
	_check_knot_entries()
	_check_groups()
	_check_id_independent_of_position()
	_check_fresh_and_isolated_definitions()
	_check_no_difficulty_labels()
	_check_experimental_puzzle_properties()
	_check_catalog_wide_order_independence()
	_check_next_from_fourteenth_reaches_canvas_validation()
	_check_group_scoped_progression()
	_check_puzzle_session_defaults_and_navigation()
	print("PUZZLE_CATALOG_FAILURES=", failures)
	quit(1 if failures else 0)
