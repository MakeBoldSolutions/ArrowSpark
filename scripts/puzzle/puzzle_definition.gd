class_name PuzzleDefinition
extends RefCounted
## Immutable fixed board: dimensions plus one cardinal direction per occupied cell.

enum Direction { UP, DOWN, LEFT, RIGHT }

var width: int
var height: int
var arrows: Dictionary # Vector2i -> Direction

func _init(p_width: int, p_height: int, p_arrows: Dictionary) -> void:
	width = p_width
	height = p_height
	arrows = p_arrows.duplicate(true)

## Structural validation only: positive dimensions, nonempty map, in-bounds
## cells and cardinal directions. Cell uniqueness is guaranteed by Dictionary
## keys. Authoring properties such as "all four directions present" are
## verified by the fixed board's own regression tests, not here.
func is_valid() -> bool:
	if width <= 0 or height <= 0:
		return false
	if arrows.is_empty():
		return false
	for cell in arrows.keys():
		if not (cell is Vector2i):
			return false
		if cell.x < 0 or cell.x >= width or cell.y < 0 or cell.y >= height:
			return false
		var direction = arrows[cell]
		if direction != Direction.UP and direction != Direction.DOWN \
				and direction != Direction.LEFT and direction != Direction.RIGHT:
			return false
	return true

func duplicate_arrows() -> Dictionary:
	return arrows.duplicate(true)

## The single manually authored 5x4 board (FR-001), documented in data-model.md.
## Witness solvability order: A, B, D, C, E, F, G, H.
static func create_fixed() -> PuzzleDefinition:
	var arrows := {
		Vector2i(0, 0): Direction.LEFT,  # A
		Vector2i(2, 0): Direction.LEFT,  # B
		Vector2i(4, 0): Direction.DOWN,  # C
		Vector2i(4, 3): Direction.RIGHT, # D
		Vector2i(0, 3): Direction.UP,    # E
		Vector2i(2, 3): Direction.LEFT,  # F
		Vector2i(2, 1): Direction.UP,    # G
		Vector2i(3, 2): Direction.RIGHT, # H
	}
	var definition := PuzzleDefinition.new(5, 4, arrows)
	assert(definition.is_valid(), "fixed puzzle definition must be structurally valid")
	return definition
