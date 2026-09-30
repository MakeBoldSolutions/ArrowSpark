class_name PuzzleCatalog
extends RefCounted
## Static registry of twenty-two authored puzzles: the original eight
## baseline puzzles, six earlier structural experiments, the large-canvas
## validation puzzle, six geometric-entanglement experiments, and the
## hand-composed Reference Knot. Every entry carries a purpose group
## (Foundations, Puzzle Lab, ArrowSpark Levels) that is pure metadata: it drives
## Level Select sections, group-relative numbering and Next Puzzle scope, and
## never affects rules. Earlier experiments deliberately
## combine structural features the baseline eight never do (see
## PuzzleAnalyzer), and one large-canvas validation board that is larger
## than a typical window at a comfortable arrow size. Never instantiated; every member is static. Each entry
## pairs a stable id (independent of array position, title, or any filesystem
## path) with a display title and a zero-argument builder returning a freshly
## constructed PuzzleDefinition — exactly PuzzleDefinition.create_fixed()'s
## existing literal-construction style, so isolation (no shared mutable
## substructure across calls) falls out of the construction pattern itself,
## with no caching layer.

const GROUP_ARROWSPARK_LEVELS := "arrowspark_levels"
const GROUP_FOUNDATIONS := "foundations"
const GROUP_PUZZLE_LAB := "puzzle_lab"
const GROUP_TITLES := {
	GROUP_ARROWSPARK_LEVELS: "ArrowSpark Levels",
	GROUP_FOUNDATIONS: "Foundations",
	GROUP_PUZZLE_LAB: "Puzzle Lab",
}

static var _entries: Array[Dictionary] = []

static func _ensure_entries() -> void:
	if not _entries.is_empty():
		return
	_entries = [
		{"id": "intro", "title": "Simple Introduction", "group": GROUP_FOUNDATIONS, "build": Callable(PuzzleCatalog, "_build_intro")},
		{"id": "first_bend", "title": "First Bend", "group": GROUP_FOUNDATIONS, "build": Callable(PuzzleCatalog, "_build_first_bend")},
		{"id": "multi_bend", "title": "Multiple Bends", "group": GROUP_FOUNDATIONS, "build": Callable(PuzzleCatalog, "_build_multi_bend")},
		{"id": "dependency_chain", "title": "Dependency Chain", "group": GROUP_FOUNDATIONS, "build": Callable(PuzzleCatalog, "_build_dependency_chain")},
		{"id": "forced_sequence", "title": "Forced Sequence", "group": GROUP_FOUNDATIONS, "build": Callable(PuzzleCatalog, "_build_forced_sequence")},
		{"id": "multiple_choices", "title": "Multiple Choices", "group": GROUP_FOUNDATIONS, "build": Callable(PuzzleCatalog, "_build_multiple_choices")},
		{"id": "dense_board", "title": "Dense Board", "group": GROUP_FOUNDATIONS, "build": Callable(PuzzleCatalog, "_build_dense_board")},
		{"id": "subtle_blockers", "title": "Subtle Blockers", "group": GROUP_FOUNDATIONS, "build": Callable(PuzzleCatalog, "_build_subtle_blockers")},
		{"id": "nested_chain", "title": "Nested Chain", "group": GROUP_PUZZLE_LAB, "build": Callable(PuzzleCatalog, "_build_nested_chain")},
		{"id": "cascade_key_arrow", "title": "Cascade / Key Arrow", "group": GROUP_PUZZLE_LAB, "build": Callable(PuzzleCatalog, "_build_cascade_key_arrow")},
		{"id": "dense_unravel", "title": "Dense Unravel", "group": GROUP_PUZZLE_LAB, "build": Callable(PuzzleCatalog, "_build_dense_unravel")},
		{"id": "bent_network", "title": "Bent Network", "group": GROUP_PUZZLE_LAB, "build": Callable(PuzzleCatalog, "_build_bent_network")},
		{"id": "long_range_blocker", "title": "Long-Range Blocker", "group": GROUP_PUZZLE_LAB, "build": Callable(PuzzleCatalog, "_build_long_range_blocker")},
		{"id": "composed_shaped", "title": "Composed / Shaped", "group": GROUP_PUZZLE_LAB, "build": Callable(PuzzleCatalog, "_build_composed_shaped")},
		{"id": "canvas_validation", "title": "Large Canvas Validation", "group": GROUP_PUZZLE_LAB, "build": Callable(PuzzleCatalog, "_build_canvas_validation")},
		{"id": "knot_long_geometry", "title": "Long Geometry", "group": GROUP_PUZZLE_LAB, "build": Callable(PuzzleCatalog, "_build_knot_long_geometry")},
		{"id": "knot_interwoven_paths", "title": "Interwoven Paths", "group": GROUP_PUZZLE_LAB, "build": Callable(PuzzleCatalog, "_build_knot_interwoven_paths")},
		{"id": "knot_dense_core", "title": "Dense Core", "group": GROUP_PUZZLE_LAB, "build": Callable(PuzzleCatalog, "_build_knot_dense_core")},
		{"id": "knot_regions", "title": "Distinct Regions", "group": GROUP_PUZZLE_LAB, "build": Callable(PuzzleCatalog, "_build_knot_regions")},
		{"id": "knot_single_release", "title": "Single Release", "group": GROUP_PUZZLE_LAB, "build": Callable(PuzzleCatalog, "_build_knot_single_release")},
		{"id": "knot_boundary", "title": "Boundary Knot", "group": GROUP_PUZZLE_LAB, "build": Callable(PuzzleCatalog, "_build_knot_boundary")},
		{"id": "reference_knot", "title": "Reference Knot", "group": GROUP_ARROWSPARK_LEVELS, "build": Callable(PuzzleCatalog, "_build_reference_knot")},
	]

static func count() -> int:
	_ensure_entries()
	return _entries.size()

static func id_at(index: int) -> String:
	_ensure_entries()
	if index < 0 or index >= _entries.size():
		return ""
	return _entries[index]["id"]

static func title_at(index: int) -> String:
	_ensure_entries()
	if index < 0 or index >= _entries.size():
		return ""
	return _entries[index]["title"]

static func index_of(id: String) -> int:
	_ensure_entries()
	for i in range(_entries.size()):
		if _entries[i]["id"] == id:
			return i
	return -1

static func ids() -> Array[String]:
	_ensure_entries()
	var result: Array[String] = []
	for entry in _entries:
		result.append(entry["id"])
	return result

static func get_title(id: String) -> String:
	var index := index_of(id)
	if index == -1:
		return ""
	return title_at(index)

## Group ids in Level Select presentation order. Presentation order only; it
## makes no quality claim.
static func group_ids() -> Array[String]:
	return [GROUP_ARROWSPARK_LEVELS, GROUP_FOUNDATIONS, GROUP_PUZZLE_LAB]

static func group_title(group_id: String) -> String:
	return String(GROUP_TITLES.get(group_id, ""))

## Group id of an entry, or "" for an unknown id.
static func group_of(id: String) -> String:
	var index := index_of(id)
	if index == -1:
		return ""
	return _entries[index]["group"]

## Members of a group in catalog order; empty for an unknown group.
static func ids_in_group(group_id: String) -> Array[String]:
	_ensure_entries()
	var result: Array[String] = []
	for entry in _entries:
		if entry["group"] == group_id:
			result.append(entry["id"])
	return result

## 1-based position of an entry within its own group, or 0 for an unknown id.
static func group_position(id: String) -> int:
	var group_id := group_of(id)
	if group_id.is_empty():
		return 0
	return ids_in_group(group_id).find(id) + 1

## Next entry in the same group, or "" at the group's end. Never wraps and
## never crosses into another group.
static func next_in_group(id: String) -> String:
	var group_id := group_of(id)
	if group_id.is_empty():
		return ""
	var members := ids_in_group(group_id)
	var position := members.find(id)
	if position == -1 or position + 1 >= members.size():
		return ""
	return members[position + 1]

## Constructs and returns a fresh PuzzleDefinition for the given id, or null
## if the id is unknown. Every call rebuilds the definition from its literal
## builder, so no two calls ever share mutable substructure.
static func get_definition(id: String) -> PuzzleDefinition:
	var index := index_of(id)
	if index == -1:
		return null
	var build: Callable = _entries[index]["build"]
	return build.call()

# --- Puzzle builders --------------------------------------------------------
# Each builder mirrors PuzzleDefinition.create_fixed()'s literal-construction
# style: dictionaries of arrows/tails passed directly to PuzzleDefinition.new().

## Six single-cell arrows, each facing straight off a board edge with an
## empty forward ray, so every one is legal from the very first state.
static func _build_intro() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var arrows := {
		Vector2i(0, 0): d.LEFT,
		Vector2i(1, 0): d.UP,
		Vector2i(3, 0): d.UP,
		Vector2i(2, 3): d.DOWN,
		Vector2i(0, 3): d.DOWN,
		Vector2i(3, 3): d.RIGHT,
	}
	return PuzzleDefinition.new(4, 4, arrows)

## Mostly straight, edge-facing single-cell arrows plus exactly one tail
## with a single right-angle bend.
static func _build_first_bend() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var arrows := {
		Vector2i(1, 1): d.RIGHT,
		Vector2i(3, 0): d.UP,
		Vector2i(3, 2): d.RIGHT,
		Vector2i(0, 2): d.LEFT,
	}
	var tails := {
		Vector2i(1, 1): [Vector2i(0, 1), Vector2i(0, 0)],
	}
	return PuzzleDefinition.new(4, 3, arrows, tails)

## A long, three-bend tail exercising the existing multi-bend geometry path,
## plus three edge-facing singles; one of them sits on the bent arrow's
## forward ray, adding a single dependency.
static func _build_multi_bend() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var arrows := {
		Vector2i(3, 4): d.LEFT,
		Vector2i(0, 0): d.UP,
		Vector2i(0, 4): d.DOWN,
		Vector2i(4, 0): d.RIGHT,
	}
	var tails := {
		Vector2i(3, 4): [Vector2i(4, 4), Vector2i(4, 3), Vector2i(3, 3), Vector2i(3, 2)],
	}
	return PuzzleDefinition.new(5, 5, arrows, tails)

## A clear A-blocks-B-blocks-C chain: removing one arrow visibly unlocks
## the next, one at a time.
static func _build_dependency_chain() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var arrows := {
		Vector2i(2, 0): d.LEFT, # A: always legal, unlocks B
		Vector2i(2, 1): d.UP,   # B: blocked by A until A departs
		Vector2i(0, 1): d.RIGHT, # C: blocked by B until B departs
	}
	return PuzzleDefinition.new(5, 3, arrows)

## Five arrows in a row, each blocked by every arrow still active to its
## own side, so exactly one legal move exists at every step of the solve.
static func _build_forced_sequence() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var arrows := {
		Vector2i(0, 1): d.LEFT,
		Vector2i(1, 1): d.LEFT,
		Vector2i(2, 1): d.LEFT,
		Vector2i(3, 1): d.LEFT,
		Vector2i(4, 1): d.LEFT,
	}
	return PuzzleDefinition.new(5, 2, arrows)

## Three fully independent, simultaneously legal arrows (a genuine
## branching state) plus one dependent arrow that only opens up once one of
## them departs.
static func _build_multiple_choices() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var arrows := {
		Vector2i(0, 0): d.LEFT,
		Vector2i(3, 0): d.RIGHT,
		Vector2i(0, 3): d.DOWN,
		Vector2i(3, 3): d.UP,
	}
	return PuzzleDefinition.new(4, 4, arrows)

## A larger 6x6 grid with ten arrows (more than the shipped fixed board's
## eight), exercising ownership/readability at higher density.
static func _build_dense_board() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var arrows := {
		Vector2i(0, 0): d.LEFT,
		Vector2i(5, 0): d.UP,
		Vector2i(0, 5): d.DOWN,
		Vector2i(5, 5): d.RIGHT,
		Vector2i(2, 0): d.UP,
		Vector2i(3, 5): d.DOWN,
		Vector2i(0, 2): d.LEFT,
		Vector2i(5, 3): d.RIGHT,
		Vector2i(3, 3): d.UP,
		Vector2i(2, 3): d.RIGHT,
	}
	return PuzzleDefinition.new(6, 6, arrows)

## Blockers positioned so the blocking relationship is not visually obvious:
## a short tail segment, two bends deep and far from its own head, sits just
## inside another arrow's long forward escape ray.
static func _build_subtle_blockers() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var arrows := {
		Vector2i(0, 2): d.RIGHT,
		Vector2i(1, 4): d.LEFT,
		Vector2i(4, 0): d.UP,
		Vector2i(0, 0): d.LEFT,
	}
	var tails := {
		Vector2i(1, 4): [Vector2i(2, 4), Vector2i(2, 3), Vector2i(2, 2)],
	}
	return PuzzleDefinition.new(5, 5, arrows, tails)

# --- Experimental puzzles ---------------------------------------------------
# Each deliberately isolates a structural combination the eight baseline
# puzzles above never exercise (see PuzzleAnalyzer). A puzzle may satisfy
# more than one experiment's structural goal at once; overlap is fine and
# expected, not a requirement that each puzzle isolate exactly one hypothesis.

## A→B→C→D dependency chain (PuzzleAnalyzer depth 3) whose four heads span
## opposite corners of the board rather than one obvious row/column, so the
## chain must be traced across separated regions instead of read at a glance.
static func _build_nested_chain() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var arrows := {
		Vector2i(4, 0): d.LEFT,  # A: always legal
		Vector2i(4, 1): d.UP,    # B: blocked by A
		Vector2i(0, 1): d.RIGHT, # C: blocked by B
		Vector2i(0, 4): d.UP,    # D: blocked by C
	}
	return PuzzleDefinition.new(5, 5, arrows)

## A single key arrow (a bent, always-legal arrow whose shape must be traced
## to discover) whose removal simultaneously unblocks three others at once
## (PuzzleAnalyzer max_unlock_fan_out 3) -- the "cascade" primitive the
## pre-Spec-006 research found untested anywhere in the baseline catalog.
static func _build_cascade_key_arrow() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var arrows := {
		Vector2i(2, 2): d.RIGHT, # key arrow: always legal, its bent tail blocks all three below
		Vector2i(0, 1): d.RIGHT,
		Vector2i(1, 4): d.UP,
		Vector2i(2, 4): d.UP,
	}
	var tails := {
		Vector2i(2, 2): [Vector2i(1, 2), Vector2i(1, 1)],
	}
	return PuzzleDefinition.new(5, 5, arrows, tails)

## Six independent depth-3 dependency chains (one per column) packed onto a
## 6x6 board: meaningfully higher density than any baseline puzzle (0.67 vs.
## the existing catalog's 0.20-0.50 range) combined with real dependency
## depth, unlike the existing dense_board puzzle (90% already legal at the
## start -- looks dense but has nothing to unravel). Here only 25% of arrows
## are legal initially, and each column peels away independently.
static func _build_dense_unravel() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var arrows := {}
	for x in range(6):
		for y in range(4):
			arrows[Vector2i(x, y)] = d.UP
	return PuzzleDefinition.new(6, 6, arrows)

## Two separately bent arrows (M1, M2), each blocking a different target
## arrow specifically via a TAIL cell rather than its head -- tracing only
## the head position is not enough to understand either dependency; the
## player must follow both bent shapes to their tail ends.
static func _build_bent_network() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var m1 := Vector2i(1, 0)
	var m2 := Vector2i(4, 3)
	var arrows := {
		m1: d.RIGHT,
		Vector2i(2, 1): d.LEFT, # blocked by M1's tail cell
		m2: d.LEFT,
		Vector2i(3, 2): d.RIGHT, # blocked by M2's tail cell
	}
	var tails := {
		m1: [Vector2i(0, 0), Vector2i(0, 1)],
		m2: [Vector2i(5, 3), Vector2i(5, 2)],
	}
	return PuzzleDefinition.new(6, 4, arrows, tails)

## A locally-free-looking arrow (Target) is actually blocked by the tail cell
## of a two-cell arrow (Blocker) seven cells away along its forward ray --
## far past the immediately adjacent cell, and via a tail rather than a head.
static func _build_long_range_blocker() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var arrows := {
		Vector2i(0, 0): d.RIGHT, # Target: looks free, but its ray reaches all the way across
		Vector2i(7, 1): d.DOWN,  # Blocker: its tail cell (not its head) sits on Target's ray
	}
	var tails := {
		Vector2i(7, 1): [Vector2i(7, 0)],
	}
	return PuzzleDefinition.new(8, 2, arrows, tails)

## A filled diamond of 25 single-cell arrows on a 7x7 board, every one facing
## UP. The occupied cells form a clearly recognizable diamond silhouette,
## while the uniform facing means every column is its own real dependency
## chain (up to depth 6 down the center column) -- the shape is not
## decorative, it is what generates the puzzle's actual structure.
static func _build_composed_shaped() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var arrows := {}
	for y in range(7):
		var dx_max: int = 3 - abs(y - 3)
		for x in range(3 - dx_max, 3 + dx_max + 1):
			arrows[Vector2i(x, y)] = d.UP
	return PuzzleDefinition.new(7, 7, arrows)

## Expands literal orthogonal path vertices (head first, then each turn or end
## point) into the ordered tail cells behind the head. Deterministic; no
## generator or randomness.
static func _tail_along(vertices: Array[Vector2i]) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for i in range(vertices.size() - 1):
		var step := Vector2i((vertices[i + 1] - vertices[i]).sign())
		var cell := vertices[i]
		while cell != vertices[i + 1]:
			cell += step
			cells.append(cell)
	return cells

## A 40x30 authored board packed with fifty-two arrows, roughly 87% of the
## cells occupied, larger than any window at a 64-pixel arrow scale. Almost
## every arrow is long and bent (most are 22-43 cells; only three are shorter
## than eight), all four directions appear, and long tails cross the rays of
## other arrows, so most removals unlock several others. The first arrow, at
## the top-left, is the initial open move. Difficulty is deliberately untuned;
## it exists to exercise navigation, off-screen assistance and long
## departures across a large canvas. The layout is fixed literal data (found
## once by a seeded search that kept every step solvable), not generated at
## runtime.
static func _build_canvas_validation() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var shapes := [
		[Vector2i(4, 1), d.UP, [Vector2i(4, 1), Vector2i(4, 10), Vector2i(14, 10), Vector2i(14, 3)]],
		[Vector2i(3, 27), d.DOWN, [Vector2i(3, 27), Vector2i(3, 19), Vector2i(12, 19), Vector2i(12, 24)]],
		[Vector2i(30, 10), d.LEFT, [Vector2i(30, 10), Vector2i(36, 10), Vector2i(36, 20), Vector2i(28, 20)]],
		[Vector2i(35, 3), d.RIGHT, [Vector2i(35, 3), Vector2i(26, 3), Vector2i(26, 12), Vector2i(20, 12)]],
		[Vector2i(18, 13), d.DOWN, [Vector2i(18, 13), Vector2i(18, 2), Vector2i(29, 2), Vector2i(29, 0), Vector2i(38, 0), Vector2i(38, 6)]],
		[Vector2i(19, 12), d.DOWN, [Vector2i(19, 12), Vector2i(19, 3), Vector2i(25, 3), Vector2i(25, 11), Vector2i(22, 11)]],
		[Vector2i(6, 16), d.LEFT, [Vector2i(6, 16), Vector2i(13, 16), Vector2i(13, 24), Vector2i(22, 24), Vector2i(22, 16), Vector2i(32, 16)]],
		[Vector2i(0, 6), d.UP, [Vector2i(0, 6), Vector2i(0, 16), Vector2i(3, 16), Vector2i(3, 9), Vector2i(1, 9)]],
		[Vector2i(4, 29), d.LEFT, [Vector2i(4, 29), Vector2i(9, 29), Vector2i(9, 25), Vector2i(20, 25), Vector2i(20, 26)]],
		[Vector2i(14, 23), d.DOWN, [Vector2i(14, 23), Vector2i(14, 15), Vector2i(9, 15), Vector2i(9, 14), Vector2i(16, 14), Vector2i(16, 2)]],
		[Vector2i(10, 18), d.DOWN, [Vector2i(10, 18), Vector2i(10, 17), Vector2i(0, 17), Vector2i(0, 21), Vector2i(2, 21), Vector2i(2, 27), Vector2i(1, 27)]],
		[Vector2i(6, 3), d.LEFT, [Vector2i(6, 3), Vector2i(10, 3), Vector2i(10, 0), Vector2i(13, 0), Vector2i(13, 4), Vector2i(7, 4), Vector2i(7, 8)]],
		[Vector2i(29, 25), d.LEFT, [Vector2i(29, 25), Vector2i(34, 25), Vector2i(34, 29), Vector2i(39, 29), Vector2i(39, 24), Vector2i(34, 24)]],
		[Vector2i(24, 18), d.UP, [Vector2i(24, 18), Vector2i(24, 26), Vector2i(33, 26), Vector2i(33, 29), Vector2i(22, 29), Vector2i(22, 25)]],
		[Vector2i(30, 8), d.LEFT, [Vector2i(30, 8), Vector2i(37, 8), Vector2i(37, 22), Vector2i(26, 22)]],
		[Vector2i(10, 11), d.LEFT, [Vector2i(10, 11), Vector2i(15, 11), Vector2i(15, 0), Vector2i(27, 0)]],
		[Vector2i(17, 4), d.UP, [Vector2i(17, 4), Vector2i(17, 14), Vector2i(18, 14), Vector2i(18, 23), Vector2i(21, 23), Vector2i(21, 21)]],
		[Vector2i(36, 21), d.RIGHT, [Vector2i(36, 21), Vector2i(27, 21), Vector2i(27, 19), Vector2i(35, 19), Vector2i(35, 11), Vector2i(29, 11)]],
		[Vector2i(20, 11), d.DOWN, [Vector2i(20, 11), Vector2i(20, 4), Vector2i(24, 4), Vector2i(24, 10), Vector2i(22, 10), Vector2i(22, 5)]],
		[Vector2i(22, 15), d.LEFT, [Vector2i(22, 15), Vector2i(28, 15), Vector2i(28, 11), Vector2i(27, 11), Vector2i(27, 6), Vector2i(32, 6)]],
		[Vector2i(8, 21), d.UP, [Vector2i(8, 21), Vector2i(8, 28), Vector2i(4, 28), Vector2i(4, 20), Vector2i(6, 20), Vector2i(6, 26)]],
		[Vector2i(17, 19), d.DOWN, [Vector2i(17, 19), Vector2i(17, 15), Vector2i(15, 15), Vector2i(15, 23), Vector2i(16, 23), Vector2i(16, 17)]],
		[Vector2i(38, 19), d.DOWN, [Vector2i(38, 19), Vector2i(38, 15), Vector2i(39, 15), Vector2i(39, 7), Vector2i(28, 7)]],
		[Vector2i(37, 1), d.UP, [Vector2i(37, 1), Vector2i(37, 6), Vector2i(33, 6), Vector2i(33, 4), Vector2i(27, 4), Vector2i(27, 5), Vector2i(31, 5)]],
		[Vector2i(5, 1), d.UP, [Vector2i(5, 1), Vector2i(5, 9), Vector2i(8, 9), Vector2i(8, 5), Vector2i(12, 5), Vector2i(12, 8)]],
		[Vector2i(32, 12), d.LEFT, [Vector2i(32, 12), Vector2i(34, 12), Vector2i(34, 18), Vector2i(31, 18), Vector2i(31, 17), Vector2i(26, 17), Vector2i(26, 18), Vector2i(29, 18)]],
		[Vector2i(10, 29), d.LEFT, [Vector2i(10, 29), Vector2i(19, 29), Vector2i(19, 26), Vector2i(16, 26), Vector2i(16, 28), Vector2i(10, 28)]],
		[Vector2i(25, 17), d.UP, [Vector2i(25, 17), Vector2i(25, 23), Vector2i(39, 23), Vector2i(39, 20), Vector2i(38, 20)]],
		[Vector2i(21, 20), d.DOWN, [Vector2i(21, 20), Vector2i(21, 14), Vector2i(27, 14), Vector2i(27, 13), Vector2i(20, 13), Vector2i(20, 21)]],
		[Vector2i(23, 20), d.UP, [Vector2i(23, 20), Vector2i(23, 28), Vector2i(26, 28), Vector2i(26, 27), Vector2i(32, 27), Vector2i(32, 28), Vector2i(29, 28)]],
		[Vector2i(15, 13), d.DOWN, [Vector2i(15, 13), Vector2i(15, 12), Vector2i(9, 12), Vector2i(9, 11), Vector2i(4, 11), Vector2i(4, 13), Vector2i(10, 13)]],
		[Vector2i(11, 24), d.DOWN, [Vector2i(11, 24), Vector2i(11, 20), Vector2i(7, 20), Vector2i(7, 27), Vector2i(5, 27), Vector2i(5, 21)]],
		[Vector2i(3, 8), d.DOWN, [Vector2i(3, 8), Vector2i(3, 3), Vector2i(1, 3), Vector2i(1, 8), Vector2i(2, 8), Vector2i(2, 7)]],
		[Vector2i(36, 1), d.RIGHT, [Vector2i(36, 1), Vector2i(30, 1), Vector2i(30, 2), Vector2i(36, 2)]],
		[Vector2i(32, 17), d.LEFT, [Vector2i(32, 17), Vector2i(33, 17), Vector2i(33, 15), Vector2i(29, 15), Vector2i(29, 13), Vector2i(33, 13)]],
		[Vector2i(16, 1), d.LEFT, [Vector2i(16, 1), Vector2i(28, 1), Vector2i(28, 0)]],
		[Vector2i(13, 5), d.UP, [Vector2i(13, 5), Vector2i(13, 9), Vector2i(11, 9), Vector2i(11, 6), Vector2i(9, 6), Vector2i(9, 9)]],
		[Vector2i(38, 25), d.RIGHT, [Vector2i(38, 25), Vector2i(35, 25), Vector2i(35, 28), Vector2i(38, 28), Vector2i(38, 26), Vector2i(36, 26)]],
		[Vector2i(1, 13), d.UP, [Vector2i(1, 13), Vector2i(1, 15), Vector2i(2, 15), Vector2i(2, 11)]],
		[Vector2i(28, 8), d.UP, [Vector2i(28, 8), Vector2i(28, 9), Vector2i(36, 9)]],
		[Vector2i(0, 22), d.UP, [Vector2i(0, 22), Vector2i(0, 26), Vector2i(1, 26), Vector2i(1, 24)]],
		[Vector2i(19, 22), d.DOWN, [Vector2i(19, 22), Vector2i(19, 15)]],
		[Vector2i(10, 24), d.DOWN, [Vector2i(10, 24), Vector2i(10, 21), Vector2i(9, 21), Vector2i(9, 24)]],
		[Vector2i(10, 27), d.DOWN, [Vector2i(10, 27), Vector2i(10, 26), Vector2i(15, 26), Vector2i(15, 27), Vector2i(12, 27)]],
		[Vector2i(1, 20), d.DOWN, [Vector2i(1, 20), Vector2i(1, 18), Vector2i(6, 18)]],
		[Vector2i(25, 24), d.UP, [Vector2i(25, 24), Vector2i(25, 25), Vector2i(26, 25), Vector2i(26, 24), Vector2i(30, 24)]],
		[Vector2i(5, 15), d.LEFT, [Vector2i(5, 15), Vector2i(8, 15), Vector2i(8, 14), Vector2i(4, 14)]],
		[Vector2i(6, 2), d.LEFT, [Vector2i(6, 2), Vector2i(9, 2), Vector2i(9, 0), Vector2i(8, 0), Vector2i(8, 1)]],
		[Vector2i(0, 28), d.LEFT, [Vector2i(0, 28), Vector2i(3, 28), Vector2i(3, 29), Vector2i(0, 29)]],
		[Vector2i(31, 24), d.LEFT, [Vector2i(31, 24), Vector2i(33, 24)]],
		[Vector2i(38, 13), d.DOWN, [Vector2i(38, 13), Vector2i(38, 11)]],
		[Vector2i(7, 1), d.DOWN, [Vector2i(7, 1), Vector2i(7, 0), Vector2i(6, 0)]],
	]
	var arrows := {}
	var tails := {}
	for shape in shapes:
		var vertices: Array[Vector2i] = []
		vertices.assign(shape[2])
		arrows[shape[0]] = shape[1]
		tails[shape[0]] = _tail_along(vertices)
	return PuzzleDefinition.new(40, 30, arrows, tails)

## Long bent paths test whether a long removal is satisfying without visual interweaving.
static func _build_knot_long_geometry() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var shapes := [
		[Vector2i(4, 2), d.UP, [Vector2i(4, 2), Vector2i(4, 18), Vector2i(14, 18), Vector2i(14, 6)]],
		[Vector2i(27, 21), d.DOWN, [Vector2i(27, 21), Vector2i(27, 5), Vector2i(18, 5), Vector2i(18, 15)]],
		[Vector2i(8, 0), d.UP, [Vector2i(8, 0), Vector2i(8, 12), Vector2i(12, 12), Vector2i(12, 16)]],
		[Vector2i(25, 23), d.DOWN, [Vector2i(25, 23), Vector2i(25, 10), Vector2i(21, 10), Vector2i(21, 20)]],
		[Vector2i(4, 0), d.UP, [Vector2i(4, 0)]],
		[Vector2i(27, 23), d.DOWN, [Vector2i(27, 23)]],
		[Vector2i(3, 10), d.LEFT, [Vector2i(3, 10)]],
		[Vector2i(28, 15), d.RIGHT, [Vector2i(28, 15)]],
	]
	var arrows := {}
	var tails := {}
	for shape in shapes:
		var vertices: Array[Vector2i] = []
		vertices.assign(shape[2])
		arrows[shape[0]] = shape[1]
		tails[shape[0]] = _tail_along(vertices)
	return PuzzleDefinition.new(32, 24, arrows, tails)

## Disjoint winding paths test whether following nearby intertwined routes increases tracing demand.
static func _build_knot_interwoven_paths() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var shapes := [
		[Vector2i(3, 2), d.UP, [Vector2i(3, 2), Vector2i(3, 19), Vector2i(12, 19), Vector2i(12, 9), Vector2i(9, 9), Vector2i(9, 14)]],
		[Vector2i(16, 22), d.DOWN, [Vector2i(16, 22), Vector2i(16, 4), Vector2i(6, 4), Vector2i(6, 10), Vector2i(8, 10)]],
		[Vector2i(28, 3), d.UP, [Vector2i(28, 3), Vector2i(28, 21), Vector2i(20, 21), Vector2i(20, 7), Vector2i(24, 7), Vector2i(24, 13)]],
		[Vector2i(3, 0), d.UP, [Vector2i(3, 0)]],
		[Vector2i(16, 23), d.DOWN, [Vector2i(16, 23)]],
		[Vector2i(28, 0), d.UP, [Vector2i(28, 0)]],
		[Vector2i(0, 10), d.RIGHT, [Vector2i(0, 10)]],
		[Vector2i(31, 12), d.LEFT, [Vector2i(31, 12)]],
	]
	var arrows := {}
	var tails := {}
	for shape in shapes:
		var vertices: Array[Vector2i] = []
		vertices.assign(shape[2])
		arrows[shape[0]] = shape[1]
		tails[shape[0]] = _tail_along(vertices)
	return PuzzleDefinition.new(32, 24, arrows, tails)

## Concentrated adjacent bent ribbons test tracing under a dense central knot.
static func _build_knot_dense_core() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var shapes := [
		[Vector2i(10, 8), d.UP, [Vector2i(10, 8), Vector2i(10, 16), Vector2i(11, 16), Vector2i(11, 12)]],
		[Vector2i(12, 8), d.UP, [Vector2i(12, 8), Vector2i(12, 16), Vector2i(13, 16), Vector2i(13, 12)]],
		[Vector2i(14, 8), d.UP, [Vector2i(14, 8), Vector2i(14, 16), Vector2i(15, 16), Vector2i(15, 12)]],
		[Vector2i(16, 8), d.UP, [Vector2i(16, 8), Vector2i(16, 16), Vector2i(17, 16), Vector2i(17, 12)]],
		[Vector2i(18, 8), d.UP, [Vector2i(18, 8), Vector2i(18, 16), Vector2i(19, 16), Vector2i(19, 12)]],
		[Vector2i(20, 8), d.UP, [Vector2i(20, 8), Vector2i(20, 16), Vector2i(21, 16), Vector2i(21, 12)]],
		[Vector2i(22, 8), d.UP, [Vector2i(22, 8), Vector2i(22, 16), Vector2i(23, 16), Vector2i(23, 12)]],
		[Vector2i(24, 8), d.UP, [Vector2i(24, 8), Vector2i(24, 16), Vector2i(25, 16), Vector2i(25, 12)]],
		[Vector2i(10, 6), d.UP, [Vector2i(10, 6)]],
		[Vector2i(14, 6), d.UP, [Vector2i(14, 6)]],
		[Vector2i(18, 6), d.UP, [Vector2i(18, 6)]],
		[Vector2i(22, 6), d.UP, [Vector2i(22, 6)]],
		[Vector2i(13, 18), d.LEFT, [Vector2i(13, 18)]],
		[Vector2i(17, 18), d.LEFT, [Vector2i(17, 18)]],
		[Vector2i(21, 18), d.LEFT, [Vector2i(21, 18)]],
		[Vector2i(25, 18), d.LEFT, [Vector2i(25, 18)]],
	]
	var arrows := {}
	var tails := {}
	for shape in shapes:
		var vertices: Array[Vector2i] = []
		vertices.assign(shape[2])
		arrows[shape[0]] = shape[1]
		tails[shape[0]] = _tail_along(vertices)
	return PuzzleDefinition.new(36, 28, arrows, tails)

## Widely separated local groups test whether region boundaries make a large board approachable.
static func _build_knot_regions() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var shapes := [
		[Vector2i(3, 2), d.UP, [Vector2i(3, 2), Vector2i(3, 12), Vector2i(12, 12), Vector2i(12, 5)]],
		[Vector2i(4, 8), d.LEFT, [Vector2i(4, 8)]],
		[Vector2i(8, 0), d.UP, [Vector2i(8, 0)]],
		[Vector2i(29, 2), d.UP, [Vector2i(29, 2), Vector2i(29, 12), Vector2i(39, 12), Vector2i(39, 4)]],
		[Vector2i(30, 8), d.LEFT, [Vector2i(30, 8)]],
		[Vector2i(34, 0), d.UP, [Vector2i(34, 0)]],
		[Vector2i(5, 29), d.DOWN, [Vector2i(5, 29), Vector2i(5, 19), Vector2i(15, 19), Vector2i(15, 26)]],
		[Vector2i(12, 23), d.RIGHT, [Vector2i(12, 23)]],
		[Vector2i(9, 31), d.DOWN, [Vector2i(9, 31)]],
		[Vector2i(30, 29), d.DOWN, [Vector2i(30, 29), Vector2i(30, 19), Vector2i(42, 19), Vector2i(42, 26)]],
		[Vector2i(39, 23), d.RIGHT, [Vector2i(39, 23)]],
		[Vector2i(34, 31), d.DOWN, [Vector2i(34, 31)]],
		[Vector2i(0, 9), d.RIGHT, [Vector2i(0, 9)]],
	]
	var arrows := {}
	var tails := {}
	for shape in shapes:
		var vertices: Array[Vector2i] = []
		vertices.assign(shape[2])
		arrows[shape[0]] = shape[1]
		tails[shape[0]] = _tail_along(vertices)
	return PuzzleDefinition.new(48, 32, arrows, tails)

## One long path holds several arrows back, testing the visual payoff of its departure.
static func _build_knot_single_release() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var shapes := [
		[Vector2i(2, 20), d.LEFT, [Vector2i(2, 20), Vector2i(20, 20), Vector2i(20, 4), Vector2i(35, 4), Vector2i(35, 25), Vector2i(5, 25)]],
		[Vector2i(0, 20), d.LEFT, [Vector2i(0, 20)]],
		[Vector2i(1, 20), d.LEFT, [Vector2i(1, 20)]],
		[Vector2i(24, 8), d.UP, [Vector2i(24, 8)]],
		[Vector2i(25, 15), d.RIGHT, [Vector2i(25, 15)]],
		[Vector2i(8, 22), d.DOWN, [Vector2i(8, 22)]],
		[Vector2i(14, 28), d.DOWN, [Vector2i(14, 28)]],
		[Vector2i(0, 29), d.RIGHT, [Vector2i(0, 29)]],
	]
	var arrows := {}
	var tails := {}
	for shape in shapes:
		var vertices: Array[Vector2i] = []
		vertices.assign(shape[2])
		arrows[shape[0]] = shape[1]
		tails[shape[0]] = _tail_along(vertices)
	return PuzzleDefinition.new(40, 30, arrows, tails)

## Repeated winding bands intentionally test when geometric busy-ness becomes tedious.
static func _build_knot_boundary() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var shapes := [
		[Vector2i(3, 2), d.UP, [Vector2i(3, 2), Vector2i(3, 7), Vector2i(20, 7), Vector2i(20, 3)]],
		[Vector2i(25, 2), d.UP, [Vector2i(25, 2), Vector2i(25, 7), Vector2i(43, 7), Vector2i(43, 3)]],
		[Vector2i(5, 10), d.UP, [Vector2i(5, 10), Vector2i(5, 15), Vector2i(22, 15), Vector2i(22, 11)]],
		[Vector2i(27, 10), d.UP, [Vector2i(27, 10), Vector2i(27, 15), Vector2i(45, 15), Vector2i(45, 11)]],
		[Vector2i(3, 18), d.UP, [Vector2i(3, 18), Vector2i(3, 23), Vector2i(20, 23), Vector2i(20, 19)]],
		[Vector2i(25, 18), d.UP, [Vector2i(25, 18), Vector2i(25, 23), Vector2i(43, 23), Vector2i(43, 19)]],
		[Vector2i(5, 26), d.UP, [Vector2i(5, 26), Vector2i(5, 31), Vector2i(22, 31), Vector2i(22, 27)]],
		[Vector2i(27, 26), d.UP, [Vector2i(27, 26), Vector2i(27, 31), Vector2i(45, 31), Vector2i(45, 27)]],
		[Vector2i(3, 0), d.UP, [Vector2i(3, 0)]],
		[Vector2i(25, 0), d.UP, [Vector2i(25, 0)]],
		[Vector2i(5, 8), d.UP, [Vector2i(5, 8)]],
		[Vector2i(27, 8), d.UP, [Vector2i(27, 8)]],
		[Vector2i(3, 16), d.UP, [Vector2i(3, 16)]],
		[Vector2i(25, 16), d.UP, [Vector2i(25, 16)]],
		[Vector2i(5, 24), d.UP, [Vector2i(5, 24)]],
		[Vector2i(27, 24), d.UP, [Vector2i(27, 24)]],
		[Vector2i(0, 4), d.RIGHT, [Vector2i(0, 4)]],
		[Vector2i(47, 12), d.LEFT, [Vector2i(47, 12)]],
		[Vector2i(0, 20), d.RIGHT, [Vector2i(0, 20)]],
		[Vector2i(47, 28), d.LEFT, [Vector2i(47, 28)]],
		[Vector2i(22, 8), d.RIGHT, [Vector2i(22, 8), Vector2i(6, 8), Vector2i(6, 9), Vector2i(23, 9)]],
		[Vector2i(45, 8), d.RIGHT, [Vector2i(45, 8), Vector2i(29, 8), Vector2i(29, 9), Vector2i(46, 9)]],
		[Vector2i(23, 16), d.RIGHT, [Vector2i(23, 16), Vector2i(7, 16), Vector2i(7, 17), Vector2i(24, 17)]],
		[Vector2i(45, 16), d.RIGHT, [Vector2i(45, 16), Vector2i(30, 16), Vector2i(30, 17), Vector2i(46, 17)]],
		[Vector2i(22, 24), d.RIGHT, [Vector2i(22, 24), Vector2i(6, 24), Vector2i(6, 25), Vector2i(23, 25)]],
		[Vector2i(45, 24), d.RIGHT, [Vector2i(45, 24), Vector2i(29, 24), Vector2i(29, 25), Vector2i(46, 25)]],
		[Vector2i(23, 32), d.RIGHT, [Vector2i(23, 32), Vector2i(7, 32), Vector2i(7, 33), Vector2i(24, 33)]],
		[Vector2i(45, 32), d.RIGHT, [Vector2i(45, 32), Vector2i(30, 32), Vector2i(30, 33), Vector2i(46, 33)]],
	]
	var arrows := {}
	var tails := {}
	for shape in shapes:
		var vertices: Array[Vector2i] = []
		vertices.assign(shape[2])
		arrows[shape[0]] = shape[1]
		tails[shape[0]] = _tail_along(vertices)
	return PuzzleDefinition.new(48, 36, arrows, tails)

## Reference Knot: a 46x32 board packed with bent and straight arrows, over 90%
## of the cells occupied and the longest over 40 cells, so almost no empty space
## remains. It grew from a hand-composed skeleton: a north comb of six long
## parallel arrows held by a row of vertical gates and an east wall, a chain
## along the top edge that opens the gates, a full-width bridge arrow across the
## middle held by one bent arrow, and tails along the bottom edge that hold the
## east wall. Arrows were then added around that skeleton, long ones first and
## short ones last to fill the gaps, found once by a seeded search that kept
## every step solvable. The layout is fixed literal data, not generated at
## runtime. Sequencing comes only from the ordinary blocking rules; nothing here
## encodes a solve order.
static func _build_reference_knot() -> PuzzleDefinition:
	var d := PuzzleDefinition.Direction
	var shapes := [
		[Vector2i(14, 2), d.RIGHT, [Vector2i(14, 2), Vector2i(2, 2)]],
		[Vector2i(16, 4), d.RIGHT, [Vector2i(16, 4), Vector2i(2, 4)]],
		[Vector2i(13, 6), d.RIGHT, [Vector2i(13, 6), Vector2i(2, 6)]],
		[Vector2i(17, 8), d.RIGHT, [Vector2i(17, 8), Vector2i(2, 8)]],
		[Vector2i(15, 10), d.RIGHT, [Vector2i(15, 10), Vector2i(2, 10)]],
		[Vector2i(14, 12), d.RIGHT, [Vector2i(14, 12), Vector2i(2, 12)]],
		[Vector2i(23, 10), d.UP, [Vector2i(23, 10)]],
		[Vector2i(21, 6), d.UP, [Vector2i(21, 6)]],
		[Vector2i(40, 0), d.RIGHT, [Vector2i(40, 0), Vector2i(26, 0)]],
		[Vector2i(24, 0), d.RIGHT, [Vector2i(24, 0)]],
		[Vector2i(24, 1), d.UP, [Vector2i(24, 1), Vector2i(24, 9)]],
		[Vector2i(30, 1), d.UP, [Vector2i(30, 1), Vector2i(30, 13), Vector2i(36, 13)]],
		[Vector2i(34, 1), d.UP, [Vector2i(34, 1), Vector2i(34, 8)]],
		[Vector2i(42, 1), d.UP, [Vector2i(42, 1), Vector2i(42, 11)]],
		[Vector2i(0, 20), d.DOWN, [Vector2i(0, 20), Vector2i(0, 16), Vector2i(1, 16)]],
		[Vector2i(2, 17), d.LEFT, [Vector2i(2, 17), Vector2i(43, 17)]],
		[Vector2i(19, 19), d.UP, [Vector2i(19, 19), Vector2i(19, 22), Vector2i(14, 22)]],
		[Vector2i(20, 20), d.LEFT, [Vector2i(20, 20), Vector2i(21, 20), Vector2i(21, 23), Vector2i(8, 23), Vector2i(8, 21)]],
		[Vector2i(10, 25), d.DOWN, [Vector2i(10, 25), Vector2i(10, 24), Vector2i(4, 24), Vector2i(4, 27)]],
		[Vector2i(26, 24), d.DOWN, [Vector2i(26, 24), Vector2i(26, 19), Vector2i(34, 19)]],
		[Vector2i(30, 21), d.LEFT, [Vector2i(30, 21), Vector2i(44, 21), Vector2i(44, 29), Vector2i(38, 29)]],
		[Vector2i(42, 25), d.UP, [Vector2i(42, 25), Vector2i(42, 28), Vector2i(28, 28)]],
		[Vector2i(22, 30), d.UP, [Vector2i(22, 30), Vector2i(22, 31), Vector2i(10, 31)]],
		[Vector2i(34, 30), d.UP, [Vector2i(34, 30), Vector2i(34, 31), Vector2i(30, 31)]],
		[Vector2i(44, 31), d.LEFT, [Vector2i(44, 31), Vector2i(45, 31), Vector2i(45, 1)]],
		[Vector2i(25, 16), d.DOWN, [Vector2i(25, 16), Vector2i(25, 5), Vector2i(29, 5), Vector2i(29, 1), Vector2i(25, 1), Vector2i(25, 4), Vector2i(27, 4), Vector2i(27, 2), Vector2i(28, 2), Vector2i(28, 4)]],
		[Vector2i(12, 29), d.UP, [Vector2i(12, 29), Vector2i(12, 30), Vector2i(6, 30), Vector2i(6, 25), Vector2i(9, 25), Vector2i(9, 27)]],
		[Vector2i(26, 11), d.UP, [Vector2i(26, 11), Vector2i(26, 16), Vector2i(31, 16), Vector2i(31, 14), Vector2i(27, 14), Vector2i(27, 10), Vector2i(29, 10), Vector2i(29, 6), Vector2i(27, 6), Vector2i(27, 9)]],
		[Vector2i(8, 5), d.LEFT, [Vector2i(8, 5), Vector2i(22, 5), Vector2i(22, 9), Vector2i(13, 9)]],
		[Vector2i(44, 12), d.UP, [Vector2i(44, 12), Vector2i(44, 20), Vector2i(32, 20)]],
		[Vector2i(38, 6), d.UP, [Vector2i(38, 6), Vector2i(38, 15), Vector2i(32, 15), Vector2i(32, 14), Vector2i(34, 14)]],
		[Vector2i(7, 11), d.RIGHT, [Vector2i(7, 11), Vector2i(0, 11), Vector2i(0, 13), Vector2i(9, 13), Vector2i(9, 16), Vector2i(13, 16), Vector2i(13, 13), Vector2i(11, 13), Vector2i(11, 15), Vector2i(12, 15)]],
		[Vector2i(10, 3), d.LEFT, [Vector2i(10, 3), Vector2i(23, 3), Vector2i(23, 0), Vector2i(20, 0), Vector2i(20, 2), Vector2i(22, 2), Vector2i(22, 1), Vector2i(21, 1)]],
		[Vector2i(25, 21), d.DOWN, [Vector2i(25, 21), Vector2i(25, 18), Vector2i(39, 18), Vector2i(39, 19), Vector2i(35, 19)]],
		[Vector2i(16, 18), d.LEFT, [Vector2i(16, 18), Vector2i(24, 18), Vector2i(24, 25), Vector2i(18, 25)]],
		[Vector2i(9, 1), d.LEFT, [Vector2i(9, 1), Vector2i(17, 1), Vector2i(17, 0), Vector2i(19, 0), Vector2i(19, 2), Vector2i(15, 2)]],
		[Vector2i(18, 26), d.RIGHT, [Vector2i(18, 26), Vector2i(14, 26), Vector2i(14, 30), Vector2i(18, 30), Vector2i(18, 27), Vector2i(15, 27), Vector2i(15, 29), Vector2i(17, 29), Vector2i(17, 28), Vector2i(16, 28)]],
		[Vector2i(36, 11), d.UP, [Vector2i(36, 11), Vector2i(36, 12), Vector2i(37, 12), Vector2i(37, 1), Vector2i(41, 1), Vector2i(41, 3), Vector2i(38, 3), Vector2i(38, 5), Vector2i(41, 5), Vector2i(41, 4), Vector2i(39, 4)]],
		[Vector2i(0, 24), d.DOWN, [Vector2i(0, 24), Vector2i(0, 21), Vector2i(7, 21), Vector2i(7, 23), Vector2i(1, 23), Vector2i(1, 31), Vector2i(9, 31)]],
		[Vector2i(35, 3), d.UP, [Vector2i(35, 3), Vector2i(35, 12), Vector2i(31, 12), Vector2i(31, 4), Vector2i(33, 4), Vector2i(33, 11), Vector2i(34, 11), Vector2i(34, 9)]],
		[Vector2i(24, 27), d.DOWN, [Vector2i(24, 27), Vector2i(24, 26), Vector2i(31, 26), Vector2i(31, 27), Vector2i(41, 27), Vector2i(41, 22), Vector2i(28, 22), Vector2i(28, 25), Vector2i(26, 25)]],
		[Vector2i(43, 10), d.UP, [Vector2i(43, 10), Vector2i(43, 16), Vector2i(32, 16)]],
		[Vector2i(37, 23), d.UP, [Vector2i(37, 23), Vector2i(37, 26), Vector2i(32, 26), Vector2i(32, 23), Vector2i(29, 23), Vector2i(29, 25), Vector2i(31, 25), Vector2i(31, 24), Vector2i(30, 24)]],
		[Vector2i(5, 20), d.LEFT, [Vector2i(5, 20), Vector2i(16, 20), Vector2i(16, 19), Vector2i(18, 19), Vector2i(18, 21), Vector2i(13, 21)]],
		[Vector2i(0, 7), d.UP, [Vector2i(0, 7), Vector2i(0, 10), Vector2i(1, 10), Vector2i(1, 7), Vector2i(12, 7)]],
		[Vector2i(0, 1), d.UP, [Vector2i(0, 1), Vector2i(0, 6), Vector2i(1, 6), Vector2i(1, 0), Vector2i(8, 0)]],
		[Vector2i(29, 31), d.DOWN, [Vector2i(29, 31), Vector2i(29, 29), Vector2i(37, 29), Vector2i(37, 31), Vector2i(43, 31), Vector2i(43, 30), Vector2i(44, 30)]],
		[Vector2i(22, 12), d.UP, [Vector2i(22, 12), Vector2i(22, 16), Vector2i(14, 16), Vector2i(14, 13), Vector2i(16, 13), Vector2i(16, 10), Vector2i(21, 10), Vector2i(21, 13)]],
		[Vector2i(41, 8), d.DOWN, [Vector2i(41, 8), Vector2i(41, 6), Vector2i(39, 6), Vector2i(39, 15), Vector2i(40, 15), Vector2i(40, 7)]],
		[Vector2i(1, 18), d.LEFT, [Vector2i(1, 18), Vector2i(8, 18), Vector2i(8, 19), Vector2i(10, 19), Vector2i(10, 18), Vector2i(14, 18), Vector2i(14, 19), Vector2i(11, 19)]],
		[Vector2i(7, 15), d.DOWN, [Vector2i(7, 15), Vector2i(7, 14), Vector2i(1, 14), Vector2i(1, 15), Vector2i(6, 15), Vector2i(6, 16), Vector2i(2, 16)]],
		[Vector2i(23, 20), d.UP, [Vector2i(23, 20), Vector2i(23, 24), Vector2i(11, 24), Vector2i(11, 29), Vector2i(7, 29), Vector2i(7, 28)]],
		[Vector2i(2, 9), d.LEFT, [Vector2i(2, 9), Vector2i(9, 9)]],
		[Vector2i(3, 26), d.RIGHT, [Vector2i(3, 26), Vector2i(2, 26), Vector2i(2, 30), Vector2i(5, 30), Vector2i(5, 28), Vector2i(4, 28)]],
		[Vector2i(18, 14), d.DOWN, [Vector2i(18, 14), Vector2i(18, 11), Vector2i(17, 11), Vector2i(17, 15), Vector2i(15, 15), Vector2i(15, 14), Vector2i(16, 14)]],
		[Vector2i(32, 3), d.LEFT, [Vector2i(32, 3), Vector2i(33, 3), Vector2i(33, 1), Vector2i(31, 1), Vector2i(31, 2), Vector2i(32, 2)]],
		[Vector2i(23, 28), d.UP, [Vector2i(23, 28), Vector2i(23, 31), Vector2i(27, 31)]],
		[Vector2i(27, 24), d.DOWN, [Vector2i(27, 24), Vector2i(27, 20), Vector2i(31, 20)]],
		[Vector2i(18, 7), d.DOWN, [Vector2i(18, 7), Vector2i(18, 6), Vector2i(15, 6), Vector2i(15, 7), Vector2i(13, 7)]],
		[Vector2i(13, 28), d.RIGHT, [Vector2i(13, 28), Vector2i(12, 28), Vector2i(12, 25), Vector2i(15, 25)]],
		[Vector2i(33, 23), d.UP, [Vector2i(33, 23), Vector2i(33, 25), Vector2i(36, 25), Vector2i(36, 23), Vector2i(34, 23), Vector2i(34, 24), Vector2i(35, 24)]],
		[Vector2i(9, 22), d.LEFT, [Vector2i(9, 22), Vector2i(12, 22), Vector2i(12, 21), Vector2i(9, 21)]],
		[Vector2i(20, 30), d.DOWN, [Vector2i(20, 30), Vector2i(20, 26), Vector2i(19, 26), Vector2i(19, 28)]],
		[Vector2i(23, 12), d.UP, [Vector2i(23, 12), Vector2i(23, 16), Vector2i(24, 16), Vector2i(24, 11)]],
		[Vector2i(43, 1), d.LEFT, [Vector2i(43, 1), Vector2i(44, 1), Vector2i(44, 3), Vector2i(43, 3), Vector2i(43, 9), Vector2i(44, 9), Vector2i(44, 5)]],
		[Vector2i(43, 28), d.DOWN, [Vector2i(43, 28), Vector2i(43, 22), Vector2i(42, 22), Vector2i(42, 24)]],
		[Vector2i(39, 26), d.DOWN, [Vector2i(39, 26), Vector2i(39, 23), Vector2i(40, 23), Vector2i(40, 26)]],
		[Vector2i(43, 18), d.UP, [Vector2i(43, 18), Vector2i(43, 19), Vector2i(40, 19), Vector2i(40, 18), Vector2i(42, 18)]],
		[Vector2i(36, 3), d.UP, [Vector2i(36, 3), Vector2i(36, 10)]],
		[Vector2i(22, 26), d.UP, [Vector2i(22, 26), Vector2i(22, 29), Vector2i(21, 29), Vector2i(21, 26)]],
		[Vector2i(42, 12), d.UP, [Vector2i(42, 12), Vector2i(42, 15), Vector2i(41, 15), Vector2i(41, 11)]],
		[Vector2i(24, 30), d.DOWN, [Vector2i(24, 30), Vector2i(24, 28), Vector2i(27, 28), Vector2i(27, 27), Vector2i(29, 27)]],
		[Vector2i(28, 30), d.DOWN, [Vector2i(28, 30), Vector2i(28, 29), Vector2i(25, 29), Vector2i(25, 30), Vector2i(27, 30)]],
		[Vector2i(32, 11), d.DOWN, [Vector2i(32, 11), Vector2i(32, 5)]],
		[Vector2i(15, 11), d.RIGHT, [Vector2i(15, 11), Vector2i(11, 11)]],
		[Vector2i(3, 5), d.LEFT, [Vector2i(3, 5), Vector2i(6, 5)]],
		[Vector2i(1, 20), d.DOWN, [Vector2i(1, 20), Vector2i(1, 19), Vector2i(5, 19)]],
		[Vector2i(28, 15), d.LEFT, [Vector2i(28, 15), Vector2i(30, 15)]],
		[Vector2i(7, 3), d.LEFT, [Vector2i(7, 3), Vector2i(9, 3)]],
		[Vector2i(22, 21), d.UP, [Vector2i(22, 21), Vector2i(22, 23)]],
		[Vector2i(36, 31), d.DOWN, [Vector2i(36, 31), Vector2i(36, 30), Vector2i(35, 30)]],
		[Vector2i(20, 15), d.DOWN, [Vector2i(20, 15), Vector2i(20, 13)]],
		[Vector2i(26, 6), d.UP, [Vector2i(26, 6), Vector2i(26, 10)]],
		[Vector2i(29, 13), d.RIGHT, [Vector2i(29, 13), Vector2i(28, 13), Vector2i(28, 11), Vector2i(29, 11), Vector2i(29, 12)]],
		[Vector2i(8, 27), d.RIGHT, [Vector2i(8, 27), Vector2i(7, 27), Vector2i(7, 26), Vector2i(8, 26)]],
		[Vector2i(38, 24), d.UP, [Vector2i(38, 24), Vector2i(38, 26)]],
		[Vector2i(13, 0), d.LEFT, [Vector2i(13, 0), Vector2i(16, 0)]],
		[Vector2i(3, 22), d.LEFT, [Vector2i(3, 22), Vector2i(6, 22)]],
		[Vector2i(2, 3), d.LEFT, [Vector2i(2, 3), Vector2i(6, 3)]],
		[Vector2i(0, 29), d.DOWN, [Vector2i(0, 29), Vector2i(0, 28)]],
		[Vector2i(36, 1), d.UP, [Vector2i(36, 1), Vector2i(36, 2)]],
		[Vector2i(1, 22), d.LEFT, [Vector2i(1, 22), Vector2i(2, 22)]],
		[Vector2i(2, 20), d.LEFT, [Vector2i(2, 20), Vector2i(3, 20)]],
		[Vector2i(23, 26), d.UP, [Vector2i(23, 26), Vector2i(23, 27)]],
		[Vector2i(19, 11), d.UP, [Vector2i(19, 11), Vector2i(19, 12)]],
		[Vector2i(25, 23), d.DOWN, [Vector2i(25, 23), Vector2i(25, 22)]],
		[Vector2i(20, 19), d.LEFT, [Vector2i(20, 19), Vector2i(21, 19)]],
		[Vector2i(19, 30), d.DOWN, [Vector2i(19, 30), Vector2i(19, 29)]],
		[Vector2i(36, 14), d.RIGHT, [Vector2i(36, 14), Vector2i(35, 14)]],
		[Vector2i(23, 8), d.UP, [Vector2i(23, 8), Vector2i(23, 9)]],
		[Vector2i(42, 0), d.RIGHT, [Vector2i(42, 0), Vector2i(41, 0)]],
		[Vector2i(8, 16), d.RIGHT, [Vector2i(8, 16), Vector2i(7, 16)]],
		[Vector2i(40, 30), d.RIGHT, [Vector2i(40, 30), Vector2i(39, 30)]],
		[Vector2i(13, 30), d.DOWN, [Vector2i(13, 30), Vector2i(13, 29)]],
		[Vector2i(37, 13), d.UP, [Vector2i(37, 13), Vector2i(37, 14)]],
		[Vector2i(21, 15), d.DOWN, [Vector2i(21, 15), Vector2i(21, 14)]],
		[Vector2i(4, 29), d.RIGHT, [Vector2i(4, 29), Vector2i(3, 29)]],
		[Vector2i(20, 12), d.DOWN, [Vector2i(20, 12), Vector2i(20, 11)]],
		[Vector2i(20, 8), d.DOWN, [Vector2i(20, 8), Vector2i(20, 7)]],
		[Vector2i(6, 19), d.LEFT, [Vector2i(6, 19), Vector2i(7, 19)]],
		[Vector2i(10, 13), d.UP, [Vector2i(10, 13), Vector2i(10, 14)]],
		[Vector2i(42, 30), d.RIGHT, [Vector2i(42, 30), Vector2i(41, 30)]],
		[Vector2i(30, 30), d.LEFT, [Vector2i(30, 30), Vector2i(31, 30)]],
		[Vector2i(9, 11), d.RIGHT, [Vector2i(9, 11), Vector2i(8, 11)]],
		[Vector2i(21, 4), d.RIGHT, [Vector2i(21, 4), Vector2i(20, 4)]],
	]
	var arrows := {}
	var tails := {}
	for shape in shapes:
		var vertices: Array[Vector2i] = []
		vertices.assign(shape[2])
		arrows[shape[0]] = shape[1]
		tails[shape[0]] = _tail_along(vertices)
	return PuzzleDefinition.new(46, 32, arrows, tails)
