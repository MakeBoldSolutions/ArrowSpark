class_name PuzzleContentVersion
extends RefCounted
## Identity of a puzzle's geometry, independent of the application version,
## catalog position, id, title or group. It changes if and only if the board
## size, an arrow head, a direction or a tail cell changes, so evidence about a
## puzzle (session notes, reactions) can name exactly which board was played.
## Pure function of a PuzzleDefinition; never touches rules or state.

## Names the canonicalization scheme. A different canonical text means a new
## prefix, never a silent change of values under the old one.
const SCHEME := "g1"

const _DIRECTION_NAMES := {
	PuzzleDefinition.Direction.UP: "up",
	PuzzleDefinition.Direction.DOWN: "down",
	PuzzleDefinition.Direction.LEFT: "left",
	PuzzleDefinition.Direction.RIGHT: "right",
}

## "g1-" followed by the first 12 lowercase hex digits of the SHA-256 of the
## canonical geometry text.
static func of(definition: PuzzleDefinition) -> String:
	return "%s-%s" % [SCHEME, canonical_text(definition).sha256_text().substr(0, 12)]

## w:<width>;h:<height>; then, for each head in (y, x) order,
## <x>,<y>,<direction>:<tx>,<ty>|<tx>,<ty>...; with the tail in path order.
## Directions are written by name, so reordering the enum cannot change a value.
static func canonical_text(definition: PuzzleDefinition) -> String:
	var heads: Array = definition.arrows.keys()
	heads.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x))
	var text := "w:%d;h:%d;" % [definition.width, definition.height]
	for head in heads:
		var cells: PackedStringArray = []
		for cell in definition.tails.get(head, []):
			cells.append("%d,%d" % [cell.x, cell.y])
		text += "%d,%d,%s:%s;" % [head.x, head.y, _DIRECTION_NAMES.get(definition.arrows[head], "?"), "|".join(cells)]
	return text
