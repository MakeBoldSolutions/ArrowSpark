# Spec 004 — Path-Following Arrow Departure

## Intent

Improve the removal animation so continuous arrows appear to be **pulled through their own path and out of the puzzle board**, rather than translating rigidly as a complete shape.

This is a presentation and game-feel change only.

The existing puzzle domain behavior must remain unchanged. A legal arrow selection still removes the entire arrow logically and atomically before visual departure begins.

## Player Experience

When the player selects a legal arrow:

1. The arrow is immediately removed from the logical puzzle, exactly as today.
2. Visually, the arrow's head begins moving forward in its travel direction.
3. The rest of the arrow follows through its existing ordered path.
4. Existing bends remain fixed in their original board locations while the arrow material feeds through them.
5. As the tail passes a bend, that bend disappears from the visible arrow.
6. The portion beyond the original head extends straight in the arrow's travel direction.
7. The arrow progressively disappears as it crosses the puzzle-board boundary.
8. Departure finishes only after the entire visible arrow, including its tail, has cleared the board.
9. If this is the final arrow, completion/results wait until its visual departure has finished, preserving the existing departure barrier.

The desired visual impression is that the arrow is being **pulled, fed, or unwound through its route and out of the board**.

It should not look like the entire bent shape is sliding rigidly across the board.

## Path Behavior

Use the arrow's existing ordered geometry.

Conceptually, the departure route is:

`tail endpoint → existing ordered tail path → original head → forward escape ray`

The original route through the board remains stationary.

The arrow moves through that route.

Do **not** animate the bend locations themselves toward the head.

For example, as a multi-bend arrow departs:

- the head proceeds forward,
- the tail advances through the existing route,
- bends remain visible until the tail reaches them,
- consumed bends disappear,
- new arrow length is added along the forward escape ray,
- the arrow eventually becomes straight,
- the remaining straight arrow continues through the board edge until fully gone.

The visual arrow should maintain a constant apparent centerline length while it is being fed through the route, subject only to progressive clipping at the board boundary.

## Geometry Model

Prefer the simplest robust implementation identified by repository research:

**Animate one scalar departure distance along an immutable presentation-only polyline and rebuild the existing continuous arrow geometry from the corresponding moving interval.**

The implementation should use the existing ordered cells and continuous-arrow presentation created in Spec 003.

The expected presentation model is approximately:

`P(s)` = position at distance `s` along the departure route.

`L` = original distance from the tail endpoint to the head center.

`d` = current departure distance.

Then conceptually:

- tail position = `P(d)`
- head position = `P(L + d)`
- visible body = the route interval between tail and head/body endpoint
- sampling beyond the original head continues analytically along the head's forward direction

When extracting the visible interval, preserve all original path vertices that occur between the moving endpoints.

Do not connect only the two sampled endpoints if doing so would create diagonal shortcuts across existing right-angle bends.

Exact implementation details may be refined during planning as long as these visual and geometric behaviors remain true.

## Existing Continuous Arrow Representation

Build upon the Spec 003 implementation.

`ArrowView` should remain the visual authority for an individual arrow.

The existing continuous representation based on a `Line2D` body and `Polygon2D` head should be retained unless implementation analysis identifies a concrete reason it cannot support this feature.

Do not introduce `Path2D`, `PathFollow2D`, `Curve2D`, physics bodies, segmented follower nodes, or similar additional Godot structures merely because they can animate paths.

Prefer the smallest implementation that cleanly supports the required behavior.

A small presentation-only geometry helper is appropriate if it makes polyline construction, cumulative distances, sampling, interval extraction, and tests substantially clearer.

Such a helper must have no puzzle-state or gameplay responsibility.

## Single-Cell and Straight Arrows

The same departure concept must work naturally for all valid arrow shapes.

### Single-cell arrow

Use the existing presentation concept of a synthetic short tail behind the head so the arrow has visible shaft length.

It should depart cleanly in a straight line without requiring a fundamentally different animation system.

### Straight multi-cell arrow

A straight arrow should visually behave like a straight-line version of the same path-following system.

### Bent arrows

One-bend and multi-bend arrows must visibly feed through their ordered route without diagonal shortcuts, disconnected geometry, or changing ownership interpretation.

## Board Boundary and Clipping

The puzzle board is the visual boundary of the puzzle.

Departing arrow geometry should be **progressively clipped at the board edge**.

Once part of an arrow crosses the puzzle-board boundary, that portion should no longer be visible.

The arrow should not continue visibly across the HUD, results area, or other surrounding UI while departing.

Logical removal remains independent of clipping.

Departure completion occurs when the entire arrow has cleared the relevant board boundary, not merely when the head leaves the board.

The implementation must account for body width, tail cap, head geometry, and an appropriate small visual clearance tolerance when determining when departure is complete.

## Departure Timing

Replace the current fixed-duration rigid departure with **distance-based motion**.

The arrow should travel at a consistent presentation speed expressed conceptually in cells per second.

Long winding arrows should therefore take longer to depart than short arrows because their tails must travel farther through the route.

Choose an initial speed that makes the unwinding behavior readable and responsive. A starting range around **8–12 cells per second** is reasonable for tuning, but the exact value is a presentation constant rather than a domain rule.

The final value should be centralized with the existing presentation/motion configuration rather than embedded throughout the animation implementation.

A reasonable maximum departure duration may be introduced if needed to prevent unusually long future arrows from delaying completion excessively. If a cap is introduced, document the rationale and keep the behavior deterministic.

Motion should remain smooth and should not use bounce or exaggerated easing that obscures the path-following effect.

## Visual State Precedence

Preserve the Spec 003 state-transition intent:

`departure → blocked → hover → normal`

When departure begins:

- mark the view as departing,
- clear hover state,
- clear blocked state,
- cancel existing hover and blocked animation writers,
- restore unit scale,
- restore appropriate normal arrow color/modulation,
- then begin path-following departure.

Once departure begins:

- hover must not affect the arrow,
- blocked feedback must not affect the arrow,
- no prior tween may fight the departure geometry,
- duplicate departure requests must not create multiple departure animations or completion callbacks.

Do not regress the normalization behavior established by Spec 003.

## Logical Behavior Must Remain Unchanged

This specification must not change puzzle rules.

In particular, preserve:

- `PuzzleDefinition`
- arrow geometry semantics
- ordered head/tail ownership
- structural validation
- blocking rules
- `PuzzleState`
- immediate atomic logical removal
- solver behavior
- scoring
- mistake counting
- accuracy
- completion rules
- unlimited attempts
- replay behavior
- whole-cell hit testing
- head/tail input equivalence

Animation progress must never participate in:

- blocker detection,
- ownership,
- solver decisions,
- scoring,
- counters,
- legal-move determination,
- completion state.

A visually departing arrow is already gone from the logical puzzle.

Other arrows may therefore become legally removable while the previous arrow is still visibly departing.

Visual overlap between simultaneously departing arrows is decorative only.

## Completion Barrier

Preserve the existing pending-departure lifecycle.

Logical puzzle completion may occur before the final animation finishes.

Results must not appear until all required visual departures have completed.

Multiple arrows may depart simultaneously and may finish in a different order from the order in which they were selected.

Completion must depend on all outstanding departures finishing, not on assumptions about which arrow finishes last.

Each departing view must emit/trigger completion exactly once.

## Resize Behavior

Spec 004 should close the current resize gap for departing arrows.

Today, departing views are removed from the active-view collection and are no longer relaid out if the board changes size.

The new implementation should preserve departure progress in board/cell-relative units so an in-progress departure can be rebuilt correctly after a resize.

A resize must:

- preserve current logical departure progress,
- recompute pixel geometry using the new cell extent,
- reposition/rebuild the departing view correctly,
- update any board-boundary clearance calculations,
- not restart the departure,
- not reactivate input,
- not emit completion more than once.

Departing arrows must remain excluded from active ownership/input routing.

A separate presentation-level collection of departing views is acceptable if needed to support resize and cleanup.

## Pause and Lifecycle Behavior

Preserve existing pause/lifecycle semantics.

Pausing during departure should freeze departure progress and visible geometry.

Resuming should continue from the same progress.

Restarting, reloading, leaving the scene, or replacing the puzzle scene must cleanly dispose of departing views and their animations without stale callbacks affecting the next attempt.

## Architecture

Expected responsibility boundaries:

### Puzzle domain

No changes expected.

The domain continues to determine:

- arrow structure,
- ownership,
- blocking,
- legal removal,
- logical state,
- counters,
- completion,
- solver behavior.

### ArrowView

Owns:

- immutable presentation departure geometry,
- departure progress,
- body/head reconstruction,
- visual-state normalization,
- departure tween/progress,
- exactly-once visual completion.

### Presentation geometry helper

If introduced, it may own pure calculations such as:

- cumulative polyline lengths,
- distance sampling,
- forward-ray sampling,
- moving-interval extraction,
- preservation of intermediate corners,
- exit/clearance calculations where appropriate.

It must not own Nodes, puzzle state, input, scoring, or solver behavior.

### PuzzleBoard

May own/provide:

- board layout information,
- cell extent,
- clipping boundary,
- departing-view layout tracking,
- resize updates,
- cleanup coordination.

### Controller

Continue to coordinate:

- logical selection outcome,
- pending departure count,
- completion barrier,
- transition to results.

Do not move path mathematics into the controller.

## Automated Verification

Favor deterministic geometry and lifecycle tests over screenshot/pixel tests.

### Geometry/unit coverage

Include tests for:

- tail-to-head route construction,
- synthetic single-cell route,
- cumulative path length,
- sampling within straight segments,
- sampling exactly at bends,
- sampling at the original head,
- sampling beyond the head along the forward ray,
- one-bend interval extraction,
- multi-bend interval extraction,
- preservation of intermediate corners,
- absence of diagonal shortcuts,
- constant centerline length during departure,
- continuity immediately before/at/after consuming a bend,
- head/body synchronization,
- fixed head orientation,
- tail clearance calculation,
- duplicate/coincident presentation-point guards,
- zero-extent safety,
- equivalent cell-relative geometry after resize,
- no visible first-frame geometry jump at departure start.

### Scene/integration coverage

Verify:

- logical removal occurs before visual departure advances,
- HUD/counters update immediately,
- departing cells cannot be selected,
- departing arrows cannot become hovered,
- blocked/hover effects normalize synchronously before departure,
- duplicate departure requests do not create duplicate tweens/callbacks,
- simultaneous departures remain independent,
- departure order does not break completion,
- pause freezes progress,
- resume continues correctly,
- resize preserves departure progress,
- final results wait for full tail clearance,
- departing views are cleaned up,
- restart/reload does not leave stale callbacks,
- domain outcomes remain independent of animation speed/duration.

Existing rule, solver, scoring, save/input, and presentation regression suites must remain green.

## Manual Visual Verification

Some acceptance criteria require actual play rather than automated assertions.

Manually verify:

- a straight arrow departure looks natural,
- a one-bend arrow visibly feeds through its corner,
- a multi-bend arrow visibly unwinds through each bend,
- no bend is replaced by a diagonal shortcut,
- motion reads as the arrow being pulled through its path,
- tail-cap motion through corners looks acceptable,
- head and body remain visually connected,
- departure begins without a visual jump,
- speed is readable without feeling sluggish,
- arrows progressively disappear at the board edge,
- departing arrows do not draw across surrounding HUD/UI,
- multiple departures remain visually understandable,
- pause/resume looks correct,
- resizing during departure does not visibly corrupt the arrow,
- final departure transitions cleanly to results.

## Durable Knowledge

If this implementation establishes durable presentation architecture or conventions that future work must understand, update project knowledge accordingly.

In particular, durable knowledge should explain the distinction between:

- immediate logical removal,
- continued presentation-only departure,
- ordered arrow geometry,
- fixed-route path-following departure,
- completion waiting on visual departures.

Do not make production code depend on this spec document.

## Out of Scope

Do not add:

- new puzzle mechanics,
- puzzle generation,
- difficulty analysis,
- additional levels,
- progression,
- persistence changes,
- achievements,
- audio,
- haptics,
- Android/mobile deployment,
- broad menu redesign,
- broad results-screen redesign,
- new scoring rules,
- curved authored arrow geometry,
- physically simulated ropes/snakes,
- moving bend locations,
- collision during departure,
- per-arrow colors,
- changes to solver/domain behavior.

This spec is specifically about **how an already legally removed continuous arrow visually leaves the board**.

## Success

Spec 004 succeeds when a player can click a legal bent arrow and clearly see it feed through its own existing path and disappear through the board edge, while the puzzle engine continues to behave exactly as it did before the animation began.

The visual effect should make long and bent arrows more satisfying to remove without making the animation part of the game rules.