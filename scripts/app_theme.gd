extends Node
## Installs the one ArrowSpark theme before any scene runs. The theme is merged
## into the engine default theme rather than set on the root window, because
## controls under a CanvasLayer (pause overlay, loading screen) do not inherit a
## root-window theme. Also points the template scene loader at the branded
## loading screen. Uses a node path, not the autoload name, so fresh-copy editor
## imports parse this script before autoloads are registered.

const _STYLE := preload("res://scripts/presentation/game_visual_style.gd")
const LOADING_SCREEN := "res://scenes/loading_screen/loading_screen.tscn"

func _ready() -> void:
	ThemeDB.get_default_theme().merge_with(_STYLE.get_theme())
	var loader := get_node_or_null(^"/root/SceneLoader")
	if loader != null and ResourceLoader.exists(LOADING_SCREEN):
		loader.set(&"loading_screen_path", LOADING_SCREEN)
