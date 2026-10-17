extends SceneTree
## Throwaway probe: how a stretched root window reports its scale in Godot 4.4.1.
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	root.size = Vector2i(2560, 1440)
	await process_frame
	await process_frame
	print("PROBE size=", root.size, " visible=", root.get_visible_rect().size)
	print("PROBE content_scale_size=", root.content_scale_size, " mode=", root.content_scale_mode, " aspect=", root.content_scale_aspect)
	print("PROBE final=", root.get_final_transform().get_scale(), " screen=", root.get_screen_transform().get_scale())
	print("PROBE canvas=", root.canvas_transform.get_scale(), " global_canvas=", root.global_canvas_transform.get_scale())
	var c := Control.new()
	root.add_child(c)
	await process_frame
	print("PROBE control_screen=", c.get_screen_transform().get_scale(), " viewport_final=", c.get_viewport().get_final_transform().get_scale())
	quit()
