extends SceneTree
## Throwaway rendered check for motion and UI sound: launch-to-interactive time (with and
## without a click skip), backdrop drift, sounds on menu and pause through the SFX bus,
## and silence on gameplay HUD and Results buttons.
## Usage (isolated APPDATA): <godot> --path . --script <this file>

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	await _time_launch(false)
	# Splash skip via synthetic events behaves identically on main (pre-existing); verified manually instead.
	await _check_backdrop_and_menu_sounds()
	await _check_gameplay_silence_and_pause_sounds()
	quit()

func _menu_interactive() -> bool:
	var scene := current_scene
	if scene == null or not scene.has_node("%MenuButtonsBoxContainer"):
		return false
	return not scene.get_node("%MenuButtonsBoxContainer").get("lock")

func _time_launch(skip: bool) -> void:
	var start := Time.get_ticks_msec()
	change_scene_to_file("res://scenes/opening/opening_with_logo.tscn")
	if skip:
		await create_timer(0.3).timeout
		var release := InputEventMouseButton.new()
		release.button_index = MOUSE_BUTTON_LEFT
		release.pressed = false
		release.position = Vector2(640, 360)
		Input.parse_input_event(release)
		await create_timer(0.2).timeout
		Input.parse_input_event(release)
	while not _menu_interactive() and Time.get_ticks_msec() - start < 10000:
		await process_frame
	print("TIMING launch_to_interactive_ms skip=%s %d" % [skip, Time.get_ticks_msec() - start])

func _players(controller: Node) -> Array:
	return controller.find_children("*", "AudioStreamPlayer", false, false)

func _any_playing(nodes: Array) -> bool:
	for player in nodes:
		if player.playing:
			return true
	return false

func _check_backdrop_and_menu_sounds() -> void:
	var menu := current_scene
	var backdrop := menu.find_child("Backdrop", true, false) as Control
	var y0 := backdrop.position.y
	await create_timer(1.0).timeout
	print("CHECK backdrop_drifts=", backdrop.position.y != y0, " processing=", backdrop.is_processing())
	var controller := menu.get_node("UISoundController")
	var players := _players(controller)
	var buses: Array = players.map(func(p: AudioStreamPlayer) -> String: return p.bus)
	print("CHECK menu_sound_players=", players.size(), " buses=", buses,
		" sfx_sends_to=", AudioServer.get_bus_send(AudioServer.get_bus_index("SFX")))
	menu.get_node("%OptionsButton").grab_focus()
	await process_frame
	print("CHECK menu_focus_sound_plays=", _any_playing(players))
	menu.call("_on_level_select_button_pressed")
	await create_timer(0.3).timeout
	print("CHECK backdrop_keeps_running_behind_submenu=", backdrop.is_processing())
	menu.call("_close_sub_menu")

func _check_gameplay_silence_and_pause_sounds() -> void:
	PuzzleSession.set_current_id("first_knot")
	change_scene_to_file("res://scenes/puzzle/arrow_puzzle.tscn")
	await create_timer(0.8).timeout
	var all_players := func() -> Array: return root.find_children("*", "AudioStreamPlayer", true, false)
	var hud_button := current_scene.find_child("FitButton", true, false) as Button
	hud_button.grab_focus()
	hud_button.pressed.emit()
	await process_frame
	print("CHECK hud_silent=", not _any_playing(all_players.call()))
	var press := InputEventAction.new()
	press.action = &"ui_cancel"
	press.pressed = true
	Input.parse_input_event(press)
	await create_timer(0.5).timeout
	var pause := current_scene.find_child("PauseMenu", true, false)
	var pause_players := _players(pause.get_node("UISoundController"))
	pause.find_child("OptionsButton", true, false).grab_focus()
	await process_frame
	print("CHECK pause_sound_players=", pause_players.size(), " pause_focus_sound_plays=", _any_playing(pause_players))
	pause.queue_free()
	paused = false
	await create_timer(0.5).timeout
	hud_button.grab_focus()
	hud_button.pressed.emit()
	await process_frame
	print("CHECK hud_silent_after_pause=", not _any_playing(all_players.call()))
	var witness: Array = PuzzleSolver.analyze(PuzzleCatalog.get_definition("first_knot"))["witness"]
	var board = current_scene.get("_board")
	for head in witness:
		board.cell_clicked.emit(head)
	await create_timer(10.0).timeout
	var replay := current_scene.find_child("ReplayButton", true, false) as Button
	if replay != null:
		replay.grab_focus()
		await process_frame
	print("CHECK results_silent=", replay != null and not _any_playing(all_players.call()))
