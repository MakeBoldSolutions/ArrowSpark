extends Control
## Completion results panel: total arrows, mistakes, score, accuracy, Replay
## and Main Menu. Absorbs background input while shown so a second
## completion or pause overlay cannot occur underneath it.

signal replay_requested
signal main_menu_requested
signal next_puzzle_requested

@onready var _puzzle_label: Label = %PuzzleLabel
@onready var _total_label: Label = %TotalLabel
@onready var _mistakes_label: Label = %MistakesLabel
@onready var _score_label: Label = %ScoreLabel
@onready var _accuracy_label: Label = %AccuracyLabel
@onready var _replay_button: Button = %ReplayButton
@onready var _next_puzzle_button: Button = %NextPuzzleButton

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func _ready() -> void:
	theme = GameVisualStyle.get_theme()
	$Background.color = GameVisualStyle.GAME_BACKGROUND
	_puzzle_label.theme_type_variation = &"SupportingText"
	for label in [_total_label, _mistakes_label, _accuracy_label]:
		label.theme_type_variation = &"NumericText"
	_score_label.theme_type_variation = &"SuccessText"
	_replay_button.theme_type_variation = &"PrimaryButton"
	_next_puzzle_button.theme_type_variation = &"PrimaryButton"
	%MainMenuButton.theme_type_variation = &"SecondaryButton"
	$CenterContainer/VBoxContainer.add_theme_constant_override("separation", GameVisualStyle.SPACING[2])
	$CenterContainer/VBoxContainer/ButtonRow.add_theme_constant_override("separation", GameVisualStyle.SPACING[2])

## has_next selects whether Next Puzzle is shown/enabled: MUST NOT appear on
## the last catalog puzzle. puzzle_id/puzzle_index reflect the puzzle that
## was actually completed, independent of the metrics above.
func show_results(results: Dictionary, puzzle_id: String, has_next: bool) -> void:
	var puzzle_index := PuzzleCatalog.index_of(puzzle_id)
	_puzzle_label.text = "%d. %s" % [puzzle_index + 1, PuzzleCatalog.get_title(puzzle_id)]
	_total_label.text = "Total Arrows: %d" % results["total_arrows"]
	_mistakes_label.text = "Mistakes: %d" % results["mistakes"]
	_score_label.text = "Score: %d" % results["score"]
	_accuracy_label.text = "Accuracy: %s" % PuzzleResultsFormat.format_accuracy_percent(results["accuracy"])
	_next_puzzle_button.visible = has_next
	show()
	_replay_button.grab_focus()

func _on_replay_button_pressed() -> void:
	replay_requested.emit()

func _on_main_menu_button_pressed() -> void:
	main_menu_requested.emit()

func _on_next_puzzle_button_pressed() -> void:
	next_puzzle_requested.emit()
