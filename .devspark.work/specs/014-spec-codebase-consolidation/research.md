# Research: Codebase Organization and Consolidation

Question ledger for the three planning questions that needed evidence. Commands were run from the
repo root on 2026-10-15 with the tree clean at `58a8bec`.

## R-01: Which template example content is provably unreachable?

- **Why it matters**: FR-009/FR-011 allow removal only with reachability evidence. Saved-data
  classes and anything uncertain must stay.
- **Evidence needed**: A walk from `project.godot` that follows `res://` paths, `uid://` ids and
  `class_name` uses. Then a reverse-reference search for each candidate across the repo, including
  the addon, the tests and the web site.
- **Answer**: The walk (a throwaway script, not kept) reached the shipped flow: the opening scene,
  then the main menu and puzzle select, then the puzzle scene, plus the pause and options menus and
  the autoloads. These project files were not reached:
  - **FR-011 categories (remove):** `scenes/game_scene/` (`game_ui.tscn`,
    `configurable_sub_viewport.gd`, `input_display_label.gd`, `levels/level.gd`, `level_1..3.tscn`);
    `scenes/end_credits/`; `scenes/menus/level_select_menu/`;
    `scenes/overlaid_menus/{game_won_menu,level_lost_menu,level_won_menu}.{gd,tscn}`;
    `scenes/loading_screen/{level_loading_screen.tscn,loading_screen_with_shader_caching.{gd,tscn},loading_screen.{gd,tscn}}`;
    `scripts/level_list_state_manager.gd`. Their only referrers are each other.
    `SceneLoader.loading_screen_path` points at the **addon's** loading screen, not the project
    copy. The won/lost overlays inherit from addon scenes, not from the project's
    `overlaid_menu.tscn`.
  - **Not in the FR-011 list (retain and label):** the project copies `scenes/menus/main_menu/main_menu.{gd,tscn}`,
    `scenes/menus/options_menu/{master_options_menu,mini_options_menu,video/video_options_menu,input/input_options_menu_with_mouse_sensitivity}.tscn`
    (plus `mini_options_menu.gd`), `scenes/opening/opening.tscn`,
    `scenes/overlaid_menus/overlaid_menu{,_container}.{gd,tscn}`, and five unused
    `resources/themes/*.tres`. They are unreferenced template customization copies. Removing them
    is not something the spec asked for, so they are listed in the responsibility map as "template
    copies, unreferenced" and not touched.
  - **Kept regardless:** `scripts/game_state.gd` and `scripts/level_state.gd`. They have no live
    gameplay use, but `user://global_state.tres` serializes them by script path, and
    `tests/save_input_regression.gd` exercises them (FR-010, Principle VI).
- **Evidence pointer**: `git grep -l <path>` for each candidate. The only matches outside the
  candidate set are the addon's own originals under `addons/maaacks_game_template/examples/` and
  `extras/`, the archived constitution draft, and
  `.knowledge/architecture/save-progression.md` (which lists `level_list_state_manager.gd` in
  `appliesTo`). No addon script holds a `res://scenes` or `res://scripts` string. Tests and
  `web/src` don't reference any candidate. `export_presets.cfg` exports all resources with only
  `tests/*` excluded, so the candidates currently ship in the web build.
- **Resolution**: Remove exactly the FR-011 set, including its `.uid` sidecars. The addon's
  `examples/` folder holds the originals, which is the restore path the responsibility map
  records. Re-run the reachability walk after removal: the shipped set must be unchanged and no
  dangling references must remain.

## R-02: Which Godot executable runs the gates?

- **Why it matters**: The spec assumes the configured engine (4.4). The executable on `PATH`
  (`godot`, from WinGet) is **4.7.2**. Opening the project with it could rewrite
  `project.godot` (`config/features`), `.uid` files or imports. That would be an engine upgrade
  disguised as a refactor.
- **Answer**: `%LOCALAPPDATA%\Temp\ArrowGame-Godot-4.4.1\bin\Godot_v4.4.1-stable_win64_console.exe`
  (`/tmp/...` in Git Bash). It is a temp-folder copy, so reinstall 4.4.1 if it is cleaned up. It reports
  `4.4.1.stable.official.49a5bc7b6` and is the same 4.4 line the previous spec verified with.
- **Resolution**: Every gate, probe, export and the editor validation use that 4.4.1 console
  executable (`<godot>` in quickstart). The `godot` on PATH is never run against this repo. A
  `git status` check after the first gate run confirms that no engine-written files changed.

## R-03: Where should the behavior-preservation probe live, and how does it run?

- **Why it matters**: FR-014 needs a before/after comparison over all 30 entries, but FR-016 and
  the planning guidance forbid permanent reporting tooling.
- **Evidence needed**: Whether a SceneTree script outside `res://` can run against the real
  project and resolve the project's global classes.
- **Answer**: Yes. A script in the system temp folder run with
  `<godot> --headless --path . --script <absolute path>` printed `COUNT=30` and
  `PuzzleContentVersion.of(intro) = g1-95a75f0e6ec0`, and left the tree clean. `.devspark.work/`
  carries a `.gdignore`, so a probe stored there is invisible to the project and never exported.
  There is precedent: `.devspark.work/specs/master/gates/drive_recovery.gd`.
- **Resolution**: The probe is a temporary SceneTree script in this spec's `gates/` folder, run by
  absolute path. Its output is written to `gates/baseline-before.txt` and `gates/baseline-after.txt`
  and compared with a plain text diff. No runner, no Python and nothing durable. It is archived with
  the spec bundle.
