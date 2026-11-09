class_name PlayerProfile
extends RefCounted
## The player's profile on this device: a display name, the levels they have
## finished with the best result on each, and simple play statistics. It needs no
## account and sends nothing anywhere. Static state bound to the running process
## (the same precedent as PuzzleSession and PuzzleScoreboard), loaded lazily from
## user://player_profile.json, which is the browser's own storage in the Web build.
##
## This file is separate from user://config.cfg (settings) and
## user://global_state.tres (the legacy save the template defines), so a damaged
## profile can never block settings or old saves, and neither of those is read or
## written here. Best results are keyed by the stable catalog puzzle id and carry
## the puzzle's content version (PuzzleContentVersion): a best result whose board
## has since changed is kept in the file but ignored, because its score no longer
## describes the board the player sees. Scoring itself stays with PuzzleState and
## PuzzleScoreboard; this class only remembers what they decided.

const FORMAT_VERSION := 1
const PROFILE_PATH := "user://player_profile.json"
const DEFAULT_NAME := "Player"
const MAX_NAME_LENGTH := 24

## Where the profile lives. Tests point it at a scratch file with use_path().
## (Do not name a static function reload(): that is Script.reload(), and calling
## it re-initializes every static variable of the class.)
static var _path: String = PROFILE_PATH
## True once the unreadable-profile recovery could not keep a copy of the original
## bytes: the original stays on disk untouched and nothing is written over it.
static var save_blocked: bool = false

static var _loaded: bool = false
static var _name: String = DEFAULT_NAME
static var _resume_id: String = ""
static var _stats: Dictionary = {}
## puzzle_id -> {content_version, score, total_arrows, mistakes, open_move_assists, accuracy}
static var _levels: Dictionary = {}
static var _notice: String = ""
## "id|content_version" -> whether that board still matches the catalog.
static var _current_cache: Dictionary = {}

## Switches to another profile file and starts from it, as a restart would.
static func use_path(new_path: String) -> void:
	_path = new_path
	restart()

## Loads the profile from disk on first use and seeds PuzzleScoreboard with the
## saved best results, so the scoreboard's comparisons and overall score start from
## what the player has already achieved. Safe to call repeatedly.
static func ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_clear_memory()
	if not FileAccess.file_exists(_path):
		return
	var text := FileAccess.get_file_as_string(_path)
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary) or not _adopt(parsed):
		_recover_unreadable()
		return
	_seed_scoreboard()

## Forgets the in-memory profile and reads it again, as a fresh start of the game
## would. Used by tests to simulate a restart.
static func restart() -> void:
	_loaded = false
	PuzzleScoreboard.clear()
	ensure_loaded()

## The notice to show the player when the saved profile could not be read, or "".
static func load_notice() -> String:
	ensure_loaded()
	return _notice

static func display_name() -> String:
	ensure_loaded()
	return _name

## Trims and shortens the name; an empty name falls back to the default. Returns
## the name actually stored.
static func set_display_name(requested: String) -> String:
	ensure_loaded()
	var cleaned := sanitize_name(requested)
	if cleaned != _name:
		_name = cleaned
		_save()
	return _name

static func sanitize_name(requested: String) -> String:
	var kept := ""
	for i in requested.length():
		var code := requested.unicode_at(i)
		kept += " " if code < 32 or code == 127 else requested[i]
	kept = kept.strip_edges()
	while kept.contains("  "):
		kept = kept.replace("  ", " ")
	if kept.length() > MAX_NAME_LENGTH:
		kept = kept.substr(0, MAX_NAME_LENGTH).strip_edges()
	return kept if not kept.is_empty() else DEFAULT_NAME

## Records one finished attempt. comparison is PuzzleScoreboard.record_attempt()'s
## outcome for it, so the saved best is exactly the scoreboard's best. Statistics
## count every finished attempt. Returns OK, or the write error (the profile stays
## correct in memory either way), or ERR_UNAVAILABLE when writes are blocked.
static func record_completion(puzzle_id: String, results: Dictionary, comparison: String,
		content_version: String) -> Error:
	ensure_loaded()
	_stats["attempts"] = int(_stats.get("attempts", 0)) + 1
	_stats["mistakes"] = int(_stats.get("mistakes", 0)) + int(results["mistakes"])
	_stats["open_move_assists"] = int(_stats.get("open_move_assists", 0)) + int(results["open_move_assists"])
	if comparison == "established" or comparison == "improved" or not _levels.has(puzzle_id):
		var best := results.duplicate()
		best["content_version"] = content_version
		_levels[puzzle_id] = best
	var next_id := PuzzleCatalog.next_in_group(puzzle_id)
	_resume_id = next_id if not next_id.is_empty() else puzzle_id
	return _save()

## The level Continue should open: the one after the level most recently finished
## in its group, or that level itself at the group's end. "" when the player has
## finished nothing, or the saved level no longer exists.
static func resume_id() -> String:
	ensure_loaded()
	return _resume_id if PuzzleCatalog.index_of(_resume_id) != -1 else ""

static func has_progress() -> bool:
	return not resume_id().is_empty()

## The saved best result for a level that is still the same board, or null.
static func best_result(puzzle_id: String) -> Variant:
	ensure_loaded()
	var entry: Variant = _levels.get(puzzle_id)
	if entry == null or not _is_current(puzzle_id, entry):
		return null
	return entry

static func is_finished(puzzle_id: String) -> bool:
	return best_result(puzzle_id) != null

static func finished_count() -> int:
	ensure_loaded()
	var count := 0
	for id in _levels:
		if best_result(id) != null:
			count += 1
	return count

## Share of catalog levels finished, 0.0 to 1.0.
static func completion_fraction() -> float:
	var total := PuzzleCatalog.count()
	return float(finished_count()) / float(total) if total > 0 else 0.0

## The best possible overall score: a perfect run (no mistakes, no assists) scores
## one point per arrow, so this is the arrow count summed over every catalog level.
static func possible_score() -> int:
	var total := 0
	for id in PuzzleCatalog.ids():
		var definition := PuzzleCatalog.get_definition(id)
		if definition != null:
			total += definition.arrows.size()
	return total

## The best possible score on just the levels finished so far, which is what the
## player's score on those levels is fairly compared with.
static func possible_score_on_finished() -> int:
	ensure_loaded()
	var total := 0
	for id in _levels:
		var entry: Variant = best_result(id)
		if entry != null:
			total += int(entry["total_arrows"])
	return total

## Score actually earned on finished levels (best result on each).
static func earned_score() -> int:
	ensure_loaded()
	var total := 0
	for id in _levels:
		var entry: Variant = best_result(id)
		if entry != null:
			total += int(entry["score"])
	return total

## attempts, mistakes and open_move_assists, summed over every finished attempt.
static func stats() -> Dictionary:
	ensure_loaded()
	return {
		"attempts": int(_stats.get("attempts", 0)),
		"mistakes": int(_stats.get("mistakes", 0)),
		"open_move_assists": int(_stats.get("open_move_assists", 0)),
	}

## Deletes the profile from this device and starts over with an empty one. The
## scoreboard is emptied too, so the overall score drops to zero immediately.
static func reset() -> Error:
	_loaded = true
	_clear_memory()
	PuzzleScoreboard.clear()
	save_blocked = false
	if not FileAccess.file_exists(_path):
		return OK
	var removed := DirAccess.remove_absolute(_path)
	if removed != OK:
		push_error("Player profile could not be deleted: %s" % error_string(removed))
	return removed

static func _clear_memory() -> void:
	_name = DEFAULT_NAME
	_resume_id = ""
	_stats = {"attempts": 0, "mistakes": 0, "open_move_assists": 0}
	_levels = {}
	_notice = ""
	_current_cache = {}
	save_blocked = false

## Validates parsed data and adopts it. Returns false when the file is not a
## profile this version can read. Individual malformed level entries are skipped.
static func _adopt(data: Dictionary) -> bool:
	if not (data.get("format") is float or data.get("format") is int):
		return false
	var format := int(data["format"])
	if format < 1 or format > FORMAT_VERSION:
		return false
	_name = sanitize_name(str(data.get("name", DEFAULT_NAME)))
	_resume_id = str(data.get("resume_id", ""))
	var stats_data: Variant = data.get("stats", {})
	if stats_data is Dictionary:
		for key in ["attempts", "mistakes", "open_move_assists"]:
			_stats[key] = maxi(0, int(stats_data.get(key, 0)))
	var levels_data: Variant = data.get("levels", {})
	if levels_data is Dictionary:
		for id in levels_data:
			var entry: Variant = _clean_entry(levels_data[id])
			if entry != null:
				_levels[str(id)] = entry
	return true

static func _clean_entry(raw: Variant) -> Variant:
	if not (raw is Dictionary):
		return null
	for key in ["score", "total_arrows", "mistakes", "open_move_assists", "accuracy"]:
		if not (raw.get(key) is float or raw.get(key) is int):
			return null
	if not (raw.get("content_version") is String):
		return null
	var total := int(raw["total_arrows"])
	var score := int(raw["score"])
	if total < 0 or score < 0 or score > total:
		return null
	return {
		"content_version": raw["content_version"],
		"score": score,
		"total_arrows": total,
		"mistakes": maxi(0, int(raw["mistakes"])),
		"open_move_assists": maxi(0, int(raw["open_move_assists"])),
		"accuracy": float(raw["accuracy"]),
	}

## A saved best only counts while the catalog still has that puzzle with the same
## board geometry.
static func _is_current(puzzle_id: String, entry: Dictionary) -> bool:
	var key := puzzle_id + "|" + str(entry["content_version"])
	if not _current_cache.has(key):
		var definition := PuzzleCatalog.get_definition(puzzle_id)
		_current_cache[key] = definition != null and PuzzleContentVersion.of(definition) == entry["content_version"]
	return _current_cache[key]

static func _seed_scoreboard() -> void:
	for id in _levels:
		var entry: Dictionary = _levels[id]
		if _is_current(id, entry):
			PuzzleScoreboard.seed_best(id, entry)

## The file could not be read as a profile. Keep its exact bytes in a recovery copy
## next to it and start with an empty profile. If the copy cannot be made, the
## original is left in place and writes are blocked so it is never overwritten.
static func _recover_unreadable() -> void:
	_clear_memory()
	var backup_path := _path + ".recovery"
	var suffix := 1
	while FileAccess.file_exists(backup_path):
		backup_path = _path + ".recovery.%d" % suffix
		suffix += 1
	var copied := DirAccess.copy_absolute(_path, backup_path)
	if copied == OK:
		_notice = "Your saved profile could not be read, so ArrowSpark started a new one. A copy of the old file was kept."
	else:
		save_blocked = true
		push_error("Player profile could not be read or backed up (%s). Original preserved; profile writes disabled." % error_string(copied))
		_notice = "Your saved profile could not be read. It was left untouched, and this visit's progress will not be saved."

static func _save() -> Error:
	if save_blocked:
		return ERR_UNAVAILABLE
	var data := {
		"format": FORMAT_VERSION,
		"name": _name,
		"resume_id": _resume_id,
		"stats": _stats,
		"levels": _levels,
	}
	var file := FileAccess.open(_path, FileAccess.WRITE)
	if file == null:
		var failure := FileAccess.get_open_error()
		push_error("Player profile could not be saved: %s" % error_string(failure))
		return failure
	file.store_string(JSON.stringify(data, "\t", true))
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		push_error("Player profile could not be written: %s" % error_string(write_error))
	return write_error
