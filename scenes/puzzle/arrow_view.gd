class_name ArrowView
extends Control
## Draws one arrow's whole shape (head plus any tail cells) and plays its
## exit/blocked feedback as a single unit. Holds no rule state; the
## controller applies state changes before requesting an effect.

signal exit_finished

var direction: int = PuzzleDefinition.Direction.UP

var _cell_offsets: Array[Vector2i] = [Vector2i.ZERO] # relative to this view's own top-left, in cell units
var _head_offset: Vector2i = Vector2i.ZERO
var _cell_extent: float = 0.0

var _tween: Tween
var _body: Line2D
var _head: Polygon2D
var _hovered: bool = false
var _blocked_active: bool = false
var _departing: bool = false
var _hover_tween: Tween

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body = Line2D.new()
	_body.name = "Body"
	_body.joint_mode = Line2D.LINE_JOINT_ROUND
	_body.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_body.end_cap_mode = Line2D.LINE_CAP_NONE
	_body.round_precision = 8
	_body.antialiased = true
	_body.default_color = GameVisualStyle.ARROW_NORMAL
	add_child(_body)
	_head = Polygon2D.new()
	_head.name = "Head"
	_head.antialiased = true
	_head.color = GameVisualStyle.ARROW_NORMAL
	add_child(_head)

func _set_visual_color(color: Color) -> void:
	_body.default_color = color
	_head.color = color

func set_hovered(hovered: bool) -> void:
	if _departing or _hovered == hovered:
		return
	_hovered = hovered
	if _blocked_active:
		return
	if _hover_tween:
		_hover_tween.kill()
	var target := GameVisualStyle.ARROW_HOVER if hovered else GameVisualStyle.ARROW_NORMAL
	_hover_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_method(_set_visual_color, _body.default_color, target, GameVisualStyle.HOVER_DURATION)

## head_offset and cell_offsets are in cell units relative to this view's own
## top-left corner (the shape's bounding-box origin), independent of pixel
## size; call set_cell_extent() separately whenever the board resizes.
func set_shape(head_offset: Vector2i, cell_offsets: Array[Vector2i], new_direction: int) -> void:
	_head_offset = head_offset
	_cell_offsets = cell_offsets.duplicate()
	direction = new_direction
	_rebuild_geometry()

func set_cell_extent(extent: float) -> void:
	_cell_extent = extent
	_rebuild_geometry()

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

func _rebuild_geometry() -> void:
	_body.clear_points()
	_head.polygon = PackedVector2Array()
	if _cell_extent <= 0.0:
		return
	var center: Vector2 = (Vector2(_head_offset) + Vector2(0.5, 0.5)) * _cell_extent
	var forward: Vector2 = _direction_vector()
	var right: Vector2 = Vector2(-forward.y, forward.x)
	var points := PackedVector2Array()
	if _cell_offsets.size() <= 1:
		points.append(center + forward * _cell_extent * GameVisualStyle.SINGLE_TAIL)
	else:
		for i in range(_cell_offsets.size() - 1, 0, -1):
			points.append((Vector2(_cell_offsets[i]) + Vector2(0.5, 0.5)) * _cell_extent)
	points.append(center + forward * _cell_extent * GameVisualStyle.BODY_END)
	_body.points = points
	_body.width = _cell_extent * GameVisualStyle.BODY_WIDTH
	var base := center + forward * _cell_extent * GameVisualStyle.HEAD_BASE
	_head.polygon = PackedVector2Array([
		center + forward * _cell_extent * GameVisualStyle.HEAD_TIP,
		base + right * _cell_extent * GameVisualStyle.HEAD_HALF_WIDTH,
		base - right * _cell_extent * GameVisualStyle.HEAD_HALF_WIDTH,
	])

## Non-color-only feedback: a brief scale pulse, capped by the coded
## constant and repeatable without ever locking further input.
func play_blocked_feedback() -> void:
	if _departing:
		return
	if _hover_tween:
		_hover_tween.kill()
	if _tween:
		_tween.kill()
	_blocked_active = true
	_set_visual_color(GameVisualStyle.CRITICAL)
	pivot_offset = size / 2.0
	scale = Vector2.ONE
	var half_duration: float = PuzzleFeedback.BLOCKED_CUE_DURATION_SECONDS / 2.0
	_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2.ONE * GameVisualStyle.BLOCKED_SCALE, half_duration)
	_tween.tween_property(self, "scale", Vector2.ONE, half_duration)
	_tween.tween_callback(_finish_blocked_feedback)

func _finish_blocked_feedback() -> void:
	if _departing:
		return
	_blocked_active = false
	scale = Vector2.ONE
	_set_visual_color(GameVisualStyle.ARROW_HOVER if _hovered else GameVisualStyle.ARROW_NORMAL)

## Translates the entire shape (all cells move together) beyond the board
## edge along the head's own direction; travel_distance is passed by the
## board sized to clear any shape's bounds with margin.
func play_exit_animation(travel_distance: float) -> void:
	if _departing:
		return
	_departing = true
	_hovered = false
	_blocked_active = false
	if _hover_tween:
		_hover_tween.kill()
	if _tween:
		_tween.kill()
	scale = Vector2.ONE
	modulate = Color.WHITE
	self_modulate = Color.WHITE
	show()
	_set_visual_color(GameVisualStyle.ARROW_NORMAL)
	var target_position: Vector2 = position + _direction_vector() * travel_distance
	_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "position", target_position, PuzzleFeedback.EXIT_TWEEN_DURATION_SECONDS)
	_tween.finished.connect(func(): exit_finished.emit())
