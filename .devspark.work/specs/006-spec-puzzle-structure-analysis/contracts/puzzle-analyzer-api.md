# Contract: `PuzzleAnalyzer` Public API

`scripts/puzzle/puzzle_analyzer.gd` — `class_name PuzzleAnalyzer`, `extends RefCounted`, static-only (never instantiated), mirroring `PuzzleSolver`'s existing shape exactly.

## `static func analyze(definition: PuzzleDefinition) -> Dictionary`

**Preconditions**: `definition` MUST be a non-null `PuzzleDefinition` instance — structurally valid or invalid is both acceptable, but `null` is not. A `null` `definition` is a caller programming error: `analyze()` asserts `definition != null` (matching `PuzzleState._init()`'s existing `assert(definition.is_valid(), ...)` precondition style) rather than returning a "valid: false"-shaped result or silently producing an empty analysis. This is a deliberate, documented, tested hard failure, not implementation-defined behavior (see [data-model.md](../data-model.md)'s "Null-definition caller contract").

**Postconditions**:

- Returns the `PuzzleStructuralAnalysis` dictionary shape documented in [data-model.md](../data-model.md).
- Does not mutate `definition` (no field write, no call to any of its mutating-looking methods beyond read-only queries like `forward_ray_cells`/`get_cell_owners`).
- Does not read or write `PuzzleSession.get_current_id()`/`set_current_id()` or any other session-scoped state.
- Does not depend on, instantiate, or reference any `Node`, `Control`, `SceneTree`, or scene file.
- Calling `analyze(definition)` twice with the same `definition` returns two dictionaries that are `==` deep-equal (Godot `Dictionary`/`Array` structural equality) in every field.
- Internally MAY construct one or more private, short-lived `PuzzleState` instances scoped to the call; none of them is returned, shared, or retained after `analyze()` returns.

**Error/edge behavior**:

- Invalid `definition` (`definition.get_validation_errors()` non-empty): returns `valid: false`, `solvable: false`, `witness: []`, `unlock_sequence: []`, `legal_move_structure` with all-zero/empty fields; `board`/`geometry` are still populated from raw structural data where computable (see data-model.md's Invalid Input note).
- Valid but unsolvable `definition` (`PuzzleSolver.analyze(definition).solvable == false`): `dependency_graph`'s static fields are still populated; `legal_choice_sequence`, `longest_forced_run`, `unlock_sequence`, and `max_unlock_fan_out` are empty/zero, since no complete witness exists to sequence them against.
- A geometric dependency cycle among remaining arrows (possible per `PuzzleDefinition.get_validation_errors()`, which does not forbid it) MUST NOT cause infinite recursion or an unbounded loop in `depth`/`longest_chain` computation. `depth` is precisely defined as the longest **simple** directed path (no repeated node) in the graph — see [data-model.md](../data-model.md)'s "Depth / Longest-Chain Semantics" section for the exact algorithm shape, determinism/tie-break rule, and why this is always finite even for a cyclic graph. This is an analysis-only allowance for a *candidate* definition; `PuzzleSolver.analyze(definition).solvable` remains the sole authority on whether a puzzle is actually completable, and no cyclic-graph definition may enter `PuzzleCatalog` (FR-020's solvability gate excludes it).

## Helper functions (implementation detail, not part of the public contract, but constrained by it)

Any private helper `PuzzleAnalyzer` uses internally (e.g. a static `_build_dependency_edges(definition: PuzzleDefinition) -> Dictionary` or `_walk_witness_metrics(definition, witness) -> Dictionary`) MUST:

- Derive every blocking fact via `PuzzleState.is_blocked(cell)` / `get_arrow_head(cell)` on a disposable internal `PuzzleState`, or via `PuzzleDefinition.forward_ray_cells`/`get_cell_owners` read-only queries — never via an independently-reimplemented blocking predicate.
- Remain snake_case, private (leading underscore), and free of any scene/Node/Control reference, per constitution Principle I and this feature's headless requirement.
