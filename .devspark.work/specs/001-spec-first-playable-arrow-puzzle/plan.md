# Implementation Plan: First Playable Arrow Puzzle

**Branch**: `001-spec-first-playable-arrow-puzzle` | **Date**: 2026-09-26 | **Spec**: [spec.md](spec.md)

## Rationale Summary

Deliver the complete session-only puzzle loop using project-level scenes and independently testable rules. Source inputs are the approved spec, constitution, save-progression knowledge, and the inspected starter scripts. A new puzzle scene reuses starter pause/options/music rather than modifying its sample level loader. Avoid new dependencies and addon changes. Review immediate inactivity, counting, replay isolation, and menu save side effects.

## Summary

Use a RefCounted puzzle state, a fixed board definition, a Control-based board and arrow views, and a results panel. Route both project main menus to the puzzle scene, hiding Continue and Level Select and keeping legacy level assets in source (spec Tradeoffs, FR-013). Preserve opening, SceneLoader, AppConfig, audio/video/input options, pause/restart/main-menu behavior and recovery. Do not attach LevelListStateManager or invoke level-won/lost progression for this puzzle.

## Technical Context

**Language/Version**: GDScript / Godot 4.4 project baseline; Python 3 for test launchers.
**Primary Dependencies**: Existing Maaack's Game Template; no added packages.
**Storage**: In-memory puzzle attempts; existing save/settings formats unchanged.
**Testing**: Headless GDScript rule regression suite, existing isolated persistence/input suite, Godot scene validation, desktop smoke tests.
**Target Platform**: Desktop, primary mouse input; existing keyboard/gamepad menus.
**Project Type**: Desktop game.
**Performance Goals**: Responsive per-click updates and nonblocking tweens; no invented frame-rate budget.
**Constraints**: One authored board; no progression, puzzle persistence, online services, mobile work or failure mechanism.
**Scale/Scope**: One 5-column by 4-row board containing eight arrows.

Godot executables are available on PATH; implementation must record the actual version used and distinguish it from the 4.4 project baseline. No runtime validation has been performed during planning.

## Constitution Check

| Principle | Pre-design | Post-design evidence |
|---|---|---|
| I Simple code | Pass | Focused snake_case scripts/functions; typed coordinates and counters. |
| II Project-level customization | Pass | New project scenes; project menu edits only; no addon modifications. |
| III Controls | Pass | Keep InputMap/remapping; preserve menu focus, pause/options and keyboard/gamepad activation; test affected paths. |
| IV Responsiveness | Pass | O(N) scan of eight active arrows per selection; scene-bound tweens; no blocking frame work. |
| V Verification | Pass | Tasks require Godot validation, rule regressions, desktop smoke and recorded evidence. |
| VI Saved data | Pass | Remove reset/start-game side effects from puzzle entry; preserve schemas, recovery and existing data. |

No waivers or unresolved violations. Passing the design gate does not assert runtime checks have passed.

## Context Resolution

```yaml
context_resolved:
  - id: arrowgame-constitution
    path: .knowledge/governance/constitution.md
    via: "appliesTo match: scripts/**, scenes/**"
    hop: 1
  - id: save-progression
    path: .knowledge/architecture/save-progression.md
    via: "source-call: scenes/menus/main_menu/main_menu_with_animations.gd -> GameState.start_game / GlobalState.reset (scripts/game_state.gd, addons/.../global_state.gd are in its appliesTo)"
    hop: 2
```

Inspected .knowledge/index.json and ontology/coverage.json: two current nodes, no edges or entities. `via` values therefore describe appliesTo or source-call traversal, not ontology relations. Traversal stops after the related save/input node; no additional relevant decisions exist. Source inspection confirms animated New Game calls GlobalState.reset(), load_game_scene calls GameState.start_game(), and existing gameplay uses LevelListStateManager. These paths must be bypassed for the puzzle. Create a current architecture node for puzzle behavior, and update save-progression to distinguish preserved legacy storage from session-only puzzle entry, extending its appliesTo to include scenes/menus/main_menu/main_menu.tscn and main_menu_with_animations.gd since the source-call resolution above depends on those files. Rebuild the knowledge index using repository tooling after those updates. Guard the no-reset behavior with an automated test (not only manual smoke) so a future template refresh that reintroduces GlobalState.reset()/GameState.start_game() on Play fails a regression suite.

## Project Structure

Repository root: `C:/GitHub/MakeBoldSolutions/ArrowGame`. All paths below are relative to this absolute root.

- scripts/puzzle/puzzle_definition.gd: fixed dimensions, direction enum and initial arrow data.
- scripts/puzzle/puzzle_state.gd: RefCounted rule/state authority.
- scenes/puzzle/arrow_puzzle.tscn and arrow_puzzle.gd: session controller, HUD, pause controller/music and results lifecycle.
- scenes/puzzle/puzzle_board.gd: board layout, click-to-cell mapping and arrow views.
- scenes/puzzle/arrow_view.gd: draws directional arrow and plays feedback/exit tweens; no rules.
- scenes/puzzle/puzzle_results.tscn and puzzle_results.gd: result labels, Replay and Main Menu buttons with focus.
- scenes/menus/main_menu/main_menu.tscn and main_menu_with_animations.tscn: game_scene_path points to new puzzle scene.
- scenes/menus/main_menu/main_menu_with_animations.gd: remove reset/start-game calls from entry, hide legacy Continue/Level Select, preserve animation/options/credits.
- tests/puzzle_regression.gd and run_puzzle_regressions.py: isolated core tests.
- tests/README.md: verification commands and smoke coverage.
- .knowledge/architecture/arrow-puzzle.md: new current behavior owner.
- .knowledge/architecture/save-progression.md and .knowledge/index.json: integration boundary and discoverability.

Retain existing game_ui.tscn, sample levels and progression scripts; they are not the active Play destination. Leave project.godot startup/autoloads/input mappings unchanged unless validation establishes a concrete need.

## Integration Design

The board receives primary mouse presses through GUI input and converts local coordinates to a grid cell; empty or inactive cells return ignored. A held mouse button does not repeat. The controller calls select_arrow(cell) once and immediately updates counters from state. Visual children ignore mouse events so a departing graphic cannot intercept another active cell. Core state alone decides blocking.

Render simple directional arrows with drawing primitives, avoiding font-glyph dependencies. Use a centered board that scales to available Control area, with margins for HUD, laid out through anchors/containers so the HUD and board rects cannot overlap by construction; assert this at 1280x720 and 960x540 with a script-level rect check rather than relying only on manual resize smoke testing (FR-007). Convert clicks in board-local coordinates and verify resized windows. Exit tweens move beyond the board edge along direction; blocked feedback pulses scale/outline without changing logical coordinates. Initial durations: 0.25 seconds exit, 0.15 seconds blocked cue, held as a named constant and asserted by a headless test against the FR-005 0.3-second cap rather than judged only by eye; the blocked cue may still be tuned after smoke testing but must stay at or below that cap. New feedback replaces existing feedback on the same view; no input lock.

Track all active exit tweens. After the state completes, show results only after all departures finish (not just the most recently selected arrow). Pause suspends board input and animations through inherited process mode; the existing pause menu remains usable. Results take focus and consume background input; prevent duplicate pause overlays while results are open. Replay kills old tweens, clears views/results, creates fresh state and increments a generation token so stale callbacks cannot affect the next attempt. Main Menu uses SceneLoader. Pause Restart reloads the current puzzle scene through the existing confirmation action.

## Artifacts and Delivery

Research: research.md. Data: data-model.md. Interfaces: contracts/puzzle.md. Validation: quickstart.md. Tasks are generated separately after this plan. Required review gates remain checklist, analyze and critic; requirements checklist passes, analyze/critic have not run. Runtime validation is outstanding until implementation.

Keep this planning bundle under .devspark.work until release archival. The shared preamble's retention rule takes precedence over the tasks command's stale instruction to delete FEATURE_DIR; no deletion task will be generated. Durable outputs must not reference planning identifiers.

## Implementation Notes

- 2026-09-26 (T017): Replay and the pause-menu Restart both call `SceneLoader.reload_current_scene()` instead of the generation-token/manual-tween-kill approach originally described above under Integration Design. Reloading the scene reconstructs `PuzzleState`, all `ArrowView` nodes and tweens from scratch on `_ready()`, which trivially guarantees no stale callback or pending tween from the finished attempt can affect the next one — the same guarantee the generation-token design was for, achieved with less code and no manual bookkeeping. Confirmed cancelled Restart and Replay-then-second-run behavior in tests/puzzle_regression.gd's fresh-state assertions and the desktop smoke pass (gates/verification.md).

## Agent Context Update

The Codex context update script completed successfully. Its installed template lookup initially failed; a temporary copy of the stock template at its expected work path allowed execution, and that copied file was removed afterward. Existing AGENTS.md content was preserved; no new technology context was needed.
