# Verification notes (working record)

## Baseline (untouched branch, Godot 4.7.2 stable; project targets 4.4)

- `python tests/run_puzzle_regressions.py --godot godot`: exit 0; every `*_FAILURES=0`.
- `python tests/run_regressions.py --godot godot`: exit 0; `REGRESSION_FAILURES=0`. The
  isolated project logs `Cannot save file 'user://global_state.tres'` / a `user://global_state.tres`
  parse error; both appear with exit 0 and zero failures and come from the isolated test project's
  user dir, not from a check.
- `godot --headless --editor --quit`: started and exited; no script/scene errors printed.

## After groups + grouped Level Select + group-scoped progression + placeholder entry

- `run_puzzle_regressions.py`: exit 0, all `*_FAILURES=0` (catalog, layout, canvas, presentation
  included; new group, group-end results, grouped Level Select and Level Select request checks pass).
- `run_regressions.py`: exit 0, `REGRESSION_FAILURES=0` (Play starts the Reference Knot; the
  Level Select request is one-shot and leaves progress untouched).
- `godot --headless --editor --quit`: no error/warning lines.
- Catalog check wall clock: ~28 s with the placeholder board against the launcher's 45 s per-script
  timeout (T009 must re-measure with the real board).

## Not yet run

- Desktop smoke test, keyboard-only and gamepad traversal, frame-time observation (T027).
- All human gates: T011, T014, T028.

## Candidate v1 (first real board)

- `reference_knot` is structurally valid, solver-confirmed solvable, witness replays with zero
  mistakes, and the catalog-wide branch order-independence check passes for it.
- Whole catalog check wall clock with v1: ~31.5 s (placeholder was ~28 s), against the launcher's
  45 s per-script timeout. The order-independence check on this board adds about 3 s, so no sampling
  is needed yet; re-measure after each larger revision.
- Both regression gates and the headless editor validation green with v1 in the catalog.
- Structural report diagnostics are in `design-report-draft.md` section 1.

## Candidate v2 (denser board)

- 59 arrows, density 0.69. Valid, solvable, witness replays; catalog order-independence passes.
- Catalog check wall clock ~35 s against the launcher's 45 s timeout (v1 ~31.5 s). Another increase
  in arrow count will likely need sampled branch checks for this board only.
- Both regression gates and the editor validation green. Desktop smoke test not yet run.
