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
	_results.replay_requested.connect(_on_results_replay_requested)
	_results.main_menu_requested.connect(_on_results_main_menu_requested)
	_results.next_puzzle_requested.connect(_on_results_next_puzzle_requested)
	_board.cell_clicked.connect(_on_cell_clicked)
	_board.hover_cell_changed.connect(_on_hover_cell_changed)
	_board.departure_finished.connect(_on_departure_finished)
	_open_move_button.pressed.connect(_on_open_move_button_pressed)
	_start_new_attempt()

func _start_new_attempt() -> void:
	var puzzle_id: String = PuzzleSession.get_current_id()
	var definition: PuzzleDefinition = PuzzleCatalog.get_definition(puzzle_id)
	_state = PuzzleState.new(definition)
	_pending_departures = 0
	_awaiting_completion = false
	_results.hide()
	_pause_menu_controller.set_process_unhandled_input(true)
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
