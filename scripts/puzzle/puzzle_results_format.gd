class_name PuzzleResultsFormat
extends RefCounted
## Pure display formatting shared by puzzle_results.gd and headless tests.

## Formats a 0..1 accuracy ratio as a one-decimal percentage string, rounding
## an exact tie half away from zero (e.g. 6.25% displays as "6.3%").
static func format_accuracy_percent(accuracy: float) -> String:
	var percent: float = accuracy * 100.0
	var scaled: float = percent * 10.0
	var magnitude: float = floor(abs(scaled) + 0.5)
	var rounded: float = magnitude if scaled >= 0.0 else -magnitude
	var one_decimal: float = rounded / 10.0
	return "%.1f%%" % one_decimal
