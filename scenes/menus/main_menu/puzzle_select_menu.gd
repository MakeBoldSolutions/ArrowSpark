extends Control
## Minimal, catalog-driven Level Select content: a keyboard/gamepad
## focus-navigable list of buttons bound to PuzzleCatalog.ids()/title_at(),
## emitting puzzle_selected(id) on selection. No locked/unlocked states —
## every catalog entry is always selectable. Built directly against
## PuzzleCatalog, not the addon example's GameState-backed script.

signal puzzle_selected(id: String)

@onready var _list_container: VBoxContainer = %PuzzleListContainer

func _ready() -> void:
	for i in range(PuzzleCatalog.count()):
		var id := PuzzleCatalog.id_at(i)
		var button := Button.new()
		button.text = "%d. %s" % [i + 1, PuzzleCatalog.get_title(id)]
		button.focus_mode = Control.FOCUS_ALL
		button.pressed.connect(_on_entry_pressed.bind(id))
		_list_container.add_child(button)

func _on_entry_pressed(id: String) -> void:
	puzzle_selected.emit(id)

## The inherited _open_sub_menu()/_close_sub_menu() show/hide mechanism does
## not itself grab focus into a newly opened sub-menu (verified by
## /devspark.critic, critic-001; Options/Credits share the same latent gap,
## but carry no keyboard/gamepad MUST requirement). Explicitly grab focus
## onto the first entry whenever this menu becomes visible, mirroring
## puzzle_results.gd's existing _replay_button.grab_focus() convention.
func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree():
		call_deferred("_grab_first_entry_focus")

func _grab_first_entry_focus() -> void:
	if _list_container.get_child_count() > 0:
		_list_container.get_child(0).grab_focus()
