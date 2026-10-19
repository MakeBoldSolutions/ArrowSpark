extends PauseMenu
## Project pause menu: the same pause/focus lifecycle with narrow-safe scrolling.
var _help: Label

func _ready() -> void:
	super._ready()
	var margin := $MenuPanelContainer/MarginContainer
	var panel := %MenuPanelContainer
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	panel.add_child(scroll)
	margin.reparent(scroll)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 12)
	%MenuButtons.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var levels := Button.new()
	levels.text = "Level Select"
	levels.pressed.connect(_open_levels)
	%MenuButtons.add_child(levels)
	var scene := get_tree().current_scene
	if scene != null and scene.has_method("control_help"):
		var pan := CheckButton.new()
		pan.text = "Mouse Pan mode"
		var board: PuzzleBoard = scene.get_node("%PuzzleBoard")
		pan.button_pressed = board.is_pan_mode()
		pan.toggled.connect(board.set_pan_mode)
		%MenuButtons.add_child(pan)
		_help = Label.new()
		_help.text = scene.control_help()
		_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_help.theme_type_variation = &"SupportingText"
		%MenuButtons.add_child(_help)
	panel.minimum_size_changed.connect(_layout_panel)
	resized.connect(_layout_panel)
	_layout_panel.call_deferred()
	%MenuButtons.get_child(0).grab_focus()

func _layout_panel() -> void:
	if not is_node_ready():
		return
	var extent := Vector2(minf(560, size.x - 24), minf(640, size.y - 24))
	%MenuPanelContainer.set_anchors_preset(Control.PRESET_TOP_LEFT)
	%MenuPanelContainer.size = extent
	%MenuPanelContainer.position = (size - extent) / 2.0

func _open_levels() -> void:
	PuzzleSession.request_level_select()
	_load_scene(main_menu_scene)
