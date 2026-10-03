```yaml
gate: critic
devspark_version: "unknown"
generated: "2026-10-03T00:00:00Z"
status: warn
blocking: false
severity: warning
summary: "FULL critique, verdict CONDITIONAL: the real-device spike may start, but the plan is wrong about two baseline facts (press-time selection plus default touch-to-mouse emulation; no content scaling today) and omits one affected knowledge doc. Three human-decision findings and one NFR target to rework; amend before T017."
reviewed_artifacts:
  - path: spec.md
    hash: "c49b8705ddf2ff2ee3d8acd238ccf347300dbd13"
  - path: plan.md
    hash: "e6edb1f6a0ecff8e1d1e816fc2cdc6f4a802d445"
  - path: tasks.md
    hash: "04e7fa3ff0da6da0109c001b932273b69edcd8b9"
```

## Technical Risk Assessment

**Analysis Date:** 2026-10-03
**Scope:** FULL
**Pass:** DISCOVERY
**Applicable:** true — signals: cross-boundary-interaction (page ↔ iframe ↔ Godot Web engine ↔ browser touch/gesture handling), state-lifecycle (orientation/resize mid-attempt); invoked: explicit
**Detected Archetype:** game (declared by Godot project; showcase site is a secondary static web surface)
**Detected Stack:** GDScript / Godot 4.4 Web (no threads) + Astro/TypeScript static site
**Context Mode:** brownfield (inferred)
**Risk Profile:** customer-facing (inferred: public showcase)
**Risk Posture:** YELLOW

### Executive Summary

The plan's sequencing (spike → freeze → small slice) is sound, and its scope control is good. Reading the baseline, though, two of its core premises do not hold as written: selection fires on press, so "a second finger cancels a pending tap" is not achievable without a decision, and the project has no content scaling today, so "stretch the existing 1280 × 720 presentation" understates a global change. One affected knowledge document was dropped from context. These are best fixed in the plan/tasks now, while changing them is cheap. Nothing here prevents starting the spike.

### Findings (source of truth)

```yaml
findings:
  - finding_id: critic-001
    owner: critic
    category: concurrency_async
    archetype_applicable: true
    location: contracts/touch-input-contract.md#5, plan.md#Phase 1, tasks.md#T023
    description: The touch contract says a second finger cancels a pending tap and a Pan-off one-finger drag never selects. In the baseline a left press emits cell_clicked immediately, and Godot emulates a mouse press from the first touch by default, so the first finger of a pinch (or the start of a drag) can already have removed or blocked-penalized an arrow before any second finger or movement is seen. A mistake costs score. The plan never decides whether touch selection moves to release time, whether engine mouse emulation is turned off, or how the two interact; with emulation on, the first finger also drives the existing mouse pan while a pinch handler zooms.
    evidence: scenes/puzzle/puzzle_board.gd:_handle_button (pressed MOUSE_BUTTON_LEFT branch emits cell_clicked on press, lines ~334-345); project.godot has no input_devices/pointing/emulate_mouse_from_touch entry (grep emulate returned nothing), so the engine default (emulation on) applies.
    root_cause: ""
    intent_cue: ""
    base_severity: critical
    effective_severity: critical
    classification: deferred-work
    recommended_action: Before T017, decide and record touch selection semantics (e.g. touch selects on release without movement, with engine mouse emulation disabled or ignored for the board), add a spike task to measure the premature-selection and double-fire cases (R1/R3), and update the contract and T023/T021 accordingly. Keep mouse press behavior unchanged for desktop.
    execution_mode: manual
    status: open
    outcome: ""
  - finding_id: critic-002
    owner: critic
    category: binary_size_perf
    archetype_applicable: true
    location: plan.md#Phase 2, tasks.md#T019, T020, research.md#R2
    description: The plan treats the 1280 × 720 presentation as something to be "stretched if the spike shows it is needed". The baseline has no content scaling at all, so UI sizes (fonts 16-32, buttons, the 480 px HelpLabel) are in canvas pixels that map to device pixels; on a high-DPR phone, 44 CSS px needs far more than 44 canvas px and 20 px labels render tiny. Scaling is therefore almost certainly required, and a global stretch change would also alter desktop window-resize behavior, which the plan promises not to touch.
    evidence: project.godot [display] sets only window/size/viewport_width=1280 and viewport_height=720 (no stretch mode/scale); export_presets.cfg html/canvas_resize_policy=2; .knowledge/architecture/game-visual-system.md type-scale table (InterfaceLabel/PrimaryButton 20, SupportingText 16); scenes/puzzle/arrow_puzzle.tscn:114 custom_minimum_size = Vector2(480, 0).
    root_cause: ""
    intent_cue: ""
    base_severity: high
    effective_severity: high
    classification: deferred-work
    recommended_action: Reword R2/T019 so scaling is an expected, capability-conditioned runtime change (applied only for touch-capable admitted devices, not a global project setting), add a desktop resize regression to Phase 3, and have the spike record the canvas-to-CSS scale and readable text sizes per device.
    execution_mode: selective
    status: open
    outcome: ""
  - finding_id: critic-003
    owner: critic
    category: testing_strategy
    archetype_applicable: true
    location: plan.md#Context Resolution, tasks.md#T025, T028, T041, T052
    description: game-visual-system.md applies to scenes/puzzle/**, puzzle_viewport_transform.gd and the type scale, and states that visual quality needs desktop checks. The plan dropped it from context_resolved, and no task updates it, yet T019/T025/T028/T041 change effective control sizes, scaling and help text in exactly those files. Current truth would silently diverge from the shipped touch behavior.
    evidence: .knowledge/architecture/game-visual-system.md frontmatter appliesTo (scenes/puzzle/**, scripts/presentation/puzzle_viewport_transform.gd, tests/puzzle_presentation_check.gd) and its type-scale table; plan.md Context Resolution lists only web-showcase, arrow-puzzle and the constitution.
    root_cause: ""
    intent_cue: ""
    base_severity: high
    effective_severity: high
    classification: deferred-work
    recommended_action: Add game-visual-system to context_resolved (hop 0, reason: touch sizing/scaling of puzzle scenes) and add a Phase 8 task to record touch control sizing, scaling and the "desktop checks" scope change in .knowledge/architecture/game-visual-system.md.
    execution_mode: auto
    status: open
    outcome: ""
  - finding_id: critic-004
    owner: critic
    category: testing_strategy
    archetype_applicable: true
    location: spec.md#SC-003, tasks.md#T008, T049
    description: SC-003 requires 100% of at least 20 taps on removable arrows to succeed. The Reference Knot spans at least 44 × 24 cells and the fit zoom is bounded by the smaller board-area axis, so on a landscape phone at Fit a cell is single-digit CSS px; a miss there is a finger-precision limit, not a defect, and the target is unreachable without first zooming. A target that cannot be met would force either a false failure or a quietly changed protocol.
    evidence: scripts/puzzle/puzzle_catalog.gd:_build_reference_knot shapes reach x=43 and y=23; scripts/presentation/puzzle_viewport_transform.gd:fit_cell_pixels = min((viewport.x - 32)/board.x, (viewport.y - 32)/board.y).
    root_cause: ""
    intent_cue: ""
    base_severity: medium
    effective_severity: medium
    classification: deferred-work
    recommended_action: Reword SC-003 and T008/T049 to define the tap protocol (zoom level, e.g. a minimum on-device cell size after pinch or reveal, and what counts as an intended-arrow tap), and report hit rate at Fit and at working zoom separately.
    execution_mode: selective
    status: open
    outcome: ""

verification_obligations:
  - assumption: Touch drags inside the game iframe do not scroll, rubber-band or zoom the parent page on iOS Safari and Android Chrome.
    why_material: No touch-action rule exists in web/game-shell/shell.html or the page styles, and the shell's gesture guard handles only Safari gesture events and Ctrl-zoom; if the engine does not call preventDefault for touch, in-game gestures leak to the page (breaks FR-011, SC-004).
    proposed_proof: Real-device R4 (verify:end-to-end): one-finger drag in Pan mode and two-finger pinch inside the iframe, observing page scroll/zoom, on each matrix device.
  - assumption: The first touch unlocks audio on both browsers without producing a selection.
    why_material: Press-time selection (critic-001) means the unlocking tap could also act on an arrow.
    proposed_proof: Real-device R7: first tap on an arrow with sound off, then confirm audio and that selection occurred exactly once.
  - assumption: The spike build can reach real devices over HTTPS in the same-origin iframe shape (the existing workflow publishes a preview URL per same-repository pull request).
    why_material: Without a reachable HTTPS host, T005 stalls the whole spike.
    proposed_proof: Confirm during T005 that a PR preview serves the spike flag; ensure T040 removes the flag from production paths.
  - assumption: 44 × 44 CSS px for all required controls fits alongside a usable board on the smallest admitted landscape viewport.
    why_material: Two rows of controls at 44 CSS px consume a large share of a phone's landscape height; if the board becomes unusably short, that viewport is excluded rather than the target lowered.
    proposed_proof: Real-device R5/R6 control audit and minimum-viewport probing; classification at the freeze (T015/T016).
```

### High

| ID | Category | Location | Issue | Impact | Suggestion |
|---|---|---|---|---|---|
| critic-002 | binary_size_perf | plan.md#Phase 2, T019, T020 | No content scaling in the baseline; scaling is treated as optional | Tiny text and controls on high-DPR phones; a global change could alter desktop behavior | Make scaling an expected, touch-conditioned change; add a desktop resize regression |
| critic-003 | testing_strategy | Context Resolution, T025/T028/T041 | game-visual-system.md omitted from context and from tasks | Current knowledge diverges from touch behavior | Resolve it and add a Phase 8 update task |

### Critical

| ID | Category | Location | Risk | Likely Impact | Action |
|---|---|---|---|---|---|
| critic-001 | concurrency_async | touch-input-contract.md#5, T023 | Press-time selection plus default touch-to-mouse emulation | First finger of a pinch/drag selects or penalizes an arrow before the gesture is known | Decide touch selection semantics before T017; spike-measure it |

### Medium (shown for completeness)

| ID | Category | Location | Issue | Suggestion |
|---|---|---|---|---|
| critic-004 | testing_strategy | SC-003, T008, T049 | 100% tap success at Fit zoom is unattainable on a ~44 × 24 board | Define zoom level and protocol |

### Missing Critical Tasks

- **Testing:** a spike measurement of premature selection and double-fire from touch-to-mouse emulation (critic-001); a desktop window-resize regression for scaling changes (critic-002).
- **Knowledge:** a game-visual-system.md update task (critic-003).

### Questionable Assumptions

1. **"A second finger cancels a pending tap"** → Failure mode: selection is already emitted on press, so cancellation arrives too late.
2. **"Stretch only if the spike shows it is needed"** → Failure mode: the baseline is unscaled device-pixel UI, so every size target is unreachable without scaling.

### Dependency Risk Assessment

| Dependency | Concern | Alternative |
|---|---|---|
| Godot 4.4 Web touch/pointer handling | Emulation defaults and page-gesture behavior are engine-version specific | Settle by real-device spike; keep any workaround in the board input path only |
| Existing Azure PR preview | Needed for HTTPS device access | Use it for T005; otherwise a temporary HTTPS tunnel |

### Estimated Technical Debt at Launch

- **Code:** a touch-conditioned scaling path and capability helper to maintain beside the desktop path.
- **Operational:** support matrix must be re-verified on new OS/browser releases; none is automated.
- **Testing:** real-device verification is manual by design; automated coverage is limited to transform equivalence and layout size checks.

### Metrics

- Showstopper 0 / Critical 1 / High 2 (effective)
- Material unique findings 4 (plus 1 medium counted above: critic-004)
- Findings by category: concurrency_async 1, binary_size_perf 1, testing_strategy 2
- Routed findings 0; verification obligations 4
- Missing operational tasks: 3 (see above)

**VERDICT:** CONDITIONAL

The verdict derives from open findings that need a consequential human decision (touch selection semantics, scaling approach) before the post-freeze implementation phases; none is a blocking defect for the spike itself.

**Required Actions Before Implementation:**

1. Decide touch selection semantics and engine touch-to-mouse emulation handling (critic-001); amend the touch contract, T021 and T023.
2. Rework scaling as an expected touch-conditioned change with a desktop regression (critic-002); amend R2, T019 and Phase 3.
3. Add game-visual-system to context_resolved and a knowledge update task (critic-003).
4. Redefine the SC-003 tap protocol (critic-004).
These can be applied through `/devspark.tasks` remediation while the spike (Phases 1–2) proceeds; they must be settled by T017.

**Recommended Risk Mitigations:**

- Record in the spike notes whether the first-finger tap selects on press, and whether Godot emits both a mouse and a touch event per tap, on each device.
- Prefer the existing PR preview for hosting the spike build.
