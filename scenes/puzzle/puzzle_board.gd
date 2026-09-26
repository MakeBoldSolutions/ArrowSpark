class_name PuzzleBoard
extends Control
## Board layout, click-to-cell mapping and arrow views. Holds no puzzle
## rules; the controller decides outcomes and tells this board what to
## display, always by an arrow's canonical head.

signal cell_clicked(cell: Vector2i)
signal departure_finished

var definition: PuzzleDefinition
var _views: Dictionary # Vector2i (head) -> ArrowView
var _cell_size: Vector2 = Vector2.ZERO
var _origin: Vector2 = Vector2.ZERO

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func setup(new_definition: PuzzleDefinition) -> void:
	for view in _views.values():
		view.queue_free()
	_views.clear()
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
	for head in _views.keys():
		var view: ArrowView = _views[head]
		var cells: Array[Vector2i] = definition.get_arrow_cells(head)
		var bbox_min: Vector2i = _bounding_min(cells)
		var bbox_max: Vector2i = _bounding_max(cells)
		view.position = _origin + Vector2(bbox_min.x, bbox_min.y) * cell_extent
		view.size = Vector2(bbox_max.x - bbox_min.x + 1, bbox_max.y - bbox_min.y + 1) * cell_extent
		view.set_cell_extent(cell_extent)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_views()

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
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed and not event.is_echo():
		cell_clicked.emit(_cell_from_local(event.position))

func play_removed(head: Vector2i) -> void:
	var view: ArrowView = _views.get(head)
	if view == null:
		return
	_views.erase(head)
	view.play_exit_animation(size.length())
	view.exit_finished.connect(func():
		departure_finished.emit()
		view.queue_free()
	)

func play_blocked(head: Vector2i) -> void:
	var view: ArrowView = _views.get(head)
	if view:
		view.play_blocked_feedback()
