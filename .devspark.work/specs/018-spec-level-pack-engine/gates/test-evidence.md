```yaml
- commit: 5e4c2f44a3de1e2d6479dd35d65288a7fd7c3bda
  tree: dirty
  command: python tests/run_puzzle_regressions.py --godot "$LOCALAPPDATA/Temp/ArrowGame-Godot-4.4.1/bin/Godot_v4.4.1-stable_win64_console.exe"
  result: "13 suites, every *_FAILURES=0 marker present (PUZZLE, ANALYZER, PACK_FORMAT, GENERATOR, CATALOG (34 entries), SCOREBOARD, ARROW_DEPARTURE_GEOMETRY, VIEWPORT, LAYOUT, CANVAS, PRESENTATION, APP_THEME, PORTRAIT_MENU); exit 0; failing: none"
  run_at: 2026-10-23T14:20:00Z
  run_by: implement
- commit: 5e4c2f44a3de1e2d6479dd35d65288a7fd7c3bda
  tree: dirty
  command: python tests/run_regressions.py --godot "$LOCALAPPDATA/Temp/ArrowGame-Godot-4.4.1/bin/Godot_v4.4.1-stable_win64_console.exe"
  result: "REGRESSION_FAILURES=0; exit 0; failing: none"
  run_at: 2026-10-23T14:21:00Z
  run_by: implement
- commit: 5e4c2f44a3de1e2d6479dd35d65288a7fd7c3bda
  tree: dirty
  command: Godot 4.4.1 --headless --path <fresh copy without .godot/.git/web/.devspark.work> --editor --quit (twice, CI pattern)
  result: "both passes exit 0; 0 SCRIPT ERROR lines"
  run_at: 2026-10-23T14:26:00Z
  run_by: implement
```

The tree was dirty because the change is not yet committed. These records are not reusable for review until rerun on the committed tree.
