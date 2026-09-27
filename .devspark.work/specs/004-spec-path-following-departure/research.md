# Research: Path-Following Arrow Departure

## Decisions

| Decision | Rationale | Alternatives considered |
|---|---|---|
| Exact cell-unit polyline and prefix distances | Existing head-first cells reverse into a complete route; validation forbids gaps/repeated cells and puts first tail behind head | Curve baking adds approximation; follower nodes do not deform a continuous shaft |
| Scalar per-frame progress, linear cell speed | Pause/zero extent and deterministic stepping are explicit; resize needs no tween restart | Tween-method viable but requires pause/resume bookkeeping for invalid layout |
| Departure-only grid clip Control | Stops UI spill without changing active hover/blocked silhouette | Clipping whole board allocation uses wrong boundary; clipping active layer changes unrelated feedback |
| Separate departing collection | Removed views currently leave _views and stop resizing; input collection must stay active-only | Keeping them active risks hover and cleanup confusion |
| Preserve controller barrier | Current immediate select then pending increment and departure callback already has correct domain separation | Domain animation state would violate scope |
| Tiny cell-unit clearance | Tail cap controls final rear support at current proportions; grid-relative threshold is resize-invariant | Head-only clearance or board diagonal can finish too early |

## Repository Evidence

ArrowView._rebuild_geometry reverses ordered tails, uses a -0.02 shaft endpoint and -0.30 synthetic tail; Line2D width is 0.14. play_exit_animation normalizes effects then tweens position for 0.25 seconds. PuzzleBoard.play_removed erases _views before animation and frees on completion. _layout_views only visits _views. Controller _on_cell_clicked mutates PuzzleState before play_removed and counts every departure. Domain validity already ensures route continuity and no own tail on the escape ray. Existing tests custom_step the old exit tween and assume its duration; replace those assertions while retaining effect-tween tests.

## API References

- https://docs.godotengine.org/en/4.4/classes/class_control.html — clip_contents clips child rendering to the control rectangle; ignored mouse filters preserve board routing.
- https://docs.godotengine.org/en/4.4/classes/class_node.html — processing and tree pause; reparent coordinates must be assigned explicitly for Control children.
- https://docs.godotengine.org/en/4.4/classes/class_curve2d.html — cached distance sampling would introduce unnecessary approximation here.

These official APIs and repository inspection support the design; actual renderer clipping and pointer eligibility still need integrated/rendered verification. No unresolved research questions. No research-agent dispatch was needed because the earlier repository research already resolved technology choices and no unknown was left to delegate.
