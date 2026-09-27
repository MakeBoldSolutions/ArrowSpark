# Implementation Plan: Path-Following Arrow Departure

**Branch**: `004-spec-path-following-departure` | **Date**: 2026-09-26 | **Spec**: [spec.md](spec.md)
**Repository root**: C:/GitHub/MakeBoldSolutions/ArrowGame
**Feature directory**: C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/004-spec-path-following-departure

## Rationale Summary

### Core Problem
Rigid translation ignores bends; removal from the active-view dictionary also excludes departing views from resize layout.

### Decision Summary
Use a pure cell-unit polyline helper and ArrowView-owned scalar progress. Render a moving constant-length interval into the existing Line2D/Polygon2D. Move departing views into a passive grid-sized clipping container, track them separately, and retain controller counting.

### Key Drivers
Preserve domain behavior, deterministic geometry, visible bend traversal, pause, resizing, and full-tail completion.

### Source Inputs
The authoritative spec and source-brief; inspected ArrowView, PuzzleBoard, controller, domain validation, existing regression launchers, and resolved current knowledge below. See research.md for decisions and official API references.

### Tradeoffs Considered
Exact polyline interval extraction avoids baking and unnecessary follower nodes. Per-frame scalar advancement avoids rebuilding a duration tween when layout becomes invalid. A departure-only clipping layer preserves active feedback bounds. No domain change, persistence migration, addon edit, or new package is needed.

### Architectural Impact
One pure presentation helper and a small amount of view/board lifecycle state. Controller selection and pending-count semantics remain intact. Test assumptions about a fixed 250ms position tween must change to geometry and clearance assertions.

### Reviewer Guidance
Check corner retention, zero-distance silhouette, tail-cap clearance, passive clipping input, pause/zero-layout recovery, and exactly-once cleanup before results. Review no domain dependency on presentation.

## Summary
Preserve logical removal before motion. Advance d in cell units at 10 cells/second while processable and layout-valid; render P(d) through P(L+d-0.02), with head center P(L+d). Retain all interval vertices. Finish at L + E + 0.07 + 0.001 cells, where E is head-center distance to the forward grid edge. See contracts/presentation.md for derivation and guards.

## Technical Context

**Language/Version**: Godot 4.4 and GDScript; Python 3.11+ regression launchers.
**Primary Dependencies**: Existing Godot Line2D, Polygon2D, Control and Maaack's Game Template; no new dependencies.
**Storage**: Existing progress/settings untouched; new state is transient presentation only.
**Testing**: Pure geometry checks, existing rule/layout/presentation/save-input launchers, Godot import validation, rendered desktop smoke.
**Target Platform**: Desktop, including Windows development; mobile deployment excluded.
**Project Type**: Godot desktop puzzle game.
**Performance Goals**: Responsive input; O(n) interval extraction per departing arrow per frame, cumulative lengths built once; no new frame-rate target.
**Constraints**: Domain sources unchanged; 10 cells/second initially; no duration cap; occupied-grid clipping; no API/node additions for curves or followers.
**Scale/Scope**: One existing 5x4 eight-arrow board plus synthetic valid shape fixtures; support all valid ordered arrow shapes without imposing a new domain limit.

## Constitution Check

Pre-research and post-design: PASS, no waivers.

| Principle | Design and required verification |
|---|---|
| I Simple maintainable code | snake_case helper/functions, pure calculations, existing visual nodes |
| II Project-level customization | Modify project scripts/tests only; no addon edits planned |
| III Accessible controls | Passive clipping layer; preserve whole-cell input, keyboard/gamepad navigation and remaps; automated plus hardware-aware manual checks |
| IV Responsive gameplay | Atomic logical removal remains before effect; no await/input lock or blocking per-frame work |
| V Practical verification | Engine import, both launchers, geometry tests, desktop smoke including pause/restart/results and resize; unavailable checks stay open |
| VI Save/settings preservation | No writes or migrations introduced; isolated test roots and existing save/remap assertions retained |

This is a design compliance check, not a claim that implementation verification has run.

## Context Resolution

```yaml
context_resolved:
  - id: arrow-puzzle
    path: .knowledge/architecture/arrow-puzzle.md
    via: direct appliesTo scenes/puzzle and tests; domain/presentation boundary
    hop: 1
  - id: game-visual-system
    path: .knowledge/architecture/game-visual-system.md
    via: arrow-puzzle gameplay-theme source link -> visual geometry and precedence
    hop: 2
  - id: save-progression
    path: .knowledge/architecture/save-progression.md
    via: direct appliesTo tests/save_input_regression.gd; preserved input/save contract
    hop: 1
  - id: arrowgame-constitution
    path: .knowledge/governance/constitution.md
    via: direct governance appliesTo scripts/scenes/tests verification policy
    hop: 1
```

Index contains no relation edges or decision entities. Followed the relevant arrow-puzzle textual link to game-visual-system; traversal stops because no additional relevant node is discovered. Implementation consumes these paths directly. Update game-visual-system and arrow-puzzle during implementation, including helper/test appliesTo ownership; save-progression needs no rewrite if its contract remains unchanged.

## Project Structure

All paths below resolve against the absolute repository root above.

- scripts/presentation/arrow_departure_geometry.gd — new RefCounted pure helper.
- scripts/presentation/game_visual_style.gd — existing visual ratios, unchanged unless necessary.
- scripts/puzzle/puzzle_feedback.gd — replace exit-duration constant with centralized cell speed and clearance policy; retain blocked constants.
- scenes/puzzle/arrow_view.gd — progress, geometry rendering, terminal completion.
- scenes/puzzle/puzzle_board.gd — departure clip layer, departing dictionary, layout and cleanup.
- scenes/puzzle/arrow_puzzle.gd — preserve existing coordination; only minimal lifecycle guards if tests demonstrate need.
- tests/arrow_departure_geometry_check.gd — new pure geometry suite.
- tests/puzzle_presentation_check.gd and tests/puzzle_layout_check.gd — updated visual/lifecycle expectations.
- tests/run_puzzle_regressions.py — isolated helper suite, existing checks retained.
- tests/save_input_regression.gd and tests/run_regressions.py — preserve checks; extend only if changed lifecycle needs coverage.
- tests/README.md — reproducible commands and manual scope.
- .knowledge/architecture/game-visual-system.md and arrow-puzzle.md — durable current behavior after implementation.

Artifacts here: research.md, data-model.md, contracts/presentation.md, quickstart.md, tasks.md, checklists/requirements.md. Script-generated knowledge/ requirement records are temporary inside this bundle, not current .knowledge/ nodes.

## Implementation Design

### Pure route mathematics
Build a defensive copy in local cell units: reversed tail centers then head center; for a single cell use head minus 0.30 forward, then head. Deduplicate adjacent equal points only; never infer adjacency connections or simplify across corners. Prefix distances start at zero. Sample by cumulative segment distance; s >= L uses the forward ray. Extract interval endpoints plus original vertices strictly inside the interval, removing coincident consecutive output points. Geometry equality tolerance: 0.00001 cells, length tolerance 0.00001 * max(1,L) cells. Never use that tolerance to authorize early completion.

### Arrow rendering and progress
At d=0, the body matches existing points (do not append the original head center beyond the body endpoint). Preserve rounded joints/caps and head overlap. Rebuild body and polygon using current extent at each progress update; do not move view.position to animate. Keep the existing effect-normalization boundary; cancel both prior tweens and disable their further writes. Enable _process only for departures; advance through one advance_departure(delta) path, used by _process and deterministic tests. Clamp nonnegative progress to finish distance, render before finishing, guard completion once. Pause inherited from the tree prevents stepping. The method also guards paused tree, finished state, invalid extent, and invalid/nonpositive delta so test calls cannot bypass lifecycle policy. Zero extent suspends progress and completion until valid layout returns; this exceptional interval does not count as active animation time.

### Board layout and clipping
Create a child Control DepartureClip with clip_contents=true and mouse_filter=IGNORE. Position it at _origin and size it to grid dimensions times extent; keep active ArrowViews as board children to avoid clipping scale feedback. On removal erase active dictionary entry, reparent the view to DepartureClip and assign explicit local position bbox_min*extent after normalization, preserving d=0 appearance. Track departing entries by original head for bbox information. Never route selection/hover through that collection. Both active and departing layouts rebuild from the same board cell extent; resize passes extent and finish distance to departing views without restarting progress. All decorative descendants ignore input, keeping gui_get_hovered_control()==board behavior intact. Overlay tests must exercise this.

### Completion and disposal
Board connects one-shot completion before starting; callback verifies tracked instance, erases departing entry, queues view for deletion, and emits departure_finished once. Controller decrements existing pending count and shows results only after logical completion and all departures finish. Different lengths naturally finish out of order. Board setup disconnects/cancels and frees both collections before replacement; ArrowView cancellation stops processing/tweens without emitting completion. Scene destruction relies on child destruction plus explicit cancellation for reuse. No queued completion is allowed to modify a replaced attempt. Results/replay behavior remains unchanged.

### Clearance and resize
Grid units make E independent of pixel extent: right W-(head.x+0.5), left head.x+0.5, down H-(head.y+0.5), up head.y+0.5. At finish the whole interval has reached the forward ray. The rear-most current geometry is the tail cap, 0.07 cells behind the tail center; the single-cell head base is still ahead of it. Therefore L+E+0.071 suffices for the current ratios. Validate this assumption against body/head support bounds so style changes cannot silently invalidate it. The clipped AA footprint cannot spill beyond the container. Recompute threshold when layout is updated; do not emit completion inside layout or while paused. At zero extent suspend; next process step after recovery can finish if already at threshold.

## Delivery and Verification

US1 provides geometry/motion/clipping preview; US2 proves domain isolation and concurrency; US3 adds resize/pause/cancellation robustness. All three plus final verification are needed for release. Follow quickstart.md. No new implementation tests were run during planning. Required analyze/critic gates follow task generation and are not fabricated here. Keep the complete bundle until /devspark.release; the shared preamble retention rule overrides older deletion wording in the task template.

Agent-context script ran successfully for codex. Its generated duplicate technology bullets and temporary feature identifiers were removed from AGENTS.md: no new technology was introduced, and durable context must not gain planning backlinks. Existing manual instructions remain intact.
