class_name GlobalState
extends Node

const SAVE_STATE_PATH = "user://global_state.tres"
const NO_VERSION_NAME = "0.0.0"

static var current : GlobalStateData
static var current_version : String
static var save_blocked : bool = false

static func _log_opened():
	if current is GlobalStateData:
		current.last_unix_time_opened = int(Time.get_unix_time_from_system())

static func _log_version():
	if current is GlobalStateData:
		current_version = ProjectSettings.get_setting("application/config/version", NO_VERSION_NAME)
		if current_version.is_empty():
			current_version = NO_VERSION_NAME
		if not current.first_version_opened:
			current.first_version_opened = current_version
		current.last_version_opened = current_version

static func _load_or_new(new_state : Resource = null):
	if current is GlobalStateData: return
	save_blocked = false
	if FileAccess.file_exists(SAVE_STATE_PATH):
		var loaded = ResourceLoader.load(SAVE_STATE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
		if loaded is GlobalStateData:
			current = loaded
			return
		save_blocked = true
		push_error("Save could not be loaded. Original preserved; saving disabled until explicit reset.")
	if new_state:
		current = new_state
	else:
		current = GlobalStateData.new()

static func open():
	_load_or_new()
	_log_opened()
	_log_version()
	save()

static func save() -> Error:
	if save_blocked:
		return ERR_UNAVAILABLE
	if current is not GlobalStateData:
		return ERR_UNCONFIGURED
	var result = ResourceSaver.save(current, SAVE_STATE_PATH)
	if result != OK:
		push_error("Failed to save progress: %s" % error_string(result))
	return result

static func has_state(state_key : String) -> bool:
	if current is not GlobalStateData: return false
	return current.has_state(state_key)

static func get_state(state_key : String, state_type_path : String):
	if current is not GlobalStateData: return
	return current.get_state(state_key, state_type_path)

static func reset() -> Error:
	if current is not GlobalStateData: return ERR_UNCONFIGURED
	if save_blocked:
		# Keep the failed save recoverable before allowing any replacement.
		var backup_path = SAVE_STATE_PATH + ".recovery"
		var suffix = 1
		while FileAccess.file_exists(backup_path):
			backup_path = SAVE_STATE_PATH + ".recovery.%d" % suffix
			suffix += 1
		var result = DirAccess.copy_absolute(SAVE_STATE_PATH, backup_path)
		if result != OK:
			push_error("Could not back up unreadable save; reset canceled: %s" % error_string(result))
			return result
		save_blocked = false
	current.states.clear()
	return save()
