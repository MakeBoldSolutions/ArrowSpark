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
- Human gates: T011 and T014 are done (see the design-report draft). T028 (SC-009, a person other than the author) was NOT performed and is deferred to the next spec by owner decision on 2026-10-01: accepted limitation, not a pass.

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

## Candidate v3 (91.6% occupied)

- 115 arrows, 1348 of 1472 cells occupied (8.4% empty). Valid, solvable, witness replays.
- Catalog check ~36 s after sampling the branch order-independence check for this board only
  (every 6th branching state); every other entry keeps the full check. Unsampled it took ~51 s,
  over the launcher's 45 s per-script limit. This is the sampling the task plan allows.
- Both regression gates and editor validation green.
- Stock structural report did not finish on this board before the analyzer fix (timed out at 45 s
  and at 180 s): the analyzer's longest-dependency-chain search explores simple paths and grows
  exponentially with edge count (661 edges here; the 59-arrow version with 276 edges finished).

## Analyzer fix (FR-027 amendment)

- `PuzzleAnalyzer._longest_simple_path` now computes the deepest chain by dynamic programming over a
  topological order when the dependency graph is acyclic, returning the same depth and the same
  tie-broken chain; a graph with a cycle still uses the original exhaustive search
  (`_longest_simple_path_search`). No new measurement, score or formula.
- `tests/puzzle_analyzer_check.gd`: shortcut equals exhaustive search on 200 seeded random acyclic
  graphs (many ties); cyclic graph keeps the exhaustive result; empty graph; a dense layered graph
  the exhaustive search could not finish resolves in under a millisecond; `reference_knot` analyzes
  to completion with a consistent chain. All existing analyzer fixtures (including the cycle and
  mixed cyclic/acyclic cases) still pass unchanged.
- Stock structural report now runs the whole catalog in about 3 s. `reference_knot` v3: density 0.92
  (1348/1472), 115 arrows, single=3, avg length 11.72, max length 43, bends 207 (max 9), initial
  legal 6/115, forced states 11, branching 104, longest forced run 3, dependency edges 661, depth 33
  (edges), max in-degree 20, max fan-out 5, blocker distance max 42 avg 11.71.
- My scratch model independently gave initial legal 6 and 661 edges (matches exactly) and a depth of
  34 counted in nodes (33 in edges): consistent.
- Both regression gates and the editor validation green after the fix. Nothing committed.

## Playtest instrumentation

- F3 developer readout (off by default) on the play screen: current on-screen cell size, supported range
  (Fit Puzzle size to 192 px), and smallest/median/largest cell size in effect at clicks this attempt.
  In memory only, no persistence, no gameplay change. Layout check covers it; gates and editor validation
  green. This supplies the FR-008 cell-size evidence without manual estimation; whether arrows were
  traceable at that size still needs the tester's own account.

## Final closeout (2026-10-01)

See the spec's Closeout section for the classification (passed / accepted limitation / deferred / learning / failed). No blocking defect remains. The pointer tooltip readout tried for the numeric cell size was reverted before commit (no independent product value). The end-to-end gate evidence is in gates/verify.md.
