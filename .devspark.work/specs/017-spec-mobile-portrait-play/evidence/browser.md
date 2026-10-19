# Real export browser evidence

Local static candidate: http://localhost:4331/play/, PUBLIC_GAME_BUILD=portrait. This is local-integration evidence, not deployed or physical-device evidence.

Actual commands (from repository root):

```text
node web/scripts/check-portrait-play.mjs http://localhost:4331/play/ .devspark.work/specs/017-spec-mobile-portrait-play/evidence/chrome-matrix --chrome
node web/scripts/check-portrait-play.mjs http://localhost:4331/play/ .devspark.work/specs/017-spec-mobile-portrait-play/evidence/firefox-matrix --firefox
node .devspark.work/specs/017-spec-mobile-portrait-play/evidence/browser-journey.mjs
node .devspark.work/specs/017-spec-mobile-portrait-play/evidence/browser-journey.mjs --firefox
```

Both host runs report: `PASS: 10 real-export host fixtures; device gestures and canvas geometry require separate evidence.` The matrices cover 360x640, 390x844 and 412x915 at DPR 1/3, 640x320/915x412 touch and 1280x720/1920x1080 desktop. Each verifies admission, horizontal overflow, gesture containment and iframe identity across resize. Chrome 155.0.8059.80 and Firefox 155.0; exact records/screenshots are in chrome-matrix/host-results.json and firefox-matrix/host-results.json. Other Chromium-derived browsers (Edge, Brave, Opera), Safari and real iPhone remain untested.

The journey drives actual exported game input, two portrait/landscape cycles, a height change, Menu and Escape/Resume. journey.json and firefox-journey.json report unchanged status pixels, retained iframe and no script/page errors. The probe's console text says Chrome in both runs; the Firefox JSON version and explicit --firefox command identify the second engine correctly. This pixel check supplements scene state checks; it does not alone prove every score field or replace phone gestures.

Rendered game geometry: focused-layout.log reports at least 84.4% board area and 90 logical pixels of chrome; Menu/Open Move/Fit sit below the board and meet the target floor at actual iframe widths. menu-matrix.log checks Main Menu, Level Select and every Options tab including scrolling targets. presentation-final.log checks Results values and scroll reachability. Retained PNGs provide visual inspection; older portrait-options.png predates the final panel minimum-size correction and is not final evidence. Final panel geometry is recorded in focused-layout.log and menu-bounds.log.

The recorded real-phone obligation remains outstanding under ../../intake/future-mobile-ui-scaling-verification-owner-2026-10-17.md; no emulated result is claimed as owner acceptance.
