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
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_window().size_changed.connect(_queue_layout)
	_update_layout()
	ThemeDB.get_default_theme().merge_with(_STYLE.get_theme())
	var loader := get_node_or_null(^"/root/SceneLoader")
	if loader != null and ResourceLoader.exists(LOADING_SCREEN):
		loader.set(&"loading_screen_path", LOADING_SCREEN)

var _layout_queued := false

func _queue_layout() -> void:
	if not _layout_queued:
		_layout_queued = true
		_update_layout.call_deferred()

func _update_layout() -> void:
	_layout_queued = false
	var css_size := get_window().size
	var touch := false
	if OS.has_feature("web"):
		var browser = JavaScriptBridge.get_interface("window")
		if browser == null:
			return
		css_size = Vector2i(int(browser.innerWidth), int(browser.innerHeight))
		touch = bool(browser.matchMedia("(any-pointer: coarse)").matches)
	var base := ResponsiveLayout.base_size(css_size, touch)
	if base == Vector2i.ZERO:
		return
	if get_window().content_scale_size != base:
		get_window().content_scale_size = base
