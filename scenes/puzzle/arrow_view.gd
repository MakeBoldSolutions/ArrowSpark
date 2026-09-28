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
var _suggested: bool = false
var _departing: bool = false
var _hover_tween: Tween
var _suggested_tween: Tween

var _geometry: ArrowDepartureGeometry
var _departure_distance: float = 0.0
var _finish_distance: float = 0.0
var _presentation_layout_valid: bool = true
var _completion_emitted: bool = false

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
	if _blocked_active or _suggested:
		return
	if _hover_tween:
		_hover_tween.kill()
	var target := GameVisualStyle.ARROW_HOVER if hovered else GameVisualStyle.ARROW_NORMAL
	_hover_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_method(_set_visual_color, _body.default_color, target, GameVisualStyle.HOVER_DURATION)

## "Show Me an Open Move" indicator: a looping pulse (the same scale ratio
## blocked feedback uses, in the ember hover accent, never a new palette
## entry) so the identified arrow is noticeable even with no mouse hover
## present (e.g. triggered via keyboard/gamepad). Precedence:
## departing > blocked > suggested > hover > normal -- blocked feedback
## always wins while active, and a mere hover never recolors over an active
## suggestion (though set_hovered() still tracks _hovered for when the
## suggestion later clears).
func set_suggested(suggested: bool) -> void:
	if _departing or _suggested == suggested:
		return
	_suggested = suggested
	if _blocked_active:
		return
	if suggested:
		_start_suggested_pulse()
	else:
		_stop_suggested_pulse()

func _start_suggested_pulse() -> void:
	if _hover_tween:
		_hover_tween.kill()
	if _suggested_tween:
		_suggested_tween.kill()
	_set_visual_color(GameVisualStyle.ARROW_HOVER)
	pivot_offset = size / 2.0
	scale = Vector2.ONE
	var half_duration: float = PuzzleFeedback.BLOCKED_PULSE_SECONDS
	_suggested_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_loops()
	_suggested_tween.tween_property(self, "scale", Vector2.ONE * GameVisualStyle.BLOCKED_SCALE, half_duration)
	_suggested_tween.tween_property(self, "scale", Vector2.ONE, half_duration)

func _stop_suggested_pulse() -> void:
	if _suggested_tween:
		_suggested_tween.kill()
	scale = Vector2.ONE
	_set_visual_color(GameVisualStyle.ARROW_HOVER if _hovered else GameVisualStyle.ARROW_NORMAL)

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
	if _departing:
		_render_departure()
	else:
		_rebuild_geometry()

## The presentation layout is invalid while the board has no usable area:
## departure advancement is suspended without changing the route, progress
## or canonical extent, and resumes when the area is valid again. A view that
## is merely off-screen still has a valid layout and keeps advancing.
func set_presentation_layout_valid(valid: bool) -> void:
	_presentation_layout_valid = valid

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
	if _suggested_tween:
		_suggested_tween.kill()
	if _tween:
		_tween.kill()
	_blocked_active = true
	_set_visual_color(GameVisualStyle.CRITICAL)
	pivot_offset = size / 2.0
	scale = Vector2.ONE
	var half_duration: float = PuzzleFeedback.BLOCKED_PULSE_SECONDS / 2.0
	_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2.ONE * GameVisualStyle.BLOCKED_SCALE, half_duration)
	_tween.tween_property(self, "scale", Vector2.ONE, half_duration)
	# Stay bright red after the pulse so the mistake is unmistakable.
	_tween.tween_interval(PuzzleFeedback.BLOCKED_CUE_DURATION_SECONDS - PuzzleFeedback.BLOCKED_PULSE_SECONDS)
	_tween.tween_callback(_finish_blocked_feedback)

func _finish_blocked_feedback() -> void:
	if _departing:
		return
	_blocked_active = false
	scale = Vector2.ONE
	if _suggested:
		_start_suggested_pulse()
	else:
		_set_visual_color(GameVisualStyle.ARROW_HOVER if _hovered else GameVisualStyle.ARROW_NORMAL)

## Builds this view's stationary tail-to-head route (in its own local cell
## units, relative to its own bounding-box origin) plus the synthetic shaft
## for single-cell shapes, exactly matching the static d=0 rendering built
## by _rebuild_geometry.
func _build_geometry() -> ArrowDepartureGeometry:
	var forward: Vector2 = _direction_vector()
	var points: Array[Vector2] = []
	if _cell_offsets.size() <= 1:
		var head_center: Vector2 = Vector2(_head_offset) + Vector2(0.5, 0.5)
		points.append(head_center + forward * GameVisualStyle.SINGLE_TAIL)
		points.append(head_center)
	else:
		for i in range(_cell_offsets.size() - 1, -1, -1):
			points.append(Vector2(_cell_offsets[i]) + Vector2(0.5, 0.5))
	return ArrowDepartureGeometry.new(points, forward, GameVisualStyle.HEAD_BASE, GameVisualStyle.BODY_WIDTH / 2.0)

## Starts feeding this arrow through its own stationary route and out past
## the grid edge. head_cell is this arrow's grid-absolute head position and
## grid_size is the board's cell dimensions, used only once here to compute
## the fixed cell-unit finish distance (independent of pixel layout).
## Repeated invocation while already departing is ignored.
func start_departure(head_cell: Vector2i, grid_size: Vector2i) -> void:
	if _departing:
		return
	_departing = true
	_hovered = false
	_blocked_active = false
	_suggested = false
	if _hover_tween:
		_hover_tween.kill()
	if _suggested_tween:
		_suggested_tween.kill()
	if _tween:
		_tween.kill()
	scale = Vector2.ONE
	modulate = Color.WHITE
	self_modulate = Color.WHITE
	show()
	_set_visual_color(GameVisualStyle.ARROW_NORMAL)
	_geometry = _build_geometry()
	_departure_distance = 0.0
	_completion_emitted = false
	if _geometry.is_valid():
		var rear_support: float = GameVisualStyle.BODY_WIDTH / 2.0
		var clearance: float = ArrowDepartureGeometry.forward_clearance(
			_geometry.forward(), Vector2(head_cell), Vector2(grid_size),
			rear_support, PuzzleFeedback.EXIT_CLEARANCE_MARGIN_CELLS)
		_finish_distance = _geometry.length() + clearance
	else:
		_finish_distance = 0.0
		_completion_emitted = true
	set_process(true)
	_render_departure()
	if _completion_emitted:
		_finish_departure()

func _process(delta: float) -> void:
	if not _departing:
		set_process(false)
		return
	advance_departure(delta)

## Advances cell-distance progress at the configured speed, capped at the
## finish distance. Refuses to advance while paused, while this view's
## presentation layout is invalid, once already finished, or for a nonpositive delta, so
## direct test calls cannot bypass lifecycle policy the same way real
## per-frame scheduling does.
func advance_departure(delta: float) -> void:
	if not _departing or _completion_emitted:
		return
	if get_tree() != null and get_tree().paused:
		return
	if not _presentation_layout_valid or _cell_extent <= 0.0 or delta <= 0.0:
		return
	_departure_distance = minf(
		_departure_distance + PuzzleFeedback.EXIT_SPEED_CELLS_PER_SECOND * delta, _finish_distance)
	_render_departure()
	if _departure_distance >= _finish_distance - ArrowDepartureGeometry.GEOMETRY_TOLERANCE:
		_finish_departure()

func _finish_departure() -> void:
	if _completion_emitted:
		return
	_completion_emitted = true
	set_process(false)
	exit_finished.emit()

## Renders the moving body interval and head polygon at the current
## departure distance, scaled by the current pixel cell extent. Never
## advances progress or emits completion — safe to call from a layout
## update while paused or resized.
func _render_departure() -> void:
	_body.clear_points()
	_head.polygon = PackedVector2Array()
	if _geometry == null or not _geometry.is_valid() or _cell_extent <= 0.0:
		return
	var d: float = _departure_distance
	var l: float = _geometry.length()
	var body_points: PackedVector2Array = _geometry.extract_interval(d, l + d + GameVisualStyle.BODY_END)
	var scaled_body := PackedVector2Array()
	for point in body_points:
		scaled_body.append(point * _cell_extent)
	_body.points = scaled_body
	_body.width = _cell_extent * GameVisualStyle.BODY_WIDTH
	var forward: Vector2 = _geometry.forward()
	var right: Vector2 = Vector2(-forward.y, forward.x)
	var tip: Vector2 = _geometry.sample_distance(l + d + GameVisualStyle.HEAD_TIP)
	var base: Vector2 = _geometry.sample_distance(l + d + GameVisualStyle.HEAD_BASE)
	_head.polygon = PackedVector2Array([
		tip * _cell_extent,
		(base + right * GameVisualStyle.HEAD_HALF_WIDTH) * _cell_extent,
		(base - right * GameVisualStyle.HEAD_HALF_WIDTH) * _cell_extent,
	])

## Stops advancement/effects and prevents any future completion signal.
## Used before setup disposal or scene teardown so a replaced attempt never
## receives a stale callback.
func cancel_departure() -> void:
	if not _departing:
		return
	_completion_emitted = true
	set_process(false)
