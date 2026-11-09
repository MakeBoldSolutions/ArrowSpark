---
id: save-progression
type: architecture
title: Save Progression and Input Settings
appliesTo:
  - project.godot
  - scripts/game_state.gd
  - scripts/level_state.gd
  - scripts/player_profile.gd
  - scenes/menus/main_menu/profile_menu.gd
  - scenes/menus/main_menu/profile_menu.tscn
  - addons/maaacks_game_template/base/scripts/global_state.gd
  - addons/maaacks_game_template/base/scripts/global_state_data.gd
  - addons/maaacks_game_template/base/scripts/app_settings.gd
  - addons/maaacks_game_template/base/scripts/config.gd
  - addons/maaacks_game_template/base/scenes/autoloads/app_config.gd
  - tests/save_input_regression.gd
  - tests/player_profile_check.gd
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
zoom/pan/fit view, menu-provided mouse Pan mode and navigation eligibility are presentation-only and
reset with every attempt: nothing about the viewport is written to
`user://global_state.tres` or the settings file, and navigating, replaying or
changing puzzles never changes their bytes. tests/save_input_regression.gd
verifies the additive actions, mixed restoration and reset behavior against the
project's real `[input]` section (copied into its isolated project) and the
unmodified inherited list defaults; tests/puzzle_canvas_check.gd verifies the
saved-bytes invariants around navigation flows. Limits: movement actions
remapped onto Tab or D-pad buttons are deliberately not consumed by the board so
focus can always leave it, which means such a remap also moves GUI focus.

## Player Profile

The player's results live in their own file, `user://player_profile.json`,
owned by `PlayerProfile` (scripts/player_profile.gd). It is separate from
`user://config.cfg` (settings) and `user://global_state.tres` (the template's
legacy save): a damaged profile can never block settings or old saves, and the
profile code never reads or writes either of those files. The profile holds a
format version, the display name, the level to resume at, summed statistics
(attempts finished, mistakes, Open Move assists) and one best result per level.

A best result is keyed by the stable catalog puzzle id and stores the puzzle's
`PuzzleContentVersion`. A best whose board has since changed (different
version, or an id no longer in the catalog) is kept in the file but ignored, so
a score never describes a board the player did not play; the next finish of that
level replaces it. Entries that fail validation are skipped without discarding
the rest of the profile.

`PuzzleScoreboard` stays the in-memory comparator and the single authority for
"established / improved / tied / not improved" and for the overall score.
`PlayerProfile.ensure_loaded()` seeds it from the saved bests, and
`arrow_puzzle.gd` calls `PlayerProfile.record_completion()` right after
`PuzzleScoreboard.record_attempt()` for every finished attempt. An abandoned
attempt records nothing, and an unfinished board is never saved: only the level
to resume at (the level after the one most recently finished in its group, or
that level at a group's end) and finished results persist. Continue appears on
the main menu once there is a level to resume at and opens it through
`PuzzleSession`; the Profile sub-menu (shown in the same container as Level
Select) edits the name, summarizes the profile, and deletes it after
confirmation. Level Select shows "Best N of M" under each finished level.

An unreadable profile (not JSON, not a profile, or a newer format version) is
never silently discarded: its exact bytes are copied to
`player_profile.json.recovery` (numbered on collisions) and the game starts a
new profile with a notice in the Profile menu. If the copy cannot be made the
original is left untouched, writes are blocked for the session and the notice
says progress will not be saved. This is lighter than the settings and
legacy-save recovery above (no startup dialog) because losing a profile costs no
settings or saved state, and the backup keeps the data recoverable by hand. The
file is written directly, not through a temporary file and rename, so the Web
build's browser storage is synced by a single file close.

Limits: the profile lives only in the browser or install that wrote it. It does
not follow the player to another device, clearing browser data removes it, and
browsers may clear site storage after a long absence (Safari's behavior on a real
iPhone is unverified). Writes are not crash-safe. One profile per device; shared
devices are not handled. Source of truth: tests/player_profile_check.gd
(persistence across a simulated restart, best-score rules, resume position,
unreadable-file recovery with and without a backup, a newer format, changed
boards, malformed entries, deletion, and the settings and legacy-save files left
byte-for-byte alone), tests/save_input_regression.gd
(`_test_profile_is_separate_and_continue_resumes()`) and
tests/puzzle_layout_check.gd (Continue, Level Select bests and the Profile menu
in the real scenes). A class must not name a static function `reload()`: it is
`Script.reload()`, which re-initializes the class's static variables.

## Session-Only Puzzle Entry vs. Preserved Legacy Storage

`scenes/menus/main_menu/main_menu_with_animations.gd`'s Play/New Game path
(`main_menu.tscn` and `main_menu_with_animations.tscn`, both routed to
`res://scenes/puzzle/arrow_puzzle.tscn`) overrides `new_game()` only to set
`PuzzleSession.set_current_id("first_knot")` (the first ArrowSpark level) before delegating to
the base `new_game()` (`load_game_scene()`); it still never calls
`GlobalState.reset()` or `GameState.start_game()`. The puzzle attempt itself
(`scripts/puzzle/puzzle_state.gd`) is in-memory only and is never read from
or written to `GlobalState`/`GameState`. `GameState` and `LevelState` stay in
`scripts/` even though no live gameplay path uses them: a saved
`user://global_state.tres` serializes them by script path, so removing either
would break loading existing saves. The template's level-list example that
used them is not part of the project (it can be restored from
`addons/maaacks_game_template/examples/`). See
.knowledge/architecture/arrow-puzzle.md for its rules, and for
`PuzzleCatalog`/`PuzzleSession` themselves. Existing saved level progress,
settings and recovery behavior described above are therefore unaffected by
starting, playing, replaying, or selecting the puzzle. Continue is shown
only when the player profile has a level to resume at and opens it through
`PuzzleSession` without calling `GlobalState.reset()` or `GameState.start_game()`
(the template's `GlobalState`/`GameState` progress stays unused); the
`NewGameButton` tooltip reads "Starts the first ArrowSpark level. Your saved
results are kept. Continue resumes where you left off." Puzzle entry also never
touches the input-remap
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
`ScrollContainer` (horizontal scrolling disabled) so all thirty entries,
shown as three collapsible group sections (an accordion: a toggle header per
group, its one-line description, then its entries), stay
reachable and fully visible when focused at 960x540, 800x800 and 1280x720; the
list is centered when it fits. Source of truth: tests/puzzle_layout_check.gd (listing/ordering,
initial focus placement, non-first-selection loading the correct puzzle),
tests/puzzle_canvas_check.gd (every entry focusable fully into view at the
three supported window sizes)
and tests/save_input_regression.gd's extended
`_test_no_reset_on_puzzle_entry()` (selection sets `PuzzleSession`, opens via
`SceneLoader.load_scene`, disturbs no save/settings/remap state, and
`new_game()` still starts the first progression level regardless of a prior Level Select choice earlier in the same session).

### Web builds

In the Web build, Godot maps `user://` to the browser's own storage for the
site, so settings, input remaps and the legacy `global_state.tres` persist
locally in that browser. This is a new storage location, not a migration:
desktop data is untouched, and nothing stored there is transmitted anywhere.
The player profile (see Player Profile above) lives in the same browser storage,
so reloading the page keeps the player's name, finished levels and best scores.

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

## Responsive options presentation

Master options tabs retain original option instances inside focus-following vertical scroll panels. Narrow presentation wraps labels and bounds inherited minimum widths; it does not reset settings or replace input events. Mini options retains its inherited pause-aware overlay and reset confirmation. Source of truth: scenes/menus/options_menu/master_options_menu.gd, scenes/menus/options_menu/mini_options_menu_with_reset.gd and tests/save_input_regression.gd. The owner played the portrait and landscape layouts on a real Pixel phone on 2026-11-08; other devices remain unchecked.
