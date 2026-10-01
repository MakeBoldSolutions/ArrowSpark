---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Implementation Plan: The ArrowSpark Reference Puzzle and Level Groups

**Branch**: `010-spec-reference-puzzle` | **Date**: 2026-09-30 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/.devspark.work/specs/010-spec-reference-puzzle/spec.md`

## Rationale Summary

### Core Problem

The catalog is a flat, equal-weight list of 21 puzzles built for different reasons, none designed against the mature ArrowSpark experience. There is no single level that shows what the game should feel like, and no way to tell foundations, research experiments and player-facing levels apart.

### Decision Summary

Add exactly one hand-authored, human-iterated Reference Puzzle to the existing catalog, plus metadata-only purpose groups (Foundations, Puzzle Lab, ArrowSpark Levels) that drive Level Select sections, within-group numbering/progression and the main-menu Play target. No rule, solver, analyzer, scoring, Open Move or viewport change.

### Key Drivers

- Constitution III/V: menu changes need keyboard/gamepad verification, Godot validation, a smoke test and recorded results.
- Spec 009 lesson: density must come from meaningful geometry, not object count.
- FR-010/FR-027/FR-029: no new mechanics, no scripted solution, no generator, groups are metadata only.
- The spec is only complete when a human wants to hand the level to someone else (FR-016); green checks alone do not finish it.

### Source Inputs

- Spec 010 and its 2026-09-29 clarifications (group-scoped Next, Play → Reference Puzzle, per-group numbering).
- Existing `PuzzleCatalog`, `PuzzleSession`, `PuzzleAnalyzer`, `PuzzleSolver`, Level Select (`puzzle_select_menu`), results panel, and `.knowledge/` nodes `arrow-puzzle`, `gameplay-contract`, `gordian-knot-experiments`.

### Tradeoffs Considered

- Option A: separate catalogs/engines per group. Not chosen: violates FR-027 and duplicates definitions.
- Option B: a group-ordered catalog array (physically reordering entries). Not chosen: existing tests and history index by array position; a `group` field on each entry gives the same result with zero id/definition churn.
- Option C: new `PuzzleGroups` script/resource. Not chosen: the regression launchers copy a fixed script list into isolated projects; extending `PuzzleCatalog` needs no launcher changes and avoids a new abstraction for three constants.
- Selected: a `group` key on each catalog entry plus small static query helpers on `PuzzleCatalog`, consumed by session, menus and results.

### Architectural Impact

- `PuzzleCatalog` gains group metadata + queries (`group_ids`, `group_title`, `group_of`, `ids_in_group`, `group_position`, `next_in_group`); one appended entry (index 21) preserves every existing index and id.
- `PuzzleSession` progression becomes group-scoped and gains an in-memory one-shot "open Level Select on menu" request (no persistence).
- Level Select renders grouped sections; results panel shows group-relative numbering and offers Level Select at a group's end; main-menu Play starts the Reference Puzzle.
- Fully backward compatible: existing ids/definitions unchanged; no save-data or settings change.

### Reviewer Guidance

Focus on (1) honesty of the playtest evidence behind the "want someone else to play it" claim, (2) group classification justified by purpose/role rather than number, (3) no gameplay-contract regression (results/next/replay/Open Move/scoring), and (4) the design report recording observations unedited.

## Summary

Deliver one Reference Puzzle via an author → validate → measure → play → revise loop (human playtest is primary evidence; analyzer/solver are diagnostics only), and organize the catalog into three purpose groups surfaced through Level Select, group-scoped Next Puzzle/Level Select at group end, group-relative display numbering, and Play → Reference Puzzle. Ship a durable design report under `.knowledge/`. Group work is small, deterministic and automatable; the puzzle work is iterative and human-gated.

## Technical Context

**Language/Version**: GDScript, Godot 4.4 (project target); Python 3.11+ launchers
**Primary Dependencies**: Maaack's Game Template addon (unchanged except as already modified); no new dependencies
**Storage**: N/A — session-lifetime static vars only; no `user://` change (FR-020)
**Testing**: `python tests/run_puzzle_regressions.py --godot <exe>` and `python tests/run_regressions.py --godot <exe>`; extended `tests/puzzle_catalog_check.gd`; `--headless --editor --quit` validation; desktop smoke test; non-gating structural report (`tests/run_puzzle_structural_report.py`)
**Target Platform**: Desktop (Windows primary), keyboard/mouse/gamepad
**Project Type**: Godot desktop game
**Performance Goals**: No new per-frame work; level must stay responsive at its board size (existing large-canvas viewport)
**Constraints**: No new mechanics; groups are metadata; ids and existing definitions unchanged; no generator/difficulty formula
**Scale/Scope**: 22 catalog entries (21 + 1), 3 groups; one board on the order of 40–60 columns × 30–40 rows (final size set by iteration, must stay within `PuzzleDefinition` limits and remain readable at supported zoom)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Assessment |
|---|---|
| I. Simple, Maintainable Code | PASS — helpers added to existing `PuzzleCatalog`; no new abstraction; snake_case names. |
| II. Project-Level Customization | PASS — all changes in project scripts/scenes; no addon edits planned (the unrelated pre-existing addon working-tree edit is out of scope). |
| III. Accessible, Configurable Controls | PASS with obligation — grouped Level Select and the new Results button must stay keyboard/gamepad navigable; verify in smoke test (task T-verify). |
| IV. Responsive Gameplay | PASS — no frame-loop work added. |
| V. Practical Gameplay Verification | PASS with obligation — Godot validation, both regression gates, extended catalog checks, desktop smoke test recorded; unrun checks disclosed. |
| VI. Preserve Saved Progress and Settings | PASS — no persistence; session flag is in-memory only. |

Post-design re-check (after Phase 1): unchanged — all PASS; no waivers required.

## Context Resolution

*Pinned multi-hop `.knowledge/` traversal for this delta. Context Projection returned no relation edges beyond the seeds (hop1/hop2 candidates: 0), so all entries are lexically discovered seeds.*

```yaml
context_resolved:
  - id: arrow-puzzle            # architecture: catalog, session, menus, results, next-puzzle flow — updated by this delta
    via: direct (seed; appliesTo puzzle_catalog.gd, puzzle_session.gd, puzzle_results.gd, main_menu_with_animations.gd)
    hop: 0
  - id: gameplay-contract       # product: results/scoring/Open Move contract that must stay unchanged; results panel text
    via: direct (seed; appliesTo puzzle_results.gd)
    hop: 0
  - id: gordian-knot-experiments  # reference: Spec 009 experiments being classified into Puzzle Lab
    via: direct (seed; appliesTo puzzle_catalog.gd, tests/puzzle_catalog_check.gd)
    hop: 0
```

## Project Structure

### Documentation (this feature)

```text
.devspark.work/specs/010-spec-reference-puzzle/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── level-groups.md
├── checklists/
├── gates/
└── tasks.md            # /devspark.tasks
```

### Source Code (repository root)

```text
scripts/puzzle/puzzle_catalog.gd      # + group metadata/queries, + reference puzzle entry & builder
scripts/puzzle_session.gd             # group-scoped advance/has_next; level-select request flag
scenes/menus/main_menu/puzzle_select_menu.gd  # grouped sections, per-group numbering
scenes/menus/main_menu/main_menu_with_animations.gd  # Play → reference puzzle; honor level-select request
scenes/puzzle/arrow_puzzle.gd         # group-relative label; group-scoped has_next; level-select handler
scenes/puzzle/puzzle_results.gd/.tscn # group-relative label; Level Select button at group end
tests/puzzle_catalog_check.gd         # 22 entries, group assignment, session/group navigation, reference puzzle
tests/save_input_regression.gd        # Play → reference puzzle; level-select request; no-reset guarantee
tests/puzzle_structural_report.gd     # (report only) include reference puzzle if it enumerates catalog
tests/run_*.py, tests/README.md       # doc/count updates only if counts are hard-coded
.knowledge/architecture/arrow-puzzle.md
.knowledge/reference/gordian-knot-experiments.md   # group classification note
.knowledge/reference/reference-puzzle-design-report.md  # NEW durable design report
.knowledge/index.json                 # regenerated
```

**Structure Decision**: Extend existing files; one new durable knowledge document (the design report, FR-015). No new scripts or scenes.

## Complexity Tracking

No constitution violations; no waivers.

## Implementation Notes

- 2026-09-30 Deviation: the dense final board made the exhaustive longest-dependency-chain search in the analyzer unable to finish. The chain is now computed in linear time when the dependency graph is acyclic (identical results; exhaustive search kept for cyclic graphs). The requirement on analyzer changes was amended to permit exactly this.
- 2026-09-30 Deviation: the catalog check samples every sixth branching state for the Reference Knot only, because the full check exceeds the launcher's per-script time limit.
- 2026-09-30 Scope added by the owner after the first playtest: a Back button on the play HUD and collapsible Level Select groups. Saved progress was declined for this spec.
- 2026-09-30 An F3 developer readout of on-screen cell size was added to gather the numeric readability evidence; it never displayed on the tester's desktop and the measurement was not captured. A tooltip variant was tried and reverted before commit.
- 2026-10-01 Fresh-player validation moved to the next spec by owner decision.
