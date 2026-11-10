---
id: ps-011
title: Faster first load of the game
status: proposed
order: 25
depends_on: []
delivery: []
---

# ps-011: Faster first load of the game

## Outcome

A first-time visitor on a supported desktop or phone sees the game start much sooner and sees honest
progress while it loads. Repeat visits stay fast.

## Current Reality

The Web export is about 45 MB: `index.wasm` is 43.7 MB (the stock Godot engine) and `index.pck` is
1.4 MB. On 2026-11-10 the deployed site served `index.wasm` with no `Content-Encoding`, although gzip
shrinks it to about 9.5 MB locally. The loading card on the Play page shows an indeterminate bar and
the engine download starts only after the admission check. Files under `/game/<build>/` are already
cached immutably for a year.

## Scope and Independence

In scope: serving the engine and game data compressed, real byte progress in the loading card, and
starting the download early on screens that pass admission. A custom smaller engine build is in scope
only if the compressed engine is still too large on a phone.

Out of scope: gameplay, rules, Level Select changes (ps-005), and changes to which screens are admitted.

Standalone boundary: with later items canceled, the game loads faster and behaves as before on every
device admitted today.

## Future Health

Keep the build-unique cache-forever paths and the admission rules. Anything that depends on a Godot
version (a custom engine build) must be reproducible in CI and not block ordinary Godot upgrades.

## Dependencies and Decisions

No prerequisites. Open question: whether Azure Static Web Apps serves pre-compressed files; if not,
the loader decompresses in the browser or a CDN sits in front.

## Completion Expectations

Transferred bytes for the engine and game data are measured before and after on the deployed or preview
site and on the owner's Pixel. Both regression gates and a browser smoke test pass, and repeat visits
still use the cache.
