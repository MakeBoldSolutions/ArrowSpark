extends Control
## Session controller: owns PuzzleState, the live HUD, and the
## playing -> draining -> results lifecycle. Reuses the starter's pause menu
## and background music; does not touch saved progress or settings.

@export_file("*.tscn") var main_menu_scene_path: String = "res://scenes/menus/main_menu/main_menu_with_animations.tscn"

@onready var _board: PuzzleBoard = %PuzzleBoard
@onready var _remaining_label: Label = %RemainingLabel
@onready var _mistakes_label: Label = %MistakesLabel
@onready var _puzzle_label: Label = %PuzzleLabel
@onready var _open_move_button: Button = %OpenMoveButton
@onready var _zoom_out_button: Button = %ZoomOutButton
@onready var _zoom_in_button: Button = %ZoomInButton
@onready var _fit_button: Button = %FitButton
@onready var _pan_button: Button = %PanButton
@onready var _help_label: Label = %HelpLabel
@onready var _results: Control = %PuzzleResults
@onready var _pause_menu_controller: Node = %PauseMenuController

var _state: PuzzleState
var _pending_departures: int = 0
var _awaiting_completion: bool = false

func _ready() -> void:
	$Background.color = GameVisualStyle.GAME_BACKGROUND
	$Layout.theme = GameVisualStyle.get_theme()
	_remaining_label.theme_type_variation = &"NumericText"
	_mistakes_label.theme_type_variation = &"NumericText"
	_puzzle_label.theme_type_variation = &"SupportingText"
	_open_move_button.theme_type_variation = &"SecondaryButton"
	for button in [_zoom_out_button, _zoom_in_button, _fit_button, _pan_button]:
		button.theme_type_variation = &"SecondaryButton"
	_help_label.theme_type_variation = &"SupportingText"
	_results.replay_requested.connect(_on_results_replay_requested)
	_results.main_menu_requested.connect(_on_results_main_menu_requested)
	_results.next_puzzle_requested.connect(_on_results_next_puzzle_requested)
	_board.cell_clicked.connect(_on_cell_clicked)
	_board.hover_cell_changed.connect(_on_hover_cell_changed)
	_board.departure_finished.connect(_on_departure_finished)
	_open_move_button.pressed.connect(_on_open_move_button_pressed)
	_zoom_out_button.pressed.connect(_board.zoom_out)
	_zoom_in_button.pressed.connect(_board.zoom_in)
	_fit_button.pressed.connect(_board.fit_puzzle)
	_pan_button.toggled.connect(_board.set_pan_mode)
	_board.pan_mode_changed.connect(_on_board_pan_mode_changed)
	_configure_navigation_focus()
	_refresh_navigation_help()
	_start_new_attempt()

func _notification(what: int) -> void:
	# Bindings can be remapped in the pause menu's options; refresh the help
	# text from the live InputMap when play resumes.
	if what == NOTIFICATION_UNPAUSED and is_node_ready():
		_refresh_navigation_help()

## Tab order: Open Move, Zoom Out, Zoom In, Fit, Pan, board, back to Open Move.
## Directional (D-pad) neighbors always leave the toolbar and the board, so the
## canvas controls can never trap focus.
func _configure_navigation_focus() -> void:
	var chain: Array[Control] = [_open_move_button, _zoom_out_button, _zoom_in_button, _fit_button, _pan_button, _board]
	for i in range(chain.size()):
		var control: Control = chain[i]
		control.focus_next = control.get_path_to(chain[(i + 1) % chain.size()])
		control.focus_previous = control.get_path_to(chain[(i - 1 + chain.size()) % chain.size()])
	var toolbar: Array[Control] = [_zoom_out_button, _zoom_in_button, _fit_button, _pan_button]
	_open_move_button.focus_neighbor_bottom = _open_move_button.get_path_to(_zoom_out_button)
	for i in range(toolbar.size()):
		var button: Control = toolbar[i]
		button.focus_neighbor_top = button.get_path_to(_open_move_button)
		button.focus_neighbor_bottom = button.get_path_to(_board)
		if i > 0:
			button.focus_neighbor_left = button.get_path_to(toolbar[i - 1])
		if i < toolbar.size() - 1:
			button.focus_neighbor_right = button.get_path_to(toolbar[i + 1])
	_board.focus_neighbor_top = _board.get_path_to(_pan_button)
	_board.focus_neighbor_left = NodePath(".")
	_board.focus_neighbor_right = NodePath(".")
	_board.focus_neighbor_bottom = NodePath(".")

func _on_board_pan_mode_changed(enabled: bool) -> void:
	_pan_button.set_pressed_no_signal(enabled)
	_refresh_navigation_help()

func _refresh_navigation_help() -> void:
	var zoom_in_key := _binding_text(&"canvas_zoom_in", true)
	var zoom_out_key := _binding_text(&"canvas_zoom_out", true)
	var fit_key := _binding_text(&"canvas_fit", true)
	_zoom_out_button.tooltip_text = "Zoom out (%s)" % _binding_text(&"canvas_zoom_out")
	_zoom_in_button.tooltip_text = "Zoom in (%s)" % _binding_text(&"canvas_zoom_in")
	_fit_button.tooltip_text = "Fit the whole puzzle in view (%s)" % _binding_text(&"canvas_fit")
	_pan_button.tooltip_text = "Toggle Pan mode: drag to move the view instead of selecting"
	var zoom_hint := "Wheel or %s/%s: zoom" % [zoom_in_key, zoom_out_key]
	if _board.is_pan_mode():
		_help_label.text = "Pan mode: drag to move - %s - %s: fit" % [zoom_hint, fit_key]
	else:
		_help_label.text = "%s - Middle-drag or Pan: move - %s: fit" % [zoom_hint, fit_key]
	_help_label.mouse_filter = Control.MOUSE_FILTER_PASS
	_help_label.tooltip_text = ("Zoom: mouse wheel, or %s / %s with the board focused. Move: middle-drag, "
		+ "Pan mode, or %s / left stick with the board focused. Fit: %s.") % [
			_binding_text(&"canvas_zoom_in"), _binding_text(&"canvas_zoom_out"),
			_movement_binding_text(), _binding_text(&"canvas_fit")]

## Compact, current text for one action's keyboard and gamepad bindings,
## derived from the live InputMap so remapped controls are described truthfully.
func _binding_text(action: StringName, first_key_only: bool = false) -> String:
	var parts: PackedStringArray = []
	for event in InputMap.action_get_events(action):
		if first_key_only and not (event is InputEventKey):
			continue
		var text := _event_label(event)
		if not text.is_empty() and not parts.has(text):
			parts.append(text)
			if first_key_only:
				break
	return " or ".join(parts) if not parts.is_empty() else "unbound"

func _movement_binding_text() -> String:
	var keys: PackedStringArray = []
	for action in [&"move_up", &"move_left", &"move_down", &"move_right"]:
		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				keys.append(_event_label(event))
				break
	return "".join(keys) if keys.size() == 4 else "the move keys"

func _event_label(event: InputEvent) -> String:
	if event is InputEventKey:
		return event.as_text_physical_keycode() if event.physical_keycode != KEY_NONE else event.as_text_keycode()
	if event is InputEventJoypadButton:
		var text: String = event.as_text()
		var open := text.find("(")
		if open >= 0:
			return text.substr(open + 1).split(",")[0].trim_suffix(")")
		return text
	if event is InputEventJoypadMotion:
		return "Left Stick" if event.axis < 2 else "Right Stick"
	return ""

func _start_new_attempt() -> void:
	var puzzle_id: String = PuzzleSession.get_current_id()
	var definition: PuzzleDefinition = PuzzleCatalog.get_definition(puzzle_id)
	_state = PuzzleState.new(definition)
	_pending_departures = 0
	_awaiting_completion = false
	_results.hide()
	_pause_menu_controller.set_process_unhandled_input(true)
	_board.set_navigation_enabled(true)
	_board.setup(definition)
	_puzzle_label.text = "%d. %s" % [PuzzleCatalog.index_of(puzzle_id) + 1, PuzzleCatalog.get_title(puzzle_id)]
	_update_hud()

func _update_hud() -> void:
	_remaining_label.text = "Remaining: %d" % _state.remaining()
	_mistakes_label.text = "Mistakes: %d" % _state.mistakes

func _on_hover_cell_changed(cell: Vector2i) -> void:
	_board.set_hovered_head(_state.get_arrow_head(cell) if not _results.visible else null)

## Any cell of a multi-cell shape (head or tail) resolves to the same
## canonical head before mutation, so the board's per-arrow views (keyed by
## head) always receive the right owner regardless of which cell was clicked.
func _on_cell_clicked(cell: Vector2i) -> void:
	var head = _state.get_arrow_head(cell)
	if head == null:
		return
	var outcome: PuzzleState.SelectOutcome = _state.select_arrow(head)
	match outcome:
		PuzzleState.SelectOutcome.IGNORED:
			pass
		PuzzleState.SelectOutcome.BLOCKED:
			_update_hud()
			_board.clear_suggestion()
			_board.play_blocked(head)
		PuzzleState.SelectOutcome.REMOVED:
			_update_hud()
			_pending_departures += 1
			if _state.completed:
				_awaiting_completion = true
			_board.play_removed(head)

## "Show Me an Open Move": identifies one currently legal arrow via the
## rules authority itself (never a duplicated legal-move check), and never
## removes it -- the player must still select it. Always reads the current
## logical state regardless of any in-flight departure animation elsewhere
## in the scene (the rules authority already reflects a removal the instant
## it happens), so it is deliberately never gated on _pending_departures.
func _on_open_move_button_pressed() -> void:
	var head = _state.request_open_move()
	if head != null:
		_board.suggest_open_move(head)

func _on_departure_finished() -> void:
	_pending_departures -= 1
	if _awaiting_completion and _pending_departures <= 0:
		_show_results()

func _show_results() -> void:
	_board.clear_hover()
	_board.set_navigation_enabled(false)
	_pause_menu_controller.set_process_unhandled_input(false)
	var results: Dictionary = _state.get_results()
	var puzzle_id: String = PuzzleSession.get_current_id()
	var comparison: String = PuzzleScoreboard.record_attempt(puzzle_id, results)
	_results.show_results(results, puzzle_id, PuzzleSession.has_next(),
		comparison, PuzzleScoreboard.get_overall_score())

## Replay reloads this scene so the identical board starts as a fully fresh
## attempt: a new PuzzleState, cleared views/tweens and no stale callbacks
## from the finished attempt. Pause-menu Restart reuses this same reload
## mechanism (unmodified addon behavior), so both honor the currently
## selected puzzle for free: PuzzleSession's static var survives the reload.
func _on_results_replay_requested() -> void:
	SceneLoader.reload_current_scene()

func _on_results_main_menu_requested() -> void:
	SceneLoader.load_scene(main_menu_scene_path)

## Advances the session to the next catalog entry, then reloads the scene
## exactly like Replay — reusing the same fresh-attempt guarantee rather
## than resetting state in place. Not reachable when PuzzleSession has no
## next entry (the results UI never offers it on the last puzzle).
func _on_results_next_puzzle_requested() -> void:
	PuzzleSession.advance_to_next()
	SceneLoader.reload_current_scene()
