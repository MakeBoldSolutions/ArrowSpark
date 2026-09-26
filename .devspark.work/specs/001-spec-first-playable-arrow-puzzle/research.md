# Research: First Playable Arrow Puzzle

## Rule ownership

Decision: RefCounted state with integer grid coordinates, cardinal direction enum, active dictionary, counters and snapshot methods. Rationale: can run under a minimal SceneTree test without scenes/input. Alternatives: rules inside arrow nodes couple truth to animation; a new test framework adds unnecessary dependencies.

## Starter integration

Decision: new project puzzle scene using existing pause menu controller, project pause menu, music and SceneLoader; change both project main-menu scene destinations. Rationale: game_ui.tscn contains a level list loader/manager and sample win/loss paths outside scope. Keep those source assets intact. Animated menu must stop invoking GlobalState.reset() and GameState.start_game() on puzzle launch, and hide Continue/Level Select rather than imply saved puzzle progression. Preserve explicit settings reset controls and recovery.

Evidence: scenes/menus/main_menu/main_menu_with_animations.gd; scenes/game_scene/game_ui.tscn; addons/maaacks_game_template/base/scripts/pause_menu_controller.gd; addons/maaacks_game_template/base/scenes/overlaid_menu/menus/pause_menu.gd; .knowledge/architecture/save-progression.md. Local source is authoritative for these integration findings; no external API research was needed.

## Authoring and solvability

Decision: 5 by 4 board with eight arrows, coordinates zero-based with y increasing downward. Layout and witness sequence are in data-model.md. Rationale: includes all directions and distant blockers while keeping manual verification easy. Alternatives: random generation or many levels violate scope. Removing arrows never creates blockers, so a verified full removal sequence suffices to establish solvability of this static board.

## Input and animation

Decision: GUI click-to-cell routing, presentation-only views, immediate logical removal and concurrent tweens. Rationale: exactly-once accounting and future touch adapter reuse. Wait for all exit tweens before results. Alternatives: animation-driven state causes timing-dependent blocking; global input locks frustrate continued play.

## Verification

Decision: add a dedicated isolated Python launcher and GDScript rule suite, using the isolation pattern in tests/run_regressions.py. Keep existing save/input suite unchanged and run it. Headless checks do not replace desktop mouse, keyboard/gamepad, focus, pause or animation smoke checks. No added packages, persistence schema changes, or addon edits are needed. All design questions are resolved; actual runtime results are deferred to implementation.
