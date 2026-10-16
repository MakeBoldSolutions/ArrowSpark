---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
devspark_version: "9.2.0"
classification: full-spec
risk_level: medium
target_workflow: specify-full
required_artifacts: spec, plan, tasks
recommended_next_step: plan
required_gates: checklist, analyze, critic, verify:end-to-end
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

<!--
  Temporary working state. This spec lives in .devspark.work/ until /devspark-release archives it.
  Durable code, tests and .knowledge/ must not reference it.
-->

# Feature Specification: Game UI Improvements

**Feature Branch**: `016-spec-game-ui-improvements`
**Created**: 2026-10-16
**Status**: In Progress
**Input**: User description: "Game UI Improvements — using this conversation and industry best practices, make the game prettier, more professional and look like a ready-for-consumer game, not a demo. NO functional change to game play or behavior."

## Product Owner TLDR

ArrowSpark's puzzle screen already wears the Make Bold look, but everything around it — the launch
splash, Main Menu, Level Select, Options, Pause and Credits — still shows the game engine's default
grey styling and logo, and the menus shrink to a small fraction of the screen on large monitors and
in the browser. This spec makes every non-gameplay surface scale to the screen, share one Make Bold
visual identity, open with Make Bold branding instead of the engine's, and feel finished through a
redesigned Main Menu and Level Select plus restrained motion and sound. How the puzzle plays,
scores and responds does not change.

## Rationale Summary

### Core Problem

Outside the puzzle board the game presents as an engine template: menus render at fixed pixel size
(tiny on large or high-density displays), use the engine's default theme, and launch with the
engine's logo, so the product reads as a demo rather than a consumer game and is visually
disconnected from both its own gameplay screen and the Make Bold showcase site.

### Decision Summary

- **Presentation-only delta.** Rules, scoring, puzzle content, input semantics, arrow visuals and
  gameplay feedback are frozen; only how surrounding screens look, size and transition changes.
- **One app-wide brand look.** The existing gameplay palette, typography and spacing vocabulary is
  extended to every screen instead of being scoped to the puzzle layout and Results. This
  deliberately reverses the current recorded rule that the brand theme is never applied app-wide;
  the visual-system knowledge must be updated to the new truth in the same change.
- **Screen-relative sizing.** All UI scales with the window/canvas from a fixed design resolution so
  it reads the same on a laptop, a 4K monitor, a browser tab and a landscape phone.
- **Three prioritized slices.** P1 (scaling + brand look + branded launch) is shippable alone;
  P2 (Main Menu and Level Select redesign) and P3 (motion, background motif, UI sound) build on it
  and can be stopped after any slice.
- **Branding stays where it already belongs.** Identity is established on application-level
  surfaces (launch, Main Menu, Credits) and recedes during play; the puzzle HUD and Results gain no
  product or company branding, and creator credit/link remain in Credits only.

### Key Drivers

- Owner feedback: "the menu is very small"; "it still feels like a Godot game engine demo."
- The public showcase presents the game as a Make Bold property; the in-game shell should match it.
- Large displays, high-density screens and the mobile web beta make fixed-pixel UI visibly broken.

### Source Inputs

- Repository inspection (2026-10-16): no screen-scaling setting; brand theme attached only to the
  puzzle layout and Results; Level Select requests brand styles that resolve to nothing; launch
  shows the engine boot splash then the engine logo; Main Menu uses the template layout with an
  empty background.
- `.knowledge/product/branding.md` — branding hierarchy and "establish identity, then recede" rule.
- `.knowledge/architecture/game-visual-system.md` — current palette, typography, spacing, motion
  vocabulary and the scoped-theme rule this spec changes.
- `web/theme/make-bold/` — Make Bold color ramps (cream, ink, rust, ember, positive) and the peak mark.
- Industry practice: resolution-independent UI from a design resolution, single root theme,
  60-30-10 color balance, one primary action per screen, 44–48 px minimum targets, WCAG AA text
  contrast, 150–300 ms ease-out UI motion that is always skippable.

### Reviewer Guidance

- Confirm the scoped-theme reversal is intended and that the visual-system knowledge node is
  rewritten (not appended) to describe the app-wide theme.
- Screen scaling changes the logical size every layout observes, including the puzzle board's fit
  and zoom and the web Play page's admission thresholds; check that gameplay framing at the existing
  regression sizes is unchanged and that the phone beta is not made smaller.

## Minimum Sufficient Change

```yaml
minimum_sufficient_change:
  minimum_valuable_outcome: "Every non-gameplay screen scales to the display, uses the Make Bold look, and launch shows Make Bold branding instead of the engine's (User Stories 1–2)."
  explicitly_not_required:
    - "Any change to puzzle rules, scoring, catalog content, progression order, input mapping or arrow appearance/feedback"
    - "New settings, persistence, accounts, achievements or saved-progress changes"
    - "A dark mode or alternate color schemes"
    - "Redesign of the web showcase site or its loading shell beyond keeping the hand-off visually smooth"
    - "New languages or translation work beyond keeping existing strings fitting"
    - "Branding added to the puzzle HUD or Results"
  acceptable_manual_operations:
    - "Rendered visual review and owner sign-off on screenshot sets (visual quality cannot be asserted headlessly)"
    - "Manual desktop, browser and real-phone smoke tests per constitution Principle V"
```

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Readable UI at any screen size (Priority: P1) ✅ Complete

A player opens ArrowSpark on a large monitor, a high-density laptop, a browser tab or a landscape
phone and sees menus, buttons and text at a comfortable, consistent size relative to the screen —
never a small cluster in the corner or middle of a large empty window.

**Why this priority**: The owner's first complaint; it makes the game look broken before any
styling is judged, and it affects every screen.

**Independent Test**: Launch at 1280×720, 1920×1080, 2560×1440 and 3840×2160 windows, a desktop
browser and the reference phone; compare Main Menu, Level Select, Options and Pause captures.

**Acceptance Scenarios**:

1. **Given** a 3840×2160 window, **When** the Main Menu appears, **Then** the title, buttons and
   text occupy the same proportion of the screen as at 1280×720.
2. **Given** the game is running, **When** the player resizes the window or rotates/resizes the
   browser, **Then** menus and overlays re-scale without clipping, overlap or needing a restart.
3. **Given** a puzzle in progress at any supported size, **When** compared to the current build,
   **Then** the board framing, fit, zoom range and pan behave the same.
4. **Given** an ultra-wide or unusually tall window, **When** any menu is shown, **Then** content
   stays centered and fully visible with the background filling the extra space.

---

### User Story 2 - One Make Bold look from launch to every screen (Priority: P1)

From the moment the game starts, the player sees Make Bold branding and a single consistent visual
system — cream surfaces, ink text, rust primary actions, ember highlights and focus — on the splash,
Main Menu, Level Select, every Options tab, Pause, Credits, confirmation dialogs and tooltips,
matching the puzzle screen and the showcase site.

**Why this priority**: Removes the "engine demo" impression; together with Story 1 it is the
minimum shippable improvement.

**Independent Test**: Walk every reachable screen and dialog with mouse, keyboard and gamepad and
confirm none shows engine default styling, fonts or logo.

**Acceptance Scenarios**:

1. **Given** a fresh launch, **When** the game loads, **Then** no engine logo or engine-default
   splash is shown; a Make Bold/ArrowSpark branded splash appears instead and remains skippable.
2. **Given** any menu screen, **When** displayed, **Then** it uses the brand palette, the brand
   heading and body typefaces, and the shared spacing, radius and focus vocabulary.
3. **Given** a screen with several actions, **When** displayed, **Then** exactly one primary action
   is visually emphasized (e.g. Play on Main Menu) and the others are visibly secondary.
4. **Given** keyboard or gamepad navigation, **When** focus moves across any control on any screen,
   **Then** a clearly visible ember focus indicator shows the focused control.
5. **Given** the Options screens, **When** sliders, checkboxes, dropdowns, tabs and scrollbars are
   used, **Then** each is styled in the brand system and keeps its current behavior and values.
6. **Given** gameplay, **When** a puzzle is being played or Results are shown, **Then** no new
   product or company branding appears there.

---

### User Story 3 - A Main Menu and Level Select that invite play (Priority: P2)

The Main Menu has a deliberate composed layout with the ArrowSpark wordmark, the "A Make Bold Spark
Game" tagline and the Make Bold mark, and a clear Play call to action; Level Select presents puzzles
as tidy, scannable cards grouped by their existing purpose groups (Foundations, Puzzle Lab,
ArrowSpark Levels) with a distinct brand accent per group.

**Why this priority**: The first screens a player judges quality by; builds on Story 1–2 styling.

**Independent Test**: Open Main Menu and Level Select at the regression sizes and on the phone;
confirm layout, grouping, ordering and that selecting each card opens the same puzzle as today.

**Acceptance Scenarios**:

1. **Given** the Main Menu, **When** shown, **Then** the same actions are available in the same
   order with the same results as today, presented in the new composed layout.
2. **Given** Level Select, **When** shown, **Then** every catalog puzzle appears exactly once, in
   the current group and order, with its existing title and description, as a selectable card.
3. **Given** the Results panel's Level Select action, **When** used, **Then** Level Select opens
   directly as it does today.
4. **Given** keyboard/gamepad, **When** navigating Level Select cards, **Then** focus order follows
   visual order and the focused card scrolls into view.

---

### User Story 4 - Polished motion, background and sound (Priority: P3)

Screens transition with short, smooth fades/slides; buttons give subtle hover and press response;
menus sit over a quiet animated background motif drawn from the game's own arrow shapes; and menu
interactions play soft UI sounds governed by the existing audio volume settings.

**Why this priority**: Raises perceived quality and engagement once layout and styling are right;
safe to defer.

**Independent Test**: Navigate all menus with motion and sound on, then with UI/master volume muted;
confirm transitions never block input and sounds respect volume settings.

**Acceptance Scenarios**:

1. **Given** any menu transition, **When** triggered, **Then** it completes within 300 ms and input
   on the destination screen is never blocked waiting for it.
2. **Given** the intro animation, **When** the player presses any accept/cancel input or clicks,
   **Then** it skips immediately, as today.
3. **Given** the background motif, **When** shown behind menus, **Then** it stays low-contrast,
   never competes with text legibility, and is absent during puzzle play.
4. **Given** UI or master volume set to zero, **When** navigating menus, **Then** no UI sound plays.

---

### Edge Cases

- Smallest admitted surfaces: 960×540 desktop browser and a 640×320 landscape phone — text and
  targets must stay legible and tappable, and must not end up smaller than today on the phone.
- Very large or high-density displays (4K, 200% scaling) and ultra-wide (21:9) or tall windows.
- Window resized or browser canvas changed during the intro, a transition, a pause overlay or an
  arrow departure.
- Long strings: the longest puzzle titles/descriptions and the existing French menu translation
  must fit cards and buttons without clipping.
- Level Select opened directly from Results, Pause opened mid-departure, Options opened from Pause.
- Hand-off from the web page's dark loading shell to the in-game splash must not flash harshly.
- Players using only keyboard, only gamepad, only mouse, or only touch.
- Audio muted or audio device unavailable in the browser before first interaction.

## Clarifications

### Session 2026-10-16

- Q: Main Menu visual direction? → A: Split layout — dark ink hero panel (mark, cream title with ember "Spark", tagline) beside a cream menu column (FR-010).

## Requirements *(mandatory)*

### Functional Requirements

**Scaling (Story 1)**

- **FR-001**: All UI MUST scale proportionally to the window or browser canvas from a single design
  resolution, re-scaling live on resize, so screen proportions at any supported size match those
  at the design resolution.
- **FR-002**: Wider or taller-than-design screens MUST extend the background to fill the extra area
  while keeping menu content centered and fully visible (no letterbox bars, no clipping).
- **FR-003**: At the design resolution, body text MUST be at least 18 px, menu titles at least
  64 px, and every interactive target at least 48 px tall; on the smallest admitted phone surface
  text and targets MUST NOT be smaller than in the current build.

**Brand look (Story 2)**

- **FR-004**: One brand visual system MUST apply to every screen, overlay, dialog, tooltip and
  popup, covering buttons, labels, panels, tabs, sliders, checkboxes/toggles, dropdowns, scrollbars
  and text inputs, using the Make Bold cream/ink/rust/ember/positive palette and the existing brand
  typefaces.
- **FR-005**: Colors MUST follow a cream-dominant, ink-structural, rust/ember-accent balance: rust
  for the single primary action per screen, ember for hover/focus/selection, ink for text and
  structure.
- **FR-006**: The launch sequence MUST show a branded ArrowSpark / Make Bold splash and MUST NOT
  show the engine's logo or default boot splash; the splash MUST remain skippable.
- **FR-007**: Pause and other in-game overlays MUST present as a dimmed scrim over the game with a
  brand-styled panel.
- **FR-008**: Every focusable control on every screen MUST show a visible ember focus indicator, and
  keyboard/gamepad navigation and input remapping MUST keep working on all screens.
- **FR-009**: Text MUST meet WCAG 2.1 AA contrast (4.5:1 body, 3:1 large text and focus indicators)
  against its background.

**Main Menu and Level Select (Story 3)**

- **FR-010**: The Main Menu MUST present the ArrowSpark title, the existing tagline and the Make Bold
  mark in a composed branded layout with Play as the primary action; available actions, their order
  and outcomes MUST be unchanged. The layout MUST be a split composition: a dark ink hero panel
  carrying the Make Bold mark, the title in cream with "Spark" in ember, and the tagline, beside a
  cream menu column holding the actions; on narrow screens the hero MAY reduce in width but MUST
  keep the title and the actions visible together.
- **FR-011**: Level Select MUST show puzzles as cards grouped under the existing purpose-group
  headings, each group carrying a distinct brand accent, preserving current membership, order,
  numbering, titles, descriptions and selection outcome.
- **FR-012**: Creator credit and the public link MUST remain in Credits only; the puzzle HUD and
  Results MUST NOT gain product or company branding.

**Motion, background, sound (Story 4)**

- **FR-013**: Screen transitions and control hover/press feedback MUST complete within 300 ms, use
  ease-out timing without bounce, and never block or delay input.
- **FR-014**: Menus MUST show a low-contrast animated background motif derived from the game's arrow
  shapes; it MUST NOT appear during puzzle play and MUST NOT reduce text contrast below FR-009.
- **FR-015**: Menu interactions MUST play short UI sounds routed through the existing audio volume
  controls so that zero volume silences them; added audio assets MUST be license-compatible and
  attributed.

**Invariants**

- **FR-016**: Architectural constraint: puzzle rules, scoring, catalog content and order, input
  bindings and semantics, arrow geometry/colors and gameplay feedback timing MUST be unchanged; the
  existing regression gates MUST pass without modifying their expectations.
- **FR-017**: Architectural constraint: saved settings and progress MUST load and behave unchanged;
  no new setting or persisted value is introduced.
- **FR-018**: The current visual-system and branding knowledge MUST be updated in the same change to
  describe the app-wide theme, scaling behavior and launch branding as current truth.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At 1280×720, 1920×1080, 2560×1440 and 3840×2160, the Main Menu title and primary button
  occupy the same fraction of screen height within ±5%.
- **SC-002**: 0 reachable screens, overlays or dialogs show engine-default styling, fonts or logo,
  checked against an inventory of every reachable surface.
- **SC-003**: 100% of interactive targets measure at least 48 px tall and 100% of text meets AA
  contrast at the design resolution.
- **SC-004**: From the branded splash, the player reaches an interactive Main Menu in under 3 seconds
  without skipping and immediately on any skip input.
- **SC-005**: 100% of Main Menu, Level Select, Options, Pause and Credits paths are completed with
  keyboard-only, gamepad-only and mouse-only input, and touch on the reference phone.
- **SC-006**: Both existing automated regression gates pass with zero changes to their expected
  results, and a manual smoke play of the first progression level and the Reference Knot shows the
  same moves, mistakes and score as the current build.
- **SC-007**: The owner signs off a rendered screenshot set (all screens at three sizes plus phone)
  as reading as the same brand as the showcase site and as a finished consumer game.

### Verification

```text
Empirical verification: REQUIRED (end-to-end)
Reason: runtime-configuration and environment-dependent-behavior — UI scaling resolves at runtime from window/canvas size and display density, which differ across desktop, browser and phone.
```

All obligations are `pre-merge`: rendered desktop runs at the listed sizes, a local web build in
Firefox and Chrome, and the reference real phone on a local build (`local-integration` evidence),
plus both headless regression gates (`automated`).

## Assumptions

- Context gathering completed with no skipped items; prior specs 001–014 reviewed for numbering.
- The design resolution remains 1280×720, matching the current layout tests and regression sizes.
- The Make Bold peak mark may be shown on the Main Menu and splash: that is application-level
  identity, consistent with the branding rule; creator credit and URL stay in Credits.
- A "Made with Godot" acknowledgment, if desired, lives in Credits; removing the engine splash is
  license-compatible.
- UI sounds are sourced from permissively licensed (e.g. CC0) assets and recorded in attribution.
- Unused template themes may be removed as part of consolidating on one look.
- Light theme only; the web loading shell keeps its current dark ink styling.

## Out of Scope

- Gameplay rules, scoring, puzzle content, progression, input mapping, arrow visuals and feedback.
- New settings (including a dedicated reduce-motion toggle), persistence, accounts or achievements.
- Dark mode or alternate palettes.
- Showcase website redesign and new translations.
- Product release, versioning, packaging or deployment.
