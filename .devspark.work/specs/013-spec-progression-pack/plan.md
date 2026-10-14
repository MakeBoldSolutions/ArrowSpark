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

Ship the camera fix first (the departure presentation change is confirmed in scope by the owner as FR-023) as a small, isolated change to the presentation transform (clamp the camera center to the board rectangle instead of clamping the viewport edge), then add about eight hand-authored levels as literal catalog data proven by the existing solver. No rules, scoring, persistence or site contract changes.

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


## Implementation Notes

- 2026-10-14, camera (T004): the clamp limits the camera center to the board rectangle above the Fit scale and locks it to the board center at Fit. Because of that bound, zoom keeps the point under the pointer fixed only while the center bound does not bind. The case that does bind is zooming out with the pointer on the board side while a corner is at the center; there the view settles at the corner instead of holding the point. The transform check measures the in-bounds case (worst drift well under one pixel). This narrows FR-021's "no drift introduced by clamping"; classified Accepted Limitation.
- 2026-10-14, departures (T007, T008): the clip is off and `EXIT_CLEARANCE_MARGIN_CELLS` is 6.0. The value is provisional until the owner's desktop smoke measures the added time before Results and judges whether removal is hidden (SC-012).
- 2026-10-14, tests (T009): `tests/puzzle_presentation_check.gd` also assumed a 0.6 s departure; its completion budget now derives from the view's finish distance. `puzzle_layout_check.gd` and the canvas timing budget needed no change.
- 2026-10-14, catalog (T016 to T023): the eight builders share a new `_from_shapes` helper in `puzzle_catalog.gd` instead of repeating the Reference Knot's literal loop; the Reference Knot builder is untouched.
- 2026-10-14, authoring: levels were found with a throwaway offline search (not committed) that places arrows in reverse solve order, with center-outward layering for the two dense levels; the game's solver confirmed all eight. The exact search parameters are recorded as observations in the design-learning record, not as code.
- 2026-10-14, engine: the first runs used Godot 4.7.2 (editor validation on a project copy, to avoid rewriting the repository's `.godot` cache). The pinned Godot 4.4-stable was then downloaded from the official release (SHA-512 verified) and both gates were re-run from a clean copy of the repository: all nine puzzle-gate markers 0 and `REGRESSION_FAILURES=0` on 4.4.

## Verification Record

2026-10-14, automated browser run (headless Chrome driving the real Godot 4.4 Web export, served by the site's dev server as build `local`). Not a substitute for the owner's own desktop and phone checks.

- Admission: at 1600 x 1150 with a fine pointer the Play page admits the game (`data-play="play"`); Godot 4.4 boots with WebGL 2; no console errors in any run.
- Play: New Game starts "1. First Knot" (9 arrows).
- Camera: with the First Knot zoomed in and held keys panning, the board's top-left corner reached the center of the board area, and the bottom-right corner likewise (arrows lie only in the opposite quadrant). Fit unchanged at start.
- Departures: with the board's right edge at the screen center, an exiting arrow was not cut at the edge; at about 0.6 s its head was far past the edge, and at about 1.1 s its tail was still leaving the screen.
- Full play-through: all nine ArrowSpark levels were played to Results by clicking arrows in solver order, each with 0 mistakes and 100% accuracy, including the 93-arrow Almost a Knot and the 115-arrow Reference Knot (session total 384 = 9+15+14+17+23+30+68+93+115). Next Puzzle moved from level 1 through to level 9; the Reference Knot offers Level Select instead of Next. Back from a level reached Level Select, which lists the group ending "8. Almost a Knot", "9. Reference Knot".
- Time from the last click to the Results screen (includes the departure and the harness's own polling): 1.1 to 3.1 s across the nine levels (1.07, 2.06, 1.37, 2.1, 2.36, 2.06, 2.62, 1.18, 3.07). The margin adds about 0.6 s per departure by calculation (6 cells at 10 cells per second); it was not measured against the old margin.

Owner confirmation (2026-10-14, own desktop play on the same build): gameplay is good, mouse wheel zoom works and middle-button drag works; the camera behavior wanted from the navigation story is as intended. The 6-cell departure margin was not objected to.

Not run, and still the owner's to do:
- Pan-mode left-drag was not tried by the owner; headless synthetic drags did not move the view, so the automated run covered only keyboard and button navigation.
- Gamepad input, keyboard activation of Play and Level Select, Open Move at an edge, pause menu, Replay.
- Other browsers (Edge launch failed under automation; Firefox not tried) and the real Android phone.
- The designer's own play of the levels and the judgment on the departure margin and the step to the Reference Knot.
- Levels 2 to 7 were played through but their screenshots were not examined beyond Results for the first, second and last levels.

Findings classification: Accepted Limitation: anchor drift when the camera-center bound binds (see the camera note); departure removal may still be visible at extreme zoom-out with the camera at an edge. Learning / Changed Assumption: the dependency, depth and fill measures of the last level differ markedly from the Reference Knot (see the design-learning record). Deferred Work: the owner's per-level play notes and the real-device checks above. No Blocking Defect found.

Owner phone and desktop report (2026-10-14, after playing all levels, phone reached over a self-signed HTTPS proxy on the local network):
- All levels played; game play, difficulty of the new boards and the progression were judged good. Pinch zoom and one-finger drag worked without issue.
- Finding (Deferred Work, outside this work's scope: no UI redesign or touch-target work): the menus between levels (Results and the other menus) are very small and hard to read on the phone, especially in fullscreen.
- Finding (Deferred Work): the Play page's admission rule measures the visible page area, so on a phone in landscape with the browser's address bar showing, the viewport can be under 320 px high and the page says the screen is too small until the bar is hidden. Plain HTTP over the local network fails Godot's secure-context check; this affects only local testing.
- Not recorded: phone model, Android version, browser.

Owner device and desktop record (2026-10-14): phone was a Google Pixel 7 Pro in Chrome (Android version and Chrome version not recorded this time). Desktop: keyboard menu navigation works, Replay works and mouse play works (desktop browser not recorded; wheel zoom and middle-drag were confirmed earlier). Not exercised: gamepad, pause menu, Open Move at an edge, any browser other than Chrome, iPhone.

Desktop browsers (owner, 2026-10-14): the game and the navigation worked in Chrome, Firefox, the VS Code internal browser and Perplexity's browser. Versions were not recorded. Not tested: Safari, Edge (the automated Edge launch failed), any mobile browser other than Chrome on Android, iPhone.
