# Presentation Contract

## Geometry interface

Proposed helper script: scripts/presentation/arrow_departure_geometry.gd. Inputs are tail-to-head Vector2 cell positions and a cardinal forward Vector2; no domain object is required. Prefix lengths use Euclidean lengths of cardinal segments. sample_distance(0) is the original tail; sample_distance(L) is the head; beyond L continues analytically. Reject negative sample requests or clamp them to zero consistently (selected policy: clamp). extract_interval(a,b) requires 0 <= a <= b, returns sampled endpoints plus every original vertex strictly inside; equal endpoints produce one point safely. Consecutive coincident points are removed without skipping true corners.

ArrowView constructs route from existing copied offsets. At distance d, body interval is [d,L+d+BODY_END], head center P(L+d); polygon offsets remain HEAD_TIP, HEAD_BASE, HEAD_HALF_WIDTH. For current ratios body length is L-0.02 > 0, including L=0.30 single-cell. At d=0 no extra head-center vertex is introduced. Body rendering never closes the line.

## Motion interface

Replace play_exit_animation(pixel_distance) with play_exit_animation(finish_distance_cells). Caller connects completion and installs a valid layout before start. Repeated start ignored. State normalization occurs synchronously even if layout is invalid. advance_departure(delta) owns d += speed*delta, capped at finish distance; it refuses paused/invalid-layout/finished advancement. _process delegates to it. Speed is PuzzleFeedback.EXIT_SPEED_CELLS_PER_SECOND=10.0; remove stale fixed-duration references from implementation and tests. Blocked feedback keeps its existing duration/tween contract.

Layout update supplies pixel extent and original bbox position without restarting. Completion must be emitted once after rendering terminal geometry; no signal from a resize notification. cancel_departure stops advancement/effects and prevents future completion; used before setup disposal.

## Boundary and clearance

Clip only departing children to Rect2(_origin, grid_dimensions*extent) in board coordinates. Within the clip, view origin is bbox_min*extent. Grid dimensions/cells determine E in the forward direction. Tail cap radius r=BODY_WIDTH/2=0.07. Finish d=L+E+r+0.001 (cell units). At this point tail's rear support is strictly beyond the edge and all later body points/head are ahead. Assert L+HEAD_BASE >= -r for the synthetic/normal shapes; if style ratios change, calculate the maximum rear support of body/head instead of assuming tail dominance. Geometry comparison tolerance 1e-5 cells; length tolerance 1e-5*max(1,L); neither relaxes clearance early. One-frame scheduling lateness is allowed; never early completion. Clipping handles antialias footprint at the edge.

## Lifecycle and interaction

Logical selection remains PuzzleState -> controller -> board. Removal erases active routing before starting animation; departing collection is presentation-only. DepartureClip and ArrowViews ignore input, so pointer mapping still targets the board. Simultaneous animations may overlap. Exactly-once board callback checks tracked view identity, removes it, frees it, and notifies controller. setup cancels and disconnects before clearing collections; no synthetic completion on disposal. Scene changes must not deliver stale signals into the next attempt.

## Verification boundaries

Point/interval tests prove geometry; Control configuration and scene checks prove clip placement and input routing, but only rendered review proves visible clipping/AA seams. Hardware navigation acceptance cannot be inferred from synthetic input. See quickstart.md for required evidence.
