# US2 rendered evidence (2026-10-16, Godot 4.4.1 rendered at 1280×720, isolated user data; inventory.gd)

## QA-04 / SC-002: surface inventory

| Surface | Capture | Result |
|---|---|---|
| Splash | 01_splash | Ink background, Make Bold mark tile; no engine logo. Boot splash is ink with no image (project.godot). |
| Loading screen | 02_loading_screen | Ink, cream text, rust progress bar. Loader wiring asserted in tests/app_theme_check.gd. |
| Main Menu | 03_main_menu | Cream background, rust primary New Game, white secondary buttons, ember focus ring. |
| Level Select | 04_level_select | Brand buttons and fonts. The card redesign follows in US3. |
| Options (5 tabs) | 05_options_* | Rust-underlined selected tab; brand sliders, toggles, dropdowns and remap buttons. |
| Dropdown popup | 06_options_3_dropdown | White panel, radio icons, ember selection. Item clipping fixed with item_end_padding. |
| Reset confirmation | 07_reset_confirmation | White branded dialog, ember focus ring. |
| Credits | 08_credits | Brand typography. Emphasis uses semibold; the faux italic was rejected. Godot-logo credit replaced by a Brand entry. |
| Puzzle HUD | 09_puzzle | Unchanged roles. |
| Pause | 10_pause | Ink 60% scrim, white card, rust primary Resume. |
| Results | 11_results | Unchanged presentation (frozen by FR-012). |
| Tooltips | — | Styled in the theme (ink panel, cream text). No rendered capture: hover tooltips cannot be forced without a real pointer delay. Owner check. |

Default-styled surfaces found: 0.

## QA-07: navigation (simulated input events)

- Keyboard `ui_down`: NewGameButton > LevelSelectButton > OptionsButton > CreditsButton > ExitButton.
- Gamepad D-pad up: CreditsButton > OptionsButton > LevelSelectButton.
- The focused control shows the ember ring.
- Remap persistence across restart is covered by `tests/run_regressions.py` (REGRESSION_FAILURES=0).

**Outstanding (manual, owner):** a physical keyboard-only, gamepad-only and mouse-only walk of every menu path. Simulated events are not proof of a physical controller (constitution III).
