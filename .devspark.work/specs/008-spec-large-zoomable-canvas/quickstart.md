# Quickstart and Verification

Planning artifact only: the following implementation checks have not yet run.

## Environment

Repository: C:/GitHub/MakeBoldSolutions/ArrowGame. Target Godot 4.4, Python 3.11+. `godot_console --version` during planning reported 4.7.2.stable.official.ed1daf0bf. Select an actual 4.4 executable for target acceptance or explicitly leave target-version verification outstanding. No engine upgrade is authorized by this plan.

## Automated checks

From repository root, using the selected executable path:

```powershell
python tests/run_puzzle_regressions.py --godot '<godot-executable>'
python tests/run_regressions.py --godot '<godot-executable>'
```

Extend the first launcher to run pure transform checks in an isolated temporary project and scene canvas checks in its existing isolated-user-data scene phase. Require new markers PUZZLE_VIEWPORT_FAILURES=0 and PUZZLE_CANVAS_FAILURES=0 plus all existing markers and zero exit codes; reject script/parse errors. Its scene phase already runs headless import. Preserve isolated APPDATA/XDG_DATA_HOME for all tests and rendered validation so real saves/remaps are untouched.

Coverage: all 20 rows in spec.md. Preserve original fourteen catalog geometries/IDs/order; append only validation entry. Exercise transformed head/tail/empty hits, GUI press/motion/release sequences, focus cancellation, wheel/buttons/remapped actions, original score accounting, zero-area recovery, pending assistance and departure completion. Include actual input dispatch tests rather than only direct board method calls.

## Desktop smoke

Launch the actual game under isolated user-data environment; select Large Canvas Validation through Level Select. At 960x540, 1280x720, 800x800 and 1920x1080:

1. Check initial fit with 16-pixel margin and toolbar/HUD readability. Original small puzzles must be playable immediately.
2. Wheel zoom about a recognizable point; exhaust both bounds; pan using middle drag and Pan-mode primary drag; fit again. At 64 px/cell reach all four corners. Verify primary gestures in Pan mode never remove arrows or change counters, including outside release/focus loss.
3. Select heads and tails after zoom/pan; select a known blocked arrow and check unchanged penalty/feedback. Confirm stationary pointer hover updates when the view changes underneath it.
4. Tab to board; WASD pan, Equal/Minus zoom, F fit; Tab back to toolbar/Open Move. Repeat with left stick, shoulders, Y, and D-pad/accept where hardware exists. Remap a zoom action through settings and verify behavior/help and reset-default restoration without losing existing mappings.
5. Pan away from the deterministic first legal arrow. Request Open Move: head and highlight become visible at readable scale, assists increment once, no removal. Repeat while already visible, with a long shape, during departure, and after invalid-area recovery.
6. Remove a long bent arrow at working scale; zoom in/out, pan away/back, resize and pause/resume while it feeds through its bends. Off-screen departure still waits for full logical clearance. Finish all arrows; results appear once after the last departure; compare score/best/overall; replay and Next reset view.
7. Resize a manual view and verify center/scale preservation subject to bounds; resize fit view and verify refit. Minimize/restore; inspect no stale drag, invalid values, or early completion. Check menu overlays and focus-loss do not accept canvas actions.
8. Repeat ordinary play on original small puzzles, checking feel, hover, feedback, fit, completion and replay. Record real outcomes, not inferred passes.

## Performance capture

Use tests/puzzle_canvas_visual_check.gd as a deterministic display/measurement driver, not a runtime telemetry subsystem. Warm 2 seconds, then record 10 seconds at 1280x720 with the 40x30 fixture, continuous pan/zoom and three overlapping long departures. Record machine CPU/GPU, engine version, build, viewport, navigation-handler and frame-time samples. Accept p95 <=2 ms handler / <=33.3 ms frames, no navigation-attributable input stall >=100 ms. Confirm static view identities and geometry remain unchanged through navigation. Investigate and remeasure before adding optimizations.

## Evidence and completion

Record actual commands, engine/build, output markers and manual steps/results in gates/verify.md with mode end-to-end. Record missing hardware or target-engine validation as outstanding. Do not mark verify pass until its required evidence exists; no pre-implementation pass is meaningful. Run analyze and critic on the finished planning bundle before implementation. Retain this bundle and populated linkage until release archival; no deletion during implementation.
