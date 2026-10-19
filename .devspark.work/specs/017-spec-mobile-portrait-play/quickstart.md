---
devspark_version: "9.2.0"
---

# Candidate Verification Quickstart

Repository: `C:/GitHub/MakeBoldSolutions/ArrowGame`.
This procedure supplements ordinary commands with browser sizing and post-deploy owner phone acceptance. It does not publish the product. Record pre-merge evidence under this temporary feature bundle, with deployed-phone evidence grouped under the existing intake obligation, with actual commands, version/build identifiers, screenshots and results; never label a planned step as executed.

## Automated and desktop checks

Use the Godot 4.4-stable pin documented in tests/README.md, not only a newer local editor. Substitute its executable for `<godot>`.

```text
python tests/run_puzzle_regressions.py --godot <godot>
python tests/run_regressions.py --godot <godot>
<godot> --headless --editor --quit
```

Use an isolated copy without .godot for fresh-import validation if the local cache was written by another engine. Tests isolate APPDATA; manual smoke should also use a dedicated test-user directory so personal settings are not reset. Preserve saved remaps while checking pause Options, restart and navigation. Both suites must exit 0 and every failure marker must be 0.

From `C:/GitHub/MakeBoldSolutions/ArrowGame/web`:

```text
npm run check
npm run build
```

Build the actual candidate game from the repository root:

```text
node web/scripts/export-game.mjs --godot <godot>
```

Use the build id printed by that command for PUBLIC_GAME_BUILD; set that environment variable for the Astro process, then build again and run `npm run preview -- --host 0.0.0.0`. Do not reuse an old exported game when evaluating changed scenes. A successful site build without an exported game proves no gameplay result. The ordinary HTTP preview is suitable for localhost desktop; a physical phone must use HTTPS.

The planned `web/scripts/check-portrait-play.mjs` uses the existing browser dependency. Run it after implementation against that candidate preview, following its implemented help/arguments; it must load the real engine, retain iframe identity/src through resizing, capture screenshots and fail on overflow/admission failures. No code-only test can prove a canvas menu's readability: pair browser host measurements with actual scene geometry and rendered screenshots.

## Rendered size and density matrix

1. Record visible top-level sizes 360x640, 390x844 and 412x915 CSS pixels at DPR 1 and a high-density setting (for example 3), using touch capability. Also cover landscape 640x320 and 915x412 and desktop 1280x720 and 1920x1080.
2. Scroll the frame into view with normal page scrolling. Record actual host bar, frame, iframe/canvas, logical viewport and board rectangles. The entire page need not fit without scrolling; the game frame must fit visible height.
3. Check zero horizontal overflow, no sticky header covering gameplay and only Menu/Open Move/Fit on the active game surface.
4. Measure board viewport area / usable game area >=0.75. Measure essential game/menu targets projected to CSS >=44x44 and body/control text >=16. Do not multiply CSS units by DPR twice. Include host fullscreen action in target checks; exclude browser chrome from game-area ratio.
5. Capture Main Menu, one-column Level Select with a long title, all Options tabs, pause/help/nested Options/confirmation, active First Knot and Reference Knot, and Results. Scroll lists and follow keyboard focus to offscreen actions.
6. At desktop sizes, verify wide presentation and no reintroduced zoom/pan toolbar. Verify that legacy result metrics and group navigation are unchanged.

## Owner real-phone acceptance — post-deploy, non-blocking for merge

Owner-ratified SC-003/SC-007 and QA-04/QA-14 remain open as deployed-evidence obligations, grouped under `.devspark.work/intake/future-mobile-ui-scaling-verification-owner-2026-10-17.md`. Reference that record; do not duplicate it. Emulation never counts as device evidence. Deferred real-phone acceptance remains outstanding, not passed.

Use the Pixel 7 Pro in Chrome and record the actual OS/browser version, candidate commit/build and observed visible dimensions. Use the published showcase over HTTPS after deployment. Plain HTTP on the computer's LAN address is insufficient for Godot's loader. Certificate provisioning or exposing a new public service is not assumed; if no secure test origin exists, record its status for the post-deploy check rather than claiming device evidence; it is not a pre-merge blocker. Public product deployment remains outside this spec.

1. Start upright, with browser chrome visible and without fullscreen. Open Play, Main Menu, Level Select and Options. Verify usable text/actions and return paths.
2. Start First Knot. Tap a legal arrow, drag starting over another arrow, pinch, lift fingers in different orders and use Fit. Complete it, review Results, replay, then continue. Ensure Open Move retains the stated cost and requires selecting the suggested arrow.
3. Open Reference Knot, zoom to a comfortable scale and reach all four corners. Test Menu, Resume, Help, nested Options, Restart confirmation and Level Select.
4. Mid-attempt record puzzle id, active arrows, mistakes, assists and session score. Rotate to landscape and back twice, then cause browser chrome to change visible height. Verify the values do not change, Fit remains usable and no delayed arrow selection appears.
5. Interrupt a gesture by opening pause/focus change and by rotation; confirm no stray tap after returning. Explicit cancelled-event regression is additionally automated because reliable browser cancellation cannot always be induced by a finger action.
6. Record the owner's SC-007 acceptance or the concrete remaining friction. Do not recruit additional players or convert missing answers into acceptance.

## Compatibility and evidence classes

Pre-merge acceptance is automated checks, the rendered size/DPR matrix on the real export, Chrome/Firefox smoke and desktop input smoke. Merge may proceed once green; record phone acceptance as deferred rather than passed.

Smoke the actual exported flow in Chrome and Firefox; record other Chromium-derived browsers as individually tested or not tested. Run mouse, physical keyboard and physical gamepad affected menu/input paths, including remapping, focused board zoom/pan/Fit, pause focus restoration and Results navigation. Synthetic input is supplemental, not a claim of hardware testing. Unavailable checks remain outstanding.

Record pre-merge automated/rendered/browser/desktop end-to-end evidence as local-integration or actual preview evidence with the environment named. A preview proves the candidate flow, not the published production target. Do not claim the public showcase was tested unless it was. The separate post-deploy obligation is the project owner's published Pixel scaled-UI/touch check in `C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/intake/future-mobile-ui-scaling-verification-owner-2026-10-17.md`; it needs deployed evidence after publication.
