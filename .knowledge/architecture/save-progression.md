---
id: save-progression
type: architecture
title: Save Progression and Input Settings
appliesTo:
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

## Session-Only Puzzle Entry vs. Preserved Legacy Storage

`scenes/menus/main_menu/main_menu_with_animations.gd`'s Play/New Game path
(`main_menu.tscn` and `main_menu_with_animations.tscn`, both routed to
`res://scenes/puzzle/arrow_puzzle.tscn`) no longer overrides `new_game()` or
`load_game_scene()`, so it never calls `GlobalState.reset()` or
`GameState.start_game()`. The puzzle attempt itself
(`scripts/puzzle/puzzle_state.gd`) is in-memory only and is never read from
or written to `GlobalState`/`GameState`; see
.knowledge/architecture/arrow-puzzle.md for its rules. Existing saved level
progress, settings and recovery behavior described above are therefore
unaffected by starting, playing, or replaying the puzzle. Continue and
Level Select stay hidden on the main menu (their scenes/scripts remain in
source, unreachable from this menu); the `NewGameButton` tooltip states that
existing level progress is preserved. Puzzle entry also never touches the
input-remap system: a keyboard/gamepad remap seeded before `new_game()`/
`load_game_scene()` is unaffected by either call. Source of truth:
tests/save_input_regression.gd's `_test_no_reset_on_puzzle_entry()`.

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
