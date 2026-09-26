# Presentation Interfaces and Invariants

Root: `C:/GitHub/MakeBoldSolutions/ArrowGame`. Internal UI contract; no external API or new domain interface.

## ArrowView

Retain `set_shape(head_offset, cell_offsets, direction)`, `set_cell_extent(extent)`, `play_blocked_feedback()`, `play_exit_animation(travel_distance)`, and `exit_finished`.

Add `set_hovered(hovered: bool)` for eligibility. It is idempotent, never changes rules, and ignores requests after departure. Every color setter updates both body and head. Body/head are passive Node2D children; parent Control retains MOUSE_FILTER_IGNORE. set_shape preserves path order and does not retain writable references to domain arrays.

`play_blocked_feedback`: ignore if departing; cancel live hover/effect writers, reset scale, show red, pulse within 1.08–1.12 (default 1.10) for 0.15 seconds. Completion restores ONE and immediate eligible hover or ink. Repeat restarts without stacking and without locking input.

`play_exit_animation`: repeated invocation cannot start a second exit. First invocation sets departing, kills both handles, restores ONE/ink/ordinary modulation and transient state synchronously, then translates the parent along head direction for 0.25 seconds. Logical removal is already complete before invocation. No late hover/block callback may alter this view. Emit exit_finished exactly once.

## PuzzleBoard and controller

Retain `cell_clicked(cell: Vector2i)` and `departure_finished`. Clicks remain discrete primary-button presses mapped by the existing cell function; release/held-repeat must not add selections.

Add `hover_cell_changed(cell: Vector2i)` with negative sentinel for no eligible cell. Controller handles this using PuzzleState.get_arrow_head only, then calls `set_hovered_head(head: Variant)` where null clears the highlight. Board verifies the view still exists and deduplicates by head. It must not call is_blocked/select_arrow for hover or infer ownership from visual geometry.

Provide a board hover-clear/refresh path used by setup, pointer/window exit/focus loss, pause/resume, results, and resizing. Stationary-pointer refresh must respect actual GUI eligibility; an overlay cannot leave hover active underneath it. Removing a highlighted head clears it synchronously even without pointer movement.

Before exit starts, remove the head from active views and connect its completion. Clear highlights for that head, forward one completion, then dispose. Active resize relayout excludes departing views as before. No change to pending departure accounting or result timing.

## Styling and scene boundaries

GameVisualStyle provides named semantic values/font roles and a reusable Theme factory. Block/exit timing remains sourced from PuzzleFeedback. No rule/solver dependency on UI resources. Normal arrows are ink, hover ember, blocked red; only completion uses success green in this iteration.

Theme attaches to Layout and PuzzleResults, not project defaults or ArrowPuzzle root. Board background ignores input. Preserve node unique names consumed by controller/tests, results full-rect input absorption, Replay focus, metric texts/arithmetic, and existing actions. No new audio, settings, or progression writes.

## Verification contract

Keep `PUZZLE_FAILURES=0`, `PUZZLE_LAYOUT_FAILURES=0`, `REGRESSION_FAILURES=0` expectations. Add `PUZZLE_PRESENTATION_FAILURES=0` for the new scene suite; exit zero plus marker are both required. Launcher prepares imports for real scene/font resources under isolated APPDATA/XDG_DATA_HOME, with bounded subprocess timeout and captured diagnostics. Do not modify pure-domain expected outcomes.

Tests must cover consecutive-only points, cardinal head orientation, in-cell single-cell shape, resize, owner-wide hover with unchanged counters, actual GUI event mapping, pulse replacement and precedence, normalized immediate departure at several interruption phases, stale-request rejection, and single completion. Rendered smoke verifies visual seams/negative space/fonts and physical input; headless results do not replace it.
