class_name PuzzleState
extends RefCounted
## Pure rule/state authority for one puzzle attempt. No Node, mouse, tween,
## persistence or UI dependency; verifiable headlessly.

enum SelectOutcome { IGNORED, BLOCKED, REMOVED }

var total_arrows: int
var successful_removals: int = 0
var mistakes: int = 0
var total_taps: int = 0
var completed: bool = false

var _definition: PuzzleDefinition
var _active_arrows: Dictionary # Vector2i (head) -> Direction, active arrows only
var _cell_owners: Dictionary # Vector2i (any cell, head or tail) -> Vector2i (head); fixed for the whole attempt

func _init(definition: PuzzleDefinition) -> void:
	assert(definition.is_valid(), "PuzzleState requires a structurally valid definition")
	_definition = definition
	_active_arrows = definition.duplicate_arrows()
	_cell_owners = definition.get_cell_owners()
	total_arrows = _active_arrows.size()

func remaining() -> int:
	return _active_arrows.size()

## The active arrow owning a cell (its head or any tail cell), or null. A
## cell whose owner has already departed also returns null: a removed
## arrow's cells are no longer meaningfully "owned" for selection purposes.
func get_arrow_head(cell: Vector2i) -> Variant:
	var head = _cell_owners.get(cell)
	if head == null or not _active_arrows.has(head):
		return null
	return head

## False for any cell with no active arrow, including an absent cell or one
## belonging to an already-departed arrow.
func is_blocked(cell: Vector2i) -> bool:
	var head = get_arrow_head(cell)
	if head == null:
		return false
	return _is_head_blocked(head)

## Every cell the arrow itself owns (head or any tail cell) is excluded
## unconditionally, regardless of position relative to the head; a valid
## definition never places one of an arrow's own cells on its own forward
## escape ray (PuzzleDefinition.get_validation_errors), so this exclusion is
## a self-ownership rule, never a conflict it has to resolve.
func _is_head_blocked(head: Vector2i) -> bool:
	var direction: int = _active_arrows[head]
	for ray_cell in _definition.forward_ray_cells(head, direction):
		var owner = _cell_owners.get(ray_cell)
		if owner != null and owner != head and _active_arrows.has(owner):
			return true
	return false

## Absent cells, departed-arrow cells and completed attempts are ignored and
## never account. Every accepted active-cell request accounts exactly once,
## and a legal removal clears every cell of that arrow's shape atomically.
func select_arrow(cell: Vector2i) -> SelectOutcome:
	if completed:
		return SelectOutcome.IGNORED
	var head = get_arrow_head(cell)
	if head == null:
		return SelectOutcome.IGNORED
	total_taps += 1
	if _is_head_blocked(head):
		mistakes += 1
		return SelectOutcome.BLOCKED
	_active_arrows.erase(head)
	successful_removals += 1
	if _active_arrows.is_empty():
		completed = true
	return SelectOutcome.REMOVED

## Read-only copy for views/tests; callers cannot mutate rule state through it.
func get_snapshot() -> Dictionary:
	return {
		"active_arrows": _active_arrows.duplicate(true),
		"remaining": remaining(),
		"total_arrows": total_arrows,
		"successful_removals": successful_removals,
		"mistakes": mistakes,
		"total_taps": total_taps,
		"completed": completed,
	}

## Score/accuracy for the completed attempt. Accuracy is the raw float
## ratio; only the displayed percentage is rounded, by the caller.
func get_results() -> Dictionary:
	var score: int = max(total_arrows - mistakes, 0)
	var accuracy: float = 0.0
	if total_taps > 0:
		accuracy = float(successful_removals) / float(total_taps)
	return {
		"total_arrows": total_arrows,
		"mistakes": mistakes,
		"score": score,
		"accuracy": accuracy,
	}
