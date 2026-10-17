# Future Work Plan: Verify the scaled game UI on a real phone

**Type**: operational
**Status**: open
**Owner**: project owner
**Required evidence**: `deployed`, meaning a real Pixel 7 Pro (Chrome) against the published showcase
**Carries**: FR-003 phone-surface clause and SC-005 touch-on-phone clause of 016-spec-game-ui-improvements (both `stage: post-deploy`)

## Problem

The game UI now scales with the canvas (canvas_items stretch from 1280×720), and the touch slop was kept at 32 physical pixels. The mobile web beta has not been re-verified on a real phone since this change: menu size, readability, and tap, one-finger drag-to-pan and pinch feel.

## Originating Spec

016-spec-game-ui-improvements (Game UI Improvements).

## Why Not Current Scope

Owner decision (2026-10-17): "approve closing the task for mobile testing, we will address in a future spec, not hold up this one."

## Evidence Already Discovered

- Desktop rendered checks pass at 1280×720 to 3840×2160. The touch slop stays physical at stretch scale 2 (tests/puzzle_canvas_check.gd).
- The Godot Web export renders at device pixel density, so a high-density phone should get larger UI than before. This is unverified on a device.
- Accepted limitation: small low-density touch screens may render the UI smaller; untested and not claimed.
- .knowledge/architecture/web-showcase.md states that the larger phone menus await real-device re-verification.

## Candidate Direction

Run the Pixel 7 Pro in Chrome against the published showcase, compared with the previous build. Check that menus are not smaller and that tap, drag and pinch feel unchanged. Update the web-showcase knowledge with the result.

## Constraints

- Constitution V: the mobile web beta is verified on at least one real phone; emulation never substitutes.
- The device needs HTTPS: Godot's loader refuses non-secure origins.

## Open Questions

Not captured. A Future Work Plan does not authorize further investigation.

## Activation Trigger

After the UI improvements are deployed to the public showcase.

## Provenance

Owner decision recorded in the originating spec's tasks.md Gate Acknowledgements on 2026-10-17.
