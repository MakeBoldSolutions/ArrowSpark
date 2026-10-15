---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
devspark_version: "undetermined"
spec_semantic_hash: "sem1:9d306b2a880308eab7b0f7b649b173b92ea5eb1d8a770dd5810c8e08681e2bb4"
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Implementation Plan: Codebase Organization and Consolidation

**Branch**: `014-spec-codebase-consolidation` | **Date**: 2026-10-15 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/.devspark.work/specs/014-spec-codebase-consolidation/spec.md`

## Rationale Summary

### Core Problem

Three behavior-defining rules are each defined more than once. Six boards are unpinned. Unused
template content sits beside the live code. Each makes the next change riskier than it should be.

### Decision Summary

- **Baseline, then pin, then change.** No production file changes until two things exist: a
  recorded behavior baseline for all 30 entries (C0), and a test-side exact-geometry pin for all
  30 (C1). Every later change is proven against both.
- **One small change per commit.** C2 (head ordering), C3 (direction step), C4 (catalog shapes)
  and C5 (template removal) are separate commits. Each passes the gates on its own, so any one can
  be reverted without touching the others.
- **Reuse the owner that already exists.** The head-ordering rule moves to `PuzzleDefinition`,
  which already owns head coordinates and the direction step, and which every current caller
  already depends on. That needs no new file and no runner change, because every isolated test
  project already copies `puzzle_definition.gd`. The direction step reuses
  `PuzzleDefinition.direction_vector`. The catalog reuses its existing `_from_shapes`.
- **Pins are added, not swapped.** The existing per-subset fingerprints stay as they are. One new
  table pins every entry's id, title, group, position and content version. Folding the old checks
  into it would be a test rewrite with no maintenance gain for this spec.
- **The probe is throwaway.** The FR-014 probe is a temporary script in this bundle's `gates/`
  folder, run by absolute path ([research.md](research.md) R-03). Nothing durable is added.
- **Removal is exactly the FR-011 set** that R-01 proved unreachable. The other unreferenced
  template copies are labelled in the map and left alone.
- **Engine pinned to 4.4.1** (R-02). The `godot` on PATH is 4.7.2 and is never run against the
  repo.

### Key Drivers

- `sort_custom` is not a stable sort. Equivalence holds because heads are unique `Vector2i` keys,
  so the row-then-column comparator is a strict total order and the new single definition must be
  the identical expression. The probe diff is the empirical check.
- Content version text depends on head order. A wrong comparator would change all 30 content
  versions at once, so C1's pins catch it immediately.

### Reviewer Guidance

Check that C1 lands, and its mutation demonstration is recorded, before C2. Check that
`gates/baseline-before.txt` was produced from the commit before C2. Check that every removed path
appears in R-01's removal list.

## Technical Context

**Language/Version**: GDScript, Godot 4.4 (executed with 4.4.1 stable console; see R-02)
**Primary Dependencies**: Maaack's Game Template addon (unchanged)
**Storage**: `user://global_state.tres` and settings (unchanged; saved-data classes kept)
**Testing**: `tests/run_puzzle_regressions.py`, `tests/run_regressions.py`, Godot `--headless --editor --quit`; manual desktop, browser and phone smoke
**Target Platform**: Windows desktop and Godot Web export (unchanged)
**Project Type**: desktop/web game
**Performance Goals**: no change (none of the changed code is in a frame loop except the arrow view's direction lookup, which keeps the same cost)
**Constraints**: zero observable behavior change; no engine upgrade; no new dependencies, gates or durable tooling
**Scale/Scope**: about 15 production files edited or removed, 2 test files edited, 2 knowledge docs updated

## Operating Context and Expected Mechanisms

```yaml
operating_context:
  expected_scale: "small, bounded refactor"
  expected_frequency: "one-time"
  execution: operator-driven
  human_review_acceptable: true
expected_new_mechanisms:
  states: 0
  runtime_settings: 0
  endpoints: 0
  persistent_stores: 0
  caches: 0
  background_workers: 0
```

**Deviations**: None. One new static function (`PuzzleDefinition.head_less_than`) replaces four
existing copies. It is not a new mechanism.

## Expected Change Surface

```yaml
expected_change_surface:
  - {path: "tests/puzzle_catalog_check.gd", change: modify, why: "C1: all-entry pin table (id, title, group, position, content version) and its check (FR-004)"}
  - {path: "scripts/puzzle/puzzle_definition.gd", change: modify, why: "C2: single head_less_than definition (FR-005)"}
  - {path: "scripts/puzzle/puzzle_state.gd", change: modify, why: "C2: find_open_move uses the shared ordering"}
  - {path: "scripts/puzzle/puzzle_solver.gd", change: modify, why: "C2: analyze uses the shared ordering"}
  - {path: "scripts/puzzle/puzzle_content_version.gd", change: modify, why: "C2: canonical_text uses the shared ordering"}
  - {path: "scripts/puzzle/puzzle_analyzer.gd", change: modify, why: "C2: drop _head_less_than; four call sites use the shared ordering"}
  - {path: "tests/puzzle_analyzer_check.gd", change: modify, why: "C2: the one test reference to PuzzleAnalyzer._head_less_than follows the moved definition"}
  - {path: "scenes/puzzle/arrow_view.gd", change: modify, why: "C3: direction step derived from PuzzleDefinition.direction_vector (FR-006)"}
  - {path: "scripts/puzzle/puzzle_catalog.gd", change: modify, why: "C4: 8 builders return _from_shapes(...) instead of repeating its loop (FR-007); C6: builder-style comment corrected (FR-002)"}
  - {path: "scenes/game_scene/", change: remove, why: "C5: unreachable template example (R-01, FR-011)"}
  - {path: "scenes/end_credits/", change: remove, why: "C5: unreachable template example"}
  - {path: "scenes/menus/level_select_menu/", change: remove, why: "C5: unreachable template example"}
  - {path: "scenes/overlaid_menus/game_won_menu.*, level_lost_menu.*, level_won_menu.*", change: remove, why: "C5: unreachable template example overlays"}
  - {path: "scenes/loading_screen/", change: remove, why: "C5: level and shader-caching loading screens and their only parent copy; SceneLoader uses the addon's"}
  - {path: "scripts/level_list_state_manager.gd", change: remove, why: "C5: referenced only by the removed example game scene"}
  - {path: "tests/run_puzzle_regressions.py", change: modify, why: "C6: docstring states 22 catalog entries; there are 30 (FR-002)"}
  - {path: ".knowledge/architecture/arrow-puzzle.md", change: modify, why: "C7: Code Responsibilities section (FR-001)"}
  - {path: ".knowledge/architecture/save-progression.md", change: modify, why: "C5/C7: appliesTo and prose no longer name the removed level-list manager; records why GameState/LevelState stay"}
  - {path: ".knowledge/index.json", change: modify, why: "C7: regenerated after knowledge edits"}
  - {path: ".devspark.work/specs/014-spec-codebase-consolidation/gates/", change: add, why: "C0/C8: temporary probe and before/after output (FR-014); ephemeral"}
  - {path: ".devspark.work/specs/014-spec-codebase-consolidation/consolidation-record.md", change: add, why: "C0/C8: before/after measures, deferred work, left alone (FR-012, FR-013, SC-006)"}
```

Not touched: `scenes/puzzle/puzzle_board.gd`, `scenes/puzzle/arrow_puzzle.gd`, all input paths,
`scripts/game_state.gd`, `scripts/level_state.gd`, `project.godot`, `export_presets.cfg`, the
addon, `web/`.

## Change Sequence

Each step is one commit. "Full gates" means both headless runners plus editor validation, all
with the 4.4.1 executable (see [quickstart.md](quickstart.md)). Verification scales with each
step's risk:

| Checkpoint | Verification |
|---|---|
| C0 (baseline), C5 (template removal), C8 (final) | Full gates, plus the probe (C0, C8) and the reachability walk (C5) |
| C1 (pins), C3 (direction) | Puzzle gate only. These changes are test-only or presentation-only, and the puzzle gate exercises them, including the real-project canvas, presentation and departure checks |
| C2 (ordering), C4 (catalog) | Puzzle gate plus probe diff |
| C6, C7 (comments, knowledge) | Puzzle gate once, after the runner docstring change; knowledge index regenerates cleanly |

A step's evidence is recorded once at its checkpoint, in `consolidation-record.md`. Separate
records for each task are not required.

| Step | Change | Dependency boundary | Evidence required before the next step |
|---|---|---|---|
| **C0** Baseline | Write `gates/behavior_probe.gd`. Run it on the unmodified tree, save `gates/baseline-before.txt`, record the before measures in `consolidation-record.md`. No repo file changes. | Probe reads only public rule/content APIs (catalog, definition, state, solver, analyzer, content version) | Probe output exists, has 30 entry blocks, and comes from commit `58a8bec`'s production code; gates green on the unmodified tree |
| **C1** Pin all 30 | Add a `CATALOG_PINS` table in catalog order (id, title, group, content version) and a check: count equals catalog count; for each index, id, title, group and `PuzzleContentVersion.of` match; an unpinned id fails with "entry `<id>` has no recorded pin". Values are copied from `baseline-before.txt`. | Test-only | Puzzle gate green. **Mutation demo**: change one tail vertex of `knot_regions` temporarily, so the puzzle gate fails naming `knot_regions`; undo that one edit, prove the file matches the committed version (quickstart), and the gate passes. Both outputs recorded (SC-001) |
| **C2** Head ordering | Add `static func head_less_than(a: Vector2i, b: Vector2i) -> bool` to `PuzzleDefinition` with the identical expression `a.y < b.y or (a.y == b.y and a.x < b.x)`. Replace the lambdas in state, solver and content version with `sort_custom(PuzzleDefinition.head_less_than)`. Remove `PuzzleAnalyzer._head_less_than`; its four uses, including `_chain_less_than`, call the shared one. Update the analyzer test reference. Update the two comments that say "the same comparator PuzzleSolver uses". | Rules layer only; no scene, input or presentation file touched | Puzzle gate green, including the C1 pins; probe re-run diff against before is empty |
| **C3** Direction step | `ArrowView._direction_vector()` returns `Vector2(PuzzleDefinition.direction_vector(direction))`; its `match` is removed. | Presentation reads the rules model (the allowed direction); the rules model gains nothing | Puzzle gate green (canvas, presentation and departure checks run against the real project); desktop smoke of departures in all four directions is deferred to C8 |
| **C4** Catalog shapes | The 8 builders with the inline loop (`canvas_validation`, `knot_long_geometry`, `knot_interwoven_paths`, `knot_dense_core`, `knot_regions`, `knot_single_release`, `knot_boundary`, `reference_knot`) end with `return _from_shapes(<w>, <h>, shapes)`. Literals, their order and comments are untouched. | Content only | Puzzle gate green, including the C1 pins (all 30); probe diff empty; `git diff --stat` on the catalog shows deletions only, apart from the 8 return lines |
| **C5** Template removal | Delete the R-01 removal list and its `.uid` sidecars. Update `save-progression.md`. | Template integration layer; saved-data classes untouched | Reachability walk re-run: shipped set unchanged, no reference to a removed path anywhere outside `addons/` originals and the archive. Editor validation shows no missing-dependency errors. `run_regressions.py` green (save preservation). `git status` shows only intended deletions |
| **C6** Stale docs | Fix the runner docstring (30 entries, current group description) and the catalog's builder-style comment. Fix only further contradictions found while writing the map, each named in the commit. | Comments and docstrings only | Puzzle gate green after the docstring change |
| **C7** Knowledge | Add `## Code Responsibilities` near the top of `arrow-puzzle.md`. It is a table of every production script by responsibility (rules and model, content, session state, presentation, input, scene flow, template integration, template copies unreferenced, saved-data compatibility). It states the rules-boundary rule, why GameState/LevelState stay, and that the removed examples can be restored from `addons/maaacks_game_template/examples/`. Regenerate `.knowledge/index.json`. | Knowledge only; no reference to this spec | Index regenerates cleanly; a reviewer can answer the six US3 questions (SC-005) |
| **C8** After | Re-run the probe, save `gates/baseline-after.txt` and diff it. Record the after measures, the deferred-work list and the left-alone list in `consolidation-record.md`. Run manual smoke tests. | n/a | Empty diff; record complete; smoke results recorded, with untested items listed |

C3 and C4 do not depend on C2 and can be reordered. C1 must precede C2 and C4. C0 must precede
everything.

## Verification

### Automated (pre-merge, repeatable)

| Check | Command (see quickstart) | Proves |
|---|---|---|
| Puzzle gate | `run_puzzle_regressions.py` | rules, solver, analyzer, catalog, including the C1 all-entry pins, scoreboard, geometry, viewport, layout, canvas, presentation |
| Save/input gate | `run_regressions.py` | saved progress and remaps preserved; menu wiring |
| Editor validation | `<godot> --headless --editor --quit` | every remaining scene and script parses; no missing dependencies after C5 |
| Behavior probe diff | `behavior_probe.gd` before vs after | FR-014: per entry, content version, validity, solvability, witness order, solver metrics, Open Move at every witness state, full analyzer report |
| Reachability walk | throwaway script (R-01) | FR-011: the removal set is unreachable before; the shipped set is unchanged after |

Empirical verification: REQUIRED (snapshot-neutral)
Reason: behavior-preservation-claim. The probe's before/after diff and the C1 pins give the
snapshot evidence.

### Manual (pre-merge, recorded in the verify gate; not automatable here)

| Check | Scope | Principle |
|---|---|---|
| Desktop smoke | Foundations (Simple Introduction), Puzzle Lab large canvas (Large Canvas Validation), Reference Knot: select, blocked feedback, departure in all four directions, Open Move, wheel zoom, keys and gamepad pan, middle-drag, Pan mode, Fit, results, Next Puzzle, Replay, Level Select, Back, pause and restart, options remap then help text | V, III |
| Browser smoke | Web export built with 4.4.1; Firefox and Chrome; one puzzle start to results, plus Level Select. Other Chromium browsers recorded as not tested | V |
| Phone smoke (conditional) | Mobile beta on one real Android phone: tap, drag pan, pinch, results. Run when a device is available. Otherwise record "mobile beta not re-verified on this build", and the beta claim is not extended to it. iPhone recorded as not tested | V |

**Completion is recorded in two parts** (in `consolidation-record.md`):

- **Technical completion**: all tasks are implemented, final full gates pass, the probe diff is
  empty, and the no-planning-reference check is clean. It can be established and reported on its
  own.
- **Manual acceptance**: the desktop and browser smoke tests are required (the Principle V MUST).
  The phone smoke is conditional, as above, because this change touches no input or touch code
  (spec edge cases).

The spec is marked Complete only when both parts pass. If desktop or browser smoke is outstanding,
the status stays In Progress and the outstanding checks are listed (Principle V). An unrun phone
smoke is disclosed but does not block completion.

## Requirement Mapping

| Requirement | Design element |
|---|---|
| FR-001 | C7 Code Responsibilities section |
| FR-002 | C6 |
| FR-003 | No moves planned; removals are not moves |
| FR-004 | C1 |
| FR-005 | C2 |
| FR-006 | C3 |
| FR-007 | C4 |
| FR-008 | No result or snapshot dictionary is touched; probe diff covers solver and analyzer output; gates cover snapshot, results and payload shapes |
| FR-009, FR-011 | C5 with R-01 evidence |
| FR-010 | C5 excludes `game_state.gd` and `level_state.gd`; `run_regressions.py` |
| FR-012, FR-013 | C8 `consolidation-record.md` (content outlined below) |
| FR-014 | C0 and C8 probe |
| FR-015 | Verification tables |
| FR-016 | Expected mechanisms all 0; no new dependencies or gates; probe is ephemeral |
| SC-001 to SC-007 | C1 demo; C2/C3/C4 counts (4→1, 2→1, 9→1); C8 diff; gates and smoke; C7 review; C8 record; C8 record |

### `consolidation-record.md` outline

1. **Before / after measures**: production files and lines; largest five files; duplication
   counts (ordering, direction, shape loop); pin coverage (24→30 of 30); unreachable template
   files (count before, count after); the catalog's line count. Before is from C0, after from C8.
2. **Deferred**, each with evidence, reason, trigger and seam:
   - puzzle data files or resources;
   - generator;
   - board input separation;
   - unify the three catalog authoring styles;
   - remove the remaining unreferenced template copies (R-01 retain list);
   - fold the three legacy pin mechanisms into the C1 table.
3. **Left alone**, each with its reason: the FR-013 list, plus `create_fixed()` (a test fixture
   on the model, used at 11 test call sites; moving it is churn).

## Constitution Check

*Pre-design and post-design results are the same; no waivers.*

- **I. Simple, maintainable code** (SHOULD: Godot conventions, small changes, justify
  abstractions; MUST: snake_case for new names): the one new function is `head_less_than`
  (snake_case). It replaces four copies, so it is justified by duplication, not by extensibility.
  No new files in `scripts/` or `scenes/`. **Pass.**
- **II. Template customization** (prefer project-level; addon edits allowed when justified): the
  addon is untouched. Removed content consists of project copies of addon examples, and the
  originals stay in the addon as the restore path. **Pass.**
- **III. Accessible controls** (MUST preserve keyboard and gamepad navigation and remapping, and
  verify affected controls): no input code changes. The desktop smoke still exercises keys,
  gamepad and remap help text, because the puzzle scene is rebuilt. **Pass.**
- **IV. Responsive gameplay**: no frame-loop work added. **Pass.**
- **V. Practical verification** (MUST: Godot validation and smoke test of affected gameplay; web
  builds verified in each supported desktop browser; record untested): covered by the
  Verification tables, with outstanding checks disclosed. The mobile-beta real-phone statement
  carries no MUST and says untested devices are not claimed. With no input or touch change, the
  phone check is conditional: if it is not run, the build is recorded as not re-verified on mobile
  and the beta claim is not extended. **Pass.**
- **VI. Saved progress** (MUST preserve): saved-data classes kept, save gate run after C5, no
  format change. **Pass.**
- **Technology**: Godot 4.4 is kept, with 4.4.1 as the execution binary. No new tooling (the probe
  is ephemeral, not knowledge-index tooling). **Pass.**

## Context Resolution

```yaml
context_resolved:
  - id: arrow-puzzle
    kind: knowledge
    via: direct
    hop: 0
    reason: Hosts the new Code Responsibilities section; documents the rules boundary, catalog, Open Move and analyzer ordering this delta consolidates
  - id: save-progression
    kind: knowledge
    via: direct
    hop: 0
    reason: Names level_list_state_manager.gd (removed in C5) and owns the GameState/LevelState preservation guarantee that bounds the removal
  - id: progression-design-learning
    kind: knowledge
    via: direct
    hop: 0
    reason: Evidence for deferring catalog data extraction and the generator (authoring friction was offline search, not format)
  - id: arrowgame-constitution
    kind: knowledge
    via: direct
    hop: 0
    reason: Principles I, II, V and VI bound abstraction, template handling, verification and saved data
```

Candidates dropped: `reference-puzzle-design-report`, `gordian-knot-experiments`,
`game-visual-system`, `guides-repo-story-repo-story-2026-09-30`. They are lexically adjacent, but
no content or presentation decision they record is changed here.

## Project Structure

Removed directories: `scenes/game_scene/`, `scenes/end_credits/`,
`scenes/menus/level_select_menu/`, `scenes/loading_screen/`. Removed files:
`scenes/overlaid_menus/{game_won_menu,level_lost_menu,level_won_menu}.{gd,tscn}` (with `.uid`) and
`scripts/level_list_state_manager.gd` (with `.uid`). Nothing is added or moved in the repository
layout. Planning bundle additions: `research.md`, `quickstart.md`, `consolidation-record.md` (at
C0), `gates/behavior_probe.gd`, `gates/baseline-*.txt`.

## Complexity Tracking

None. No constitution violations, and no repeated integration across call sites beyond replacing
existing duplicates with one shared definition.

## Implementation Notes

- 2026-10-15 (T005–T007): `tests/run_puzzle_regressions.py` hides a failing check's output
  (`subprocess.run(check=True)` raises before printing). The SC-001 entry name was therefore taken
  from a direct run of `tests/puzzle_catalog_check.gd`. The runner is left unchanged, as an adjacent
  improvement, and listed under Deferred in `consolidation-record.md`.
- 2026-10-15 (bookkeeping): the DevSpark semantic hash treats `**Checkpoint**: Phase complete` lines
  in `tasks.md` as semantic, so each one would make the Analyze gate `stale-recheck-required`. Phase
  checkpoint lines are therefore added in one pass at the end, followed by a single focused Analyze
  recheck, instead of a recheck after every phase. DevSpark itself is not changed.
