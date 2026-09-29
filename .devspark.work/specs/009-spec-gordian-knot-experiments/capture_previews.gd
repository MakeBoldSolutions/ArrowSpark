extends SceneTree

func _initialize() -> void:
	var folder := "res://.devspark.work/specs/009-spec-gordian-knot-experiments/previews"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	DisplayServer.window_set_size(Vector2i(1280, 720))
	get_root().size = Vector2i(1280, 720)
	for id in ["knot_long_geometry", "knot_interwoven_paths", "knot_dense_core", "knot_regions", "knot_single_release", "knot_boundary"]:
		PuzzleSession.set_current_id(id)
		var puzzle: Control = load("res://scenes/puzzle/arrow_puzzle.tscn").instantiate()
		get_root().add_child(puzzle)
		for i in range(4):
			await process_frame
		var image := get_root().get_texture().get_image()
		var result := image.save_png(ProjectSettings.globalize_path(folder + "/" + id + ".png"))
		print("CAPTURE ", id, " ", result, " ", image.get_width(), "x", image.get_height())
		puzzle.queue_free()
		await process_frame
	quit()
