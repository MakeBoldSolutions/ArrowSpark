extends SceneTree

var failures := 0
var output: String
var remap: InputEventKey
var save_bytes: PackedByteArray
var settings_bytes: PackedByteArray

func check(condition: bool, label: String) -> void:
	print("PASS: " if condition else "FAIL: ", label)
	if not condition:
		failures += 1

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	root.push_input(event)
	event.pressed = false
	root.push_input(event)

func click_control(control: Control) -> void:
	# Scripted activation supplements physical checks; it does not claim a mouse click.
	(control as BaseButton).pressed.emit()

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	output = OS.get_cmdline_user_args()[0]
	root.size = Vector2i(960, 540)
	var progress := GameState.get_game_state()
	progress.times_played = 5
	progress.max_level_reached = 3
	GlobalState.save()
	remap = InputEventKey.new()
	remap.physical_keycode = KEY_Q
	var joy := InputEventJoypadMotion.new()
	joy.axis = JOY_AXIS_LEFT_Y
	joy.axis_value = -1.0
	Config.set_config(AppSettings.INPUT_SECTION, "move_up", [remap, joy])
	AppSettings.set_input_from_config("move_up")
	save_bytes = FileAccess.get_file_as_bytes("user://global_state.tres")
	settings_bytes = FileAccess.get_file_as_bytes("user://config.cfg")
	root.get_node("SceneLoader").load_scene("res://scenes/menus/main_menu/main_menu_with_animations.tscn")
	await create_timer(1.8).timeout
	click_control(current_scene.get_node("%NewGameButton"))
	await create_timer(1.8).timeout
	check(current_scene.has_node("%PuzzleBoard"), "New Game opens puzzle")
	var puzzle = current_scene
	puzzle.get_node("%PuzzleBoard").cell_clicked.emit(Vector2i(3, 0))
	key(KEY_ESCAPE)
	await create_timer(0.15).timeout
	check(paused, "keyboard Escape opens pause during feedback")
	var menu = puzzle.get_node_or_null("PauseMenu")
	if menu == null:
		check(false, "pause menu exists")
		quit(1)
		return
	check(menu.theme != GameVisualStyle.get_theme(), "pause retains inherited theme")
	check(puzzle.get_node("%PuzzleBoard")._hovered_head == null, "pause clears hover")
	click_control(menu.find_child("RestartButton", true, false))
	await create_timer(0.1).timeout
	check(menu.get_node("%ConfirmRestart").visible, "Restart opens confirmation")
	menu.get_node("%ConfirmRestart").get_cancel_button().pressed.emit()
	menu.close_popup()
	check(puzzle._state.mistakes == 1, "Restart cancellation preserves attempt")
	click_control(menu.get_node("%OptionsButton"))
	await create_timer(0.25).timeout
	var options = menu.find_child("MiniOptionsOverlaidMenu", false, false)
	check(options != null, "Options opens within pause")
	if options:
		options.close()
	await create_timer(0.15).timeout
	key(KEY_ESCAPE)
	await create_timer(0.2).timeout
	check(not paused and puzzle._state.mistakes == 1, "resume preserves counters")
	key(KEY_ESCAPE)
	await create_timer(0.15).timeout
	menu = puzzle.get_node("PauseMenu")
	click_control(menu.find_child("RestartButton", true, false))
	await create_timer(0.1).timeout
	menu.get_node("%ConfirmRestart").confirmed.emit()
	await create_timer(0.4).timeout
	check(current_scene._state.mistakes == 0 and current_scene._state.remaining() == 8, "confirmed Restart reconstructs clean puzzle")
	for head in PuzzleSolver.analyze(PuzzleDefinition.create_fixed()).witness:
		current_scene.get_node("%PuzzleBoard").cell_clicked.emit(head)
	await create_timer(0.4).timeout
	var results = current_scene.get_node("%PuzzleResults")
	check(results.visible and results.get_node("%ReplayButton").has_focus(), "completion focuses Replay")
	key(KEY_RIGHT)
	check(results.get_node("%MainMenuButton").has_focus(), "keyboard navigates to Main Menu")
	key(KEY_LEFT)
	key(KEY_ENTER)
	await create_timer(0.4).timeout
	check(current_scene._state.remaining() == 8 and current_scene._state.total_taps == 0, "keyboard Replay reconstructs fresh attempt")
	for head in PuzzleSolver.analyze(PuzzleDefinition.create_fixed()).witness:
		current_scene.get_node("%PuzzleBoard").cell_clicked.emit(head)
	await create_timer(0.4).timeout
	click_control(current_scene.get_node("%PuzzleResults").get_node("%MainMenuButton"))
	await create_timer(1.8).timeout
	check(current_scene.has_node("%NewGameButton"), "results Main Menu returns to menu")
	check(InputMap.action_has_event("move_up", remap), "seeded remap survives roundtrip")
	check(FileAccess.get_file_as_bytes("user://global_state.tres") == save_bytes, "saved progress bytes unchanged")
	var before := ConfigFile.new()
	before.parse(settings_bytes.get_string_from_utf8())
	var after := ConfigFile.new()
	after.load("user://config.cfg")
	print("SETTINGS_BEFORE=", settings_bytes.get_string_from_utf8())
	print("SETTINGS_AFTER=", FileAccess.get_file_as_string("user://config.cfg"))
	for section in before.get_sections():
		for entry in before.get_section_keys(section):
			check(var_to_str(before.get_value(section, entry)) == var_to_str(after.get_value(section, entry)), "saved setting retained: %s/%s" % [section, entry])
	print("NAVIGATION_FAILURES=", failures, " JOYPADS=", Input.get_connected_joypads())
	quit(1 if failures else 0)
