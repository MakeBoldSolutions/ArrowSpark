class_name Config
extends Object

## Interface for a single configuration file through [ConfigFile].

const CONFIG_FILE_LOCATION := "user://config.cfg"

static var config_file : ConfigFile
static var save_blocked : bool = false

static func _init():
	load_config_file()

static func _save_config_file() -> Error:
	if save_blocked:
		return ERR_UNAVAILABLE
	var save_error : int = config_file.save(CONFIG_FILE_LOCATION)
	if save_error:
		push_error("save config file failed with error %d" % save_error)
	return save_error

static func load_config_file() -> void:
	if config_file != null:
		return
	config_file = ConfigFile.new()
	save_blocked = false
	if not FileAccess.file_exists(CONFIG_FILE_LOCATION):
		return
	var load_error : int = config_file.load(CONFIG_FILE_LOCATION)
	if load_error:
		# Discard partially parsed values, but never overwrite their source.
		config_file = ConfigFile.new()
		save_blocked = true
		push_error("Settings could not be loaded. Original preserved; settings writes disabled.")

static func reset_unreadable_config() -> Error:
	load_config_file()
	if not save_blocked:
		return ERR_UNCONFIGURED
	var backup_path = CONFIG_FILE_LOCATION + ".recovery"
	var suffix = 1
	while FileAccess.file_exists(backup_path):
		backup_path = CONFIG_FILE_LOCATION + ".recovery.%d" % suffix
		suffix += 1
	var result = DirAccess.copy_absolute(CONFIG_FILE_LOCATION, backup_path)
	if result != OK:
		push_error("Settings backup failed; reset canceled: %s" % error_string(result))
		return result
	# Save an empty configuration without discarding session values on failure.
	var defaults = ConfigFile.new()
	result = defaults.save(CONFIG_FILE_LOCATION)
	if result != OK:
		push_error("Settings reset failed: %s" % error_string(result))
		return result
	config_file = defaults
	save_blocked = false
	return OK

static func set_config(section: String, key: String, value) -> void:
	load_config_file()
	config_file.set_value(section, key, value)
	_save_config_file()

static func get_config(section: String, key: String, default = null) -> Variant:
	load_config_file()
	return config_file.get_value(section, key, default)

static func has_section(section: String):
	load_config_file()
	return config_file.has_section(section)

static func has_section_key(section: String, key: String):
	load_config_file()
	return config_file.has_section_key(section, key)

static func erase_section(section: String):
	if has_section(section):
		config_file.erase_section(section)
		_save_config_file()

static func erase_section_key(section: String, key: String):
	if has_section_key(section, key):
		config_file.erase_section_key(section, key)
		_save_config_file()

static func get_section_keys(section: String):
	load_config_file()
	if config_file.has_section(section):
		return config_file.get_section_keys(section)
	return PackedStringArray()
