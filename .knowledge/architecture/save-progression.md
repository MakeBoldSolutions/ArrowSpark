---
id: save-progression
type: architecture
title: Save Progression and Input Settings
appliesTo:
  - project.godot
  - scripts/game_state.gd
  - scripts/level_state.gd
  - scripts/level_list_state_manager.gd
  - addons/maaacks_game_template/base/scripts/global_state.gd
  - addons/maaacks_game_template/base/scripts/global_state_data.gd
  - addons/maaacks_game_template/base/scripts/app_settings.gd
  - addons/maaacks_game_template/base/scripts/config.gd
  - addons/maaacks_game_template/base/scenes/autoloads/app_config.gd
  - tests/save_input_regression.gd
  - tests/run_regressions.py
  - scenes/menus/main_menu/main_menu.tscn
  - scenes/menus/main_menu/main_menu_with_animations.gd
  - scenes/menus/main_menu/puzzle_select_menu.gd
  - scenes/menus/main_menu/puzzle_select_menu.tscn
---

# Save Progression and Input Settings

## Ownership and Startup

The AppConfig autoload opens GlobalState, then applies configured input, audio,
and window settings. GlobalState stores a GlobalStateData resource at
`user://global_state.tres`. GameState holds level states, the highest level reached,
the selected level, and the play count. LevelListStateManager connects level
selection and advancement to GameState updates. LevelState stores each level's color.

Config stores player settings separately at `user://config.cfg`. Progress resets
clear the GlobalState states dictionary; they do not reset input/audio/video settings.

## Save Recovery

A missing save initializes fresh state. An existing resource is accepted only if
it is GlobalStateData. If loading fails or the resource has the wrong type, the
original bytes remain untouched, fresh in-memory state is available for the session,
and `save_blocked` prevents ordinary writes. This protects recoverable data while
allowing play without persistence.

At startup, a confirmation dialog offers continuing without saving or backing up
and resetting progress. Explicit reset first copies the failed save to
`global_state.tres.recovery`, with a numeric suffix when a backup already exists.
Only a successful backup permits reset and re-enables saving. A failed backup
cancels the reset and retains write protection. Save/reset return Godot Error
values, and write failures are logged; the startup recovery action also displays
a failure notice. Existing callers may ignore the returned error.

These narrow addon changes keep persistence protection in the shared save entry
point, covering all callers. Input restoration likewise belongs in the shared
settings implementation. Keep these local fixes when updating the bundled addon.

## Input Restoration

### Unreadable Settings

Config distinguishes missing files from failed loads. Failed loads discard partially
parsed values, preserve the original file, and block every settings-save path.
Setters and erase operations remain usable in memory for the current session.
Startup offers temporary settings or explicit backup/reset; when both progress and
settings need recovery, the settings prompt follows dismissal of the progress prompt.

Reset copies the original settings to `config.cfg.recovery` (numbered on collisions)
before writing an empty configuration. Backup or reset-write failures retain write
protection. Successful reset enables persistence and asks the player to restart to
apply defaults; it does not reinitialize audio/window/input state mid-session.
Changes made after successful reset may be persisted normally.

AppSettings reads saved events for each action, clears the action, and restores
the complete configured event list. Duplicate detection uses the rebuilt InputMap,
not the previous defaults. Changing a keyboard key therefore retains an unchanged
gamepad binding. Reset-to-default input restores the captured startup defaults and
removes the stored input configuration.

### Canvas Actions and Transient Camera State

The canvas zoom/fit actions (`canvas_zoom_in`, `canvas_zoom_out`, `canvas_fit`)
are additive custom `InputMap` actions declared in project.godot beside the
untouched `move_*` and `interact` actions. The inherited input list shows every
custom action (`show_all_actions` stays true; no project options scene hides
them), so they appear, remap and reset like the existing actions: a remapped
key, a remapped gamepad button or a mixed keyboard-plus-gamepad mapping is
restored from the `[Input]` settings section without duplicating events, and
reset-to-default restores the shipped keyboard and gamepad bindings. The
zoom/pan/fit view, Pan mode and navigation eligibility are presentation-only and
reset with every attempt: nothing about the viewport is written to
`user://global_state.tres` or the settings file, and navigating, replaying or
changing puzzles never changes their bytes. tests/save_input_regression.gd
verifies the additive actions, mixed restoration and reset behavior against the
project's real `[input]` section (copied into its isolated project) and the
unmodified inherited list defaults; tests/puzzle_canvas_check.gd verifies the
saved-bytes invariants around navigation flows. Limits: movement actions
remapped onto Tab or D-pad buttons are deliberately not consumed by the board so
focus can always leave it, which means such a remap also moves GUI focus.

## Session-Only Puzzle Entry vs. Preserved Legacy Storage

`scenes/menus/main_menu/main_menu_with_animations.gd`'s Play/New Game path
(`main_menu.tscn` and `main_menu_with_animations.tscn`, both routed to
`res://scenes/puzzle/arrow_puzzle.tscn`) overrides `new_game()` only to set
`PuzzleSession.set_current_id(PuzzleCatalog.id_at(0))` before delegating to
the base `new_game()` (`load_game_scene()`); it still never calls
`GlobalState.reset()` or `GameState.start_game()`. The puzzle attempt itself
(`scripts/puzzle/puzzle_state.gd`) is in-memory only and is never read from
or written to `GlobalState`/`GameState`; see
.knowledge/architecture/arrow-puzzle.md for its rules, and for
`PuzzleCatalog`/`PuzzleSession` themselves. Existing saved level progress,
settings and recovery behavior described above are therefore unaffected by
starting, playing, replaying, or selecting the puzzle. Continue stays
hidden on the main menu (its scene/script remains in source, unreachable
from this menu); the `NewGameButton` tooltip states that existing level
progress is preserved. Puzzle entry also never touches the input-remap
system: a keyboard/gamepad remap seeded before `new_game()`/
`load_game_scene()` is unaffected by either call. Source of truth:
tests/save_input_regression.gd's `_test_no_reset_on_puzzle_entry()`.

### Level Select

Level Select is now shown (`LevelSelectButton.visible = true`,
`level_select_packed_scene` pointed at the new
`scenes/menus/main_menu/puzzle_select_menu.tscn`/`puzzle_select_menu.gd`),
replacing the addon example's `GameState`-backed level list script. It is
built directly against `PuzzleCatalog`/`PuzzleSession`, not the addon's
`LevelListManager`/`GameState` level infrastructure: `_setup_level_select()`
connects the new scene's `puzzle_selected(id)` signal to a handler that
calls `PuzzleSession.set_current_id(id)` then the existing
`load_game_scene()` — never `GameState.set_current_level()` or any other
template persistence call. Selecting a puzzle therefore carries the same
no-reset, no-remap-disturbance guarantee as New Game. `puzzle_select_menu.gd`
explicitly grabs focus onto its first entry when it becomes visible, since
the inherited `_open_sub_menu()` mechanism does not do this itself (see
.knowledge/architecture/arrow-puzzle.md's Puzzle Catalog and
Session-Scoped Selection section, and the sub-menu open/close mechanics
below). The entry list sits in a vertically scrolling, focus-following
`ScrollContainer` (horizontal scrolling disabled) so all fifteen entries stay
reachable and fully visible when focused at 960x540, 800x800 and 1280x720; the
list is centered when it fits. Source of truth: tests/puzzle_layout_check.gd (listing/ordering,
initial focus placement, non-first-selection loading the correct puzzle),
tests/puzzle_canvas_check.gd (every entry focusable fully into view at the
three supported window sizes)
and tests/save_input_regression.gd's extended
`_test_no_reset_on_puzzle_entry()` (selection sets `PuzzleSession`, opens via
`SceneLoader.load_scene`, disturbs no save/settings/remap state, and
`new_game()` still resets to catalog position 0 regardless of a prior
Level Select choice earlier in the same session).

## Validation and Limits

Run `python tests/run_regressions.py` with Godot on PATH, or pass `--godot` with
the desired executable. It uses a temporary project and unique application name;
APPDATA/XDG_DATA_HOME redirect test data away from the game's saved progress.
Expected negative-case engine errors appear alongside PASS lines. A successful run
must exit zero and print `REGRESSION_FAILURES=0`.

The suite covers missing/valid/corrupt/incompatible saves, backup collisions and
failures, save-write errors, disk-loaded mixed keyboard/gamepad remaps, repeat
restoration, and input reset. Interactive checks should also cover both recovery
choices, menu navigation with keyboard and gamepad, and progress after restart.

Settings regressions also cover partially parsed files, in-memory updates, all
mutation paths, backup failure, exact-byte preservation, and persistence after reset.

Resource type validation does not implement schema migrations for otherwise
loadable but semantically incompatible data. Ordinary saves are not transactional
or crash-safe. Settings recovery covers parse/load failures, not semantic validation
of every successfully parsed setting value.
The recovery backup is retained for manual inspection; no automatic restoration or
backup deletion policy is imposed.
