extends SceneTree
## Throwaway rendered capture: splash, Main Menu, Level Select and Options at one window size.
## Usage: <godot> --path . --script <this file> -- <width> <height> <out_dir>

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var window_size := Vector2i(int(args[0]), int(args[1]))
	var out_dir: String = args[2]
	DisplayServer.window_set_size(window_size)
	await create_timer(0.3).timeout
	change_scene_to_file("res://scenes/opening/opening_with_logo.tscn")
	await create_timer(1.2).timeout
	_save(out_dir, "splash", window_size)
	change_scene_to_file("res://scenes/menus/main_menu/main_menu_with_animations.tscn")
	await create_timer(3.0).timeout
	_save(out_dir, "main_menu", window_size)
	var menu := current_scene
	menu.call("_on_level_select_button_pressed")
	await create_timer(0.6).timeout
	_save(out_dir, "level_select", window_size)
	menu.call("_close_sub_menu")
	menu.call("_on_options_button_pressed")
	await create_timer(0.6).timeout
	_save(out_dir, "options", window_size)
	quit()

func _save(out_dir: String, name: String, window_size: Vector2i) -> void:
	var path := "%s/%s_%dx%d.png" % [out_dir, name, window_size.x, window_size.y]
	root.get_texture().get_image().save_png(path)
	print("SAVED ", path)
