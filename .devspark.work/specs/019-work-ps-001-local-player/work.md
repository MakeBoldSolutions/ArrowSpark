# Work: ps-001 Local player profile with saved progress

**Status**: Complete
**Branch**: 019-work-ps-001-local-player

## Intended Outcome

A player has a profile with no sign-in: a name, finished levels, best score per level, and simple
statistics (attempts, mistakes, Open Move use). It stays on the device (`user://`, browser storage on
web, no cookies). Closing the game or reloading the page returns them to where they were.

## Acceptance Evidence

- After a desktop restart and a web reload, the profile, finished levels and best scores persist, and
  Continue on the main menu resumes at the right level.
- Level Select shows completion and best score. A profile view exists, with reset/delete.
- Nothing leaves the device; the Play page wording on what the browser keeps is widened to cover the profile.
- A pre-existing save and settings load unchanged (`GameState`/`LevelState` stay loadable).
- A corrupt profile recovers and never stops the game starting.
- Gameplay contract rewritten to match. Both regression gates, Godot validation, desktop and browser
  smoke tests pass.

## Material Exclusions

Sign-in, any network call, several profiles per device, leaderboards, any change to scoring or rules.

## Operating Assumptions

One profile per device. Scores keyed by stable puzzle id with a format version, so a later online
account (ps-003) can merge a local profile. Safari storage eviction is checked, not assumed.

## Decisions (owner, 2026-11-08)

- **Overall score** = sum of best scores across all finished levels. Scoring formula unchanged.
- **Unfinished board** is not saved. Only level position and completed results persist.
  Basis: keeps saved data small and avoids board-state compatibility problems.
- **Own file, not the settings file:** the profile is `user://player_profile.json`, so a damaged profile
  cannot block settings or legacy saves. An unreadable profile is copied to `.recovery` and replaced,
  with a notice, instead of the startup dialog the settings and legacy-save recovery use.
- **Board changes:** a best result carries the puzzle's content version and is ignored (but kept) when
  the board has changed.

## Verification Evidence (2026-11-08)

Godot 4.4.1 (official release, checksum verified) for gates; 4.4-stable for the web export.

- `run_puzzle_regressions.py`: exit 0, every marker `=0`, including the new `PLAYER_PROFILE_FAILURES=0`.
- `run_regressions.py`: exit 0, `REGRESSION_FAILURES=0` (expected negative-case engine errors only).
- `--headless --editor --quit` on the real project: exit 0, no errors, no files changed.
- `build_knowledge_index.py --check`: exit 0. `check-planning-references`: no finding in touched files
  (eight pre-existing findings in binary assets and `history.json`).
- Site: `npm run check` (0 errors, 59 tests, content ok) and `npm run build` (content ok).
- Desktop rendered smoke (scripted, isolated user data): two separate processes, the second showed
  Continue, "Best 9 of 9" in Level Select, and compared a worse replay against the saved best.
  Screenshots reviewed at 1280x720 and 400x800.
- Web export smoke, automated headless Chrome and Firefox (Playwright), real export served from a
  production site build: name saved, page reload and full browser restart kept it; finished First Knot
  by clicking; after restart Continue appeared, Level Select showed "Best 9 of 9", Continue opened
  "2. Two Neighborhoods". No page errors or console errors.

## Not Verified

- A real phone (Pixel or iPhone): the Profile name field and soft keyboard, and iPhone Safari storage
  eviction, were not tested. The mobile beta statement stays as it was.
- Edge and other Chromium-derived desktop browsers were not tested individually; Chrome and Firefox were.
- The game was driven by scripted input, not played by a person with a real window and mouse.
- The web profile write was not crash-tested (a tab closed mid-write).

## Unresolved Blockers

None.

## Next Useful Action

Commit (including the three new `.uid` files and this directory), then `/devspark-create-pr`.
