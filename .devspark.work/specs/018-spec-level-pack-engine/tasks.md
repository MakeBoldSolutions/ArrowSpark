---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
description: "Task list for the level pack engine"
devspark_version: "9.3.0"
plan_semantic_hash: "sem1:3ff47d123d190502005d56cabe849bf3b797c4e963db79c323ff6122d0ea6517"
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Tasks: Level Pack Engine

**Input**: Design documents from `/.devspark.work/specs/018-spec-level-pack-engine/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/pack-build-cli.md, quickstart.md

**Tests**: Delta is `add` (pack gate, generator check, build-tool double-run) and `update` (catalog pins, launchers, structural report). Required gates: checklist, analyze, critic, `verify:snapshot-neutral`, `verify:end-to-end`.

`$G44` = Godot 4.4.1 console executable; `$G44WEB` = Godot 4.4-stable editor with installed Web templates (see quickstart.md). Throwaway probes live under `.devspark.work/specs/018-spec-level-pack-engine/probes/` and are never committed outside `.devspark.work/`.

## Foundational (blocks all stories)

- [ ] T001 Capture the BEFORE snapshot on the unchanged catalog. Write `gates/snapshot-before-report.txt` from `python tests/run_puzzle_structural_report.py --godot "$G44"`, and write `gates/snapshot-before-pins.txt` from a probe printing `index|id|title|group|group_position|next_in_group|content_version` for every entry (verify:snapshot-neutral, quickstart §1). This must run before any change to `scripts/puzzle/puzzle_catalog.gd`. (Implements: FR-005)
- [ ] T002 Create `PuzzlePackFormat` in `scripts/puzzle/puzzle_pack_format.gd`. It parses the catalog manifest and packs (with int conversion and per-level errors naming pack and level), converts a record to a `PuzzleDefinition` (the vertex expansion moved from `_tail_along`), converts a definition to compressed vertex arrows in `head_less_than` order, and serializes a pack deterministically in the data-model.md key order with one arrow per line. (Implements: FR-002, FR-010, FR-020)

## User Story 1 — Existing levels play exactly as before from level packs (P1)

**Goal**: The 30 levels load from packs with identical catalog behavior (FR-001–FR-010). **Independent Test**: The BEFORE/AFTER snapshot diffs are empty and both regression gates pass (SC-001, SC-002).

- [ ] T003 [US1] Add the pack gate to `tests/puzzle_catalog_check.gd`. It checks that `PuzzleCatalog.load_errors()` is empty, and for every entry: validity, solvability, stored `content_version` equal to `PuzzleContentVersion.of()`, a group in `GROUP_TITLES`, and unique ids and content versions across all packs. Keep `CATALOG_PINS` and every existing check unchanged. (Implements: FR-008, FR-009, FR-010)
- [ ] T004 [US1] Run a migration probe that reads the current builders through `PuzzleCatalog.get_definition`. It writes `levels/packs/foundations.json`, `levels/packs/puzzle_lab.json` and `levels/packs/arrowspark_levels.json` through `PuzzlePackFormat`, with `provenance: {"kind": "hand-authored"}` and each builder's doc comment as `notes`, plus `levels/catalog.json` listing those three packs. (Implements: FR-002, FR-005)
- [ ] T005 [US1] Rework `scripts/puzzle/puzzle_catalog.gd`:
  - `_ensure_entries` loads `res://levels/catalog.json` and its packs through `PuzzlePackFormat`, builds an id→index Dictionary, and exposes `load_errors()` (with `push_error` per error).
  - `get_definition` builds a fresh definition from the stored record, and `index_of` uses the map.
  - Delete every `_build_*` builder, `_from_shapes` and `_tail_along`.
  - Rewrite the class doc comment for packs. The public API is unchanged.

  (Implements: FR-001, FR-003, FR-004, FR-007, FR-010)
- [ ] T006 [P] [US1] In `export_presets.cfg`, set `include_filter="levels/catalog.json, levels/packs/*.json"` and set `exclude_filter="tests/*, levels/recipes/*"`. (Implements: FR-006)
- [ ] T007 [P] [US1] Make the isolated temp projects copy `levels/` and `scripts/puzzle/puzzle_pack_format.gd`, keeping the same `res://levels/` paths, in `tests/run_puzzle_regressions.py`, `tests/run_puzzle_structural_report.py` and `tests/run_regressions.py`. (Implements: FR-001)
- [ ] T008 [US1] Capture the AFTER snapshot (same commands as T001, into `gates/snapshot-after-report.txt` and `gates/snapshot-after-pins.txt`) before the sample pack exists. Diff each against BEFORE (both must be empty) and record the commands, outputs and diffs as the `snapshot-neutral` block in `gates/verify.md` (verify:snapshot-neutral). (Implements: FR-005)
- [ ] T009 [US1] Run `python tests/run_puzzle_regressions.py --godot "$G44"` and `python tests/run_regressions.py --godot "$G44"`; both must pass with 30 entries (SC-002).

## User Story 2 — Developer generates a reproducible level from a profile (P2)

**Goal**: A deterministic seeded generator measured only by the existing validator, solver and analyzer (FR-011–FR-016). **Independent Test**: `tests/puzzle_generator_check.gd` passes inside the puzzle regression gate.

- [ ] T010 [US2] Add `tests/puzzle_generator_check.gd`, printing `PUZZLE_GENERATOR_FAILURES=<n>` like the existing checks. It covers:
  - the same profile and seed called 3 times give the same content version, and different seeds differ (FR-011, SC-004)
  - a reachable small profile returns `ok`, valid, solvable and in range (FR-012, FR-013)
  - `initial_playable_cap` is honored (FR-012)
  - an unreachable profile returns `ok == false` with `misses` naming each metric (FR-014, FR-015)
  - each contradictory-profile case is rejected with `profile_errors` and `attempts_used == 0` (FR-016)

  Also register it in `tests/run_puzzle_regressions.py`, including copying `scripts/puzzle/puzzle_generator.gd`. Keep the profiles small so the gate stays fast. (Implements: FR-011, FR-012, FR-013, FR-014, FR-015, FR-016)
- [ ] T011 [US2] Implement `PuzzleGenerator.generate(profile, seed)` in `scripts/puzzle/puzzle_generator.gd`, as in the plan Decision Summary and data-model.md:
  - profile validation before any search
  - one seeded `RandomNumberGenerator`
  - reverse-solve-order placement with `center_out` / `uniform` layering and the playable-cap tail preference
  - candidates measured only via `get_validation_errors()` and `PuzzleAnalyzer.analyze()`
  - normalized out-of-range scoring, stopping early at a score of 0 within the `attempts` budget
  - a result dictionary as in data-model.md, and the `GENERATOR_SCHEME := "gen1"` constant

  (Implements: FR-011, FR-012, FR-013, FR-014, FR-015, FR-016)

## User Story 3 — Developer builds a level pack from a recipe (P3)

**Goal**: One command builds a gated, reproducible pack, and the sample pack appears as its own Level Select group (FR-017–FR-023). **Independent Test**: `run_level_pack_build.py --check` exits 0 on the committed sample, and the fourth section plays (SC-005, SC-008).

- [ ] T012 [P] [US3] Move `_print_entry` from `tests/puzzle_structural_report.gd` into a static helper in `tests/puzzle_report_format.gd`, and call it from the structural report so its output stays byte-identical. Add the helper to the copy list in `tests/run_puzzle_structural_report.py`. (Implements: FR-018)
- [ ] T013 [US3] Add `tests/level_pack_build.gd`, following contracts/pack-build-cli.md:
  - parse the recipe
  - check the pack is listed in `levels/catalog.json`
  - generate each level and require `ok`, validity and solvability
  - check id and content-version uniqueness against the other packs (skipping the pack being rebuilt) and within the recipe
  - print the shared report entry plus a profile line
  - write `generated` provenance with the inline profile
  - print `PACK_BUILD_FAILURES=<n>`, and print the serialized pack between `PACK_BEGIN`/`PACK_END` only when that count is 0

  (Implements: FR-017, FR-018, FR-019)
- [ ] T014 [US3] Add `tests/run_level_pack_build.py` (`--godot`, `--recipe`, `--check`), following contracts/pack-build-cli.md:
  - build an isolated temp project as `run_puzzle_structural_report.py` does
  - fail on script or parse errors or on failures greater than 0, writing nothing
  - write `levels/packs/<pack>.json` with the exact marker bytes
  - in `--check` mode, compare byte-for-byte with the committed file

  (Implements: FR-017, FR-019, FR-020)
- [ ] T015 [US3] Add `GROUP_GENERATED := "generated"` with the title "Generated Levels" to `GROUP_TITLES` in `scripts/puzzle/puzzle_catalog.gd`, appended last in `group_ids()`. (Implements: FR-022)
- [ ] T016 [P] [US3] In `scenes/menus/main_menu/puzzle_select_menu.gd`, map the generated group to `&"LevelCardEmber"` in `GROUP_CARD_VARIATIONS`, and give it the description "Boards built by the level generator; an untuned first sample." in `GROUP_DESCRIPTIONS`. (Implements: FR-022, FR-023)
- [ ] T017 [US3] Author `levels/recipes/generated_sample.json`:
  - four levels in group `generated`, rising from about 7×6 with 6 arrows to about 15×10 with 20 arrows, all `center_out` with a playable cap
  - add `generated_sample` last in `levels/catalog.json`
  - run `python tests/run_level_pack_build.py --godot "$G44" --recipe levels/recipes/generated_sample.json`, adjusting seeds or profiles until it writes `levels/packs/generated_sample.json`
  - curate the titles by hand

  (Implements: FR-021, FR-022)
- [ ] T018 [US3] Update `tests/puzzle_catalog_check.gd`:
  - append four `CATALOG_PINS` entries for the sample levels
  - extend the group checks to the generated group: its title, its position after the existing three, group-relative numbering from 1, and no next level after its last level
  - assert that the existing three groups' order and numbering are unchanged

  Update `tests/puzzle_layout_check.gd` or `tests/portrait_menu_check.gd` only if they assume exactly three Level Select sections. (Implements: FR-008, FR-022, FR-023)
- [ ] T019 [US3] Run `run_level_pack_build.py ... --check` on the sample recipe; it must exit 0 (FR-020, SC-004, SC-005). Run a temporary recipe under `probes/` with an unreachable profile and one with a duplicate id; each must exit non-zero, name the level and write nothing. Record the commands and outputs in `gates/verify.md`. (Implements: FR-019, FR-020)

## Final — Knowledge, verification, linkage

- [ ] T020 Update `.knowledge/architecture/arrow-puzzle.md`. Cover the catalog loading level packs, the pack format and manifest, `PuzzlePackFormat`, `PuzzleGenerator` (one rules engine, generation never at runtime), the pack-build tool, the generated group, the pack gate and `load_errors()`. Replace references to builders, `_from_shapes` and `_tail_along`, and add the new files to `appliesTo`. (Implements: FR-001, FR-011, FR-017, FR-022)
- [ ] T021 [P] Update `.knowledge/reference/progression-design-learning.md`, `.knowledge/reference/gordian-knot-experiments.md` and `.knowledge/reference/reference-puzzle-design-report.md`. Boards and design notes now live in `levels/packs/*.json`. Where the progression doc says the search is not kept, state that a seeded generator and pack-build tool now exist in the repo, and that Reference-Knot-class density is not reached by it. Add `appliesTo` entries for the packs.
- [ ] T022 [P] Update the Export bullet in `.knowledge/architecture/web-showcase.md` with the level-pack include and recipe exclude filters. (Implements: FR-006)
- [ ] T023 [P] Document `puzzle_generator_check.gd`, the pack gate, `run_level_pack_build.py` (including `--check`) and the shared report helper in `tests/README.md`. (Implements: FR-017)
- [ ] T024 [P] Add a Recent Changes entry to `CLAUDE.md` (justified support: the agent guidance file) describing level packs, the generator and the pack-build tool. It must contain no spec, plan, task or feature identifiers.
- [ ] T025 Run Godot validation with `"$G44" --headless --path . --editor --quit`, then both regression gates, all with 34 entries. Record the results (Principle V).
- [ ] T026 Run the desktop smoke test from quickstart.md §4 with a fresh scratch `APPDATA`:
  - four sections in the right order
  - one level per group played with mouse, keyboard and gamepad
  - Next Puzzle within the generated group, with no next after its last level
  - Level Select load time compared with before

  Record the results, and record any input method not tested as not tested (Principle III and V, SC-007, SC-008).
- [ ] T027 Run the Web end-to-end check from quickstart.md §5:
  - `node web/scripts/export-game.mjs --godot "$G44WEB"`, then `cd web && npm ci && npm run check && npm run build`
  - play one level from each of the four groups in Firefox, in a Chromium-based browser, and on at least one real phone
  - confirm there are no load errors in the console

  Record it as the `end-to-end` block in `gates/verify.md`, with untested browsers or devices recorded as not tested (verify:end-to-end, SC-003). (Implements: FR-006)
- [ ] T028 Run the no-back-link check. Search the durable changes (`scripts/`, `scenes/`, `tests/`, `levels/`, `.knowledge/`, `CLAUDE.md`, `export_presets.cfg`) for `018-spec`, `.devspark.work`, `spec.md`, `plan.md`, `tasks.md` and FR/SC ids, and confirm none appear. Keep the complete feature directory under `.devspark.work/` after all checks pass.

## Gate Remediation

- [ ] T029 [P] Add `levels/**` and `export_presets.cfg` to both `on.push.paths` and `on.pull_request.paths` in `.github/workflows/godot-regression-tests.yml` (justified support for the pack gate, under developer decision D-001) (Implements: FR-008) (resolves: critic-001)

---

## Dependencies

- T001 must complete before T004/T005 touch the catalog. T002 blocks T004, T005, T013 and T014.
- T008 runs after T005–T007 and before T017, so both snapshots cover exactly the 30 migrated levels.
- US3's T013/T014/T017 need US1 (loader, launchers) and US2 (T011). T015 must land before T017 builds levels in the `generated` group.
- T025–T027 run after all story tasks. T020–T024 can run in parallel with them once T018 is done.
