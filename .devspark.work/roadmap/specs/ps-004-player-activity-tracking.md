---
id: ps-004
title: Player activity tracking
status: proposed
order: 90
depends_on: [ps-002]
delivery: []
---

# ps-004: Player activity tracking

## Outcome

The project can see how the game is played: which levels are started and finished, where players stop
and how often they use Open Move, under terms players have been told about.

## Current Reality

There is no analytics of any kind. Reactions carry the result of a finished attempt in the current
page visit and nothing that links visits. `PuzzleAnalyzer` describes each level's structure, but
nothing connects that to how people play.

## Scope and Independence

In scope: recording a defined, small set of gameplay events, storing them through the API, a way for
the owner to read the results, and telling players what is recorded.

Out of scope: advertising, third-party trackers, and using activity for anything beyond improving the
game.

Standalone boundary: with later items canceled, the owner can answer the defined questions, and the
game plays identically when tracking is off or unreachable.

## Future Health

Record events against stable puzzle ids and board versions so results stay comparable as packs grow.
Do not let tracking add work to the frame loop or make gameplay wait on the network (constitution
Principle IV).

## Dependencies and Decisions

Depends on ps-002 for the identity and privacy terms it relies on. Decided by the owner on 2026-11-08:
server-side tracking comes later, with logins, so signed-out play is not tracked. ps-001's on-device
statistics never leave the player's device. Open questions for the owner: what "user tracking" must
answer, listed as specific questions, and how long raw events are kept.

## Completion Expectations

The owner can answer each defined question from real recorded data. Players can read exactly what is
collected. Gameplay is unaffected when the API is down. Regression gates and smoke tests pass.
