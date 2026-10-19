extends MasterOptionsMenu
## Tabs retain their live settings and are individually scrollable at narrow widths.
func _ready() -> void:
	for tab in $TabContainer.get_children():
		if not tab is Control:
			continue
		var index := tab.get_index()
		var title := tab.name
		var scroll := ScrollContainer.new()
		scroll.name = title + "Scroll"
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.follow_focus = true
		$TabContainer.add_child(scroll)
		$TabContainer.move_child(scroll, index)
		tab.reparent(scroll)
		tab.show()
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll.name = title
	resized.connect(_reflow)
	_reflow.call_deferred()

func _reflow() -> void:
	if is_node_ready():
		ResponsiveLayout.fit_options($TabContainer, ResponsiveLayout.compact(size))
		$TabContainer.set_deferred("size", size)
