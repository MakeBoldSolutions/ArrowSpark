class_name PuzzleFeedback
extends RefCounted
## Named animation-duration constants shared by arrow_view.gd and headless
## tests, so FR-005's cap is asserted against the actual coded value rather
## than judged only by eye during smoke testing.

## FR-005: blocked feedback MUST last no longer than 0.3 seconds.
const BLOCKED_CUE_DURATION_SECONDS: float = 0.15
const BLOCKED_CUE_DURATION_CAP_SECONDS: float = 0.3

const EXIT_TWEEN_DURATION_SECONDS: float = 0.25
