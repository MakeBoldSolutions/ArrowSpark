class_name PuzzleBoard
extends Control
## Board canvas, click-to-cell mapping and arrow views. Holds no puzzle
## rules; the controller decides outcomes and tells this board what to
## display, always by an arrow's canonical head.
##
## The board Control is a fixed, clipped window. Every arrow view is built
## once at a canonical 64-pixel cell extent under a passive World node whose
## position and scale come from PuzzleViewportTransform, so fitting, zooming
## and panning never rebuild geometry and hit testing uses the inverse of the
## same transform.

signal cell_clicked(cell: Vector2i)
signal departure_finished
signal hover_cell_changed(cell: Vector2i)
signal view_changed
signal pan_mode_changed(enabled: bool)

const CANONICAL_CELL := PuzzleViewportTransform.CANONICAL_CELL_PIXELS
## Screen pixels per second the camera moves for focused keyboard/gamepad pan.
const KEY_PAN_SPEED := 600.0
const _FOCUS_COLOR := GameVisualStyle.ARROW_HOVER

var definition: PuzzleDefinition
var view_transform := PuzzleViewportTransform.new()
var _views: Dictionary # Vector2i (head) -> ArrowView
var _departing_views: Dictionary # Vector2i (original head) -> ArrowView, presentation-only
var _world: Control
var _departure_clip: Control
var _layout_valid: bool = false
var _hovered_head: Variant = null
var _last_hover_cell := Vector2i(-1, -1)
var _suggested_head: Variant = null
var _pending_reveal: bool = false
var _navigation_enabled: bool = true
var _pan_mode: bool = false
var _drag_button: int = 0 # 0 while no navigation drag is captured
var _suppress_primary_until_release: bool = false

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	clip_contents = true
	_world = Control.new()
	_world.name = "World"
	_world.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_world)
	_departure_clip = Control.new()
	_departure_clip.name = "DepartureClip"
	_departure_clip.clip_contents = true
	_departure_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_world.add_child(_departure_clip)

func _ready() -> void:
	mouse_exited.connect(clear_hover)
	get_window().mouse_exited.connect(clear_hover)
	get_window().focus_exited.connect(_on_window_focus_exited)

func _process(delta: float) -> void:
	# GUI hover can be cached until the next mouse motion. Refresh it so a
	# newly shown overlay also clears a stationary pointer's old owner.
	get_viewport().update_mouse_cursor_state()
	_process_focused_pan(delta)
	if _drag_button != 0 or not _pointer_eligible():
		clear_hover()
		return
	_sample_hover(get_local_mouse_position())

func _pointer_eligible() -> bool:
	return is_visible_in_tree() and not get_tree().paused \
		and get_window().has_focus() and get_viewport().gui_get_hovered_control() == self

func _sample_hover(local_position: Vector2) -> void:
	var cell := _cell_from_local(local_position)
	if cell != _last_hover_cell:
		_last_hover_cell = cell
		hover_cell_changed.emit(cell)

func clear_hover() -> void:
	_last_hover_cell = Vector2i(-1, -1)
	set_hovered_head(null)

func set_hovered_head(head: Variant) -> void:
	if head != null and not _views.has(head):
		head = null
	if head == _hovered_head:
		return
	if _hovered_head != null and _views.has(_hovered_head):
		_views[_hovered_head].set_hovered(false)
	_hovered_head = head
	if head != null:
		_views[head].set_hovered(true)

## "Show Me an Open Move" identification, presentation-only: the controller
## resolves which head to show via PuzzleState.request_open_move(); this
## board only renders it, never decides which arrow is legal. The head is
## first revealed at a readable scale (see PuzzleViewportTransform.reveal_cell),
## then pulsed by the view. Superseding an existing suggestion (a repeated
## request) clears the prior one first. While the layout is invalid the
## reveal stays pending and applies, without a new rule request, once the
## area is valid again.
func suggest_open_move(head: Vector2i) -> void:
	if not _views.has(head):
		return
	clear_suggestion()
	_suggested_head = head
	if _layout_valid:
		if view_transform.reveal_cell(head):
			_apply_view_change()
	else:
		_pending_reveal = true
	_views[head].set_suggested(true)

## Clears any active suggestion indicator. Called on any accepted selection
## (played or blocked) and on a fresh setup(), so a stale suggestion never
## outlives the board state it was shown against.
func clear_suggestion() -> void:
	if _suggested_head != null and _views.has(_suggested_head):
		_views[_suggested_head].set_suggested(false)
	_suggested_head = null
	_pending_reveal = false

func setup(new_definition: PuzzleDefinition) -> void:
	_cancel_drag()
	set_pan_mode(false)
	clear_hover()
	clear_suggestion()
	for view in _views.values():
		view.queue_free()
	_views.clear()
	for view in _departing_views.values():
		view.cancel_departure()
		view.queue_free()
	_departing_views.clear()
	definition = new_definition
	view_transform.configure(Vector2i(definition.width, definition.height))
	view_transform.resize_view(size)
	_world.size = Vector2(definition.width, definition.height) * CANONICAL_CELL
	_departure_clip.position = Vector2.ZERO
	_departure_clip.size = _world.size
	for head in definition.arrows.keys():
		var cells: Array[Vector2i] = definition.get_arrow_cells(head)
		var bbox_min: Vector2i = _bounding_min(cells)
		var offsets: Array[Vector2i] = []
		for cell in cells:
			offsets.append(cell - bbox_min)
		var view := ArrowView.new()
		view.set_shape(head - bbox_min, offsets, definition.arrows[head])
		_world.add_child(view)
		_views[head] = view
		_position_view(view, head)
	_sync_layout()
	view_changed.emit()

static func _bounding_min(cells: Array[Vector2i]) -> Vector2i:
	var result: Vector2i = cells[0]
	for cell in cells:
		result = Vector2i(min(result.x, cell.x), min(result.y, cell.y))
	return result

static func _bounding_max(cells: Array[Vector2i]) -> Vector2i:
	var result: Vector2i = cells[0]
	for cell in cells:
		result = Vector2i(max(result.x, cell.x), max(result.y, cell.y))
	return result

## Canonical bbox-relative placement in world space. Called once per view:
## navigation and resizing only move the World node, never these values.
func _position_view(view: ArrowView, head: Vector2i) -> void:
	var cells: Array[Vector2i] = definition.get_arrow_cells(head)
	var bbox_min: Vector2i = _bounding_min(cells)
	var bbox_max: Vector2i = _bounding_max(cells)
	view.position = Vector2(bbox_min.x, bbox_min.y) * CANONICAL_CELL
	view.size = Vector2(bbox_max.x - bbox_min.x + 1, bbox_max.y - bbox_min.y + 1) * CANONICAL_CELL
	view.set_cell_extent(CANONICAL_CELL)
	view.set_presentation_layout_valid(_layout_valid)

## Projects the current transform onto World and propagates layout validity to
## the views, but only when validity actually changes. An invalid (zero or
## non-finite) area keeps the last valid projection and suspends hit testing,
## hover and departure advancement; a valid recovery applies any reveal that
## was requested meanwhile.
func _sync_layout() -> void:
	if view_transform.layout_valid:
		_world.position = view_transform.world_position()
		_world.scale = view_transform.world_scale()
	if view_transform.layout_valid != _layout_valid:
		_layout_valid = view_transform.layout_valid
		for view in _views.values():
			view.set_presentation_layout_valid(_layout_valid)
		for view in _departing_views.values():
			view.set_presentation_layout_valid(_layout_valid)
		if not _layout_valid:
			_cancel_drag()
			clear_hover()
	if _layout_valid and _pending_reveal and _suggested_head != null:
		_pending_reveal = false
		view_transform.reveal_cell(_suggested_head)
		_world.position = view_transform.world_position()
		_world.scale = view_transform.world_scale()

func _apply_view_change() -> void:
	_sync_layout()
	_last_hover_cell = Vector2i(-1, -1)
	view_changed.emit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		view_transform.resize_view(size)
		_apply_view_change()
	elif what == NOTIFICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT \
			or what == NOTIFICATION_WM_MOUSE_EXIT or what == NOTIFICATION_VISIBILITY_CHANGED:
		_cancel_drag()
		clear_hover()
	elif what == NOTIFICATION_FOCUS_ENTER or what == NOTIFICATION_FOCUS_EXIT:
		if what == NOTIFICATION_FOCUS_EXIT:
			_cancel_drag()
		queue_redraw()

func _on_window_focus_exited() -> void:
	_cancel_drag()
	clear_hover()

func _draw() -> void:
	if has_focus():
		draw_rect(Rect2(Vector2.ZERO, size).grow(-1.0), _FOCUS_COLOR, false, 2.0)

func _cell_from_local(local_position: Vector2) -> Vector2i:
	return view_transform.cell_at(local_position)

# --- Navigation API -----------------------------------------------------------

func fit_puzzle() -> void:
	if not _navigation_eligible():
		return
	var before := view_transform.cell_pixels
	var center_before := view_transform.center_cells
	view_transform.fit_puzzle()
	if view_transform.cell_pixels != before or view_transform.center_cells != center_before:
		_apply_view_change()

func zoom_in() -> void:
	_zoom_about_center(PuzzleViewportTransform.ZOOM_STEP)

func zoom_out() -> void:
	_zoom_about_center(1.0 / PuzzleViewportTransform.ZOOM_STEP)

func _zoom_about_center(factor: float) -> void:
	if _navigation_eligible() and view_transform.zoom_at(factor, size / 2.0):
		_apply_view_change()

func set_pan_mode(enabled: bool) -> void:
	if enabled == _pan_mode:
		return
	_cancel_drag()
	_pan_mode = enabled
	mouse_default_cursor_shape = Control.CURSOR_DRAG if enabled else Control.CURSOR_ARROW
	pan_mode_changed.emit(enabled)

func is_pan_mode() -> bool:
	return _pan_mode

## Disabled by the controller while results cover the board. Also cancels any
## captured gesture and pan mode's effect on later input.
func set_navigation_enabled(enabled: bool) -> void:
	if enabled == _navigation_enabled:
		return
	_navigation_enabled = enabled
	if not enabled:
		_cancel_drag()
		clear_hover()

func is_navigation_enabled() -> bool:
	return _navigation_enabled

func _navigation_eligible() -> bool:
	return _navigation_enabled and _layout_valid and is_visible_in_tree() and not get_tree().paused

func _cancel_drag() -> void:
	_drag_button = 0
	_suppress_primary_until_release = false

# --- Input --------------------------------------------------------------------

## A discrete left-click press produces at most one selection request; a
## held button must not repeat without a new physical click. Any cell of a
## multi-cell shape (head or tail) is emitted as-is; the controller resolves
## the owning arrow before deciding the outcome. Panning (middle drag, or
## primary drag while Pan mode is on) never emits a selection, and wheel
## zoom, drags, and the focused canvas actions only run while navigation is
## eligible.
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_handle_motion(event)
	elif event is InputEventMouseButton:
		_handle_button(event)
	elif _is_canvas_action_event(event):
		_handle_canvas_action(event)

func _handle_motion(event: InputEventMouseMotion) -> void:
	if _drag_button == 0:
		_sample_hover(event.position)
		return
	var held: bool = (event.button_mask & _mask_for(_drag_button)) != 0
	if not held or not _navigation_eligible():
		_cancel_drag()
		return
	if view_transform.pan_pixels(event.relative):
		_apply_view_change()
	accept_event()

func _handle_button(event: InputEventMouseButton) -> void:
	var button: int = event.button_index
	if button == MOUSE_BUTTON_WHEEL_UP or button == MOUSE_BUTTON_WHEEL_DOWN:
		if event.pressed and _navigation_eligible():
			_wheel_zoom(event)
		accept_event()
		return
	if not event.pressed:
		if button == _drag_button:
			_cancel_drag()
			accept_event()
		elif button == MOUSE_BUTTON_LEFT:
			_suppress_primary_until_release = false
		return
	if event.is_echo():
		return
	if button == MOUSE_BUTTON_MIDDLE:
		if _navigation_eligible():
			_begin_drag(button)
			# A simultaneous primary press must not select during this gesture.
			_suppress_primary_until_release = true
		accept_event()
	elif button == MOUSE_BUTTON_LEFT:
		if _suppress_primary_until_release or _drag_button == MOUSE_BUTTON_MIDDLE:
			return
		if _pan_mode:
			if _navigation_eligible():
				_begin_drag(button)
			accept_event()
			return
		var cell := _cell_from_local(event.position)
		if cell.x >= 0:
			cell_clicked.emit(cell)

func _begin_drag(button: int) -> void:
	_drag_button = button
	clear_hover()
	grab_focus()

func _wheel_zoom(event: InputEventMouseButton) -> void:
	# The step scales with the event's amount and is clamped per event, so a
	# high-resolution trackpad burst can never overshoot a full step.
	var amount: float = event.factor if event.factor > 0.0 else 1.0
	amount = clampf(amount, 0.05, 1.0)
	var factor: float = pow(PuzzleViewportTransform.ZOOM_STEP, amount)
	if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		factor = 1.0 / factor
	if view_transform.zoom_at(factor, event.position):
		_apply_view_change()

static func _mask_for(button: int) -> int:
	match button:
		MOUSE_BUTTON_LEFT:
			return MOUSE_BUTTON_MASK_LEFT
		MOUSE_BUTTON_MIDDLE:
			return MOUSE_BUTTON_MASK_MIDDLE
		MOUSE_BUTTON_RIGHT:
			return MOUSE_BUTTON_MASK_RIGHT
	return 0

const _PAN_ACTIONS: Array[StringName] = [&"move_left", &"move_right", &"move_up", &"move_down"]

const _DPAD_BUTTONS: Array[int] = [JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT]

## True for the events this focused board consumes: the pan actions (so a stick
## push cannot also move GUI focus) and the zoom/fit actions. Focus navigation
## is never consumed, whatever the remapping: Tab/Shift+Tab and the D-pad
## always keep a way off the board.
func _is_canvas_action_event(event: InputEvent) -> bool:
	if event is InputEventMouse or event is InputEventScreenTouch or event is InputEventScreenDrag:
		return false
	if event.is_action(&"ui_focus_next") or event.is_action(&"ui_focus_prev"):
		return false
	if event is InputEventJoypadButton and _DPAD_BUTTONS.has(event.button_index):
		return false
	for action in _PAN_ACTIONS:
		if event.is_action(action):
			return true
	return event.is_action(&"canvas_zoom_in") or event.is_action(&"canvas_zoom_out") 		or event.is_action(&"canvas_fit")

## Focused zoom/fit actions, and consumption of the pan actions so a stick
## push does not also move GUI focus. Pan itself is polled per frame.
func _handle_canvas_action(event: InputEvent) -> void:
	if event.is_action_pressed(&"canvas_zoom_in", true):
		zoom_in()
	elif event.is_action_pressed(&"canvas_zoom_out", true):
		zoom_out()
	elif event.is_action_pressed(&"canvas_fit", false):
		fit_puzzle()
	accept_event()

func _process_focused_pan(delta: float) -> void:
	if not has_focus() or not _navigation_eligible() or not get_window().has_focus():
		return
	var direction := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if direction == Vector2.ZERO:
		return
	if view_transform.pan_camera_pixels(direction * KEY_PAN_SPEED * minf(delta, 0.1)):
		_apply_view_change()

# --- Departures and feedback --------------------------------------------------

## Moves the arrow's view from active ownership into the passive departing
## collection, reparented under the clipping layer at its own bbox-relative
## position, then starts its feed-through-the-route departure. Completion is
## connected before motion starts so a same-frame full-clearance advance
## cannot race the callback.
func play_removed(head: Vector2i) -> void:
	var view: ArrowView = _views.get(head)
	if view == null:
		return
	if head == _hovered_head:
		clear_hover()
	clear_suggestion()
	_views.erase(head)
	_departing_views[head] = view
	view.reparent(_departure_clip, false)
	view.set_presentation_layout_valid(_layout_valid)
	view.exit_finished.connect(func():
		if _departing_views.get(head) == view:
			_departing_views.erase(head)
		view.queue_free()
		departure_finished.emit()
	, CONNECT_ONE_SHOT)
	view.start_departure(head, Vector2i(definition.width, definition.height))

func play_blocked(head: Vector2i) -> void:
	var view: ArrowView = _views.get(head)
	if view:
		view.play_blocked_feedback()
