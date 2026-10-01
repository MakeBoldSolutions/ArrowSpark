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

func _close_sub_menu():
	super._close_sub_menu()
	animation_state_machine.travel("OpenMainMenu")

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

## New Game (Play) always starts the Reference Knot, regardless of any prior
## Level Select choice earlier in the same session. The base implementation's
## existing no-GlobalState.reset()/no-GameState.start_game() guarantee is
## otherwise untouched — this only sets which puzzle load_game_scene() opens.
func new_game():
	PuzzleSession.set_current_id("reference_knot")
	super.new_game()

func _on_puzzle_selected(id: String):
	PuzzleSession.set_current_id(id)
	load_game_scene()
