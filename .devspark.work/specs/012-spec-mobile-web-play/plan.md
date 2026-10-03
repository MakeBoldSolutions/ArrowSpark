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

# Implementation Plan: ArrowSpark Mobile Web Play — Touch + Responsive Landscape

**Branch**: `012-spec-mobile-web-play` | **Date**: 2026-10-03 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/.devspark.work/specs/012-spec-mobile-web-play/spec.md`

> Temporary working state. Stays in `.devspark.work/` until release archival; durable code and
> `.knowledge/` must not reference it.

## Rationale Summary

### Core Problem

Spec 011 gates play to a fine pointer and ≥ 960 × 540 CSS px. Touch visitors can read about the game but not play it. Nobody yet knows, on real hardware, whether Godot 4.4 Web touch, 1280 × 720 scaling, the iframe and audio behave well enough.

### Decision Summary

Make the game mobile-web-first (the showcase site is already mobile-first): modern phone + mobile browser + touch + landscape is the normal public gameplay path, and tablets alone are not sufficient. Phase the work around evidence: a real-device spike first, a **matrix-freeze checkpoint**, then a small implementation slice limited to what the spike proved. All gestures feed the existing `PuzzleViewportTransform`; the page gate is rewritten from the frozen matrix; constitution and knowledge are amended only after the matrix is real.

### Key Drivers

- Rules, scoring, puzzles, Reference Knot geometry/version, session model and completion message are unchanged.
- No second viewport model; no gesture math in UI layers.
- Capability-based input (touch and fine pointer coexist); desktop path intact.
- Support claims come only from real-hardware evidence.

### Source Inputs

- Spec 012 spec and clarifications (support rule, hybrid input, 44 × 44 CSS px target).
- `.knowledge/architecture/web-showcase.md`, `.knowledge/architecture/arrow-puzzle.md`, constitution v2.1.0.
- Current code: `scenes/puzzle/puzzle_board.gd` (mouse-only `_gui_input`; touch events are only recognized as non-focus canvas events), `scripts/presentation/puzzle_viewport_transform.gd`, `scenes/puzzle/arrow_puzzle.{gd,tscn}`, `web/game-shell/shell.html`, `web/src/{components/play,scripts}/`.

### Tradeoffs Considered

- Build everything, then test on devices: rejected; wastes work if a premise (tap, iframe, scaling) fails.
- Separate mobile UI or portrait redesign: rejected; out of scope.
- Relying only on the engine's touch-to-mouse emulation: kept as a *spike candidate*, not assumed; the plan permits a thin touch→board translation if the spike shows it is needed.
- Selected: evidence-gated, landscape-first slice reusing existing authority.

### Architectural Impact

- `PuzzleBoard` gains touch handling that calls the same `view_transform.pan_pixels` / `zoom_at` / `cell_clicked` paths as mouse.
- HUD/toolbar sizing becomes touch-aware, driven by capability checks; desktop layout unchanged.
- Web page admission becomes a capability/viewport/orientation decision from the frozen matrix.
- Help text becomes capability-appropriate; desktop text retained.

### Reviewer Guidance

Verify there is exactly one viewport authority, desktop behavior is protected by regressions, no claim exceeds the evidence, and the spike results (not this plan) fix every number.

## Summary

Run a real-device spike (US1) on one iPhone and one Android phone (plus an iPad if available). Freeze the support matrix at a checkpoint. Then implement the smallest slice proven usable: touch tap/pan/pinch into the existing transform, 44 × 44 CSS px required controls on touch-capable devices, honest rotate/larger-screen messaging, capability-based page admission, touch help wording, regression coverage, and finally constitution and knowledge updates.

## Technical Context

**Language/Version**: GDScript / Godot 4.4 (Web export, no threads); strict TypeScript + Astro static site; Python 3.11+ launchers
**Primary Dependencies**: Existing only (Godot, Maaack's template, Astro, Vitest). None added.
**Storage**: N/A — no persistence, analytics or device logging added
**Testing**: Godot headless checks (`run_puzzle_regressions.py`, `run_regressions.py`); Vitest for site admission logic; Godot validation; desktop smoke; mobile-emulation smoke (supplemental); **real-device checks (authoritative)**
**Target Platform**: Godot Web build in a same-origin iframe on iOS Safari and Android Chrome (landscape); desktop browsers unchanged
**Project Type**: Game plus static showcase site
**Performance Goals**: No new numeric target; gesture responsiveness is judged on devices in the spike and recorded
**Constraints**: Required controls ≥ 44 × 44 CSS px; Reference Knot geometry unchanged; no hover/wheel/middle/right-click/keyboard/fullscreen dependency; completion hand-off contract v1 unchanged
**Scale/Scope**: Puzzle HUD, Results and menu control families, and one site page; no new screens beyond a short unsupported/rotate message

No `NEEDS CLARIFICATION` remains. The seven FR-001 questions are research tasks in `research.md` and are deliberately not answered here.

## Constitution Check

*GATE: pass before research; re-checked after design.*

| Principle | Status | Note |
|---|---|---|
| I. Simple, Maintainable Code | Pass | Small changes to existing scripts; no generalized gesture framework; snake_case for new names. |
| II. Prefer Project-Level Customization | Pass | Changes live in project scenes/scripts. If the spike forces addon menu edits (Maaack menu controls), document why per the principle. |
| III. Accessible, Configurable Controls | Pass (watch) | Keyboard/gamepad navigation and remapping MUST be preserved; touch is additive. Verify affected controls with supported input methods. |
| IV. Responsive Gameplay | Pass | Event-driven gestures; no frame-loop blocking. Measure only if the spike reports lag. |
| V. Practical Gameplay Verification | Amendment needed later | Clause says smoke tests "in each supported desktop browser". Verification runs per supported mobile browser as recorded evidence now; the **amendment waits for the frozen matrix** (Phase 5). Sequencing with disclosure, not a waiver. |
| VI. Preserve Saved Progress/Settings | Pass | No new persistence; settings untouched. |

Post-design re-check: no violations; no Constitution Waivers required.

## Context Resolution

```yaml
context_resolved:
  - id: web-showcase
    kind: knowledge
    via: direct (lexical: desktop-only boundary, iframe, page-zoom guard, audio start)
    hop: 0
    reason: Owns the desktop-only gate, frame focus, zoom guard and completion bridge this spec revises; updated after matrix freeze.
  - id: arrow-puzzle
    kind: knowledge
    via: direct (lexical: board input, viewport transform, results, Web completion hand-off)
    hop: 0
    reason: Owns board input authority, PuzzleViewportTransform and the completion message that must stay unchanged.
  - id: arrowgame-constitution
    kind: knowledge
    via: direct (governance; Principle V browser verification, Principle III controls)
    hop: 0
    reason: Principle V amendment timing and Principle III keyboard/gamepad preservation bind this delta.
  - id: game-visual-system
    kind: knowledge
    via: direct (appliesTo covers scenes/puzzle/**, puzzle_viewport_transform.gd and the type scale)
    hop: 0
    reason: Touch control sizing, runtime scaling and the "desktop checks" validation scope change in files it owns; updated in Phase 5.
```

Projection from seeds `web-showcase` and `arrow-puzzle` returned no hop-1 or hop-2 candidates. `gameplay-contract.md` was considered and dropped (it describes no input, pan, zoom or control sizes, and rules are unchanged); `game-visual-system` was added after the critic review.

## Project Structure

### Documentation (this feature)

```text
.devspark.work/specs/012-spec-mobile-web-play/
├── plan.md
├── research.md          # FR-001 questions as research tasks + decisions needing no spike
├── data-model.md        # Spike Record, Support Matrix, Touch Gesture, Capability Profile
├── quickstart.md        # spike and verification runbook
├── contracts/
│   ├── touch-input-contract.md
│   ├── page-admission-contract.md
│   └── spike-record-template.md
└── tasks.md             # later, /devspark.tasks
```

### Source Code (likely touch points; confirmed or trimmed by the spike)

```text
scenes/puzzle/puzzle_board.gd                 # touch events -> existing transform / cell_clicked
scenes/puzzle/arrow_puzzle.gd, .tscn          # HUD/toolbar sizing, help text, Back control
scenes/puzzle/puzzle_results.*                # Results/Replay/Level Select target sizes
scenes/menus/**, scenes/overlaid_menus/**     # Level Select / pause / menu control sizes
scripts/presentation/puzzle_viewport_transform.gd  # authority; new method only if a gap is proven
scripts/presentation/game_visual_style.gd     # static touch-capability, control-size and runtime-scale helpers (no new file)
project.godot                                 # stretch/content scale only if the spike justifies
web/game-shell/shell.html                     # touch-action / viewport / gesture guard
web/src/scripts/desktop-query.ts              # replaced by capability/viewport admission module
web/src/components/play/{GameFrame,DesktopOnlyNotice}.astro, web/src/pages/play.astro
web/src/scripts/page-zoom-guard.ts            # touch extension only if the spike shows conflicts
web/tests/                                    # admission-logic unit tests
tests/                                        # touch->transform headless check, minimum-size check
```

**Structure Decision**: Existing layout (Godot under `scenes/`, `scripts/`; Astro under `web/`). No new top-level directories.

## Phases

Plan phase to task phase map: spike (plan Phase 0) = tasks Phases 1–2; Matrix Freeze = T016/T017; plan Phase 1 = tasks Phases 3–4; plan Phase 2 = tasks Phases 3–5; plan Phase 3 = tasks Phase 6; plan Phase 4 = tasks Phase 7; plan Phase 5 = tasks Phase 8.

### Phase 0 — Real-device spike (US1, FR-001); nothing shipped
Spike builds are throwaway or flag-gated and must not change the shipped gate. Sequence in `quickstart.md`: prepare a spike build with a probe overlay; baseline-load the unmodified build per device; tap/selection; scaling and readability of the Reference Knot; pan and pinch feasibility through the existing transform; iframe behavior and page scroll/zoom conflicts; minimum-viewport probing; control-size audit against 44 × 44; fullscreen/audio/gesture/iframe permissions; orientation and resize. Output: filled Spike Records and a per-device classification (Supported / Supported with documented limitation / Unsupported in Spec 012).

### Checkpoint — Matrix Freeze (decision gate)
Owner and reviewer read the Spike Records and freeze the **Support Matrix** (phone classes are the primary rows; the spike seeks the smallest changes that make normal modern phones usable before any phone class is excluded): per tested device/browser, the classification, the minimum landscape CSS viewport and documented limitations. Nothing later may widen it. A device class needing substantial redesign is excluded, not accommodated. If no phone class is usable without material redesign, the primary success case is unmet: the spec ends at the spike and records that outcome, even if tablets are usable. Tablets alone do not justify shipping this spec as scoped.

### Phase 1 — Input and gesture path (after freeze)
Add touch handling in `PuzzleBoard` only as far as the spike showed necessary, with **release-time selection** (owner decision): a touch is a pending tap and emits `cell_clicked` only on release if no second finger appeared, movement stayed below the tap/drag threshold, neither Pan mode nor pinch took ownership, and nothing cancelled it (focus loss, pause, visibility change, results). One-finger drag in Pan mode → `pan_pixels`; two-finger pinch → `zoom_at` about the pinch midpoint (midpoint drift via `pan_pixels` only if needed). Board selection does not rely on the engine touch-to-mouse emulation: emulated mouse events are ignored while a real touch sequence owns the board; real desktop mouse press-time behavior is untouched. No new transform class and no gesture framework.

### Phase 2 — Layout and control sizing
Touch scaling is an expected, **capability-conditioned runtime adaptation** applied only for admitted touch-capable devices (not a global project stretch setting); desktop scaling and resize behavior stay unchanged and are protected by a desktop resize regression. The spike records canvas-to-CSS scale and readable text sizes per device. The touch-capability query, control-size and scale helpers are static functions on the existing `game_visual_style.gd` (no new script). Required controls (Back, Fit, Open Move, Pan, zoom buttons, Results actions, Replay, Level Select) must render ≥ 44 × 44 CSS px on frozen devices (control px × measured canvas-to-CSS scale ≥ 44). Desktop sizes unchanged. Replace fixed minimums that block touch landscape (e.g. the `HelpLabel` 480 px minimum width). Handle safe-area insets where the spike shows overlap.

### Phase 3 — Page admission and guidance
Replace `DESKTOP_QUERY` with admission logic from the frozen matrix: viewport minimum, orientation, and relevant input capabilities (touch and/or fine pointer; never a single `pointer: fine` flag, never last-input switching). Unsupported portrait/narrow → a concise rotate-or-larger-screen message with the story link. Load the engine only when admitted. Guard page scroll/zoom during in-game gestures per spike findings. Orientation/resize re-evaluates admission without destroying an attempt where feasible.

### Phase 4 — Help text
Capability-appropriate wording for wheel, middle-drag, keyboard and fullscreen references (`arrow_puzzle.gd`, Play page notes, in-game help); desktop wording kept. No critical action requires a keyboard; fullscreen is never relied on for iOS Safari.

### Phase 5 — Verification, then governance and knowledge
Run the Verification Plan. SC-003 uses the working-zoom tap protocol; Fit-zoom tap usability is reported separately. Only then: amend constitution Principle V via `/devspark.evolve-constitution` (supported mobile browsers/devices from the frozen matrix), and update `.knowledge/architecture/web-showcase.md`, the input section of `arrow-puzzle.md`, and `game-visual-system.md` (touch control sizing, runtime scaling, desktop-validation scope) to replace the desktop-only boundary with the proven boundary and record deferrals.

## Verification Plan

**Automated**: headless check that touch-derived calls (release-time tap, drag, pinch, cancel, emulated-mouse suppression) yield the same transform state as the equivalent mouse paths (tap→cell, drag→pan, pinch→bounded zoom, cancel rules); existing `puzzle_viewport_transform_check`, canvas/layout checks and both regression gates stay green; a minimum-size layout check for required controls at a representative scaled viewport; a desktop resize/scale regression; Vitest table-driven admission tests (including hybrid devices and portrait); `npm run check && npm run build`; Godot validation; desktop smoke; mobile-emulation smoke as a supplement only.

**Real device (authoritative, per frozen matrix)**: load, orientation, tap, blocked selection, pan, pinch, Fit, Open Move, Back, completion, Results, Replay, Level Select, resize/orientation change, page scroll/zoom conflicts, audio, iframe behavior. Record device model, OS, browser/version, landscape CSS viewport, devicePixelRatio. Anything not performed is disclosed and the claim withheld. Gate: `verify:end-to-end`.

## Desktop Protection

Touch code is additive and capability-gated; mouse branches in `_gui_input` are not modified; the transform API is unchanged; desktop layout sizes change only under a touch-capability condition; the desktop admission path (fine pointer, ≥ 960 × 540) must continue to admit; both regression gates and a desktop smoke run before and after each phase.

## Deferred / Explicit Non-Goals

Portrait-first redesign (unless the spike shows it is trivial), new puzzles or geometry, mobile scoring, persistence, analytics, native apps, PWA/offline, a generalized gesture framework, broad responsive redesign, small phones below the proven minimum, reliance on fullscreen, support claims for untested devices.

## Complexity Tracking

No constitution violations. The Principle V amendment is sequenced after evidence, not waived.
