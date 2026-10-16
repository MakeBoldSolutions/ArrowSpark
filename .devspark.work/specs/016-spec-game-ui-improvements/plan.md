---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
devspark_version: "9.2.0"
spec_semantic_hash: "sem1:f6830b005f65b086ebb783d811f01d9a8e5df43bc233f6ce3238191d6654f10f"
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Implementation Plan: Game UI Improvements

**Branch**: `016-spec-game-ui-improvements` | **Date**: 2026-10-16 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/.devspark.work/specs/016-spec-game-ui-improvements/spec.md`

## Rationale Summary

### Core Problem

Every surface around the puzzle board still renders with the engine and template defaults, at fixed pixel size, so the shipped game reads as a template demo.

### Decision Summary

- **Scaling (R1).** Use the engine's built-in `canvas_items` stretch with `expand` aspect, fractional scale and a 1280×720 base. There is no runtime clamp. Logical layout sizes never fall below the base, so the board's fit and zoom math and every verified layout are unchanged in logical terms.
- **Touch slop stays physical (R1, owner decision).** PuzzleBoard's 32 px tap/pan slop was tuned in physical pixels. The existing comparison divides it by the viewport's current stretch scale, so the physical threshold is unchanged at every scale. This adds no state or setting, and it is the only change to gameplay input code (FR-016).
- **One theme, one seam (R2).**
  - `GameVisualStyle.get_theme()` grows from puzzle-only roles into the full app theme, covering every standard control type.
  - A new project autoload, `AppTheme`, installs that same cached Theme on the root Window and points the scene loader at a branded loading screen before any scene runs.
  - The existing puzzle and Results assignments stay, handing out the same object, so the scope test at `tests/puzzle_presentation_check.gd:311` keeps passing unchanged.
  - This reuses the one existing theme-construction seam instead of wiring styles screen by screen.
- **Brand assets (R3).** One "mark tile" (the unmodified Make Bold mark on a cream tile with clear space) is used for the splash, the Main Menu hero and the application icon. The boot splash and the opening splash are ink, continuing the dark web shell. The Godot logo asset and its credit entry are removed.
- **Main Menu and Level Select (R5).**
  - Project-owned hero panel plus re-anchored inherited containers. No addon edits and no node renames.
  - Level Select keeps its Button-based API and becomes a grouped grid of card-styled Buttons with a per-group accent variation.
- **Motion and sound (R4, R6).**
  - Retimed existing animations; instant stylebox hover and press states.
  - A drawn arrow-motif backdrop in the hero (a single transform drift).
  - Original UI sounds on the Main Menu's existing `UISoundController` and a new one in the pause overlay only, so gameplay HUD and Results stay silent.

### Key Drivers

- A CI allow-list pins exact error lines in `scenes/opening/opening.gd`, so the opening is changed through its `.tscn` exports only, never its script.
- The headless gates never load the real `[display]` settings, so scaling is proven only by rendered desktop, browser and phone checks (Principle V; spec `verify:end-to-end`).

### Reviewer Guidance

- Verify on the first rendered run that pause-overlay and loading-screen Controls under a CanvasLayer inherit the root theme (R2). If they do not, apply the documented fallback before continuing.
- At a 960×540 CSS desktop canvas with DPR 1, UI renders at 0.75× (an accepted bounded limitation, R1). Confirm it is legible in the browser smoke test.

## Technical Context

**Language/Version**: GDScript, Godot 4.4-stable (gates); Python 3.11+ launchers
**Primary Dependencies**: Maaack's Game Template (inherited scenes; no addon edits planned)
**Storage**: N/A. No new settings or persisted values (FR-017).
**Testing**:
- `python tests/run_puzzle_regressions.py --godot <4.4>` and `python tests/run_regressions.py --godot <4.4>`.
- A new focused headless check for theme coverage and contrast.
- `--headless --editor --quit` validation.
- Rendered desktop, Firefox/Chrome and real-phone smoke tests.

**Target Platform**: Windows desktop, Web export (Firefox, Chrome/Chromium), Android phone landscape (beta)
**Project Type**: Desktop/web game (Godot)
**Performance Goals**: No new per-frame work beyond one backdrop transform update while menus are shown; gameplay frame loop unchanged.
**Constraints**:
- Presentation-only (FR-016).
- WCAG AA contrast (FR-009).
- ≥48 px targets and ≥18 px body text at 1280×720 (FR-003).
- Transitions ≤300 ms (FR-013).

**Scale/Scope**:
- About 9 screen surfaces: splash, loading, Main Menu, Level Select, Options (5 tabs), Credits, Pause, dialogs/popups/tooltips, plus Results and HUD inheriting base controls.
- Every catalog entry (currently 30) in Level Select.

## Operating Context and Expected Mechanisms

```yaml
operating_context:
  expected_scale: "bounded — one local player, ~9 UI surfaces"
  expected_frequency: "every launch and menu visit"
  execution: operator-driven
  human_review_acceptable: true
expected_new_mechanisms:
  states: 0
  runtime_settings: 0
  endpoints: 0
  persistent_stores: 0
  caches: 0
  background_workers: 0
```

**Deviations**: One new autoload (`AppTheme`). Its shape is a Node whose `_ready()` assigns the root Window theme and the scene loader's loading-screen path.
- **Forcing requirement**: FR-004 and SC-002, since the template loading screen can render before any project scene with a script we may change.
- **Least-complex alternative**: the `gui/theme/custom` project setting is equally early, but it needs a saved theme resource that would duplicate the code-built theme.

The backdrop motif's per-frame drift is a presentation animation, not a background worker.

## Expected Change Surface

```yaml
expected_change_surface:
  - {path: "project.godot", change: modify, why: "stretch mode/aspect, ink boot splash without engine image, cream default clear color, AppTheme autoload (R1–R3)"}
  - {path: "scenes/puzzle/puzzle_board.gd", change: modify, why: "compare touch slop in physical pixels by dividing by the viewport stretch scale, preserving the tuned touch feel under scaling (R1; FR-016)"}
  - {path: "tests/puzzle_canvas_check.gd", change: modify, why: "headless touch check at a non-1 stretch scale: a drag under the physical slop still taps, one over it pans"}
  - {path: "scripts/presentation/game_visual_style.gd", change: modify, why: "add brand ramp tokens (rust hover/pressed, ember tint, ink hero, scrim) and extend get_theme() into the full app theme incl. PrimaryButton states, LevelCard accents, hero roles"}
  - {path: "scripts/presentation/control_theme.gd", change: add, why: "styling for standard control types (Button, Label, Panel, TabContainer/TabBar, sliders, CheckBox/CheckButton, OptionButton/PopupMenu, ScrollBar, LineEdit, Tree, ProgressBar, RichTextLabel, tooltips, embedded windows) kept out of the vocabulary file"}
  - {path: "scripts/app_theme.gd", change: add, why: "AppTheme autoload: root Window theme + branded loading screen path (R2)"}
  - {path: "assets/brand/", change: add, why: "mark tile SVG (unmodified mark on cream tile) used by splash, hero and icon source (R3)"}
  - {path: "assets/ui/", change: add, why: "brand-colored control icons (checkbox, radio, toggle, slider grabber, dropdown/tree arrows) for a light theme"}
  - {path: "assets/audio/ui/", change: add, why: "three original short UI sounds (R4)"}
  - {path: "icon.png", change: modify, why: "replace template author's icon with the ArrowSpark mark tile"}
  - {path: "assets/godot_engine_logo/", change: remove, why: "engine logo no longer shown (FR-006)"}
  - {path: "scenes/opening/opening_with_logo.tscn", change: modify, why: "ink background, mark tile image, retimed exports; script untouched (CI allow-list)"}
  - {path: "scenes/loading_screen/loading_screen.tscn", change: add, why: "project inherited loading screen with brand background instead of 50% black over default panel"}
  - {path: "scenes/menus/main_menu/main_menu_with_animations.tscn", change: modify, why: "hero panel, right-column anchors, Primary Play, hidden template title, retargeted/shortened animations, UI sound streams"}
  - {path: "scenes/menus/main_menu/main_menu_with_animations.gd", change: modify, why: "only if hero title needs wiring not expressible in the scene; no behavior change"}
  - {path: "scenes/menus/main_menu/menu_backdrop.gd", change: add, why: "low-contrast drawn arrow motif with slow single-transform drift (FR-014)"}
  - {path: "scenes/menus/main_menu/puzzle_select_menu.gd", change: modify, why: "card grid layout and group accent variations; accessors, order, numbering, toggles, focus unchanged"}
  - {path: "scenes/menus/main_menu/puzzle_select_menu.tscn", change: modify, why: "layout containers for the card grid"}
  - {path: "scenes/overlaid_menus/", change: modify, why: "ink scrim + brand panel for pause overlay; UISoundController while open; R2 fallback theme assignment only if needed"}
  - {path: "scenes/credits/credits.tscn", change: modify, why: "brand typography/colors; remove Godot Engine Logo credit"}
  - {path: "resources/themes/", change: remove, why: "five unreferenced template themes (verified no project references)"}
  - {path: "ATTRIBUTION.md", change: modify, why: "drop engine-logo entry; record original UI sounds and mark-tile derivation"}
  - {path: "tests/app_theme_check.gd", change: add, why: "headless check: every listed control type resolves brand styles from the app theme; palette text pairs meet AA; LevelCard/PrimaryButton variations exist"}
  - {path: "tests/run_puzzle_regressions.py", change: modify, why: "register the new check in the puzzle gate"}
  - {path: ".knowledge/architecture/game-visual-system.md", change: modify, why: "rewrite theme scope, scaling, launch, motion, sound as current truth (FR-018)"}
  - {path: ".knowledge/product/branding.md", change: modify, why: "splash/hero/icon use of the mark; credits content"}
  - {path: ".knowledge/architecture/arrow-puzzle.md", change: modify, why: "Gameplay theme boundary section and template-integration table"}
  - {path: ".knowledge/architecture/web-showcase.md", change: modify, why: "ink boot hand-off and stretch behavior in the browser canvas, if described"}
```

## Constitution Check

*Pre-design and post-design: PASS.*

| Principle | Assessment |
|---|---|
| I. Simple, Maintainable Code | New files use snake_case. The single new abstraction (`control_theme.gd`) splits an otherwise ~300-line vocabulary file. One autoload is justified under Deviations. |
| II. Prefer Project-Level Template Customization | All template changes go through inherited project scenes and exports. No addon edits are planned. If R2's fallback or the loading screen needs an addon change, it is documented then. |
| III. Accessible, Configurable Controls (MUST) | Navigation and remapping code are untouched; Level Select entries remain focusable Buttons; an ember focus style on every control (FR-008). Verification: every menu path with keyboard, gamepad, mouse and touch (SC-005). The touch-slop correction in `puzzle_board.gd` is an input change: it is verified by a headless touch check at a non-1 scale and on the real phone (tap, drag-to-pan, pinch). |
| IV. Responsive Gameplay | No gameplay frame-loop change. The backdrop updates one transform per frame only while menus are visible. Transitions never gate input. |
| V. Practical Gameplay Verification (MUST) | Both gates; editor validation; desktop smoke test at 1280×720, 1920×1080, 2560×1440 and 3840×2160; local web build in Firefox and Chrome; real-phone landscape check. Untested browsers or devices are recorded as not tested. |
| VI. Preserve Saved Progress and Settings (MUST) | No setting keys or saved data are added or changed. The existing Audio/Video/Input options keep their values (FR-017). |

No waivers required.

## Context Resolution

```yaml
context_resolved:
  - id: game-visual-system
    kind: knowledge
    via: direct (lexical: theme, visual, system)
    hop: 0
    reason: authoritative palette/typography/motion vocabulary and the scoped-theme rule this delta reverses; must be rewritten (FR-018)
  - id: product-branding
    kind: knowledge
    via: direct (lexical: branding, menu)
    hop: 0
    reason: identity-then-recede rule, Main Menu tagline, Credits-only creator credit (FR-012)
  - id: arrow-puzzle
    kind: knowledge
    via: direct (appliesTo main menu / puzzle_select_menu)
    hop: 0
    reason: Gameplay theme boundary and template-integration table describe current theme scope and menu wiring that change
  - id: save-progression
    kind: knowledge
    via: direct (heading: Level Select; appliesTo main menu)
    hop: 0
    reason: Level Select and no-reset contracts the card redesign must preserve; settings persistence (FR-017)
  - id: touch-gestures
    kind: knowledge
    via: direct (appliesTo scenes/puzzle/puzzle_board.gd)
    hop: 0
    reason: documents the 32 px touch slop and its real-phone verification; must state that the slop is physical pixels independent of UI scale
  - id: web-showcase
    kind: knowledge
    via: direct (heading: The game in the page)
    hop: 0
    reason: dark loading shell hand-off, play admission thresholds and browser verification set
```

Dropped candidates: progression-design-learning, reference-puzzle-design-report and gameplay-contract (puzzle content, design and rules, all unaffected by this presentation-only delta).

## Project Structure

New directories and files:

- `assets/brand/`
- `assets/ui/`
- `assets/audio/ui/`
- `scenes/loading_screen/`
- `scripts/app_theme.gd`
- `scripts/presentation/control_theme.gd`
- `scenes/menus/main_menu/menu_backdrop.gd`
- `tests/app_theme_check.gd`

Removed:

- `assets/godot_engine_logo/`
- `resources/themes/`

Everything else is modified in place.

Planning bundle: `research.md` (R1–R6) and `qa-acceptance.md`. No `data-model.md`, contracts or quickstart are needed, since there is no data or interface change.

## Complexity Tracking

| Violation / Complexity | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| New autoload `AppTheme` | Theme must reach the template loading screen, which renders before any editable project scene script | Project `gui/theme/custom` needs a saved resource duplicating the code-built theme; theming from Main Menu misses the loading screen; editing `opening.gd` collides with the CI error allow-list |

## Implementation Notes

- 2026-10-16, T001: the probe showed a root-Window theme does not reach Controls under a CanvasLayer (pause overlay, loading screen) in Godot 4.4.1. Merging into `ThemeDB.get_default_theme()` does, and it also reaches popups. `AppTheme` (T006) therefore merges the app theme into the default theme rather than assigning `root.theme`, and T016 needs no per-overlay theme assignment. This is a simpler seam with the same requirement coverage (FR-004, SC-002); no contract changes.
- 2026-10-16, T008: research R1 corrected. The real-project checks (layout, canvas, presentation, app theme) load `[display]` and the `AppTheme` autoload. With stretch enabled, both gates pass with unchanged expectations.
- 2026-10-16, T039/T040: `_touch_slop()` reads the scale from `get_viewport().get_final_transform()` (probe `evidence/probe_stretch_scale.gd`: 2.0 at a 2560×1440 window). A mutation check (fix reverted) makes the new test fail, so the test discriminates.
