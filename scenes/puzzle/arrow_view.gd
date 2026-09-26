class_name ArrowView
extends Control
## Draws one arrow's whole shape (head plus any tail cells) and plays its
## exit/blocked feedback as a single unit. Holds no rule state; the
## controller applies state changes before requesting an effect.

signal exit_finished

const CELL_COLOR: Color = Color(0.16, 0.2, 0.28)
const ARROW_COLOR: Color = Color(0.85, 0.9, 1.0)

var direction: int = PuzzleDefinition.Direction.UP

var _cell_offsets: Array[Vector2i] = [Vector2i.ZERO] # relative to this view's own top-left, in cell units
var _head_offset: Vector2i = Vector2i.ZERO
var _cell_extent: float = 0.0

var _tween: Tween

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

## head_offset and cell_offsets are in cell units relative to this view's own
## top-left corner (the shape's bounding-box origin), independent of pixel
## size; call set_cell_extent() separately whenever the board resizes.
func set_shape(head_offset: Vector2i, cell_offsets: Array[Vector2i], new_direction: int) -> void:
	_head_offset = head_offset
	_cell_offsets = cell_offsets
	direction = new_direction
	queue_redraw()

func set_cell_extent(extent: float) -> void:
	_cell_extent = extent
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
	if _cell_extent <= 0.0:
		return
	var margin: float = _cell_extent * 0.12
	for offset in _cell_offsets:
		var top_left: Vector2 = Vector2(offset.x, offset.y) * _cell_extent
		draw_rect(Rect2(top_left + Vector2(margin, margin), Vector2(_cell_extent, _cell_extent) - Vector2(margin, margin) * 2.0), CELL_COLOR)

	var head_top_left: Vector2 = Vector2(_head_offset.x, _head_offset.y) * _cell_extent
	var center: Vector2 = head_top_left + Vector2(_cell_extent, _cell_extent) / 2.0
	var forward: Vector2 = _direction_vector()
	var right: Vector2 = Vector2(-forward.y, forward.x)
	var length: float = _cell_extent * 0.32
	var tip: Vector2 = center + forward * length
	var back_left: Vector2 = center - forward * length + right * length * 0.75
	var back_right: Vector2 = center - forward * length - right * length * 0.75
	draw_polygon(PackedVector2Array([tip, back_left, back_right]), PackedColorArray([ARROW_COLOR]))

## Non-color-only feedback: a brief scale pulse, capped by the coded
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

## Translates the entire shape (all cells move together) beyond the board
## edge along the head's own direction; travel_distance is passed by the
## board sized to clear any shape's bounds with margin.
func play_exit_animation(travel_distance: float) -> void:
	if _tween:
		_tween.kill()
	var target_position: Vector2 = position + _direction_vector() * travel_distance
	_tween = create_tween()
	_tween.tween_property(self, "position", target_position, PuzzleFeedback.EXIT_TWEEN_DURATION_SECONDS)
	_tween.finished.connect(func(): exit_finished.emit())
