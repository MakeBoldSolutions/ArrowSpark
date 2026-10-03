# Quickstart: Spike and Verification Runbook

## Spike execution sequence (Phase 0)

1. **Prepare.** Build the Web export plus the site (`cd web && npm ci && npm run build`) from this branch with a flag-gated spike mode: the page admits any viewport on a spike URL, and a small probe overlay reports `innerWidth/innerHeight`, `devicePixelRatio`, orientation, touch and pointer media features, and the canvas-to-CSS scale. The shipped gate is untouched. Host over HTTPS on the real origin shape (same-origin iframe) so iOS behavior matches production.
2. **Devices.** One recent iPhone (current iOS Safari), one recent Android phone (current Chrome); iPad (current iPadOS Safari) if available. Fill the identity block of a Spike Record for each.
3. **Baseline (R4, R1).** Load the unmodified game in the iframe in landscape; try tap, blocked tap, scroll, pinch and drag; note what the page and the game each do, and explicitly record whether Godot emits both touch and mouse events for one tap, any premature (press-time) selection, and any double-fire. Repeat the iframe check against the game URL opened directly.
4. **Scaling and readability (R2).** Record the canvas-to-CSS scale and readable text sizes per device; view the Reference Knot at each device's viewport; compare scaling options one at a time; confirm geometry is unchanged.
5. **Gesture feasibility (R3).** Call the existing transform methods from a throwaway touch prototype; confirm bounds, anchor behavior and Fit.
6. **Control audit (R6).** Measure the rendered CSS size of each required control; list menu/Results/Level Select blockers.
7. **Viewport probing (R5).** Find the smallest landscape viewport (with and without browser chrome) where the Reference Knot is usable.
8. **Browser permissions (R7).** Fullscreen API per browser; first-tap audio unlock; gesture and viewport-meta effects; iframe focus.
9. **Orientation/resize.** Rotate mid-puzzle, show/hide browser chrome, record whether the attempt survives.
10. **Classify** each device and write the Spike Records (`contracts/spike-record-template.md`).

## Matrix-freeze checkpoint
Owner and reviewer review the Spike Records, freeze the Support Matrix, then `/devspark.tasks` is generated from it. Anything unclassified or only emulated stays out.

## Verification after implementation

```text
python tests/run_puzzle_regressions.py --godot <executable>
python tests/run_regressions.py --godot <executable>
<godot> --headless --editor --quit
cd web && npm ci && npm run check && npm run build
```

Then desktop smoke, mobile-emulation smoke (supplemental), and the full real-device checklist from the plan on every Frozen matrix row: load, orientation, tap, blocked selection, pan, pinch, Fit, Open Move, Back, completion, Results, Replay, Level Select, resize/orientation change, page scroll/zoom conflicts, audio, iframe behavior. Record results and disclose anything not performed.
