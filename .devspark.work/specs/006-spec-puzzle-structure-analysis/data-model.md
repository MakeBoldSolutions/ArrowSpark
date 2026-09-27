# Phase 1 Data Model: Puzzle Structure, Challenge, and Character

All entities below are read-only analytical views or plain data records. None introduces a new mutable gameplay/session state class; `PuzzleDefinition`, `PuzzleState`, and `PuzzleSolver`'s existing shapes are unchanged (spec FR-010, FR-011).

## PuzzleStructuralAnalysis (return value of `PuzzleAnalyzer.analyze(definition)`)

A `Dictionary`, matching `PuzzleSolver.analyze()`'s existing dictionary-contract precedent. Deterministic; never mutates `definition`; never touches a live gameplay `PuzzleState` or session state (FR-008).

**Null-definition caller contract**: `definition` MUST be a non-null `PuzzleDefinition` instance. `PuzzleAnalyzer.analyze(definition)` asserts this precondition as its first statement (`assert(definition != null, "PuzzleAnalyzer.analyze() requires a non-null PuzzleDefinition")`), matching the existing precondition style `PuzzleState._init()` already uses for its own `assert(definition.is_valid(), ...)` — a null definition is a caller programming error, not a data-quality case to report gracefully through the returned dictionary's `valid: false` path (that path is reserved for a real, non-null definition that fails structural validation). Empirically verified (Godot 4.4.1, headless, no debugger attached — this repo's actual automated-test environment): the failed assertion prints a `SCRIPT ERROR` and aborts the rest of `analyze()`'s body without reaching its `return` statement, so the statically-`-> Dictionary`-typed function yields an **empty `Dictionary` (`{}`)** to the caller rather than `null` or a crash. This is the deliberate, tested, documented outcome — never an unspecified one — and is exactly what `tests/puzzle_analyzer_check.gd` asserts (`not result.has("valid")`).

| Field | Type | Description | Source FR |
|---|---|---|---|
| `valid` | `bool` | Mirrors `PuzzleSolver.analyze(definition).valid`; when `false`, every field below is zero/empty rather than throwing. | FR-008 |
| `solvable` | `bool` | Mirrors `PuzzleSolver.analyze(definition).solvable`. | FR-004 (edge case) |
| `board` | `Dictionary` | `{width, height, total_cells, arrow_count, occupied_cell_count, density}`. `density = occupied_cell_count / total_cells`. | FR-001 |
| `geometry` | `Dictionary` | `{single_cell_count, multi_cell_count, average_length, max_length, bent_arrow_count, total_bends, average_bends_per_arrow, max_bends_on_one_arrow}`. "Length" = `1 + tail.size()`; "bends" per arrow = direction changes along its tail path (0 for a straight or single-cell arrow). | FR-002 |
| `legal_move_structure` | `Dictionary` | `{initial_legal_count, initial_legal_ratio, min_legal, max_legal, average_legal, forced_state_count, forced_state_ratio, branching_state_count, branching_state_ratio, longest_forced_run, legal_choice_sequence}`. `legal_choice_sequence` is an `Array[int]`, one entry per witness step, aligned with `witness`. Only computed when `solvable` (see Edge Cases below for the unsolvable case). | FR-003 |
| `witness` | `Array[Vector2i]` | Copied from `PuzzleSolver.analyze(definition).witness` for alignment with `legal_choice_sequence`/`unlock_sequence`. | FR-003, FR-006 |
| `dependency_graph` | `Dictionary` | See **DependencyGraph** below. | FR-004, FR-005 |
| `unlock_sequence` | `Array[int]` | One entry per witness step: how many previously-blocked arrows became newly legal immediately after that step's removal. A "cascade event" is any entry ≥ 2. Empty when `solvable` is `false`. | FR-006 |
| `blocker_distance` | `Dictionary` | `{max_distance, average_distance, edges}` where `edges` is an `Array` of `{blocked: Vector2i, blocker: Vector2i, distance: int}` — `distance` is the 1-based index of the blocker's cell within `blocked`'s `forward_ray_cells`, computed at the *initial* (fully-occupied) state. Explicitly labeled a geometric proxy, not a perceptual measurement (FR-007). | FR-007 |

**Invalid input**: when `valid` is `false`, `board`/`geometry` are still computed from raw `arrows`/`tails`/`width`/`height` where structurally possible (mirrors the spirit of reporting facts, not hiding them). Every other field — `legal_move_structure`, `witness`, `dependency_graph` (all of it, including its otherwise-static geometric fields), `unlock_sequence`, and `blocker_distance` — is empty/zeroed, consistent with `PuzzleSolver.analyze()`'s own "invalid input yields every metric at zero" contract. This is deliberately stricter than the unsolvable-but-valid case below: an invalid definition's cell ownership itself may be ill-formed (e.g. two arrows claiming the same cell), so there is no single well-formed dependency graph to report — attempting one over broken geometry would be unsound, not merely incomplete.

**Unsolvable input** (`valid: true, solvable: false`): cell ownership is well-formed (validation passed), so `dependency_graph`'s fully static, geometry-only fields (`edge_count`, `max_in_degree`, `max_out_degree`, `component_count`, `depth`, `longest_chain` — over the *whole* graph including unreachable branches) and `blocker_distance` (also purely geometric, computed at the initial state) are both still computed, since neither depends on a witness existing. `legal_move_structure`'s witness-sequence-dependent fields (`legal_choice_sequence`, `longest_forced_run`, etc.) and `unlock_sequence` (and therefore `dependency_graph.max_unlock_fan_out`, which is defined purely in terms of `unlock_sequence`) are empty/zero, since no complete witness exists to sequence them against. This is called out explicitly so a computed `dependency_graph`/`blocker_distance` is never mistaken for a claim that the puzzle is solvable (spec Edge Cases).

## DependencyGraph (the `dependency_graph` field above)

| Field | Type | Description |
|---|---|---|
| `edge_count` | `int` | Count of ordered pairs (A, B) at the *initial* state where a cell A occupies lies on B's forward escape ray (A blocks B), per `PuzzleState.is_blocked`'s exact check. |
| `depth` | `int` | The length, in edges, of the graph's **longest simple directed path** (see Depth/Longest-Chain Semantics below), computed over the full initial-state graph (not witness-order-dependent). |
| `longest_chain` | `Array[Vector2i]` | One concrete head sequence realizing `depth` — a simple path (no repeated node) — for inspection/debugging. Deterministic tie-break: see below. |
| `max_in_degree` | `int` | Maximum number of distinct blockers affecting any single arrow at the initial state. |
| `max_out_degree` | `int` | Maximum number of arrows any single arrow blocks at the initial state — reported for completeness, but **never** presented as "cascade fan-out" (see spec FR-005: a blocked arrow may have more than one blocker, so out-degree alone does not predict `unlock_sequence`'s empirical fan-out). |
| `component_count` | `int` | Number of weakly-connected components in the graph (arrows with zero edges to any other arrow each count as their own singleton component). |
| `max_unlock_fan_out` | `int` | `max(unlock_sequence)` if non-empty, else `0`. This is the system's one authoritative "cascade fan-out" value, always empirically derived from `unlock_sequence`, never from `max_out_degree` (FR-005, FR-006). |

**Orientation convention** (FR-004): edge `A -> B` means "A blocks B." `A`'s out-degree counts arrows it blocks; `B`'s in-degree counts arrows currently blocking it. Edges only ever disappear as arrows are removed (monotonic graph), matching `PuzzleState`'s own monotonic removal guarantee — this is stated for implementers, not re-validated by a new proof, since `PuzzleSolver`'s existing header already carries the proof this graph's monotonicity depends on.

### Depth / Longest-Chain Semantics (precise, including cyclic graphs)

A geometric dependency cycle among remaining arrows is possible (`PuzzleDefinition.get_validation_errors()` does not forbid it — see spec Edge Cases), even though a *catalog* puzzle is still required to be solver-confirmed solvable (FR-020) and therefore, in practice, never ships with one. `depth`/`longest_chain` must still be precisely and finitely defined for the general case, since `PuzzleAnalyzer` is also usable analytically/for debugging against a candidate definition that hasn't been (or can't be) solver-confirmed yet.

- **Definition**: `depth` is the length, in edges, of the graph's longest **simple** directed path — a path that visits no node (arrow head) more than once. This is well-defined and finite for *any* directed graph, cyclic or not: a simple path in a graph with `N` nodes has at most `N` nodes and `N-1` edges, so no path-search may revisit a node already on the current path, which is exactly what guarantees termination for a cyclic graph (a would-be revisit ends that branch of the search rather than looping).
- **Algorithm shape**: depth-first search from every node, tracking a *per-path* visited set (not a single global-visited set) so the same node can be explored as the start of a different path, but never revisited within one path. `tests/puzzle_analyzer_check.gd`'s cyclic-graph case (see Fix below) is the executable proof this terminates and returns the documented value.
- **Determinism / tie-break**: when more than one simple path realizes the maximum length, `longest_chain` returns the one whose *sequence of heads* sorts lexicographically smallest under `PuzzleSolver.analyze()`'s own existing (y, x)-ascending head comparator (the same comparator already used to break ties when multiple arrows are simultaneously legal) — applied by comparing successive heads position-by-position along each candidate path. This reuses an existing, already-tested ordering rule rather than inventing a second one.
- **Cyclic subgraphs specifically**: a cycle contributes at most `(cycle length - 1)` edges to any single simple path through it (the path must break the cycle by refusing to revisit its starting node), so `depth` over a purely cyclic component is finite and equal to the size of its longest simple sub-path, never "infinite" or "undefined."
- **This is an analysis-only allowance, not a content or gameplay concession**: computing a finite `depth`/`longest_chain` for a cyclic candidate definition does not imply that candidate is solvable or shippable. `PuzzleSolver.analyze(definition).solvable` remains the sole authority on whether a puzzle can be completed, and FR-020's regression gate remains the sole authority on whether a puzzle may ship in `PuzzleCatalog`. A cyclic component among remaining arrows is definitionally unsolvable (no legal move can ever exist within it), so `PuzzleAnalyzer` correctly computing a finite `depth` for such a graph is purely a debugging/analysis aid for a *candidate* definition, never evidence that the candidate belongs in the catalog.
- **Test coverage**: `tests/puzzle_analyzer_check.gd` includes a synthetic mixed acyclic+cyclic case (e.g. three arrows A→B→C forming a simple chain, plus a separate two-arrow cycle D↔E with no edge into or out of {A,B,C}) asserting the exact expected `depth` (2, realized by A→B→C), `longest_chain` (`[A, B, C]`), and `component_count` (2) — proving both the termination guarantee and the exact documented value, not merely "does not hang."

## ExperimentalPuzzleCatalogEntry (extension of the existing `PuzzleCatalog` entry shape)

No new fields on the existing `{id: String, title: String, build: Callable}` entry shape — six new entries are appended using the identical shape the existing eight already use. Distinguished only by which of the six named experiments (Nested Chain, Cascade/Key Arrow, Dense Unravel, Bent Network, Long-Range Blocker, Composed/Shaped) its authored geometry is designed to satisfy, verifiable after the fact by running `PuzzleAnalyzer.analyze()` against its `build()` result (spec FR-013 through FR-018; overlap across experiments is allowed and desirable per FR-012).

### Operational Acceptance Thresholds (FR-013, FR-015, FR-017, FR-018)

Spec.md's product-facing wording for these four requirements is deliberately qualitative ("meaningfully higher," "meaningfully far," "board large enough") — that phrasing is preserved as-is in spec.md. This subsection is the operational anchor tasks.md's verification step (T025) checks against, so "meaningfully" resolves to a specific, checkable number rather than reviewer judgment, without editing the spec's product language:

- **FR-015 (Dense Unravel) density threshold**: the pre-spec research (`.devspark.work/research/pre-spec-006-puzzle-difficulty-research.md`) measured the existing eight catalog puzzles' density in the 0.20–0.50 range, and the unshipped legacy `create_fixed()` board at 0.65. "Meaningfully higher" for this puzzle means `board.density >= 0.55` — closer to the proven-richer legacy board than to any shipped puzzle — **combined with** `legal_move_structure.forced_state_ratio + legal_move_structure.branching_state_ratio` implying at least one non-trivial forced or branching state (i.e. `legal_move_structure.initial_legal_ratio <= 0.50`, ruling out the existing `dense_board` puzzle's 0.90 "everything already legal" pattern).
- **FR-017 (Long-Range Blocker) distance threshold**: "meaningfully far" means at least one `blocker_distance.edges[].distance >= 4` (the blocking cell is the 4th-or-later cell along the blocked arrow's forward ray, not the immediately adjacent 1st or 2nd), on a board dimension large enough to contain that ray (i.e. `board.width >= 5` or `board.height >= 5` along the relevant axis).
- **FR-018 (Composed / Shaped) board-size threshold**: "large enough" means `board.total_cells >= 49` (at least a 7x7 board, the smallest square that can render a recognizable non-trivial macro shape via `PuzzleAnalyzer.occupancy_grid()`), combined with `dependency_graph.edge_count >= 1` (the "genuine dependency edge" requirement).
- **FR-013 (Nested Chain) spatial-distribution proxy**: "not laid out as one obvious straight run" means `dependency_graph.depth >= 3` **and** the realizing `longest_chain`'s head cells are not all collinear (not all sharing the same row or the same column) — a cheap, objective proxy for "spread across board regions" consistent with FR-013's own wording; this does not claim to measure human-perceived discoverability (that remains the calibration worksheet's job per spec FR-022).

These thresholds are operational/verification detail, not new product requirements — they exist so T025's "verify property" step has an exact pass/fail check instead of subjective re-reading of the spec's qualitative language.

## DeveloperStructuralReport (output of `tests/puzzle_structural_report.gd`)

Not a data class — a deterministic sequence of `print()` lines over the full `PuzzleCatalog`, each puzzle's `PuzzleAnalyzer.analyze()` result, and nine explicit superlative lines (deepest chain, fewest initial legal, widest branching, largest cascade, longest forced run, highest density, most bends, longest blocker distance, largest board) per spec FR-021. See [contracts/developer-report-format.md](contracts/developer-report-format.md) for the exact line format.

## HumanCalibrationRecord (one entry per experimental puzzle in `calibration/records.md`)

| Field | Type | Notes |
|---|---|---|
| `puzzle_id` | string | Must match a `PuzzleCatalog` stable id among the six new entries. |
| `score`, `mistakes`, `accuracy` | from `PuzzleState.get_results()` | Recorded verbatim from an actual completed play session, not re-derived. |
| `perceived_challenge` | int, 1–5 | Human-assigned. |
| `scanning_load` | enum: low / medium / high | Human-assigned. |
| `sequence_discoverability` | enum: obvious / required_some_tracing / required_significant_tracing | Human-assigned. |
| `aha_moment` | bool | Human-assigned. |
| `felt_solved_before_completion` | bool | Human-assigned. |
| `interesting_because` | free text | Required. |
| `frustrating_because` | free text | Optional (FR-022). |

## FindingsSummary (`calibration/findings-summary.md`, FR-026)

Not a structured data record — a short markdown document, one subsection per named experiment, each stating a `Supported` / `Contradicted` / `Inconclusive` verdict against that experiment's targeted hypothesis plus one or two sentences of supporting observation drawn from the matching `HumanCalibrationRecord`(s), and a closing list of characteristics recommended for further investigation before any future generation spec. Explicitly excludes any composite score, formula, or generator design (FR-026).
