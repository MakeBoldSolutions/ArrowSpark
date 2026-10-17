extends SceneTree
## Throwaway rendered check: Level Select opened via the Results request path, scrolled to
## the longest Puzzle Lab titles, and the Main Menu in French for clipping.
## Usage (isolated APPDATA): <godot> --path . --script <this file> -- <width> <height> <out_dir>

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var window_size := Vector2i(int(args[0]), int(args[1]))
	var out_dir: String = args[2]
	for attempt in range(5):
		DisplayServer.window_set_size(window_size)
		await create_timer(0.2).timeout
		if DisplayServer.window_get_size() == window_size:
			break
	PuzzleSession.request_level_select()
	change_scene_to_file("res://scenes/menus/main_menu/main_menu_with_animations.tscn")
	await create_timer(1.0).timeout
	var menu := current_scene
	var level_select = menu.get("level_select_scene")
	print("CHECK opened_from_results=", level_select != null and level_select.visible)
	_save(out_dir, "ls_from_results", window_size)
	var buttons: Array = level_select.entry_buttons()
	var clipped: Array[String] = []
	for button in buttons:
		var font: Font = button.get_theme_font("font")
		var size: int = button.get_theme_font_size("font_size")
		var needed := font.get_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		var normal: StyleBox = button.get_theme_stylebox("normal")
		var available: float = button.size.x - normal.get_margin(SIDE_LEFT) - normal.get_margin(SIDE_RIGHT)
		if needed > available:
			clipped.append(button.text)
	print("CHECK clipped_titles=", clipped)
	buttons[-1].grab_focus()
	await create_timer(0.6).timeout
	_save(out_dir, "ls_puzzle_lab_end", window_size)
	TranslationServer.set_locale("fr")
	change_scene_to_file("res://scenes/menus/main_menu/main_menu_with_animations.tscn")
	await create_timer(3.0).timeout
	_save(out_dir, "main_menu_fr", window_size)
	quit()

func _save(out_dir: String, name: String, window_size: Vector2i) -> void:
	var path := "%s/%s_%dx%d.png" % [out_dir, name, window_size.x, window_size.y]
	root.get_texture().get_image().save_png(path)
	print("SAVED ", name)
