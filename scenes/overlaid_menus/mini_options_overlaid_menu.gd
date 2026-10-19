extends OverlaidMenuContainer
## Keeps the inherited options instance and values, within a scrollable overlay.
func _ready() -> void:
	var panel := %MenuPanelContainer
	var margin := panel.get_node("MarginContainer")
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	panel.add_child(scroll)
	margin.reparent(scroll)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 12)
	panel.minimum_size_changed.connect(_layout_panel)
	resized.connect(_layout_panel)
	_layout_panel.call_deferred()

func _layout_panel() -> void:
	if not is_node_ready():
		return
	var extent := Vector2(minf(560, size.x - 24), minf(640, size.y - 24))
	%MenuPanelContainer.set_anchors_preset(Control.PRESET_TOP_LEFT)
	%MenuPanelContainer.size = extent
	%MenuPanelContainer.position = (size - extent) / 2.0
