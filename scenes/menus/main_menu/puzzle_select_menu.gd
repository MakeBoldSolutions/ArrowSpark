extends Control
## Minimal, catalog-driven Level Select content: accordion group sections. Each
## purpose group has a header button that collapses or expands its entries;
## entries are keyboard/gamepad focus-navigable buttons numbered within their
## group, emitting puzzle_selected(id) on selection. Collapsed entries are
## hidden, so focus skips them. Every group starts expanded. No locked/unlocked states —
## every catalog entry is always selectable. Built directly against
## PuzzleCatalog, not the addon example's GameState-backed script.

signal puzzle_selected(id: String)

@onready var _list_container: VBoxContainer = %PuzzleListContainer

var _first_button: Button
var _header_buttons: Array[Button] = []
var _entry_buttons: Array[Button] = []

func _ready() -> void:
	for group_id in PuzzleCatalog.group_ids():
		var members := PuzzleCatalog.ids_in_group(group_id)
		var header := Button.new()
		header.toggle_mode = true
		header.button_pressed = true
		header.alignment = HORIZONTAL_ALIGNMENT_LEFT
		header.focus_mode = Control.FOCUS_ALL
		header.theme_type_variation = &"SecondaryButton"
		_list_container.add_child(header)
		_header_buttons.append(header)
		var section := VBoxContainer.new()
		section.add_theme_constant_override("separation", 8)
		_list_container.add_child(section)
		for id in members:
			var button := Button.new()
			button.text = "%d. %s" % [PuzzleCatalog.group_position(id), PuzzleCatalog.get_title(id)]
			button.focus_mode = Control.FOCUS_ALL
			button.pressed.connect(_on_entry_pressed.bind(id))
			section.add_child(button)
			_entry_buttons.append(button)
			if _first_button == null:
				_first_button = button
		header.toggled.connect(_on_header_toggled.bind(header, section, group_id, members.size()))
		_refresh_header(header, true, group_id, members.size())

func _on_header_toggled(expanded: bool, header: Button, section: Control, group_id: String, count: int) -> void:
	section.visible = expanded
	_refresh_header(header, expanded, group_id, count)

func _refresh_header(header: Button, expanded: bool, group_id: String, count: int) -> void:
	header.text = "%s %s (%d)" % ["-" if expanded else "+", PuzzleCatalog.group_title(group_id), count]

## Puzzle entry buttons in presentation order, and the group header buttons.
func entry_buttons() -> Array[Button]:
	return _entry_buttons

func header_buttons() -> Array[Button]:
	return _header_buttons

func _on_entry_pressed(id: String) -> void:
	puzzle_selected.emit(id)

## The inherited _open_sub_menu()/_close_sub_menu() show/hide mechanism does
## not itself grab focus into a newly opened sub-menu. Explicitly grab focus
## onto the first entry whenever this menu becomes visible, mirroring
## puzzle_results.gd's existing _replay_button.grab_focus() convention.
func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree():
		call_deferred("_grab_first_entry_focus")

func _grab_first_entry_focus() -> void:
	if _first_button != null:
		_first_button.grab_focus()
