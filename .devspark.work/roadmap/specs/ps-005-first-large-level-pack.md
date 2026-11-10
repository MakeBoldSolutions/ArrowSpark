---
id: ps-005
title: First large level pack
status: active
order: 20
depends_on: []
delivery:
  - "Regroup into five difficulty tiers (80800b7, 4c18abc, e03a7a6)"
  - "PR #21 (757e3f8): generator depth_bias and 45 Advanced levels"
  - "PR #22 (89c8655): 45 Expert and 10 Intermediate levels; the catalog is 134 levels"
---

# ps-005: First large level pack

## Outcome

The game ships a large new set of levels with a clear rise in difficulty, and finding and browsing
them stays easy at that size.

## Current Reality

As of `main` at `89c8655` (2026-11-10): 134 levels in five difficulty tiers (Getting Started 13,
Intermediate 25, Advanced 48, Expert 47, Master 1), stored as JSON packs built reproducibly from
recipes. The 100 new levels (10 Intermediate, 45 Advanced, 45 Expert) are delivered and passed the
gates. Still open: Level Select is an accordion built for tens of entries and has not been examined at
this size on desktop and phone, and load times are not measured. The puzzle gate now takes about 3.5
minutes, with sampling used for generated levels.

## Scope and Independence

In scope: generator recipes tuned for defined difficulty bands, one large pack in the catalog, a Level
Select that stays usable at that size on desktop and phone, and regression gates that still finish in
a reasonable time. Also in scope (owner decision, 2026-11-09): reorganizing every existing level,
including the generated sample, into a graduated player-facing structure so the new levels have a
natural home. The current "breadcrumb" groups (Foundations, Puzzle Lab, ArrowSpark Levels, Generated
Levels) describe how the project was built, not how a player progresses, and are retired.

Out of scope: boards approaching Reference Knot density (ps-006), new rules, and hand-authoring each
level.

Standalone boundary: with later items canceled, the game has a large, complete level set and a menu
that handles it. Level completion marks arrive with ps-001 and are not required here.

## Future Health

Keep puzzle ids stable and never reuse them, so saved and synced scores stay valid. Decide how the
gates scale before the level count makes CI slow. Packs must remain reproducible from their recipes.

## Dependencies and Decisions

No delivered prerequisites. Decided by the owner on 2026-11-09:

- The existing 34 levels are reorganized now, into graduated or themed groups for a playable game.
- The new levels get a natural home in that structure rather than being added as a fifth group.
- The Generated Levels sample is absorbed: all four are good playable examples and are presented in the
  graduated structure, not kept as a labelled sample.

Constraints on the regroup: puzzle ids stay unchanged (saved profiles key best results by id), and
only group membership, order and titles move. Group ids drive group-relative numbering, group-scoped
Next Puzzle and Continue's resume position (`next_in_group`), so a profile's `resume_id` must still
resolve after the move. Moving a level between groups must not mark it unfinished.

Also decided on 2026-11-09: the grouping is option A, difficulty tiers (see Grouping Options), and the
new pack is 100 levels, bringing the catalog to about 134.

Still open: the tier names (Getting Started, Intermediate, Advanced, Expert, Master are working
names); how the 100 are split across tiers (proposal below); and how much of the pack the owner plays
before it ships, since the generator can prove a board solvable but not enjoyable.

## Proposed Split of the 100 New Levels

Owner direction (2026-11-09): there is already plenty at the easy end, so the new levels go to the
top, and the Master tier (more than 100 arrows at near 100% density, the Reference Knot class) is
delayed to ps-006. To make up for it, Advanced and Expert carry more arrows and higher density than
first proposed.

| Tier | New levels | Arrows | Density |
| --- | --- | --- | --- |
| Getting Started | 0 | existing only | existing only |
| Intermediate | 10 | About 8 to 25 | Light to moderate |
| Advanced | 45 | About 25 to 70 | Moderate to high, about 0.5 to 0.8 |
| Expert | 45 | About 70 to 110 | High, about 0.8 to 0.9 |
| Master | 0 here | More than 100 | Near 100%; new levels come from ps-006 |

The arrow and density figures are starting targets, not measurements. They are fixed from
`PuzzleAnalyzer` measurements of the existing levels and then confirmed by the owner playing a sample
from each tier. Expert's upper edge deliberately overlaps Master's arrow count but stays clearly below
its density, so the step into Master is a step in density, not just size. Density is also what the
generator finds hardest, so it is measured per recipe, not assumed.

Master holds only the Reference Knot, the one existing level over 100 arrows, until ps-006 ships. Risk: the generator reaches about 20 arrows and moderate density
today, so Advanced and Expert are now a large tuning effort and the main schedule risk. Fallbacks, in
order: lower the density target before the arrow count; then fewer Expert levels. Not hand-authoring.
Solver, analyzer and gate time grow fastest on large dense boards, so generation and gate time are
measured as each tier lands.

Suggested delivery order so each step ships on its own: regroup the existing 34 first, then add one
tier's levels at a time, easiest first.

## Measured Classification of the Existing 34 Levels

From `python tests/run_puzzle_structural_report.py` on 2026-11-09, approved by the owner. Density is
occupied cells over board area. Dependency depth and the number of arrows playable at the start track
difficulty better than density, so tier bands use them too: depth about 6 to 12 for Advanced, 12 to 25
for Expert, 30 or more for Master (a reading of the table, to be confirmed against recipes).

| Tier | Existing levels |
| --- | --- |
| Getting Started (13) | The 8 Foundations, Warm-Up, long_range_blocker, nested_chain, cascade_key_arrow, bent_network |
| Intermediate (15) | first_knot, gen_sample_02, the_bridge, gen_sample_03, two_neighborhoods, false_simplicity, gen_sample_04, the_rescan, dense_unravel, composed_shaped, knot_single_release, knot_long_geometry, knot_interwoven_paths, knot_regions, knot_dense_core |
| Advanced (3) | knot_boundary, major_release, dense_weave |
| Expert (2) | canvas_validation (52 arrows, depth 25), almost_a_knot (93 arrows, 0.80) |
| Master (1) | reference_knot (115 arrows, 0.92, depth 33) |

The catalog is bottom-heavy: 28 of 34 levels sit in the lower two tiers, which is why the new levels
go to Advanced and Expert. The five large sparse knot boards are placed by structure (easy) with their
size as the challenge; whether they belong higher is for play to decide. canvas_validation was built
as a canvas test and is kept as an Expert level on its structure.

## Grouping Options

Measured today: Foundations are 2 to 10 arrows on boards up to 6 x 6. Puzzle Lab mixes small rule
experiments (2 to 4 arrows) with huge sparse boards (up to 48 x 36, 8 to 52 arrows). ArrowSpark Levels
rise from 9 to 115 arrows. The generated sample runs 6 to 20 arrows. Arrow count alone does not order
them, which is why the old groups feel arbitrary.

- **A. Difficulty tiers (recommended).** Getting Started, Intermediate, Advanced, Expert, Master. Each
  new tier is a clear step; the large pack fills Intermediate through Advanced; the Reference Knot ends
  Master. Easiest to explain and the best match for "graduated". Sketch: Getting Started takes the
  eight Foundations plus Warm-Up and is not extended; Intermediate takes the small Puzzle Lab rule experiments, First Knot,
  Tangle and the early ArrowSpark Levels; Advanced takes Growing Web, Wide Field and the mid-size
  levels; Expert takes Dense Weave, the dense Puzzle Lab boards and the new hard levels; Master takes
  the large knots, Almost a Knot and Reference Knot.
- **B. Themed by skill.** Chains, Blockers, Bends, Dense Boards, Large Boards. Teaches one idea per
  group and suits the named Foundations and Puzzle Lab levels. Weaker for the generated bulk, which has
  no single theme, so it needs a difficulty order inside each group.
- **C. Tiers with chapters.** Option A tiers, each split into small numbered sets (for example
  Intermediate 1 to 4) so a 100-level pack stays browsable and the menu can collapse finished sets.
  Best fit for the Level Select size concern; likely needed once the pack is large.

Recommendation: A for the structure, with C's sets introduced inside a tier only when it grows past
about 20 levels. Difficulty bands come from measurable `PuzzleAnalyzer` values (arrows, density,
playable-at-start), so assignment is repeatable rather than by feel.

## Completion Expectations

The pack is in the catalog and every level passes the solver and pack audit. Rebuilding from the
recipe reproduces it exactly. The owner has played an agreed sample and accepts the difficulty rise.
Level Select works at full size on desktop and the real phone, and Level Select open time is measured. (The size and time of the first game load belong to ps-011.)
