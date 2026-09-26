extends Control
## Completion results panel: total arrows, mistakes, score, accuracy, Replay
## and Main Menu. Absorbs background input while shown so a second
## completion or pause overlay cannot occur underneath it.

signal replay_requested
signal main_menu_requested

@onready var _total_label: Label = %TotalLabel
@onready var _mistakes_label: Label = %MistakesLabel
@onready var _score_label: Label = %ScoreLabel
@onready var _accuracy_label: Label = %AccuracyLabel
@onready var _replay_button: Button = %ReplayButton

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func show_results(results: Dictionary) -> void:
	_total_label.text = "Total Arrows: %d" % results["total_arrows"]
	_mistakes_label.text = "Mistakes: %d" % results["mistakes"]
	_score_label.text = "Score: %d" % results["score"]
	_accuracy_label.text = "Accuracy: %s" % PuzzleResultsFormat.format_accuracy_percent(results["accuracy"])
	show()
	_replay_button.grab_focus()

func _on_replay_button_pressed() -> void:
	replay_requested.emit()

func _on_main_menu_button_pressed() -> void:
	main_menu_requested.emit()
