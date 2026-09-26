class_name PuzzleDefinition
extends RefCounted
## Immutable fixed board: dimensions plus one shape (head cell, direction,
## and an ordered tail-cell path) per arrow. A single-cell arrow is the
## degenerate case of an empty tail.

enum Direction { UP, DOWN, LEFT, RIGHT }

var width: int
var height: int
var arrows: Dictionary # Vector2i (head) -> Direction
var tails: Dictionary # Vector2i (head) -> Array[Vector2i], omitted heads have an empty tail

func _init(p_width: int, p_height: int, p_arrows: Dictionary, p_tails: Dictionary = {}) -> void:
	width = p_width
	height = p_height
	arrows = p_arrows.duplicate(true)
	tails = p_tails.duplicate(true)

## The unit step from a head toward its own direction of travel.
static func direction_vector(direction: int) -> Vector2i:
	match direction:
		Direction.UP:
			return Vector2i(0, -1)
		Direction.DOWN:
			return Vector2i(0, 1)
		Direction.LEFT:
			return Vector2i(-1, 0)
		Direction.RIGHT:
			return Vector2i(1, 0)
	return Vector2i.ZERO

## Cells strictly between a head and the board edge along its own direction
## of travel (its forward escape ray), computed from fixed geometry alone —
## independent of which arrows are currently active. Shared by validation
## (an arrow's own tail may never occupy this) and runtime blocking checks
## (PuzzleState scans exactly this set for other arrows' occupied cells), so
## both agree on one definition of "ahead."
func forward_ray_cells(head: Vector2i, direction: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var step: Vector2i = direction_vector(direction)
	var cell: Vector2i = head + step
	while cell.x >= 0 and cell.x < width and cell.y >= 0 and cell.y < height:
		cells.append(cell)
		cell += step
	return cells

## The full ordered shape (head followed by its tail, if any) for one arrow.
func get_arrow_cells(head: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = [head]
	for cell in tails.get(head, []):
		cells.append(cell)
	return cells

## Vector2i (any occupied cell) -> Vector2i (owning head), for every active
## arrow's full shape. Independent copies on every call.
func get_cell_owners() -> Dictionary:
	var owners: Dictionary = {}
	for head in arrows.keys():
		for cell in get_arrow_cells(head):
			owners[cell] = head
	return owners

func duplicate_arrows() -> Dictionary:
	return arrows.duplicate(true)

func duplicate_tails() -> Dictionary:
	return tails.duplicate(true)

## Structural and geometric validation: positive dimensions, nonempty map,
## in-bounds cells, cardinal directions, a connected non-branching tail path
## with no diagonal/gap/repeated cells whose first cell sits immediately
## behind the head, no arrow's own tail on its own forward escape ray, and
## no cell shared between two arrows. Adjacency between different arrows'
## cells is never a validation concern.
func get_validation_errors() -> Array[String]:
	var errors: Array[String] = []
	if width <= 0 or height <= 0:
		errors.append("board dimensions must be positive")
	if arrows.is_empty():
		errors.append("at least one arrow is required")
	if not errors.is_empty():
		return errors

	var owners: Dictionary = {} # Vector2i -> Vector2i(head), across all arrows
	for head in arrows.keys():
		if not (head is Vector2i):
			errors.append("arrow head must be a Vector2i")
			continue
		var direction = arrows[head]
		if direction != Direction.UP and direction != Direction.DOWN \
				and direction != Direction.LEFT and direction != Direction.RIGHT:
			errors.append("arrow at %s has a non-cardinal direction" % [head])
			continue
		if not _is_in_bounds(head):
			errors.append("arrow head %s is out of bounds" % [head])
			continue

		var shape_cells: Dictionary = {head: true} # visited-cell guard for this arrow only
		var tail: Array = tails.get(head, [])
		var expected_first: Vector2i = head - direction_vector(direction)
		var previous: Vector2i = head
		var ray_cells: Dictionary = {}
		for ray_cell in forward_ray_cells(head, direction):
			ray_cells[ray_cell] = true

		for i in range(tail.size()):
			var cell = tail[i]
			if not (cell is Vector2i):
				errors.append("arrow at %s has a non-Vector2i tail cell" % [head])
				break
			if not _is_in_bounds(cell):
				errors.append("arrow at %s has an out-of-bounds tail cell %s" % [head, cell])
				break
			if i == 0 and cell != expected_first:
				errors.append("arrow at %s tail must start immediately behind the head, opposite its direction of travel" % [head])
				break
			var delta: Vector2i = cell - previous
			if abs(delta.x) + abs(delta.y) != 1:
				errors.append("arrow at %s tail cell %s is not orthogonally adjacent to the previous cell" % [head, cell])
				break
			if shape_cells.has(cell):
				errors.append("arrow at %s has a repeated tail cell %s" % [head, cell])
				break
			if ray_cells.has(cell):
				errors.append("arrow at %s has a tail cell %s on its own forward escape ray" % [head, cell])
				break
			shape_cells[cell] = true
			previous = cell

		for cell in shape_cells.keys():
			if owners.has(cell):
				errors.append("cell %s is claimed by more than one arrow" % [cell])
			else:
				owners[cell] = head

	return errors

func is_valid() -> bool:
	return get_validation_errors().is_empty()

func _is_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < width and cell.y >= 0 and cell.y < height

## The single manually authored 5x4 board: all four cardinal directions, a
## twice-bent tail (A), two straight tails (B, D), tail-caused blocking
## (A blocks B and E; B blocks G), and an arrow removable only after another
## departs.
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
	var tails := {
		Vector2i(0, 0): [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1)], # A: bends twice
		Vector2i(2, 0): [Vector2i(3, 0)], # B: straight
		Vector2i(4, 3): [Vector2i(3, 3)], # D: straight
	}
	var definition := PuzzleDefinition.new(5, 4, arrows, tails)
	assert(definition.is_valid(), "fixed puzzle definition must be structurally valid")
	return definition
