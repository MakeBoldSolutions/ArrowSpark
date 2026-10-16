extends SceneTree
## Throwaway rendered inventory walk: captures every reachable surface and drives Main Menu
## focus with simulated keyboard and gamepad navigation events.
## Usage (isolated APPDATA): <godot> --path . --script <this file> -- <width> <height> <out_dir>

var out_dir := ""
var window_size := Vector2i(1280, 720)

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	window_size = Vector2i(int(args[0]), int(args[1]))
	out_dir = args[2]
	for attempt in range(5):
		DisplayServer.window_set_size(window_size)
		await create_timer(0.2).timeout
		if DisplayServer.window_get_size() == window_size:
			break
	change_scene_to_file("res://scenes/opening/opening_with_logo.tscn")
	await create_timer(1.2).timeout
	_save("01_splash")
	change_scene_to_file("res://scenes/menus/main_menu/main_menu_with_animations.tscn")
	await create_timer(0.3).timeout
	var loading: Node = load("res://scenes/loading_screen/loading_screen.tscn").instantiate()
	root.add_child(loading)
	await create_timer(0.3).timeout
	_save("02_loading_screen")
	loading.queue_free()
	await create_timer(3.0).timeout
	_save("03_main_menu")
	await _navigate_focus()
	var menu := current_scene
	menu.call("_on_level_select_button_pressed")
	await create_timer(0.6).timeout
	_save("04_level_select")
	menu.call("_close_sub_menu")
	menu.call("_on_options_button_pressed")
	await create_timer(0.6).timeout
	var tabs := menu.find_child("TabContainer", true, false) as TabContainer
	for i in range(tabs.get_tab_count()):
		tabs.current_tab = i
		await create_timer(0.3).timeout
		_save("05_options_%d_%s" % [i, tabs.get_tab_title(i).to_lower()])
		var option := _first_visible(tabs.get_current_tab_control(), "OptionButton") as OptionButton
		if option != null:
			option.show_popup()
			await create_timer(0.3).timeout
			_save("06_options_%d_dropdown" % i)
			option.get_popup().hide()
		var reset := tabs.get_current_tab_control().find_child("ResetGameControl", true, false)
		if reset != null:
			reset.call("_on_ResetButton_pressed")
			await create_timer(0.3).timeout
			_save("07_reset_confirmation")
			reset.get_node("ConfirmResetDialog").hide()
			reset.call("_on_confirm_reset_dialog_canceled")
	menu.call("_close_sub_menu")
	menu.call("_on_credits_button_pressed")
	await create_timer(7.0).timeout
	_save("08_credits")
	PuzzleSession.set_current_id("first_knot")
	change_scene_to_file("res://scenes/puzzle/arrow_puzzle.tscn")
	await create_timer(0.8).timeout
	_save("09_puzzle")
	var press := InputEventAction.new()
	press.action = &"ui_cancel"
	press.pressed = true
	Input.parse_input_event(press)
	await create_timer(0.6).timeout
	_save("10_pause")
	var pause := current_scene.find_child("PauseMenu", true, false)
	if pause != null:
		pause.queue_free()
	paused = false
	await create_timer(0.3).timeout
	var puzzle := current_scene
	var board = puzzle.get("_board")
	var witness: Array = PuzzleSolver.analyze(PuzzleCatalog.get_definition("first_knot"))["witness"]
	for head in witness:
		board.cell_clicked.emit(head)
	await create_timer(12.0).timeout
	_save("11_results")
	quit()

## Simulated keyboard (ui_down) and gamepad (D-pad down) navigation through the menu.
func _navigate_focus() -> void:
	var trail: Array[String] = []
	var owner := root.gui_get_focus_owner()
	trail.append(owner.name if owner else "<none>")
	for step in range(4):
		var key := InputEventAction.new()
		key.action = &"ui_down"
		key.pressed = true
		Input.parse_input_event(key)
		await process_frame
		var release := InputEventAction.new()
		release.action = &"ui_down"
		release.pressed = false
		Input.parse_input_event(release)
		await create_timer(0.1).timeout
		owner = root.gui_get_focus_owner()
		trail.append(owner.name if owner else "<none>")
	print("FOCUS keyboard ", " > ".join(trail))
	_save("03b_main_menu_keyboard_focus")
	var pad_trail: Array[String] = []
	for step in range(3):
		var pad := InputEventJoypadButton.new()
		pad.button_index = JOY_BUTTON_DPAD_UP
		pad.pressed = true
		Input.parse_input_event(pad)
		await process_frame
		var pad_release := InputEventJoypadButton.new()
		pad_release.button_index = JOY_BUTTON_DPAD_UP
		pad_release.pressed = false
		Input.parse_input_event(pad_release)
		await create_timer(0.1).timeout
		owner = root.gui_get_focus_owner()
		pad_trail.append(owner.name if owner else "<none>")
	print("FOCUS gamepad ", " > ".join(pad_trail))
	var focus := owner.get_theme_stylebox("focus") as StyleBoxFlat if owner else null
	print("FOCUS ring_ember=", focus != null and focus.border_color == GameVisualStyle.ARROW_HOVER)

func _first_visible(node: Node, type: String) -> Control:
	for child in node.find_children("*", type, true, false):
		if child is Control and child.is_visible_in_tree():
			return child
	return null

func _save(name: String) -> void:
	var path := "%s/%s_%dx%d.png" % [out_dir, name, window_size.x, window_size.y]
	root.get_texture().get_image().save_png(path)
	print("SAVED ", name)
