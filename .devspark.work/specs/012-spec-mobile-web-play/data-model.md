# Data Model: Mobile Web Play

No runtime persistence is introduced. These are documentation/evidence entities and transient in-memory concepts.

## Spike Record (document, one per device/browser)

| Field | Notes |
|---|---|
| device_model, os_version, browser_and_version | Exact, as reported by the device |
| landscape_css_viewport, device_pixel_ratio | Recorded with and without browser chrome visible |
| build_id | The exact game/site build tested |
| r1..r7 | Observation, evidence (photo/video/log reference), pass/fail/not-performed with reason |
| control_audit | Per required control: rendered CSS px width × height, meets 44 × 44 (yes/no) |
| classification | Supported / Supported with documented limitation / Unsupported in Spec 012 |
| limitations, rationale | Required when not plain Supported |

Rule: a Spike Record may be created only from a real device; emulated runs go in a separate "supplemental" section and cannot set the classification.

## Support Matrix (document, frozen at the checkpoint)

Rows derived 1:1 from Spike Records classified Supported or Supported with documented limitation: device/browser, minimum landscape CSS viewport, input capabilities exercised, limitations. States: `Draft` → `Frozen` (checkpoint) → `Verified` (final real-device verification). Only `Verified` rows feed the constitution and knowledge updates.

## Touch Gesture (transient, in memory in the board)

| Gesture | Resolves to |
|---|---|
| Tap (release-time) | existing cell selection request (`cell_clicked`), on release only |
| One-finger drag, Pan mode on | `pan_pixels` on the viewport transform |
| Two-finger pinch | `zoom_at` about the pinch midpoint on the viewport transform |
| Any gesture cancelled (focus loss, pause, results, visibility) | no selection, no view change |

State: idle → pending-tap → (release: tap) | panning | pinching → idle. A second finger or movement past the threshold cancels pending-tap; emulated mouse events are ignored while a touch sequence owns the board. No gesture state is persisted.

## Capability Profile (transient, page side)

Page side: derived from viewport size, orientation, touch availability and fine-pointer availability. Not stored, not sent, and not reduced to a single "mode" flag. Input to the admission decision (see `contracts/page-admission-contract.md`).

Game side: touch availability is a static query on `game_visual_style.gd` (no stored state, no new entity) used only for sizing, scaling and help text.
