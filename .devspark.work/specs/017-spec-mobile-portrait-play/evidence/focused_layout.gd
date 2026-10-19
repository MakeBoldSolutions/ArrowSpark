extends "res://tests/puzzle_layout_check.gd"
func _initialize() -> void:
	await _check_nested_pause_portrait()
	await _check_portrait_action_strip()
	print("PORTRAIT_FOCUSED_FAILURES=", failures)
	quit(1 if failures else 0)
