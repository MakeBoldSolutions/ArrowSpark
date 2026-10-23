# Research: Level Pack Engine

Question ledger for planning decisions that needed evidence beyond reading the code.

## Q1 — Which file format for level packs?

- **Why it matters**: FR-001, FR-002, FR-006, FR-020. The catalog, the build tool, the isolated test launchers and the Web export must all read it, and rebuilds must be byte-identical.
- **Evidence needed**: Whether Godot 4.4 reads `.json` under `res://` without import or registration, how numbers parse, and whether the launchers' bare temp projects could load a custom `Resource`.
- **Answer**: In a bare temp project, Godot 4.4.1 recognizes `json` as a resource extension (`ResourceLoader.get_recognized_extensions_for_type("JSON")` returns `["tres", "res", "json"]`), and `FileAccess.open("res://levels/x.json")` + `JSON.parse_string` works. Numbers parse as floats (`[1.0, 2.0]`), so the parser must convert to `int` and reject non-integers. `JSON.stringify` sorts keys. A custom `Resource` with a `class_name` would need copying and registering into every launcher's temp project, and `.tres` diffs poorly for geometry.
- **Evidence pointer**: Probe `jsonprobe/probe.gd` run with Godot 4.4.1 headless in the session scratchpad (2026-10-23). `tests/run_puzzle_regressions.py` builds temp projects from copied scripts only.
- **Resolution**: JSON, read via `FileAccess` + `JSON.parse_string`, written by a hand-rolled deterministic serializer (one arrow per line) in `PuzzlePackFormat`. Rejected: a `.tres` custom Resource (registry and diff cost).

## Q2 — Will the Web export include the pack files?

- **Why it matters**: FR-006, SC-003, `verify:end-to-end`.
- **Evidence needed**: The current preset's filters.
- **Answer**: `export_presets.cfg` uses `export_filter="all_resources"`, `include_filter=""`, `exclude_filter="tests/*"`. Because `json` is a recognized resource extension (Q1), `all_resources` probably already includes the files, but that is inferred, not proven.
- **Evidence pointer**: `export_presets.cfg` lines 8–11; the Q1 probe.
- **Resolution**: Don't rely on the inference. Set `include_filter="levels/catalog.json, levels/packs/*.json"` and add `levels/recipes/*` to `exclude_filter`. Proof is the end-to-end Web smoke test, which loads a level from each group in the exported build ([quickstart.md](quickstart.md)).

## Q3 — How does the catalog know which packs exist, and in what order?

- **Why it matters**: FR-003 (catalog order, group order and positions must match `CATALOG_PINS`).
- **Evidence needed**: Current catalog order, and whether each group is contiguous.
- **Answer**: `_entries` lists Foundations (8), then Puzzle Lab (13), then ArrowSpark Levels (9), each contiguous, so one pack per group in that order reproduces every position. `group_ids()` (display order) is separate and stays in code.
- **Evidence pointer**: `scripts/puzzle/puzzle_catalog.gd` lines 33–65; `CATALOG_PINS` in `tests/puzzle_catalog_check.gd`.
- **Resolution**: An explicit manifest, `levels/catalog.json`, lists packs in catalog order. Directory listing is rejected because its order is not a contract and it behaves differently inside an exported `.pck`.

## Q4 — Can every existing board be expressed as `[direction, vertices]`?

- **Why it matters**: FR-005 (lossless migration), including boards built from dictionaries and computed loops (`dense_unravel`, `composed_shaped`).
- **Evidence needed**: Whether every tail is an orthogonal path from the head, which can always be compressed to its turning points.
- **Answer**: Validation requires each tail to start immediately behind the head and continue in orthogonal unit steps without repeats. Any such path is exactly the vertex list "head, each cell where the step direction changes, last cell", and `_tail_along` expands that back to the same cells. Single-cell arrows are `[head]`. `PuzzleContentVersion.canonical_text` is computed from expanded cells in (y, x) head order, so equal versions prove an identical round trip.
- **Evidence pointer**: `PuzzleDefinition.get_validation_errors`, `PuzzleCatalog._tail_along`, `PuzzleContentVersion.canonical_text`.
- **Resolution**: One encoding for every level. Migration compresses tails, and the 30 pins prove the result.

## Q5 — Is a seeded `RandomNumberGenerator` reproducible enough for FR-011?

- **Why it matters**: FR-011, SC-004, FR-020.
- **Evidence needed**: Whether the sequence is fixed for a given seed on the gate engine.
- **Answer**: With `seed = 101`, Godot 4.4.1 produced `59339390, 1219197910` (PCG32). The remaining sources of nondeterminism are Dictionary iteration order (insertion order in GDScript, so deterministic when built deterministically) and floating-point scoring (only compared, never serialized).
- **Evidence pointer**: Q1 probe output.
- **Resolution**: One RNG per `generate()` call, seeded once. Candidate lists are Arrays built in (y, x) order before shuffling. `tests/puzzle_generator_check.gd` asserts identical content versions across repeated calls, and the build tool's double-run check covers separate processes. Determinism is promised on Godot 4.4.x only (spec assumption).
