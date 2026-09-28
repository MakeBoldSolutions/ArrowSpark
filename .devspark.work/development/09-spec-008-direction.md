# Spec 008 Direction --- Large Zoomable Puzzle Canvas

> **Status (2026-09-28):** in progress. The spec, plan, and tasks exist and
> have passed the checklist, analyze, and critic gates; implementation has not
> started. This file is the original direction brief. Where it differs from
> `.devspark.work/specs/008-spec-large-zoomable-canvas/`, the spec bundle wins.

## Problem

Current puzzle presentation is still fundamentally screen-oriented.

The emerging Gordian-knot direction requires boards that may be
substantially larger than the visible display.

Shrinking all arrows until a large board fits is not an acceptable
solution because it harms: - readability; - tracing; - selection; -
accessibility; - visual payoff.

## Product Principle

> **The puzzle defines the world. The screen is only a window into it.**

## Goals

Spec 008 should establish: - puzzle dimensions independent of viewport
dimensions; - zoom in/out; - pan; - Fit Puzzle; - sensible initial
view; - keyboard/gamepad access; - correct selection after transforms; -
resize stability; - Open Move visibility when selected arrow is
off-screen; - path-following departure under zoom/pan.

## Board Size vs. Density vs. Viewport

These must remain distinct.

### Board size

Logical width/height from PuzzleDefinition.

### Geometric density

Amount of meaningful arrow geometry occupying a region.

### Viewport

Current visible region.

### Zoom

Scale at which that region is viewed.

A future 20×20 puzzle should not imply tiny arrows. It should imply a
larger world.

## Zoom Behavior

Desired characteristics: - bounded minimum/maximum; - predictable focal
behavior; - conventional desktop controls; - explicit controls
accessible to keyboard/gamepad; - future-compatible with pinch zoom
without requiring mobile work now.

The exact Godot implementation should be researched rather than
predetermined.

## Pan Behavior

Panning must not become accidental arrow selection.

The design needs a clear distinction between: - navigation gesture; -
arrow-selection gesture.

Desktop and keyboard/gamepad navigation both matter.

## Fit Puzzle

Fit Puzzle is a first-class capability, not merely a convenience.

It supports the intended cognitive rhythm:

`whole knot → local inspection → local work → whole knot again`

It also provides a reliable recovery action after extensive navigation.

## Initial View

Likely default: - Fit Puzzle on start.

But small existing puzzles should remain natural and not feel as if the
player is operating a camera unnecessarily.

## Open Move and Off-Screen Arrows

If Open Move chooses an arrow outside the viewport, the assist has
failed unless the player can perceive the result.

Spec 008 should define a predictable reveal behavior.

Likely approach: - adjust viewport so the selected arrow is visible; -
then show the existing highlight.

The movement must not alter gameplay state beyond the normal assist
cost.

## Departure Animation

Long-arrow departure is central to the emerging game identity.

Zooming/panning must not: - reset route; - corrupt progress; - cause
diagonal shortcuts; - alter logical state; - break the pending-departure
barrier.

A long arrow should continue to unwind correctly even while the camera
moves.

## Resize

Window resize should preserve player orientation where practical.

It must not: - reset attempt; - change logical cells; - alter score; -
corrupt animation.

Planning should decide the exact invariant: - preserve focal point; -
preserve zoom; - or another clear equivalent.

## Validation Content

One deliberately large validation puzzle may be useful.

It should prove: - board larger than viewport; - pan/zoom; - Fit
Puzzle; - transformed selection; - off-screen Open Move; - long
departure; - completion.

It should not become a polished Gordian-knot experiment.

## Non-Goals

Spec 008 should not include: - procedural generation; - final
hard-puzzle design; - mobile redesign; - Web deployment; - telemetry; -
persistence; - player identity; - difficulty rating; - new removal
rules; - infinite canvas; - speculative performance infrastructure.

## Testing Focus

Automated: - logical state unchanged by viewport; - transforms select
correct arrow; - Fit Puzzle bounds; - zoom limits; - no persistence; -
solver/analyzer unaffected; - animation geometry stable.

Manual: - wheel/button zoom feel; - panning feel; - click-vs-drag
behavior; - keyboard/gamepad navigation; - Open Move off-screen
reveal; - animation while transformed; - resize; - small puzzle feel.

## Success

Spec 008 succeeds when puzzle authors no longer have to ask:

> "Can this puzzle fit on the screen?"

They should ask:

> "Is this puzzle worth exploring?"
