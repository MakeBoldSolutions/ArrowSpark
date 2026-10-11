---
gate: verify
devspark_version: "unknown"
generated: "2026-10-11T00:00:00Z"
status: pass
blocking: false
summary: "Public mobile-web beta release bar verified: site check and build, emulated desktop/phone/tablet/portrait/small-screen smoke on the PR preview, owner real-phone smoke, green CI. Real-device protocols beyond the smoke are deferred verification by owner decision."
modes:
  - mode: end-to-end
    status: pass
    scope: "Release bar for the beta (owner decision 2026-10-03), not the original full real-device matrix."
    test_ref: "web/tests/play-admission.test.ts::decidePlay"
    evidence: |
      1. Site: `npm run check` 0 errors, 58 tests pass (includes web/tests/play-admission.test.ts); `npm run build` passes, CSP step ok, content check ok.
      2. CI on PR #6 head b3c18e9: Build and Deploy Job pass (after one re-run of a known flaky Godot first-import validation step), Synthetic Check (deployment) pass.
      3. Emulated smoke on the PR preview (Playwright, no page errors in any run):
         desktop 1440x900            -> play, engine started, no beta note
         desktop window 800x500      -> larger-screen notice, game hidden
         phone landscape 915x412     -> play, engine started, beta note, frame 619x348 fits the 412 px height
         phone landscape 568x320     -> larger-screen notice
         phone portrait 411x891      -> rotate notice
         tablet landscape 1180x820   -> play, engine started, beta note
         header position: phone landscape static, desktop sticky (final build).
      4. Owner real-phone smoke (Google Pixel 7 Pro, Android 17, Chrome 154; earlier Edge Beta 155): page loads, game starts, taps work, buttons and Pan usable in the unmodified game (spike records: spike/android-chrome.md).
      5. Desktop behavior: desktop admission boundary unchanged (fine pointer, >= 960x540) and covered by unit tests; the desktop smoke above plays.
      6. Production deployment load check: recorded as a comment on PR #6 after the merge deploys.
      7. Re-run at head 5517bdd (includes modeless touch c140776), 2026-10-11:
         `cd web; npm run check` -> 0 errors, 5 files / 58 tests pass; `npm run build` -> 15 pages, build-csp ok, check-content ok.
         `python tests/run_puzzle_regressions.py --godot godot_console.exe` -> exit 0; PUZZLE_FAILURES=0, ANALYZER=0, CATALOG=0, SCOREBOARD=0, DEPARTURE_GEOMETRY=0, VIEWPORT=0, LAYOUT=0, CANVAS=0, PRESENTATION=0.
         `python tests/run_regressions.py --godot godot_console.exe` -> exit 0 (ERROR lines are the deliberate save/recovery failure-path cases).
         `godot_console.exe --headless --editor --quit` -> exit 0.
         NOT performed: real-device check of modeless touch (tap-on-release, one-finger pan, pinch); no device in this session.
discovered:
  - "Modeless touch (c140776) passes headless gates and the site build but is unverified on a real phone; pinch previously failed on the Pixel."
  - "Flaky CI: the Godot first-import validation step (and the Godot regression job on the throwaway branch) intermittently crashes or prints parse noise on a fresh import; re-running passes. Deferred improvement."
  - "On a landscape phone the game frame sits below the intro text, so the player scrolls down to reach it."
  - "No audio content was found in the repository, so audio start has nothing to unlock."
---

# Verify - Spec 012, mobile web beta release scope

Pass for the beta release bar. The original real-device matrix (iPhone, 20-tap protocol, gesture matrix) is deferred verification and is not claimed.
