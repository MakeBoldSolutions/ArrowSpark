extends Control
## Completion results panel: total arrows, mistakes, score, accuracy, Replay
## and Main Menu. Absorbs background input while shown so a second
## completion or pause overlay cannot occur underneath it.

signal replay_requested
signal main_menu_requested
signal next_puzzle_requested
signal level_select_requested

@onready var _puzzle_label: Label = %PuzzleLabel
@onready var _total_label: Label = %TotalLabel
@onready var _mistakes_label: Label = %MistakesLabel
@onready var _open_move_assists_label: Label = %OpenMoveAssistsLabel
@onready var _score_label: Label = %ScoreLabel
@onready var _accuracy_label: Label = %AccuracyLabel
@onready var _session_comparison_label: Label = %SessionComparisonLabel
@onready var _overall_session_score_label: Label = %OverallSessionScoreLabel
@onready var _replay_button: Button = %ReplayButton
@onready var _next_puzzle_button: Button = %NextPuzzleButton
@onready var _level_select_button: Button = %LevelSelectButton

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func _ready() -> void:
	theme = GameVisualStyle.get_theme()
	$Background.color = GameVisualStyle.GAME_BACKGROUND
	_puzzle_label.theme_type_variation = &"SupportingText"
	for label in [_total_label, _mistakes_label, _open_move_assists_label, _accuracy_label]:
		label.theme_type_variation = &"NumericText"
	_score_label.theme_type_variation = &"SuccessText"
	_session_comparison_label.theme_type_variation = &"SupportingText"
	_overall_session_score_label.theme_type_variation = &"SupportingText"
	_replay_button.theme_type_variation = &"PrimaryButton"
	_next_puzzle_button.theme_type_variation = &"PrimaryButton"
	_level_select_button.theme_type_variation = &"PrimaryButton"
	%MainMenuButton.theme_type_variation = &"SecondaryButton"
	$CenterContainer/VBoxContainer.add_theme_constant_override("separation", GameVisualStyle.SPACING[2])
	$CenterContainer/VBoxContainer/ButtonRow.add_theme_constant_override("separation", GameVisualStyle.SPACING[2])

## has_next selects whether Next Puzzle is shown (there is a next puzzle in
## the same group); otherwise Level Select is shown instead. puzzle_id/puzzle_index reflect the puzzle that
## was actually completed, independent of the metrics above.
##
## session_comparison is one of PuzzleScoreboard.record_attempt()'s four
## outcome strings ("established"/"improved"/"tied"/"not_improved");
## overall_session_score is PuzzleScoreboard.get_overall_score() taken right
## after that same record_attempt call. This panel only displays what it is
## given -- it never calls PuzzleScoreboard itself -- kept to two short lines
## per the spec's "no progression dashboard" constraint.
func show_results(results: Dictionary, puzzle_id: String, has_next: bool,
		session_comparison: String, overall_session_score: int) -> void:
	_puzzle_label.text = "%d. %s" % [PuzzleCatalog.group_position(puzzle_id), PuzzleCatalog.get_title(puzzle_id)]
	_total_label.text = "Total Arrows: %d" % results["total_arrows"]
	_mistakes_label.text = "Mistakes: %d" % results["mistakes"]
	_open_move_assists_label.text = "Open Move Assists: %d" % results["open_move_assists"]
	_score_label.text = "Score: %d" % results["score"]
	_accuracy_label.text = "Accuracy: %s" % PuzzleResultsFormat.format_accuracy_percent(results["accuracy"])
	_session_comparison_label.text = _format_session_comparison(session_comparison, results["score"])
	_overall_session_score_label.text = "Overall Session Score: %d" % overall_session_score
	_next_puzzle_button.visible = has_next
	_level_select_button.visible = not has_next
	show()
	_replay_button.grab_focus()

static func _format_session_comparison(outcome: String, score: int) -> String:
	match outcome:
		"established":
			return "New session best: %d" % score
		"improved":
			return "Session best improved to %d" % score
		"tied":
			return "Matched session best: %d" % score
		_: # "not_improved"
			return "Session best unchanged"

func _on_replay_button_pressed() -> void:
	replay_requested.emit()

func _on_main_menu_button_pressed() -> void:
	main_menu_requested.emit()

func _on_next_puzzle_button_pressed() -> void:
	next_puzzle_requested.emit()

func _on_level_select_button_pressed() -> void:
	level_select_requested.emit()
