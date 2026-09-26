class_name PuzzleState
extends RefCounted
## Pure rule/state authority for one puzzle attempt. No Node, mouse, tween,
## persistence or UI dependency (FR-012); verifiable headlessly.

enum SelectOutcome { IGNORED, BLOCKED, REMOVED }

var total_arrows: int
var successful_removals: int = 0
var mistakes: int = 0
var total_taps: int = 0
var completed: bool = false

var _definition: PuzzleDefinition
var _active_arrows: Dictionary # Vector2i -> PuzzleDefinition.Direction

func _init(definition: PuzzleDefinition) -> void:
	assert(definition.is_valid(), "PuzzleState requires a structurally valid definition")
	_definition = definition
	_active_arrows = definition.duplicate_arrows()
	total_arrows = _active_arrows.size()

func remaining() -> int:
	return _active_arrows.size()

## False for any cell with no active arrow, including an absent cell
## (contracts: querying blocking on an absent cell returns false).
func is_blocked(cell: Vector2i) -> bool:
	if not _active_arrows.has(cell):
		return false
	var direction: int = _active_arrows[cell]
	match direction:
		PuzzleDefinition.Direction.LEFT:
			for x in range(0, cell.x):
				if _active_arrows.has(Vector2i(x, cell.y)):
					return true
		PuzzleDefinition.Direction.RIGHT:
			for x in range(cell.x + 1, _definition.width):
				if _active_arrows.has(Vector2i(x, cell.y)):
					return true
		PuzzleDefinition.Direction.UP:
			for y in range(0, cell.y):
				if _active_arrows.has(Vector2i(cell.x, y)):
					return true
		PuzzleDefinition.Direction.DOWN:
			for y in range(cell.y + 1, _definition.height):
				if _active_arrows.has(Vector2i(cell.x, y)):
					return true
	return false

## Absent cells and completed attempts are ignored and never account.
## Every accepted active-cell request accounts exactly once (FR-008).
func select_arrow(cell: Vector2i) -> SelectOutcome:
	if completed or not _active_arrows.has(cell):
		return SelectOutcome.IGNORED
	total_taps += 1
	if is_blocked(cell):
		mistakes += 1
		return SelectOutcome.BLOCKED
	_active_arrows.erase(cell)
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

## Score/accuracy for the completed attempt (FR-010). Accuracy is the raw
## float ratio; only the displayed percentage is rounded, by the caller.
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
