# Explicit verification run

DevSpark 9.2.0. Branch 017-spec-mobile-portrait-play; HEAD 5d99c022c0c5e0ff877a7667309fcfa61da4b9a7 plus working-tree changes. Candidate pack/build hashes and source identity are in verify-candidate.json. The clean-copy runtime/test files match the current tree byte-for-byte.

Declared proof: end-to-end, local-integration. No product deployment was performed.

## Actual automated commands and results

```powershell
python tests/run_puzzle_regressions.py --godot "$env:TEMP/arrowspark-tools/Godot_v4.4.1-stable_win64_console.exe"
# Workspace import crashed: exit 3221225477 (access violation); verify-puzzle.log.
# Current runtime/tests copied into a fresh temporary directory without .godot.
$copy=(Get-Content .devspark.work/specs/017-spec-mobile-portrait-play/evidence/verify-snapshot.json | ConvertFrom-Json).path
python "$copy/tests/run_puzzle_regressions.py" --godot "$env:TEMP/arrowspark-tools/Godot_v4.4.1-stable_win64_console.exe"
# Exit 0; verify-puzzle-clean.log. All eleven completion markers below.
python tests/run_regressions.py --godot "$env:TEMP/arrowspark-tools/Godot_v4.4.1-stable_win64_console.exe"
# Exit 0; REGRESSION_FAILURES=0; verify-settings.log.
npm run check --prefix web
# Exit 0; 59/59 tests; verify-web-check.log.
$env:PUBLIC_GAME_BUILD='portrait'
npm run build --prefix web
# Exit 0; verify-web-build.log.
```

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
```

The initial workspace crash is retained and not labeled passing. Clean-copy import and all real scene tests passed. Expected negative null-input and settings recovery diagnostics remain visible; headless physical-key icon lookup is unsupported and is not hardware testing.

## Actual browser commands

```text
node web/scripts/check-portrait-play.mjs http://localhost:4331/play/ .devspark.work/specs/017-spec-mobile-portrait-play/evidence/verify-chrome --chrome
node web/scripts/check-portrait-play.mjs http://localhost:4331/play/ .devspark.work/specs/017-spec-mobile-portrait-play/evidence/verify-firefox --firefox
node web/scripts/check-portrait-play.mjs http://localhost:4331/play/ .devspark.work/specs/017-spec-mobile-portrait-play/evidence/verify-firefox-retry --firefox
node .devspark.work/specs/017-spec-mobile-portrait-play/evidence/browser-journey.mjs
node .devspark.work/specs/017-spec-mobile-portrait-play/evidence/browser-journey.mjs --firefox
node .devspark.work/specs/017-spec-mobile-portrait-play/evidence/verify-firefox-fixtures.mjs http://localhost:4331/play/ .devspark.work/specs/017-spec-mobile-portrait-play/evidence/verify-firefox-configured --firefox
```

Chrome reports 10 fixtures passed. Both journey records show statusPixelsRetained=true, iframeRetained=true and errors=[]. Versions are recorded by their JSON artifacts.

The two default Firefox matrix attempts reached all eight touch fixtures, then timed out at the fine-pointer desktop fixture. A direct browser capability probe at 1280x720 recorded fine=false, coarse=false, verdict=larger. Admission correctly rejects that no-pointer environment. A separate fine-pointer Firefox probe recorded fine=true, coarse=false, verdict=play.

The evidence-only Firefox fixture wrapper is identical to the existing matrix except its two desktop contexts launch Firefox with ui.primaryPointerCapabilities=6 and ui.allPointerCapabilities=6. Touch fixtures retain default launch settings. It does not override admission, JavaScript matchMedia or page code. It configures the simulated pointer expected by the desktop fixture; it is still emulated input, not physical hardware evidence. The wrapper and raw logs are retained for reproduction.

Physical desktop input: owner reported “yes” to the requested mouse/keyboard/gamepad checks during this run; see desktop-input.md for the exact scope and limits. Real Pixel acceptance remains post-deploy under the existing intake record. Edge/Brave/Opera and Safari were not tested.

## Findings carried into closeout

Existing planning child freshness remains unresolved by this command; verification does not rewrite Analyze/Critic/Judge. Existing baseline 4.4.0 import and planning-reference observations remain recorded in earlier artifacts. A stale source header comment in play-admission.ts still describes the old rotate notice; runtime admission, tests and player-facing copy admit portrait. This non-runtime comment does not invalidate those measured results and is recorded as a documentation learning, not expanded into implementation during verify.

Final configured Firefox matrix exit: 0; `PASS: 10 real-export host fixtures; device gestures and canvas geometry require separate evidence.` Chrome 155.0.8059.80, Firefox 155.0.

Verification: pass, end-to-end/local-integration. Closeout: not-complete solely for existing CO-004 planning freshness. Physical CO-001 was resolved by the owner report; phone CO-002 stays deferred, not passed.
