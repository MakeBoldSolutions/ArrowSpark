@tool
extends InputOptionsMenu

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint():
		return
	resized.connect(_reflow_bindings)
	_reflow_bindings.call_deferred()
	for child in get_children():
		if child is Window:
			child.visibility_changed.connect(_fit_dialog.bind(child))

func _fit_dialog(dialog: Window) -> void:
	if dialog.visible:
		dialog.wrap_controls = false
		dialog.min_size = Vector2i.ZERO
		dialog.size.x = mini(dialog.size.x, int(get_viewport_rect().size.x) - 24)
		dialog.move_to_center()

func _reflow_bindings() -> void:
	if not is_node_ready() or Engine.is_editor_hint():
		return
	var narrow := ResponsiveLayout.compact(get_viewport_rect().size)
	var list := %InputActionsList
	list.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	for row in list.get_node("%ParentBoxContainer").get_children():
		if row == list.get_node("%ActionBoxContainer") or not row is BoxContainer:
			continue
		row.vertical = narrow
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var bindings := 0
		for child in row.get_children():
			if child is Button:
				bindings += 1
				child.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				child.tooltip_text = "%s: binding %d" % [row.get_child(0).text, bindings]
		row.visible = bindings > 0 or not narrow
