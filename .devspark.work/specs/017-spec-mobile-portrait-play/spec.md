---
devspark_version: "9.2.0"
classification: full-spec
route_intent: full-spec
risk_level: medium
target_workflow: specify-full
required_artifacts: spec, plan, tasks
recommended_next_step: plan
required_gates: checklist, analyze, critic, verify:end-to-end
status: Draft
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Feature Specification: Maximize Mobile Web Portrait Gameplay

**Feature Branch**: `017-spec-mobile-portrait-play`
**Created**: 2026-10-18
**Status**: Complete
**Input**: "Maximize Mobile Web Vertical Game Play"; full-spec and branch creation explicitly confirmed by the owner.

## Product Owner TLDR

Play ArrowSpark holding a phone upright, without a rotate notice or a crowded toolbar getting between the player and the puzzle. Give the board most of the screen, using tap, drag and pinch for direct interaction. Make menus and Results comfortable on a narrow phone. The owner's hands-on testing guides acceptance; recruiting outside players is not required.

## Rationale Summary

### Core Problem

Mobile web currently rejects portrait play, forcing the owner to turn their phone. Separate zoom and pan buttons duplicate gestures and consume puzzle space.

### Decision Summary

Enable portrait play and adapt the complete play journey. Remove persistent Zoom In, Zoom Out and Pan buttons; retain Fit Puzzle, Open Move and one menu entry. In portrait touch layouts, place Menu, Open Move and Fit Puzzle in a bottom action strip within safe-area insets for one-handed thumb reach; keep status text at the top. Landscape and desktop retain the header arrangement. The bottom strip counts toward usable game area and the HUD chrome budget; FR-003 remains 75 percent. Put restart, navigation, options and help inside the menu flow. Preserve supported mouse, keyboard and gamepad capabilities and remapping. Large puzzles remain explorable through zoom and pan rather than requiring readable whole-board display.

Portrait is optimized. Landscape and desktop are preserved, not optimized, apart from the agreed control simplification. A landscape-optimization follow-up spec is planned and is out of scope here.

### Key Drivers

- Upright phone play is the owner's preferred experience.
- Phone touch and mouse are the design targets; dedicated touchpad ergonomics are not a target for this change.
- Modeless gestures already work and their feel must be preserved.
- Existing Make Bold styling should adapt rather than be redesigned.

### Source Inputs

- Owner conversation, 2026-10-18: portrait rejection and excessive controls are the immediate gripes; owner testing is sufficient at this stage.
- `web/src/scripts/play-admission.ts` rejects portrait touch; `scenes/puzzle/arrow_puzzle.tscn` exposes Zoom In, Zoom Out, Fit and Pan.
- Current knowledge: `.knowledge/architecture/web-showcase.md`, `.knowledge/reference/touch-gestures.md`, `.knowledge/architecture/game-visual-system.md`, `.knowledge/product/gameplay-contract.md`.
- Applicable governance: `.knowledge/governance/constitution.md`, principles I–VI. Landscape-only admission in current knowledge is intentionally changed by this request; affected knowledge must be updated.
- Existing published-phone obligation: `.devspark.work/intake/future-mobile-ui-scaling-verification-owner-2026-10-17.md`. Local phone acceptance here does not satisfy its deployed-evidence requirement.

### Reviewer Guidance

Removing the portrait restriction alone is insufficient: verify usable board space, readable menus and real finger interaction without fullscreen. Control simplification must not strand keyboard or gamepad players.

## Minimum Sufficient Change

```yaml
minimum_sufficient_change:
  minimum_valuable_outcome: "The owner can start, play, complete and continue puzzles holding a phone upright, with direct gestures and minimal controls."
  explicitly_not_required:
    - "Outside-player recruitment or usability study"
    - "New puzzles, generation, scoring, saved progress or accounts"
    - "Touchpad-specific controls or toolbar-customization settings"
    - "Native app, installation flow or brand redesign"
    - "Publication or deployment as a spec completion condition"
  acceptable_manual_operations:
    - "Owner tests the published build on a real Pixel 7 Pro in Chrome post-deploy; this outstanding deployed-evidence obligation does not block merge."
    - "Owner records acceptance and remaining limitations in plain language."
```

## User Scenarios & Testing

### User Story 1 - Play upright (Priority: P1)

As the owner playing on my phone, I want portrait play so I do not have to rotate the device.

**Why this priority**: Forced rotation blocks the preferred experience before play begins.

**Independent Test**: Start and complete First Knot on an upright phone without fullscreen.

**Acceptance Scenarios**:

1. **Given** a portrait touch viewport at least 360 by 640 CSS pixels, **When** I open Play, **Then** the game is available without a rotate notice.
2. **Given** visible browser chrome and unavailable fullscreen, **When** I start play, **Then** the game fits the available area and essential actions remain reachable.
3. **Given** Reference Knot in portrait, **When** I pinch, drag and use Fit, **Then** I can inspect and reach every board corner without rotating.

### User Story 2 - Give the puzzle space (Priority: P1)

As a player, I want minimal controls so I can focus on arrows and interact directly with the board.

**Why this priority**: Portrait should improve play rather than squeeze the existing toolbar into a narrow screen.

**Independent Test**: Inspect active controls, navigate by gestures, request Open Move and recover the overview using Fit.

**Acceptance Scenarios**:

1. **Given** active gameplay, **When** I inspect the surface, **Then** only Fit Puzzle, Open Move and one menu entry persist as action controls.
2. **Given** a finger over an arrow, **When** I drag or add a second finger to pinch, **Then** the view changes without selecting the arrow or adding a mistake.
3. **Given** I need restart, navigation, options or help, **When** I open the menu, **Then** they are reachable and Resume returns to the same attempt.
4. **Given** mouse, keyboard or gamepad input, **When** I navigate after toolbar removal, **Then** selection, zoom, pan and Fit remain available through supported input paths.

### User Story 3 - Finish the portrait journey (Priority: P2)

As a phone player, I want usable menus and Results so starting, pausing and continuing levels do not force rotation.

**Why this priority**: Small between-level menus are already an owner-reported problem.

**Independent Test**: Walk Main Menu, Level Select, Options, play, pause, restart, Results, replay and Next Puzzle in portrait.

**Acceptance Scenarios**:

1. **Given** a narrow viewport, **When** a screen opens, **Then** text is readable and essential actions are reachable, with vertical scrolling when necessary and no horizontal overflow.
2. **Given** a partly completed attempt, **When** I rotate to landscape and back or browser chrome changes height, **Then** the attempt and session scores remain intact and the board stays navigable.
3. **Given** Results, **When** I replay, continue or choose Level Select, **Then** existing group-scoped navigation works without clipped controls.

### Edge Cases

- Browser chrome appears or disappears: adapt the game area without reload or a fullscreen requirement.
- Safe areas and rounded edges: keep essential controls inside usable space.
- A second finger, touch cancellation, pause or rotation interrupts a gesture: no delayed selection follows.
- Screens below the portrait minimum: an honest larger-screen notice is allowed.
- Dense boards have tiny arrows at Fit scale: zoom and pan remain the intended inspection method; do not alter geometry to fit.
- Long titles, lists and remapping screens wrap or scroll without hiding the way back.

## Requirements

### Functional Requirements

- **FR-001**: Touch portrait play MUST be admitted at visible page areas at least 360 by 640 CSS pixels without rotation, fullscreen or hidden browser chrome. Existing landscape and desktop admission MUST remain available.
- **FR-002**: Host page and game MUST adapt to the visible viewport without horizontal overflow. Site navigation MUST be able to scroll away and MUST NOT cover the board or essential actions during play.
- **FR-003**: With no menu open, the portrait board viewport MUST occupy at least 75 percent of usable game area. Usable game area excludes browser chrome and device safe areas but includes game HUD and controls; board viewport means the interactive pan-and-zoom region, not the area occupied by visible cells.
- **FR-004**: Active gameplay MUST have at most three persistent action controls: Fit Puzzle, Open Move and one menu entry. Persistent Zoom In, Zoom Out and Pan buttons MUST be removed in portrait, landscape and desktop layouts. Status information may remain without becoming additional actions.
- **FR-005**: Tap selects, one-finger drag pans and pinch zooms without modes. Pan, pinch and cancelled gestures MUST NOT select arrows, request assists or affect score. Board gestures MUST NOT scroll or zoom the surrounding page.
- **FR-006**: Initial entry and Fit Puzzle MUST provide a whole-board overview. Zoom and pan MUST allow all corners to be reached. Readable whole-board display for every puzzle size is not required.
- **FR-007**: The menu MUST provide Resume, Restart, level navigation, Options and control help. Opening it MUST pause gameplay and block input to the board. Resume preserves the attempt; intentional Restart retains fresh-attempt semantics.
- **FR-008**: Main Menu, Level Select, Options, pause and Results MUST work in portrait without clipped essential content, overlap or horizontal scrolling. Vertical scrolling is allowed. Existing branding and contrast MUST be preserved; phone help MUST describe tap, drag, pinch and Fit.
- **FR-009**: Essential action targets MUST display at least 44 by 44 CSS pixels and body/control text at least 16 CSS pixels on admitted portrait sizes. This does not enlarge logical arrow cells or require finger-sized arrows at Fit scale.
- **FR-010**: Orientation and browser-viewport changes MUST preserve the active attempt and session scoreboard without game reload. Interrupted gestures MUST clear safely; Fit MUST remain usable for view recovery.
- **FR-011**: Keyboard/gamepad navigation, input remapping, mouse selection and wheel zoom MUST remain supported. Mouse drag-to-pan means middle-drag, plus a menu-provided Pan toggle for single-button mice; left-drag on an arrow still selects. Removed buttons MUST NOT remove keyboard/gamepad access to their actions. Focus MUST be visible and never land on hidden controls.
- **FR-012**: **Domain invariant:** Puzzle identities, geometry, legal moves, departures, scoring, assist cost, group progression and session-only gameplay memory MUST remain unchanged. Saved settings and remaps MUST be preserved.
- **FR-013**: **Architectural constraint:** Rules MUST remain independent of scenes and input. Admission and presentation may change; ownership of game scoring and state MUST remain unchanged.
- **FR-014**: Changed code, focused regression protection and current knowledge MUST agree on admission, controls, gestures and device support. Evidence MUST distinguish emulation from real-device results and identify untested browsers/devices.

## Success Criteria

### Measurable Outcomes

- **SC-001**: At visible portrait areas 360x640, 390x844 and 412x915 CSS pixels, admission succeeds with zero rotate notices, horizontal overflow or obscured essential actions. Measure visible page area, not advertised device dimensions. Covers FR-001, FR-002 and FR-008.
- **SC-002**: At all three sizes, board viewport area is at least 75 percent of usable game area; at most three persistent action controls appear, and no Zoom In, Zoom Out or Pan buttons. Covers FR-003 and FR-004.
- **SC-003** (stage: post-deploy; evidence_class: deployed; owner: project owner): On the owner's real Pixel 7 Pro in Chrome, complete First Knot in portrait and explore Reference Knot using tap, drag, pinch, Fit and Open Move, reaching all corners without rotation. A sequence including touch cancellation produces zero unintended selections or penalties. Covers FR-005 and FR-006.
- **SC-004**: Walk all screens in User Story 3 with zero clipped essential actions. Measure essential targets and body/control text against FR-009 at the three portrait sizes. Covers FR-007 through FR-009.
- **SC-005**: Two portrait-to-landscape-to-portrait cycles and a browser-chrome height change during an attempt cause zero changes to puzzle identity, active arrows, mistakes, assists and session scores, with no delayed selection. Covers FR-010.
- **SC-006**: Affected gameplay, menus, pause, restart, transitions and input pass Godot validation and desktop smoke testing; both repository regression suites and site checks pass. Browser flows are smoke-tested in Chrome and Firefox, recording other Chromium-derived browsers as tested or not tested. Verify affected keyboard/gamepad paths, remaps and mouse controls. Covers FR-011 through FR-014 and constitution V.
- **SC-007** (stage: post-deploy; evidence_class: deployed; owner: project owner): The owner records acceptance that upright play gives the puzzle sufficient space, controls are comfortable and the complete journey requires no rotation. This is owner acceptance, not outside-player validation.

### Verification Staging

Owner-ratified staging amendment (2026-10-18): SC-003 and SC-007 are **post-deploy**, require **deployed** real-phone evidence and remain open under the existing published-phone obligation in `.devspark.work/intake/future-mobile-ui-scaling-verification-owner-2026-10-17.md`. They are non-blocking for merge. Other criteria are **pre-merge**: automated checks, the rendered size/DPR matrix on the real export, Chrome/Firefox smoke and desktop input smoke. Merge may proceed once those checks are green. Emulation never counts as device evidence. Deferred real-phone acceptance remains outstanding, not passed.

Empirical verification: REQUIRED (end-to-end)
Reason: environment-dependent-behavior — pre-merge proof covers the actual export, rendered size/DPR matrix, Chrome/Firefox and desktop input; physical-phone acceptance remains an outstanding post-deploy deployed-evidence obligation.

Public deployment is not a pre-merge completion condition. Group SC-003 and SC-007 with the existing published-phone obligation cited above, owned by the project owner; reference that record without duplicating it. Local or preview acceptance cannot close the deployed-evidence obligation.

## Assumptions

- The owner is the acceptance tester; outside-player recruitment is unnecessary.
- The 360x640 floor, 75 percent board-area target, three-action surface and 44-pixel targets are explicit draft defaults inferred from the agreed direction. Amend them explicitly if layout evidence warrants a change.
- Pixel 7 Pro Chrome is the primary phone acceptance target. Touch/viewport admission may admit iPhone Safari in portrait while unverified. Play-page copy must state support is unverified outside Pixel/Chrome; admission does not establish support. Wider certification is outside scope.
- Residual risk accepted by the owner: real-phone sizing failures, including targets and board fraction, may surface after merge.
- Owner decision point: FR-011 middle-drag plus menu Pan toggle, with left-drag on an arrow still selecting, is **pending owner confirmation**.
- Portrait touch actions use a safe-area-aware bottom strip with status at top; landscape/desktop retain the header. The strip is included in usable area and the existing chrome budget.
- Landscape and desktop are preserved, not optimized, except intentional toolbar simplification and menu consolidation. A landscape-optimization follow-up spec is planned.
- Current constitution and relevant knowledge were read during this session. Skill context summary was used for scope awareness rather than replacing the constitution. Skipped context: none.

## Out of Scope

- Generation, new puzzles, difficulty redesign, scoring or assist-penalty changes.
- Saved progress, accounts, telemetry, reaction API changes or toolbar-customization settings.
- Touchpad-specific design, native apps, arbitrary tiny screens or universal device certification.
- Public release/deployment and a new visual identity.
- Landscape-specific layout, such as a side action rail, and a landscape board-area target; landscape optimization belongs to a planned follow-up spec.

This spec and its checklist remain temporary working artifacts in `.devspark.work/` until release archival. Durable code, tests and current knowledge must not reference this bundle or its planning identifiers.
