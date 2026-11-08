---
id: ps-001
title: Local player profile with saved progress
status: proposed
order: 10
depends_on: []
delivery: []
---

# ps-001: Local player profile with saved progress

## Outcome

A player has a profile with no sign-in: a name, the levels they have finished, their best score on
each, and their own play statistics. It stays on their device. Closing the game or reloading the page
brings them back to where they were.

## Current Reality

Gameplay memory ends with the session by contract (`.knowledge/product/gameplay-contract.md`).
`PuzzleScoreboard` holds best scores in memory. Continue is hidden on the main menu. Settings already
persist through `user://`, which the Web build maps to the browser's own storage. `GameState` and
`LevelState` must stay loadable because existing saves reference them by script path.

## Scope and Independence

In scope: one profile per device, created without an account, persisting completed levels, best scores and simple
statistics (attempts, mistakes, Open Move use) on desktop and web, Continue from the main menu,
completion and best score shown in Level Select, a profile view, a way to reset or delete the profile,
and rewriting the gameplay contract to match.

Out of scope: sign-in, an authentication provider, any network call, several profiles on one device,
leaderboards, and any change to scoring or the rules.

Standalone boundary: with every later item canceled, this is a complete offline feature. Nothing is
sent anywhere, so "No account, no tracking and no visitor ID" stays true, and the Play page's wording
on what the browser keeps is widened to cover the profile.

## Future Health

Key saved scores by stable puzzle id and keep a format version, so ps-003 can later merge a local
profile into an online account, and a changed board cannot leave a best score that no longer means
anything. Do not design a server-style identity into the local profile. Constitution Principle VI
applies: existing saves and settings must keep working. Save writes are not crash-safe today, so a
corrupt profile must follow the existing recovery behavior and not stop the game from starting.

## Dependencies and Decisions

No prerequisites. Decided by the owner on 2026-11-08:

- No login and no authentication provider for this item.
- Storage follows best practice: the game's existing device storage (`user://`, which is browser
  storage on web) and no cookies, so the site's statement that it sets none stays true.
- One profile per device. Shared-device and other edge cases are left for online accounts.

Open questions: what "overall score" means once it no longer resets with the session, and whether an
unfinished board is restored mid-attempt or only the level position.

Known limit to state to players: a local profile lives only in that browser or install. It does not
follow them to another device, and clearing browser data removes it. Safari is known to clear
site-written storage after a period without a visit, so iPhone behavior should be checked and not
assumed.

## Completion Expectations

After a restart on desktop and a reload in a supported browser and on the real phones, the profile,
finished levels and best scores are still there and Continue resumes correctly. Nothing leaves the
device. A pre-existing save loads unchanged. A corrupt profile is recoverable. Required regression
gates and smoke tests pass.
