extends PauseMenuController
## Shares one overlay entry between touch Menu and the bound cancel action.
var _menu: Control

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		open_menu()

func open_menu() -> void:
	if is_instance_valid(_menu) or get_tree().paused:
		return
	var scene := get_tree().current_scene
	if scene == null or scene.get("_awaiting_completion") == true:
		return
	var results := scene.get_node_or_null("%PuzzleResults")
	if results != null and results.visible:
		return
	_menu = pause_menu_packed.instantiate()
	scene.add_child(_menu)
