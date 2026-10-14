```yaml
gate: verify
devspark_version: "9.1.0"
generated: "2026-10-14T13:00:00Z"
status: pass
blocking: false
summary: "End-to-end proof passes: the real Godot 4.4 Web export, served by the site, was played by script through all nine ArrowSpark levels to Results with 0 mistakes, each completion posted a valid hand-off message, and the owner confirmed desktop and phone play. Both regression gates pass on the pinned Godot 4.4 and on 4.7.2. One gap found by this run (the SC-009 literal check) was closed with a new test before this artifact was written."
modes:
  - mode: end-to-end
    evidence_class: local-integration
    status: pass
    test_ref: "tests/puzzle_canvas_check.gd::_check_corner_reach_for_every_catalog_size; tests/puzzle_viewport_transform_check.gd::_test_corner_reach; tests/puzzle_catalog_check.gd::_check_progression_levels"
    evidence: |
      Applicability (verification contract 2.2):
        Empirical verification: REQUIRED (end-to-end)
        Reason: environment-dependent-behavior; camera input and rendering depend on the browser, GPU and device, which the headless tests do not observe.
      Build under test: Godot 4.4-stable (SHA-512 verified from the official release) exported with
        Godot_v4.4-stable_win64_console.exe --headless --path <clean copy> --export-release Web web/public/game/local/index.html
        (no ERROR lines; index.wasm 43,682,606 bytes). Served by PUBLIC_GAME_BUILD=local npx astro dev --host; reached at http://localhost:4321/play/ by headless Chrome and, through an HTTPS proxy, at https://192.168.1.233:4443/play/ by a Pixel 7 Pro.
      Command (this session, final run): node solveall3.mjs 1,2,3,4,5,6,7,8,9  (playwright-core driving Chrome; clicks every arrow in solver order)
        {"level":1,"arrows":9,"resultsShown":true,"secondsLastClickToResults":0.86}
        {"level":2,"arrows":15,"resultsShown":true,"secondsLastClickToResults":2.12}
        {"level":3,"arrows":14,"resultsShown":true,"secondsLastClickToResults":1.18}
        {"level":4,"arrows":17,"resultsShown":true,"secondsLastClickToResults":2.07}
        {"level":5,"arrows":23,"resultsShown":true,"secondsLastClickToResults":2.37}
        {"level":6,"arrows":30,"resultsShown":true,"secondsLastClickToResults":2.09}
        {"level":7,"arrows":68,"resultsShown":true,"secondsLastClickToResults":2.75}
        {"level":8,"arrows":93,"resultsShown":true,"secondsLastClickToResults":1.17}
        {"level":9,"arrows":115,"resultsShown":true,"secondsLastClickToResults":2.99}
        no console errors
      Mistakes: the level 8 and 9 Results screens read "Mistakes: 0" and "Accuracy: 100.0%" (earlier run, same code); the session total 384 equals 9+15+14+17+23+30+68+93+115.
      Completion hand-off (same kind of run with a window message listener), one message per level, each with the eight contract keys:
        {"puzzleId":"first_knot","puzzleVersion":"g1-8f675c5f02cc","mistakes":0,"openMoveAssists":0,"score":9,...}
        two_neighborhoods g1-ecf87d2e92ec, the_bridge g1-1fa47c6f7736, false_simplicity g1-d324da959318, the_rescan g1-6f5cf54bbf35, major_release g1-f916a6ea8496, dense_weave g1-030c1402781a, almost_a_knot g1-76fa1582e5a2
        {"puzzleId":"reference_knot","puzzleVersion":"g1-7ce0942d4a5e","mistakes":0,"openMoveAssists":0,"score":115,...}
        Every version equals the value pinned in tests/puzzle_catalog_check.gd; the Reference Knot version is unchanged.
      Camera (screenshots, First Knot zoomed, held keys): with the top-left board corner at the camera center the arrows sit only in the lower-right quadrant; with the bottom-right corner centered, only in the upper-left.
      Departures (screenshot sequence, board right edge at the screen center): at about 0.6 s the exiting arrow head is far past the board edge and not sliced; at about 1.1 s its tail is still leaving the view.
      Owner, hands-on on 2026-10-14: desktop (Chrome, Firefox, the VS Code internal browser, Perplexity browser) wheel zoom, middle-drag, keyboard menu navigation, Replay and mouse play work; Pixel 7 Pro in Chrome: all levels played, pinch zoom and one-finger drag without issue.
      Automated gates on Godot 4.4-stable from a clean copy (final code, including the new every-catalog-size corner check):
        python tests/run_puzzle_regressions.py --godot Godot_v4.4-stable_win64_console.exe  -> exit 0
        PUZZLE_FAILURES=0 PUZZLE_ANALYZER_FAILURES=0 PUZZLE_CATALOG_FAILURES=0 PUZZLE_SCOREBOARD_FAILURES=0 ARROW_DEPARTURE_GEOMETRY_FAILURES=0 PUZZLE_VIEWPORT_FAILURES=0 PUZZLE_LAYOUT_FAILURES=0 PUZZLE_CANVAS_FAILURES=0 PUZZLE_PRESENTATION_FAILURES=0
        python tests/run_regressions.py --godot Godot_v4.4-stable_win64_console.exe  -> exit 0, REGRESSION_FAILURES=0
        PASS: every catalog board size can bring each corner to the viewport center (176 cases, 0 misses)   [23 distinct sizes]
        The same gate also passes on Godot 4.7.2; editor validation (--headless --editor --quit) on a fresh project copy: exit 0, no error lines.
      This evidence is local-integration. Nothing was deployed.
discovered:
  - "SC-009 asked for corner centering over every distinct catalog board size; the transform check covered five shapes. Found by this run and closed with tests/puzzle_canvas_check.gd::_check_corner_reach_for_every_catalog_size (23 sizes, 176 cases, 0 misses)."
  - "On a Pixel 7 Pro the menus and Results screens between levels are very small and hard to read, especially in fullscreen."
  - "The Play page admission rule measures the visible page area, so on a landscape phone with the browser address bar showing the page can say the screen is too small until the bar hides."
  - "Godot's loader refuses a non-secure origin, so the game cannot start over plain HTTP on a local network; this only affects local testing."
  - "With the camera at a board edge and fully zoomed out, the area beyond the edge spans many cells, so departure removal at the 6-cell margin may still be visible there; not exercised in the browser."
  - "Headless synthetic mouse drags did not move the view; the owner confirmed real middle-drag works."
  - "Edge failed to launch under automation; Safari, Edge, iPhone, gamepad, the pause menu and Open Move at an edge were not exercised."
  - "The structural step from almost_a_knot to the Reference Knot is large (depth 12 to 33, average length 7.4 to 11.7)."
```
