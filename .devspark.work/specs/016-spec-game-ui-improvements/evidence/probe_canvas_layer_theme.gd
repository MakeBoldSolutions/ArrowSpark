extends SceneTree
## Throwaway probe: do Controls under a CanvasLayer, and popup Windows, inherit a theme set on the root Window?

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var theme := Theme.new()
	theme.set_color("font_color", "Label", Color.RED)
	theme.set_color("font_color", "PopupMenu", Color.RED)
	ThemeDB.get_default_theme().merge_with(theme)
	var late_layer := CanvasLayer.new()
	var plain := Label.new()
	root.add_child(plain)
	var layer := CanvasLayer.new()
	root.add_child(layer)
	var layered_parent := Control.new()
	layer.add_child(layered_parent)
	var layered := Label.new()
	layered_parent.add_child(layered)
	var option := OptionButton.new()
	root.add_child(option)
	var popup: PopupMenu = option.get_popup()
	var late_label := Label.new()
	root.add_child(late_layer)
	late_layer.add_child(late_label)
	await process_frame
	print("PROBE late_canvas_layer_label_inherits=", late_label.get_theme_color("font_color") == Color.RED)
	print("PROBE button_default_untouched=", Button.new().get_theme_color("font_color") != Color.RED)
	print("PROBE plain_label_inherits=", plain.get_theme_color("font_color") == Color.RED)
	print("PROBE canvas_layer_label_inherits=", layered.get_theme_color("font_color") == Color.RED)
	print("PROBE popup_menu_inherits=", popup.get_theme_color("font_color") == Color.RED)
	quit()
