extends SceneTree
func _initialize():
	call_deferred("run")
func run():
	for i in 4:
		root.size = Vector2i(390, 784)
		await process_frame
	var puzzle = load("res://scenes/puzzle/arrow_puzzle.tscn").instantiate()
	root.add_child(puzzle)
	current_scene = puzzle
	await process_frame
	puzzle.get_node("%PauseMenuController").open_menu()
	await process_frame
	var menu = puzzle.get_node("%PauseMenuController")._menu
	menu.open_options_menu()
	for i in 5:
		await process_frame
	dump(menu, 0)
	quit()
func dump(node, depth):
	if node is Control:
		print(" ".repeat(depth), node.name, " rect=", node.get_rect(), " min=", node.get_combined_minimum_size())
	for child in node.get_children():
		dump(child, depth+1)
