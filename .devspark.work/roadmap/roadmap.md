# Roadmap: ArrowSpark

## Direction

ArrowSpark has a playable game and settled mechanics. The next stretch turns it into a fuller game
that gives a returning player a reason to come back: a player profile on their own device with
progress and scores that last, and far more levels. Online accounts come later, so that progress does
not wait on choosing an authentication provider.

Outcomes that matter over this horizon:

- A player has a profile with no sign-in, and can leave and return without losing their place or
  their best scores.
- The catalog is large enough to feel like a full game, and stays provably solvable.
- Later, with logins: a player's scores and progress can follow an online account, players can compare
  results, and the project can see how the game is played, under terms stated plainly to players.

The promise that defines the game does not change: you can always keep going, and the only cost of
being wrong is score. Every level remains proven solvable by `PuzzleSolver`.

## Current Baseline

As of `main` at `89c8655` (2026-11-10).

- **Game:** Godot 4.4 and GDScript. Multi-cell bent arrows, Open Move assist, zoom and pan on mouse,
  keyboard, gamepad and touch. The rule core is RefCounted and independent of scenes
  (`scripts/puzzle/`).
- **Levels:** 134 in five difficulty tiers (Getting Started 13, Intermediate 25, Advanced 48, Expert
  47, Master 1), stored as JSON packs (`levels/catalog.json`, `levels/packs/`).
- **Generator:** `PuzzleGenerator` is developer tooling. A depth lever (`depth_bias`) now builds the 100
  generated Intermediate, Advanced and Expert levels from recipes (`levels/recipes/`). It does not yet
  reach Reference Knot density (`.knowledge/reference/progression-design-learning.md`).
- **Scores and profile:** a local player profile (name, finished levels, best results, simple counts)
  persists on the device in `user://` (browser storage on web) and is never sent anywhere. Session
  scoring is unchanged (`scripts/player_profile.gd`, `scripts/puzzle_scoreboard.gd`).
- **Web:** Astro static site with a Godot Web export at https://arrow.makeboldspark.com. The export is
  about 45 MB, of which the engine `.wasm` (43.7 MB) is served uncompressed. Mobile web
  is a beta, played by the owner on one Pixel in portrait and landscape. A rough test on one iPhone
  in portrait (owner report, 2026-11-08) found the game playable; fuller iPhone testing is still to
  come.
- **API:** the only player-facing endpoint is anonymous, write-only reactions, in
  `MakeBoldSolutions/MakeBoldSpark.com` (.NET, `src/MakeBoldSpark.Api/Features/ArrowSparkReactions/`).
  The reaction contract forbids accounts and identifiers. That API already has authentication for
  its admin routes and a database, but no player accounts. The game itself never calls an API; the
  web page does.
- **Public promises today:** the Play page says "No account, no tracking and no visitor ID"
  (`web/src/pages/play.astro`) and describes the local profile.
- **Testing:** the owner has done nearly all the playing. No first-time player has been observed
  finding their way. Regression gates pass in CI, with a
  recurring Godot import crash that passes on re-run. PR previews currently fail on Azure's staging
  environment limit.

## Themes

In priority order.

- **Local player profile (delivered):**
  [ps-001 Local player profile with saved progress](specs/complete/ps-001-local-player-profile.md)
- **Much more levels:**
  [ps-005 First large level pack](specs/ps-005-first-large-level-pack.md),
  [ps-006 Hard-tier level generation](specs/ps-006-hard-tier-generation.md)
- **Reach and confidence:**
  [ps-011 Faster first load of the game](specs/ps-011-faster-first-load.md),
  [ps-007 iPhone Safari](specs/ps-007-iphone-safari.md),
  [ps-010 Easier arrow selection on touch](specs/ps-010-touch-selection.md),
  [ps-008 First outside playtest](specs/ps-008-first-outside-playtest.md),
  [ps-009 Reliable CI and PR previews](specs/ps-009-reliable-ci-previews.md)
- **Online accounts (later):**
  [ps-002 Online player accounts and sign-in](specs/ps-002-player-profiles.md),
  [ps-003 Scores and progress follow the account](specs/ps-003-profile-progress-sync.md),
  [ps-004 Player activity tracking](specs/ps-004-player-activity-tracking.md)

## Decisions

- **2026-11-08: Local player profiles first, online accounts later.** No login in the first profile
  work. Basis: the owner wants to make more progress and delay the authentication provider issues.
  This replaces the profile API part of the "come next" decision below. Storage follows best practice
  (the game's device storage, no cookies), with one profile per device; edge cases such as shared
  devices are left for accounts. Server-side tracking and comparing players also wait for logins.
- **2026-11-08: Build toward a fuller game now.** The owner chose this over an evidence-first
  direction. Basis: the game and mechanics are playable, and tracking, persisted scoring and many
  more levels are what is missing. This is the separate product decision that the gameplay contract
  says durable progression requires. It replaces "saved progress is out of scope" and "do not add
  another scoring or progression system" in the earlier planning notes.
- **2026-11-08: Saved progress and the profile API come next, alongside many more levels.** Owner
  priority.
- **2026-11-08: Outside playtesting waits.** The owner judges the game not ready for it yet.
- **2026-11-08: More iPhone testing comes later.** A rough test found the game playable, and the owner
  will schedule fuller testing later.

- **2026-11-10: First-load speed gets its own item.** Basis: the deployed engine file is 43.7 MB and
  served uncompressed; compressing it is the largest single saving for new players (ps-011).

## Delivered

- ps-001 Local player profile with saved progress: PR #20 and `2eb58a2`, confirmed on the owner's
  Pixel on 2026-11-10 (status: complete).
