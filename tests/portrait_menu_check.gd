extends SceneTree
## Rendered geometry and focus-follow access for every portrait menu family.
var failures := 0
func _initialize() -> void:
	_run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func settle() -> void:
	for i in 8:
		await process_frame
func controls(node: Node) -> void:
	if node is BaseButton and node.is_visible_in_tree():
		var box: Rect2 = node.get_global_rect()
		check(box.position.x >= -1 and box.end.x <= root.get_visible_rect().size.x + 1, "%s fits horizontally: %s" % [node.get_path(), box])
		check(box.size.x >= 44 and box.size.y >= 44, "%s meets target floor" % node.get_path())
		check(node.get_theme_font_size("font_size") >= 16, "%s meets text floor" % node.get_path())
		var ancestor := node.get_parent()
		while ancestor != null:
			if ancestor is ScrollContainer:
				ancestor.ensure_control_visible(node)
			ancestor = ancestor.get_parent()
		await process_frame
		check(root.get_visible_rect().encloses(node.get_global_rect()), "%s reachable by scrolling" % node.get_path())
	for child in node.get_children():
		await controls(child)
func _run() -> void:
	for extent in [Vector2i(320, 580), Vector2i(350, 784), Vector2i(372, 855)]:
		for i in 4:
			root.size = extent
			await process_frame
		var menu = load("res://scenes/menus/main_menu/main_menu_with_animations.tscn").instantiate()
		root.add_child(menu)
		await settle()
		menu.intro_done()
		await create_timer(0.7).timeout
		await controls(menu.get_node("%MenuButtonsBoxContainer"))
		menu.queue_free()
		await settle()
		for path in ["res://scenes/menus/main_menu/puzzle_select_menu.tscn", "res://scenes/menus/options_menu/master_options_menu_with_tabs.tscn"]:
			var scene: Control = load(path).instantiate()
			root.add_child(scene)
			await settle()
			if scene.has_node("TabContainer"):
				var tabs: TabContainer = scene.get_node("TabContainer")
				for index in tabs.get_tab_count():
					tabs.current_tab = index
					await settle()
					await controls(tabs.get_child(index))
			else:
				await controls(scene)
			scene.queue_free()
			await settle()
		print("PORTRAIT_MENU area=", extent)
	print("PORTRAIT_MENU_FAILURES=", failures)
	quit(1 if failures else 0)
