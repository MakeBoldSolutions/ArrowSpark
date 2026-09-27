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

## FR-014: every catalog entry is enumerated without loading any
## presentation scene, and must be a unique-id, structurally valid,
## solver-confirmed-solvable, zero-mistake-witness entry, or the whole gate
## fails loudly rather than skipping the malformed one.
func _check_full_catalog_solvable() -> void:
	var count := PuzzleCatalog.count()
	check(count == 14, "the catalog contains exactly 14 entries (8 baseline + 6 experimental)")

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

## FR-002: identity (stable id) is independent of array position, title, or
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

## FR-015: obtaining a definition is safe for a fresh attempt — playing or
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

## FR-005: the eight puzzles provide meaningfully different structures, and
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

func _initialize() -> void:
	_check_full_catalog_solvable()
	_check_id_independent_of_position()
	_check_fresh_and_isolated_definitions()
	_check_no_difficulty_labels()
	_check_experimental_puzzle_properties()
	_check_puzzle_session_defaults_and_navigation()
	print("PUZZLE_CATALOG_FAILURES=", failures)
	quit(1 if failures else 0)
