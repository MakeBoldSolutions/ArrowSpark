```yaml
gate: verify
status: warn
blocking: false
summary: "end-to-end passes: fresh automated runs on Godot 4.4 (target) and 4.7.2 are green, performance is within budget, and the operator confirmed the desktop flow with mouse and keyboard. Gamepad and several desktop sub-scenarios remain outstanding (accepted by the operator, not claimed passed)."
modes:
  - mode: end-to-end
    status: pass
    test_ref: tests/puzzle_canvas_check.gd::_check_state_parity_across_navigation
    evidence: |
      Working tree on branch 008-spec-large-zoomable-canvas (base commit 924280f, changes uncommitted), run 2026-09-28 in this session.

      Godot 4.7.2 (in the repository, isolated APPDATA/XDG_DATA_HOME set by the launchers):
      - python tests/run_puzzle_regressions.py --godot godot -> exit 0
        PUZZLE_FAILURES=0 PUZZLE_ANALYZER_FAILURES=0 PUZZLE_CATALOG_FAILURES=0 PUZZLE_SCOREBOARD_FAILURES=0 ARROW_DEPARTURE_GEOMETRY_FAILURES=0 PUZZLE_VIEWPORT_FAILURES=0 PUZZLE_LAYOUT_FAILURES=0 PUZZLE_CANVAS_FAILURES=0 PUZZLE_PRESENTATION_FAILURES=0
      - python tests/run_regressions.py --godot godot -> exit 0, REGRESSION_FAILURES=0

      Godot 4.4-stable, the declared target (from a fresh mirror of the repo without .godot/.git/.devspark.work/.archive; `--headless --editor --quit` first, which printed 0 SCRIPT ERROR/Parse Error lines; two independent fresh mirrors):
      - python tests/run_puzzle_regressions.py --godot <4.4 console exe> -> exit 0 (both mirrors), all nine markers above = 0
      - python tests/run_regressions.py --godot <4.4 console exe> -> exit 0 (both mirrors), REGRESSION_FAILURES=0

      Performance (tests/puzzle_canvas_visual_check.gd, non-headless, real renderer, Godot 4.4, AMD Ryzen 9 7900X / AMD Radeon integrated, OpenGL 3, 1280x720, 52-arrow fixture, 8 overlapping departures, 2 s warmup + 10 s capture):
      VISUAL_FIXTURE samples=599 handler_p95_ms=0.091 frame_p95_ms=17.11 longest_frame_ms=19.9
      VISUAL_FIXTURE_WITHIN_BUDGET=true (handler <= 2.0 ms, frame p95 <= 33.3 ms, no frame >= 100 ms)

      Operator desktop testing, Windows 11, mouse and keyboard (evidence/desktop.md): fit, wheel zoom, pan, Fit, selection while zoomed, Show Me an Open Move reveal, long bent departure and clear-out, resize, level 15 difficulty/readability confirmed; blocked-feedback strengthening requested, implemented and relaunched.

      Environment finding (not a product defect): Godot 4.4 headless `--import` on a fresh project intermittently crashes (observed exit 3221225477 / 0xC0000005 in one run), and running `--editor --quit` on a project that already has a .godot cache from an earlier import produces `SceneLoader` parse errors that then fail later runs. Both explain the earlier intermittent 4.4 launcher failures. Reliable sequence: fresh mirror, `--editor --quit` first, then the launchers.
    outstanding: |
      - Gamepad: no device; only event-dispatch tests cover gamepad zoom/pan/fit and focus exits.
      - Not explicitly reported by the operator (automated tests only): blocked-feedback re-check after the change, pause/resume mid-departure, results/Replay/Next view reset, remapping a zoom action in settings, minimize/restore, Level Select scrolling at 960x540/800x800, 1920x1080.
```

# Verification Gate — 008 Large Zoomable Puzzle Canvas

Status `warn`: the declared `verify:end-to-end` mode passes on the evidence above, with the outstanding items disclosed and accepted by the operator on 2026-09-28. They are not claimed as passed. No test was weakened to reach this result.
