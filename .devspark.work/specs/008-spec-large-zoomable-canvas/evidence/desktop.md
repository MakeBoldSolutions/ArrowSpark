# Desktop scenarios (T030) — OPERATOR SIGN-OFF WITH DISCLOSED GAPS

Status: **closed by operator decision on 2026-09-28** after mouse-focused passes. The operator reviewed the results below and asked to complete the spec; scenarios marked partial/outstanding were not exercised and are accepted as such, not passed. Gamepad remains outstanding.

## Operator report, 2026-09-28 (informal, Windows 11, mouse mostly, some keyboard; window sizes not stated)
- Level 15 is described as a game changer, close to the intended look.
- Gameplay still good; scaling, zoom in/out, Fit and Pan work as expected.
- Selecting while zoomed worked.
- A bit of keyboard use, mostly mouse; no keyboard problems reported.
- The level 15 long departure was very satisfying, the intended feel.
- Resize worked well; zoom in/out/pan described as a nice feature.
- Second pass on the revised 52-arrow level 15: difficulty about medium-hard; looks exactly as intended; readability great; zoom works well; chain reactions and clear-out loved; Show Me works great.
- Requested change: blocked-arrow feedback should be brighter red and stay longer. Implemented (red #E8221A, 600 ms hold) and relaunched; operator then asked to wrap up without a further explicit re-test note.
- Follow-up: zoom in and mouse wheel worked; Show Me an Open Move moved the view to the selected arrow (Open Move reveal).

Status: The physical mouse, keyboard, gamepad, remap-through-settings and interactive resize scenarios in quickstart.md must be performed by the operator on Windows 11 with mouse and keyboard. Headless suite output never satisfies them and nothing below the "agent-run" section is an operator result.

outstanding: gamepad — no gamepad was used; every gamepad scenario (left stick pan, shoulders zoom, Y fit, D-pad focus exits, gamepad remap) remains outstanding. Only event-dispatch tests exist for them.

## Agent-run rendered checks (real renderer, synthetic input) — informational only
Run with `tests/puzzle_canvas_visual_check.gd` and an ad hoc capture script on this Windows 11 workstation (AMD Ryzen 9 7900X / AMD Radeon integrated graphics, OpenGL 3):
- Rendered overview / 64 px / 192 px captures, 1280x720: readable, smooth edges (evidence/overview.png, working_scale.png, maximum_zoom.png, dense_working_scale.png).
- Navigation cost and frame time within budget on 4.4 and 4.7.2 (evidence/performance.md).
- Fifteen-entry Level Select rendered at 1280x720, 960x540 and 800x800: at 960x540 the list first overflowed the window (first and last entries clipped); fixed with a focus-following ScrollContainer; the last entry focused at 960x540 is fully visible (evidence/level_select_960x540_last_focused.png). The 800x800 and 1280x720 lists fit without scrolling.
- The first size assignment of a scripted run can be overridden by the window's initialization; the screenshots above were re-taken with the intended size confirmed.

## Scenarios the operator still records (window sizes 960x540, 1280x720, 800x800, 1920x1080)
Mark each Pass / Fail with observations and device.

| # | Scenario | Result |
|---|---|---|
| 1 | Initial fit with 16 px margin; toolbar/HUD/help readable; original small puzzles playable immediately | pass (operator: gameplay still good; window sizes not stated) |
| 2 | Wheel zoom about a recognizable point; both bounds; middle drag; Pan-mode primary drag; fit; all four corners at 64 px/cell; Pan-mode gestures never remove arrows or change counters (including outside release and focus loss) | pass for zoom, bounds, Fit, Pan (operator); corner reach and Pan-mode no-selection not explicitly reported |
| 3 | Head/tail selection after zoom/pan; blocked arrow keeps feedback and penalty; stationary-pointer hover updates when the view moves | partial: selection while zoomed pass (operator); blocked feedback and hover not explicitly reported |
| 4 | Tab to board; WASD pan, Equal/Minus zoom, F fit; Tab back to toolbar/Open Move; remap a zoom action in settings, check behavior/help and reset-default; (gamepad: outstanding) | partial: some keyboard use, no issues reported; remap and help-line refresh not reported; gamepad outstanding |
| 5 | Open Move off-screen / already visible / long shape / during departure / after invalid-area recovery: head visible at readable scale, one assist, no removal | pass for off-screen reveal on the revised level (operator, twice); other sub-cases covered by automated tests only. Earlier note: Open Move moved the view to the selected arrow (operator); assist count, already-visible, during-departure cases not explicitly reported |
| 6 | Long bent arrow departure with zoom, pan, resize, pause/resume; results once; score/best/overall; Replay and Next reset the view | partial: long departure on level 15 satisfying (operator); pause, zoom-during-departure, results/Replay/Next not explicitly reported |
| 7 | Resize manual vs fit views; minimize/restore; no stale drag; overlays and focus loss reject canvas actions | partial: resize worked well (operator); fit-vs-manual detail, minimize/restore, overlays not explicitly reported |
| 8 | Ordinary play on original small puzzles: feel, hover, feedback, fit, completion, replay | outstanding |
| 9 | Fifteen-entry puzzle select menu at 960x540 and 800x800 (mouse wheel/scroll and keyboard focus) | outstanding (rendered agent check and automated reachability test only) |
