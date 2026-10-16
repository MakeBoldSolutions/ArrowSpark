# QA Acceptance: Game UI Improvements

Acceptance scenarios for the delta. Temporary; never referenced by durable files.

| ID | Trace | Surface | Scenario | Runner | Regression |
|---|---|---|---|---|---|
| QA-01 | SC-001, FR-001 | Desktop | Given windows of 1280×720, 1920×1080, 2560×1440 and 3840×2160, When Main Menu shows, Then the title and Play button heights as fractions of screen height agree within ±5% | manual | none (rendered-only; gates do not load display settings) |
| QA-02 | FR-002 | Desktop | Given 21:9 and 4:3 windows, When Main Menu, Level Select, Options and Pause show, Then content is centered and fully visible with the background filling the extra space | manual | none (rendered-only) |
| QA-03 | SC-006, FR-016 | Desktop | Given the first progression level and the Reference Knot, When played with the same move sequence as on main, Then moves, mistakes and score match, and fit/zoom/pan behave the same | manual | none (both gates already pin rules and layout) |
| QA-04 | SC-002, FR-004, FR-006 | Desktop + Web | Given a fresh launch, When every reachable surface is visited (splash, loading, Main Menu, Level Select, the 5 Options tabs incl. dropdown popups and the reset confirmation, Credits, Pause, Results, tooltips), Then none shows engine-default styling, fonts or logo | manual | none (owner inventory) |
| QA-05 | SC-003, FR-003, FR-009 | Automated | Given the app theme, When each listed control type and palette text pair is inspected headlessly, Then each resolves brand styles, targets are ≥48 px tall and text pairs meet AA | automated | add `tests/app_theme_check.gd` |
| QA-06 | SC-004, FR-013 | Desktop + Web | Given a cold launch, When no input is given, Then Main Menu is interactive under 3 s after the splash appears; When any skip input is given, Then it advances immediately | manual | none |
| QA-07 | SC-005, FR-008 | Desktop + Phone | Given keyboard-only, gamepad-only, mouse-only and touch-only play, When all Main Menu, Level Select, Options, Pause and Credits paths are walked, Then every control is reachable with a visible ember focus and input remapping still works | manual | none (existing remap regressions remain in `tests/run_regressions.py`) |
| QA-08 | FR-011 | Desktop | Given Level Select, When opened from the Main Menu and from Results, Then all catalog entries appear once in the current group/order/numbering as cards, collapsing works, and each card opens its puzzle | hybrid | none (existing Level Select regressions cover order and selection) |
| QA-09 | FR-007, FR-015 | Desktop + Web | Given a puzzle, When Pause opens, Then an ink scrim and brand panel show and menu sounds play; When SFX or Master is 0, Then no UI sound plays; puzzle HUD and Results buttons stay silent | manual | none |
| QA-10 | FR-003, R1 | Phone + Web | Given the reference phone in landscape and a 960×540 desktop browser canvas, When menus show, Then text and targets are legible/tappable and, on the phone, not smaller than on main | manual | none |
| QA-11 | SC-007 | Owner | Given a screenshot set of every screen at three desktop sizes plus phone, When the owner reviews it beside the showcase site, Then they sign off that it reads as the same brand and a finished game | manual | none |
