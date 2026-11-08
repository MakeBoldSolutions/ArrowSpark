---
id: ps-003
title: Scores and progress follow the account
status: proposed
order: 80
depends_on: [ps-001, ps-002]
delivery: []
---

# ps-003: Scores and progress follow the account

## Outcome

A signed-in player's completed levels and best scores are stored against their account and appear on
any device where they sign in.

## Current Reality

After ps-001 and ps-002, progress lives in a local profile and accounts hold no game data. Scores are computed
locally, so the client is the only source of a score.

## Scope and Independence

In scope: saving progress and best scores to the API, loading them at sign-in, a defined merge when
local progress and profile progress differ, and playing offline when the API is unreachable.

Out of scope: leaderboards, comparing players, and activity tracking.

Standalone boundary: with later items canceled, signed-in players have working cross-device progress
and signed-out players keep local progress.

## Future Health

Merge must never lower a best score or lose progress. Store which version of a board a score belongs
to. Because the client computes scores, stored scores can be faked; that is acceptable for private
progress and must be reconsidered before any leaderboard.

## Dependencies and Decisions

Requires ps-001 and ps-002. Open question: whether signing in for the first time offers to import
this device's progress or does so automatically.

## Completion Expectations

Progress made on one device appears on another after sign-in. An interrupted or failed save loses
nothing and does not block play. Deleting a profile deletes its progress. Regression gates, API tests
and browser and phone smoke tests pass.
