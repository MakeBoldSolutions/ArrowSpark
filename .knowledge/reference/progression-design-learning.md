---
id: progression-design-learning
type: authoritative-reference
title: Progression Levels Design Learning
appliesTo:
  - scripts/puzzle/puzzle_catalog.gd
  - tests/puzzle_catalog_check.gd
  - tests/puzzle_analyzer_check.gd
  - tests/puzzle_structural_report.gd
---

# Progression Levels Design Learning

What the eight progression levels (`first_knot` to `almost_a_knot`, between the Foundations and the Reference Knot) show about how levels are built and measured. This is a record of observations, kept so a later generator specification could use them as constraints. It commits to building nothing. Facts are separated from judgments and open questions.

Evidence base: one designer, and the structural tooling (`PuzzleAnalyzer`, `PuzzleSolver`). The designer played all eight levels on desktop and on a phone; their notes are in the last section and are aggregate, not per level. The measured facts below do not depend on them.

## Observed facts: what each level measures

All values come from `python tests/run_puzzle_structural_report.py`, which is descriptive and sets no thresholds. Every level is valid and solvable and has no single-cell arrows.

| Level | Board | Arrows | Density | Initial playable | Dependency depth | Edges | Components | Max unlock fan-out | Bends | Longest / average length |
|---|---|---|---|---|---|---|---|---|---|---|
| `first_knot` | 9x7 | 9 | 0.63 | 3 of 9 | 3 | 8 | 2 | 3 | 10 | 7 / 4.4 |
| `two_neighborhoods` | 15x9 | 15 | 0.59 | 6 of 15 | 4 | 16 | 2 | 3 | 25 | 8 / 5.3 |
| `the_bridge` | 17x9 | 14 | 0.42 | 7 of 14 | 3 | 10 | 4 | 2 | 14 | 12 / 4.6 |
| `false_simplicity` | 14x11 | 17 | 0.59 | 4 of 17 | 5 | 21 | 3 | 2 | 22 | 10 / 5.4 |
| `the_rescan` | 20x12 | 23 | 0.59 | 5 of 23 | 4 | 37 | 1 | 2 | 37 | 11 / 6.2 |
| `major_release` | 22x14 | 30 | 0.47 | 8 of 30 | 6 | 33 | 5 | 5 | 29 | 11 / 4.8 |
| `dense_weave` | 26x16 | 68 | 0.70 | 12 of 68 | 10 | 104 | 5 | 3 | 67 | 16 / 4.3 |
| `almost_a_knot` | 36x24 | 93 | 0.80 | 16 of 93 | 12 | 196 | 5 | 3 | 239 | 32 / 7.4 |
| `reference_knot` (for comparison) | 46x32 | 115 | 0.92 | 6 of 115 | 33 | 661 | 1 | 5 | 207 | 43 / 11.7 |

Per-level structure that was checked directly, beyond the tooling's summary:

- `two_neighborhoods`: the analyzer reports two components because one arrow stands alone; the other fourteen form one web. Counting dependencies by which side of the gutter the head sits on gives eight from the left cluster to the right and three the other way.
- `the_bridge`: the long arrow (12 cells) has two arrows holding up its path and holds up two others. The graph has four components, so the bridge links part of the board, not all of it.
- `major_release`: five parallel arrows are each held up by exactly one arrow, the tall key arrow, which is itself held up by one other arrow. The key arrow is therefore not an opening move. The tooling's single large release (five at once) appears late in its witness order.
- `the_rescan`: one dependency component. Under a simple model of a player who always takes the nearest playable arrow, five moves end with nothing newly freed and the nearest playable arrow six or more cells away.
- `false_simplicity`: the longest forced run (a state with a single legal move) is five, the longest in this set.

## Observed facts: how the levels were found

- Boards are fixed literal data. They were found by a seeded offline search that places arrows in reverse solve order, so each new arrow's path is clear of everything placed before it and every board is solvable by construction. The game's solver then confirmed all eight, including a complete order-independence check along every branch.
- The search needed a different construction for different intents: separate regions for `two_neighborhoods`, a hand-placed long arrow between two clusters for `the_bridge`, five parallel rows plus one crossing arrow for `major_release`, a cap on playable arrows for `false_simplicity` and `the_rescan`.
- Uniform random placement saturates at roughly half to three-fifths of the board, because each late arrow needs a clear path to the edge. Dense boards needed center-outward layering, building the middle first and the outer ring last.
- Keeping few arrows playable at the start conflicts with density. The dense levels needed caps of 12 and 16 playable arrows to reach 70 and 80 percent fill; the Reference Knot has six playable of 115 at 92 percent fill, which this search did not reach.
- Intent claims written from a profile were checked against the data before being kept: several first-draft descriptions overstated the structure (for example, that everything flows through the bridge) and were rewritten to what the tooling shows.

## Designer judgments

- Recorded so far: once a search existed, finding a level for a given profile was cheap; placing dense boards by coordinates is slow, which is why the Reference Knot also grew from a hand-composed skeleton filled out by a seeded search (see its builder comment in the catalog).
- After playing every level on desktop and phone, the designer judged the new boards to be at the right level of difficulty and the progression to be good, and the game play to be what they wanted. This is one person's judgment and was not given level by level.
- Pinch zoom and one-finger drag on the phone raised no issue and were described as fun.

## Open questions

- The jump from `almost_a_knot` to the Reference Knot in structural terms is large: dependency depth 12 to 33, average arrow length 7.4 to 11.7, playable arrows at the start 16 to 6, fill 0.80 to 0.92. The designer reported a good progression overall and did not single out that step, so no cliff was reported; whether the step feels natural to a first-time player is untested.
- Structure is not perceived difficulty. Whether `false_simplicity` looks easier than it is, whether `the_rescan` forces rescans in play, and whether `dense_weave` reads as dense and not as a pile of short arrows, are untested.
- Components, depth and fan-out describe a graph the player never sees. Which of them predict the experience of a level, if any, is open; a single designer is too small an evidence base to say.
- Whether a generator could produce these profiles without the per-level constructions above is untested.

## Playtest notes

Recorded once, in aggregate, after the designer played all eight levels (and the Reference Knot) on a desktop browser and on a phone:

- Game play: good, "just what I wanted".
- Difficulty of the new boards: the right level.
- Progression across the new levels: good.
- Gestures on the phone (pinch zoom, drag): no issue.
- Not noted per level: where the designer searched, where an insight occurred, which releases felt especially good. The structural measures are the only per-level record.
- Not part of the levels, but observed in the same session: the between-level menu and results screens are small and hard to read on a phone, especially in fullscreen.
