extends SceneTree
## Throwaway rendered capture: splash, Main Menu, Level Select and Options at one window size,
## plus SC-001 measurements (title and Play button height as fractions of window height).
## Usage: <godot> --path . --script <this file> -- <width> <height> <out_dir>
## A size equal to the screen is captured exclusive-fullscreen (the OS clamps oversized windows).
## Run with APPDATA pointed at a scratch folder: the template persists window mode to user settings.

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var window_size := Vector2i(int(args[0]), int(args[1]))
	var out_dir: String = args[2]
	for attempt in range(5):
		if window_size == DisplayServer.screen_get_size():
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_size(window_size)
		await create_timer(0.3).timeout
		if DisplayServer.window_get_size() == window_size:
			break
	print("WINDOW ", DisplayServer.window_get_size())
	change_scene_to_file("res://scenes/opening/opening_with_logo.tscn")
	await create_timer(1.0).timeout
	_save(out_dir, "splash", window_size)
	change_scene_to_file("res://scenes/menus/main_menu/main_menu_with_animations.tscn")
	await create_timer(3.0).timeout
	_save(out_dir, "main_menu", window_size)
	_measure(window_size)
	var menu := current_scene
	menu.call("_on_level_select_button_pressed")
	await create_timer(0.6).timeout
	_save(out_dir, "level_select", window_size)
	menu.call("_close_sub_menu")
	menu.call("_on_options_button_pressed")
	await create_timer(0.6).timeout
	_save(out_dir, "options", window_size)
	quit()

func _measure(window_size: Vector2i) -> void:
	var scale := root.get_final_transform().get_scale().y
	var height := float(DisplayServer.window_get_size().y)
	var title: Control = null
	for candidate in ["HeroTitle", "TitleLabel"]:
		var node := current_scene.find_child(candidate, true, false) as Control
		if node != null and node.is_visible_in_tree():
			title = node
			break
	var play := current_scene.find_child("NewGameButton", true, false) as Control
	var title_frac := title.size.y * scale / height if title != null else -1.0
	var play_frac := play.size.y * scale / height if play != null else -1.0
	print("MEASURE %dx%d scale=%.3f title_frac=%.4f play_frac=%.4f play_px=%.1f" % [
		window_size.x, window_size.y, scale, title_frac, play_frac, play.size.y * scale])

func _save(out_dir: String, name: String, window_size: Vector2i) -> void:
	var path := "%s/%s_%dx%d.png" % [out_dir, name, window_size.x, window_size.y]
	root.get_texture().get_image().save_png(path)
	print("SAVED ", path)
