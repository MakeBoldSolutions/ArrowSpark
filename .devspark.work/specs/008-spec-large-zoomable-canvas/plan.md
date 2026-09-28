# Implementation Plan: Large Zoomable Puzzle Canvas

**Branch**: `008-spec-large-zoomable-canvas` | **Date**: 2026-09-28 | **Spec**: [spec.md](spec.md)
**Input**: C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/008-spec-large-zoomable-canvas/spec.md
**Route**: full-spec / high risk / specify-full. Required gates: checklist, analyze, critic, verify:end-to-end.

## Rationale Summary

### Core Problem

PuzzleBoard currently derives every arrow's pixel extent from available screen area. Input assumes that fit transform; departures already retain independent cell-unit routes.

### Decision Summary

Keep the GUI board fixed and clipped, add one transformed passive World child, and put all active/departing visuals under it at a fixed 64-pixel canonical cell extent. A pure presentation transform helper owns fitting, bounded navigation and coordinate conversion. Rules and scoring stay unchanged.

### Key Drivers

Usable large geometry, safe pan versus selection, accessible configurable controls, predictable off-screen assistance, and intact departure/result/session invariants.

### Source Inputs

[Research](research.md), current spec, five pinned knowledge documents below, current board/view/controller/scene/input settings and regression launchers. Official Godot 4.4 references and engine-version evidence are recorded in research.md.

### Tradeoffs Considered

A parent transform avoids repeated geometry rebuilds without introducing Camera2D, a SubViewport or rendering indexes. Middle drag and explicit Pan mode preserve existing Select-mode left-press behavior. Minimal head reveal preserves working scale rather than fitting an entire long arrow.

### Architectural Impact

Add one pure presentation helper, a passive World layer and a toolbar; reuse the board and controller. Add one authored catalog validation entry and focused tests. No new package, addon edit, rule dependency, camera persistence, generator or engine upgrade.

### Reviewer Guidance

Check inverse mapping, focus/input cancellation, head reveal at board edges, zero-area suspension, world versus viewport clipping, and old tests' assumptions about pixel geometry. Numerical defaults and formulas are in research.md and the interaction contract.

## Summary

Implement bounded zoom [fit scale, max(192, fit scale)] in pixels per cell, 1.2x steps, 16-pixel fit margins, and a 64-pixel working scale. Manual views retain focal center/scale on resize; fit views refit. Mouse zoom anchors at pointer; buttons and focused keyboard/gamepad actions anchor at center. Pan is middle drag or primary drag in explicit Pan mode, plus focused WASD/left-stick movement. Open Move reveals a padded target head at a minimum 48-pixel cell scale before its existing pulse.

## Technical Context

**Language/Version**: GDScript (Godot 4.4 target); Python 3.11+ test launchers.
**Primary Dependencies**: Existing Godot Control/CanvasItem and Maaack's Game Template; no new dependency.
**Storage**: N/A
**Testing**: Isolated headless rule/geometry/scene suites, new pure-transform and canvas interaction checks, saved-input regressions, rendered desktop smoke and measured navigation capture.
**Target Platform**: Desktop; primary validation workstation Windows. Godot on PATH currently reports 4.7.2; a Godot 4.4 executable is a precondition (tasks T001); 4.7.2 runs are supplementary.
**Project Type**: Godot desktop puzzle game.
**Performance Goals**: Warm 10-second large-fixture capture: handler p95 <=2 ms, frame p95 <=33.3 ms, no navigation-attributable stall >=100 ms; recorded machine/build only.
**Constraints**: Presentation-only camera state; configurable input preserved; no whole-board reconstruction per navigation event; immediate logical removal and asynchronous full-board departure clearance.
**Scale/Scope**: Existing fourteen entries plus one 40x30/12-arrow validation entry; 960x540, 1280x720, 800x800, 1920x1080 windows. No arbitrary-size guarantee.

## Constitution Check

| Principle | Pre-research | Post-design resolution |
|---|---|---|
| I. Simple maintainable code | Pass | One focused RefCounted presentation helper; snake_case scripts/functions; explicit types where useful |
| II. Project-level customization | Pass | Project board/controller/scene/actions only; no addon modification planned |
| III. Accessible configurable controls | Pass | Focusable toolbar/board; keyboard/gamepad zoom, pan, fit; existing custom-action remap UI; input regression and real-device checks |
| IV. Responsive gameplay | Pass | Parent transform, no pan/zoom shape rebuilding, declared measurement scenario and budgets |
| V. Practical verification | Pass | Godot validation, both isolated suites, affected desktop/menu/pause/replay checks; outstanding hardware checks disclosed |
| VI. Preserve saves/settings | Pass | Camera fields never serialized; existing input configuration and corrupt-save recovery retained and tested |

No unresolved constitutional violations or waivers. This is design compliance, not runtime verification. Target-engine or hardware unavailability cannot be marked passed.

## Context Resolution

Lexical discovery matched appliesTo paths and gameplay constraints. Executed context-projection.ps1 with five --seed arguments and --max-hops 2 --json. Projection returned exactly the five direct candidates below, no unresolved seeds, no accepted neighbors at hop 1 or 2, and no truncation. All were evaluated and retained; no graph edge or deeper provenance is invented.

```yaml
context_resolved:
  - id: arrow-puzzle
    path: .knowledge/architecture/arrow-puzzle.md
    seed: arrow-puzzle
    via: lexical appliesTo match for board/controller/definition/catalog/tests
    hop: 0
  - id: game-visual-system
    path: .knowledge/architecture/game-visual-system.md
    seed: game-visual-system
    via: lexical appliesTo match for arrow view/departure/style
    hop: 0
  - id: gameplay-contract
    path: .knowledge/product/gameplay-contract.md
    seed: gameplay-contract
    via: lexical match for Open Move/scoring/session boundary
    hop: 0
  - id: save-progression
    path: .knowledge/architecture/save-progression.md
    seed: save-progression
    via: lexical match for settings/input restoration
    hop: 0
  - id: arrowgame-constitution
    path: .knowledge/governance/constitution.md
    seed: arrowgame-constitution
    via: lexical governance appliesTo match
    hop: 0
```

Implementation reads this working set directly. Update arrow-puzzle for transforms/input/reveal/catalog/test ownership; game-visual-system for fixed geometry/world projection; save-progression for additive action remapping and no viewport persistence. The gameplay product contract and constitution are preservation references, not planned rewrites.

## Project Structure

### Documentation

C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/008-spec-large-zoomable-canvas/: spec.md, checklists/requirements.md, plan.md, research.md, data-model.md, contracts/canvas-interaction.md, quickstart.md, tasks.md. Later verification evidence goes in gates/verify.md and evidence/. These remain temporary until release archival.

### Source Code

All paths below are relative to C:/GitHub/MakeBoldSolutions/ArrowGame:

```text
scripts/presentation/puzzle_viewport_transform.gd   new pure transform helper
scenes/puzzle/puzzle_board.gd                     World/clip/input/navigation/reveal
scenes/puzzle/arrow_view.gd                       explicit layout-validity guard
scenes/puzzle/arrow_puzzle.gd                     toolbar/attempt/results wiring
scenes/puzzle/arrow_puzzle.tscn                   separate toolbar, focus/help
project.godot                                   additive zoom/fit actions
scripts/puzzle/puzzle_catalog.gd                 append authored canvas_validation
scenes/menus/options_menu/input/                 inspect/test inherited remap UI
scripts/presentation/arrow_departure_geometry.gd preservation reference only
scripts/puzzle/{definition,state,solver,analyzer} existing authorities, unchanged
scripts/puzzle_scoreboard.gd                     unchanged session-score authority
tests/puzzle_viewport_transform_check.gd         new isolated transform checks
tests/puzzle_canvas_check.gd                     new integrated event/scene checks
tests/puzzle_canvas_visual_check.gd              desktop fixture/measurement driver
tests/run_puzzle_regressions.py                  register isolated new suites
tests/puzzle_{layout,presentation,catalog,analyzer}_check.gd compatibility assertions
tests/save_input_regression.gd                   additive actions/storage preservation
.knowledge/architecture/{arrow-puzzle,game-visual-system,save-progression}.md
```

**Structure Decision**: Keep existing directories and dependency boundaries. The transform helper is presentation math, not a puzzle rule. Passive children are created by PuzzleBoard like its existing DepartureClip; no new scene wrapper is needed.

## Design and Integration Sequence

1. Add pure transform helper and independent numeric tests. Capture existing behavior/fixture expectations in isolated tests before modifying layout.
2. Introduce canonical World/DepartureClip hierarchy and shared projection. Keep board GUI target and all view ownership APIs. Update existing tests to project canonical geometry rather than assert resize rebuilds it.
3. Add safe mouse navigation, fit and toolbar; append the authored validation entry without changing prior content.
4. Add focused keyboard/gamepad actions and remap/focus tests; avoid global action polling over overlays.
5. Use the same inverse transform for hit/hover; reveal head before existing assistance highlight with no extra rule call.
6. Complete layout-validity, in-flight navigation/resize/replay checks, all regressions, desktop validation and measured performance. Update current knowledge in the same behavior changes.

The first story is a demonstrable canvas increment, not the full release: all four P1 stories and gates are required for release. Tasks are generated by the separately requested tasks command, not by plan setup.

## Validation and Workflow Boundaries

See quickstart.md for commands and actual desktop scenarios. No runtime tests have been run as part of this planning step. Required end-to-end gate remains pending until implementation evidence exists; it must never be labeled passed from design review. If framework pre-flight rejects implementation solely because future feature evidence cannot yet exist, report that workflow conflict and follow an explicitly approved staged execution; do not forge evidence or drop the gate.

The shared preamble's release-only archival rule overrides the tasks template's inconsistent deletion sentence: retain the completed bundle and populated linkage for /devspark.release. Agent-context script must run; remove only generated planning identifiers or duplicate/no-new-technology entries if it adds them to durable guidance. Preserve manual context.

## Agent Context Update

Ran update-agent-context.ps1 -AgentType codex successfully on 2026-09-28. It added a duplicate technology line carrying a planning branch identifier to AGENTS.md. Removed only that generated line to preserve the no-durable-planning-reference contract; existing manual guidance already describes all required technology and remains unchanged.

## Implementation Notes

- 2026-09-28 (T001/T029): Godot 4.4-stable was located at a temporary path and used as the target engine. Running 4.4 directly in the repository fails in the layout step with `SceneLoader` parse errors because the git-ignored `.godot/` cache was generated by 4.7.2; 4.4 runs therefore execute from a mirror of the repository copied without `.godot`, `.git`, `.devspark.work` and `.archive`. Not a product defect; recorded in evidence/baseline.md and evidence/regressions.md.
- 2026-09-28 (T006/T024): the minimal invalid-layout guard required by T006 needed the ArrowView validity flag itself, so `ArrowView.set_presentation_layout_valid` landed with T006; T024 then covered its propagation and tests (`_check_zero_area_pause_and_replacement`).
- 2026-09-28 (T015): focus navigation is never consumed by the board: Tab/Shift+Tab and D-pad buttons are excluded from the events the focused board consumes, whatever the `move_*` remapping, so focus can always leave the board (a movement action remapped onto those inputs also moves GUI focus). The toolbar's help label shares the toolbar row (wrapping beneath the buttons when narrow) and full binding detail lives in tooltips, to keep small-puzzle scale high at 960x540.
- 2026-09-28 (T030 pre-check, found while verifying the 15-entry menu): the appended fifteenth entry made the Level Select list (577 px) taller than a 960x540 window, clipping the first and last entries. `puzzle_select_menu.tscn` now wraps the list in a focus-following vertical `ScrollContainer`; the scene/script node names `PuzzleListContainer` are unchanged. Covered by `_check_level_select_reaches_every_entry_at_supported_windows`.
- 2026-09-28 (post-operator feedback): `canvas_validation` was re-authored as a 52-arrow, ~87%-filled board of mostly long bent arrows (same 40x30 size) at the operator's request; tests now derive departure heads from the solver witness. Blocked-arrow feedback was strengthened at the operator's request (brighter red `#E8221A`, 600 ms total cue with a 150 ms pulse, cap raised from 0.3 s to 0.75 s), a deliberate change to the earlier 0.3 s ceiling. The launcher's per-process timeout for real-project checks was raised from 90 s to 180 s.

