# Research: Mobile Web Play

Two kinds of items: **spike research** (empirical, unanswered by design) and **decisions** that need no device evidence.

## A. FR-001 spike research tasks (unanswered)

Each is answered only by real-device observation; emulation may supplement but never answers.

| # | Question | What to observe | Known starting facts (not answers) |
|---|---|---|---|
| R1 | Does Godot 4.4 Web reliably turn a simple touch into the existing arrow selection? | Taps on removable and blocked arrows at working zoom (≥ 20 distinct removable arrows) and Fit-zoom usability (informational); **explicitly record: whether Godot emits both touch and mouse events for one tap, any premature selection (on press), and any double-fire**; behavior with emulation on/off | `PuzzleBoard._gui_input` handles only mouse events; `InputEventScreenTouch/Drag` are only recognized as non-focus canvas events |
| R2 | Is the 1280 × 720 presentation readable in landscape via capability-conditioned runtime scaling, without changing puzzle geometry? | Reference Knot legibility; label/HUD legibility; **record canvas-to-CSS scale and readable text sizes per device** | Project viewport is 1280 × 720; the web export uses `canvas_resize_policy=2` |
| R3 | Can pinch and touch pan feed `PuzzleViewportTransform` without a second model? | Prototype calling `zoom_at` / `pan_pixels`; zoom bounds respected; no drift; Fit restores | Transform already offers `zoom_at(factor, anchor)`, `pan_pixels(delta)`, `fit_puzzle()` |
| R4 | Does the game behave correctly in the existing same-origin iframe? | Touch reaches game; page does not scroll/zoom/rubber-band; focus; completion message still delivered | iframe has `allow="fullscreen; autoplay"`; shell blocks Safari gesture events and Ctrl/Cmd zoom keys; page guard covers frame chrome only |
| R5 | What is the minimum usable landscape CSS viewport? | Probing at each device's real viewport, with and without browser chrome | Current desktop floor is 960 × 540 |
| R6 | Which controls/layouts block mobile use? | Rendered size of every required control in CSS px vs 44 × 44; clipping/overlap; menu and Results layouts | HelpLabel has a 480 px minimum width; toolbar is an HFlowContainer; HUD is one HBox |
| R7 | What do the browsers actually permit for fullscreen, audio start, gestures, iframe interaction? | Fullscreen API result per browser; audio unlock on first tap; gesture/viewport meta effects; iframe-focus behavior | Page has a Fullscreen button (disabled until ready); first click starts audio on desktop |

## B. Decisions needing no spike

- **D1 Evidence-gated sequencing.** Spike → matrix freeze → implementation. *Why:* every design number (viewport floor, scale, minimum control scale) depends on device facts. *Rejected:* implement then test.
- **D2 Single viewport authority.** All touch gestures call existing `PuzzleViewportTransform` methods; a new transform method is added only if the spike proves a gap, and then to the same class. *Rejected:* a mobile-only transform or gesture layer in UI scenes.
- **D3 Capability-based input.** Touch interactions enabled when touch exists; pointer interactions retained when a fine pointer exists; no whole-UI mode switch on last input. *Rejected:* "desktop mode / touch mode".
- **D4 Admission from the frozen matrix.** The page decides from viewport, orientation and capabilities; `pointer: fine` is no longer the sole signal. *Rejected:* a single capability flag.
- **D5 Target-size rule.** 44 × 44 CSS px for required controls; a miss is a layout problem; exceptions are explicit and evidence-backed. Puzzle cells and arrows are excluded.
- **D6 Orientation scope.** Landscape only; portrait shows the rotate/larger-screen message unless the spike shows portrait is trivial.
- **D7 No new persistence, analytics or device logging.** Admission uses on-page capability checks only. *Rejected:* user-agent sniffing stored or sent anywhere.
- **D8 Governance timing.** Constitution Principle V and `web-showcase.md` change only after the matrix is frozen and verified.
- **D10 Touch selection semantics (owner decision).** Release-time pending-tap; no reliance on touch-to-mouse emulation; desktop mouse press-time behavior unchanged. *Rejected:* press-time touch selection (premature selection on pinch or drag).
- **D11 Scaling.** A capability-conditioned runtime adaptation for admitted touch devices, not a global project stretch setting; desktop scaling and resize unchanged.
- **D12 Helpers.** Touch capability, control-size and scale helpers are static functions on the existing `game_visual_style.gd`; no new script.
- **D9 Regression approach.** Reuse the existing headless pattern (`tests/*_check.gd`) for touch→transform equivalence; Vitest for admission logic; no new test framework.

## C. Spike exit criteria

The spike is finished when every device has a filled Spike Record answering R1–R7 (or marking items "not performed" with reason) and a classification of Supported / Supported with documented limitation / Unsupported in Spec 012.
