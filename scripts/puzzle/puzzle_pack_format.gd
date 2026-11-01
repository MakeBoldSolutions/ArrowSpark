class_name PuzzlePackFormat
extends RefCounted
## Reads, audits and writes level packs: committed JSON files under a levels
## root (`catalog.json` naming the packs in catalog order, then
## `packs/<name>.json` holding each pack's levels). The one place the pack
## format is defined, shared by PuzzleCatalog (reading) and the pack-build
## tool (writing), so both agree byte for byte. Never decides validity or
## solvability itself: boards are checked through PuzzleDefinition,
## PuzzleSolver and PuzzleContentVersion.
##
## A level record is a Dictionary with id, title, group, width, height,
## content_version, provenance, optional notes, and arrows, where each arrow is
## [direction name, vertices]: vertices[0] is the head, then every cell where
## the path turns, then the tail end.

const CATALOG_FORMAT := "arrowspark-catalog/1"
const PACK_FORMAT := "arrowspark-pack/1"
const PROVENANCE_KINDS := ["hand-authored", "generated"]

const DIRECTION_NAMES := {
	PuzzleDefinition.Direction.UP: "up",
	PuzzleDefinition.Direction.DOWN: "down",
	PuzzleDefinition.Direction.LEFT: "left",
	PuzzleDefinition.Direction.RIGHT: "right",
}
const DIRECTIONS_BY_NAME := {
	"up": PuzzleDefinition.Direction.UP,
	"down": PuzzleDefinition.Direction.DOWN,
	"left": PuzzleDefinition.Direction.LEFT,
	"right": PuzzleDefinition.Direction.RIGHT,
}

## Loads `<root>/catalog.json` and every pack it lists, in order. Returns
## {"levels": Array (records, each tagged with "pack"), "errors": Array[String]}.
## A listed pack whose file is missing is an error, except `skip_pack`, which
## is never read (a pack being built or rebuilt). A malformed level is
## reported and left out; it never stops the other levels from loading.
static func load_catalog(root: String, skip_pack: String = "") -> Dictionary:
	var levels: Array = []
	var errors: Array[String] = []
	var manifest_path := root.path_join("catalog.json")
	var manifest_text = _read_text(manifest_path)
	if manifest_text == null:
		errors.append("catalog manifest %s is missing or unreadable" % manifest_path)
		return {"levels": levels, "errors": errors}
	var packs := parse_manifest(manifest_text, errors)
	for pack_name in packs:
		if pack_name == skip_pack:
			continue
		var pack_path := root.path_join("packs").path_join("%s.json" % pack_name)
		var pack_text = _read_text(pack_path)
		if pack_text == null:
			errors.append("pack '%s' is listed in catalog.json but %s is missing or unreadable" % [pack_name, pack_path])
			continue
		var parsed := parse_pack(pack_text, pack_name)
		levels.append_array(parsed["levels"])
		errors.append_array(parsed["errors"])
	return {"levels": levels, "errors": errors}

## Pack names from catalog manifest text, in order; problems go to `errors`.
static func parse_manifest(text: String, errors: Array[String]) -> Array[String]:
	var names: Array[String] = []
	var data = _parse_json(text)
	if data is String:
		errors.append("catalog.json is not valid JSON: %s" % data)
		return names
	if not (data is Dictionary):
		errors.append("catalog.json is not a JSON object")
		return names
	if data.get("format") != CATALOG_FORMAT:
		errors.append("catalog.json format must be '%s'" % CATALOG_FORMAT)
		return names
	var packs = data.get("packs")
	if not (packs is Array):
		errors.append("catalog.json must list its packs in a 'packs' array")
		return names
	for name in packs:
		if not (name is String) or (name as String).is_empty():
			errors.append("catalog.json lists a pack name that is not a non-empty string")
		elif names.has(name):
			errors.append("catalog.json lists pack '%s' more than once" % name)
		else:
			names.append(name)
	return names

## Parses one pack's text. Returns {"levels": Array, "errors": Array[String]};
## every returned level is well-formed and passes board validation.
static func parse_pack(text: String, pack_name: String) -> Dictionary:
	var levels: Array = []
	var errors: Array[String] = []
	var data = _parse_json(text)
	if data is String:
		errors.append("pack '%s' is not valid JSON: %s" % [pack_name, data])
		return {"levels": levels, "errors": errors}
	if not (data is Dictionary):
		errors.append("pack '%s' is not a JSON object" % pack_name)
		return {"levels": levels, "errors": errors}
	if data.get("format") != PACK_FORMAT:
		errors.append("pack '%s' format must be '%s'" % [pack_name, PACK_FORMAT])
		return {"levels": levels, "errors": errors}
	if data.get("pack") != pack_name:
		errors.append("pack '%s' names itself '%s'" % [pack_name, data.get("pack")])
	var items = data.get("levels")
	if not (items is Array):
		errors.append("pack '%s' must hold a 'levels' array" % pack_name)
		return {"levels": levels, "errors": errors}
	for i in range(items.size()):
		var record = _parse_level(items[i], pack_name, i, errors)
		if record != null:
			levels.append(record)
	return {"levels": levels, "errors": errors}

## A fresh PuzzleDefinition for a parsed level record.
static func record_to_definition(record: Dictionary) -> PuzzleDefinition:
	var arrows := {}
	var tails := {}
	for arrow in record["arrows"]:
		var vertices: Array = arrow[1]
		arrows[vertices[0]] = arrow[0]
		tails[vertices[0]] = expand_vertices(vertices)
	return PuzzleDefinition.new(record["width"], record["height"], arrows, tails)

## The tail cells along a vertex path from the head through every bend to the
## tail end, excluding the head itself.
static func expand_vertices(vertices: Array) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for i in range(vertices.size() - 1):
		var step := Vector2i((vertices[i + 1] - vertices[i]).sign())
		var cell: Vector2i = vertices[i]
		while cell != vertices[i + 1]:
			cell += step
			cells.append(cell)
	return cells

## A level record for a definition, with arrows in head order and each tail
## compressed to its turning points.
static func make_record(id: String, title: String, group: String, definition: PuzzleDefinition,
		provenance: Dictionary, notes: String = "") -> Dictionary:
	var heads: Array = definition.arrows.keys()
	heads.sort_custom(PuzzleDefinition.head_less_than)
	var arrows: Array = []
	for head in heads:
		arrows.append([definition.arrows[head], compress_cells(definition.get_arrow_cells(head))])
	var record := {
		"id": id,
		"title": title,
		"group": group,
		"width": definition.width,
		"height": definition.height,
		"content_version": PuzzleContentVersion.of(definition),
		"provenance": provenance,
		"arrows": arrows,
	}
	if not notes.is_empty():
		record["notes"] = notes
	return record

## The head, every cell where the step direction changes, and the last cell.
static func compress_cells(cells: Array[Vector2i]) -> Array[Vector2i]:
	var vertices: Array[Vector2i] = [cells[0]]
	for i in range(1, cells.size() - 1):
		if cells[i] - cells[i - 1] != cells[i + 1] - cells[i]:
			vertices.append(cells[i])
	if cells.size() > 1:
		vertices.append(cells[cells.size() - 1])
	return vertices

## Every invariant a shipped set of levels must hold: valid and solvable
## boards, a stored content version equal to the recomputed one, ids and
## boards unique across all levels, and a known group. Returns one message
## per violation, naming the pack and level.
static func audit_levels(levels: Array, known_groups: Array) -> Array[String]:
	var errors: Array[String] = []
	var seen_ids := {}
	var seen_versions := {}
	for record in levels:
		var where := _where(record.get("pack", "?"), record["id"])
		if not known_groups.has(record["group"]):
			errors.append("%s: unknown group '%s'" % [where, record["group"]])
		var definition := record_to_definition(record)
		var validation_errors := definition.get_validation_errors()
		if not validation_errors.is_empty():
			errors.append("%s: invalid board: %s" % [where, "; ".join(validation_errors)])
			continue
		if not PuzzleSolver.analyze(definition)["solvable"]:
			errors.append("%s: board is not solvable" % where)
		var version := PuzzleContentVersion.of(definition)
		if version != record["content_version"]:
			errors.append("%s: stored content_version %s does not match its geometry (%s)" % [where, record["content_version"], version])
		if seen_ids.has(record["id"]):
			errors.append("%s: duplicate id, also in pack '%s'" % [where, seen_ids[record["id"]]])
		else:
			seen_ids[record["id"]] = record.get("pack", "?")
		if seen_versions.has(version):
			errors.append("%s: same board (%s) as level '%s'" % [where, version, seen_versions[version]])
		else:
			seen_versions[version] = record["id"]
	return errors

## Deterministic pack text: fixed key order, two-space indent, one arrow per
## line, trailing newline. The same levels always give the same bytes.
static func serialize_pack(pack_name: String, levels: Array) -> String:
	var lines: PackedStringArray = [
		"{",
		'  "format": %s,' % JSON.stringify(PACK_FORMAT),
		'  "pack": %s,' % JSON.stringify(pack_name),
		'  "levels": [',
	]
	for i in range(levels.size()):
		var record: Dictionary = levels[i]
		lines.append("    {")
		lines.append('      "id": %s,' % JSON.stringify(record["id"]))
		lines.append('      "title": %s,' % JSON.stringify(record["title"]))
		lines.append('      "group": %s,' % JSON.stringify(record["group"]))
		lines.append('      "width": %d,' % record["width"])
		lines.append('      "height": %d,' % record["height"])
		lines.append('      "content_version": %s,' % JSON.stringify(record["content_version"]))
		lines.append('      "provenance": %s,' % JSON.stringify(_normalize_numbers(record["provenance"]), "", true))
		if record.has("notes"):
			lines.append('      "notes": %s,' % JSON.stringify(record["notes"]))
		lines.append('      "arrows": [')
		var arrows: Array = record["arrows"]
		for j in range(arrows.size()):
			var points: PackedStringArray = []
			for vertex in arrows[j][1]:
				points.append("[%d, %d]" % [vertex.x, vertex.y])
			lines.append('        ["%s", [%s]]%s' % [DIRECTION_NAMES[arrows[j][0]], ", ".join(points), "," if j < arrows.size() - 1 else ""])
		lines.append("      ]")
		lines.append("    }%s" % ("," if i < levels.size() - 1 else ""))
	lines.append("  ]")
	lines.append("}")
	return "\n".join(lines) + "\n"

static func _parse_level(item, pack_name: String, index: int, errors: Array[String]) -> Variant:
	var label := "#%d" % index
	if not (item is Dictionary):
		errors.append("%s: is not a JSON object" % _where(pack_name, label))
		return null
	if item.get("id") is String and not (item["id"] as String).is_empty():
		label = item["id"]
	var where := _where(pack_name, label)
	var problems: Array[String] = []
	for key in ["id", "title", "group", "content_version"]:
		if not (item.get(key) is String) or (item[key] as String).is_empty():
			problems.append("'%s' must be a non-empty string" % key)
	var width = _to_int(item.get("width"))
	var height = _to_int(item.get("height"))
	if width == null or width <= 0 or height == null or height <= 0:
		problems.append("'width' and 'height' must be positive whole numbers")
	var provenance = item.get("provenance")
	if not (provenance is Dictionary) or not PROVENANCE_KINDS.has(provenance.get("kind")):
		problems.append("'provenance.kind' must be one of %s" % [PROVENANCE_KINDS])
	if item.has("notes") and not (item["notes"] is String):
		problems.append("'notes' must be a string")
	var arrows: Array = []
	var raw_arrows = item.get("arrows")
	if not (raw_arrows is Array) or raw_arrows.is_empty():
		problems.append("'arrows' must be a non-empty array")
	else:
		for j in range(raw_arrows.size()):
			var arrow = _parse_arrow(raw_arrows[j], j, problems)
			if arrow != null:
				arrows.append(arrow)
	if not problems.is_empty():
		for problem in problems:
			errors.append("%s: %s" % [where, problem])
		return null
	var record := {
		"pack": pack_name,
		"id": item["id"],
		"title": item["title"],
		"group": item["group"],
		"width": width,
		"height": height,
		"content_version": item["content_version"],
		"provenance": provenance,
		"arrows": arrows,
	}
	if item.has("notes"):
		record["notes"] = item["notes"]
	var validation_errors := record_to_definition(record).get_validation_errors()
	if not validation_errors.is_empty():
		errors.append("%s: invalid board: %s" % [where, "; ".join(validation_errors)])
		return null
	return record

static func _parse_arrow(raw, index: int, problems: Array[String]) -> Variant:
	if not (raw is Array) or raw.size() != 2 or not DIRECTIONS_BY_NAME.has(raw[0]) or not (raw[1] is Array) or raw[1].is_empty():
		problems.append("arrow %d must be [direction, [vertices...]] with a direction of up, down, left or right" % index)
		return null
	var vertices: Array[Vector2i] = []
	for point in raw[1]:
		var x = _to_int(point[0]) if point is Array and point.size() == 2 else null
		var y = _to_int(point[1]) if point is Array and point.size() == 2 else null
		if x == null or y == null:
			problems.append("arrow %d has a vertex that is not a pair of whole numbers: %s" % [index, JSON.stringify(point)])
			return null
		var vertex := Vector2i(x, y)
		if not vertices.is_empty():
			var delta: Vector2i = vertex - vertices[vertices.size() - 1]
			if delta == Vector2i.ZERO or (delta.x != 0 and delta.y != 0):
				problems.append("arrow %d has a %s step to %s; each step must move along one row or column" % [index, "zero-length" if delta == Vector2i.ZERO else "diagonal", vertex])
				return null
		vertices.append(vertex)
	return [DIRECTIONS_BY_NAME[raw[0]], vertices]

## A whole-number JSON value as int, or null (fractional, non-numeric, missing).
static func _to_int(value) -> Variant:
	if value is int:
		return value
	if value is float and is_finite(value) and value == floorf(value):
		return int(value)
	return null

## JSON parsing yields floats; whole numbers are written back as integers so
## generated provenance reads naturally and serializes the same every time.
static func _normalize_numbers(value) -> Variant:
	if value is float and is_finite(value) and value == floorf(value):
		return int(value)
	if value is Dictionary:
		var out := {}
		for key in value.keys():
			out[key] = _normalize_numbers(value[key])
		return out
	if value is Array:
		return value.map(func(item): return _normalize_numbers(item))
	return value

## The parsed value, or a String describing where parsing failed. Callers
## only ever expect objects, so a successfully parsed string is never mistaken
## for an error message.
static func _parse_json(text: String) -> Variant:
	var json := JSON.new()
	if json.parse(text) != OK:
		return "line %d: %s" % [json.get_error_line(), json.get_error_message()]
	var data = json.data
	return null if data is String else data

static func _read_text(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	return file.get_as_text()

static func _where(pack_name: String, label: String) -> String:
	return "pack '%s' level '%s'" % [pack_name, label]
