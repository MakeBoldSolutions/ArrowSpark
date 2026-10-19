# Automated evidence

Candidate baseline: 5d99c02, working branch 017-spec-mobile-portrait-play. No commit or deployment was requested.

Godot 4.4.1 stable is the validated 4.4-series patch binary. The original 4.4.0 wrapper fails its isolated editor import with SceneLoader undeclared; the identical error reproduces on baseline (baseline-isolated-import.log). This is not counted as a passing 4.4.0 wrapper. The web candidate is exported with the installed 4.4.stable templates and official 4.4.0 executable.

Actual commands:

```powershell
python tests/run_puzzle_regressions.py --godot "$env:TEMP/arrowspark-tools/Godot_v4.4.1-stable_win64_console.exe"
python tests/run_regressions.py --godot "$env:TEMP/arrowspark-tools/Godot_v4.4.1-stable_win64_console.exe"
npm run check --prefix web
node web/scripts/export-game.mjs --godot "$env:TEMP/arrowspark-tools/Godot_v4.4-stable_win64_console.exe" --build portrait
$env:PUBLIC_GAME_BUILD='portrait'
npm run build --prefix web
```

Raw output: puzzle-regressions441-final.log, settings-regressions441-final.log, web-check.log, export.log, web-build.log. Final puzzle launcher includes portrait_menu_check.gd. Negative recovery tests deliberately emit settings-write errors; analyzer deliberately asserts on null input. Headless remap icons report unsupported physical-key translation; this is not hardware verification.

Supplemental direct scene output: layout-final.log, canvas-final.log, presentation-final.log, focused-layout.log and menu-matrix.log. The rendered menu matrix uses actual iframe widths 320/350/372, not advertised page widths. Results checks use those same widths and scroll each metric/action into view. The original two-frame resize check was corrected to let logical scaling and container layout settle, and to compare against the logical viewport. No rule, score, catalog or persistence expectations were relaxed.

The initial narrow check exposed a 361-pixel action minimum at the 320-pixel iframe. Portrait now labels the same Fit Puzzle action “Fit”; narrow checks assert the game layout itself fits the iframe width.

Final full 4.4.1 wrapper exit: 0. Actual completion markers:

```text
PUZZLE_FAILURES=0
PUZZLE_ANALYZER_FAILURES=0
PUZZLE_CATALOG_FAILURES=0
PUZZLE_SCOREBOARD_FAILURES=0
ARROW_DEPARTURE_GEOMETRY_FAILURES=0
PUZZLE_VIEWPORT_FAILURES=0
PUZZLE_LAYOUT_FAILURES=0
PUZZLE_CANVAS_FAILURES=0
PUZZLE_PRESENTATION_FAILURES=0
APP_THEME_FAILURES=0
PORTRAIT_MENU_FAILURES=0
REGRESSION_FAILURES=0
Tests 59 passed (59)
```
