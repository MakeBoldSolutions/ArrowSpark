---
devspark_version: "9.2.0"
---

# Portrait UI and Input Contract

This changes the user interface; no network API, completion payload, persisted settings or domain model changes.

## Host boundary

- Fine-pointer desktop admission: existing 960x540 CSS floor.
- Touch portrait admission: 360x640 visible CSS floor. Touch landscape: existing 640x320 floor. A hybrid may qualify through either path.
- A subminimum transient may hide the existing game; it never replaces the loaded iframe or changes src. Returning to an admitted size resumes the same running state.
- Touch host fits the visible height using 100dvh, with safe-area/border-box padding, grid auto bar and remaining-height stage. No fixed 16:9 stage on touch. Scrolling the page can align the full frame; content before/after it remains scrollable.
- Touch header scrolls away in both orientations. Touch inside the stage is reserved for game gestures; stage and shell keep touch-action: none and overscroll-behavior: none to prevent pull-to-refresh/scroll chaining. Outside-page browser zoom remains available.
- Fullscreen is optional and targets the safe-area-aware host. Its host action is not part of the game's persistent action count.

## CSS/logical/physical units

- Touch-web logical content dimensions match the actual iframe CSS dimensions, independently of DPR; target and text measurements are in effective CSS pixels.
- Existing theme target height 48 remains >=44 after projection; essential width >=44; body/control text >=16.
- The top-level size matrix is not the iframe size: measure actual frame, canvas, logical scene and projected controls.
- Keep touch slop at 32 physical pixels using the existing final-transform conversion; do not reinterpret it as 32 CSS pixels.
- Board area fraction = interactive board viewport rectangle area / usable game canvas area. Denominator includes HUD/actions/margins and excludes browser chrome/safe areas outside game. Requirement >=0.75 in portrait without a menu.

Emulation never counts as device evidence. Deferred real-phone acceptance remains outstanding, not passed. See spec.md Verification Staging.

## Active surface

Exactly the following action roles are allowed, at most three persistent controls: Menu, Open Move, Fit Puzzle. In portrait touch these actions sit in a bottom strip within safe-area insets for one-handed reach; passive status stays at top. Landscape/desktop retain the header. The strip counts toward usable game area and the 112-unit chrome budget; the 75% ratio is unchanged. Compact visible labels are allowed with meaningful accessible names. Remaining/mistakes status is passive. Full level title and detailed help may live in Menu. No persistent Zoom In, Zoom Out, Pan or separate Back action.

Menu opens the same pause flow as cancel input. Resume retains the attempt. Restart retains confirmation/fresh-attempt behavior. Level Select/Main Menu are deliberate scene navigation and preserve session scoreboard/settings, not an implicit save of the current attempt. Nested Options closes back to the paused menu, not unpaused board input. Menu cannot duplicate itself or open under Results.

## Direct input

- Tap acts once on release through current rules.
- One-finger drag pans; two-finger pinch zooms and pans; neither selects or changes score.
- Cancellation, resize, focus loss, pause and interrupted pinch discard pending taps; remaining contacts cannot produce a delayed selection.
- Mouse wheel/middle-drag remain. Single-button Pan toggle is provided through menu help rather than permanent toolbar; left-drag on an arrow still selects (FR-011 pending owner confirmation).
- Keyboard/gamepad canvas actions and remapping remain. Focus follows visual order: portrait board -> Menu -> Open Move -> Fit -> board; landscape/desktop Menu -> Open Move -> Fit -> board; overlays capture and restore focus and scrolling follows focused menu content.

## Menus and transitions

Main Menu stacks in compact width; Level Select uses one fitting card column where two do not fit; Options and dialogs wrap/scroll; Results stacks actions. No horizontal scrolling or clipped essential actions. Reflow changes presentation only: no board setup, rule mutation, new score record or settings reset on resize.

## Invariants

Keep puzzle ids/content versions/geometry, legal moves, departures, Open Move cost, results metrics, group progression and session-memory boundary. Keep game-to-host completion contract unchanged. Physical evidence must be labeled separately from emulation; untested devices receive no new support claim.
