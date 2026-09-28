class_name PuzzleFeedback
extends RefCounted
## Named animation-duration/speed constants shared by arrow_view.gd and
## headless tests, so the blocked-feedback cap and departure speed are
## asserted against the actual coded values rather than judged only by eye
## during smoke testing.

## Blocked feedback: a quick scale pulse inside a longer bright-red hold. The
## whole cue (red until the arrow returns to normal) lasts
## BLOCKED_CUE_DURATION_SECONDS and must not exceed its cap.
const BLOCKED_PULSE_SECONDS: float = 0.15
const BLOCKED_CUE_DURATION_SECONDS: float = 0.6
const BLOCKED_CUE_DURATION_CAP_SECONDS: float = 0.75

## Centrally configured, shared cell-distance departure speed (cells/second).
## Tuning within 8-12 is permitted with recorded visual evidence; no duration
## cap is applied.
const EXIT_SPEED_CELLS_PER_SECOND: float = 10.0
## Extra cell-unit clearance beyond exact edge contact so full-tail finish
## never completes early from floating-point boundary equality.
const EXIT_CLEARANCE_MARGIN_CELLS: float = 0.001
