extends SceneTree
func _initialize():
	for c in [Button.new(), HBoxContainer.new()]:
		for prop in c.get_property_list():
			if prop.name in ["autowrap_mode", "vertical"]:
				print(c.get_class(), ":", prop.name)
	quit()
