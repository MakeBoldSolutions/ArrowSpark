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

# Implementation Plan: Puzzle Structure, Challenge, and Character

**Branch**: `006-spec-puzzle-structure-analysis` | **Date**: 2026-09-27 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `.devspark.work/specs/006-spec-puzzle-structure-analysis/spec.md`

## Rationale Summary

### Core Problem

The spec establishes *what* evidence ArrowSpark needs (objective structural metrics, six deliberately combinatorial experimental puzzles, a comparison report, and human calibration) but leaves *how* to build it inside the existing GDScript/Godot architecture — exact module boundaries, the dependency-graph's internal representation, and where the report/worksheet artifacts live — as explicit planning-level decisions (spec's "Assumptions and Defaults").

### Decision Summary

Add one new sibling domain class, `PuzzleAnalyzer` (scripts/puzzle/puzzle_analyzer.gd), alongside `PuzzleSolver` rather than inside it, reusing `PuzzleSolver.analyze()`'s witness/metrics and a disposable internal `PuzzleState` for rule evaluation (never a second rules engine). Extend `PuzzleCatalog` with six new builder entries (8 → 14). Extend the existing bare-isolated-project regression harness (`tests/run_puzzle_regressions.py`) with a new `puzzle_analyzer_check.gd` synthetic-puzzle test suite and an expanded `puzzle_catalog_check.gd`. Add one new non-gating developer script, `tests/puzzle_structural_report.gd` (run via a new `tests/run_puzzle_structural_report.py` launcher), for the FR-021 comparison report. Keep the human-calibration worksheet, filled records, and the FR-026 findings summary as plain markdown files inside this spec's own temporary bundle (`.devspark.work/specs/006-.../calibration/`), consistent with "no persistence infrastructure" and with `.knowledge/` holding only validated, durable truth.

### Key Drivers

- `PuzzleSolver`'s existing header comment already states its monotonicity proof directly; the analyzer must cite and reuse that proof, not re-derive or risk contradicting it.
- The spec explicitly warns against turning `PuzzleSolver` into "a miscellaneous statistics container" — a sibling class keeps solver-correctness code and speculative-metric code in separately reviewable files.
- The existing `tests/puzzle_catalog_check.gd`/`run_puzzle_regressions.py` pattern already proves that `PuzzleCatalog`-dependent code needs no scene/font/addon dependency and can share the same bare isolated temp project as the pure rule tests — the analyzer and its tests fit the same isolation for free.
- FR-021's report "MUST NOT be a new in-game analytics screen" and FR-009/FR-023 forbid any composite score — a headless `SceneTree` script that only prints deterministic per-puzzle facts (no scoring, no ranking beyond factual max/min) satisfies both without inventing a new artifact class.

### Source Inputs

- [spec.md](spec.md) — this spec, particularly the Assumptions and Defaults subsection explicitly deferring analyzer shape, dependency-graph representation, report format, and worksheet medium to this plan.
- `.knowledge/architecture/arrow-puzzle.md` — current authoritative description of `PuzzleDefinition`, `PuzzleState`, `PuzzleSolver`, `PuzzleCatalog`, `PuzzleSession`, and the existing test/isolation patterns this plan extends rather than replaces.
- `scripts/puzzle/puzzle_solver.gd`, `puzzle_state.gd`, `puzzle_definition.gd`, `puzzle_catalog.gd` — read directly during planning to confirm exact existing method signatures (`analyze()`'s return dict, `is_blocked`/`select_arrow`/`get_snapshot`, `forward_ray_cells`, `PuzzleCatalog`'s `{id, title, build}` entry shape) that the analyzer must build on without modification.
- `tests/puzzle_catalog_check.gd`, `tests/run_puzzle_regressions.py` — read directly to confirm the existing bare-isolated-project test pattern (`check()`/`_initialize()`/`quit(1 if failures else 0)`, `PUZZLE_CATALOG_FAILURES=0` marker convention) this plan's new test files follow.
- `.devspark.work/specs/005-spec-multiple-puzzles/quickstart.md` — reused as the format precedent for this spec's quickstart.md.
- Project constitution — Principle I (simple/maintainable, snake_case, justified abstractions), Principle IV (no frame-loop impact — the analyzer is a dev/test-time-only capability), Principle V (Godot validation + smoke test for the six new puzzles' playability), Principle VI (no persistence touched, so no migration plan needed).

### Tradeoffs Considered

- Extending `PuzzleSolver.analyze()`'s existing return dictionary in place with all new metrics: rejected — the spec's FR-010 explicitly forbids altering the solver's existing contract/semantics, and mixing solver-correctness code with the larger structural/dependency-graph surface area risks exactly the "miscellaneous statistics container" the spec warns against.
- A brand-new isolated Godot temp project for the analyzer's tests: rejected — `PuzzleAnalyzer` depends only on `PuzzleDefinition`/`PuzzleState`/`PuzzleSolver`, identical to `PuzzleCatalog`'s existing dependency footprint, so it fits directly into the same bare project `puzzle_regression.gd`/`puzzle_catalog_check.gd` already share; a second temp project would duplicate harness setup for no isolation benefit.
- A dedicated `PuzzleDependencyGraph` class/Resource with its own file: rejected for this scope — the graph is a pure derived view (adjacency computed on demand from `PuzzleState.is_blocked`), small enough to live as private helper functions inside `PuzzleAnalyzer` returning plain `Dictionary`/`Array` structures (matching `PuzzleSolver.analyze()`'s own dictionary-contract precedent) rather than introducing a new public class and its own validation surface.
- Making the developer report part of the mandatory `run_puzzle_regressions.py` gate (so it always runs and must "pass"): rejected — FR-021 explicitly frames it as comparison/inspection output, not a pass/fail gate; conflating it with `PUZZLE_*_FAILURES=0` markers would wrongly imply the report itself can "fail." It gets its own small, separately invoked launcher instead.
- Storing calibration records/findings summary under `.knowledge/`: rejected — the constitution and the spec's FR-025/FR-026 both require durable knowledge to hold only current, validated truth, never a hypothesis log or a temporary evidence artifact; the calibration bundle stays inside this spec's own `.devspark.work/` directory and is superseded, not archived-and-kept, once its findings are (or are not) promoted into durable knowledge.
- A brand-new top-level `tools/` directory for the developer report script: rejected — the repository has no existing `tools/` convention, and the report is a headless Godot `SceneTree` script identical in shape to the existing `tests/*_check.gd` files; adding it to `tests/` (with a distinct non-gating launcher) avoids introducing a new top-level convention for one file.

### Architectural Impact

`PuzzleAnalyzer` sits beside `PuzzleSolver` as a second static, presentation-independent `RefCounted` entry point consuming `PuzzleDefinition` (and, internally, `PuzzleSolver.analyze()`'s result). It introduces no new public class surface beyond one file; the dependency-graph/cascade/blocker-distance data are plain dictionaries/arrays returned alongside the existing-style metrics, matching `PuzzleSolver.analyze()`'s dictionary-contract precedent so a future consumer (a later generator spec) can treat `PuzzleAnalyzer.analyze()`'s output the same way `PuzzleSolver.analyze()`'s is treated today. `PuzzleCatalog` grows from 8 to 14 entries via the same literal-builder pattern; no change to its public API shape. `PuzzleDefinition`/`PuzzleState`/`PuzzleSolver`'s existing files are read-only for this feature except `PuzzleCatalog`, which only gains entries. No scene, presentation, or session file changes; no new Godot dependency; no new external package.

### Reviewer Guidance

Confirm `PuzzleAnalyzer` never imports or references any scene/Node/Control type; confirm every dependency-graph/cascade computation is traceable line-for-line to `PuzzleState.is_blocked`'s existing check (grep for any independent re-derivation of blocking logic); confirm the six new `PuzzleCatalog` builders are literal-constructed exactly like the existing eight (no `.tres`/JSON); confirm `tests/run_puzzle_regressions.py`'s existing markers (`PUZZLE_FAILURES=0`, `PUZZLE_CATALOG_FAILURES=0`, etc.) are unchanged in meaning and a new `PUZZLE_ANALYZER_FAILURES=0` marker is additive; confirm the developer report script and its launcher are excluded from the required-green regression gate; confirm the calibration bundle lives under `.devspark.work/specs/006-.../` and never under `.knowledge/`.

## Summary

Add a headless `PuzzleAnalyzer` sibling to `PuzzleSolver` that computes objective structural metrics (board scale, arrow geometry, legal-move structure, a dependency graph, cascade/unlock fan-out, blocker-distance proxies) from any `PuzzleDefinition`, reusing `PuzzleSolver.analyze()`'s witness and a disposable internal `PuzzleState` rather than a second rules engine. Extend `PuzzleCatalog` with six new experimental puzzles (8 → 14), each satisfying at least one of six named structural experiments (overlap allowed). Extend the existing bare-isolated-project regression harness with analyzer unit tests (synthetic puzzles with hand-computed expected values) and expanded catalog coverage. Add one non-gating developer report script for catalog-wide comparison, and a plain-markdown human-calibration worksheet/records/findings-summary bundle inside this spec's own `.devspark.work/` directory. No gameplay rule, rendering, session, or persistence behavior changes.

## Technical Context

**Language/Version**: GDScript under Godot 4.4 (`config/features=PackedStringArray("4.4")` in `project.godot`, unchanged); Python 3.11+ for the existing headless regression launchers this plan extends.
**Primary Dependencies**: None new. Reuses the existing in-repo domain classes (`PuzzleDefinition`, `PuzzleState`, `PuzzleSolver`, `PuzzleCatalog`) and Maaack's Game Template addon (untouched by this feature).
**Storage**: N/A — `PuzzleAnalyzer` is stateless/pure-function-style (like `PuzzleSolver`); no persistence, no `.tres`/save-file interaction; calibration records are plain markdown files inside `.devspark.work/`, not application storage.
**Testing**: Godot headless `--script` execution via the existing bare-isolated-project pattern (`tests/run_puzzle_regressions.py`), extended with a new `tests/puzzle_analyzer_check.gd` suite and expanded `tests/puzzle_catalog_check.gd` coverage; a separate non-gating `tests/run_puzzle_structural_report.py` launcher for the developer report.
**Target Platform**: Desktop (unchanged; no new platform surface — this feature adds no player-facing platform dependency).
**Project Type**: Single Godot project (game) with a headless-testable domain/rule core, matching the existing `scripts/puzzle/` + `tests/` structure from specs 001–005.
**Performance Goals**: None new. `PuzzleAnalyzer` runs only from tests/dev tooling, never per-frame or during gameplay, so Principle IV (responsive gameplay, no frame-loop blocking work) is satisfied by construction rather than by a numeric budget.
**Constraints**: Headless (no scene/Node/Control dependency); deterministic; MUST NOT mutate the supplied `PuzzleDefinition`, any *live* gameplay `PuzzleState`, or session-scoped current-puzzle state (FR-008); MUST NOT alter `PuzzleSolver`'s existing correctness path or return contract (FR-010); MUST NOT introduce any composite difficulty score/label (FR-009).
**Scale/Scope**: One new ~150–250 line GDScript file (`puzzle_analyzer.gd`); six new `PuzzleCatalog` builder functions (14 total entries); two new/extended test files plus one new non-gating report script; a small markdown calibration bundle (template + 6 records + 1 findings summary) inside the spec's own directory.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Applicability | Assessment |
|---|---|---|
| I. Simple, Maintainable Code | Applies | New files (`puzzle_analyzer.gd`, `puzzle_analyzer_check.gd`, `puzzle_structural_report.gd`) use snake_case filenames and functions per existing convention. The new `PuzzleAnalyzer` class is justified by a concrete need the spec states explicitly (keeping solver correctness decoupled from speculative structural metrics) rather than added speculatively. No new external dependency. |
| II. Prefer Project-Level Template Customization | Applies loosely | No addon (`addons/maaacks_game_template/`) files are touched by this feature; N/A beyond that. |
| III. Accessible, Configurable Controls | Applies | The six new puzzles play through the existing scene/controls (no new input surface); Level Select must continue to support keyboard/gamepad navigation across 14 entries — verified by extending the existing `tests/puzzle_layout_check.gd`-style manual/automated coverage per spec FR-024, not by adding new UI. |
| IV. Responsive Gameplay | Applies | `PuzzleAnalyzer` and the developer report never run during actual gameplay or the frame loop — they are test/dev-tooling-only, invoked headlessly. No frame-rate or frame-time claim is made or needed. |
| V. Practical Gameplay Verification | Applies | Godot validation of new/changed scripts required; manual desktop smoke play of all six new puzzles required (spec FR-024); existing regression suites (`run_puzzle_regressions.py`, `run_regressions.py`) must continue to pass unchanged for the original eight puzzles and all existing gameplay/session behavior. |
| VI. Preserve Saved Progress and Settings | Applies | No persistence code is touched; `PuzzleCatalog`/`PuzzleSession` remain session-only exactly as spec 005 established. No migration/reset plan is needed because no save-format or persistent-state shape changes. |

**Result**: No violations. No `## Constitution Waivers` block needed.

## Context Resolution

*The multi-hop `.knowledge/` traversal for this delta, pinned down here so `/devspark.implement` consumes it as already-resolved and never traverses more than one hop itself. `/devspark.analyze` validates every entry resolves against the current ontology; `/devspark.critic` judges whether the set is sufficient for the delta.*

```yaml
context_resolved:
  - id: arrow-puzzle
    via: direct
    hop: 1
  - id: arrowgame-constitution
    via: direct
    hop: 1
```

No other `.knowledge/` entity or decision informs this delta: `game-visual-system` (presentation/rendering) and `save-progression` (persistent save data) are both explicitly out of scope for this feature (no rendering change, no persistence touched), and `product/branding` is unrelated to puzzle structure. The ontology index (`.knowledge/ontology/coverage.json`) currently reports zero indexed entities, so this traversal relies on the flat `.knowledge/architecture/` and `.knowledge/governance/` docs directly rather than a graph walk.

## Project Structure

### Documentation (this feature)

```text
.devspark.work/specs/006-spec-puzzle-structure-analysis/
├── plan.md              # This file (/devspark.plan command output)
├── research.md          # Phase 0 output (/devspark.plan command)
├── data-model.md        # Phase 1 output (/devspark.plan command)
├── quickstart.md        # Phase 1 output (/devspark.plan command)
├── contracts/           # Phase 1 output (/devspark.plan command)
│   ├── puzzle-analyzer-api.md
│   └── developer-report-format.md
├── calibration/         # Phase 1 output (/devspark.plan command; filled during implementation)
│   ├── worksheet-template.md
│   ├── records.md
│   └── findings-summary.md
├── gates/               # Persisted gate artifacts from analyze/critic/checklist
└── tasks.md             # Phase 2 output (/devspark.tasks command - NOT created by /devspark.plan)
```

### Source Code (repository root)

```text
scripts/puzzle/
├── puzzle_definition.gd     # existing, unchanged
├── puzzle_state.gd          # existing, unchanged
├── puzzle_solver.gd         # existing, unchanged (correctness/contract untouched)
├── puzzle_catalog.gd        # existing, EXTENDED: 6 new builder entries (8 -> 14 total)
└── puzzle_analyzer.gd       # NEW: PuzzleAnalyzer static class (sibling to PuzzleSolver)

scripts/
└── puzzle_session.gd        # existing, unchanged

tests/
├── puzzle_regression.gd         # existing, unchanged
├── puzzle_catalog_check.gd      # existing, EXTENDED: 14-entry coverage + per-experiment assertions
├── puzzle_analyzer_check.gd     # NEW: synthetic-puzzle unit tests for PuzzleAnalyzer
├── puzzle_structural_report.gd  # NEW: non-gating developer comparison report (FR-021)
├── run_puzzle_regressions.py    # existing, EXTENDED: adds puzzle_analyzer_check.gd to the
│                                 #   existing bare isolated project + PUZZLE_ANALYZER_FAILURES=0
└── run_puzzle_structural_report.py  # NEW: small non-gating launcher for puzzle_structural_report.gd
```

**Structure Decision**: Single Godot project, unchanged top-level layout. `PuzzleAnalyzer` is added as a sibling file inside the existing `scripts/puzzle/` domain directory (not a new top-level module), and every new test/report file follows the existing `tests/*.gd` + `tests/run_*.py` launcher convention already established by specs 001–005. No new top-level directory (e.g. no `tools/`) is introduced. The calibration worksheet/records/findings-summary are plain markdown files scoped to this spec's own `.devspark.work/` bundle, not application source.

## Complexity Tracking

No Constitution Check violations were identified; this section is intentionally empty.
