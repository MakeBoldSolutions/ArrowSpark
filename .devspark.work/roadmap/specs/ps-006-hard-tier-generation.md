---
id: ps-006
title: Hard-tier level generation
status: proposed
order: 50
depends_on: [ps-005]
delivery: []
---

# ps-006: Hard-tier level generation

## Outcome

The generator can produce large, dense boards in the class of the game's hardest levels, and a pack of
them ships.

## Current Reality

The generator does not reach Reference-Knot-class boards (115 arrows at 0.92 density with six playable
at the start). The densest progression boards needed per-level construction and caps on playable
arrows (`.knowledge/reference/progression-design-learning.md`).

## Scope and Independence

In scope: generation methods that reach an agreed hard-tier profile, and one shipped pack of those
boards.

Out of scope: rule changes, and generation at runtime in the game.

Standalone boundary: with later items canceled, the game has a hard-tier pack and its existing packs
are untouched.

## Future Health

The generator stays developer tooling and measures only through `PuzzleSolver` and `PuzzleAnalyzer`.
Dense boards are where solver and analyzer time grows fastest, so generation and gate time need
measuring as part of the work.

## Dependencies and Decisions

Depends on ps-005 for tuned recipes and a catalog and gates proven at scale. Open question: how close
to the Reference Knot the tier should reach, and how readable boards remain on a phone at that
density.

## Completion Expectations

Generated boards meet the agreed profile and are proven solvable. The owner accepts an agreed sample
after playing it on desktop and phone. Gates still finish within their limits.
