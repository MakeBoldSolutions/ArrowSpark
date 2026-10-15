# Consolidation Record

The before/after evidence, deferred work and left-alone decisions for this spec. It stays with the
spec bundle in `.devspark.work/` until release archival, and durable code and knowledge never
reference it.

All commands used Godot `4.4.1.stable.official.49a5bc7b6` (Git Bash
`/tmp/ArrowGame-Godot-4.4.1/bin/Godot_v4.4.1-stable_win64_console.exe`).

## Pre-change gate baseline (T001)

Run on 2026-10-15 at `e424388`, whose production code is identical to `58a8bec`.

| Gate | Result |
|---|---|
| `run_puzzle_regressions.py` | exit 0; PUZZLE, ANALYZER, CATALOG, SCOREBOARD, ARROW_DEPARTURE_GEOMETRY, VIEWPORT, LAYOUT, CANVAS and PRESENTATION `_FAILURES=0` |
| `run_regressions.py` | exit 0; `REGRESSION_FAILURES=0` |
| `--headless --editor --quit` | exit 0; no errors |
| `git status --short` | no engine-written changes |

## Behavior baseline (T002–T003)

`gates/behavior_probe.gd` was run at `e424388` into `gates/baseline-before.txt`: 30 entry blocks
(195,273 bytes); all 30 `valid=true solvable=true`; all 30 Open Move trails end `completed=true`.

## Before measures (T004)

| Measure | Before |
|---|---|
| Production GDScript (scripts/ + scenes/) | 48 files, 4,427 lines |
| Largest five | catalog 1,145 · board 548 · analyzer 513 · arrow view 315 · puzzle scene 250 |
| Head-ordering definitions (production) | 4 |
| Direction-to-step mappings (production) | 2 |
| Shape-to-board loops (catalog) | 9 (one helper + 8 inline) |
| Catalog lines | 1,145 |
| Catalog entries with an exact-geometry pin | 24 of 30 (14 fingerprints, 1 canvas fingerprint, 9 content versions) |
| Unreachable template example content (FR-011 set) | 23 files plus 11 `.uid` sidecars; 11 of them GDScript (226 lines) |
