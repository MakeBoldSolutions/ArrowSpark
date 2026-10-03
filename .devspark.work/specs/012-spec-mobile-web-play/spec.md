---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
classification: full-spec
risk_level: high
target_workflow: specify-full
required_artifacts: spec, plan, tasks
recommended_next_step: implement
required_gates: checklist, analyze, critic, verify:end-to-end # real-device behavior depends on browser/OS and the deployed iframe; added per verification contract 2.1 (environment-dependent behavior, deployed-state assumption)
depends_on: []
supersedes: []
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Feature Specification: ArrowSpark Mobile Web Play — Touch + Responsive Landscape

**Feature Branch**: `012-spec-mobile-web-play`
**Created**: 2026-10-03
**Status**: Complete <!-- Valid: Draft | In Progress | Complete -->
**Input**: User description: "Make the existing ArrowSpark browser game genuinely playable on touch-primary devices (iOS Safari, Android Chrome; landscape primary) without redesigning the game or changing its rules. Follow-on to Spec 011."

> This spec is temporary working state under `.devspark.work/specs/`. It remains there until
> release archival and must not be referenced by durable code or `.knowledge/` content.

## Product Owner TLDR

The public showcase currently lets only desktop visitors play; phone and tablet visitors can read the story but see a "play on a larger screen" notice. The showcase site and its editorial content are already mobile-first; this spec makes the **game** mobile-web-first while it remains an in-browser Godot game: a visitor arriving on a reasonably modern phone should normally be able to choose Play and play directly in the browser using touch, with no installation, mouse, keyboard or second device. The same game, puzzles and Reference Knot are played in landscape with taps, one-finger pan and pinch zoom; phone usability is the primary success case, tablets are useful evidence but not sufficient alone, and desktop stays fully supported. A short rotate or larger-screen message is a fallback for genuinely unsupported cases, not the expected mobile experience. Because browser touch behavior can't be trusted from emulators, the work starts with a real-device spike, and the supported-device boundary is decided by what that spike proves. If landscape works and portrait would need a restructure, we ship landscape and record portrait as deferred.

## Rationale Summary

### Core Problem

Spec 011 deliberately gated play to a fine pointer and at least 960 × 540 CSS pixels. A large share of visitors arrive on phones, so they can read the story about a game they cannot try. The game itself already has a Pan mode, Fit Puzzle and a shared viewport-transform authority; it is not known whether touch input, 1280 × 720 content scaling, iframe interaction, audio start and control sizes work acceptably on iOS Safari and Android Chrome.

### Decision Summary

Make the existing game playable on touch landscape, with modern phones as the primary success case; do not redesign it into a mobile game. The spike looks for the smallest changes that make normal modern phones usable rather than for reasons to exclude them. Prove feasibility on real devices first, then adapt scaling, control sizes, help text and the page gate. Unsupported viewports stay unsupported with an honest message; puzzle geometry is never altered to fit them.

### Key Drivers

- Visitors on touch devices, above all modern phones, should be able to play, not only read; phone play is the normal public path, not an optional compatibility extra.
- Rules, scoring, puzzles, content versions and the session model are unchanged (Reference Knot stays the same puzzle and version).
- Gesture math must feed the existing logical-grid → board-local transform → viewport authority, not a second viewport model.
- Emulation cannot answer iOS Safari / Android Chrome questions (touch-to-mouse translation, iframe gestures, audio unlock, fullscreen limits).

### Source Inputs

- Spec 011 (web showcase) and `.knowledge/architecture/web-showcase.md`: desktop-only boundary (fine pointer, ≥ 960 × 540 CSS px), page-zoom guard, same-origin iframe, first-click audio/keyboard focus.
- Spec 008 (large zoomable canvas): Pan mode, Fit Puzzle, viewport transform and board input authority.
- Project base viewport is 1280 × 720.
- Constitution Principle V: Web builds are browser-smoke-tested "in each supported desktop browser".

### External Contracts

- None consumed from other repos. The existing completion hand-off message from the game to the page (contract version 1) MUST remain unchanged.

### Tradeoffs Considered

- Portrait-first redesign: rejected; large UI restructure, out of scope.
- Mobile-specific puzzle geometry for the Reference Knot: rejected; viewport becomes unsupported instead.
- Emulator-only validation: rejected; does not prove iOS/Android behavior.
- Selected: landscape-first adaptation of the existing game, proven on real devices, with a rotate/unsupported message elsewhere.

### Architectural Impact

- Showcase page gate changes from "fine pointer only" to a boundary that admits supported touch landscape devices and keeps the notice for the rest.
- Game input gains touch handling (tap, one-finger pan in Pan mode, two-finger pinch) that routes into the existing viewport-transform authority.
- Menu/HUD controls get touch-sized hit areas on touch devices; desktop layout and behavior are unchanged.
- Help text gains touch wording alongside, not replacing, desktop wording.
- `.knowledge/` web-showcase and constitution wording ("supported desktop browsers") need updating once the supported matrix is proven.

### Reviewer Guidance

Check that desktop behavior is unchanged, that no second gesture/viewport path exists, that no required action depends on hover/wheel/middle/right click/keyboard/fullscreen, and that the supported/unsupported boundary is backed by recorded real-device evidence rather than emulation.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Feasibility spike on real devices (Priority: P1)

The team learns, on physical iPhone Safari and Android Chrome (and iPad Safari if available), what the current Web build actually does with touch, scaling, iframe interaction and audio, and records the answers before committing to implementation details.

**Why this priority**: Every other story depends on facts that emulators cannot provide; an unproven plan risks building on false assumptions.

**Independent Test**: A written spike record exists that answers each research question below with device model, OS/browser version, steps and observed result, and states the resulting supported-viewport boundary.

**Acceptance Scenarios**:

1. **Given** the current game build on a real iPhone and a real Android phone, **When** the tester taps an arrow, **Then** the record states whether the existing arrow-selection/removal behavior fires, and on which devices.
2. **Given** the current build in landscape, **When** viewed at the device's CSS viewport, **Then** the record states whether the 1280 × 720 presentation is readable via scaling alone, with puzzle geometry unchanged, and the smallest CSS viewport judged usable.
3. **Given** the same-origin iframe on the showcase page, **When** the tester taps, pans and pinches inside it, **Then** the record states whether gestures reach the game, whether the page scrolls or zooms instead, and what iOS Safari permits for fullscreen and audio start.
4. **Given** the current menus, HUD and Results, **When** inspected at touch landscape sizes, **Then** the record lists controls whose fixed minimum sizes block touch use.

---

### User Story 2 - Play a puzzle with touch in landscape (Priority: P1)

A visitor on a supported phone or tablet in landscape opens Play and solves a puzzle: tapping arrows to remove them, panning with one finger in Pan mode, pinching to zoom, using Fit Puzzle and Open Move.

**Why this priority**: This is the feature's purpose.

**Independent Test**: On each supported real device, complete the Reference Knot using only touch.

**Acceptance Scenarios**:

1. **Given** a supported touch device in landscape, **When** the visitor taps an arrow that can leave, **Then** it is removed exactly as with a mouse click.
2. **Given** a blocked arrow, **When** the visitor taps it, **Then** the same blocked-selection feedback and mistake accounting occur as on desktop.
3. **Given** Pan mode is on, **When** the visitor drags with one finger, **Then** the board pans; **When** Pan mode is off, **Then** a one-finger drag does not unintentionally select or remove an arrow.
4. **Given** any puzzle, **When** the visitor pinches, **Then** the board zooms about the pinch point within the same zoom limits as desktop, and Fit Puzzle restores the fitted view.
5. **Given** the visitor taps Open Move, **When** it resolves, **Then** the assist and score behave exactly as on desktop.

---

### User Story 3 - Complete the full session flow on touch (Priority: P2)

A touch visitor navigates menu, Level Select, play, Back, Results and Replay, and finishes a puzzle, without any desktop-only input.

**Why this priority**: A playable board is not enough if the surrounding flow traps the user.

**Independent Test**: On each real device, go Play → Level Select → puzzle → Back → puzzle → completion → Results → Replay using touch only.

**Acceptance Scenarios**:

1. **Given** touch only, **When** the visitor needs to leave or pause, **Then** an on-screen control (not Esc) is available.
2. **Given** completion, **When** Results appears, **Then** Replay and Level Select are reachable by tap at finger-sized targets.
3. **Given** completion, **When** the attempt finishes, **Then** the existing completion message to the page is sent unchanged.

---

### User Story 4 - Honest gate and guidance for unsupported situations (Priority: P2)

A visitor on a portrait phone, a too-small viewport or an unproven device sees a concise message (rotate to landscape, or use a larger screen) instead of an unusable game; rotating to landscape on a supported device offers the game; desktop visitors see no change.

**Why this priority**: Prevents silently unusable play and keeps desktop behavior intact.

**Independent Test**: Load Play on desktop, supported touch landscape, touch portrait and an undersized viewport; rotate a supported device during a session.

**Acceptance Scenarios**:

1. **Given** a touch device in portrait, **When** Play loads, **Then** a concise rotate-to-landscape message is shown, the story link remains, and the game is not presented as playable.
2. **Given** a supported device, **When** it rotates or the browser chrome changes the viewport mid-session, **Then** the game resizes without losing the attempt, or the visitor is told clearly what happened.
3. **Given** a desktop browser, **When** Play loads, **Then** the experience and the existing ≥ 960 × 540 fine-pointer boundary behave as before.

---

### User Story 5 - Touch-appropriate help text (Priority: P3)

Help and hint text shows touch wording (tap, drag in Pan mode, pinch, on-screen Back) on touch devices while retaining the desktop wording (Wheel, Middle-drag, Esc) for desktop.

**Why this priority**: Discoverability without hover or keyboard.

**Independent Test**: Open help on desktop and on a touch device; each shows wording valid for its input.

**Acceptance Scenarios**:

1. **Given** a touch device, **When** help is shown, **Then** no instruction requires wheel, middle-drag, right-click, hover, keyboard or fullscreen.
2. **Given** a desktop browser, **When** help is shown, **Then** the existing instructions remain present.

---

### Edge Cases

- A second finger lands mid-tap or mid-pan (tap must not fire; pan must hand off cleanly to pinch).
- A pinch ends with one finger still down (no accidental selection or jump).
- Page scrolling or browser pull-to-refresh / back-swipe competes with in-game gestures; the page must not scroll or zoom while the player gestures inside the game.
- Browser toolbars appearing/disappearing change the viewport height during play.
- Orientation change mid-puzzle, including rotating to portrait and back.
- Touch hybrid devices (laptop with touchscreen, tablet with mouse): a fine pointer must keep working and must not be misclassified into an unusable mode.
- Audio is blocked until a user gesture; the first tap must unlock it without a stray selection.
- Devices below the proven minimum viewport: the message is shown; the puzzle is never altered to fit.
- Small phones where target sizes cannot be met without breaking Reference Knot readability: unsupported, not squeezed.

## Requirements *(mandatory)*

### Functional Requirements

> Each `FR-###` is a stable traceability anchor referenced by tasks via `Implements: FR-###`.

- **FR-001**: Before implementation details are fixed, a recorded real-device spike MUST answer: (1) whether a tap on iOS Safari and Android Chrome triggers the existing arrow selection; (2) whether the 1280 × 720 presentation is readable in landscape via scaling alone without changing puzzle geometry; (3) whether pinch and touch pan can feed the existing viewport-transform authority; (4) whether the same-origin iframe is usable on both; (5) the minimum usable CSS viewport; (6) which controls have fixed minimum sizes that block touch; (7) what iOS Safari permits for fullscreen, audio start, gestures and iframe interaction.
- **FR-002**: The game MUST let a touch user complete the existing game using tap-to-select/remove, one-finger pan (Pan mode or an equally explicit mode), pinch zoom, Fit Puzzle, Open Move, Back/menu navigation, Results, Replay and Level Select.
- **FR-003**: No required action MAY depend on mouse hover, mouse wheel, middle mouse, right click, keyboard or fullscreen.
- **FR-004**: Touch zoom and pan MUST feed the existing viewport-transform authority; the logical grid → board-local transform → viewport chain MUST be preserved, with no second or mobile-only transform path and no gesture math duplicated in separate UI layers.
- **FR-005**: Rules, scoring, puzzle definitions, Reference Knot geometry and content version, session model, saved progress and the completion hand-off message MUST be unchanged.
- **FR-006**: Touch selection MUST use release-time semantics: a touch is a pending tap and selects only on release, and only if no second finger appeared, movement stayed below the tap/drag threshold, Pan mode did not take ownership, pinch did not take ownership, and the gesture was not cancelled by focus loss, pause, visibility change or results. A second finger or movement past the threshold cancels the pending tap. Board selection MUST NOT rely on the engine's touch-to-mouse emulation; emulated mouse input is ignored while a real touch sequence owns the board. Actual desktop mouse press-time behavior is unchanged.
- **FR-007**: All required interactive controls MUST have practical finger-sized hit areas on touch devices and MUST NOT be scaled to unusable sizes; the minimum is 44 × 44 CSS px for gameplay-critical and navigation controls (Back, Fit Puzzle, Open Move, Pan mode, Results actions, Replay, Level Select/navigation); this does not apply to puzzle cells or arrow geometry. On touch-capable admitted devices the presentation is adapted by a capability-conditioned runtime scaling adaptation, not a global project stretch setting, and sizes are judged in rendered CSS px. A control that cannot meet it is a layout problem to solve; any exception MUST be explicit and backed by real-device evidence.
- **FR-008**: State and discoverability MUST NOT depend on hover.
- **FR-009**: Help text shown on touch devices MUST use touch-appropriate wording; desktop help wording (e.g., Wheel, Middle-drag, Esc) MUST remain for desktop.
- **FR-010**: The showcase Play page MUST present: desktop → existing experience; supported touch landscape → the game; unsupported portrait/narrow/undersized → a concise rotate-or-use-a-larger-screen message with the story link. The desktop-only gate MUST be replaced only for combinations the spike proves usable. Admission MUST be capability-based: touch interactions are enabled when touch is available and pointer interactions remain available when a fine pointer is available; the UI MUST NOT switch whole-UI mode on the most recent input or remove desktop affordances because touch exists.
- **FR-011**: The page MUST NOT scroll, zoom or navigate away while the player gestures inside the game on supported devices, while page zoom and scrolling outside the game remain usable.
- **FR-012**: The game MUST handle viewport resize and orientation change without losing the attempt, and unsupported viewports MUST be handled by an honest message rather than silent breakage.
- **FR-013**: The first user gesture MUST start audio where the browser requires it without causing an unintended game action.
- **FR-014**: Desktop behavior, desktop supported boundary, desktop visuals, desktop scaling and window-resize behavior, and desktop mouse selection MUST be unchanged, protected by a desktop resize regression.
- **FR-015**: Verification MUST include real-device evidence on at least an iPhone (Safari) and an Android device (Chrome), plus iPad Safari if available, recording for each exact device model, OS version, browser/version, landscape CSS viewport and devicePixelRatio, covering load, orientation, tap, blocked selection, pinch zoom, pan, Fit Puzzle, Open Move, Back, completion, Results, Replay, Level Select, page/game scroll conflicts, audio and resize/orientation change. Emulation MAY supplement but MUST NOT replace this evidence; checks not performed MUST be disclosed.
- **FR-016**: Durable knowledge (`.knowledge/architecture/web-showcase.md`, gameplay input docs) and constitution Principle V wording ("supported desktop browsers") MUST be updated to match the proven supported matrix, and portrait MUST be recorded as deferred if it is not supported.
- **FR-017**: Appropriate regression coverage MUST be added: headless checks for touch→transform behavior where testable, the existing two regression gates continuing to pass, and site checks for the gate boundary.
- **FR-018**: If landscape works and portrait requires material UI restructuring, landscape support MUST ship and portrait MUST be recorded as deferred rather than expanding scope.

### Key Entities

- **Supported Device Matrix**: Written only from real-hardware evidence; the recorded set of device/browser/orientation/viewport combinations proven usable; drives the page gate and knowledge docs.
- **Spike Record**: Device-level evidence answering the research questions; the source of truth for the matrix and minimum control sizes.
- **Touch Gesture**: Tap, one-finger pan, two-finger pinch; each resolves to an existing board action or viewport-transform change, never to a parallel model.

### Assumptions

- Supported targets are current-generation iPhone/iPad Safari and Android Chrome phones/tablets; older OS versions are not promised.
- Landscape is the only orientation promised; portrait is deferred unless it proves trivial.
- The minimum supported viewport is derived from the spike, not guessed here; the minimum touch target is fixed at 44 × 44 CSS px.
- The Godot Web build (no threads) and same-origin iframe embedding from Spec 011 remain the delivery model.
- Fullscreen is optional enhancement at most, never required.
- No analytics or persistence is added to detect devices; classification uses on-page capability checks only.

### Constitution & Knowledge Notes

- **Principle V** currently requires Web smoke tests "in each supported desktop browser". This spec widens the supported set; the clause must be amended through the constitution workflow (`/devspark.evolve-constitution`) once the matrix is proven — not silently reinterpreted.
- `.knowledge/architecture/web-showcase.md` ("Desktop-only boundary", page-zoom guard, first-click keyboard focus) describes behavior this spec revisits; it is updated at implementation, not contradicted before then.

### Smallest Credible Slice

1. **Spike first (US1)**: a throwaway or flag-gated build on real devices, answering the seven questions. No gate change yet.
2. **Minimum shippable (US2 + US3 core)**: touch landscape on the *one or two device classes the spike proves* (likely larger phones and tablets): tap, Pan-mode drag, pinch via the viewport-transform authority, touch-sized Back/Fit/Open Move/Results/Replay controls, page-gesture guard, gate admits those viewports.
3. **Then**: rotate/unsupported messaging (US4) and touch help text (US5), knowledge and constitution updates, regression coverage.
4. **Deferred by default**: portrait gameplay, small-phone support below the proven minimum, fullscreen.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On at least one real iPhone and one real Android phone in landscape (tablets are supplementary evidence only and cannot satisfy this on their own), a first-time tester completes the Reference Knot using touch alone, with no reliance on keyboard, mouse, wheel or fullscreen.
- **SC-002**: 100% of the FR-015 checklist items are recorded as pass/fail/not-performed for each tested real device, with at least one iPhone and one Android device included.
- **SC-003**: Working-zoom tap protocol: on each frozen device, after the tester pinches or reveals to a documented working zoom (the on-device cell size in CSS px is recorded and a working-zoom minimum is frozen at the checkpoint), at least 20 taps on distinct removable arrows all remove the intended arrow, and taps on blocked arrows produce the same blocked feedback and mistake count as desktop; premature selection and double-fire counts are zero. Fit-zoom tap usability is reported separately as informational data and is not a precision pass criterion.
- **SC-004**: On supported devices, in-game gestures cause zero unintended page scrolls, page zooms or navigations during a full puzzle attempt.
- **SC-005**: Every required on-screen control is at least 44 × 44 CSS px (or has an evidence-backed explicit exception), with zero other required controls below it on supported viewports.
- **SC-006**: Existing regression gates (puzzle and general headless checks) and the site check/build pass with no desktop behavior change, and desktop smoke testing records no regression.
- **SC-007**: Visitors on portrait or undersized touch viewports see the rotate/larger-screen message within one second of Play loading, and never see the game presented as playable.
- **SC-008**: Rotating a supported device mid-puzzle preserves the attempt in every recorded trial.

## Clarifications

### Session 2026-10-03

- Q: Which physical devices and OS/browser versions will be tested? → A: Support is evidence-based. Spec 012 may claim support only for device/browser combinations actually exercised on real hardware during the spike and final verification. Required initial targets: one recent iPhone on current iOS Safari and one recent Android phone on current Android Chrome. If available, also one iPad on current iPadOS Safari. For each, record exact device model, OS version, browser/version, landscape CSS viewport and devicePixelRatio. No claim is made for all iOS or all Android devices, and the final supported matrix is written from this evidence. Emulation may supplement but never replace real-device checks.
- Q: How should touch devices that also have a fine pointer behave? → A: Capability-based input, not mutually exclusive "desktop mode" and "touch mode". If touch input is available, touch interactions are enabled; if a fine pointer is available, mouse/pointer interactions remain available. Touchscreen laptops and iPads with a mouse may use either. The UI MUST NOT switch whole-UI mode based on the most recent input, MUST NOT remove desktop affordances merely because touch capability exists, and MUST NOT require hover for any gameplay-critical function. Page admission considers whether viewport and interaction capabilities meet the proven support criteria rather than forcing a single input identity.
- Q: What is the minimum touch target? → A: 44 × 44 CSS px for gameplay-critical and navigation controls (Back, Fit Puzzle, Open Move, Pan mode, Results actions, Replay, Level Select/navigation). This does not apply to puzzle cells or arrow geometry, which may stay visually dense. If a required control cannot meet 44 CSS px without breaking the layout, the spike reports a layout problem to solve, not permission to lower the target. Any exception must be explicit and backed by real-device evidence.

The seven FR-001 research questions are intentionally NOT answered here; they remain empirical findings for the spike.

### Session 2026-10-03 (analysis and critic remediation)

- Q: How should touch selection behave given press-time mouse selection and engine touch-to-mouse emulation? → A: Release-time semantics for touch (see FR-006); desktop mouse unchanged; the spike must record whether the engine emits both touch and mouse events for one tap, any premature selection and any double-fire.
- Q: What does "mobile-web-first" mean for this spec? → A: The site and editorial content are already mobile-first; this spec makes the game mobile-web-first while remaining an in-browser Godot game. A visitor on a reasonably modern phone should normally be able to choose Play and play in the browser with touch alone. Desktop remains fully supported. It does not mean native apps, portrait-first redesign, mobile-specific puzzles, rules or scoring, or a separate mobile UI architecture. Phone usability is the primary success case; tablets are evidence but not sufficient by themselves; landscape is acceptable; the spike seeks the smallest changes that make normal modern phones usable; exclusion is valid only when real evidence shows a viewport cannot be made usable without material redesign; the evidence-based matrix stays and no untested devices or OS versions are promised; the rotate/larger-screen message is a fallback for genuinely unsupported cases.
- Q: Is touch scaling a project stretch setting? → A: No. It is an expected capability-conditioned runtime adaptation; desktop scaling and resize stay unchanged; the spike records canvas-to-CSS scale and readable text sizes per device (FR-007, FR-014).
- Q: How is SC-003 measured? → A: At a documented working zoom; Fit-zoom tap usability is reported separately (SC-003).

### Session 2026-10-03 (iPhone availability)

- Q: What happens to the iPhone row while no iPhone is available for the spike? → A: Continue on Android now. The iPhone is not frozen as a Supported row, because a support claim needs real-device evidence. It is carried as **Unverified: best educated guess** (expected to work with limitations such as no iframe fullscreen, not claimed). Implementation is written to be iOS-safe by design, and iPhones keep seeing the existing notice until an iPhone is tested. SC-001 stays unmet for the iPhone until then and is recorded as a visible limitation.

### Session 2026-10-03 (release posture and owner-testing budget)

- Q: What is the release goal and how much real-device testing does the owner do? → A: Ship a usable mobile-web beta, not a mobile certification. The owner's manual responsibility is a short smoke check on real mobile hardware only: the page loads, the game starts, tap works, basic pan/zoom/navigation is usable, and there is no obvious showstopper. Everything else is proven by automation, browser emulation, instrumentation and implementation-owned checks. Detailed protocols (20-tap runs, gesture matrices, repeated device-by-device verification) are classified as deferred verification, post-release learning or public-beta feedback unless they reveal a true blocking defect. Known limitations are stated honestly in the release notes and knowledge docs. Pinch zoom, small touch targets, awkward viewport sizes and unavailable fullscreen do not block release; the on-screen zoom, Fit and Pan controls remain the supported way to change the view. The 44 x 44 CSS px target, release-time touch selection and the support-matrix freeze are deferred improvements, not release gates.

