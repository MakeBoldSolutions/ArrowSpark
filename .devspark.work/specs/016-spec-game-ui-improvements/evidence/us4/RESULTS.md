# US4 evidence (2026-10-16, Godot 4.4.1 rendered, isolated user data; motion_sound_check.gd, probe_skip.gd)

## SC-004 / QA-06: timing

| Measure | main | branch |
|---|---|---|
| Splash start → interactive Main Menu, no input | ≈5.4 s (3.0 s splash + 2.4 s intro) | **2.6 s** |
| Menu intro, no input | 2.5 s | 0.9 s |
| Menu intro with accept or click | 0.28 s | 0.28 s (unchanged) |

- Every fade is ≤300 ms with ease-out (transition 0.5): title, tagline, buttons and version label in the intro; a 200 ms sub-menu fade-in; a 200 ms pause scrim and card fade-in.
- Hover and press are instant stylebox states.
- Observation (pre-existing, not a regression): synthetic `ui_cancel`/`ui_accept` releases sent during the splash do not reach the menu within 6 s on **both** main and the branch. A real key-press splash skip is added to the owner's manual walk.

## FR-014: backdrop motif

- Drifts (position changes over 1 s), keeps running behind sub-menus, and is freed with the menu scene. It is drawn once and moved by a single transform.
- Placement deviation: the motif sits in the cream column, not the ink hero. Any arrow lighter than about #212121 behind the ember "Spark" title would push it below 3:1. Over the motif tint, contrast is 6.24 (secondary) and 13.75 (primary), asserted in tests/app_theme_check.gd.

## FR-015 / QA-09: UI sound

- Main Menu controller: 4 players (focus, press, tab, slider release), all on SFX, which sends to Master. Focus sound plays.
- Pause controller: 4 players; focus sound plays.
- HUD button press: silent. After closing pause: silent. Results: silent.
- Volume: the players are on SFX → Master, so the existing SFX and Master volume and mute settings govern them. The spec's "UI volume" is the SFX control; no new control was added.
- Outstanding (owner): listening check of the sound quality on real speakers.
