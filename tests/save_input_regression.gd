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
	_test_no_reset_on_puzzle_entry()
	_test_puzzle_scoreboard_session_only()
	print("REGRESSION_FAILURES=", failures)
	quit(1 if failures else 0)

## PuzzleScoreboard's session-best/overall-score bookkeeping
## must never reach the save file, and a freshly started process must begin
## with no remembered scores at all.
func _test_puzzle_scoreboard_session_only() -> void:
	check(PuzzleScoreboard.get_overall_score() == 0,
		"a freshly started process begins with a zero overall session score")
	check(PuzzleScoreboard.get_best(PuzzleCatalog.id_at(0)) == null,
		"a freshly started process begins with no session-best entries")

	var save_path := GlobalState.SAVE_STATE_PATH
	var save_bytes_before: PackedByteArray = FileAccess.get_file_as_bytes(save_path) if FileAccess.file_exists(save_path) else PackedByteArray()

	PuzzleScoreboard.record_attempt(PuzzleCatalog.id_at(0),
		{"total_arrows": 8, "mistakes": 0, "open_move_assists": 0, "score": 8, "accuracy": 1.0})
	PuzzleScoreboard.record_attempt(PuzzleCatalog.id_at(1),
		{"total_arrows": 6, "mistakes": 1, "open_move_assists": 1, "score": 0, "accuracy": 0.8})
	check(PuzzleScoreboard.get_overall_score() == 8,
		"recording completed attempts updates the in-memory overall session score (sum of stored bests)")

	var save_bytes_after: PackedByteArray = FileAccess.get_file_as_bytes(save_path) if FileAccess.file_exists(save_path) else PackedByteArray()
	check(save_bytes_after == save_bytes_before,
		"recording PuzzleScoreboard attempts never writes to the save file (user://global_state.tres)")

## Opening the puzzle from Play/New Game MUST NOT reset or save existing
## progress, or disturb keyboard/gamepad remaps. Guards against a future
## template refresh silently reintroducing GlobalState.reset()/
## GameState.start_game() on that path, or wiring puzzle entry into the
## input-remap system it currently never touches (registered as
## "SceneLoader" autoload, tests/scene_loader_stub.gd records calls without
## touching the filesystem or scene tree).
func _test_no_reset_on_puzzle_entry() -> void:
	GlobalState.current = null
	GlobalState.open()
	var game_state: GameState = GameState.get_game_state()
	game_state.max_level_reached = 3
	game_state.times_played = 5
	game_state.current_level = 2
	GameState.get_level_state("preserved_level")
	GlobalState.save()

	var remap_action := "regression_puzzle_entry_move"
	InputMap.add_action(remap_action)
	var remap_key := InputEventKey.new()
	remap_key.physical_keycode = KEY_W
	var remap_joy := InputEventJoypadButton.new()
	remap_joy.button_index = JOY_BUTTON_A
	InputMap.action_add_event(remap_action, remap_key)
	InputMap.action_add_event(remap_action, remap_joy)
	AppSettings.set_default_inputs()
	var seeded_remap := InputEventKey.new()
	seeded_remap.physical_keycode = KEY_Q
	Config.set_config(AppSettings.INPUT_SECTION, remap_action, [seeded_remap, remap_joy])
	AppSettings.set_input_from_config(remap_action)
	check(InputMap.action_has_event(remap_action, seeded_remap) and InputMap.action_has_event(remap_action, remap_joy),
		"a keyboard/gamepad remap is seeded and active before puzzle entry")

	var menu = load("res://main_menu_with_animations.gd").new()
	menu.game_scene_path = "res://dummy_puzzle.tscn"

	menu.new_game()
	check(InputMap.action_has_event(remap_action, seeded_remap) and InputMap.action_has_event(remap_action, remap_joy),
		"new_game() does not disturb a seeded keyboard/gamepad remap")
	var after_new_game: GameState = GameState.get_game_state()
	check(after_new_game.times_played == 5,
		"new_game() does not call GameState.start_game() (times_played unchanged)")
	check(after_new_game.max_level_reached == 3,
		"new_game() does not call GlobalState.reset() (max_level_reached unchanged)")
	check(after_new_game.level_states.has("preserved_level"),
		"new_game() does not call GlobalState.reset() (existing level_states preserved)")
	# Accessed via get_node, not the bare "SceneLoader" identifier: this entry
	# script is compiled before autoloads register as global constants, so a
	# bare autoload identifier here fails to compile even though it resolves
	# fine from a script loaded later (e.g. main_menu_with_animations.gd above).
	var scene_loader := get_root().get_node("SceneLoader")
	check(scene_loader.load_scene_calls >= 1,
		"new_game() still opens the puzzle via SceneLoader.load_scene")

	menu.load_game_scene()
	var after_load_game_scene: GameState = GameState.get_game_state()
	check(after_load_game_scene.times_played == 5,
		"load_game_scene() does not call GameState.start_game() (times_played unchanged)")
	check(InputMap.action_has_event(remap_action, seeded_remap) and InputMap.action_has_event(remap_action, remap_joy),
		"load_game_scene() does not disturb a seeded keyboard/gamepad remap")

	# Level Select selection: PuzzleSession updates and the puzzle opens via
	# SceneLoader, with the same no-reset/no-remap-disturbance guarantee.
	var chosen_id := PuzzleCatalog.id_at(3)
	var load_scene_calls_before: int = scene_loader.load_scene_calls
	menu._on_puzzle_selected(chosen_id)
	check(PuzzleSession.get_current_id() == chosen_id,
		"selecting a Level Select entry sets PuzzleSession to that catalog id")
	check(scene_loader.load_scene_calls > load_scene_calls_before,
		"selecting a Level Select entry still opens the puzzle via SceneLoader.load_scene")
	var after_level_select: GameState = GameState.get_game_state()
	check(after_level_select.times_played == 5,
		"selecting a Level Select entry does not call GameState.start_game() (times_played unchanged)")
	check(after_level_select.max_level_reached == 3,
		"selecting a Level Select entry does not call GlobalState.reset() (max_level_reached unchanged)")
	check(InputMap.action_has_event(remap_action, seeded_remap) and InputMap.action_has_event(remap_action, remap_joy),
		"selecting a Level Select entry does not disturb a seeded keyboard/gamepad remap")

	# New Game always starts catalog position 0, regardless of the Level
	# Select choice above having already changed PuzzleSession this session.
	menu.new_game()
	check(PuzzleSession.get_current_id() == PuzzleCatalog.id_at(0),
		"new_game() resets PuzzleSession to catalog position 0 regardless of a prior Level Select selection")

	menu.free()
