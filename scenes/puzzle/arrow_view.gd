class_name ArrowView
extends Control
## Draws one arrow cell and plays its exit/blocked feedback. Holds no rule
## state (FR-012); the controller applies state changes before requesting an
## effect (contracts/puzzle.md).

signal exit_finished

const CELL_COLOR: Color = Color(0.16, 0.2, 0.28)
const ARROW_COLOR: Color = Color(0.85, 0.9, 1.0)

var direction: int = PuzzleDefinition.Direction.UP

var _tween: Tween

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_direction(new_direction: int) -> void:
	direction = new_direction
	queue_redraw()

func _direction_vector() -> Vector2:
	match direction:
		PuzzleDefinition.Direction.UP:
			return Vector2(0, -1)
		PuzzleDefinition.Direction.DOWN:
			return Vector2(0, 1)
		PuzzleDefinition.Direction.LEFT:
			return Vector2(-1, 0)
		PuzzleDefinition.Direction.RIGHT:
			return Vector2(1, 0)
	return Vector2.ZERO

func _draw() -> void:
	var margin: float = min(size.x, size.y) * 0.12
	draw_rect(Rect2(Vector2(margin, margin), size - Vector2(margin, margin) * 2.0), CELL_COLOR)
	var center: Vector2 = size / 2.0
	var forward: Vector2 = _direction_vector()
	var right: Vector2 = Vector2(-forward.y, forward.x)
	var length: float = min(size.x, size.y) * 0.32
	var tip: Vector2 = center + forward * length
	var back_left: Vector2 = center - forward * length + right * length * 0.75
	var back_right: Vector2 = center - forward * length - right * length * 0.75
	draw_polygon(PackedVector2Array([tip, back_left, back_right]), PackedColorArray([ARROW_COLOR]))

## Non-color-only feedback (FR-005): a brief scale pulse, capped by the coded
## constant and repeatable without ever locking further input.
func play_blocked_feedback() -> void:
	if _tween:
		_tween.kill()
	pivot_offset = size / 2.0
	scale = Vector2.ONE
	var half_duration: float = PuzzleFeedback.BLOCKED_CUE_DURATION_SECONDS / 2.0
	_tween = create_tween()
	_tween.tween_property(self, "scale", Vector2(1.3, 1.3), half_duration)
	_tween.tween_property(self, "scale", Vector2.ONE, half_duration)

func play_exit_animation(travel_distance: float) -> void:
	if _tween:
		_tween.kill()
	var target_position: Vector2 = position + _direction_vector() * travel_distance
	_tween = create_tween()
	_tween.tween_property(self, "position", target_position, PuzzleFeedback.EXIT_TWEEN_DURATION_SECONDS)
	_tween.finished.connect(func(): exit_finished.emit())
