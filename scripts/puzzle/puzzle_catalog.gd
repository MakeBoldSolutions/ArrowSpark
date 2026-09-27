class_name PuzzleCatalog
extends RefCounted
## Static registry of the eight authored puzzles. Never instantiated; every
## member is static. Each entry pairs a stable id (independent of array
## position, title, or any filesystem path) with a display title and a
## zero-argument builder returning a freshly constructed PuzzleDefinition —
## exactly PuzzleDefinition.create_fixed()'s existing literal-construction
## style, so isolation (no shared mutable substructure across calls) falls
## out of the construction pattern itself, with no caching layer.

static var _entries: Array[Dictionary] = []

static func _ensure_entries() -> void:
	if not _entries.is_empty():
		return
	_entries = [
		{"id": "intro", "title": "Simple Introduction", "build": Callable(PuzzleCatalog, "_build_intro")},
		{"id": "first_bend", "title": "First Bend", "build": Callable(PuzzleCatalog, "_build_first_bend")},
		{"id": "multi_bend", "title": "Multiple Bends", "build": Callable(PuzzleCatalog, "_build_multi_bend")},
		{"id": "dependency_chain", "title": "Dependency Chain", "build": Callable(PuzzleCatalog, "_build_dependency_chain")},
		{"id": "forced_sequence", "title": "Forced Sequence", "build": Callable(PuzzleCatalog, "_build_forced_sequence")},
		{"id": "multiple_choices", "title": "Multiple Choices", "build": Callable(PuzzleCatalog, "_build_multiple_choices")},
		{"id": "dense_board", "title": "Dense Board", "build": Callable(PuzzleCatalog, "_build_dense_board")},
		{"id": "subtle_blockers", "title": "Subtle Blockers", "build": Callable(PuzzleCatalog, "_build_subtle_blockers")},
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
