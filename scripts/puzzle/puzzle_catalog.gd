class_name PuzzleCatalog
extends RefCounted
## Static registry of every playable level, read from the committed level
## packs under res://levels (see PuzzlePackFormat): catalog.json names the
## packs in catalog order, and each pack holds its levels in order. Every entry
## carries a stable id (independent of position, title, pack or file path), a
## display title and a purpose group (Foundations, Puzzle Lab, ArrowSpark
## Levels, Generated Levels) that is pure metadata: it drives Level Select sections,
## group-relative numbering and Next Puzzle scope, and never affects rules.
## Never instantiated; every member is static. The packs are read once per
## process; get_definition() still builds a fresh PuzzleDefinition from the
## stored level data on every call, so no two calls share mutable
## substructure. A pack or level that fails to load is reported through
## load_errors() and push_error and left out, never silently dropped; the
## catalog regression gate fails on any load error.

const LEVELS_ROOT := "res://levels"

const GROUP_ARROWSPARK_LEVELS := "arrowspark_levels"
const GROUP_FOUNDATIONS := "foundations"
const GROUP_GENERATED := "generated"
const GROUP_PUZZLE_LAB := "puzzle_lab"
const GROUP_TITLES := {
	GROUP_ARROWSPARK_LEVELS: "ArrowSpark Levels",
	GROUP_FOUNDATIONS: "Foundations",
	GROUP_GENERATED: "Generated Levels",
	GROUP_PUZZLE_LAB: "Puzzle Lab",
}

static var _loaded := false
static var _entries: Array[Dictionary] = []
static var _index_by_id: Dictionary = {}
static var _load_errors: Array[String] = []

static func _ensure_entries() -> void:
	if _loaded:
		return
	_loaded = true
	var result := PuzzlePackFormat.load_catalog(LEVELS_ROOT)
	_load_errors.assign(result["errors"])
	for message in _load_errors:
		push_error(message)
	for record in result["levels"]:
		if _index_by_id.has(record["id"]):
			continue # reported by the catalog gate's pack audit
		_index_by_id[record["id"]] = _entries.size()
		_entries.append(record)

## Every problem found while reading the packs, each naming its pack and
## level. Empty for a healthy catalog.
static func load_errors() -> Array[String]:
	_ensure_entries()
	return _load_errors.duplicate()

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
	return _index_by_id.get(id, -1)

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
	return [GROUP_ARROWSPARK_LEVELS, GROUP_FOUNDATIONS, GROUP_PUZZLE_LAB, GROUP_GENERATED]

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
## if the id is unknown. Every call rebuilds the definition from the stored
## level data, so no two calls ever share mutable substructure.
static func get_definition(id: String) -> PuzzleDefinition:
	var index := index_of(id)
	if index == -1:
		return null
	return PuzzlePackFormat.record_to_definition(_entries[index])
