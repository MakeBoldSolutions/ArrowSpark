---
devspark_version: "9.2.0"
spec_semantic_hash: "sem1:9302309199b17ef363234a6e986fce460e4e61dc14cb3799251e9d86c2428fcb"
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Implementation Plan: Maximize Mobile Web Portrait Gameplay

**Branch**: `017-spec-mobile-portrait-play` | **Date**: 2026-10-18 | **Spec**: [spec.md](spec.md)
**Repository root**: `C:/GitHub/MakeBoldSolutions/ArrowGame`
**Feature directory**: `C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/017-spec-mobile-portrait-play`

All paths below are relative to that absolute repository root unless explicitly marked otherwise. This plan is design work; it contains no executable task sequence and claims no implementation or device acceptance.

## Rationale Summary

### Core Problem

Portrait admission, a 16:9 host frame and wide game scenes jointly prevent comfortable upright phone play.

### Decision Summary

Use the existing Astro host to size the iframe to available phone height, and the existing AppTheme startup seam to set mobile logical content dimensions from the iframe's CSS size. Layout controls in those logical units so device density does not shrink touch targets. Keep the existing 1280x720 desktop scale policy for wide fine-pointer play. Use responsive containers in project scenes, retain the one PuzzleViewportTransform for board math, and extend the project pause overlay rather than adding a second menu lifecycle. See [research.md](research.md) for the material sizing and integration questions and [contracts/portrait-ui.md](contracts/portrait-ui.md) for the presentation contract.

Portrait is optimized; landscape and desktop are preserved, not optimized. A landscape-optimization follow-up spec is planned and out of scope. Landscape admission at 640x320, the three-action surface and rotation state-retention remain unchanged.

### Key Drivers

- AppTheme runs before scenes and already centralizes theme installation; it is the appropriate owner of window sizing policy across scenes and CanvasLayer overlays.
- Host CSS owns frame geometry and safe-area padding; the game owns its responsive layout and all gameplay state. No gameplay messages or new API are needed.
- Existing project subclasses provide menu and pause extension points; addon modifications are not required.

### Reviewer Guidance

Confirm CSS-pixel sizing at multiple device densities and actual iframe dimensions, not only the top-level phone dimensions. Check resize while paused, focus restoration and Options child screens; changing only the top-level menu will leave inherited minimum widths unresolved.

## Technical Context

**Language/Version**: Godot 4.4 and GDScript; strict TypeScript and Astro in web/; Python 3.11+ regression launchers.
**Primary Dependencies**: Maaack's Game Template; existing Godot Web export with no threads; existing Node/npm, Vitest and Playwright tooling. No new dependency.
**Storage**: Existing settings/input remaps only; no storage schema or gameplay persistence change.
**Testing**: Existing puzzle and settings launchers, scene-based GDScript checks, Vitest admission checks, browser smoke and post-deploy physical-phone owner acceptance.
**Target Platform**: Pixel 7 Pro Chrome mobile web first; existing landscape and desktop mouse/keyboard/gamepad. Chrome/Firefox desktop smoke; other Chromium-derived browsers explicitly recorded. iPhone support is not newly claimed.
**Project Type**: Godot game embedded in a static Astro showcase.
**Performance Goals**: Responsive direct manipulation; resize work is event-driven, coalesced and unchanged-value guarded. No new frame-rate target or optimization framework.
**Constraints**: Portrait visible-page floor 360x640 CSS px, board viewport >=75% of usable game area, essential targets >=44x44 CSS px and body/control text >=16 CSS px. Board cells are exempt from finger-target minimum at Fit. Rules, catalog, score, session memory and remaps stay unchanged.
**Scale/Scope**: One game, its host frame and existing menu families; no added content or backend.

## Operating Context and Expected Mechanisms

```yaml
operating_context:
  expected_scale: "One embedded game with existing catalog and menus; phone portrait matrix plus desktop/landscape compatibility"
  expected_frequency: "Layout updates on initial load and viewport/capability changes; gestures during play"
  execution: automated
  human_review_acceptable: true
expected_new_mechanisms:
  states: 0
  runtime_settings: 0
  endpoints: 0
  persistent_stores: 0
  caches: 0
  background_workers: 0
```

Transient measurements, a coalescing flag and a live pause-overlay reference are ordinary presentation/lifecycle variables, not new player modes or persisted state. Use one small project responsive-layout helper for shared size policy and AppTheme to apply it; avoid a layout registry, new autoload, feature flag or parallel transform. **Deviations**: none.

## Expected Change Surface

```yaml
expected_change_surface:
  - {path: "web/src/scripts/play-admission.ts", change: modify, why: "Add portrait floor while preserving desktop and landscape admission"}
  - {path: "web/src/components/play/GameFrame.astro", change: modify, why: "Observe visible viewport, retain iframe across resizing, host fullscreen safely"}
  - {path: "web/src/styles/arrowspark.css", change: modify, why: "Phone frame height, scroll-away header and safe areas in both orientations"}
  - {path: "web/src/pages/play.astro", change: modify, why: "Replace landscape-only and removed-button instructions"}
  - {path: "web/src/components/play/PlayUnavailableNotice.astro", change: modify, why: "Remove rotate-only notice for admitted portrait and retain smaller-screen explanation"}
  - {path: "web/game-shell/shell.css", change: modify, why: "Add overscroll suppression alongside touch-action and retain canvas sizing"}
  - {path: "scripts/app_theme.gd", change: modify, why: "One event-driven logical viewport policy before scenes and while paused"}
  - {path: "scripts/presentation/responsive_layout.gd", change: add, why: "Small pure size-policy helper shared by AppTheme and project scenes"}
  - {path: "scenes/puzzle/arrow_puzzle.tscn", change: modify, why: "Replace wide HUD and toolbar with compact status/action strip and expanding board"}
  - {path: "scenes/puzzle/arrow_puzzle.gd", change: modify, why: "Remove dead button wiring; connect Menu, focus and dynamic help"}
  - {path: "scenes/puzzle/puzzle_board.gd", change: modify, why: "Cancel gestures on resize and explicit touch cancellation while keeping existing navigation authority"}
  - {path: "scripts/presentation/puzzle_viewport_transform.gd", change: inspect, why: "Reuse existing fit/manual resize and corner-reach behavior"}
  - {path: "scripts/presentation/puzzle_pause_controller.gd", change: add, why: "Project extension of PauseMenuController shares guarded open flow between Menu and ui_cancel"}
  - {path: "scenes/overlaid_menus/pause_menu.gd", change: modify, why: "Responsive menu, control help and Level Select through existing lifecycle"}
  - {path: "scenes/overlaid_menus/pause_menu.tscn", change: modify, why: "Scrollable narrow-safe content with accessible actions"}
  - {path: "scenes/overlaid_menus/mini_options_overlaid_menu.tscn", change: modify, why: "Fit existing nested Options panel to narrow/short areas"}
  - {path: "scenes/puzzle/puzzle_results.tscn", change: modify, why: "Scrollable content and narrow-safe action layout"}
  - {path: "scenes/puzzle/puzzle_results.gd", change: modify, why: "Adaptive action arrangement preserving metrics/signals/focus"}
  - {path: "scenes/menus/main_menu/main_menu_with_animations.tscn", change: modify, why: "Compact stacked hero and menu/submenu bounds"}
  - {path: "scenes/menus/main_menu/main_menu_with_animations.gd", change: modify, why: "Resize-aware compact presentation without changing selection semantics"}
  - {path: "scenes/menus/main_menu/puzzle_select_menu.gd", change: modify, why: "One/two-column card reflow and width-relative cards"}
  - {path: "scenes/menus/main_menu/puzzle_select_menu.tscn", change: modify, why: "Narrow-safe scrolling content"}
  - {path: "scenes/menus/options_menu/", change: modify, why: "Project-owned inherited options, tabs, row wrapping and minimum widths"}
  - {path: "scripts/presentation/game_visual_style.gd", change: modify, why: "Compact heading variation where needed; retain shared palette, fonts and target floors"}
  - {path: "tests/puzzle_layout_check.gd", change: modify, why: "Result flow, three-action surface, pause/resume and responsive bounds"}
  - {path: "tests/puzzle_canvas_check.gd", change: modify, why: "Interrupted touch and resized/scaled-board selection regression"}
  - {path: "tests/app_theme_check.gd", change: modify, why: "Logical mobile sizing and unchanged desktop brand scaling"}
  - {path: "tests/puzzle_presentation_check.gd", change: modify, why: "Update changed scene paths while retaining result/visual invariants"}
  - {path: "tests/save_input_regression.gd", change: inspect, why: "Retain settings/remap and no-reset coverage"}
  - {path: "tests/README.md", change: modify, why: "Document resulting responsive/input checks and physical acceptance limits"}
  - {path: "web/tests/play-admission.test.ts", change: modify, why: "Portrait boundaries, hybrid inputs and viewport changes"}
  - {path: "web/scripts/check-portrait-play.mjs", change: add, why: "Rendered size/density smoke and retained iframe check using existing browser tooling"}
```

This is orientation, not a file allow-list. Derive affected durable knowledge owners from these paths during implementation; do not copy this bundle's identifiers into durable code or knowledge.

## Constitution Check

Pre-design and post-design evaluation: **PASS**, no waiver needed.

| Principle | Applicable obligation and design response |
|---|---|
| I. Simple, Maintainable Code | Focused scene/container changes; one sizing seam; new scripts/functions snake_case; explicit types where useful. No new dependency or general layout framework. |
| II. Prefer Project-Level Template Customization | Extend project scripts/inherited scenes, including a PauseMenuController subclass; addon source stays unchanged. |
| III. Accessible, Configurable Controls | Preserve keyboard/gamepad paths and remaps; visible focus and focus restoration; measurable readable targets; verify affected physical input paths and menus. Removing buttons does not remove bound actions. |
| IV. Responsive Gameplay | Keep board's one transform; event-driven layout, no per-frame browser calls or rule reconstruction. Measure/investigate observed lag rather than inventing a frame budget. |
| V. Practical Gameplay Verification | Godot validation, both launchers, affected desktop/input smoke, site checks/build and Chrome/Firefox browser smoke. Record other Chromium-derived browsers individually as tested/not tested. Owner-ratified SC-003/SC-007 real-phone acceptance is post-deploy with deployed evidence, grouped under the existing published-phone record; pre-merge checks are automated, real-export rendered size/DPR, Chrome/Firefox and desktop input smoke. Emulation never counts as device evidence. Deferred real-phone acceptance remains outstanding, not passed. |
| VI. Preserve Saved Progress and Settings | No persisted keys or defaults change; existing settings and remaps retained, no GameState reset. Session score remains transient. |

The user's preference for owner testing is compatible with V: the owner supplies real-device and usability evidence post-deploy; no outside-player study is required. A missing phone run cannot be called a pass. No existing accepted post-deploy obligation is moved into the pre-merge gate.

## Context Resolution

Lexical matching and projection ran together using `explain-context.ps1 --project --json` for "mobile portrait play touch puzzle viewport game menus web showcase": one verified index build, max two hops, eight lexical seed candidates, no relationship-hop expansion. Retain the following six direct seeds. Drop `reference-puzzle-design-report` (no content/difficulty change) and `product-branding` (visual palette already fully constrained by game-visual-system); their adjacency does not authorize work. Constitution is separately authoritative above.

```yaml
context_resolved:
  - {id: touch-gestures, kind: knowledge, via: "lexical seed: mobile/touch/viewport", hop: 0, reason: "Preserve modeless gestures, physical slop and iframe touch-action"}
  - {id: web-showcase, kind: knowledge, via: "lexical seed: mobile/web/portrait", hop: 0, reason: "Admission, host sizing, browser support, export and site/game ownership"}
  - {id: arrow-puzzle, kind: knowledge, via: "lexical seed: puzzle/viewport/menus", hop: 0, reason: "Board transform, session controller, groups, focus and no-reset flow"}
  - {id: game-visual-system, kind: knowledge, via: "lexical seed: game/menus/viewport", hop: 0, reason: "App-wide theme, scale policy, presentation and target roles"}
  - {id: save-progression, kind: knowledge, via: "lexical seed: game/menus", hop: 0, reason: "Options/remapping and restart must preserve settings recovery and session boundary"}
  - {id: gameplay-contract, kind: knowledge, via: "lexical seed: game/play/puzzle", hop: 0, reason: "Unchanged assist penalty, completion/results and session memory contract"}
```

## Project Structure

Repository structure is unchanged. Add only `scripts/presentation/responsive_layout.gd`, the project pause controller under `scripts/presentation/`, and the browser smoke script under `web/scripts/`. Keep inherited UI changes in existing project scene families. The planning bundle includes research, the UI contract, quickstart and QA acceptance scenarios. No data-model artifact is justified because domain/persisted shape does not change.

## Design

### Host admission, size and lifecycle

Keep the pure `decidePlay` function. Add portrait minimum 360x640 and keep landscape minimum 640x320 and fine-pointer desktop minimum 960x540. Use orientation only to choose the applicable touch floor, never to reject portrait categorically. Below the floor, retain a larger-screen explanation; remove obsolete rotate-only UI/copy and tests. Touch and fine-pointer checks remain independent for hybrids.

Use one visible-area measurement for admission and frame geometry: visualViewport width/height where available at normal page zoom, otherwise innerWidth/innerHeight. Account for visualViewport scale so browser zoom outside the game remains available. Listen to window resize, orientationchange and visualViewport resize; coalesce updates via requestAnimationFrame. Do not continuously measure during gameplay. Maintain the existing set-src-once guard and startGameBridge once. Once loaded, hiding for a below-minimum transient must retain that iframe, its src and its running state.

For touch-capable admitted play, remove the 16:9 constraint from stage sizing and use available viewport height minus the measured host bar, padding and safe-area insets; use full available container width with compact side gutters. Use CSS 100dvh for the host block-size and a two-row grid (auto host bar, minmax(0, 1fr) stage), subtracting safe-area padding through border-box sizing. The stage has aspect-ratio: auto on touch. Leave JS responsible for admission only; do not introduce style attributes, stylesheet mutation or unsafe-inline CSP. The definitive constraint is that the frame's border box fits the visible height once scrolled into view, not that all Play-page content fits at once.

Make the site header non-sticky on touch in both orientations. Keep page scrolling outside the board and retain `touch-action: none` with `overscroll-behavior: none` at both host stage and shell so downward board drags cannot trigger pull-to-refresh or scroll chaining. The game must not auto-scroll the page on every resize. Apply safe-area padding on the host; request optional fullscreen on the host element rather than the bare iframe so the same bounds/padding policy survives fullscreen. The fullscreen button is outside the game's three-action count and is optional, never needed for acceptance. Its displayed target also meets the phone target floor.

### Logical units and responsive ownership

Keep project.godot desktop canvas_items/expand baseline 1280x720. At startup AppTheme reads mobile-web dimensions from its own iframe window using existing JavaScriptBridge, not a parent-window message or public API. Read CSS width/height and touch capability; validate finite positive measurements. On touch web, use those CSS dimensions as Window.content_scale_size with factor 1, retaining high-density rendering; one logical UI unit then maps to one CSS pixel. Desktop wide fine-pointer keeps existing baseline scaling. A native narrow-window path uses window dimensions for rendered fixtures without pretending it is device evidence.

Use Window/viewport size-change notification and one deferred, unchanged-value-guarded update. AppTheme must operate while paused so rotation resizes overlays too. Invalid zero size retains the last usable scale until recovery. The responsive helper computes size policy and compact layout from current logical available width; compact below 720 units, expanded above. Phone logical sizing applies in landscape too, avoiding small low-density controls. Desktop wide behavior is unchanged except the intentional simpler toolbar.

Do not set independent scales on every menu or multiply gesture coordinates by DPR. Board uses its real resized logical area and existing final transform. The existing physical 32-pixel gesture slop remains physical, including on high-density canvases.

### Gameplay surface and input

Replace Back and toolbar with Menu / Open Move / Fit Puzzle. In portrait touch layouts, put these three actions in a bottom strip within safe-area insets for one-handed thumb reach, with status text at the top. Landscape and desktop keep the header arrangement. Shorten the Open Move label while keeping its accessible name and menu help explicit about its five-mistake cost. Use separate small status text for remaining/mistakes; put full long puzzle title and instructions inside the menu if needed to meet space limits. Remove dead Zoom/Pan node references, tooltips, signal wiring and focus neighbors. Do not leave hidden buttons as focus targets.

Compact layout budgets at most 112 logical/CSS pixels for HUD, bottom strip, safe-area spacing, margins and gaps; the strip counts toward usable game area and the unchanged 75 percent ratio; board expands in the rest. At 360x640 top-level size, measure the actual smaller iframe after host chrome and verify the 75% area ratio there. Do not count host chrome as board or omit HUD from the denominator. Expanded layout may put status/actions on one row. Body text remains >=16 and buttons >=48 logical high (existing theme) with width >=44. No persistent help row. Narrow/full labels must not force a minimum width larger than the iframe.

Keep mouse wheel, middle-drag and current keyboard/gamepad canvas actions. Provide the mouse Pan toggle inside the menu's control-help area for single-button mice; mouse drag-to-pan means middle-drag plus that toggle, and left-drag on an arrow still selects (FR-011 pending owner confirmation); it is not a fourth active-surface control. Match focus to visual order: portrait touch uses board -> Menu -> Open Move -> Fit -> board (top status is passive), with Up from the bottom strip returning to the board. Landscape/desktop retain Menu -> Open Move -> Fit -> board. Configure directional exits using live nodes. Help derives remapped binding text from InputMap.

Keep PuzzleViewportTransform as the only zoom/pan/hit authority. On any board resize, cancel current touches/drag before applying resize_view, including valid-to-valid changes. In raw touch handling, check explicit cancellation before treating release as a tap; erase/clear contacts without emitting cell_clicked. Existing pause/focus cancellation remains. Resize must not call setup, reconstruct PuzzleState or emit completion. Existing Fit/manual policy may refit or clamp view as designed; exact camera preservation is not required, but state preservation and reachable Fit are.

### Pause/menu and transitions

Subclass PauseMenuController in the project and expose one guarded open_menu method. Override ui_cancel handling to use it; Menu button calls the same method. Track the single live overlay, consume the triggering event, reuse current focus capture/tree-exit restoration and block opening while Results is visible or completion is draining. Reuse the controller enable/disable lifecycle in arrow_puzzle.gd. Do not synthesize global cancel events or maintain two pause implementations.

Extend project pause menu with scrollable content, control help and Level Select. Resume restores the same attempt; Restart uses existing confirmation/reload. Level Select sets PuzzleSession.request_level_select and loads the project main menu via the existing scene loader with the tree unpaused. Main Menu navigation retains confirmation semantics. Options opens the inherited project mini-options flow without replacing the puzzle. Clear/cancel board gestures when overlays open. Use existing OverlaidMenu pause ownership and close behavior, including nested Options; ensure closing Options leaves the pause overlay paused and focus returns to its triggering button. Dialogs also fit the narrow safe area.

### Main Menu, Level Select, Options and Results

Main Menu compact layout stacks a smaller brand heading/mark above full-width vertically scrollable actions; wide keeps split hero. Keep animation node paths stable and animate only opacity, not layout anchors. Opening Options/Level Select/credits gives the submenu the full safe width; decorative hero never steals that width. Back remains visible outside scrollable content. Update inherited locked-center button offsets and 40% left anchors through project overrides or resize callback with reversible wide defaults.

Level Select chooses one column when two actual minimum cards plus gap cannot fit, otherwise two. Remove fixed 300-unit card minimum in compact mode, fit cards to content width, wrap long labels with enough height, retain group accordion semantics and stable ids. Scroll follows keyboard/gamepad focus and collapsed children remain unfocusable.

Results uses existing metric fields/signals, a scrollable bounded content panel and vertically stacked actions in compact width; wide retains row arrangement. Set the root full rect when showing as today, and update arrangement on resize while visible. Replay/Next/Level Select behavior and comparison labels remain unchanged.

Options requires all existing project families: master tabs, input/remap rows, mini options, audio/video/game controls and reset confirmations. Retain TabContainer behavior with narrow-safe tab scrolling/arrow controls; wrap label/control rows or stack them at narrow widths, replace hard 400-unit/project minimums with available width, and use vertical ScrollContainers. Override inherited child nodes/resources in project scenes rather than editing addon source. Protect remap capture and user settings: reflow never resets or rebuilds option values from defaults. Check focus-follow scrolling and dialog minimums. Add compact typography variations only for display headings (not body text below 16).

### Requirement-to-design mapping

| Requirement | Design element | Acceptance |
|---|---|---|
| FR-001 | Orientation-specific touch floors in pure admission | SC-001 |
| FR-002 | Dynamic-height host, safe areas, non-sticky touch header | SC-001 |
| FR-003 | Expanding board, bounded compact chrome, measured ratio | SC-002 |
| FR-004 | Portrait bottom strip / preserved landscape-desktop header and removed toolbar wiring | SC-002 |
| FR-005 | Existing raw touches/one transform, explicit cancellation and host touch-action | SC-003 |
| FR-006 | Initial/Fit overview and existing corner-reachable transform | SC-003 |
| FR-007 | Single controller entry and inherited overlay/nested-menu lifecycle | SC-004 |
| FR-008 | Responsive menu families, scroll and wrapping | SC-001, SC-004 |
| FR-009 | CSS-equivalent logical units and measured theme/host targets | SC-004 |
| FR-010 | Src-once host, guarded scaling, resize cancels gestures without setup | SC-005 |
| FR-011 | Rebuilt focus graph, retained bindings/Pan capability, remap-derived help | SC-006 |
| FR-012 | Rule/catalog/score untouched; existing complete-attempt and settings checks retained | SC-006 |
| FR-013 | Presentation helper and existing ownership boundaries | SC-006 |
| FR-014 | Update path-derived knowledge owners and resulting regression docs | SC-006 |

## Verification Strategy

Empirical verification: REQUIRED (end-to-end)
Reason: environment-dependent-behavior — pre-merge actual-export rendered size/DPR, Chrome/Firefox and desktop input checks remain required; physical-phone acceptance is an outstanding post-deploy deployed-evidence obligation.

Use [quickstart.md](quickstart.md) and [qa-acceptance.md](qa-acceptance.md). Automated focused tests cover admission thresholds, compact geometry/targets, invalid size recovery, state retention and cancelled touch. Update existing navigation assertions to the new controls; retain all existing scoring, content fingerprints, departure and no-reset expectations. Do not weaken semantic expectations to accommodate layout changes. Browser smoke uses the real exported game, not a stand-in iframe.

Record portrait sizes 360x640, 390x844, 412x915 at DPR 1 and a high-density setting, plus landscape 640x320 and 915x412, desktop 1280x720 and 1920x1080. Phone dimensions here refer to visible page area; iframe is smaller after host chrome. Capture frame and scene bounds, targets/text in effective CSS pixels, board area ratio, action count, scroll and screenshots. A headless run does not establish real readability, OS focus or physical gestures.

Pre-merge acceptance is both Python launchers against pinned Godot 4.4, fresh-copy editor validation if needed, npm run check/build, rendered size/DPR matrix on the real export, desktop gameplay/menu/input smoke and Chrome/Firefox browser smoke. Merge may proceed once green. Owner real Pixel Chrome acceptance is post-deploy and non-blocking for merge. A physical gamepad check is required for affected paths; simulated input supplies regression coverage but does not silently replace hardware evidence. Record actual browser/engine versions and explicit untested devices; Safari/iPhone remains outside the claimed verified set.

Owner-ratified staging: SC-003/SC-007 and T032/QA-04/QA-14 are post-deploy, deployed-evidence and non-blocking for merge, grouped with the project owner's existing published-phone obligation, captured_as `.devspark.work/intake/future-mobile-ui-scaling-verification-owner-2026-10-17.md`. Other criteria remain pre-merge. Emulation never counts as device evidence. Deferred real-phone acceptance remains outstanding, not passed. Do not duplicate the intake record or close it using local-integration evidence.

## Complexity Tracking

No constitution violations. Repeated resize hooks in individual scene families are justified because each owns a distinct container/animation graph; only measurement and sizing policy are shared at AppTheme. A universal scene walker that rewrites controls would be less predictable for inherited menus, remapping capture and animation ownership. No new data model, message protocol or persistent mechanism is justified.

## Out of Scope

Landscape-specific layout (for example a side action rail) and a landscape board-area target are excluded. Landscape and desktop are preserved, not optimized; the planned landscape-optimization follow-up is separate.


## Implementation Notes

2026-10-18: Responsive options retain existing option/input nodes and their values. The options-only sizing helper wraps labels and bounds inherited minimum widths rather than changing HBoxContainer orientation (Godot forbids changing that subclass orientation). Master tabs wrap original contents in scrolling panels; no new settings/store/channel is introduced. A project mini-options overlay script is a supporting file for its planned inherited scene. Main-menu action scroll adds an intermediate ActionsScroll node; the two lock animation tracks follow the retained actions node at its new path. Portrait action/status containers retain logical target units and the existing board transform.

The isolated settings launcher also copies the new responsive helper because its existing main-menu fixture now references that class. This is a fixture dependency update, not a change to settings expectations.
