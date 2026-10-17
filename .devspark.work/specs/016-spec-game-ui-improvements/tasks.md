---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
description: "Task list for Game UI Improvements"
devspark_version: "9.2.0"
plan_semantic_hash: "sem1:3ec711d836231bf71894a1996b0d33f6b5ee92eeb076ecfe53ac954f807c8354"
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Tasks: Game UI Improvements

**Input**: Design documents from `/.devspark.work/specs/016-spec-game-ui-improvements/`
**Prerequisites**: plan.md, spec.md, research.md (R1–R6), qa-acceptance.md (QA-01–QA-11)

**Tests**:
- **Add**: `tests/app_theme_check.gd` (QA-05).
- **Update**:
  - `tests/puzzle_layout_check.gd`: Level Select card/variation and Main Menu hero checks.
  - `tests/puzzle_canvas_check.gd`: touch slop at a non-1 stretch scale (T040).
  - `tests/puzzle_presentation_check.gd:311`: message text only (T041).
- **Unchanged**: the existing assertions in both gates (FR-016). The scaling, brand, motion and sound scenarios are manual rendered checks (QA-01–04, 06–11).

**Pinned contracts that must survive** (from current tests):
- `%PuzzleListContainer` remains a `VBoxContainer`.
- `%ScrollContainer` keeps `follow_focus` and disabled horizontal scroll.
- Entry text stays `"%d. %s"`.
- Headers keep `- `/`+ ` prefixes.
- Each entry's parent is its group section, which collapsing hides.
- The `entry_buttons()`/`header_buttons()`/`description_labels()` accessors and `_first_button` remain.
- The Main Menu `BackButton` keeps text "Back".
- `puzzle.theme == null` while `Layout.theme != null` (`tests/puzzle_presentation_check.gd:311`). Only its message text changes (T041).

**Pre-PR only**: every task below completes before merge. There are no post-deploy obligations.

## Format: `[ID] [P?] [Story] Description (Implements: FR-###)`

## Phase 1: Setup

- [X] T001 Probe whether Controls under a CanvasLayer inherit a theme set on the root Window in Godot 4.4.1. Use a throwaway SceneTree script in `.devspark.work/specs/016-spec-game-ui-improvements/evidence/`. Record yes/no in `research.md` R2, and select the overlay fallback if no (plan Reviewer Guidance, R2) (code_ref: n/a — throwaway probe in evidence/, no durable code | knowledge_ref: n/a — outcome recorded in research.md R2 and plan Implementation Notes)
- [X] T002 [P] Create `assets/brand/mark_tile.svg`: the unmodified paths of `web/theme/make-bold/logo-mark.svg` centred on a cream (#F8F6F2) rounded tile with ≥1× tallest-peak clear space (plan R3) (code_ref: assets/brand/mark_tile.svg | knowledge_ref: n/a — asset only; documented with the branding update in T030)
- [X] T003 [P] Author light-theme control icons in `assets/ui/` as SVGs in brand colors: checkbox on/off, radio on/off, toggle on/off, slider grabber and highlight, dropdown arrow, tree arrow and collapsed (plan expected_change_surface `assets/ui/`) (code_ref: assets/ui/{checkbox_checked,checkbox_unchecked,radio_checked,radio_unchecked,toggle_on,toggle_off,slider_grabber,slider_grabber_highlight,arrow_down,arrow_right}.svg | knowledge_ref: n/a — documented in the game-visual-system rewrite (T029))

## Phase 2: Foundational

- [X] T004 Add brand ramp tokens to `scripts/presentation/game_visual_style.gd`: rust-400/600 hover/pressed, ember-50/300 tints, ink-800/900 hero, scrim, positive-soft, plus three group accents. Keep every existing constant value unchanged (plan Decision Summary) (code_ref: scripts/presentation/game_visual_style.gd | knowledge_ref: n/a — palette table rewritten in T029)
- [X] T005 Create `scripts/presentation/control_theme.gd`, which adds brand styles to the cached theme. It is called from `GameVisualStyle.get_theme()` and covers the plan's control list:
  - Button default states (≥48 px min height, hover one step darker, press one step darker plus a 1 px nudge, ember focus);
  - PrimaryButton rust states;
  - Label, Panel/PanelContainer, TabContainer/TabBar, H/VSlider, CheckBox/CheckButton (T003 icons), OptionButton/PopupMenu, ScrollBar, LineEdit, Tree, ProgressBar, RichTextLabel, TooltipPanel/TooltipLabel, embedded Window/AcceptDialog;
  - `LevelCard` variations per group and hero label roles.

  Existing role values and variations stay unchanged (code_ref: scripts/presentation/control_theme.gd, scripts/presentation/game_visual_style.gd::get_theme | knowledge_ref: n/a — documented in T029)
- [X] T006 Create the `scripts/app_theme.gd` autoload, which assigns `preload`ed `GameVisualStyle.get_theme()` to the root Window and sets the scene loader's loading-screen path via `/root/SceneLoader` node lookup (no autoload identifier). Register it in `project.godot` after the template autoloads (plan R2, Deviations) (code_ref: scripts/app_theme.gd, project.godot [autoload] | knowledge_ref: n/a — documented in T029/T031)
- [X] T007 Create `tests/app_theme_check.gd` and register it in `tests/run_puzzle_regressions.py`, alongside the presentation check's isolated project files plus `control_theme.gd` and the `assets/ui/` icons. It checks that:
  - each control type from T005 resolves non-default brand styles;
  - each type has an ember focus stylebox;
  - Button and PrimaryButton min height is ≥48;
  - body and title font sizes are ≥18 and ≥64;
  - every palette text/background pair used by the theme meets AA (4.5:1 body, 3:1 large and focus);
  - `LevelCard` variations exist; the per-group mapping assertion moved to T022, where the mapping exists (QA-05) (Implements: FR-003, FR-008, FR-009)

  (code_ref: tests/app_theme_check.gd, tests/run_puzzle_regressions.py | knowledge_ref: n/a — tests/README.md updated in T032)

**Checkpoint**: Both gates pass with the new check green and every existing count still 0.
**Checkpoint**: Phase complete — 2026-10-16 (Setup and Foundational; puzzle gate 10/10 counts 0 including APP_THEME_FAILURES, REGRESSION_FAILURES=0)

## Phase 3: User Story 1 — Readable UI at any screen size (Priority: P1)

**Goal**: The UI scales from a 1280×720 design base with expand aspect (R1).

**Independent Test**: QA-01, QA-02 and QA-03; SC-001.

- [X] T008 [US1] Set `display/window/stretch/mode="canvas_items"`, `aspect="expand"` and fractional scale in `project.godot` (Implements: FR-001, FR-002) (code_ref: project.godot [display] window/stretch/mode, window/stretch/aspect | knowledge_ref: n/a — scaling described in the T029 game-visual-system rewrite)
- [X] T039 [US1] In `scenes/puzzle/puzzle_board.gd`, compare `_TOUCH_SLOP_PIXELS` in physical pixels by dividing it by the viewport's current stretch scale at the existing slop comparison. No new state or setting. Update `.knowledge/reference/touch-gestures.md` to state that the 32 px slop is physical and independent of UI scale (plan Decision Summary, R1) (Implements: FR-016) (code_ref: scenes/puzzle/puzzle_board.gd::_touch_slop, scenes/puzzle/puzzle_board.gd::_drag_single_touch | knowledge_ref: .knowledge/reference/touch-gestures.md)
- [X] T040 [US1] Add a headless touch check to `tests/puzzle_canvas_check.gd` at a non-1 stretch scale: a single-touch drag just under the physical slop still selects on release, and one just over it pans without selecting. Existing touch assertions are unchanged (Implements: FR-016) (code_ref: tests/puzzle_canvas_check.gd::_check_touch_slop_is_physical_under_scaling | knowledge_ref: .knowledge/reference/touch-gestures.md)
- [X] T009 [US1] Extend `.devspark.work/specs/016-spec-game-ui-improvements/evidence/capture_menus.gd` runs to 1280×720, 1920×1080, 2560×1440, 3840×2160, 2560×1080 and 1280×960. Measure title and Play-button height fractions against the ±5% target, and record results in `evidence/` (QA-01, QA-02) (Implements: FR-001, FR-002, FR-003) (code_ref: n/a — verification only (evidence/us1/RESULTS.md, evidence/capture_menus.gd) | knowledge_ref: n/a — verification only)
- [X] T010 [US1] Desktop smoke at 1280×720 and 2560×1440: play the first progression level and the Reference Knot with a recorded move sequence on `main` and on the branch. Compare moves, mistakes, score and fit/zoom/pan, and record in `evidence/` (QA-03) (Implements: FR-016) (code_ref: n/a — verification only (evidence/us1/RESULTS.md, evidence/gameplay_smoke.gd) | knowledge_ref: n/a — verification only)

**Checkpoint**: SC-001 is met in captures, and gameplay is identical.
**Checkpoint**: Phase complete — 2026-10-16 (SC-001 within 1.9%; main vs branch results identical at 1280×720 and 2560×1440)

## Phase 4: User Story 2 — One Make Bold look from launch to every screen (Priority: P1)

**Goal**: The app theme reaches every surface, launch is branded, and the engine logo and template icon are gone.

**Independent Test**: QA-04, QA-07 and QA-05 (automated); SC-002, SC-005.

- [X] T011 [US2] In `project.godot`, set the boot splash to ink #1E1E1E background with `show_image=false`, and set the default clear color to cream #F8F6F2 (Implements: FR-006) (code_ref: project.godot [application] boot_splash/*, [rendering] environment/defaults/default_clear_color | knowledge_ref: n/a — launch documented in T029/T030)
- [X] T012 [US2] In `scenes/opening/opening_with_logo.tscn`, add an ink full-rect background and replace the Godot logo image with `assets/brand/mark_tile.svg`. Make scene/export changes only; `scenes/opening/opening.gd` is untouched (Implements: FR-006) (code_ref: scenes/opening/opening_with_logo.tscn | knowledge_ref: n/a — documented in T030)
- [X] T013 [P] [US2] Create `scenes/loading_screen/loading_screen.tscn`, inheriting the template loading screen, with an ink background replacing the 50% black over the default panel and a brand progress bar from the theme. T006 points the loader at it (Implements: FR-004) (code_ref: scenes/loading_screen/loading_screen.tscn, scripts/app_theme.gd, tests/app_theme_check.gd | knowledge_ref: n/a — documented in T029/T031)
- [X] T014 [P] [US2] Replace `icon.png` with a raster export of `assets/brand/mark_tile.svg`, rendered through a throwaway Godot headless script in `evidence/` (Implements: FR-006) (code_ref: icon.png (rendered by evidence/render_icon.gd) | knowledge_ref: n/a — documented in T030)
- [X] T015 [US2] Set `theme_type_variation = &"PrimaryButton"` on `NewGameButton` in `scenes/menus/main_menu/main_menu_with_animations.tscn`. Other menu buttons inherit the default (secondary) Button style (Implements: FR-005) (code_ref: scenes/menus/main_menu/main_menu_with_animations.tscn (NewGameButton) | knowledge_ref: n/a — documented in T029)
- [X] T016 [P] [US2] Give the pause overlay in `scenes/overlaid_menus/` (project overlaid menu/pause scenes) an ink scrim at about 60% and a brand panel. If T001 found no CanvasLayer inheritance, also assign the app theme on the overlay's top Control (Implements: FR-007, FR-004) (code_ref: scenes/overlaid_menus/pause_menu.tscn (BackgroundColor scrim, CloseButton PrimaryButton); no per-overlay theme needed (T001) | knowledge_ref: n/a — documented in T029)
- [X] T017 [P] [US2] Restyle `scenes/credits/credits.tscn` text to brand fonts and colors. Remove the "Godot Engine Logo" credit, delete `assets/godot_engine_logo/`, and update `ATTRIBUTION.md` (drop the logo entry; note the mark-tile derivation). Creator credit and link stay in Credits (Implements: FR-004, FR-006, FR-012) (code_ref: scenes/credits/credits.tscn, ATTRIBUTION.md, assets/godot_engine_logo/ (removed), scripts/presentation/control_theme.gd (RichTextLabel fonts) | knowledge_ref: n/a — documented in T030)
- [X] T018 [P] [US2] Confirm that `resources/themes/*.tres` have no project or addon references (grep), then remove `resources/themes/` (plan expected_change_surface) (code_ref: resources/themes/ (removed; no path or uid references) | knowledge_ref: n/a — arrow-puzzle table updated in T031)
- [X] T019 [US2] Rendered inventory walk on desktop (QA-04): splash, loading, Main Menu, Level Select, the five Options tabs including dropdown popups and the reset confirmation, Credits, Pause, Results and tooltips, with screenshots in `evidence/`. Then walk every menu path with keyboard-only, gamepad-only and mouse-only input, and remap one key and one gamepad button across a restart, confirming existing audio/video settings load unchanged (QA-07; constitution III, VI) (Implements: FR-004, FR-008, FR-012, FR-017) (code_ref: n/a — verification (evidence/us2/RESULTS.md inventory, 0 default-styled surfaces; evidence/owner_checks.md: keyboard and mouse pass; physical gamepad and real-key splash skip not tested, disclosed) | knowledge_ref: n/a — verification only)

**Checkpoint**: SC-002 shows 0 default-styled surfaces, the focus ring is visible everywhere, and remapping works.
**Checkpoint**: Phase complete — 2026-10-17 (0 default-styled surfaces; owner keyboard and mouse walk passed; gamepad disclosed as not physically tested)

## Phase 5: User Story 3 — A Main Menu and Level Select that invite play (Priority: P2)

**Goal**: An ink hero split Main Menu and a grouped card grid in Level Select (R5).

**Independent Test**: QA-08 and QA-10; FR-010, FR-011.

- [X] T020 [US3] In `scenes/menus/main_menu/main_menu_with_animations.tscn`:
  - add a project hero panel (left about 40%, ink) holding the mark tile, a title label using the template config-name label script (cream, with "Spark" in ember), and the tagline;
  - re-anchor the inherited `MenuContainer`, `OptionsContainer`, `CreditsContainer`, `LevelSelectContainer` and `FlowControlContainer` to the right cream column;
  - hide the inherited title and subtitle labels (keeping the nodes) and retarget the animation tracks to the hero;
  - touch `main_menu_with_animations.gd` only if the ember "Spark" split cannot be expressed in the scene (Implements: FR-010, FR-012)

  (code_ref: scenes/menus/main_menu/main_menu_with_animations.tscn (Hero panel, re-anchored containers, retargeted Intro/OpenMainMenu/OpenSubMenu/RESET tracks) | knowledge_ref: n/a — documented in T029/T030)
- [X] T021 [US3] In `scenes/menus/main_menu/puzzle_select_menu.gd` and `.tscn`, change each group section to a `GridContainer` of card-styled entry Buttons using that group's `LevelCard` variation, and style headers as section headings. All pinned contracts listed above stay unchanged (Implements: FR-011) (code_ref: scenes/menus/main_menu/puzzle_select_menu.gd (GROUP_CARD_VARIATIONS, GridContainer sections, LevelGroupHeader); scenes/menus/main_menu/main_menu_with_animations.tscn (LevelSelectContainer margins) | knowledge_ref: n/a — documented in T031)
- [X] T022 [US3] Update `tests/puzzle_layout_check.gd` to check that:
  - every entry uses its group's `LevelCard` variation;
  - each section is a grid;
  - the hero title text equals `config/name`;
  - `NewGameButton` uses `PrimaryButton`;
  - Main Menu action order is unchanged.

  Existing assertions are untouched (Implements: FR-010, FR-011, FR-005) (code_ref: tests/puzzle_layout_check.gd::_check_menu_brand_layout | knowledge_ref: n/a — test only)
- [X] T023 [US3] Rendered check (QA-08): open Level Select from the Main Menu and from Results at 1280×720 and 1920×1080. Confirm group order and numbering, collapse, and that the card opens the right puzzle. Capture the longest titles and the French locale Main Menu for clipping, and record in `evidence/` (Implements: FR-010, FR-011) (code_ref: n/a — verification only (evidence/us3/RESULTS.md, evidence/level_select_check.gd) | knowledge_ref: n/a — verification only)

**Checkpoint**: Captures match the clarified layout, and the pinned contracts and gates stay green.
**Checkpoint**: Phase complete — 2026-10-16 (hero split layout and accented Level Select cards rendered; 0 clipped titles; layout/canvas checks 0 failures)

## Phase 6: User Story 4 — Polished motion, background and sound (Priority: P3)

**Goal**: Brand-timed transitions, a hero backdrop motif, and menu-only UI sounds (R4, R6).

**Independent Test**: QA-06 and QA-09; SC-004.

- [X] T024 [US4] Retime the work so that interactive Main Menu arrives in under 3 s and transitions take ≤300 ms with ease-out (QA-06):
  - the splash exports in `scenes/opening/opening_with_logo.tscn`;
  - the Intro, OpenMainMenu and OpenSubMenu animations in `scenes/menus/main_menu/main_menu_with_animations.tscn` (Intro about 1.0 s, staggered; sub-menu fades 200 ms);
  - a 200 ms pause-scrim fade in `scenes/overlaid_menus/` (Implements: FR-013)

  (code_ref: scenes/opening/opening_with_logo.tscn (timing exports), scenes/menus/main_menu/main_menu_with_animations.tscn (Intro 0.8 s, OpenSubMenu/RESET fades), scenes/overlaid_menus/pause_menu.tscn (FadeInPlayer) | knowledge_ref: n/a — documented in T029)
- [X] T025 [P] [US4] Create `scenes/menus/main_menu/menu_backdrop.gd`, a low-contrast arrow motif drawn once from `GameVisualStyle` geometry ratios with a slow single-transform drift (no per-frame rebuild), active only while the menu is visible. Add it behind the hero content in `main_menu_with_animations.tscn` (Implements: FR-014) (code_ref: scenes/menus/main_menu/menu_backdrop.gd, scenes/menus/main_menu/main_menu_with_animations.tscn (BackdropClip/Backdrop), tests/app_theme_check.gd (backdrop contrast) | knowledge_ref: n/a — documented in T029)
- [X] T026 [P] [US4] Author three original short UI sounds (focus tick, press, tab/slider) as `assets/audio/ui/*.wav` using an offline generator kept in `evidence/`, and record them as original in `ATTRIBUTION.md` (Implements: FR-015) (code_ref: assets/audio/ui/focus.wav, assets/audio/ui/press.wav, assets/audio/ui/tab.wav, ATTRIBUTION.md (generator kept in evidence/generate_ui_sounds.py) | knowledge_ref: n/a — documented in T029/T030)
- [X] T027 [US4] Assign the T026 streams to the Main Menu's `UISoundController` in `main_menu_with_animations.tscn`, and add a `UISoundController` (SFX bus) to the project pause overlay scene. Puzzle HUD and Results get no controller (Implements: FR-015, FR-016) (code_ref: scenes/menus/main_menu/main_menu_with_animations.tscn (UISoundController streams), scenes/overlaid_menus/pause_menu.tscn (UISoundController) | knowledge_ref: n/a — documented in T029)
- [X] T028 [US4] Rendered check (QA-06, QA-09): time a cold launch to an interactive menu, confirm skip inputs, and confirm transitions never block input. Then confirm menu and pause sounds play, are silent at SFX=0 and Master=0 (the spec's "UI volume" is the SFX control; no new control), and that HUD and Results stay silent. Record in `evidence/` (resolves: analyze-003) (Implements: FR-013, FR-014, FR-015) (code_ref: n/a — verification only (evidence/us4/RESULTS.md, evidence/motion_sound_check.gd) | knowledge_ref: n/a — verification only)

**Checkpoint**: SC-004 is met, and sounds respect volume settings.
**Checkpoint**: Phase complete — 2026-10-16 (launch to interactive 2.6 s; fades ≤300 ms; backdrop drifts; menu and pause sounds on SFX→Master; HUD and Results silent)

## Final Phase: Polish & Cross-Cutting Concerns

- [X] T029 Rewrite `.knowledge/architecture/game-visual-system.md` as current truth:
  - app-wide theme via `AppTheme`;
  - control coverage and the added tokens;
  - stretch behavior;
  - launch/splash/icon;
  - motion timings;
  - backdrop;
  - menu-only UI sound.

  Add `scripts/app_theme.gd`, `scripts/presentation/control_theme.gd`, `scenes/menus/main_menu/menu_backdrop.gd`, `tests/app_theme_check.gd` and `assets/ui/**` to `appliesTo`. Remove the "never root/project theme" rule (Implements: FR-018) (code_ref: n/a — knowledge only | knowledge_ref: .knowledge/architecture/game-visual-system.md, .knowledge/index.json)
- [X] T030 [P] Update `.knowledge/product/branding.md`: the mark tile on splash, hero and app icon; the Main Menu hero composition; the Credits content after logo removal; the unchanged gameplay recede rule (Implements: FR-018, FR-012) (code_ref: n/a — knowledge only | knowledge_ref: .knowledge/product/branding.md)
- [X] T031 [P] Update `.knowledge/architecture/arrow-puzzle.md` (the "Gameplay theme boundary" section's "No root/global theme" sentence and the template-integration table: loading screen, autoload, overlay) and `.knowledge/architecture/save-progression.md` Level Select wording, if it describes layout (Implements: FR-018) (code_ref: n/a — knowledge only | knowledge_ref: .knowledge/architecture/arrow-puzzle.md (save-progression.md reviewed: describes Level Select behavior, not layout; unchanged))
- [X] T032 [P] Update `.knowledge/architecture/web-showcase.md` for the ink boot hand-off and canvas scaling in the browser, including the accepted limitation that small low-density touch screens may render the UI smaller and are untested (critic-002), and update `tests/README.md` to describe `tests/app_theme_check.gd` in the puzzle gate list (Implements: FR-018) (code_ref: tests/README.md | knowledge_ref: .knowledge/architecture/web-showcase.md)
- [X] T041 Reword only the message of the assertion at `tests/puzzle_presentation_check.gd:311` so it says the puzzle carries its own theme reference (not that root overlays stay unthemed). The boolean expectation is unchanged (resolves: analyze-002) (code_ref: tests/puzzle_presentation_check.gd (message only; expectation unchanged) | knowledge_ref: n/a — test message only)
- [X] T033 Run `--headless --editor --quit` validation (Godot 4.4.1, plus a fresh copy without `.godot/` to mirror CI) and confirm no new SCRIPT ERROR beyond the CI allow-list. Run both gates and record exit codes and failure counts (constitution V) (code_ref: n/a — verification (fresh-copy editor: 0 SCRIPT ERROR; puzzle gate 11/11 counts 0; REGRESSION_FAILURES=0) | knowledge_ref: n/a — verification only)
- [X] T034 Export the Web build with Godot 4.4-stable (`node web/scripts/export-game.mjs`), then serve locally and smoke-test in Firefox and Chrome: launch hand-off, menus, pause and a puzzle at a 960×540 and a full-window canvas (QA-04 web, QA-10). Record any untested browser as not tested (constitution V) (code_ref: n/a — verification (evidence/owner_checks.md: Chrome, Firefox, Perplexity, VS Code browser pass; Edge not tested) | knowledge_ref: n/a — verification only)
- [X] T035 ~~Real-phone landscape smoke~~ removed from this spec by owner decision (2026-10-17); preserved as a Future Work Plan in `.devspark.work/intake/future-mobile-ui-scaling-verification-owner-2026-10-17.md` (code_ref: n/a — moved to future spec by owner | knowledge_ref: n/a — web-showcase.md already records that larger phone menus await real-device re-verification)
- [X] T036 Assemble the screenshot set (every screen at 1280×720, 1920×1080 and 3840×2160, plus phone) in `evidence/` and obtain the owner's sign-off (QA-11, SC-007) (code_ref: n/a — verification (evidence/owner_checks.md: owner approval 2026-10-17; screenshots in evidence/us1–us4) | knowledge_ref: n/a — verification only)
- [ ] T037 Record `verify:end-to-end` evidence from T009, T010, T019, T023, T028 and T033–T036 in `gates/verify.md` via `/devspark-verify` (spec required_gates) (code_ref: pending | knowledge_ref: pending)
- [X] T038 Scan durable changes (code, tests, `.knowledge/`, `ATTRIBUTION.md`, `README.md`) for spec/plan/task/FR/SC/QA identifiers or `.devspark.work` links. Populate every task's `code_ref`/`knowledge_ref`, and retain the complete feature directory in `.devspark.work/` (preamble §0) (code_ref: n/a — scan: 67 durable files changed, 0 planning identifiers in added lines; check-planning-references hits are pre-existing false positives in untouched files (addon PNGs, BeVietnamPro-Medium.ttf, repo-story history.json); linkage populated per task | knowledge_ref: n/a — verification only)

---

## Dependencies

- T001 gates the fallback branch of T016.
- T039 follows T008, and T040 follows T039. T041 precedes T033 so the gates run against the reworded message.
- T002 precedes T012, T014 and T020. T003 precedes T005.
- T004 → T005 → T006 → T007, and the Foundational phase precedes all stories.
- T013 depends on T006 (loader path).
- T020 precedes T024 (animation retargeting) and T025 (hero host). T026 precedes T027.
- US3 and US4 depend on US1 and US2 for scaling and theme. US1 and US2 are independent of each other after Foundational.
- T029–T032 follow the implementation they describe. T033–T037 follow all implementation tasks.

## Gate Acknowledgements

- Gate: verify (constitution V, mobile web beta real-phone check)
- Concern: the scaled UI and touch feel (QA-10 phone, QA-07 touch) are not verified on a real phone in this spec
- Decision: proceed and close. Phone verification moves to a future spec (Future Work Plan in `.devspark.work/intake/`). No phone readability claim is made, and web-showcase knowledge discloses the gap.
- Recorded By: project owner ("approve closing the task for mobile testing, we will address in a future spec, not hold up this one")
- Date: 2026-10-17

- Gate: verify (constitution III, supported input methods)
- Concern: no physical gamepad menu walk or real-key splash skip; keyboard and mouse were verified by the owner, and gamepad navigation was simulated
- Decision: proceed, disclosed as not tested. Mouse-only gameplay is accepted as existing behaviour.
- Recorded By: project owner ("menu with keyboard is fine, game play requires mouse which is FINE, accepted")
- Date: 2026-10-17
