# Verification Quickstart

Working directory: C:/GitHub/MakeBoldSolutions/ArrowGame. Use a Godot 4.4 executable for
declared-baseline proof; record the actual version and executable used. If only another version
is available, record that and leave 4.4 verification outstanding, per the same disclosed-not-
skipped policy prior specs established.

## Automated

1. Record clean baseline before code changes:
   `python tests/run_puzzle_regressions.py --godot <executable>` and
   `python tests/run_regressions.py --godot <executable>`.
2. After implementation, run the same commands. The puzzle launcher must add a new
   `PUZZLE_ANALYZER_FAILURES=0` marker alongside existing markers `PUZZLE_FAILURES=0`,
   `PUZZLE_CATALOG_FAILURES=0`, `ARROW_DEPARTURE_GEOMETRY_FAILURES=0`,
   `PUZZLE_LAYOUT_FAILURES=0`, `PUZZLE_PRESENTATION_FAILURES=0`. Save/input requires
   `REGRESSION_FAILURES=0`.
3. `tests/puzzle_analyzer_check.gd` runs in the same bare isolated temp project as
   `tests/puzzle_regression.gd`/`tests/puzzle_catalog_check.gd` (no fonts/scenes needed —
   `PuzzleAnalyzer` depends only on `PuzzleDefinition`/`PuzzleState`/`PuzzleSolver`). It exercises
   at least ten small synthetic puzzles with hand-computed expected values: independent/no-
   dependency, simple chain, deep chain, branching/open, cascade (fan-out >= 2), multiple blockers
   on one arrow, bent-arrow dependency, long-range blocker, invalid-puzzle handling, determinism
   (repeated calls), and non-mutation of the supplied definition. It must fail loudly on any
   mismatch, not skip.
4. `tests/puzzle_catalog_check.gd` is extended to assert the catalog contains exactly 14 entries
   (not 8), that all fourteen remain unique-id/valid/solver-confirmed-solvable/zero-mistake-
   witness, and that each of the six new entries' `PuzzleAnalyzer.analyze()` output confirms its
   named experiment's defining property (e.g. the Cascade/Key Arrow entry's `max_unlock_fan_out
   >= 2`; the Bent Network entry has >=2 bent arrows and at least one dependency edge whose
   blocking cell is a tail cell; the Long-Range Blocker entry has a `blocker_distance` clearly
   beyond immediate adjacency on a board large enough for it to be meaningful; the Composed/Shaped
   entry's occupied-cell grid forms the intended macro shape while `edge_count >= 1`).
5. Run `python tests/run_puzzle_structural_report.py --godot <executable>` (new, non-gating) and
   confirm the printed Catalog Comparison section answers all nine FR-021 questions and contains
   no difficulty label, tier, or composite score. Run it twice and confirm identical output
   (modulo the Godot engine banner).
6. Confirm no test writes to real player save data: continue using the existing
   APPDATA/XDG_DATA_HOME-isolated temp root pattern for every scene test; this feature adds no new
   scene-level test beyond the existing `puzzle_layout_check.gd`/`puzzle_catalog_check.gd`
   coverage extended to 14 entries.

## Desktop visual and input acceptance

Play all six new experimental puzzles start-to-finish via Level Select (now 14 entries). For
each: confirm it is understandable/completable with the existing rules (no new mechanic, control,
or failure state), confirm continuous-arrow rendering and path-following departure (specs 003/004)
behave correctly on the new geometry, and immediately fill out one
[calibration/worksheet-template.md](calibration/worksheet-template.md) block per puzzle into
[calibration/records.md](calibration/records.md).

Exercise Level Select with the enlarged fourteen-entry list using **keyboard-only** and, if
hardware is available, **gamepad-only** navigation (constitution Principle III) — confirm focus
traversal, selection, and activation still work at the new list length without a mouse.

Confirm across the session: no persistent save file is written or altered while playing any of
the six new puzzles (same isolated-user-data evidence pattern as prior specs).

Once all six calibration records are filled in, write
[calibration/findings-summary.md](calibration/findings-summary.md) per FR-026: a
Supported/Contradicted/Inconclusive verdict per named experiment plus follow-up characteristics
for a future spec — no composite score, no generator design.

Record commands, engine/version, markers, puzzle IDs exercised, observed results, and any missing
checks in `gates/verification.md`. User-reported acceptance must be distinguished from
agent-observed tests, per the established pattern from prior specs.

## Documentation checks

After implementation: `python .devspark/scripts/build_knowledge_index.py --repo-root . --check`;
confirm `.knowledge/architecture/arrow-puzzle.md` is updated to describe `PuzzleAnalyzer`'s
boundaries and metric definitions, the dependency-graph interpretation, the enlarged
fourteen-puzzle catalog, and the explicit distinction between objective metrics and labeled
perceptual hypotheses (dependency discoverability, false affordance, unlock rhythm, reasoning
span, composition) — none of which may be recorded as established product truth ahead of the
calibration findings.
