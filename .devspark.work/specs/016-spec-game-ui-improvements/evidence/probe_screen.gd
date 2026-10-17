extends SceneTree
func _initialize() -> void:
	print("PROBE screen=", DisplayServer.screen_get_size(), " scale=", DisplayServer.screen_get_scale(), " usable=", DisplayServer.screen_get_usable_rect())
	DisplayServer.window_set_size(Vector2i(3840, 2160))
	await process_frame
	await process_frame
	print("PROBE window_after_4k=", DisplayServer.window_get_size(), " root=", root.size)
	quit()
