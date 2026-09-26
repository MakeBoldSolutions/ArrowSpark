extends SceneTree

var failures: int = 0

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func write_save(text: String) -> void:
	var file = FileAccess.open(GlobalState.SAVE_STATE_PATH, FileAccess.WRITE)
	file.store_string(text)
	file.close()

func _initialize() -> void:
	print("TEST_USER_DIR=", OS.get_user_data_dir())
	GlobalState.open()
	check(not GlobalState.save_blocked, "missing save initializes normally")
	GlobalState.current.first_version_opened = "retained-value"
	check(GlobalState.save() == OK, "valid state saves")
	GlobalState.current = null
	GlobalState.open()
	check(GlobalState.current.first_version_opened == "retained-value", "valid state survives reload")

	write_save("CORRUPT_SAVE_SENTINEL")
	GlobalState.current = null
	GlobalState.open()
	check(GlobalState.save_blocked, "corrupt save blocks writes")
	check(GlobalState.save() == ERR_UNAVAILABLE, "ordinary save cannot bypass recovery")
	check(FileAccess.get_file_as_string(GlobalState.SAVE_STATE_PATH) == "CORRUPT_SAVE_SENTINEL", "corrupt original remains intact")
	check(GlobalState.reset() == OK, "explicit reset succeeds after backup")
	check(FileAccess.get_file_as_string(GlobalState.SAVE_STATE_PATH + ".recovery") == "CORRUPT_SAVE_SENTINEL", "reset preserves exact original bytes")
	check(not GlobalState.save_blocked, "reset re-enables saving")

	ResourceSaver.save(Resource.new(), GlobalState.SAVE_STATE_PATH)
	var incompatible = FileAccess.get_file_as_string(GlobalState.SAVE_STATE_PATH)
	GlobalState.current = null
	GlobalState.open()
	check(GlobalState.save_blocked, "wrong resource type blocks saving")
	check(FileAccess.get_file_as_string(GlobalState.SAVE_STATE_PATH) == incompatible, "incompatible original remains intact")
	check(GlobalState.reset() == OK, "incompatible save can be explicitly reset")
	check(FileAccess.get_file_as_string(GlobalState.SAVE_STATE_PATH + ".recovery.1") == incompatible, "backup collision retains both originals")

	write_save("BACKUP_FAILURE_SENTINEL")
	GlobalState.current = null
	GlobalState.open()
	DirAccess.make_dir_absolute(GlobalState.SAVE_STATE_PATH + ".recovery.2")
	check(GlobalState.reset() != OK, "backup failure cancels reset")
	check(GlobalState.save_blocked, "backup failure keeps write protection")
	check(FileAccess.get_file_as_string(GlobalState.SAVE_STATE_PATH) == "BACKUP_FAILURE_SENTINEL", "backup failure preserves original")

	DirAccess.remove_absolute(GlobalState.SAVE_STATE_PATH)
	DirAccess.make_dir_absolute(GlobalState.SAVE_STATE_PATH)
	GlobalState.save_blocked = false
	check(GlobalState.save() != OK, "write errors reach caller")

	var action = "regression_move"
	InputMap.add_action(action)
	var key = InputEventKey.new()
	key.physical_keycode = KEY_W
	var joy = InputEventJoypadButton.new()
	joy.button_index = JOY_BUTTON_A
	InputMap.action_add_event(action, key)
	InputMap.action_add_event(action, joy)
	AppSettings.set_default_inputs()
	var replacement = InputEventKey.new()
	replacement.physical_keycode = KEY_Q
	Config.set_config(AppSettings.INPUT_SECTION, action, [replacement, joy])
	Config.config_file = null
	Config.load_config_file()
	AppSettings.set_input_from_config(action)
	check(InputMap.action_has_event(action, replacement), "saved keyboard remap restored from disk")
	check(InputMap.action_has_event(action, joy), "unchanged gamepad binding restored from disk")
	check(InputMap.action_get_events(action).size() == 2, "complete mapping restored")
	check(not InputMap.action_has_event(action, key), "old keyboard binding removed")
	AppSettings.set_input_from_config(action)
	check(InputMap.action_get_events(action).size() == 2, "repeated restoration does not duplicate bindings")
	AppSettings.reset_to_default_inputs()
	check(InputMap.action_has_event(action, key) and InputMap.action_has_event(action, joy), "reset restores keyboard and gamepad defaults")
	var corrupt_settings = "[AudioSettings]\nvolume=0.5\nbroken=INVALID_SENTINEL\n"
	var settings_file = FileAccess.open(Config.CONFIG_FILE_LOCATION, FileAccess.WRITE)
	settings_file.store_string(corrupt_settings)
	settings_file.close()
	Config.config_file = null
	Config.load_config_file()
	check(Config.save_blocked, "corrupt settings block writes")
	check(Config.get_config("AudioSettings", "volume", 1.0) == 1.0, "partially parsed settings discarded")
	Config.set_config("Session", "value", 42)
	check(Config.get_config("Session", "value") == 42, "temporary settings remain usable")
	Config.erase_section_key("Session", "value")
	Config.set_config("Session", "other", 1)
	Config.erase_section("Session")
	check(Config._save_config_file() == ERR_UNAVAILABLE, "direct settings save stays blocked")
	check(FileAccess.get_file_as_string(Config.CONFIG_FILE_LOCATION) == corrupt_settings, "all settings mutation paths preserve original")
	DirAccess.make_dir_absolute(Config.CONFIG_FILE_LOCATION + ".recovery")
	check(Config.reset_unreadable_config() != OK and Config.save_blocked, "settings backup failure cancels reset")
	check(FileAccess.get_file_as_string(Config.CONFIG_FILE_LOCATION) == corrupt_settings, "settings backup failure preserves original")
	DirAccess.remove_absolute(Config.CONFIG_FILE_LOCATION + ".recovery")
	check(Config.reset_unreadable_config() == OK, "explicit settings reset succeeds")
	check(FileAccess.get_file_as_string(Config.CONFIG_FILE_LOCATION + ".recovery") == corrupt_settings, "settings backup preserves exact bytes")
	check(not Config.save_blocked, "settings reset enables writes")
	Config.set_config("Session", "value", 99)
	Config.config_file = null
	Config.load_config_file()
	check(Config.get_config("Session", "value") == 99, "settings persist after reset and reload")
	print("REGRESSION_FAILURES=", failures)
	quit(1 if failures else 0)
