```yaml
gate: verify
devspark_version: "9.2.0"
generated: "2026-10-17T05:23:59Z"
status: pass
blocking: false
summary: "end-to-end PASS at HEAD 6615bdd: both regression gates green (11/11 counts 0, 7620 PASS lines); rendered desktop flows at six window sizes, gameplay parity with main, full surface inventory, motion/sound checks; local web build approved by the owner in Chrome, Firefox and two Chromium-based browsers. Phone verification moved to a post-deploy Future Work Plan by owner amendment."
modes:
  - mode: end-to-end
    evidence_class: local-integration
    status: pass
    test_ref:
      - tests/app_theme_check.gd
      - tests/puzzle_layout_check.gd::_check_menu_brand_layout
      - tests/puzzle_canvas_check.gd::_check_touch_slop_is_physical_under_scaling
    evidence: |
      Engine: Godot 4.4.1-stable (gates, rendered runs); Godot 4.4-stable (web export).
      Rendered runs used a fresh isolated APPDATA per run.

      1. Regression gates at HEAD 6615bdd (this session, 2026-10-17):
         $ python tests/run_puzzle_regressions.py --godot <4.4.1 console>
           puzzle exit=0
           PUZZLE_FAILURES=0 PUZZLE_ANALYZER_FAILURES=0 PUZZLE_CATALOG_FAILURES=0
           PUZZLE_SCOREBOARD_FAILURES=0 ARROW_DEPARTURE_GEOMETRY_FAILURES=0
           PUZZLE_VIEWPORT_FAILURES=0 PUZZLE_LAYOUT_FAILURES=0 PUZZLE_CANVAS_FAILURES=0
           PUZZLE_PRESENTATION_FAILURES=0 APP_THEME_FAILURES=0   (7620 PASS lines)
           PASS: a 2560x1440 window stretches the 1280x720 design by 2 (got 2.00)
           PASS: a drift under the physical slop still taps at a stretch scale of 2
           PASS: a drag past the physical slop pans and never selects at a stretch scale of 2
           PASS: the hero title reads the product name
           PASS: Play/New Game is the single primary action
           PASS: every Level Select entry uses its group's card variation
           PASS: the scene loader uses the branded loading screen
         $ python tests/run_regressions.py --godot <4.4.1 console>
           regress exit=0   REGRESSION_FAILURES=0
         Mutation check: reverting the touch-slop correction makes
           "a drag past the physical slop pans..." FAIL (PUZZLE_CANVAS_FAILURES=1).

      2. Fresh-copy editor validation, mirroring CI (tar without .godot/.git/web, two --editor --quit passes):
           fresh-copy script errors: 0 (allow-listed: 0). scenes/opening/opening.gd untouched.

      3. Scaling (evidence/capture_menus.gd; evidence/us1/RESULTS.md):
           MEASURE 1280x720  scale=1.000 title_frac=0.0931 play_frac=0.0681 play_px=49.0
           MEASURE 1920x1080 scale=1.500 title_frac=0.0931 play_frac=0.0694 play_px=75.0
           MEASURE 2560x1440 scale=2.000 title_frac=0.0931 play_frac=0.0681 play_px=98.0
           MEASURE 3840x2160 scale=3.000 title_frac=0.0931 play_frac=0.0681 play_px=147.0
           MEASURE 2560x1080 scale=1.500 (21:9, content centred)
           MEASURE 1280x960  scale=1.000 (4:3, expand adds height)
         After the hero layout: title_frac 0.1278 at 1280x720 and 0.1269 at 1920x1080 (evidence/us3).

      4. Gameplay parity (evidence/gameplay_smoke.gd: one blocked tap, then the solver witness):
           main   @1280x720  first_knot     {"mistakes":1,"score":8,"accuracy":0.9}
           branch @1280x720  first_knot     identical; branch @2560x1440 identical
           main   @1280x720  reference_knot {"mistakes":1,"score":114,"accuracy":0.991379310344828}
           branch @1280x720  reference_knot identical; branch @2560x1440 identical

      5. Surface inventory and navigation (evidence/inventory.gd; evidence/us2/RESULTS.md):
           SAVED 01_splash … 11_results (splash, loading, main menu, level select, 5 options tabs,
           dropdown, reset confirmation, credits, puzzle, pause, results). Default-styled surfaces: 0.
           FOCUS keyboard NewGameButton > LevelSelectButton > OptionsButton > CreditsButton > ExitButton
           FOCUS gamepad  CreditsButton > OptionsButton > LevelSelectButton
           FOCUS ring_ember=true

      6. Main Menu and Level Select (evidence/level_select_check.gd; evidence/us3/RESULTS.md):
           CHECK opened_from_results=true
           CHECK clipped_titles=[]
           main_menu_fr: no clipping

      7. Motion and sound (evidence/motion_sound_check.gd, evidence/probe_skip.gd; evidence/us4/RESULTS.md):
           TIMING launch_to_interactive_ms skip=false 2575   (main baseline about 5.4 s)
           PROBE intro unlock: no input 900 ms (main 2515); accept or click 276-277 ms (main 276)
           CHECK backdrop_drifts=true processing=true
           CHECK menu_sound_players=4 buses=["SFX","SFX","SFX","SFX"] sfx_sends_to=Master
           CHECK menu_focus_sound_plays=true
           CHECK pause_sound_players=4 pause_focus_sound_plays=true
           CHECK hud_silent=true  hud_silent_after_pause=true  results_silent=true

      8. Web build and browsers (local-integration):
           $ node web/scripts/export-game.mjs --godot <4.4-stable>   -> build 5d045e5
           Served by the local Astro dev server at http://localhost:4321/play/ (game/local refreshed
           with 5d045e5; HTTP 200, index.pck 1222032 bytes).
           Owner smoke, 2026-10-17: Chrome, Firefox, Perplexity (Chromium) and the VS Code internal
           browser (Chromium) all pass; Edge not tested individually. Keyboard menu navigation passes
           (owner). Mouse-only gameplay accepted as existing behaviour. Owner approval: "all look
           great, totally approve!" (evidence/owner_checks.md)
discovered:
  - "Synthetic ui_cancel/ui_accept releases during the splash do not reach the menu within 6 s, on main and on the branch alike (pre-existing; not caused by this change)."
  - "The template's French menu strings are partial (New Game and Level Select stay English); pre-existing."
  - "Results shows two rust primary buttons (Replay and Next Puzzle); existing Results presentation, frozen by FR-012."
  - "check-planning-references reports matches only in files this branch did not touch (addon PNG bytes, BeVietnamPro-Medium.ttf, repo-story history.json); the branch's own delta carries no planning identifiers."
  - "Hover tooltips have no rendered capture (a real pointer delay is needed); their styling is asserted in tests/app_theme_check.gd."
  - "A physical gamepad walk and a real-key splash skip were not performed (gamepad simulated; owner accepted via SC-005 amendment)."
  - "Process incident: a non-isolated 4K capture overwrote the owner's ArrowSpark video settings; restored, and all later runs isolated."
```
