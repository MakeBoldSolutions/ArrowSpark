# Spike notes

One Spike Record per real device (copies of `contracts/spike-record-template.md`):
`iphone-safari.md`, `android-chrome.md`, and optionally `ipad-safari-optional.md`.
Emulated runs go in a "supplemental" section only and never set a classification.

Open the spike build at `<site>/play/?spike` (spike mode admits any viewport and shows the
probe overlay inside the game; it is removed or inert for production by T040).

Known baseline facts to confirm or refute on the devices (not answers):
- `web/game-shell/shell.css` already sets `touch-action: none` on `body`; the shell also blocks Safari `gesture*` events.
- The probe overlay counts browser-level touch/pointer/mouse events only; whether Godot itself emits both a touch and a mouse event for one tap is observed in the T010 prototype.
