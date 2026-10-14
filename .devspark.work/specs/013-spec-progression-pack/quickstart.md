# Quickstart: Verifying the Progression Pack

Run from the repo root. `<godot>` is the Godot 4.4 executable.

## Build for browser tests

Export the game and build the site before any browser or phone check, and record the build id tested:

```text
node web/scripts/export-game.mjs --godot <godot>
cd web && npm ci && npm run build
```

## Automated gates

```text
python tests/run_puzzle_regressions.py --godot <godot>
python tests/run_regressions.py --godot <godot>
<godot> --headless --editor --quit
python tests/run_puzzle_structural_report.py --godot <godot>   # non-gating; capture level characteristics
cd web && npm ci && npm run check && npm run build            # only if site copy changed
```

Expected: every failure marker reports zero (including `PUZZLE_VIEWPORT_FAILURES=0` and `PUZZLE_CANVAS_FAILURES=0`).

## Part A: Camera (desktop smoke)

1. Open a small puzzle (Simple Introduction) and the Reference Knot.
2. Zoom in with the wheel. Drag until each of the four corners sits at the middle of the board area.
3. Wheel-zoom with the cursor on a board edge; the point under the cursor stays put.
4. Zoom fully out: the board is centered and cannot be dragged. Press Fit; the view matches the old Fit.
5. Use WASD and a gamepad stick, the zoom keys and Open Move at an edge; each respects the bounds and the head ends up visible.
6. Complete the Reference Knot while zoomed in with an edge near the screen center: departing arrows leave without being sliced at an invisible line; measure and record the added time before Results.

## Part A: Camera (real Android phone, mobile beta)

Pinch near a corner, drag a corner to the center, tap an arrow near the edge, then Fit. Record device, browser and result; untested devices are not claimed.

## Part B: Levels

1. Main menu Play (mouse, keyboard and gamepad) starts the first new level; Level Select shows the group in the intended order ending with the Reference Knot.
2. Play each level to Results; Replay, Next Puzzle and Level Select behave as for existing puzzles; Next Puzzle from the last new level opens the Reference Knot.
3. Browser smoke on the showcase build; on the phone open each level and play a representative sample.
4. Record designer notes per level and update the design-learning record.

## Evidence to record

Command outputs with failure markers, the structural report rows per level, smoke results by platform, items not tested, and any finding classified as Blocking Defect, Accepted Limitation, Deferred Work or Learning / Changed Assumption.
