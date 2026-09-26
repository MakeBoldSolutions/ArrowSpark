extends Control
## Session controller: owns PuzzleState, the live HUD, and the
## playing -> draining -> results lifecycle (data-model.md). Reuses the
## starter's pause menu and background music; does not touch saved
## progress or settings (FR-013).

@export_file("*.tscn") var main_menu_scene_path: String = "res://scenes/menus/main_menu/main_menu_with_animations.tscn"

@onready var _board: PuzzleBoard = %PuzzleBoard
@onready var _remaining_label: Label = %RemainingLabel
@onready var _mistakes_label: Label = %MistakesLabel
@onready var _results: Control = %PuzzleResults
@onready var _pause_menu_controller: Node = %PauseMenuController

var _state: PuzzleState
var _pending_departures: int = 0
var _awaiting_completion: bool = false

func _ready() -> void:
	_results.replay_requested.connect(_on_results_replay_requested)
	_results.main_menu_requested.connect(_on_results_main_menu_requested)
	_board.cell_clicked.connect(_on_cell_clicked)
	_board.departure_finished.connect(_on_departure_finished)
	_start_new_attempt()

func _start_new_attempt() -> void:
	var definition: PuzzleDefinition = PuzzleDefinition.create_fixed()
	_state = PuzzleState.new(definition)
	_pending_departures = 0
	_awaiting_completion = false
	_results.hide()
	_pause_menu_controller.set_process_unhandled_input(true)
	_board.setup(definition)
	_update_hud()

func _update_hud() -> void:
	_remaining_label.text = "Remaining: %d" % _state.remaining()
	_mistakes_label.text = "Mistakes: %d" % _state.mistakes

func _on_cell_clicked(cell: Vector2i) -> void:
	var outcome: PuzzleState.SelectOutcome = _state.select_arrow(cell)
	match outcome:
		PuzzleState.SelectOutcome.IGNORED:
			pass
		PuzzleState.SelectOutcome.BLOCKED:
			_update_hud()
			_board.play_blocked(cell)
		PuzzleState.SelectOutcome.REMOVED:
			_update_hud()
			_pending_departures += 1
			if _state.completed:
				_awaiting_completion = true
			_board.play_removed(cell)

func _on_departure_finished() -> void:
	_pending_departures -= 1
	if _awaiting_completion and _pending_departures <= 0:
		_show_results()

func _show_results() -> void:
	_pause_menu_controller.set_process_unhandled_input(false)
	_results.show_results(_state.get_results())

## Replay reloads this scene so the identical board starts as a fully fresh
## attempt: a new PuzzleState, cleared views/tweens and no stale callbacks
## from the finished attempt (data-model.md Presentation lifecycle).
func _on_results_replay_requested() -> void:
	SceneLoader.reload_current_scene()

func _on_results_main_menu_requested() -> void:
	SceneLoader.load_scene(main_menu_scene_path)
