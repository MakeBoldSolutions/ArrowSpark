class_name PuzzleBoard
extends Control
## Board layout, click-to-cell mapping and arrow views. Holds no puzzle rules
## (FR-012); the controller decides outcomes and tells this board what to
## display (contracts/puzzle.md).

signal cell_clicked(cell: Vector2i)
signal departure_finished

var definition: PuzzleDefinition
var _views: Dictionary # Vector2i -> ArrowView
var _cell_size: Vector2 = Vector2.ZERO
var _origin: Vector2 = Vector2.ZERO

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func setup(new_definition: PuzzleDefinition) -> void:
	for view in _views.values():
		view.queue_free()
	_views.clear()
	definition = new_definition
	for cell in definition.arrows.keys():
		var view := ArrowView.new()
		view.set_direction(definition.arrows[cell])
		add_child(view)
		_views[cell] = view
	_layout_views()

func _layout_views() -> void:
	if definition == null or size.x <= 0.0 or size.y <= 0.0:
		return
	var cell_extent: float = min(size.x / float(definition.width), size.y / float(definition.height))
	_cell_size = Vector2(cell_extent, cell_extent)
	_origin = (size - Vector2(cell_extent * definition.width, cell_extent * definition.height)) / 2.0
	for cell in _views.keys():
		var view: ArrowView = _views[cell]
		view.position = _origin + Vector2(cell.x, cell.y) * cell_extent
		view.size = _cell_size

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_views()

func _cell_from_local(local_position: Vector2) -> Vector2i:
	if _cell_size.x <= 0.0 or _cell_size.y <= 0.0:
		return Vector2i(-1, -1)
	var relative: Vector2 = local_position - _origin
	return Vector2i(int(floor(relative.x / _cell_size.x)), int(floor(relative.y / _cell_size.y)))

## A discrete left-click press produces at most one selection request
## (FR-002); a held button must not repeat without a new physical click.
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed and not event.is_echo():
		cell_clicked.emit(_cell_from_local(event.position))

func play_removed(cell: Vector2i) -> void:
	var view: ArrowView = _views.get(cell)
	if view == null:
		return
	_views.erase(cell)
	view.play_exit_animation(size.length())
	view.exit_finished.connect(func():
		departure_finished.emit()
		view.queue_free()
	)

func play_blocked(cell: Vector2i) -> void:
	var view: ArrowView = _views.get(cell)
	if view:
		view.play_blocked_feedback()
