---
classification: full-spec
risk_level: medium
required_gates: checklist, analyze, critic
---
# Implementation Plan: Gordian Knot Experiments

**Branch**: `009-spec-gordian-knot-experiments` | **Date**: 2026-09-28 | **Spec**: [spec.md](spec.md)

## Rationale Summary

### Core Problem
Structural measurements cannot establish whether a large geometric knot feels satisfying.

### Decision Summary
Append six literal, hand-authored puzzles to the existing catalog, reuse the solver and analyzer, and record actual human completions in a durable experiment report. Reuse all existing selection, navigation, assistance, departure and scoring behavior.

### Key Drivers
Keep experiments distinct, preserve all fifteen existing puzzles, and separate measured geometry from one-session subjective evidence.

### Source Inputs
The specification, current catalog/solver/analyzer and regression launchers, and the current knowledge nodes pinned below. Prior investigations are motivation, not new measured evidence.

### Tradeoffs Considered
A generator would undermine the investigation; a new authoring framework is unnecessary for six layouts. New metrics are optional in the specification: choose zero because existing lengths, bends, density, dependencies and unlock sequences describe the planned set. Omit the optional seventh control to keep human playtesting manageable.

### Architectural Impact
Catalog grows from 15 to 21 entries, with original entries retaining IDs, order, titles and literal geometry. No runtime schema, rule, persistence, input or addon changes are planned. The developer report exposes existing solver witness and analyzer fields more completely; it does not score puzzle quality.

### Reviewer Guidance
Check actual geometry against its stated purpose, full completion witnesses, preserved original content, navigation at dense regions, and honest human evidence. Existing count/final-entry assertions must be updated, not discarded. SC-005's unchanged-regression intent means preserving existing behavioral coverage; assertions of exactly fifteen entries necessarily change with FR-001.

## Summary
Six new experiments use the existing RefCounted rule boundary and dynamic catalog-driven UI. Authoring targets below guide design, not acceptance thresholds or difficulty rankings. Final dimensions and counts are recorded from actual definitions before playtesting.

| Stable ID | Purpose and hypothesis | Starting canvas / authoring direction |
|---|---|---|
| knot_long_geometry | Long removals can be satisfying without substantial interweaving | 32x24; a few long bent paths and simple blockers |
| knot_interwoven_paths | Following interleaved paths increases tracing demand | 32x24; disjoint adjacent winding tails and tail-based dependencies |
| knot_dense_core | Concentrated geometry creates a readable challenge | 36x28; dense central knot with clear escape opportunities |
| knot_regions | Spatial grouping makes a large board approachable | 48x32; separated local groups linked by a few dependencies |
| knot_single_release | One long departure visibly simplifies the board | 40x30; prominent long path, with a small set of prerequisites |
| knot_boundary | Excessive winding becomes tedious or unreadable | 48x36; deliberately busy disjoint paths, still valid and assistable |

All paths must obey current adjacency, direction and non-overlap validation. Interweaving means visual routing around each other, never occupied-cell crossings. No numeric complexity threshold determines whether an experiment is good. Do not shrink authored dimensions merely to fit a screen. Negative reactions are evidence; repair invalidity and selection/navigation defects without erasing the boundary experiment's purpose.

## Technical Context

**Language/Version**: Godot 4.4 GDScript; Python 3.11+ launchers.
**Primary Dependencies**: Existing Maaack's Game Template and RefCounted PuzzleDefinition, PuzzleState, PuzzleSolver, PuzzleAnalyzer, PuzzleCatalog.
**Storage**: Existing settings/progress unchanged; manual Markdown report outside runtime saves.
**Testing**: Existing isolated Python/Godot suites, catalog and canvas checks, headless Godot import, desktop smoke and required human play sessions.
**Target Platform**: Desktop.
**Project Type**: Godot puzzle game with developer analysis tooling.
**Performance Goals**: Responsive input and departure/navigation feedback; measure dense-scene issues when observed, no invented frame budget. Analyzer runs offline only; its longest-simple-path search can be expensive, so run and time the existing full-catalog report after each authored pair, requiring completion within the launcher's existing 45-second subprocess timeouts before further authoring. On timeout, isolate the expensive entry and diagnose it while preserving geometry and metric semantics; do not merely raise timeouts. These early checks use existing output, before the later report-format extension, and never run in gameplay.
**Constraints**: No generator, composite rating, telemetry, profiles, persistent session scores, new rules or new input system.
**Scale/Scope**: Six additive puzzles, twenty-one total, one report, zero new structural metrics.

## Constitution Check

| Principle | Before research | After design / required implementation evidence |
|---|---|---|
| I: maintainable code | Pass | Literal catalog builders; snake_case; reuse analysis/rules |
| II: project customization | Pass | No addon modifications |
| III: accessible controls | Pass | Verify scrolling Level Select, keyboard/gamepad focus and remapping, mouse selection, zoom/pan/fit and assistance; do not imply gamepad arrow selection exists |
| IV: responsive gameplay | Pass | Offline analysis only; desktop dense-board/navigation/departure checks |
| V: gameplay verification | Pass | Both regression launchers, Godot validation and desktop smoke explicitly tasked; unrun checks stay outstanding |
| VI: saved progress/settings | Pass | Original content frozen; no migration; verify saved bytes/remaps and session-only results |

Post-design gate: no unresolved violations or waivers. Planning does not claim runtime verification passed.

## Context Resolution

Lexical seeds were selected by catalog/analyzer/canvas/save paths and their appliesTo owners. Ran PowerShell context-projection with the four IDs below, --max-hops 2 --json. All resolved; projection returned only these hop-0 seeds, zero related candidates, and no truncation. Traversal stopped because no accepted relationship edges expanded. Constitution was loaded separately as governing authority.

```yaml
context_resolved:
  - id: arrow-puzzle
    via: lexical appliesTo scripts/puzzle/puzzle_catalog.gd and scripts/puzzle/puzzle_analyzer.gd
    path: .knowledge/architecture/arrow-puzzle.md
    hop: 0
  - id: gameplay-contract
    via: lexical rule assistance scoring and session boundary
    path: .knowledge/product/gameplay-contract.md
    hop: 0
  - id: game-visual-system
    via: lexical appliesTo scenes/puzzle/** and tests/puzzle_canvas_check.gd
    path: .knowledge/architecture/game-visual-system.md
    hop: 0
  - id: save-progression
    via: lexical appliesTo Level Select and tests/save_input_regression.gd
    path: .knowledge/architecture/save-progression.md
    hop: 0
```

Update arrow-puzzle and save-progression catalog descriptions. Update game-visual-system only if a demonstrated presentation defect requires a behavior change; gameplay-contract remains the invariant. Create the report as `.knowledge/reference/gordian-knot-experiments.md`, type `authoritative-reference`, with appliesTo catalog/report tooling and durable code/test sources. It describes the current authored set and bounded observations, not a decision log. Never cite temporary planning from durable files.

## Project Structure

```text
scripts/puzzle/puzzle_catalog.gd               # six appended literal builders
scripts/puzzle/puzzle_analyzer.gd              # reuse unchanged
scripts/puzzle/puzzle_solver.gd                # reuse unchanged
scenes/puzzle/                                # existing runtime, verify
scenes/menus/main_menu/puzzle_select_menu.gd    # existing dynamic list, verify
 tests/puzzle_catalog_check.gd                 # new content and original invariants
 tests/puzzle_canvas_check.gd                  # dense content navigation coverage
 tests/puzzle_structural_report.gd             # expose existing facts and witness
 tests/run_puzzle_structural_report.py         # existing isolated launcher
.knowledge/reference/gordian-knot-experiments.md
.knowledge/architecture/arrow-puzzle.md
.knowledge/architecture/save-progression.md
```

Temporary artifacts alongside this plan: research.md, data-model.md, contracts/experiment-contract.md, quickstart.md and tasks.md. No new runtime module or new dependency is needed.

## Delivery and Gates

Research and design are complete in the companion artifacts. Checklist is complete; analyze and critic are required next, not yet passed. US1 provides the playable MVP; US2 validates navigation; US3 requires actual human input; US4 cannot conclude until every human record is complete. All six experiments must finish all four stories for feature completion.

The shared preamble's explicit lifecycle rule takes precedence over the tasks command's stale deletion bullet: implementation preserves this bundle with populated linkage; only /devspark.release archives it. No deletion task is appropriate.

## Implementation Notes

- 2026-09-29 (T014-T019, T022): the owner supplied session-level playtest conclusions instead of six per-puzzle worksheets and directed that they be accepted. The durable report records one aggregate session, labels per-puzzle detail as not recorded (unknown, not zero), and uses supported/inconclusive verdicts only where that evidence justifies them. This deviates from the plan's one-session-per-final-layout intent and is acknowledged in tasks.md.
- 2026-09-29 (T024): final validation was also run on Godot 4.4.1 from a fresh mirror of the working tree (editor import first, then both regression launchers and the structural report). No baseline comparison is claimed.
