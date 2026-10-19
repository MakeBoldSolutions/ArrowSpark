class_name ResponsiveLayout
extends RefCounted
## CSS-sized touch UI with the established wide desktop scale.

static func base_size(css_size: Vector2i, touch: bool) -> Vector2i:
	if css_size.x <= 0 or css_size.y <= 0:
		return Vector2i.ZERO
	if touch or css_size.x < 960:
		return css_size
	return Vector2i(1280, 720)

static func compact(area: Vector2) -> bool:
	return area.x < 720.0

static func portrait(area: Vector2) -> bool:
	return area.y > area.x and compact(area)

## Adapt only an options content subtree, retaining option instances and values.
static func fit_options(node: Node, narrow: bool) -> void:
	if node is Control:
		var control := node as Control
		if control is Container:
			control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if control.custom_minimum_size.x > 0:
			if not control.has_meta("wide_minimum"):
				control.set_meta("wide_minimum", control.custom_minimum_size.x)
			control.custom_minimum_size.x = minf(float(control.get_meta("wide_minimum")), 120.0) if narrow else float(control.get_meta("wide_minimum"))
		if control is Label:
			control.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if control is MarginContainer:
			for edge in ["left", "right"]:
				var key: String = "margin_" + edge
				if not control.has_meta(key):
					control.set_meta(key, control.get_theme_constant(key))
				control.add_theme_constant_override(key, mini(int(control.get_meta(key)), 8) if narrow else int(control.get_meta(key)))
	for child in node.get_children():
		if not child is Window:
			fit_options(child, narrow)
