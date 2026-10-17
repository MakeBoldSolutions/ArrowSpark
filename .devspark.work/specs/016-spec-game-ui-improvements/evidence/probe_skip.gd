extends SceneTree
## Throwaway probe: splash skip (ui_cancel and ui_accept released) to the Main Menu.
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	for action in [&"", &"ui_cancel", &"ui_accept"]:
		var start := Time.get_ticks_msec()
		change_scene_to_file("res://scenes/opening/opening_with_logo.tscn")
		await create_timer(0.4).timeout
		if action != &"":
			var released := InputEventAction.new()
			released.action = action
			released.pressed = false
			Input.parse_input_event(released)
		while (current_scene == null or current_scene.name != "MainMenu") and Time.get_ticks_msec() - start < 6000:
			await process_frame
		print("PROBE splash_skip=%s reached_menu_ms=%d" % [action if action != &"" else "none", Time.get_ticks_msec() - start])
		await create_timer(0.5).timeout
	quit()
