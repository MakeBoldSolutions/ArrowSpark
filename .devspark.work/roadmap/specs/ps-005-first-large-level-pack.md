---
id: ps-005
title: First large level pack
status: proposed
order: 20
depends_on: []
delivery: []
---

# ps-005: First large level pack

## Outcome

The game ships a large new set of levels with a clear rise in difficulty, and finding and browsing
them stays easy at that size.

## Current Reality

There are 34 levels. Packs are JSON and validated by `PuzzlePackFormat`, and
`tests/run_level_pack_build.py` builds reproducible packs from recipes. The generator is untuned and
has produced only four levels of up to 20 arrows, labelled as a sample in the game. Level Select is
an accordion of level cards built for tens of entries. Every level is checked by the regression
gates, and the Reference Knot's order-independence check is already sampled because the full check
exceeds the launcher's time limit.

## Scope and Independence

In scope: generator recipes tuned for defined difficulty bands, one large pack in the catalog, a Level
Select that stays usable at that size on desktop and phone, and regression gates that still finish in
a reasonable time.

Out of scope: boards approaching Reference Knot density (ps-006), new rules, and hand-authoring each
level.

Standalone boundary: with later items canceled, the game has a large, complete level set and a menu
that handles it. Level completion marks arrive with ps-001 and are not required here.

## Future Health

Keep puzzle ids stable and never reuse them, so saved and synced scores stay valid. Decide how the
gates scale before the level count makes CI slow. Packs must remain reproducible from their recipes.

## Dependencies and Decisions

No delivered prerequisites. Open questions for the owner: the target size of this pack; how the new
levels are organized and named; how much of the pack the owner plays before it ships, since the
generator can prove a board solvable but not enjoyable; and whether the current Generated Levels
sample stays.

## Completion Expectations

The pack is in the catalog and every level passes the solver and pack audit. Rebuilding from the
recipe reproduces it exactly. The owner has played an agreed sample and accepts the difficulty rise.
Level Select works at full size on desktop and the real phone, and load times are measured.
