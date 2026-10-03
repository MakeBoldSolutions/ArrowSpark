---
gate: closeout
devspark_version: "unknown"
generated: "2026-10-03T20:32:00Z"
status: pass
blocking: false
produced_by: verify
objective: achieved
decision: complete
summary: "Public mobile-web beta released with documented limitations: touch landscape screens can play ArrowSpark in the browser; pinch, small touch targets and iPhone verification are carried forward, not outstanding."
criteria:
  - {id: FR-001, kind: requirement, outcome: deferred, evidence: "Partial real-device answers for one Pixel 7 Pro (spike/android-chrome.md); the full seven-question spike across devices is deferred verification."}
  - {id: FR-002, kind: requirement, outcome: satisfied, evidence: "Beta bar: tap, Fit, zoom buttons, Pan, Back and menus work in the unmodified game on a real Pixel 7 Pro; pinch is a documented limitation."}
  - {id: FR-003, kind: invariant, outcome: satisfied, evidence: "Beta play needs no hover, wheel, middle or right click, keyboard or fullscreen on the Pixel; full screen is optional."}
  - {id: FR-004, kind: invariant, outcome: satisfied, evidence: "No second viewport model shipped; game input code is unchanged."}
  - {id: FR-005, kind: invariant, outcome: satisfied, evidence: "No rule, scoring, puzzle or gameplay-script change; completion hand-off untouched."}
  - {id: FR-006, kind: requirement, outcome: deferred, evidence: "Release-time touch selection is a deferred improvement; selection happens on touch-down (known limitation)."}
  - {id: FR-007, kind: requirement, outcome: deferred, evidence: "44 x 44 CSS px targets and touch scaling deferred; controls are about 17 CSS px tall on the Pixel (known limitation)."}
  - {id: FR-008, kind: requirement, outcome: satisfied, evidence: "Nothing in beta play depends on hover."}
  - {id: FR-009, kind: requirement, outcome: accepted, evidence: "Play page has touch wording; in-game help text still shows desktop wording (known limitation)."}
  - {id: FR-010, kind: requirement, outcome: satisfied, evidence: "web/tests/play-admission.test.ts and emulated smoke: desktop, touch landscape, portrait, small screen, hybrid."}
  - {id: FR-011, kind: requirement, outcome: accepted, evidence: "No page scroll or zoom leakage seen on the one tested device; not verified elsewhere."}
  - {id: FR-012, kind: requirement, outcome: satisfied, evidence: "Admission re-evaluates on resize and orientation change and a loaded game stays loaded (hidden); the owner switched orientation on the Pixel without losing the game."}
  - {id: FR-013, kind: requirement, outcome: accepted, evidence: "No audio content found in the repository; nothing to unlock."}
  - {id: FR-014, kind: invariant, outcome: satisfied, evidence: "Desktop smoke and unit tests: desktop boundary and behavior unchanged; header stays sticky on desktop."}
  - {id: FR-015, kind: requirement, outcome: deferred, evidence: "One short owner real-phone smoke plus emulation; the full checklist on iPhone and more devices is deferred verification."}
  - {id: FR-016, kind: requirement, outcome: satisfied, evidence: ".knowledge/architecture/web-showcase.md and constitution 2.2.0 updated to the proven, honestly limited boundary."}
  - {id: FR-017, kind: requirement, outcome: accepted, evidence: "Admission unit tests added; touch-input and layout-size headless checks deferred with the touch work."}
  - {id: FR-018, kind: requirement, outcome: satisfied, evidence: "Landscape shipped; portrait shows a rotate message."}
  - {id: SC-001, kind: target, outcome: deferred, evidence: "Needs an iPhone and a first-time tester; beta feedback will inform."}
  - {id: SC-002, kind: target, outcome: deferred, evidence: "Full real-device checklist deferred."}
  - {id: SC-003, kind: target, outcome: deferred, evidence: "Working-zoom tap protocol deferred."}
  - {id: SC-004, kind: target, outcome: accepted, evidence: "No leakage observed on the one tested device."}
  - {id: SC-005, kind: target, outcome: deferred, evidence: "Control sizes deferred."}
  - {id: SC-006, kind: invariant, outcome: satisfied, evidence: "Site check and build pass; CI green; desktop unchanged."}
  - {id: SC-007, kind: target, outcome: satisfied, evidence: "Emulated: the rotate and larger-screen notices render immediately with no game download."}
  - {id: SC-008, kind: target, outcome: accepted, evidence: "Orientation change kept the game on the Pixel; not measured across devices."}
findings:
  - {id: CO-001, classification: accepted-limitation, summary: "Pinch zoom does not work on a real phone; one-finger drag pans only in Pan mode; touch targets are small; selection happens on touch-down; fullscreen may be unavailable.", rationale: "Not a failure of the beta objective (a usable mobile-web beta); hits no expansion trigger because the release bar explicitly allows these.", accepted_by: "owner, 2026-10-03 release posture"}
  - {id: CO-002, classification: accepted-limitation, summary: "iPhone Safari is admitted by capability but not verified on a real device.", rationale: "Owner chose a beta over certification; the knowledge doc and release notes make no iPhone claim.", accepted_by: "owner, 2026-10-03 release posture"}
  - {id: CO-003, classification: deferred-work, summary: "Touch scaling and 44 x 44 px controls, release-time selection, pinch and one-finger pan, in-game touch help.", rationale: "Improvements, not objective failures.", captured_as: "branch 012-spike-touch-prototype (pinch prototype) and the Release Posture section of tasks.md; to be prioritized from beta feedback"}
  - {id: CO-004, classification: deferred-work, summary: "Flaky Godot first-import validation in CI.", rationale: "Pre-existing, intermittent, passes on re-run; not caused by this change.", captured_as: "discovered list in gates/verify.md (no work item yet)"}
  - {id: CO-005, classification: learning, summary: "The engine already turns touch into the existing click path, so a usable beta needed only an admission change, not new input code.", rationale: "Changed the plan from building a touch layer to shipping a gate change.", original_expectation: "Touch input would need new handling in the board before phones could play.", revised_understanding: "Taps, buttons and Pan work through the engine's touch-to-mouse step; only pinch and ergonomics need new work."}
regression_gates:
  - "web/tests/play-admission.test.ts (admission boundary, hybrid, portrait, small screens)"
  - "npm run check and npm run build in web/ (site, CSP, content)"
  - "tests/run_regressions.py and tests/run_puzzle_regressions.py via CI (game unchanged)"
unclassified: []
---

# Closeout - Spec 012

Objective: ACHIEVED (public mobile-web beta). Blocking defects: 0. Accepted limitations: 2. Deferred work: 2. Changed assumptions: 1. Unclassified findings: 0. Regression gates: GREEN.

CLOSEOUT: READY. Public mobile-web beta released with documented limitations; the deferred items are carried forward, not outstanding.
