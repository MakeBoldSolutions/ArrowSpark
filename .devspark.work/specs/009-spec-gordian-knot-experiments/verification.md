# Implementation Verification

Godot executable: `godot`, v4.7.2.stable.official. Project guidance targets 4.4; installed validation uses 4.7.2.

Baseline puzzle regression: exit 0 on unmodified catalog. Other baseline output was not retained; rerun before claiming a baseline result.

Original canvas_validation full geometry fingerprint: `ccce768282c82848b925f672268842c8523a23a6d16cf612f8ae3083349bed9d` (40x30, 52 arrows; same canonical serialization as puzzle_catalog_check.gd).

## Incremental structural report timings

After first authored pair: structural report exit 0, elapsed 3.18s; launcher subprocess timeout 45s.
After knot_dense_core / knot_regions: structural report exit 0, elapsed 3.17s; launcher subprocess timeout 45s.
After knot_single_release / knot_boundary: structural report exit 0, elapsed 3.27s; launcher subprocess timeout 45s.
After adding the regional bridge, full-catalog structural report exit 0 in 4.45s (45s subprocess timeout).
Regional bridge revised after structural report exposed a blocking cycle; full-catalog report exit 0 in 3.50s and region solvable=true.

Before the boundary revision, two full-catalog outputs were identical for catalog Git object 1be41d2ff9208254383f8c12eb45323b759df125. All six new entries reported valid=true and solvable=true with full witnesses. Report process exit alone is not a solvability gate.

## Automated validation of current content

- `python tests/run_puzzle_regressions.py --godot godot`: exit 0; PUZZLE_FAILURES, PUZZLE_ANALYZER_FAILURES, PUZZLE_CATALOG_FAILURES, PUZZLE_SCOREBOARD_FAILURES, ARROW_DEPARTURE_GEOMETRY_FAILURES, PUZZLE_VIEWPORT_FAILURES, PUZZLE_LAYOUT_FAILURES, PUZZLE_CANVAS_FAILURES and PUZZLE_PRESENTATION_FAILURES all 0. Final run about 94 seconds. Includes all 21 catalog entries and transformed-selection checks for all six new puzzles.
- `python tests/run_regressions.py --godot godot`: exit 0; REGRESSION_FAILURES=0. Expected negative-case save/settings errors appear in output from recovery tests.
- `python tests/run_puzzle_structural_report.py --godot godot`: exit 0; final output repeated deterministically, with all six new entries valid and solvable. Non-gating report execution alone does not establish solvability.
- `godot --headless --path . --editor --quit`: exit 0 under Godot 4.7.2.

## Outstanding checks

Rendered desktop smoke testing (mouse, keyboard, gamepad, readability and responsiveness), confirmation on Godot 4.4, and actual completed human play sessions for all six puzzles remain outstanding. No subjective observations or hypothesis verdicts have been inferred from automated runs.
Boundary layout expanded after rendered review; full-catalog report exit 0 in 4.37s, valid=true, solvable=true.
After the boundary revision, two full-catalog structural reports matched exactly; second exit 0 in 3.37s.

Final boundary layout: 28 arrows, 508 occupied cells, 0.29 board density, 32 bends, six initial legal moves, 51 dependency edges; full witness recorded in the current reference. All six 1280x720 rendered overview captures were inspected; hardware input, gamepad, varied window sizes and felt readability still require a human desktop session. Final catalog Git object cc30ad4a41e2c6a4919603c0bcf41e63e900ef7b.

Planning-reference check: branch-name and completed-task linkage checks passed, but the stock checker reported five pre-existing false positives from binary PNG files in the bundled addon media directory. Those files were untouched. Knowledge index --check and knowledge coverage validation passed.

After the final boundary revision, `python tests/run_puzzle_regressions.py --godot godot` exited 0 in 95.16s; all nine puzzle-suite failure counters remained zero. `git diff --check`, knowledge-index `--check`, and knowledge-coverage validation passed.

## Final verification (2026-09-29)

Godot 4.4.1 (`Godot_v4.4.1-stable_win64_console.exe`, portable build kept in the temp directory), run against a fresh mirror of the working tree excluding `.git`, `.godot`, `.devspark.work` and `.archive`. Sequence: `--headless --editor --quit` first (exit 0), then the launchers.

- `python tests/run_puzzle_regressions.py --godot <4.4.1>`: exit 0; all nine PUZZLE/ARROW failure counters 0. Output retained as puzzle-godot44-output.txt.
- `python tests/run_regressions.py --godot <4.4.1>`: exit 0; REGRESSION_FAILURES=0. Output retained as full-godot44-output.txt.
- `python tests/run_puzzle_structural_report.py --godot <4.4.1>`: exit 0. All six experiment witnesses are identical to the 4.7.2 witnesses in the reference. Output retained as report-godot44-output.txt.
- Catalog Git object unchanged: `cc30ad4a41e2c6a4919603c0bcf41e63e900ef7b`.
- Knowledge index regenerated and checked; the planning-reference check reported none.

Not verified: the rendered desktop smoke matrix by input method and resolution, and gamepad hardware. The human evidence is one aggregate session with per-puzzle fields unrecorded. No baseline comparison is claimed where baseline output was not retained.
