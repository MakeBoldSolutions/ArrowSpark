---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
devspark_version: "9.3.0"
spec_semantic_hash: "sem1:5f6bc6aa66ba9fe5e48269dde709109c86b2fd0e2d7344b92071add3c020144c"
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Implementation Plan: Level Pack Engine

**Branch**: `018-spec-level-pack-engine` | **Date**: 2026-10-23 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/.devspark.work/specs/018-spec-level-pack-engine/spec.md`

## Rationale Summary

### Core Problem

Level geometry lives in per-level GDScript builders and the search that found the best boards is not in the repository, so levels cannot be added, reproduced or produced at volume.

### Decision Summary

**Closest existing pattern**: `PuzzleCatalog` (`scripts/puzzle/puzzle_catalog.gd`) — a static registry whose `_entries` hold `{id, title, group, build}` and whose `_from_shapes`/`_tail_along` already express most boards as `[head, direction, vertices]`. It is **extended**: the entry's `build` Callable is replaced by a parsed level record, and the public API is unchanged. The regression side reuses `tests/puzzle_catalog_check.gd` (`CATALOG_PINS`, already pinning id, title, group, position and content version for all 30 levels) and the isolated temp-project launchers `tests/run_puzzle_regressions.py` / `tests/run_puzzle_structural_report.py`. The build tool copies the structural-report launcher pattern.

**New mechanism**:
1. `PuzzlePackFormat` (`scripts/puzzle/puzzle_pack_format.gd`) — parse, convert and deterministically serialize level packs. Needed because both the catalog (read) and the build tool (write) must agree byte-for-byte on one format (FR-002, FR-020); putting it inside `PuzzleCatalog` would make the catalog a writer. Lighter option rejected: Godot `JSON.stringify` alone — it cannot produce the one-arrow-per-line layout that keeps a 115-arrow board reviewable.
2. `PuzzleGenerator` (`scripts/puzzle/puzzle_generator.gd`) — the seeded generator (FR-011–FR-016). Nothing in the repo proposes boards; the analyzer and solver only measure them. It never decides validity, solvability or metrics itself (architectural constraint).
3. The pack-build tool (`tests/run_level_pack_build.py` + `tests/level_pack_build.gd`) — FR-017–FR-020. It is a sibling of the structural-report launcher and lives under `tests/`, which the Web export already excludes.

Decisions (evidence in [research.md](research.md)):

- **Format: JSON text files, read with `FileAccess` + `JSON.parse_string`.** They diff cleanly, need no `class_name` registry (so the bare temp-project launchers keep working), and Python can read them. The Web preset's `include_filter` explicitly adds `levels/packs/*.json` and `levels/catalog.json`, so inclusion doesn't depend on how `all_resources` classifies `.json`. Recipes go in `levels/recipes/`, which is added to `exclude_filter`.
- **Catalog order comes from one manifest**, `levels/catalog.json`, which lists packs in order: `foundations`, `puzzle_lab`, `arrowspark_levels`, `generated_sample`. Catalog order is the manifest order, then the level order within each pack. Directory listing is rejected because its order is not a contract and listing behaves differently in exported builds.
- **Groups stay in code.** `GROUP_*` constants, `GROUP_TITLES` and `group_ids()` stay in `PuzzleCatalog`; one constant, `GROUP_GENERATED := "generated"`, is added. Its title is "Generated Levels" and its description is "Boards built by the level generator; an untuned first sample." `group_ids()` appends it last (FR-022). The menu reuses the existing `&"LevelCardEmber"` card variation, so no theme change is needed. There are only four groups, and moving group metadata into data would buy nothing.
- **Arrow encoding: `[direction_name, vertices]`.** `vertices[0]` is the head, followed by each bend, then the tail end. This is the `_from_shapes` form. Direction names (`up/down/left/right`) match `PuzzleContentVersion`. Migration compresses each existing tail into vertices. Because the `g1` hash is computed from the expanded cells, a lossless round trip is proved by equal content versions (FR-005).
- **Hand-authored provenance keeps each builder's doc comment as `notes`.** That prose is the only per-level design record (for example, why `false_simplicity` exists). Deleting the builders (FR-007) must not delete it.
- **Loader failure is loud, not fatal.** `_ensure_entries` collects parse and shape errors into `PuzzleCatalog.load_errors()` and calls `push_error` for each, naming the pack and level. A malformed level is never added. The catalog gate asserts `load_errors()` is empty. The game does not crash on a bad pack in a player's build, but the gate makes that state unshippable (edge cases, FR-010).
- **Lookup uses an id→index Dictionary** built once in `_ensure_entries` (FR-004). `get_definition` builds a new `PuzzleDefinition` from the stored record on every call. The constructor's `duplicate(true)` keeps definitions isolated (FR-003).
- **The generator is a pure static function**: `PuzzleGenerator.generate(profile, seed) -> Dictionary`.
  - **Determinism**: one `RandomNumberGenerator` with `seed` set, and iteration only over Arrays it builds in a fixed order.
  - **Placement**: reverse solve order. A new arrow's head is accepted only if its forward ray is clear of every already-placed cell. Its tail is a random walk over empty cells that never enters its own ray. So the last arrow placed is the first removable, and the board is solvable by construction (FR-012).
  - **Layering**: `center_out` orders candidate heads by distance from the board centre with seeded jitter; `uniform` shuffles them.
  - **Playable cap**: while the number of arrows with a clear ray exceeds `initial_playable_cap`, the tail walk prefers cells on currently-clear arrows' rays.
  - **Scoring**: each candidate is measured only through `PuzzleDefinition.get_validation_errors()` and `PuzzleAnalyzer.analyze()`, which runs `PuzzleSolver`. Its score is the sum of each profiled metric's normalized distance outside its range. The search stops at the first score of 0 or when the attempt budget runs out, keeping the lowest score (the first one on ties). The result reports every metric against its range (FR-013–FR-015). A profile is rejected before any search if a min exceeds its max, a dimension is under 2, the maximum arrow count exceeds the cell count, density is outside (0, 1], or the budget is outside 1–5000 (FR-016).
  - **Scheme stamp**: provenance records `generator: "gen1"`, so a later algorithm change is visible next to the pinned content version.
- **Build tool flow** (the build is atomic; FR-019):
  1. Python copies the puzzle scripts and `levels/` into a fresh temp project.
  2. Godot generates every level, then checks validity, solvability, the profile, and that no id or content version repeats one in another pack or in the recipe itself. Levels already in the pack being rebuilt are ignored, so a rebuild doesn't collide with itself.
  3. It prints the structural report for each level, plus the serialized pack between `PACK_BEGIN` and `PACK_END` markers and `PACK_BUILD_FAILURES=<n>`.
  4. Python writes `levels/packs/<pack>.json` only when the failure count is 0.
  5. The recipe's profile is stored inline in each level's provenance, so a level can be regenerated without the recipe.
- **Structural report printing is shared.** `_print_entry` moves into `tests/puzzle_report_format.gd` as a static helper used by both the structural report and the build tool (FR-018), so the two reports cannot diverge.
- **The 30 levels are migrated once by a throwaway probe**, kept under `.devspark.work/` and never committed. It reads the current builders, writes the three packs through `PuzzlePackFormat.serialize_pack`, and copies each builder's doc comment into `notes`. The builders are then deleted. The proof is the existing pins plus the before/after snapshot in [quickstart.md](quickstart.md).

### Key Drivers

- `CATALOG_PINS` already pins all 30 levels, so the migration needs no new proof machinery, only a snapshot run before and after.
- The bare temp-project launchers have no `class_name` cache beyond the copied scripts, which rules out a custom `Resource` format that would need registering in each launcher.
- The Web export uses `export_filter="all_resources"` with an empty `include_filter`. A new non-script data file is the one place a test-green change can still be missing from the shipped `.pck`.

### Reviewer Guidance

- Check that `PuzzleGenerator` imports no rule logic: every legality, validity or metric value must come from `PuzzleDefinition`, `PuzzleSolver` or `PuzzleAnalyzer`. The only geometry it computes itself is the placement-time clear-ray and empty-cell tests that propose candidates. Those are proposals, re-checked by the solver.
- Check that the snapshot evidence diffs the full structural report (which includes witnesses) and the pins dump, before and after, for all 30 levels.

## Technical Context

**Language/Version**: GDScript, Godot 4.4 (gates on 4.4.1; Web export on 4.4-stable templates); Python 3.11+ launchers
**Primary Dependencies**: Godot built-ins only (`FileAccess`, `JSON`, `RandomNumberGenerator`); no new addon or package
**Storage**: Committed read-only JSON files under `res://levels/`; no `user://` access (no save data touched)
**Testing**: Headless GDScript checks under `tests/` run by `tests/run_puzzle_regressions.py` and `tests/run_regressions.py`; desktop, browser and real-phone smoke tests per Principle V
**Target Platform**: Desktop (Windows) and the Godot Web export (no threads) in Firefox, Chromium-based browsers and one real phone
**Project Type**: Godot game plus developer tooling
**Performance Goals**: Catalog load (parse four packs, about 34 levels) runs once per process, with no perceptible delay when opening Level Select (SC-007). Generator speed is a developer concern only, bounded by the attempt budget.
**Constraints**: Generation never runs in the shipped game. One rules engine. Byte-identical rebuilds. Determinism is promised on Godot 4.4.x only.
**Scale/Scope**: 30 migrated levels plus 4 sample levels. The pack-build tool is run by hand by a developer, occasionally.

## Expected Change Surface

```yaml
expected_change_surface:
  - {path: "scripts/puzzle/puzzle_pack_format.gd", change: add, why: "PuzzlePackFormat: parse/validate pack and manifest text, record -> PuzzleDefinition, definition -> vertex arrows, deterministic serialize_pack"}
  - {path: "scripts/puzzle/puzzle_generator.gd", change: add, why: "PuzzleGenerator: seeded reverse-solve-order placement, profile validation, scoring via PuzzleAnalyzer"}
  - {path: "scripts/puzzle/puzzle_catalog.gd", change: modify, why: "load manifest + packs, id->index map, load_errors(), GROUP_GENERATED; delete all _build_* builders, _from_shapes and _tail_along (moved into PuzzlePackFormat); public API unchanged"}
  - {path: "levels/catalog.json", change: add, why: "ordered pack manifest (catalog order)"}
  - {path: "levels/packs/foundations.json", change: add, why: "8 migrated Foundations levels"}
  - {path: "levels/packs/puzzle_lab.json", change: add, why: "13 migrated Puzzle Lab levels"}
  - {path: "levels/packs/arrowspark_levels.json", change: add, why: "9 migrated ArrowSpark Levels"}
  - {path: "levels/packs/generated_sample.json", change: add, why: "4-level sample pack built by the tool (FR-021/FR-022)"}
  - {path: "levels/recipes/generated_sample.json", change: add, why: "sample recipe proving the tool"}
  - {path: "export_presets.cfg", change: modify, why: "include_filter adds levels/catalog.json and levels/packs/*.json; exclude_filter adds levels/recipes/*"}
  - {path: "scenes/menus/main_menu/puzzle_select_menu.gd", change: modify, why: "GROUP_CARD_VARIATIONS and GROUP_DESCRIPTIONS gain the generated group"}
  - {path: "tests/puzzle_catalog_check.gd", change: modify, why: "pack gate (load_errors empty, validity, solvability, stored vs recomputed content version, unique ids/versions, known groups); CATALOG_PINS gains 4 sample entries; group checks include the new group"}
  - {path: "tests/puzzle_generator_check.gd", change: add, why: "determinism, profile rejection, playable cap, in-range result, unreachable-profile miss report"}
  - {path: "tests/puzzle_report_format.gd", change: add, why: "shared structural-report entry printer"}
  - {path: "tests/puzzle_structural_report.gd", change: modify, why: "use the shared printer"}
  - {path: "tests/level_pack_build.gd", change: add, why: "headless build: generate, gate, report, emit serialized pack"}
  - {path: "tests/run_level_pack_build.py", change: add, why: "launcher: temp project, run build, atomically write pack on zero failures"}
  - {path: "tests/run_puzzle_regressions.py", change: modify, why: "copy levels/ and the new scripts into the temp project; run puzzle_generator_check.gd"}
  - {path: "tests/run_puzzle_structural_report.py", change: modify, why: "copy levels/, puzzle_pack_format and the shared printer"}
  - {path: "tests/run_regressions.py", change: modify, why: "its temp project copies puzzle_catalog; add puzzle_pack_format and levels/"}
  - {path: "tests/README.md", change: modify, why: "document the generator check and the pack-build tool"}
  - {path: ".knowledge/architecture/arrow-puzzle.md", change: modify, why: "catalog now reads level packs; pack format, generator and build tool; replace builder references"}
  - {path: ".knowledge/reference/progression-design-learning.md", change: modify, why: "boards are now pack data; the search now exists in the repo"}
  - {path: ".knowledge/reference/gordian-knot-experiments.md", change: modify, why: "source-of-truth line names the catalog file; point at the pack"}
  - {path: ".knowledge/reference/reference-puzzle-design-report.md", change: modify, why: "builder-comment references now point at the pack's notes"}
  - {path: ".knowledge/architecture/web-showcase.md", change: modify, why: "Export bullet: level pack include/exclude filters"}
  - {path: "tests/puzzle_layout_check.gd", change: inspect, why: "runs against the real project; confirm Level Select section count assumptions"}
  - {path: "tests/portrait_menu_check.gd", change: inspect, why: "may count Level Select sections or buttons"}
```

## Constitution Check

*Pre-design and post-design: PASS, no waivers.*

| Principle | Applies | How the design satisfies it |
|---|---|---|
| I. Simple, Maintainable Code | Yes | Three new mechanisms, each tied to a requirement the catalog cannot meet (see Decision Summary). New files and functions are snake_case. The catalog's public API is unchanged, and the 1,091-line builder file shrinks to a loader. |
| II. Template Customization | Yes | No addon file changes. The menu change is in a project script. |
| III. Accessible Controls | Yes (menu) | The new section is built by the existing loop in `puzzle_select_menu.gd`, so focus order and gamepad/keyboard navigation come from the existing mechanism. The smoke test walks to the fourth section with keyboard and gamepad (FR-023, SC-008). |
| IV. Responsive Gameplay | Yes | Packs are parsed once per process. No generation at runtime. Load time is checked in the desktop and Web smoke tests (SC-007). |
| V. Practical Verification | Yes | Godot `--headless --editor --quit` validation, both regression gates, a desktop smoke test, a Web smoke test in Firefox and a Chromium-based browser, and one real phone. Anything not run is recorded as not tested ([quickstart.md](quickstart.md)). |
| VI. Preserve Saved Progress | Yes (no-op) | No `user://` reads or writes. `PuzzleSession` and `PuzzleScoreboard` keep ids, which are unchanged, so nothing in saved data is affected. |

## Context Resolution

```yaml
context_resolved:
  - id: arrow-puzzle
    kind: knowledge
    via: direct (lexical match; appliesTo puzzle_catalog.gd, puzzle_select_menu.gd, launchers)
    hop: 0
    reason: owns catalog, content version, group and launcher behavior that this delta changes and must document
  - id: progression-design-learning
    kind: knowledge
    via: direct (lexical match; appliesTo puzzle_catalog.gd)
    hop: 0
    reason: source of the placement methods (reverse solve order, center-outward, playable cap) and of the claim that boards are literal data
  - id: reference-puzzle-design-report
    kind: knowledge
    via: direct (lexical match; appliesTo puzzle_catalog.gd)
    hop: 0
    reason: refers to the Reference Knot builder comment, which moves into pack notes
  - id: gordian-knot-experiments
    kind: knowledge
    via: direct (lexical match; appliesTo puzzle_catalog.gd)
    hop: 0
    reason: names puzzle_catalog.gd as its source of truth for six Puzzle Lab boards that move into a pack
  - id: web-showcase
    kind: knowledge
    via: direct (lexical match; appliesTo export_presets.cfg)
    hop: 0
    reason: documents the Web export preset whose filters change
  - id: arrowgame-constitution
    kind: knowledge
    via: file owner (appliesTo scripts/**, scenes/**, export_presets.cfg)
    hop: 0
    reason: Principles I, III, IV, V and VI bound the design and verification
```

Dropped candidates: `save-progression` (no save data touched), `gameplay-contract` (no rule change), `guides-repo-story-repo-story-2026-09-30` (historical narrative).

## Project Structure

New top-level data directory and new files only. Existing layout is otherwise unchanged.

```text
levels/
├── catalog.json                 # ordered pack manifest
├── packs/                       # shipped (export include_filter)
│   ├── foundations.json
│   ├── puzzle_lab.json
│   ├── arrowspark_levels.json
│   └── generated_sample.json
└── recipes/                     # developer input (export exclude_filter)
    └── generated_sample.json
scripts/puzzle/
├── puzzle_pack_format.gd        # new
└── puzzle_generator.gd          # new
tests/
├── puzzle_generator_check.gd    # new
├── puzzle_report_format.gd      # new (shared report printer)
├── level_pack_build.gd          # new
└── run_level_pack_build.py      # new
```

Planning bundle: [research.md](research.md), [data-model.md](data-model.md), [contracts/pack-build-cli.md](contracts/pack-build-cli.md), [quickstart.md](quickstart.md).

## Complexity Tracking

| Violation / Complexity | Why Needed | Simpler Alternative Rejected Because |
|------------------------|------------|--------------------------------------|
| Separate `PuzzlePackFormat` class | Reader (catalog) and writer (build tool, migration) must share one byte-exact format | Serializer inside `PuzzleCatalog` would make the runtime registry own a developer-only write path |
| Every launcher copies `levels/` | The isolated temp projects resolve `res://` against the temp root | Pointing the catalog at an absolute repo path would break the export and the isolation the launchers exist for |
