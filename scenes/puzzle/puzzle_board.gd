class_name PuzzleBoard
extends Control
## Board layout, click-to-cell mapping and arrow views. Holds no puzzle
## rules; the controller decides outcomes and tells this board what to
## display, always by an arrow's canonical head.

signal cell_clicked(cell: Vector2i)
signal departure_finished
signal hover_cell_changed(cell: Vector2i)

var definition: PuzzleDefinition
var _views: Dictionary # Vector2i (head) -> ArrowView
var _departing_views: Dictionary # Vector2i (original head) -> ArrowView, presentation-only
var _departure_clip: Control
var _cell_size: Vector2 = Vector2.ZERO
var _origin: Vector2 = Vector2.ZERO
var _hovered_head: Variant = null
var _last_hover_cell := Vector2i(-1, -1)
var _suggested_head: Variant = null

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_departure_clip = Control.new()
	_departure_clip.name = "DepartureClip"
	_departure_clip.clip_contents = true
	_departure_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_departure_clip)

func _ready() -> void:
	mouse_exited.connect(clear_hover)
	get_window().mouse_exited.connect(clear_hover)
	get_window().focus_exited.connect(clear_hover)

func _process(_delta: float) -> void:
	# GUI hover can be cached until the next mouse motion. Refresh it so a
	# newly shown overlay also clears a stationary pointer's old owner.
	get_viewport().update_mouse_cursor_state()
	if not _pointer_eligible():
		clear_hover()
		return
	_sample_hover(get_local_mouse_position())

func _pointer_eligible() -> bool:
	return is_visible_in_tree() and not get_tree().paused \
		and get_window().has_focus() and get_viewport().gui_get_hovered_control() == self

func _sample_hover(local_position: Vector2) -> void:
	var cell := _cell_from_local(local_position)
	if definition == null or not Rect2(Vector2.ZERO, size).has_point(local_position) \
			or cell.x < 0 or cell.y < 0 or cell.x >= definition.width or cell.y >= definition.height:
		cell = Vector2i(-1, -1)
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
## board only renders it, never decides which arrow is legal. Superseding an
## existing suggestion (a repeated request) clears the prior one first.
func suggest_open_move(head: Vector2i) -> void:
	if not _views.has(head):
		return
	clear_suggestion()
	_suggested_head = head
	_views[head].set_suggested(true)

## Clears any active suggestion indicator. Called on any accepted selection
## (played or blocked) and on a fresh setup(), so a stale suggestion never
## outlives the board state it was shown against.
func clear_suggestion() -> void:
	if _suggested_head != null and _views.has(_suggested_head):
		_views[_suggested_head].set_suggested(false)
	_suggested_head = null

func setup(new_definition: PuzzleDefinition) -> void:
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
	for head in definition.arrows.keys():
		var cells: Array[Vector2i] = definition.get_arrow_cells(head)
		var bbox_min: Vector2i = _bounding_min(cells)
		var offsets: Array[Vector2i] = []
		for cell in cells:
			offsets.append(cell - bbox_min)
		var view := ArrowView.new()
		view.set_shape(head - bbox_min, offsets, definition.arrows[head])
		add_child(view)
		_views[head] = view
	_layout_views()

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

func _layout_views() -> void:
	if definition == null or size.x <= 0.0 or size.y <= 0.0:
		return
	var cell_extent: float = min(size.x / float(definition.width), size.y / float(definition.height))
	_cell_size = Vector2(cell_extent, cell_extent)
	_origin = (size - Vector2(cell_extent * definition.width, cell_extent * definition.height)) / 2.0
	_departure_clip.position = _origin
	_departure_clip.size = Vector2(cell_extent * definition.width, cell_extent * definition.height)
	for head in _views.keys():
		var view: ArrowView = _views[head]
		_position_view(view, head, cell_extent, _origin)
	for head in _departing_views.keys():
		var view: ArrowView = _departing_views[head]
		_position_view(view, head, cell_extent, Vector2.ZERO)

## bbox-relative position/size for an owned shape, offset by origin (board
## coordinates for active views, or zero for departing views already
## parented under _departure_clip which itself sits at the grid origin).
func _position_view(view: ArrowView, head: Vector2i, cell_extent: float, origin: Vector2) -> void:
	var cells: Array[Vector2i] = definition.get_arrow_cells(head)
	var bbox_min: Vector2i = _bounding_min(cells)
	var bbox_max: Vector2i = _bounding_max(cells)
	view.position = origin + Vector2(bbox_min.x, bbox_min.y) * cell_extent
	view.size = Vector2(bbox_max.x - bbox_min.x + 1, bbox_max.y - bbox_min.y + 1) * cell_extent
	view.set_cell_extent(cell_extent)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_views()
		_last_hover_cell = Vector2i(-1, -1)
	elif what == NOTIFICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT \
			or what == NOTIFICATION_WM_MOUSE_EXIT or what == NOTIFICATION_VISIBILITY_CHANGED:
		clear_hover()

func _cell_from_local(local_position: Vector2) -> Vector2i:
	if _cell_size.x <= 0.0 or _cell_size.y <= 0.0:
		return Vector2i(-1, -1)
	var relative: Vector2 = local_position - _origin
	return Vector2i(int(floor(relative.x / _cell_size.x)), int(floor(relative.y / _cell_size.y)))

## A discrete left-click press produces at most one selection request; a
## held button must not repeat without a new physical click. Any cell of a
## multi-cell shape (head or tail) is emitted as-is; the controller resolves
## the owning arrow before deciding the outcome.
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_sample_hover(event.position)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed and not event.is_echo():
		cell_clicked.emit(_cell_from_local(event.position))

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
	if _cell_size.x > 0.0:
		_position_view(view, head, _cell_size.x, Vector2.ZERO)
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
