---
classification: full-spec
risk_level: medium
required_gates: checklist, analyze, critic
---
# Implementation Plan: Rich Arrow Model and Solvability Foundation

**Branch**: `002-spec-multi-arrow-solvability` | **Date**: 2026-09-26 | **Spec**: [spec.md](spec.md)
**Repository root**: `C:/GitHub/MakeBoldSolutions/ArrowGame`
**IMPL_PLAN**: `C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/002-spec-multi-arrow-solvability/plan.md`
All source paths below resolve against the absolute repository root.

## Rationale Summary

### Core Problem
The head-cell map cannot represent tails or certify authored boards as solvable.

### Decision Summary
Keep head coordinates as arrow identities; add ordered tails and cell ownership. Analyze a fresh rule state with deterministic legal removals: removing occupancy cannot make another arrow less removable.

### Key Drivers
Whole-shape selection and blocking, verified content, unchanged arrow-based accounting, and preserved menus/saves/settings.

### Source Inputs
The authoritative spec, constitution v2.0.0, current arrow-puzzle and save-progression knowledge, and inspected puzzle core, views, controller and test launcher.

### Tradeoffs Considered
Head-coordinate identities avoid new IDs. An ownership dictionary avoids shape scans per click. Monotone elimination replaces unnecessary backtracking. Copied dictionaries/arrays avoid new dependencies and shared mutable shape resources.

### Architectural Impact
Preserve the three-argument definition constructor and direction map, adding optional tails. Add occupancy accessors and one pure solver script. Update existing board/view/controller boundaries without addon, menu-routing or persistence changes.

### Reviewer Guidance
Check monotonicity proof, ownership validation, tail-click identity resolution before removal, one departure callback per arrow, and metric scope along one traversal.

## Summary
Implement shared shape/occupancy rules, then whole-shape visuals, representative content, solver, and additive metrics. Replay solver witnesses against fresh rule states; retain formula, scene and save/input regressions.

## Technical Context

**Language/Version**: GDScript on Godot 4.4; Python 3.11+ test launchers
**Primary Dependencies**: Godot built-ins and existing Maaack's Game Template
**Storage**: N/A
**Testing**: Isolated headless GDScript regressions, real-project scene checks, desktop smoke tests
**Target Platform**: Desktop
**Project Type**: Godot puzzle game
**Performance Goals**: Responsive input/feedback; analysis outside gameplay frame processing
**Constraints**: No new packages, generation, difficulty ranking, persistence schema or exhaustive enumeration
**Scale/Scope**: One handcrafted 5x4 eight-arrow puzzle; rules support positive dimensions and arbitrary finite tails

## Constitution Check

| Principle | Pre-design | Post-design obligation |
|---|---|---|
| I Maintainability | PASS | snake_case scripts/functions; focused typed coordinates |
| II Project customization | PASS | No addon changes planned |
| III Controls | PASS | Preserve mouse board, keyboard/gamepad menus and saved remaps; verify affected routes |
| IV Responsiveness | PASS | Small synchronous occupancy updates, non-blocking effects, offline solver |
| V Verification | PASS | Godot validation, automated regressions and actual desktop smoke tasks required |
| VI Saved data | PASS | Attempts in memory; isolated save/input checks; no migration needed |

Post-design: PASS; no waivers or unresolved violations. Runtime checks remain outstanding until implementation; this is design compliance only.

## Context Resolution

```yaml
context_resolved:
  - id: arrow-puzzle
    path: .knowledge/architecture/arrow-puzzle.md
    via: direct appliesTo match on scripts/puzzle and scenes/puzzle
    hop: 1
  - id: save-progression
    path: .knowledge/architecture/save-progression.md
    via: arrow-puzzle menu integration -> shared menu appliesTo -> save-progression
    hop: 2
  - id: arrowgame-constitution
    path: .knowledge/governance/constitution.md
    via: direct governance appliesTo match
    hop: 1
```

Traversal stops after two hops: index and current nodes yield no further relevant entities/decisions. Update arrow-puzzle per behavior increment and extend appliesTo to solver. Update save-progression with verified compatibility evidence. Remove existing temporary-document and requirement references in affected durable files as they are edited.

## Project Structure

```text
.devspark.work/specs/002-spec-multi-arrow-solvability/
  spec.md, plan.md, research.md, data-model.md, quickstart.md, tasks.md
  contracts/puzzle.md
  checklists/requirements.md
  gates/                         # subsequent gate results
scripts/puzzle/
  puzzle_definition.gd            # optional tails, validation, authored layout
  puzzle_state.gd                 # occupancy, ownership, atomic removal
  puzzle_solver.gd                # new pure analysis
scenes/puzzle/
  arrow_view.gd                   # whole-shape drawing/effects
  puzzle_board.gd                 # layout and head-keyed views
  arrow_puzzle.gd                 # resolve clicked owner before mutation
tests/                           # existing test directory (repository root)
  puzzle_regression.gd
  puzzle_layout_check.gd
  run_puzzle_regressions.py
  save_input_regression.gd
  run_regressions.py
.knowledge/architecture/
  arrow-puzzle.md
  save-progression.md
```

**Structure Decision**: Extend existing boundaries and suites without new runtime services or test frameworks.

## Delivery and Gates
US1 supplies shapes/presentation; US2 integrates blockers/content; US3 proves solvability; US4 supplies metrics. Shared occupancy must be correct before either player story. US1 is a preview; complete delivery requires all four stories. Checklist is complete; analyze and critic remain required and unrun.

Keep the completed planning bundle live for release under the shared preamble's explicit retention rule. The older tasks outline's deletion instruction conflicts with that rule and destroys required traceability; do not schedule deletion during implementation.

Agent context update completed successfully using the stock PowerShell script after placing the existing stock agent template at its expected project override location. AGENTS.md retains all manual instructions and adds only current stack, rule-boundary and verification guidance.
