# S-1 export spike: Godot 4.4-stable Web

**Date:** 2026-10-02 · **Result:** PASS (one project-side blocking defect found and fixed; no engine defect, no version change)

## Engine and templates

| Item | Value |
|---|---|
| Source | `https://github.com/godotengine/godot/releases/download/4.4-stable/` (same source as `.github/workflows/godot-regression-tests.yml`) |
| Editor | `Godot_v4.4-stable_win64.exe.zip`, SHA-512 verified against `SHA512-SUMS.txt` (`sha512sum --check --strict`: OK) |
| Templates | `Godot_v4.4-stable_export_templates.tpz`, SHA-512 verified (OK); only `web_nothreads_release.zip` / `web_nothreads_debug.zip` installed to `%APPDATA%/Godot/export_templates/4.4.stable/` |
| Version string | `4.4.stable.official.4c311cbee` |
| Local 4.7.2 editor | not used for any export or evidence |

## Procedure

- Runs use a clean mirror of the working tree without `.godot`, `.git`, `.devspark.work`, `.archive` (the in-repo `.godot` cache was produced by 4.7.2 and makes 4.4 report `SceneLoader not declared`; known environment issue, same as Specs 008/009).
- `--headless --editor --quit` in the mirror: exit 0, 0 `SCRIPT ERROR` / `Parse Error` lines.
- Export: `--headless --export-release Web <out>/index.html` with the committed `export_presets.cfg` "Web" preset (threads off, custom shell `web/game-shell/shell.html`, `shell.css` copied beside it by `web/scripts/export-game.mjs`). Exit 0.
- Play: served locally over HTTP; headless Chromium 153 (Playwright 1.63) with `--use-angle=swiftshader`. Renderer reported: `ANGLE (Google, Vulkan 1.3.0 (SwiftShader Device (Subzero)), SwiftShader driver)`.
- To reach results without a human, a **spike-only autoload** (added to the mirror only, never committed) called the main menu's own `new_game()` (what Play does), then cleared the board by repeatedly asking the rules for an open move (`PuzzleState.request_open_move()`) and passing it to the controller's own click handler `_on_cell_clicked()`. Mouse input itself is covered by the browser smoke test, not here.

## Results

| Check | Result |
|---|---|
| Engine starts (`engineState=started`) | pass, 0.8 s after navigation (local server; not a network measurement) |
| `SceneLoader` behaviour | loading screen → main menu → Play loads `reference_knot` through `SceneLoader` without errors on the no-threads build |
| Play starts the Reference Knot | pass (`PuzzleSession.get_current_id()` = `reference_knot`; board renders, 115 arrows) |
| Reaches results | pass after fix: 115/115 removed, `{"accuracy":1.0,"mistakes":0,"open_move_assists":115,"score":0,"total_arrows":115}` (score 0 is expected: every move used Open Move) |
| Console errors | none |

### Blocking defect found and fixed

The results overlay (`scenes/puzzle/puzzle_results.gd`) rendered with size 0×0 in the Web build at both 1280×720 and 1200×675, so the results screen appeared as a clipped fragment in the top-left corner. Cause: the panel is hidden while its parent is sized, and the Web build starts at its final canvas size and never resizes, so the hidden full-rect Control never received its layout. Desktop hid this because the OS window normally resizes at launch. Fix: `show_results()` applies `PRESET_FULL_RECT` before `show()`. After the fix the overlay is 1200×675 (equal to its parent) and renders centered. Classified as a **Blocking Defect** (browser play cannot show results), not an engine defect.

## Sizes (plain release export, no spike driver)

| File | Raw | gzip -9 | brotli q11 |
|---|---|---|---|
| `index.wasm` | 43,682,606 B | 9,477,730 B | 6,406,687 B |
| `index.pck` | 1,287,040 B | 922,773 B | 829,159 B |
| `index.js` | 317,142 B | 80,554 B | 68,663 B |

What Azure Static Web Apps actually serves (`Content-Encoding`, transferred size) is measured on the preview in the browser performance check, not inferred here.

## Decision

4.4-stable is the pinned engine. No version-change prerequisite. The [S-1] tasks are unblocked.

## Gates on the pinned engine after the game-side changes (T023)

Fresh mirror without `.godot` for each run; Godot `4.4.stable.official.4c311cbee`.

| Command | Result |
|---|---|
| `python tests/run_puzzle_regressions.py --godot <4.4>` | exit 0; `PUZZLE_FAILURES=0`, `PUZZLE_ANALYZER_FAILURES=0`, `PUZZLE_CATALOG_FAILURES=0`, `PUZZLE_SCOREBOARD_FAILURES=0`, `ARROW_DEPARTURE_GEOMETRY_FAILURES=0`, `PUZZLE_VIEWPORT_FAILURES=0`, `PUZZLE_LAYOUT_FAILURES=0`, `PUZZLE_CANVAS_FAILURES=0`, `PUZZLE_PRESENTATION_FAILURES=0` |
| `python tests/run_regressions.py --godot <4.4>` | exit 0; `REGRESSION_FAILURES=0` |
| `<4.4> --headless --editor --quit` | exit 0; 0 `SCRIPT ERROR` / `Parse Error` lines |

- **Reference Knot content version (pinned in `tests/puzzle_catalog_check.gd`): `g1-7ce0942d4a5e`.**
- Environment note: on this Windows host 4.4 prints spurious `SceneLoader not declared` parse errors when a project that already has a 4.4 `.godot` cache is imported a second time, and the second import sometimes segfaults. Reproduced on an untouched `git archive HEAD` copy, so it is pre-existing and not caused by this change. Gates are therefore run on a fresh mirror where the launcher's own `--import` is the first import; CI validates the editor import on a fresh copy for the same reason.
- Re-export and play (2026-10-02): the Web export with the completion emitter, hosted in the real Play page (`astro preview`, headless Chromium with SwiftShader), started the engine, Play started `reference_knot`, the spike driver cleared it, the results screen rendered full size, and the page received **exactly one** message: same origin, from the game iframe's window, `{"contractVersion":1,"elapsedSeconds":3,"mistakes":0,"openMoveAssists":115,"puzzleId":"reference_knot","puzzleVersion":"g1-7ce0942d4a5e","score":0,"type":"arrowspark.attemptCompleted"}`. No console errors.
- Synthetic check (`web/scripts/synthetic-check.mjs`) against the local preview with a plain export: renderer `ANGLE (… SwiftShader driver)`, `Game engine state: started`, no console errors on `/` and `/play/`.
