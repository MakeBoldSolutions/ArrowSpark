# Verification Quickstart

Working directory: C:/GitHub/MakeBoldSolutions/ArrowGame. Use a Godot 4.4 executable for declared-baseline proof; record the actual version and executable. If only another version is available, record that and leave 4.4 verification outstanding. Keep engine import caches version-isolated when validating multiple engines.

## Automated

1. Record clean baseline before code changes: `python tests/run_puzzle_regressions.py --godot <executable>` and `python tests/run_regressions.py --godot <executable>`.
2. After implementation run the same commands. The puzzle launcher must add isolated pure helper checks (ARROW_DEPARTURE_GEOMETRY_FAILURES=0), then retain PUZZLE_FAILURES=0, PUZZLE_LAYOUT_FAILURES=0, PUZZLE_PRESENTATION_FAILURES=0. Save/input requires REGRESSION_FAILURES=0. Require successful exits and no unexpected parse/script failures; do not suppress negative-case save diagnostics indiscriminately.
3. Existing launcher real-project `--headless --import` validates scripts/scenes/assets under isolated APPDATA/XDG_DATA_HOME. Do not replace it with an early editor quit that can leave font import unfinished. Add the helper fixture in an isolated project with no scenes/addons or domain dependency, preserving pure rule-suite isolation.
4. Compare samples at zero, each corner minus/at/plus 1e-4 cells, L, and finish minus/at/plus tolerance. Cover four directions and four shape categories, near-touching nonconsecutive cells, coincident input points, and long routes. Check length tolerance and head overlap. Integrate equal active time with different delta partitions for frame-rate independence.
5. Scene tests cover immediate removal, dependent click during visible exit, ignored old cells, multiple different lengths completing out of selection order, final barrier, repeated starts, normalization at pulse times 0.02/0.075/0.11 seconds, pause, invalid extent recovery, resize while paused, cleanup and new attempts. Replace fixed-0.25-second waits with calculated bounded deadlines or explicit progress stepping; never remove barrier assertions merely to make timing tests pass.
6. Test resize at 960x540, 1280x720 and 800x800. Check clip rect matches occupied grid and decorative controls never become hovered input targets. Record no live player data touched.

## Desktop visual and input acceptance

Use isolated user data for smoke testing and fixture scenes/scripts under tests/ when shipped content lacks a one-bend fixture; do not add a level or alter shipped board content. Exercise single/straight/one/multi-bend departures, all directions, edge heads, corner tail caps, head/body seams, no starting jump, and speed readability. Observe progressive clipping at occupied-grid edge with no HUD spill. Rapidly remove dependents while earlier arrows remain visible. Pause/resume and resize midway, including during pause; finish all arrows and inspect results timing. Restart cancel/confirm, Replay, Main Menu, options, keyboard/gamepad navigation/remapping and seeded progress/settings preservation must be exercised or recorded as outstanding with hardware limitations.

Record commands, engine/version, markers, dimensions, fixture descriptions, observed results, and missing checks in gates/verification.md. Screenshots may supplement but never substitute for dynamic play or numerical evidence. User-reported acceptance must be distinguished from agent-observed tests.

## Documentation checks

After implementation: `python .devspark/scripts/build_knowledge_index.py --repo-root . --check`; use repository planning-reference scanner including tests; `git diff --check`. If ownership changes, rebuild knowledge index/coverage before checking. Check no production/test/current-knowledge references point back to planning artifacts. All required analyze/critic findings must be resolved and actual runtime evidence recorded before marking the spec Complete. Retain bundle for release archival.
