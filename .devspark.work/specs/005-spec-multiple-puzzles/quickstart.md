# Verification Quickstart

Working directory: C:/GitHub/MakeBoldSolutions/ArrowGame. Use a Godot 4.4 executable for
declared-baseline proof; record the actual version and executable used. If only another version
is available, record that and leave 4.4 verification outstanding, per the same disclosed-not-
skipped policy spec 004 established.

## Automated

1. Record clean baseline before code changes:
   `python tests/run_puzzle_regressions.py --godot <executable>` and
   `python tests/run_regressions.py --godot <executable>`.
2. After implementation, run the same commands. The puzzle launcher must add the new isolated
   catalog gate (`PUZZLE_CATALOG_FAILURES=0`) alongside existing markers `PUZZLE_FAILURES=0`,
   `ARROW_DEPARTURE_GEOMETRY_FAILURES=0`, `PUZZLE_LAYOUT_FAILURES=0`,
   `PUZZLE_PRESENTATION_FAILURES=0`. Save/input requires `REGRESSION_FAILURES=0`.
3. `tests/puzzle_catalog_check.gd` runs in the same bare isolated temp project as
   `tests/puzzle_regression.gd` (no fonts/scenes needed — `PuzzleCatalog` depends only on
   `PuzzleDefinition`). It enumerates the full 8-entry catalog and, for each: unique/valid ID,
   `is_valid()`, `PuzzleSolver.analyze().solvable`, and a replayed zero-mistake witness. It must
   fail loudly (not skip) on any malformed or unsolvable entry.
4. Extend `tests/puzzle_layout_check.gd` (real-project scene tests, isolated user data) to cover:
   New Game loads catalog position 0; Level Select selecting a non-first puzzle loads that exact
   puzzle and the gameplay HUD reflects it; Replay reloads the same selected puzzle with fresh
   `PuzzleState`; pause-menu Restart also reloads the same selected puzzle (not just Replay); Next
   Puzzle advances to the following catalog entry with fresh state; the last catalog puzzle's
   results show no Next Puzzle action; switching puzzles disposes any prior attempt's departing
   views/callbacks (extends the existing spec-004 setup-replacement-disposal pattern); results
   metrics correspond to the puzzle actually played.
5. Confirm no test writes to real player save data: continue using the existing
   APPDATA/XDG_DATA_HOME-isolated temp root pattern for every scene test.

## Desktop visual and input acceptance

Play all 8 puzzles start-to-finish via both entry points (New Game for puzzle 1; Level Select for
at least 3 others, including the last). For each: confirm it's understandable/completable, and
that continuous-arrow rendering and path-following departure (specs 003/004) look and behave
correctly on the newly authored geometry, not just the original fixed board.

Exercise Level Select and the Next Puzzle results action using **keyboard-only** and, if hardware
is available, **gamepad-only** navigation (constitution Principle III; this spec's clarified
requirement) — confirm focus traversal, selection, and activation all work without a mouse.
Record any hardware limitation honestly rather than reporting it as passed.

Confirm across the session: no persistent save file is written or altered by New Game, Level
Select, Replay, pause-menu Restart, or Next Puzzle (compare `user://global_state.tres`
before/after, or rely on the automated isolated-user-data tests as the primary evidence and note
this manual spot-check as supplementary).

Record subjective observations about which puzzles feel easier, harder, more obvious, or more
satisfying — useful evidence for future difficulty work, but must not be used to alter this
spec's scope or add difficulty labels now.

Record commands, engine/version, markers, puzzle IDs exercised, observed results, and any missing
checks in `gates/verification.md`. User-reported acceptance must be distinguished from
agent-observed tests, per the established pattern from spec 004.

## Documentation checks

After implementation: `python .devspark/scripts/build_knowledge_index.py --repo-root . --check`;
run the repository planning-reference scanner (`check-planning-references.*`) including tests;
`git diff --check`. Confirm no production/test/current-knowledge references point back to this
planning bundle. All required analyze/critic findings must be resolved and actual runtime
evidence recorded before marking the spec Complete.
