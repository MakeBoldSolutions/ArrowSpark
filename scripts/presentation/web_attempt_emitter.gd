class_name WebAttemptEmitter
extends RefCounted
## One-way hand-off of a completed attempt from the Web build to the page that
## hosts it. The game never waits for, reads or depends on the page: emit() is
## fire-and-forget and does nothing outside a Web build, so desktop and
## headless runs are unaffected. The message carries no player, visitor,
## session or device identifier and no timestamp.

const TYPE := "arrowspark.attemptCompleted"
const CONTRACT_VERSION := 1

## The exact eight-field message for one completed attempt. elapsed_msec is
## wall-clock time from the attempt's start to the removal that completed it,
## pauses included; it is reported in whole seconds, rounded to the nearest.
static func build_payload(puzzle_id: String, definition: PuzzleDefinition, results: Dictionary, elapsed_msec: int) -> Dictionary:
	return {
		"type": TYPE,
		"contractVersion": CONTRACT_VERSION,
		"puzzleId": puzzle_id,
		"puzzleVersion": PuzzleContentVersion.of(definition),
		"mistakes": int(results["mistakes"]),
		"openMoveAssists": int(results["open_move_assists"]),
		"score": int(results["score"]),
		"elapsedSeconds": maxi(0, roundi(elapsed_msec / 1000.0)),
	}

## Posts the payload as a JSON string to the parent page, restricted to this
## document's own origin. Returns false (and does nothing) when not running as
## a Web build or when no page interface is available.
static func emit(payload: Dictionary) -> bool:
	if not OS.has_feature("web"):
		return false
	var window = JavaScriptBridge.get_interface("window")
	if window == null or window.parent == null:
		return false
	window.parent.postMessage(JSON.stringify(payload), window.location.origin)
	return true
