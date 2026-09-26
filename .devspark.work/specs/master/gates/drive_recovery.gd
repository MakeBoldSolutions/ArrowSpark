extends SceneTree

func _initialize():
	drive.call_deferred()

func demand(condition: bool, label: String):
	if not condition:
		push_error("FAIL: " + label)
		quit(1)
		return false
	print("PASS: " + label)
	return true

func prompt(title_text: String) -> ConfirmationDialog:
	for child in root.get_node("AppConfig").get_children():
		if child is ConfirmationDialog and child.visible and child.title == title_text:
			return child
	return null

func drive():
	await process_frame
	await process_frame
	var phase = OS.get_environment("VERIFY_PHASE")
	if phase == "restart":
		if not demand(not GlobalState.save_blocked and not Config.save_blocked, "restart loads recovered files without blocking"): return
		if not demand(GameState.get_current_level() == 2, "progress survives actual process restart"): return
		var events = InputMap.action_get_events("move_up")
		var key_found = false
		var joy_found = false
		for event in events:
			if event is InputEventKey and event.physical_keycode == KEY_Q: key_found = true
			if event is InputEventJoypadMotion: joy_found = true
		if not demand(key_found and joy_found, "keyboard remap and unchanged gamepad axis survive restart"): return
	else:
		var save_prompt = prompt("Saved progress could not be loaded")
		if not demand(save_prompt != null, "real startup shows progress recovery"): return
		if phase == "cancel":
			save_prompt.get_cancel_button().pressed.emit()
		else:
			save_prompt.get_ok_button().pressed.emit()
		await process_frame
		await process_frame
		var settings_prompt = prompt("Settings could not be loaded")
		if not demand(settings_prompt != null, "settings recovery follows progress dialog"): return
		if phase == "cancel":
			settings_prompt.get_cancel_button().pressed.emit()
			Config.set_config("Session", "value", 7)
			GlobalState.save()
			if not demand(GlobalState.save_blocked and Config.save_blocked, "cancel preserves write protection for both files"): return
		else:
			settings_prompt.get_ok_button().pressed.emit()
			if not demand(not GlobalState.save_blocked and not Config.save_blocked, "confirm resets both files and enables persistence"): return
			GameState.set_current_level(2)
			var events = InputMap.action_get_events("move_up")
			var replacement = InputEventKey.new()
			replacement.physical_keycode = KEY_Q
			var saved: Array = [replacement]
			for event in events:
				if event is InputEventJoypadMotion: saved.append(event)
			AppSettings.set_config_input_events("move_up", saved)
			print("PASS: real progress and input settings written for restart")
	print("END_TO_END_PHASE_PASS=", phase)
	quit(0)
