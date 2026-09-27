# Contract: Developer Structural Report Output Format

`tests/puzzle_structural_report.gd` — a headless `extends SceneTree` script, run via `tests/run_puzzle_structural_report.py`. Not a regression gate: no `check()`/failure counter, no `PUZZLE_*_FAILURES=0` marker, always exits 0 on successful completion (an unhandled script error still exits non-zero, same as any Godot script).

## Behavior

1. Enumerate `PuzzleCatalog` in catalog order (`0` .. `PuzzleCatalog.count() - 1`), never hardcoding an assumption of exactly 8 or exactly 14 entries.
2. For each entry, call `PuzzleAnalyzer.analyze(PuzzleCatalog.get_definition(id))` and print one deterministic block:

   ```text
   [<id>] <title>
     board: <width>x<height>  density=<density, 2 decimals>  arrows=<arrow_count>
     geometry: single=<n> multi=<n> bends_total=<n> max_bends=<n> max_length=<n>
     legal: initial=<initial_legal_count>/<arrow_count> (<initial_legal_ratio, 2 decimals>) forced=<forced_state_count> branching=<branching_state_count> longest_forced_run=<n>
     legal_choice_sequence: <comma-joined ints>
     dependency: edges=<edge_count> depth=<depth> max_in_degree=<n> components=<n>
     cascade: max_unlock_fan_out=<n> unlock_sequence=<comma-joined ints>
     blocker_distance: max=<n> avg=<2 decimals>
   ```

3. After all entries, print a fixed-order **Catalog Comparison** section answering exactly the nine questions from spec FR-021, one line each, naming the winning puzzle id (ties broken by lowest catalog index, stated as "(tie, first: ...)" when more than one puzzle shares the winning value):

   ```text
   === Catalog Comparison ===
   deepest dependency chain: <id> (depth=<n>)
   fewest initial legal arrows: <id> (<n>/<arrow_count>)
   widest branching: <id> (<max_legal_in_run>)
   largest cascade: <id> (max_unlock_fan_out=<n>)
   longest forced run: <id> (<n>)
   highest density: <id> (<density>)
   most bends: <id> (<total_bends>)
   longest blocker distance: <id> (<n>)
   largest board: <id> (<width>x<height>, <total_cells> cells)
   ```

4. No line in this output may include a difficulty label, tier, star rating, or composite score (spec FR-009, FR-021). Every value printed must be traceable to a single named field in the `PuzzleStructuralAnalysis` dictionary ([data-model.md](../data-model.md)) — no new derived "overall" figure is introduced here.

## Determinism

Running the script twice against an unchanged `PuzzleCatalog` MUST produce byte-identical stdout (modulo a leading Godot engine banner, which the launcher may strip/ignore when comparing output, matching the existing `run_puzzle_regressions.py` marker-substring-check pattern rather than a full-output diff).
