# Implementation Plan: Continuous Arrow Visuals and Game Visual Foundation

**Branch**: `003-spec-continuous-arrow-visuals` | **Date**: 2026-09-26 | **Spec**: [spec.md](spec.md)
**Repository root**: `C:/GitHub/MakeBoldSolutions/ArrowGame`
**Feature directory**: `C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/003-spec-continuous-arrow-visuals`
**Route**: full-spec / medium risk; checklist, analyze, critic required. Specification remains Draft.

## Rationale Summary

### Core Problem

Disconnected cell rectangles obscure arrow identity; pulse interruption can leak scale into departure. The puzzle has no reusable Make Bold visual vocabulary.

### Decision Summary

Keep ArrowView as the per-arrow Control, render its ordered centerline through a Line2D child and matching Polygon2D head, and animate the parent. Add presentation-only owner hover, explicit effect precedence, and project-local semantic styling with bundled fonts. Keep all rule authorities unchanged.

### Key Drivers

- Recognizable continuous shapes with generous existing hit targets.
- No changes to puzzle definitions, state, blocking, solver, or arithmetic.
- Predictable interruption, pause, resize, and completion behavior.
- Reusable visual decisions documented as current knowledge during implementation.

### Source Inputs

The accepted specification and its hover clarification; the constitution; the three knowledge nodes pinned below; current puzzle scripts/scenes and regression launchers; official Godot/font sources linked in research.md. Local source is authoritative for current behavior. No production code or runtime checks are performed by this planning step.

### Tradeoffs Considered

Native line joins avoid custom silhouette triangulation. Rounded joins retain cell-center corners instead of adding true curved elbows. A local theme factory avoids duplicated token values across scripts and serialized themes. Separate hover/effect animation handles prevent color transitions from fighting departure. Bundled fonts avoid runtime network or installed-font dependencies.

### Architectural Impact

Presentation expands in place; no new framework, autoload, persistence, input action, or domain entity. Only new styling/font resources and focused presentation tests are needed. Existing PuzzleFeedback remains the sole source for blocked/exit durations; visual styling owns hover timing and pulse amplitude. The pure-rule test copy stays independent of UI/font assets.

### Reviewer Guidance

Check ordered connectivity rather than adjacency inference; normal-state departure before any tween frame; same-owner hover stability; preservation of physical event semantics; local theme boundaries; and meaningful tests rather than only constant assertions. Rendered acceptance remains required.

## Summary

Replace per-cell tile drawing with a slender continuous body and filled directional head. Use the supplied light palette, Inter Tight UI, Be Vietnam Pro heading roles, and a 1.10× default blocked pulse. Whole-cell input and immediate logical removal remain exactly as established. Results retain fields/actions/layout with restrained success styling.

## Technical Context

**Language/Version**: GDScript / Godot 4.4 baseline; Python 3.11+ regression launchers.
**Primary Dependencies**: Existing Maaack's Game Template; built-in Line2D, Polygon2D, Theme, FontVariation, Tween.
**Storage**: No new persistence; bundle redistributable fonts and license notices as project assets.
**Testing**: Existing pure-rule/layout/save suites plus a focused scene-based presentation suite and rendered desktop smoke.
**Target Platform**: Existing desktop Compatibility renderer; acceptance at 1280×720 and 960×540 and resizing between them.
**Project Type**: Godot desktop puzzle game.
**Performance Goals**: Keep input nonblocking; rebuild geometry on shape/extent changes, not every animation frame. No invented FPS budget.
**Constraints**: Light only; shared ink arrows; no curved centerlines, domain changes, new audio, broad menus/results redesign, or weakened domain expectations.
**Scale/Scope**: One fixed 5×4, eight-arrow board; fixtures cover variable lengths/multiple bends. Hover can poll one pointer and resolve one cell per active frame.

Earlier verification used Godot 4.7.2 despite the 4.4 baseline. Implementation must record its actual executable/version and validate on 4.4 when available; missing baseline/hardware checks stay outstanding. Font availability and rendered appearance are implementation checks, not claimed research successes.

## Constitution Check

| Principle | Pre-design | Post-design control |
|---|---|---|
| I Maintainable code | PASS | Focused scripts, snake_case names; built-in renderer primitives; no unrelated rule refactoring |
| II Project-level customization | PASS | No addon edits; local styling and existing project scenes |
| III Accessible/configurable controls | PASS | Retain input map, whole-cell clicks, focusable buttons, visible focus; physical keyboard/gamepad verification task |
| IV Responsive gameplay | PASS | Nonblocking effects, no runtime asset downloads; event/one-cell hover refresh |
| V Practical verification | PASS | Baseline/final Godot validation, regression suites, physical/rendered smoke, honest outstanding evidence |
| VI Preserve progress/settings | PASS | No persistence/schema changes; existing no-reset/remap suites retained and menu roundtrip tested |

Post-design check passes with no waivers. PASS means the design satisfies obligations, not that future runtime verification has already passed.

## Context Resolution

Context resolution started from presentation-file appliesTo matches in `.knowledge/index.json`. After reading arrow-puzzle, save-progression was resolved through their shared appliesTo entry for `scenes/menus/main_menu/main_menu_with_animations.gd`. This is a shared-file ownership connection, not an explicit document reference or ontology edge. No archived work products were consulted.

```yaml
context_resolved:
  - id: arrow-puzzle
    path: C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/arrow-puzzle.md
    via: direct appliesTo match for scenes/puzzle and tests/puzzle_layout_check.gd
    hop: 1
    informs: ordered shape input, ownership boundary, departure barrier, replay, test isolation
  - id: arrowgame-constitution
    path: C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/governance/constitution.md
    via: direct appliesTo match for scenes, scripts, resources, assets
    hop: 1
    informs: project-local customization, preserved controls/settings, mandatory validation and smoke
  - id: save-progression
    path: C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/save-progression.md
    via: shared appliesTo with arrow-puzzle for scenes/menus/main_menu/main_menu_with_animations.gd
    hop: 2
    informs: no reset, remap survival, isolated test data, preserve recovery behavior
```

Create typed `game-visual-system` knowledge during implementation at `.knowledge/architecture/game-visual-system.md`, with appliesTo for the styling script, font resources, touched puzzle scenes/views, and presentation tests. This is planned new ownership, not an existing context_resolved node. Update arrow-puzzle's presentation section and its appliesTo coverage; save-progression needs no rewrite unless implementation actually changes its documented contract. Refresh the knowledge index with the repository tooling after durable knowledge changes.

## Project Structure

All source paths below are relative to the absolute repository root above; artifact paths are inside the absolute feature directory above.

```text
scripts/presentation/game_visual_style.gd           # new semantic values, fonts, local Theme factory
resources/fonts/inter_tight_regular.tres             # new FontVariation 400
resources/fonts/inter_tight_semibold.tres            # new FontVariation 600
resources/fonts/inter_tight_numeric.tres             # new 600 + tnum where supported
assets/fonts/be_vietnam_pro/                        # official static 700/800 + OFL.txt
assets/fonts/inter_tight/                           # official upright variable font + OFL.txt
scenes/puzzle/arrow_view.gd                         # replace tile renderer; visual state/effects
scenes/puzzle/puzzle_board.gd                       # pointer cell sampling, owner view dispatch
scenes/puzzle/arrow_puzzle.gd                       # read-only ownership resolution, style integration
scenes/puzzle/arrow_puzzle.tscn                     # light background, scoped HUD styling
scenes/puzzle/puzzle_results.gd / .tscn              # local light styling and success cue
tests/puzzle_presentation_check.gd                  # new scene-based behavioral checks
tests/run_puzzle_regressions.py                     # isolated third suite, import preparation
tests/puzzle_layout_check.gd                        # retain/extend meaningful layout coverage
tests/README.md / ATTRIBUTION.md                    # commands and asset attribution
.knowledge/architecture/game-visual-system.md       # new durable visual roles and intended use
.knowledge/architecture/arrow-puzzle.md             # current presentation contract
```

Do not edit puzzle_definition.gd, puzzle_state.gd, puzzle_solver.gd, puzzle_results_format.gd, authored layouts, scoring, or existing domain-test expectations. Do not make PuzzleFeedback depend on fonts or styling. Its 0.15s block and 0.25s departure defaults need no change.

## Design

### Ordered visual geometry

Keep setup/set_shape and board bounding-box layout. Copy input offsets defensively and convert to centers `(offset + Vector2(0.5, 0.5)) * extent`. Reverse the ordered centers for tail-to-head rendering without mutating the definition. Never discover connections by adjacency or reconstruct a path from cell ownership.

Initial presentation tokens, tunable by rendered review without rule changes:

| Measure | Initial proportion of cell extent |
|---|---|
| Body width | 0.14 |
| Head tip from head center along forward | +0.30 |
| Head base from head center along forward | -0.06 |
| Head half-width perpendicular to forward | 0.22 |
| Body endpoint inside head from center along forward | -0.02 |
| Single-cell shaft start from center along forward | -0.30 |

Multi-cell bodies begin at the final tail-cell center, end slightly inside the head, and connect all intervening ordered centers. Single-cell bodies use the decorative two-point shaft above. Use round begin cap, no end cap beneath the head, round joints, antialiasing on both children, initial round precision 8. Body/head share opaque color. Node order draws head over body. No texture, outline, fill tile, grid line, curve smoothing, or per-arrow palette. Keep normal silhouettes within owned-cell corridors; at these defaults parallel adjacent shafts have substantial separation. Do not claim pulse/departure swept silhouettes are rule collision shapes.

Use cell extent to regenerate geometry on resize while leaving parent scale at ONE. Parent pivot is size/2 for the pulse. Departing views retain their captured geometry and tween target as today; active relayout must not snap a departure back or emit extra completion. Verify resize behavior visually and with lifecycle assertions.

### Hover routing

PuzzleBoard samples board-local pointer coordinates and emits `hover_cell_changed(cell)` or a sentinel for no eligible pointer. Controller resolves the raw cell through `_state.get_arrow_head(cell)` and calls `board.set_hovered_head(head_or_null)`. This reuses authoritative active ownership rather than maintaining another mutable occupancy map. Board deduplicates by owner, so crossing an owner's cells does not reset its color tween.

During normal unpaused processing, refresh the pointer after resize and when stationary using `get_local_mouse_position()`, board bounds, window focus, and viewport hovered-Control checks so an overlay does not highlight the board beneath it. Clear on mouse/window exit, focus loss, pause notification, results display, setup/replay, and removal of the hovered owner. Re-evaluate on resume/return only when the board is the actual eligible GUI target. Hover sampling is read-only and never calls select_arrow. Leave discrete left-press input behavior intact and keep the ArrowView Control mouse-filter IGNORE; Node2D body/head have no independent picking.

### Effect precedence and departure

ArrowView owns `_hovered`, `_blocked_active`, `_departing`, a hover-color tween, and an effect tween. A single setter applies one visual color to body and head (do not multiply ink by ink through modulate). Effective state precedence: departing > blocked > hover > normal.

Hover interpolates color over 0.12s using smooth ease-out, with no work for unchanged owner/state. Blocked feedback cancels any color transition and prior effect, resets scale, sets critical red immediately, and pulses 1 -> 1.10 -> 1 over 0.15s, with ease-out and no bounce. Repeated requests restart from baseline rather than accumulating. Hover eligibility can change during the pulse without replacing red. At pulse completion, restore scale then assign hover color immediately if eligible, otherwise normal ink (the accepted clarification); do not append another hover-duration tail to the block cue.

Departure is an idempotent terminal presentation transition: mark departing first; clear hover/blocked flags; kill BOTH tween handles; synchronously set scale ONE, ordinary modulation/visibility, and normal ink; then start position-only rigid translation for 0.25s. No next-frame normalization, no wait for blocked completion, no late callback may recolor/rescale the departing view. Ignore later hover/blocked requests. Preserve exactly one exit_finished. Board connects completion before starting the effect, removes its active-view entry, clears hover if needed, and forwards one departure_finished. Controller's pending-departure barrier and immediate domain mutation remain unchanged.

### Semantic styling and fonts

GameVisualStyle is a presentation-only RefCounted helper with semantic color/spacing/shape constants, geometry ratios, hover duration, pulse amplitude, font roles, and a cached local Theme factory. It references current PuzzleFeedback timing constants where needed instead of duplicating them. No rule class imports GameVisualStyle.

Bundle official OFL fonts and licenses during implementation; record source revision/hash and attribution. Use static Be Vietnam Pro Bold/ExtraBold and Inter Tight variable upright through 400/600 FontVariation resources. Numeric variation enables tnum only when the bundled file supports it; verify support and equal-digit advances, document fallback if unavailable, do not substitute an unrelated family. No runtime downloads or machine-installed font fallback as the intended design.

Expose Theme type variations for game/secondary headings, labels, supporting text, numeric text, primary/secondary buttons, and surfaces. Initial logical font sizes: major 32, secondary 24, UI/numeric 20, supporting 16; verify at 960×540 and retain readable minima rather than shrinking text with cell extent. Current labels mixing captions and values may use the semibold numeric font as a whole, avoiding disruptive node splitting. Heading roles may be established for reuse without inventing a new screen.

Set the light background via an ignored-input ColorRect behind Layout. Apply Theme to Layout/HUD and explicitly to PuzzleResults, not the ArrowPuzzle root or project global theme: runtime pause/options children of the root must keep their inherited styling. Results retain four metrics and two buttons; use light background/surface and success green on the existing score display. Preserve Replay focus, visible keyboard focus styles, normal button semantics, and panel input absorption. No new result fields or major composition changes.

### Knowledge and verification

Each story updates relevant current-knowledge descriptions after code/test behavior exists. The final visual-system document records the exact palette, fonts/weights, tnum capability, spacing/radius/border/shadow vocabulary, state precedence, timings, proportions, intended use, and scoped-theme boundary, citing only durable source/tests. Regenerate knowledge index/coverage with existing tools; no archived records or reverse links.

Add a third headless presentation suite to the existing isolated launcher. Keep pure-domain copying unchanged. Perform real-project headless import under isolated APPDATA/XDG_DATA_HOME before scene suites so new fonts/global classes are available on a clean checkout. Both scene suites use the same isolated user-data environment; each requires exit zero and its own success marker. Tests inspect actual visual children/state and route synthetic GUI events through board input, supplemented by real desktop input tests. See quickstart.md for the complete acceptance matrix.

## Delivery and Gates

The smallest visual preview is foundation plus US1; full delivery requires US1–US5 and all verification. Tasks follow the accepted story order with dependencies called out. Planning produces research.md, data-model.md, contracts/presentation.md, quickstart.md and then the requested tasks.md; it does not implement them.

Specification checklist is complete. Analyze and critic remain required next-stage reviews, not passes asserted by this plan. Retain the full bundle for release; the shared preamble's explicit retention rule takes precedence over the older tasks-template instruction to delete FEATURE_DIR.

## Agent Context

Ran `.devspark/scripts/powershell/update-agent-context.ps1 -AgentType codex` successfully (no override present). It added duplicated stack descriptions tagged with the feature identifier to AGENTS.md. Removed only those generated lines to honor the no-planning-backlinks rule and retain current, rather than future, guidance. Existing manual content and active technologies are preserved; AGENTS.md has no net change. No new production stack is introduced.
