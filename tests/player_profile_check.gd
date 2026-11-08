extends SceneTree
## Headless isolated-project checks for PlayerProfile: persistence across a
## simulated restart, best-score rules, resume position, name handling, recovery
## from an unreadable file, board-change handling and deletion. Run via
## tests/run_puzzle_regressions.py in the same bare temp project as the catalog
## and scoreboard checks, with the application-data root redirected.

var failures: int = 0
var _case: int = 0

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

## A PuzzleState.get_results()-shaped dictionary for a given score out of 10.
func _result(score: int, mistakes: int = 0, assists: int = 0) -> Dictionary:
	return {"total_arrows": 10, "mistakes": mistakes, "open_move_assists": assists,
		"score": score, "accuracy": 1.0}

## Points the profile at a scratch file nothing else uses, then simulates a start.
func _fresh() -> String:
	_case += 1
	var file_path := "user://player_profile_check_%d.json" % _case
	_remove_with_recoveries(file_path)
	PlayerProfile.use_path(file_path)
	return file_path

func _remove_with_recoveries(file_path: String) -> void:
	for candidate in [file_path, file_path + ".recovery", file_path + ".recovery.1", file_path + ".recovery.2"]:
		if DirAccess.dir_exists_absolute(candidate):
			DirAccess.remove_absolute(candidate)
		elif FileAccess.file_exists(candidate):
			DirAccess.remove_absolute(candidate)

## The same two calls arrow_puzzle.gd makes when an attempt is finished.
func _complete(id: String, results: Dictionary) -> String:
	var comparison := PuzzleScoreboard.record_attempt(id, results)
	PlayerProfile.record_completion(id, results, comparison,
		PuzzleContentVersion.of(PuzzleCatalog.get_definition(id)))
	return comparison

func _write(file_path: String, text: String) -> void:
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(text)
	file.close()

func _level_ids() -> Array[String]:
	return PuzzleCatalog.ids_in_group(PuzzleCatalog.GROUP_ARROWSPARK_LEVELS)

func _test_fresh_profile() -> void:
	var file_path := _fresh()
	check(PlayerProfile.display_name() == PlayerProfile.DEFAULT_NAME, "a new profile has the default name")
	check(not PlayerProfile.has_progress() and PlayerProfile.resume_id().is_empty(), "a new profile has nothing to continue")
	check(PlayerProfile.finished_count() == 0, "a new profile has no finished levels")
	check(PlayerProfile.stats() == {"attempts": 0, "mistakes": 0, "open_move_assists": 0}, "a new profile has zero statistics")
	check(PlayerProfile.load_notice().is_empty(), "a new profile shows no recovery notice")
	check(not FileAccess.file_exists(file_path), "merely loading a new profile writes no file")

func _test_persists_across_restart() -> void:
	var file_path := _fresh()
	var ids := _level_ids()
	check(_complete(ids[0], _result(7, 3, 1)) == "established", "the first finish establishes a best")
	check(FileAccess.file_exists(file_path), "finishing a level writes the profile file")
	PlayerProfile.restart()
	var best: Variant = PlayerProfile.best_result(ids[0])
	check(best != null and best["score"] == 7 and best["total_arrows"] == 10
		and best["mistakes"] == 3 and best["open_move_assists"] == 1,
		"the best result survives a restart with every field")
	check(PlayerProfile.is_finished(ids[0]) and PlayerProfile.finished_count() == 1, "the finished level is still finished after a restart")
	check(PlayerProfile.stats() == {"attempts": 1, "mistakes": 3, "open_move_assists": 1}, "statistics survive a restart")
	check(PlayerProfile.resume_id() == ids[1], "Continue points at the level after the one just finished")
	check(PuzzleScoreboard.get_best(ids[0])["score"] == 7, "the scoreboard is seeded with the saved best after a restart")
	check(PuzzleScoreboard.get_overall_score() == 7, "the overall score after a restart is the sum of saved bests")
	check(_complete(ids[0], _result(5)) == "not_improved", "a worse replay after a restart is compared with the saved best")

func _test_best_only_improves() -> void:
	_fresh()
	var id := _level_ids()[0]
	_complete(id, _result(6))
	_complete(id, _result(4, 6))
	check(PlayerProfile.best_result(id)["score"] == 6, "a worse replay never lowers the saved best")
	_complete(id, _result(6))
	check(PlayerProfile.best_result(id)["score"] == 6, "a tied replay keeps the saved best")
	_complete(id, _result(9))
	PlayerProfile.restart()
	check(PlayerProfile.best_result(id)["score"] == 9, "a better replay raises the saved best")
	check(PlayerProfile.stats()["attempts"] == 4, "statistics count every finished attempt, including worse ones")
	check(PuzzleScoreboard.get_overall_score() == 9, "the overall score counts each level's best once")

func _test_resume_position() -> void:
	_fresh()
	var ids := _level_ids()
	_complete(ids[2], _result(5))
	check(PlayerProfile.resume_id() == ids[3], "resume follows the most recently finished level, not the furthest")
	_complete(ids[ids.size() - 1], _result(5))
	check(PlayerProfile.resume_id() == ids[ids.size() - 1], "at a group's end Continue stays on the last level")
	PlayerProfile.restart()
	check(PlayerProfile.resume_id() == ids[ids.size() - 1], "the resume position survives a restart")

func _test_name() -> void:
	_fresh()
	check(PlayerProfile.set_display_name("  Ada \t Lovelace \n") == "Ada Lovelace", "names are trimmed and whitespace collapsed")
	PlayerProfile.restart()
	check(PlayerProfile.display_name() == "Ada Lovelace", "the name survives a restart")
	check(PlayerProfile.set_display_name("   ") == PlayerProfile.DEFAULT_NAME, "an empty name falls back to the default")
	var long_name := PlayerProfile.set_display_name("x".repeat(80))
	check(long_name.length() == PlayerProfile.MAX_NAME_LENGTH, "a long name is shortened to the maximum length")

func _test_unreadable_profile_is_kept_and_replaced() -> void:
	var file_path := _fresh()
	_write(file_path, "CORRUPT_PROFILE_SENTINEL")
	PlayerProfile.restart()
	check(not PlayerProfile.has_progress() and PlayerProfile.finished_count() == 0, "an unreadable profile starts empty")
	check(not PlayerProfile.load_notice().is_empty(), "an unreadable profile produces a notice")
	check(FileAccess.get_file_as_string(file_path + ".recovery") == "CORRUPT_PROFILE_SENTINEL", "the unreadable file's exact bytes are kept")
	check(not PlayerProfile.save_blocked, "writes stay enabled when the copy was made")
	var id := _level_ids()[0]
	_complete(id, _result(8))
	PlayerProfile.restart()
	check(PlayerProfile.best_result(id) != null, "the game saves a new profile after recovery")
	_write(file_path, "{ not json")
	PlayerProfile.restart()
	check(FileAccess.get_file_as_string(file_path + ".recovery.1") == "{ not json", "a second unreadable file gets its own numbered copy")
	check(FileAccess.get_file_as_string(file_path + ".recovery") == "CORRUPT_PROFILE_SENTINEL", "the earlier copy is not overwritten")

func _test_unreadable_without_backup_is_never_overwritten() -> void:
	var file_path := _fresh()
	_write(file_path, "BACKUP_FAILURE_SENTINEL")
	DirAccess.make_dir_absolute(file_path + ".recovery")
	PlayerProfile.restart()
	check(PlayerProfile.save_blocked, "failing to keep a copy blocks profile writes")
	check(not PlayerProfile.load_notice().is_empty(), "the player is told progress will not be saved")
	var id := _level_ids()[0]
	var comparison := PuzzleScoreboard.record_attempt(id, _result(6))
	var error := PlayerProfile.record_completion(id, _result(6), comparison,
		PuzzleContentVersion.of(PuzzleCatalog.get_definition(id)))
	check(error == ERR_UNAVAILABLE, "recording is refused while writes are blocked")
	check(FileAccess.get_file_as_string(file_path) == "BACKUP_FAILURE_SENTINEL", "the unreadable original is left untouched")
	check(PlayerProfile.is_finished(id), "the visit still tracks progress in memory")
	DirAccess.remove_absolute(file_path + ".recovery")

func _test_newer_format_is_not_overwritten_unseen() -> void:
	var file_path := _fresh()
	var newer := '{"format": 99, "name": "From Later", "levels": {}}'
	_write(file_path, newer)
	PlayerProfile.restart()
	check(PlayerProfile.display_name() == PlayerProfile.DEFAULT_NAME, "a profile from a newer format is not read as this one")
	check(FileAccess.get_file_as_string(file_path + ".recovery") == newer, "a profile from a newer format is kept in a recovery copy")

func _test_changed_board_is_ignored_but_kept() -> void:
	var file_path := _fresh()
	var ids := _level_ids()
	var stale := {"format": 1, "name": "Player", "resume_id": ids[1], "stats": {"attempts": 2, "mistakes": 0, "open_move_assists": 0},
		"levels": {ids[0]: {"content_version": "g1-000000000000", "score": 9, "total_arrows": 10, "mistakes": 0,
			"open_move_assists": 0, "accuracy": 1.0}}}
	_write(file_path, JSON.stringify(stale))
	PlayerProfile.restart()
	check(PlayerProfile.best_result(ids[0]) == null and not PlayerProfile.is_finished(ids[0]),
		"a best result for a board that has since changed does not count")
	check(PuzzleScoreboard.get_best(ids[0]) == null and PuzzleScoreboard.get_overall_score() == 0,
		"a best result for a changed board is not seeded into the scoreboard")
	check(_complete(ids[0], _result(4)) == "established", "finishing the changed board establishes a fresh best")
	check(PlayerProfile.best_result(ids[0])["score"] == 4, "the new result replaces the stale one")
	_complete(ids[3], _result(5))
	var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(file_path))
	check(saved["levels"].has(ids[3]) and saved["levels"].has(ids[0]), "saving keeps every level's entry")

func _test_malformed_entries_are_skipped() -> void:
	var file_path := _fresh()
	var ids := _level_ids()
	var good_version := PuzzleContentVersion.of(PuzzleCatalog.get_definition(ids[0]))
	var data := {"format": 1, "levels": {
		ids[0]: {"content_version": good_version, "score": 3, "total_arrows": 10, "mistakes": 1, "open_move_assists": 0, "accuracy": 0.5},
		ids[1]: {"content_version": "x", "score": 99, "total_arrows": 10, "mistakes": 0, "open_move_assists": 0, "accuracy": 1.0},
		ids[2]: "not a dictionary",
		ids[3]: {"score": 1},
	}}
	_write(file_path, JSON.stringify(data))
	PlayerProfile.restart()
	check(PlayerProfile.finished_count() == 1 and PlayerProfile.is_finished(ids[0]), "only well-formed level entries are used")
	check(PlayerProfile.load_notice().is_empty(), "skipping a bad entry does not discard the rest of the profile")

func _test_reset_deletes_everything() -> void:
	var file_path := _fresh()
	var id := _level_ids()[0]
	_complete(id, _result(8))
	PlayerProfile.set_display_name("Grace")
	check(PlayerProfile.reset() == OK, "deleting the profile succeeds")
	check(not FileAccess.file_exists(file_path), "deleting the profile removes the file")
	check(not PlayerProfile.has_progress() and PlayerProfile.finished_count() == 0, "a deleted profile has no progress")
	check(PlayerProfile.display_name() == PlayerProfile.DEFAULT_NAME, "a deleted profile has the default name")
	check(PuzzleScoreboard.get_overall_score() == 0 and PuzzleScoreboard.get_best(id) == null, "deleting the profile empties the scoreboard")
	PlayerProfile.restart()
	check(not PlayerProfile.has_progress(), "a deleted profile stays deleted after a restart")
	check(PlayerProfile.reset() == OK, "deleting an absent profile also succeeds")

## The settings file and the template's legacy save are separate files this class
## must never read or write, even while recovering from an unreadable profile.
func _test_other_files_are_untouched() -> void:
	var file_path := _fresh()
	var settings := "user://config.cfg"
	var legacy := "user://global_state.tres"
	_write(settings, "SETTINGS_SENTINEL")
	_write(legacy, "LEGACY_SAVE_SENTINEL")
	var id := _level_ids()[0]
	_complete(id, _result(8))
	PlayerProfile.set_display_name("Edsger")
	_write(file_path, "garbage")
	PlayerProfile.restart()
	PlayerProfile.reset()
	check(FileAccess.get_file_as_string(settings) == "SETTINGS_SENTINEL", "the settings file is never changed by the profile")
	check(FileAccess.get_file_as_string(legacy) == "LEGACY_SAVE_SENTINEL", "the legacy save is never changed by the profile")
	DirAccess.remove_absolute(settings)
	DirAccess.remove_absolute(legacy)

func _initialize() -> void:
	_test_fresh_profile()
	_test_persists_across_restart()
	_test_best_only_improves()
	_test_resume_position()
	_test_name()
	_test_unreadable_profile_is_kept_and_replaced()
	_test_unreadable_without_backup_is_never_overwritten()
	_test_newer_format_is_not_overwritten_unseen()
	_test_changed_board_is_ignored_but_kept()
	_test_malformed_entries_are_skipped()
	_test_reset_deletes_everything()
	_test_other_files_are_untouched()
	print("PLAYER_PROFILE_FAILURES=", failures)
	quit(1 if failures else 0)
