---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
description: "Task list for the level pack engine"
devspark_version: "9.3.0"
plan_semantic_hash: "sem1:c0e26606a36f65ba2bf8af4e44d2843e26f89c17a843534044e7f2d16ca47db8"
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

**Tests**: Delta is `add` (pack gate, malformed-input negative checks, generator check, build-tool repeat and negative runs) and `update` (catalog pins, launchers, structural report). Required gates: checklist, analyze, critic, `verify:snapshot-neutral`, `verify:end-to-end`.

`$G44` = Godot 4.4.1 console executable; `$G44WEB` = Godot 4.4-stable editor with installed Web templates (see quickstart.md). Throwaway probes live under `.devspark.work/specs/018-spec-level-pack-engine/probes/` and are never committed outside `.devspark.work/`.

## Foundational (blocks all stories)
**Checkpoint**: Phase complete — 2026-10-23

- [X] T001 Capture the BEFORE snapshot on the unchanged catalog. Write `gates/snapshot-before-report.txt` from `python tests/run_puzzle_structural_report.py --godot "$G44"`, and write `gates/snapshot-before-pins.txt` from a probe printing `index|id|title|group|group_position|next_in_group|content_version` for every entry (verify:snapshot-neutral, quickstart §1). This must run before any change to `scripts/puzzle/puzzle_catalog.gd`. (Implements: FR-005)
- [X] T002 Create `PuzzlePackFormat` in `scripts/puzzle/puzzle_pack_format.gd`:
  - `load_catalog(root, skip_pack := "")` returning `{levels, errors}`, where a missing listed pack is an error unless it is `skip_pack`
  - pack-text parsing with int conversion that rejects fractional or non-numeric values and diagonal or zero-length vertex steps, with errors naming pack and level
  - record → `PuzzleDefinition` (the vertex expansion moved from `_tail_along`)
  - definition → compressed vertex arrows in `head_less_than` order
  - `audit_levels(levels, known_groups)` covering validity, solvability, content-version match, duplicate ids, duplicate boards and unknown groups
  - deterministic `serialize_pack` in the data-model.md key order, one arrow per line

  (Implements: FR-002, FR-008, FR-009, FR-010, FR-020)

## User Story 1 — Existing levels play exactly as before from level packs (P1)
**Checkpoint**: Phase complete — 2026-10-23

**Goal**: The 30 levels load from packs with identical catalog behavior (FR-001–FR-010). **Independent Test**: The BEFORE/AFTER snapshot diffs are empty and both regression gates pass, including the malformed-input checks (SC-001, SC-002).

- [X] T003 [US1] Add the pack gate to `tests/puzzle_catalog_check.gd`. It asserts `PuzzleCatalog.load_errors()` is empty and that `PuzzlePackFormat.audit_levels` over all catalog levels with the `GROUP_TITLES` keys returns no errors. Keep `CATALOG_PINS` and every existing check unchanged. (Implements: FR-008, FR-009, FR-010)
- [X] T004 [US1] Add `tests/puzzle_pack_format_check.gd`, printing `PUZZLE_PACK_FORMAT_FAILURES=<n>`, and register it in `tests/run_puzzle_regressions.py`. It must have one negative case each for: malformed JSON, a fractional coordinate, a non-numeric coordinate, a diagonal vertex step, a zero-length vertex step, an arrow that fails board validation, a missing listed pack (manifest fixture written under `user://`), duplicate ids, duplicate boards, and an unknown group. Each case asserts a non-empty error naming the pack and level, plus one passing well-formed fixture and a `skip_pack` case where a missing skipped pack produces no error. (Implements: FR-010)
- [X] T005 [US1] Run a migration probe that reads the current builders through `PuzzleCatalog.get_definition`. It writes `levels/packs/foundations.json`, `levels/packs/puzzle_lab.json` and `levels/packs/arrowspark_levels.json` through `PuzzlePackFormat.serialize_pack`, with `provenance: {"kind": "hand-authored"}` and each builder's doc comment as `notes`, plus `levels/catalog.json` listing those three packs. (Implements: FR-002, FR-005)
- [X] T006 [US1] Rework `scripts/puzzle/puzzle_catalog.gd`:
  - `_ensure_entries` calls `PuzzlePackFormat.load_catalog("res://levels")`, builds an id→index Dictionary, and exposes `load_errors()` (with `push_error` per error).
  - `get_definition` builds a fresh definition from the stored record, and `index_of` uses the map.
  - Delete every `_build_*` builder, `_from_shapes` and `_tail_along`.
  - Rewrite the class doc comment for packs. The public API is unchanged.

  (Implements: FR-001, FR-003, FR-004, FR-007, FR-010)
- [X] T007 [P] [US1] In `export_presets.cfg`, set `include_filter="levels/catalog.json, levels/packs/*.json"` and set `exclude_filter="tests/*, levels/recipes/*"`. (Implements: FR-006)
- [X] T008 [P] [US1] Make the isolated temp projects copy `levels/` and `scripts/puzzle/puzzle_pack_format.gd`, keeping the same `res://levels/` paths, in `tests/run_puzzle_regressions.py`, `tests/run_puzzle_structural_report.py` and `tests/run_regressions.py`. (Implements: FR-001)
- [X] T009 [US1] Capture the AFTER snapshot (same commands as T001, into `gates/snapshot-after-report.txt` and `gates/snapshot-after-pins.txt`) before the sample pack exists. Diff each against BEFORE (both must be empty) and record the commands, outputs and diffs as the `snapshot-neutral` block in `gates/verify.md` (verify:snapshot-neutral). (Implements: FR-005)
- [X] T010 [US1] Run `python tests/run_puzzle_regressions.py --godot "$G44"` and `python tests/run_regressions.py --godot "$G44"`; both must pass with 30 entries and the pack-format checks (SC-002).

## User Story 2 — Developer generates a reproducible level from a profile (P2)
**Checkpoint**: Phase complete — 2026-10-23

**Goal**: A deterministic, bounded, seeded generator measured only by the existing validator, solver and analyzer (FR-011–FR-016). **Independent Test**: `tests/puzzle_generator_check.gd` passes inside the puzzle regression gate.

- [X] T011 [US2] Add `tests/puzzle_generator_check.gd`, printing `PUZZLE_GENERATOR_FAILURES=<n>`, and register it in `tests/run_puzzle_regressions.py` (copying `scripts/puzzle/puzzle_generator.gd`). It covers:
  - the same profile and seed called 3 times give the same content version, and different seeds differ (FR-011)
  - a reachable small profile returns `ok`, valid, solvable and in range (FR-012, FR-013)
  - a profile with `initial_playable_cap` and no `initial_playable` range never returns `ok` with more playable arrows than the cap, and reports an `initial_playable_cap` miss when it cannot meet it (FR-012)
  - an unreachable structural profile returns `ok == false` with `misses` (FR-014, FR-015)
  - a profile whose arrows can rarely be placed (tiny board, long minimum length) still returns within its budget (FR-014)
  - rejection with `profile_errors` and `attempts_used == 0` for min greater than max, each out-of-range value, and no feasible board size (FR-016)
  - a ranged board size draws only feasible (width, height) pairs (FR-016)

  Keep the profiles small so the gate stays within its timeout. (Implements: FR-011, FR-012, FR-013, FR-014, FR-015, FR-016)
- [X] T012 [US2] Implement `PuzzleGenerator.generate(profile, seed)` in `scripts/puzzle/puzzle_generator.gd`, as in the plan Decision Summary and data-model.md:
  - profile rejection by the single feasibility rule, then feasible (width, height) pairs in a fixed order
  - one seeded `RandomNumberGenerator`
  - reverse-solve-order placement with `center_out` / `uniform` layering and the cap tail preference
  - bounded construction with `MAX_HEAD_TRIES` and dead-end tail stops
  - candidates measured only via `get_validation_errors()` and `PuzzleAnalyzer.analyze()`
  - the cap enforced as an acceptance constraint
  - normalized out-of-range scoring, stopping early at a score of 0 within the `attempts` budget
  - a result dictionary as in data-model.md, and `GENERATOR_SCHEME := "gen1"`

  (Implements: FR-011, FR-012, FR-013, FR-014, FR-015, FR-016)

## User Story 3 — Developer builds a level pack from a recipe (P3)
**Checkpoint**: Phase complete — 2026-10-23

**Goal**: One command builds a gated, reproducible, atomically written pack, and the sample pack appears as its own Level Select group (FR-017–FR-023). **Independent Test**: Three independent builds of the sample recipe agree, the negative builds leave the pack untouched, and the fourth section plays (SC-004, SC-005, SC-008).

- [X] T013 [P] [US3] Move `_print_entry` from `tests/puzzle_structural_report.gd` into a static helper in `tests/puzzle_report_format.gd`, and call it from the structural report so its output stays byte-identical. Add the helper to the copy list in `tests/run_puzzle_structural_report.py`. (Implements: FR-018)
- [X] T014 [US3] Add `tests/level_pack_build.gd`, following contracts/pack-build-cli.md:
  - parse the recipe and check the pack is listed in `levels/catalog.json`
  - load the other packs with `load_catalog("res://levels", skip_pack)`; the target pack is skipped, so a first build works, and any other load error fails
  - generate each level and require `ok`
  - run `audit_levels` over the other packs plus the new levels
  - print the shared report entry, a profile line and a `level: <id> <content_version>` line per level
  - write `generated` provenance with the inline profile
  - print `PACK_BUILD_FAILURES=<n>`, and print the serialized pack between `PACK_BEGIN`/`PACK_END` only when that count is 0

  (Implements: FR-017, FR-018, FR-019)
- [X] T015 [US3] Add `tests/run_level_pack_build.py` (`--godot`, `--recipe`, `--check`), following contracts/pack-build-cli.md:
  - build an isolated temp project as `run_puzzle_structural_report.py` does
  - fail on script or parse errors or on failures greater than 0, writing nothing
  - write mode: write `levels/packs/.<pack>.json.tmp`, flush and `fsync` it, then `os.replace` it onto `levels/packs/<pack>.json`, deleting the temp file on any error
  - `--check` mode: compare byte-for-byte with the committed file and never write

  (Implements: FR-017, FR-019, FR-020)
- [X] T016 [US3] Add `GROUP_GENERATED := "generated"` with the title "Generated Levels" to `GROUP_TITLES` in `scripts/puzzle/puzzle_catalog.gd`, appended last in `group_ids()`. (Implements: FR-022)
- [X] T017 [P] [US3] In `scenes/menus/main_menu/puzzle_select_menu.gd`, map the generated group to `&"LevelCardEmber"` in `GROUP_CARD_VARIATIONS`, and give it the description "Boards built by the level generator; an untuned first sample." in `GROUP_DESCRIPTIONS`. (Implements: FR-022, FR-023)
- [X] T018 [US3] Author `levels/recipes/generated_sample.json`:
  - four levels in group `generated`, rising from about 7×6 with 6 arrows to about 15×10 with 20 arrows, all `center_out` with a playable cap and practical attempt budgets
  - add `generated_sample` last in `levels/catalog.json`
  - run `python tests/run_level_pack_build.py --godot "$G44" --recipe levels/recipes/generated_sample.json` (the first build relies on the skipped missing pack), adjusting seeds or profiles until it writes `levels/packs/generated_sample.json`
  - curate the titles by hand

  (Implements: FR-021, FR-022)
- [X] T019 [US3] Update `tests/puzzle_catalog_check.gd`:
  - append four `CATALOG_PINS` entries for the sample levels
  - extend the group checks to the generated group: its title, its position after the existing three, group-relative numbering from 1, and no next level after its last level
  - assert that the existing three groups' order and numbering are unchanged

  Update `tests/puzzle_layout_check.gd` or `tests/portrait_menu_check.gd` only if they assume exactly three Level Select sections. (Implements: FR-008, FR-022, FR-023)
- [X] T020 [US3] Run the repeat and negative builds, and record every command and its output in `gates/verify.md`.
  - **SC-004:** run `run_level_pack_build.py ... --check` twice after T018's write. Together that is three independent processes, which must print identical `level:` lines, with both `--check` runs exiting 0 (SC-004, SC-005, FR-020).
  - **Negative builds:** record `git hash-object levels/packs/generated_sample.json`, then run temporary recipes under `probes/` targeting `generated_sample`: one with an unreachable profile, one with a duplicate id, and one whose level exceeds its playable cap. Each must exit non-zero and name the level. The pack hash must be unchanged and no `.generated_sample.json.tmp` may remain (FR-019).

  (Implements: FR-012, FR-019, FR-020)

## Final — Knowledge, verification, linkage

- [X] T021 Update `.knowledge/architecture/arrow-puzzle.md`. Cover:
  - the catalog loading level packs, the pack format and manifest, and `PuzzlePackFormat` (`load_catalog`, `audit_levels`)
  - `PuzzleGenerator`: one rules engine, generation never at runtime, the hard playable cap, feasibility-only rejection, bounded construction
  - the pack-build tool with its atomic write and first-build skip
  - the generated group, the pack gate, `load_errors()` and the malformed-input checks

  Replace references to builders, `_from_shapes` and `_tail_along`, and add the new files to `appliesTo`. (Implements: FR-001, FR-010, FR-011, FR-017, FR-022)
- [X] T022 [P] Update `.knowledge/reference/progression-design-learning.md`, `.knowledge/reference/gordian-knot-experiments.md` and `.knowledge/reference/reference-puzzle-design-report.md`. Boards and design notes now live in `levels/packs/*.json`. Where the progression doc says the search is not kept, state that a seeded generator and pack-build tool now exist in the repo, and that Reference-Knot-class density is not reached by it. Add `appliesTo` entries for the packs.
- [X] T023 [P] Update the Export bullet in `.knowledge/architecture/web-showcase.md` with the level-pack include and recipe exclude filters. (Implements: FR-006)
- [X] T024 [P] Document `puzzle_pack_format_check.gd`, `puzzle_generator_check.gd`, the pack gate, `run_level_pack_build.py` (including `--check` and the atomic write) and the shared report helper in `tests/README.md`. (Implements: FR-017)
- [X] T025 [P] Add a Recent Changes entry to `CLAUDE.md` (justified support: the agent guidance file) describing level packs, the generator and the pack-build tool. It must contain no spec, plan, task or feature identifiers.
- [X] T026 Run Godot validation with `"$G44" --headless --path . --editor --quit`, then both regression gates, all with 34 entries. Record the results (Principle V).
- [ ] T027 Run the desktop smoke test from quickstart.md §4 with a fresh scratch `APPDATA`: <!-- WIP: automated scene checks pass (four sections, focus, Next scope); native desktop run with mouse, keyboard and a physical gamepad not yet performed -->
  - four sections in the right order
  - one level per group played with mouse, keyboard and gamepad
  - Next Puzzle within the generated group, with no next after its last level
  - Level Select load time compared with before

  Record the results, and record any input method not tested as not tested (Principle III and V, SC-007, SC-008).
- [ ] T028 Run the Web end-to-end check from quickstart.md §5: <!-- WIP: export and site build pass; Chromium-based browser played all four groups; Firefox and a real phone not yet tested -->
  - `node web/scripts/export-game.mjs --godot "$G44WEB"`, then `cd web && npm ci && npm run check && npm run build`
  - play one level from each of the four groups in Firefox, in a Chromium-based browser, and on at least one real phone
  - confirm there are no load errors in the console

  Record it as the `end-to-end` block in `gates/verify.md`, with untested browsers or devices recorded as not tested (verify:end-to-end, SC-003). (Implements: FR-006)
- [X] T029 Run the no-back-link check. Search the durable changes (`scripts/`, `scenes/`, `tests/`, `levels/`, `.knowledge/`, `.github/`, `CLAUDE.md`, `export_presets.cfg`) for `018-spec`, `.devspark.work`, `spec.md`, `plan.md`, `tasks.md`, FR/SC ids and decision ids, and confirm none appear. Keep the complete feature directory under `.devspark.work/` after all checks pass.

## Gate Remediation
**Checkpoint**: Phase complete — 2026-10-23

- [X] T030 [P] Add `levels/**` and `export_presets.cfg` to both `on.push.paths` and `on.pull_request.paths` in `.github/workflows/godot-regression-tests.yml` (justified support for the pack gate, under developer decision D-001) (Implements: FR-008) (resolves: critic-001)

---

## Dependencies

- T001 must complete before T005/T006 touch the catalog. T002 blocks T003–T006, T014 and T015.
- T009 runs after T006–T008 and before T018, so both snapshots cover exactly the 30 migrated levels.
- US3's T014/T015/T018 need US1 (loader, launchers) and US2 (T012). T016 must land before T018 builds levels in the `generated` group. T020 runs after T018.
- T026–T028 run after all story tasks. T021–T025 can run in parallel with them once T019 is done.
