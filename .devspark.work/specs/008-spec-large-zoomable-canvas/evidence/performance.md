# Navigation performance and rendered captures (T028)

Date: 2026-09-28. Driver: `tests/puzzle_canvas_visual_check.gd` (non-headless, real renderer).
Machine: AMD Ryzen 9 7900X (12-core), AMD Radeon integrated graphics, Windows 11 Pro Insider Preview, OpenGL 3 (gl_compatibility) renderer, window 1280x720 (board area 1280x566, fit scale 17.80 px/cell), vsync on.

Scenario: 2 s warmup then a 10 s capture of one navigation step per frame (alternating wheel zoom in/out at off-center pointers and middle-drag pans) through the board's real `_gui_input`, with eight overlapping departures (the first eight heads of the solver witness) started at the beginning of the warmup. Fixture is the revised 52-arrow, 87%-filled board (update after operator feedback; earlier 12-arrow numbers were similar).

## Fixture (canvas_validation, 40x30, 52 arrows) — gated budget

| Engine | samples | handler p95 (budget 2 ms) | frame p95 (budget 33.3 ms) | longest frame (stall >= 100 ms fails) | result |
|---|---|---|---|---|---|
| Godot 4.4-stable (target) | 599 | 0.108 ms | 17.19 ms | 31.3 ms | within budget |
| Godot 4.7.2-stable (supplementary) | 599 | 0.109 ms | 17.08 ms | 17.6 ms | within budget |

## Synthetic dense board (informational, never in the catalog)

60x40, 600 single-cell arrows (every other cell, four directions), same navigation script, no departures.

| Engine | handler p95 | frame p95 | longest frame |
|---|---|---|---|
| 4.4-stable | 0.431 ms | 17.25 ms | 49.9 ms (single hitch, not gated) |
| 4.7.2-stable | 0.451 ms | 17.06 ms | 17.4 ms |

## Rendered readability review (4.7.2 captures in this folder)

- overview.png (about 17.8 px/cell, revised 52-arrow board): the packed maze of long bent arrows stays legible; margin visible on all sides.
- working_scale.png (64 px/cell): shaft, round join/cap and head silhouette crisp; head clearly distinguishable.
- maximum_zoom.png (192 px/cell): head and shaft edges remain smooth; no stair-stepping visible on diagonals-free orthogonal geometry.
- dense_working_scale.png: 600-arrow board at working scale reads cleanly; board shows the 2 px ember focus outline after a drag.

Per-node antialiasing looked adequate at all three scales, so the fallback (disable per-node antialiasing or a project MSAA setting) was not applied.
Limitations: captures are from one display; hover, blocked and Open Move colors were not re-captured in this pass (unchanged code and constants; covered by the desktop scenarios in T030).
