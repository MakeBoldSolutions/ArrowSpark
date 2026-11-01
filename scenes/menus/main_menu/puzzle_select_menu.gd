extends Control
## Minimal, catalog-driven Level Select content: accordion group sections. Each
## purpose group has a header button that collapses or expands its entries,
## followed by one line saying what the group is for (never a ranking);
## entries are keyboard/gamepad focus-navigable card buttons in a two-column
## grid, numbered within their group and edged in the group's accent,
## emitting puzzle_selected(id) on selection. Collapsed entries are
## hidden, so focus skips them. Every group starts expanded. No locked/unlocked states —
## every catalog entry is always selectable. Built directly against
## PuzzleCatalog, not the addon example's GameState-backed script.

signal puzzle_selected(id: String)

## Card accent per purpose group (a GameVisualStyle LevelCard variation).
const GROUP_CARD_VARIATIONS := {
	PuzzleCatalog.GROUP_ARROWSPARK_LEVELS: &"LevelCardRust",
	PuzzleCatalog.GROUP_FOUNDATIONS: &"LevelCardInk",
	PuzzleCatalog.GROUP_PUZZLE_LAB: &"LevelCardEmber",
	PuzzleCatalog.GROUP_GENERATED: &"LevelCardEmber",
}
const CARD_COLUMNS := 2
const CARD_WIDTH := 300

## One honest line per purpose group. Shown even when the group is collapsed.
const GROUP_DESCRIPTIONS := {
	PuzzleCatalog.GROUP_ARROWSPARK_LEVELS: "The intended ArrowSpark experience.",
	PuzzleCatalog.GROUP_FOUNDATIONS: "Small boards that teach the rule.",
	PuzzleCatalog.GROUP_PUZZLE_LAB: "Development experiments, some deliberately over-tangled.",
	PuzzleCatalog.GROUP_GENERATED: "Boards built by the level generator; an untuned first sample.",
}

@onready var _list_container: VBoxContainer = %PuzzleListContainer

var _first_button: Button
var _header_buttons: Array[Button] = []
var _entry_buttons: Array[Button] = []
var _description_labels: Array[Label] = []

func _ready() -> void:
	resized.connect(_reflow)
	_reflow.call_deferred()
	for group_id in PuzzleCatalog.group_ids():
		var members := PuzzleCatalog.ids_in_group(group_id)
		var header := Button.new()
		header.toggle_mode = true
		header.button_pressed = true
		header.alignment = HORIZONTAL_ALIGNMENT_LEFT
		header.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		header.focus_mode = Control.FOCUS_ALL
		header.theme_type_variation = &"LevelGroupHeader"
		_list_container.add_child(header)
		_header_buttons.append(header)
		var description := Label.new()
		description.text = String(GROUP_DESCRIPTIONS.get(group_id, ""))
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.theme_type_variation = &"SupportingText"
		description.focus_mode = Control.FOCUS_NONE
		_list_container.add_child(description)
		_description_labels.append(description)
		var section := GridContainer.new()
		section.columns = CARD_COLUMNS
		section.add_theme_constant_override("h_separation", 12)
		section.add_theme_constant_override("v_separation", 12)
		_list_container.add_child(section)
		for id in members:
			var button := Button.new()
			button.text = "%d. %s" % [PuzzleCatalog.group_position(id), PuzzleCatalog.get_title(id)]
			button.focus_mode = Control.FOCUS_ALL
			button.theme_type_variation = GROUP_CARD_VARIATIONS.get(group_id, &"LevelCardInk")
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			button.custom_minimum_size = Vector2(CARD_WIDTH, 0)
			button.tooltip_text = button.text
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

## The group description lines, in group order.
func description_labels() -> Array[Label]:
	return _description_labels

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
	var target := _first_visible_focus_target()
	if target != null:
		target.grab_focus()

## The first entry button that can be seen, or the first group header when every
## group is collapsed, so focus never lands on a hidden control (a collapsed
## group keeps its state when the menu is reopened).
func _first_visible_focus_target() -> Button:
	for button in _entry_buttons:
		if button.is_visible_in_tree():
			return button
	for header in _header_buttons:
		if header.is_visible_in_tree():
			return header
	return null

func _reflow() -> void:
	if not is_node_ready():
		return
	var available := maxf(0.0, size.x - 28.0)
	var columns := 2 if available >= CARD_WIDTH * 2 + 12 else 1
	for section in _list_container.get_children():
		if section is GridContainer:
			section.columns = columns
	for button in _entry_buttons:
		button.custom_minimum_size.x = minf(CARD_WIDTH, maxf(0, (available - 12 * (columns - 1)) / columns))
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_list_container.custom_minimum_size.x = available
