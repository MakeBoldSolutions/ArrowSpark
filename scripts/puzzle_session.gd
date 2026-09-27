class_name PuzzleSession
extends RefCounted
## Process-lifetime, in-memory-only holder naming which catalog puzzle is
## currently selected. A GDScript static var is bound to the running
## process, not to any node or scene, so it survives
## SceneLoader.reload_current_scene()/load_scene() identically to an
## autoload while needing no project.godot registration or _ready()
## lifecycle — the same precedent GameVisualStyle's static _theme cache
## already establishes in this codebase. Never reads or writes GlobalState,
## GameState, LevelState, or user://global_state.tres. Reset only by a
## fresh engine process.

static var _current_id: String = ""

## Defaults to the first catalog entry whenever unset or no longer a valid
## catalog id, so the very first read (before any New Game/Level Select
## action) is always safe.
static func get_current_id() -> String:
	if PuzzleCatalog.index_of(_current_id) == -1:
		_current_id = PuzzleCatalog.id_at(0)
	return _current_id

## Caller (New Game, Level Select selection) is responsible for passing a
## valid catalog id.
static func set_current_id(id: String) -> void:
	_current_id = id

## Advances to the next catalog entry in order; no-op (returns false) at the
## last entry.
static func advance_to_next() -> bool:
	var index := PuzzleCatalog.index_of(get_current_id())
	if index + 1 >= PuzzleCatalog.count():
		return false
	_current_id = PuzzleCatalog.id_at(index + 1)
	return true

static func has_next() -> bool:
	return PuzzleCatalog.index_of(get_current_id()) + 1 < PuzzleCatalog.count()
