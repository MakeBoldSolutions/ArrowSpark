# Research: Game UI Improvements

Question ledger for planning decisions that needed evidence. Temporary; never referenced by durable files.

## R1 — How should UI scale with the window and canvas?

- **Why it matters**: FR-001, FR-002, FR-003, SC-001; it also affects puzzle framing (FR-016) and the phone beta.
- **Evidence needed**: Current display settings, how the board computes fit, how the regression gates size the root, and how the web canvas sizes itself.
- **Answer**:
  - `project.godot` sets only a 1280×720 viewport, with no stretch mode, so the UI is drawn 1:1 in physical pixels.
  - The web export uses `canvas_resize_policy=2` (adaptive). Godot's web canvas renders at device-pixel density, so a phone at DPR ≈3 currently draws 20 px text at about 6 CSS px.
  - `PuzzleViewportTransform` fits the board inside its own Control's logical size, and pointer and touch events arrive in logical coordinates.
  - Both regression runners write a minimal `project.godot` without `[display]` settings and size the root directly, so a stretch setting never reaches the headless gates.
- **Evidence pointer**: `project.godot` `[display]`; `export_presets.cfg` (`html/canvas_resize_policy=2`); `tests/run_puzzle_regressions.py:63`, `tests/run_regressions.py:32`; `scripts/presentation/puzzle_viewport_transform.gd`; `tests/puzzle_layout_check.gd:121`.
- **Resolution**:
  - Use the engine's built-in `canvas_items` stretch with `expand` aspect and a 1280×720 base, at fractional scale.
  - In logical units the window is then never narrower than 1280 or shorter than 720 at 16:9 or wider, so every existing layout keeps its verified logical size, and the board's fit and zoom math is unchanged in logical terms.
  - The scale factor is min(W/1280, H/720) in physical pixels:
    - 1080p → 1.5×, 1440p → 2×, 4K → 3×.
    - Reference phone (≈2.2–3.5×): larger than today, which satisfies FR-003.
    - A desktop browser canvas smaller than 1280×720 physical px scales below 1×.
  - **Accepted, bounded limitation:** a 960×540 CSS canvas at DPR 1 renders at 0.75×. FR-003's floors apply at the design resolution and on the phone. This is recorded for the rendered 960×540 check.
  - **Rejected alternative:** a scripted minimum-scale clamp. It is extra runtime machinery, and it would break FR-001's proportionality below the design size.
  - **Rejected alternative:** `integer` scale mode. It stays at 1× on 1080p displays, so it fails SC-001.
  - **Touch slop (owner decision, 2026-10-16):**
    - `scenes/puzzle/puzzle_board.gd:40` compares a 32 px slop against board-local positions. Under stretch, that would grow physically by the scale factor (about 2× on the reference phone) and change the tuned touch feel.
    - The owner chose to preserve it: divide the slop by the viewport's current stretch scale at the existing comparison. No new state or setting.
    - **Rejected alternative:** accepting the larger slop and re-verifying. It changes input feel that FR-016 freezes.

## R2 — Where is the single app theme installed so that every surface receives it?

- **Why it matters**: FR-004, FR-007, SC-002; it also determines whether existing test expectations change (FR-016).
- **Evidence needed**: Current theme attachment points, the first code to run, and the CI constraints on startup scripts.
- **Answer**:
  - The theme is currently attached only in `arrow_puzzle.gd:31` (`$Layout`) and `puzzle_results.gd:27`.
  - Level Select requests `SecondaryButton` and `SupportingText` variations that resolve to nothing.
  - The template loading screen (`SceneLoader.loading_screen_path`) can appear between the splash and the Main Menu, and its unthemed Panel sits under a 50 % black ColorRect.
  - The web CI job allow-lists exact error lines in `scenes/opening/opening.gd:1` and the addon's `opening.gd`. Adding code there risks shifting a known-quirk error onto a non-allowed line.
  - Autoload *identifiers* are what trip that fresh-import quirk; `preload()` paths do not.
- **Evidence pointer**: `.github/workflows/azure-static-web-apps-green-bay-09bdc1010.yml:106`; `addons/maaacks_game_template/base/scenes/autoloads/scene_loader.tscn`; `addons/.../loading_screen/loading_screen.tscn:31`.
- **Resolution**:
  - Add one project autoload, `AppTheme`, which runs before any scene. It:
    - assigns the theme to the root Window (inherited by every Control, popup and embedded dialog);
    - points the scene loader at a project-owned branded loading screen through a node-path lookup, with no autoload identifier.
  - It reaches `GameVisualStyle` through `preload`.
  - **Rejected alternative:** the `gui/theme/custom` project setting. It needs a saved `.tres`, which would duplicate the code-built theme and drift from it.
  - **Rejected alternative:** setting the theme from the Main Menu. That misses the loading screen.
  - **Rejected alternative:** editing `opening.gd`. That is the CI allow-list risk.
  - The existing `$Layout` and Results assignments stay. They hand out the same cached Theme object, which keeps the puzzle scene self-contained when it is instanced alone (as the tests do). The scope assertion at `tests/puzzle_presentation_check.gd:311` therefore still holds unchanged.
  - **To verify in the first implementation task:** whether Controls under a CanvasLayer (pause overlay, loading screen) inherit the root Window theme in Godot 4.4. Expected yes, because ThemeOwner falls back to the viewport. If not, the fallback is assigning the same theme on the CanvasLayer's top Control in the project's inherited overlay scenes.

## R3 — How does the Make Bold mark appear on the dark hero and splash without breaking brand rules?

- **Why it matters**: FR-006, FR-010.
- **Evidence needed**: Brand logo usage rules and the available assets.
- **Answer**:
  - The brand guide says "never recolor, distort, rotate, or crowd the logo", with clear space of 1× the tallest peak.
  - The only mark in the repository is `web/theme/make-bold/logo-mark.svg` (rust #982407 and ink #1E1E1E). Its ink peak is invisible on ink-900.
  - The current `icon.png` is the template author's "M / Game" icon, not ArrowSpark's.
  - The web loading shell is ink (#1E1E1E).
- **Evidence pointer**: `web/theme/make-bold/readme.md` (Logo usage rules); `web/game-shell/shell.css:11`; `icon.png`.
- **Resolution**:
  - Create one "mark tile" asset: the unmodified mark paths centred on a cream rounded square with ≥1× clear space. It is used on:
    - the opening splash (on ink, continuing the dark web shell with no flash);
    - the Main Menu hero (on ink);
    - the application icon (a raster export replaces `icon.png`).
  - The boot splash uses an ink background with no engine image.
  - Splash ink → Main Menu ink hero gives a continuous hand-off.

## R4 — Where do UI sounds come from and how are they scoped?

- **Why it matters**: FR-015, FR-016.
- **Evidence needed**: Template sound hooks, buses and current assets.
- **Answer**:
  - The template's `UISoundController` already exists on the Main Menu (persistent, hooks nodes added while the menu is alive).
  - It exports button, tab and slider streams and plays them on the `SFX` bus, which the existing Audio options control.
  - There are no audio assets in the repository.
  - The `ProjectUISoundController` autoload has no streams and hooks the whole tree, so giving it streams would also sound on puzzle HUD buttons, which is gameplay.
- **Evidence pointer**: `addons/maaacks_game_template/base/scripts/ui_sound_controller.gd:11-80`; `default_bus_layout.tres`.
- **Resolution**:
  - Assign streams on the Main Menu's controller.
  - Add a controller to the project pause overlay, which exists only while the menu is open, so no HUD or Results button gains sound.
  - Author three short original sounds (focus tick, press, tab/slider) offline. They are original work, so there is no third-party licence, and they are recorded in `ATTRIBUTION.md` as original.
  - **Rejected alternative:** third-party CC0 packs. They add a download, provenance step and attribution for a few hundred milliseconds of audio.

## R5 — How are the Main Menu split layout and Level Select cards achieved without breaking the menu contracts?

- **Why it matters**: FR-010, FR-011, SC-005; also the no-reset and New Game guarantees in `tests/run_regressions.py`.
- **Evidence needed**: The node tree, the script contracts and the tests that pin them.
- **Answer**:
  - The project Main Menu inherits the addon scene, and its scripts address `%MenuContainer`, `%MenuButtonsBoxContainer`, `%BackButton`, `%OptionsContainer`, `%LevelSelectContainer` and the button names.
  - Inherited nodes cannot be reparented, but their anchors, visibility and overrides can be changed.
  - Level Select exposes `entry_buttons()`, `header_buttons()` and `description_labels()`, uses Buttons with toggle headers, and keeps group membership and order.
  - Puzzles have titles and group positions but no per-puzzle description; groups have one description line each.
- **Evidence pointer**: `addons/.../main_menu/main_menu.tscn`; `scenes/menus/main_menu/main_menu_with_animations.tscn`; `scenes/menus/main_menu/puzzle_select_menu.gd`.
- **Resolution — Main Menu**:
  - Add a project-owned hero panel (left about 40 %) containing the mark tile, the title (the template config-name label behaviour reused) and the tagline.
  - Re-anchor the inherited menu, options, credits, Level Select and Back containers to the right cream column, so sub-menus keep the hero visible.
  - Hide the inherited title and subtitle labels, keeping the nodes for script compatibility.
  - Retarget the Intro and OpenMainMenu animation tracks to the hero and shorten them (FR-013, SC-004).
- **Resolution — Level Select**:
  - Entries stay Buttons, laid out in a grid under each group header with a group accent variation.
  - The accessor APIs, numbering, order, toggles and focus behaviour are unchanged.
  - "Existing title and description" means the puzzle title plus its group's description line. No new content is invented.

## R6 — Which motion values apply?

- **Why it matters**: FR-013, FR-014, SC-004.
- **Evidence needed**: Brand motion tokens and current template timings.
- **Answer**:
  - Brand tokens: `--dur-fast` 120 ms, `--dur-base` 200 ms; ease-out with no bounce; hover darkens one step; press darkens a further step with a 1 px nudge ("no scale-shrink toys").
  - Current timings: the splash runs about 3.0 s (0.5 + 0.2 + 1.6 + 0.2 + 0.5) and the menu Intro takes 2.4 s before the buttons appear, about 5.4 s in total.
- **Evidence pointer**: `web/theme/make-bold/tokens/effects.css`; `addons/.../opening/opening.gd:7-13`; Intro animation in `main_menu_with_animations.tscn`.
- **Resolution**:
  - Retune the splash exports to about 1.4 s visible in total and the Intro to about 1.0 s, staggered.
  - Sub-menu open/close and the pause scrim use 200 ms fades.
  - Hover and press are instant stylebox states (darken one step; press adds a 1 px content nudge), so they never wait on a tween.
  - The backdrop motif is slow drift of a single transform with no per-frame geometry rebuild (constitution IV).
