extends "res://tests/puzzle_canvas_check.gd"
func _initialize() -> void:
	await _check_cancelled_touch_and_resize()
	await _check_results_barrier_and_navigation_gating()
	print("CANVAS_FOCUSED_FAILURES=", failures)
	quit(1 if failures else 0)
