---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
devspark_version: "undetermined"
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Implementation Plan: ArrowSpark Progression Pack

**Branch**: `013-spec-progression-pack` | **Date**: 2026-10-13 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/.devspark.work/specs/013-spec-progression-pack/spec.md`

## Rationale Summary

### Core Problem

Two things stand between the showcase and "comfortable sending people to": (1) the camera is clamped to the board, so a corner or edge can never be centered when zoomed in, and (2) the catalog jumps from tutorial puzzles to the 115-arrow Reference Knot.

### Decision Summary

Ship the camera fix first as a small, isolated change to the presentation transform (clamp the camera center to the board rectangle instead of clamping the viewport edge), then add about eight hand-authored levels as literal catalog data proven by the existing solver. No rules, scoring, persistence or site contract changes.

### Key Drivers

- Corner centering must work at every zoom beyond Fit, on desktop and touch, without changing how Fit looks.
- Departing arrows currently slide off the board edge and are clipped there; once empty world is visible around the board that clip would show as arrows vanishing at an invisible line.
- Levels are content: validity comes from the existing solver, feel comes from the designer's play.
- Constitution Principle V: Godot validation, desktop smoke test, browser smoke test, and a real phone for the mobile beta; unchecked items are disclosed, not claimed.

### Source Inputs

- [spec.md](spec.md) (User Story 1 camera/world, User Story 2 progression, FR-001 to FR-022, SC-001 to SC-011).
- Existing code: `scripts/presentation/puzzle_viewport_transform.gd`, `scenes/puzzle/puzzle_board.gd`, `scripts/presentation/arrow_departure_geometry.gd`, `scenes/puzzle/arrow_view.gd`, `scripts/puzzle/puzzle_feedback.gd`, `scripts/puzzle/puzzle_catalog.gd`, `scenes/menus/main_menu/main_menu_with_animations.gd`.
- Existing checks: `tests/puzzle_viewport_transform_check.gd`, `tests/puzzle_canvas_check.gd`, `tests/puzzle_catalog_check.gd`, `tests/puzzle_analyzer_check.gd`, `tests/arrow_departure_geometry_check.gd`, `tests/puzzle_structural_report.gd`.

### Tradeoffs Considered

- Explicit padded world rectangle (a fixed or viewport-proportional buffer, with the clamp at the world edge): rejected. The buffer would have to depend on viewport size and zoom, and a corner could still miss the center. Clamping the camera center to the board rectangle is exact: every board point, including corners, is reachable, and the visible "world" is whatever the viewport shows beyond the edge.
- Recenter button or minimap: rejected in the spec; leaves the clamp in place.
- Leave the departure clip at the board edge: rejected as the default because arrows would be cut off in plain sight; kept as the documented fallback if the owner prefers the old look.
- Generate levels: out of scope per the spec.
- Selected: center clamp to the board rectangle; unclipped departures with a longer fixed exit margin; literal-data levels.

### Architectural Impact

- `PuzzleViewportTransform`: `_clamped_center` changes; no new state, API or signals.
- `PuzzleBoard`: `DepartureClip` no longer clips; `reveal_cell` and every input path are unchanged because all go through the transform.
- `PuzzleFeedback.EXIT_CLEARANCE_MARGIN_CELLS` grows so a departing arrow is fully out of sight of any reachable view (see research R-02).
- `PuzzleCatalog` gains about eight entries in `arrowspark_levels` before `reference_knot`; the main-menu Play action points at the first.
- Content-version ids are derived from geometry, so existing puzzles keep theirs and new ones get their own automatically.

### Reviewer Guidance

Review the camera change by panning each corner to the middle on a small and a large puzzle, then by wheel- and pinch-zooming near an edge. Review levels by playing them and reading the per-level notes; do not review for metric conformance.

## Summary

Two independent deliverables on one branch, built camera first. Part A (Story 1) is a pure-math change to the view transform plus an exit-margin change so departures read correctly in the visible world, with the two checks that encode the old clamp rewritten. Part B (Story 2) authors, proves, catalogs and documents about eight levels, repoints Play, updates catalog tests and durable knowledge, and records a design-learning note.

## Technical Context

**Language/Version**: GDScript, Godot 4.4; Python 3.11+ regression launchers
**Primary Dependencies**: Maaack's Game Template addon (untouched); no new dependencies
**Storage**: N/A (camera is transient; no persistence)
**Testing**: `python tests/run_puzzle_regressions.py --godot <exe>` and `python tests/run_regressions.py --godot <exe>`; Godot `--headless --editor --quit`; desktop smoke; browser smoke; one real Android phone
**Target Platform**: Godot desktop and Godot Web export (no threads), mobile web beta on the showcase Play page
**Project Type**: Game with a static showcase site (the site is not changed)
**Performance Goals**: No change; clamp is O(1) arithmetic. The longer exit margin lengthens departures slightly (see Risks).
**Constraints**: Rules core stays scene-independent; camera state never serialized; Fit view unchanged; ids of existing puzzles unchanged
**Scale/Scope**: One small transform change, one constant, one clip flag, about eight new catalog entries, test and knowledge updates

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Assessment |
|---|---|
| I. Simple, maintainable code | PASS. No new classes or abstractions; snake_case for any new function or file. |
| II. Project-level customization | PASS. Changes live in project scripts and scenes; no addon edit. |
| III. Accessible, configurable controls | PASS. No input mapping changes. Keyboard/gamepad pan and focused zoom are verified to obey the new bounds. |
| IV. Responsive gameplay | PASS. Constant-time math; no frame-loop work added. |
| V. Practical verification | PLANNED. Godot validation, both regression gates, desktop smoke (including menu, replay, next, Play), browser smoke, real phone; limits disclosed. |
| VI. Preserve saved progress/settings | PASS. No saved data touched; camera never serialized. |

Post-design re-check: unchanged, PASS. No waivers needed.

## Context Resolution

```yaml
context_resolved:
  - id: arrow-puzzle
    kind: knowledge
    via: direct (lexical: viewport transform, canvas navigation, catalog)
    hop: 0
    reason: Canonical description of the transform clamp, departures, catalog, and the checks that gate them; must be updated in place.
  - id: touch-gestures
    kind: knowledge
    via: direct (lexical: pinch, pan, anchor)
    hop: 0
    reason: Pinch/pan behavior relies on the transform; anchor stability and device-verification notes apply.
  - id: reference-puzzle-design-report
    kind: knowledge
    via: direct (lexical: Reference Knot, design principles)
    hop: 0
    reason: Source of the level-design principles and the Reference Knot facts the progression ramps toward.
  - id: web-showcase
    kind: knowledge
    via: direct (lexical: Play page, mobile beta, Reference Knot mentions)
    hop: 0
    reason: Describes the Play page and beta evidence; may need a line about the new levels and navigation; site contracts themselves do not change.
  - id: arrowgame-constitution
    kind: knowledge
    via: governance (appliesTo scripts/**, scenes/**)
    hop: 0
    reason: Principle V verification and recording requirements bind this work.
```

Projection from the three lexical seeds returned no hop-1 or hop-2 candidates; `game-visual-system` (departure visuals) was dropped because `arrow-puzzle` already holds the departure contract.

## Project Structure

### Documentation (this feature)

```text
.devspark.work/specs/013-spec-progression-pack/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── camera-bounds.md
├── checklists/requirements.md
├── gates/
└── tasks.md             # created by /devspark.tasks
```

### Source Code (repository root)

```text
scripts/presentation/puzzle_viewport_transform.gd   # Part A: center clamp to board rect
scenes/puzzle/puzzle_board.gd                       # Part A: DepartureClip no longer clips
scripts/puzzle/puzzle_feedback.gd                   # Part A: exit margin constant
scripts/puzzle/puzzle_catalog.gd                    # Part B: new levels, group order
scenes/menus/main_menu/main_menu_with_animations.gd # Part B: Play starts the first level
tests/puzzle_viewport_transform_check.gd            # Part A: replace clamp assertions, add corner/anchor checks
tests/puzzle_canvas_check.gd                        # Part A: corner reachability to center, departure clip assertions
tests/arrow_departure_geometry_check.gd             # Part A: margin-dependent expectations
tests/puzzle_catalog_check.gd                       # Part B: counts, group sizes, positions, Play target
tests/puzzle_analyzer_check.gd                      # Part B: new levels analyze valid and solvable
.knowledge/architecture/arrow-puzzle.md             # both parts: clamp, departure, catalog, Play
.knowledge/reference/                               # Part B: design-learning record (observed / judged / open)
web/                                                # evidence/story copy only if it states the level count; no code
```

**Structure Decision**: single-project Godot layout as already present; no new directories except the design-learning document under `.knowledge/reference/`.

## Risks and Open Items

| Risk | Handling |
|---|---|
| Departing arrows vanish at the board edge in plain view | Unclipped departures plus longer fixed exit margin (R-02). Owner eyeballs it in the desktop smoke; fallback is the old clip. |
| Longer exit margin lengthens the last departure before Results (10 cells/s) | Choose the smallest margin that clears the visible view at the supported zoom range; measure; disclose the added seconds. |
| Pinch near edges previously drifted because of the clamp | New clamp is wider; verify anchor error under one pixel (SC-010) headless, then on the real phone. |
| Hand-authoring dense levels is slow | Time-box per level, drop weak levels (spec edge cases allow six); record cost in the learning note. |
| Solver time on larger levels may exceed the headless limit | Existing sampled-check precedent (`SAMPLED_BRANCH_ENTRY`) applies; record it. |
| iPhone and untested browsers | Not claimed (Principle V). |

## Complexity Tracking

No constitution violations; section intentionally empty.
