extends MainMenu

@export var level_select_packed_scene: PackedScene

var level_select_scene
var animation_state_machine : AnimationNodeStateMachinePlayback

func intro_done():
	animation_state_machine.travel("OpenMainMenu")

func _is_in_intro():
	return animation_state_machine.get_current_node() == "Intro"

func _event_is_mouse_button_released(event : InputEvent):
	return event is InputEventMouseButton and not event.is_pressed()

func _event_skips_intro(event : InputEvent):
	return event.is_action_released("ui_accept") or \
		event.is_action_released("ui_select") or \
		event.is_action_released("ui_cancel") or \
		_event_is_mouse_button_released(event)

func _open_sub_menu(menu):
	super._open_sub_menu(menu)
	animation_state_machine.travel("OpenSubMenu")
	_layout_compact.call_deferred()

func _close_sub_menu():
	super._close_sub_menu()
	animation_state_machine.travel("OpenMainMenu")
	_layout_compact.call_deferred()

func _setup_level_select():
	if level_select_packed_scene != null:
		level_select_scene = level_select_packed_scene.instantiate()
		level_select_scene.hide()
		%LevelSelectContainer.call_deferred("add_child", level_select_scene)
		if level_select_scene.has_signal("puzzle_selected"):
			level_select_scene.connect("puzzle_selected", _on_puzzle_selected)

func _input(event):
	if _is_in_intro() and _event_skips_intro(event):
		intro_done()
		return
	super._input(event)

func _ready():
	super._ready()
	var actions: Control = %MenuButtonsBoxContainer
	var scroll := ScrollContainer.new()
	scroll.name = "ActionsScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	actions.get_parent().add_child(scroll)
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	actions.reparent(scroll)
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.size_flags_vertical = Control.SIZE_EXPAND_FILL
	resized.connect(_layout_compact)
	_layout_compact.call_deferred()
	_setup_level_select()
	animation_state_machine = $MenuAnimationTree.get("parameters/playback")
	if PuzzleSession.consume_level_select_request():
		call_deferred("_open_requested_level_select")

## Opens Level Select on load after the results panel's Level Select button.
## Deferred so the Level Select child (added deferred in _setup_level_select)
## is in the tree and the animation state machine is assigned; the intro is
## finished first so the AnimationTree is out of Intro.
func _open_requested_level_select() -> void:
	if level_select_scene == null:
		return
	intro_done()
	_open_sub_menu(level_select_scene)

## Continue stays hidden: this puzzle is session-only and implies no saved
## level progression to continue from. Its scene/script remains in source,
## unreachable from this menu, so it can be restored later.
func _on_continue_game_button_pressed():
	load_game_scene()

func _on_level_select_button_pressed():
	_open_sub_menu(level_select_scene)

## New Game (Play) always starts the first ArrowSpark level, regardless of any
## prior Level Select choice earlier in the same session. The base implementation's
## existing no-GlobalState.reset()/no-GameState.start_game() guarantee is
## otherwise untouched — this only sets which puzzle load_game_scene() opens.
func new_game():
	PuzzleSession.set_current_id("first_knot")
	super.new_game()

func _on_puzzle_selected(id: String):
	PuzzleSession.set_current_id(id)
	load_game_scene()

func _layout_compact() -> void:
	if not is_node_ready():
		return
	var narrow := ResponsiveLayout.compact(size)
	var header_height := 172.0 if narrow else 0.0
	$Hero.visible = not narrow or sub_menu == null
	$Hero.anchor_right = 1.0 if narrow else 0.4
	$Hero.anchor_bottom = 0.0 if narrow else 1.0
	$Hero.offset_bottom = header_height
	var hero := $Hero/HeroContent
	hero.anchor_top = 0.0 if narrow else 0.5
	hero.anchor_bottom = 1.0 if narrow else 0.5
	hero.offset_left = 12.0 if narrow else 64.0
	hero.offset_right = -12.0 if narrow else -48.0
	hero.offset_top = 8.0 if narrow else -150.0
	hero.offset_bottom = -8.0 if narrow else 150.0
	hero.add_theme_constant_override("separation", 4 if narrow else 16)
	$Hero/HeroContent/MarkTile.custom_minimum_size = Vector2(48, 48) if narrow else Vector2(112, 112)
	$Hero/HeroContent/TitleRow/HeroTitle.theme_type_variation = &"CompactHero" if narrow else &"HeroTitle"
	$Hero/HeroContent/TitleRow/HeroAccent.theme_type_variation = &"CompactHeroAccent" if narrow else &"HeroAccent"
	for area in [%MenuContainer, %OptionsContainer, %CreditsContainer, %LevelSelectContainer, $FlowControlContainer]:
		area.anchor_left = 0.0 if narrow else 0.4
	%MenuContainer.offset_top = header_height if narrow else 0.0
	for area in [%OptionsContainer, %LevelSelectContainer]:
		for edge in ["left", "right", "top"]:
			area.add_theme_constant_override("margin_" + edge, 8 if narrow else 24)
	%MenuButtonsBoxContainer.add_theme_constant_override("separation", 8 if narrow else 16)
