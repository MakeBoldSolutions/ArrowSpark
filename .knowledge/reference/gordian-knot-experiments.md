---
id: gordian-knot-experiments
type: authoritative-reference
title: Gordian Knot Experiments
appliesTo:
  - scripts/puzzle/puzzle_catalog.gd
  - tests/puzzle_catalog_check.gd
  - tests/puzzle_structural_report.gd
  - tests/run_puzzle_structural_report.py
---

# Gordian Knot Experiments

Six hand-authored puzzles follow the original fifteen catalog entries. `canvas_validation` remains a prior canvas validation puzzle and is not one of these experiments. Objective facts come from `PuzzleAnalyzer` and `PuzzleSolver`; personal observations require an actual completed human session. No single structural measure decides puzzle quality.

Measured against the authored catalog Git object `cc30ad4a41e2c6a4919603c0bcf41e63e900ef7b` with Godot 4.7.2. The project targets Godot 4.4, and the same catalog was re-run under Godot 4.4.1: both regression launchers passed and the reported witnesses were identical.

Source of truth: `scripts/puzzle/puzzle_catalog.gd`, `tests/puzzle_catalog_check.gd`, and `tests/puzzle_structural_report.gd`. Human evidence is one aggregate author play session across all six puzzles; per-puzzle detail was not recorded and is marked unknown.

Each session record must identify the final puzzle geometry/build, date and author/reviewer role, completion, perceived challenge, tracing demand, removal satisfaction, a particular removal's visible simplification, assistance count, mistakes and final score/accuracy, actual zoom/pan/fit use and usefulness, arrow readability, overall qualitative verdict, and author familiarity/play order. Write zero when the count is zero and unknown when evidence is unavailable. Do not turn an unplayed puzzle into an inconclusive verdict.

## Long Geometry (`knot_long_geometry`)

**Purpose and pre-play hypothesis:** Long bent paths may make removals satisfying even without substantial interweaving.

### Measurements

Godot 4.7.2 structural report (the project targets Godot 4.4). The complete ordered witness is an objective solver result, not a record of human play.

```text
status: valid=true solvable=true
board: 32x24  density=0.17  arrows=8 occupied=128
geometry: single=4 multi=4 bends_total=8 max_bends=2 max_length=39 avg_length=16.00
legal: initial=6/8 (0.75) forced=2 branching=6 longest_forced_run=2
legal_choice_sequence: 6,6,5,4,3,2,1,1
dependency: edges=2 depth=1 max_in_degree=1 components=6
cascade: max_unlock_fan_out=1 unlock_sequence: 1,0,0,0,0,0,1,0
blocker_distance: max=2 avg=2.00
witness_xy: 4,0;8,0;4,2;3,10;28,15;25,23;27,23;27,21
```

### Observed in this session

Recorded as one aggregate author play session across the six puzzles, with session-level conclusions only. Per-puzzle completion, mistakes, score/accuracy, assistance count, and zoom/pan/fit use were **not recorded** for this puzzle; they are unknown, not zero.

**Observed human reaction (aggregate):** Long and bent geometry gave a reasoning challenge while tracing and visible satisfaction when substantial geometry was removed.

### Interpretation

**Verdict for this session only:** Supported (aggregate session; not attributed to this puzzle alone).

**Design inference (hypothesis, not a rule):** Long bent removals are a worthwhile ingredient even when interweaving is light. With only two dependency edges, the reasoning here is mostly tracing one arrow's path, not chaining consequences.

Limits: one author, one session, familiar with the design, play order not recorded. The objective measurements above are facts; this section is not.

## Interwoven Paths (`knot_interwoven_paths`)

**Purpose and pre-play hypothesis:** Nearby disjoint winding paths may increase tracing demand.

### Measurements

Godot 4.7.2 structural report (the project targets Godot 4.4). The complete ordered witness is an objective solver result, not a record of human play.

```text
status: valid=true solvable=true
board: 32x24  density=0.18  arrows=8 occupied=138
geometry: single=5 multi=3 bends_total=11 max_bends=4 max_length=51 avg_length=17.25
legal: initial=3/8 (0.38) forced=3 branching=5 longest_forced_run=2
legal_choice_sequence: 3,3,3,2,1,1,2,1
dependency: edges=9 depth=2 max_in_degree=3 components=1
cascade: max_unlock_fan_out=2 unlock_sequence: 1,1,0,0,1,2,0,0
blocker_distance: max=20 avg=8.00
witness_xy: 3,0;28,0;3,2;28,3;16,23;16,22;0,10;31,12
```

### Observed in this session

Recorded as one aggregate author play session across the six puzzles, with session-level conclusions only. Per-puzzle completion, mistakes, score/accuracy, assistance count, and zoom/pan/fit use were **not recorded** for this puzzle; they are unknown, not zero.

**Observed human reaction (aggregate):** Interwoven paths and tail-based dependencies were among the sources of meaningful density and of reasoning challenge.

### Interpretation

**Verdict for this session only:** Supported (aggregate session; not attributed to this puzzle alone).

**Design inference (hypothesis, not a rule):** Interweaving and tail-based blockers make tracing matter. A long blocker distance (max 20) is only interesting where discovering it needed real spatial reasoning; the distance value alone says nothing about that.

Limits: one author, one session, familiar with the design, play order not recorded. The objective measurements above are facts; this section is not.

## Dense Core (`knot_dense_core`)

**Purpose and pre-play hypothesis:** Concentrated adjacent geometry may create satisfying challenge while remaining readable.

### Measurements

Godot 4.7.2 structural report (the project targets Godot 4.4). The complete ordered witness is an objective solver result, not a record of human play.

```text
status: valid=true solvable=true
board: 36x28  density=0.12  arrows=16 occupied=120
geometry: single=8 multi=8 bends_total=16 max_bends=2 max_length=14 avg_length=7.50
legal: initial=9/16 (0.56) forced=4 branching=12 longest_forced_run=4
legal_choice_sequence: 9,9,9,9,9,8,7,6,5,4,3,2,1,1,1,1
dependency: edges=10 depth=3 max_in_degree=3 components=9
cascade: max_unlock_fan_out=1 unlock_sequence: 1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,0
blocker_distance: max=12 avg=4.80
witness_xy: 10,6;14,6;18,6;22,6;10,8;12,8;14,8;16,8;18,8;20,8;22,8;24,8;13,18;17,18;21,18;25,18
```

### Observed in this session

Recorded as one aggregate author play session across the six puzzles, with session-level conclusions only. Per-puzzle completion, mistakes, score/accuracy, assistance count, and zoom/pan/fit use were **not recorded** for this puzzle; they are unknown, not zero.

**Observed human reaction (aggregate):** Nothing specific to this puzzle was recorded. The session did conclude that a busy board of short arrows can be tedious, and that density is promising when it comes from substantial geometry.

### Interpretation

**Verdict for this session only:** Inconclusive. The recorded evidence does not say whether this puzzle's density read as meaningful or merely busy.

**Design inference (hypothesis, not a rule):** This puzzle has 16 short arrows (average length 7.5) at density 0.12, so it is a candidate for the busy-but-shallow pattern. That is an inference and was not observed.

Limits: one author, one session, familiar with the design, play order not recorded. The objective measurements above are facts; this section is not.

## Distinct Regions (`knot_regions`)

**Purpose and pre-play hypothesis:** Separated regions may make a large puzzle more approachable.

### Measurements

Godot 4.7.2 structural report (the project targets Godot 4.4). The complete ordered witness is an objective solver result, not a record of human play.

```text
status: valid=true solvable=true
board: 48x32  density=0.08  arrows=13 occupied=123
geometry: single=9 multi=4 bends_total=8 max_bends=2 max_length=30 avg_length=9.46
legal: initial=8/13 (0.62) forced=1 branching=12 longest_forced_run=1
legal_choice_sequence: 8,7,6,6,6,6,5,4,3,3,3,2,1
dependency: edges=10 depth=2 max_in_degree=3 components=6
cascade: max_unlock_fan_out=1 unlock_sequence: 0,0,1,1,1,0,0,0,1,1,0,0,0
blocker_distance: max=29 avg=12.90
witness_xy: 8,0;34,0;3,2;29,2;4,8;30,8;0,9;5,29;30,29;39,23;12,23;9,31;34,31
```

### Observed in this session

Recorded as one aggregate author play session across the six puzzles, with session-level conclusions only. Per-puzzle completion, mistakes, score/accuracy, assistance count, and zoom/pan/fit use were **not recorded** for this puzzle; they are unknown, not zero.

**Observed human reaction (aggregate):** Regional structure was judged a promising direction: a region can be substantially progressed locally but not always finished locally, because a remaining arrow may depend on geometry from another region.

### Interpretation

**Verdict for this session only:** Inconclusive for the stated hypothesis (approachability), because approachability was not recorded. The regional idea itself is supported as a direction worth pursuing.

**Design inference (hypothesis, not a rule):** Local versus global reasoning and cross-neighborhood aha moments are design hypotheses drawn from the session. This puzzle's sparse inter-region dependencies are a starting point, not a model.

Limits: one author, one session, familiar with the design, play order not recorded. The objective measurements above are facts; this section is not.

## Single Release (`knot_single_release`)

**Purpose and pre-play hypothesis:** Removing one prominent long arrow may visibly simplify the board.

### Measurements

Godot 4.7.2 structural report (the project targets Godot 4.4). The complete ordered witness is an objective solver result, not a record of human play.

```text
status: valid=true solvable=true
board: 40x30  density=0.09  arrows=8 occupied=108
geometry: single=7 multi=1 bends_total=4 max_bends=4 max_length=101 avg_length=13.50
legal: initial=3/8 (0.38) forced=1 branching=7 longest_forced_run=1
legal_choice_sequence: 3,3,3,5,4,3,2,1
dependency: edges=6 depth=3 max_in_degree=2 components=3
cascade: max_unlock_fan_out=3 unlock_sequence: 1,1,3,0,0,0,0,0
blocker_distance: max=10 avg=3.50
witness_xy: 0,20;1,20;2,20;24,8;25,15;8,22;14,28;0,29
```

### Observed in this session

Recorded as one aggregate author play session across the six puzzles, with session-level conclusions only. Per-puzzle completion, mistakes, score/accuracy, assistance count, and zoom/pan/fit use were **not recorded** for this puzzle; they are unknown, not zero.

**Observed human reaction (aggregate):** Removing substantial geometry produced visual payoff, and a release that unlocks several follow-ups supported anticipating multiple moves.

### Interpretation

**Verdict for this session only:** Supported (aggregate session; the specific arrow and its effect were not recorded).

**Design inference (hypothesis, not a rule):** One release can visibly change the board. A long arrow that unlocks a chain is closer to an insight chain than a lone legal move.

Limits: one author, one session, familiar with the design, play order not recorded. The objective measurements above are facts; this section is not.

## Boundary Knot (`knot_boundary`)

**Purpose and pre-play hypothesis:** Excessive winding may become tedious or unreadable despite remaining completable.

### Measurements

Godot 4.7.2 structural report (the project targets Godot 4.4). The complete ordered witness is an objective solver result, not a record of human play.

```text
status: valid=true solvable=true
board: 48x36  density=0.29  arrows=28 occupied=508
geometry: single=12 multi=16 bends_total=32 max_bends=2 max_length=35 avg_length=18.14
legal: initial=6/28 (0.21) forced=2 branching=26 longest_forced_run=2
legal_choice_sequence: 6,6,6,7,9,8,8,8,8,7,6,6,5,5,5,5,4,4,5,4,4,4,4,3,2,2,1,1
dependency: edges=51 depth=6 max_in_degree=5 components=2
cascade: max_unlock_fan_out=3 unlock_sequence: 1,1,2,3,0,1,1,1,0,0,1,0,1,1,1,0,1,2,0,1,1,1,0,0,1,0,1,0
blocker_distance: max=25 avg=9.22
witness_xy: 3,0;25,0;3,2;25,2;0,4;5,8;27,8;45,8;22,8;5,10;27,10;47,12;3,16;25,16;45,16;23,16;3,18;25,18;0,20;5,24;27,24;45,24;22,24;5,26;27,26;47,28;45,32;23,32
```

### Observed in this session

Recorded as one aggregate author play session across the six puzzles, with session-level conclusions only. Per-puzzle completion, mistakes, score/accuracy, assistance count, and zoom/pan/fit use were **not recorded** for this puzzle; they are unknown, not zero.

**Observed human reaction (aggregate):** The session concluded that structural complexity can coexist with a poor experience and that busy boards can tire the player. It was not recorded which puzzle showed this.

### Interpretation

**Verdict for this session only:** Inconclusive. The evidence is consistent with the tedium hypothesis but is not attributable to this puzzle.

**Design inference (hypothesis, not a rule):** At 28 arrows and 51 dependency edges this puzzle is completable per the solver. Whether it crosses the spaghetti boundary is not established by these notes.

Limits: one author, one session, familiar with the design, play order not recorded. The objective measurements above are facts; this section is not.

## Cross-experiment synthesis

**Bottom line:** the six experiments produced a vocabulary and a toolbox, not a recipe for a perfect level. No experiment is the definitive ArrowSpark level, and none was designed to be. What remains unproven is whether these tools can be composed into one excellent complete level.

**Evidence basis:** one aggregate author play session, informed by the objective measurements above. These are design hypotheses, not validated game-design laws. Author familiarity, play order and single-session effects limit every claim. No difficulty score, entanglement score or generator recommendation follows from this.

### Design vocabulary

These are terms for design discussion, not gameplay rules or analyzer metrics.

- **Meaningful Density:** density created by substantial arrow geometry, not by filling the board with trivial arrows.
- **Neighborhood:** a recognizable area where meaningful local progress can be made.
- **Cross-Neighborhood Dependency:** finishing an area requires understanding or removing geometry associated with another area.
- **Bridge Arrow:** a substantial arrow whose geometry or dependencies connect otherwise recognizable neighborhoods.
- **Insight Chain:** a short sequence of upcoming consequences that becomes understandable together after a discovery ("this comes out, which frees that, which lets me pull that").
- **Discovery Beat:** uncertainty, investigation, discovery, a short insight chain, execution, visible payoff, a changed board, then renewed uncertainty.

### Findings by topic

- **Density versus meaningful density:** structural complexity can still give a poor experience. Raw occupancy density, or a grid of many short or single-cell arrows, produced a visually busy but tedious feel. Density looks more promising when it comes from long paths, bends, interwoven paths, tail-based dependencies, long blocker relationships and cross-region relationships.
- **Arrow count versus arrow geometry:** more arrows did not mean more interesting play. Geometry mattered more than count. `knot_dense_core` (16 arrows, average length 7.5) and `knot_long_geometry` (8 arrows, average length 16.0) show the contrast in measurements, though the recorded reaction is aggregate.
- **Single-cell-arrow-heavy play:** tedious when it dominates. Single-cell arrows are cheap to remove and give no reasoning payoff.
- **Arrow length and bends:** long and bent geometry created reasoning challenge while tracing and visual satisfaction on removal.
- **Blocker distance:** descriptive, not inherently valuable. A long blocker relationship only matters if finding and understanding it needs meaningful tracing or spatial reasoning.
- **Tail-based dependencies and interweaving:** promising sources of tracing demand and of meaningful density.
- **Regional and neighborhood structure:** worth further investigation. A promising shape is a region that can be substantially progressed locally but not necessarily completed locally, giving two levels of reasoning: local ("what can I untangle here?") and global ("why can't I finish this area, and where does its blocker originate?"). Cross-neighborhood dependencies look promising when they cause the "aha" that apparently separate parts of the knot are connected.
- **Visual payoff:** removing substantial geometry changed the board visibly and rewarded the player.
- **Readability:** busy boards of short arrows reduced it. The spaghetti boundary was not attributed to a specific puzzle by the recorded evidence, so `knot_boundary` remains inconclusive.
- **Zoom and pan usefulness:** not recorded per puzzle. The canvas checks confirm navigation works on all six boards, but its felt usefulness is unknown.
- **Open Move usage:** not recorded. It is unknown, not zero.
- **Anticipating multiple moves:** the strongest emerging reward is understanding several consequences at once (an insight chain), not merely finding one legal arrow.
- **Stopping to reconsider:** the promising rhythm alternates uncertainty and mastery: search, understand something, execute briefly, change the board materially, stop and rethink, discover again. One giant discoverable A-to-Z sequence would turn the player into an executor once understood. A full rescan after every single move is exhausting. A good level likely contains several Discovery Beats. The final portion may intentionally allow a larger collapse once the last major discovery is made.

### Objective measures versus experience

Structural metrics are useful diagnostics, not sufficient measures of gameplay quality. Nothing in the record contradicts a specific metric outright, but nothing supports using any threshold as a gate either.

### Contradictions and limits

No contradictions were recorded between the session conclusions themselves. The main limits are single-session evidence, author familiarity, unrecorded play order and unrecorded per-puzzle detail.

### Transition

Specs 006 and 009 taught us about individual ingredients: geometry, density, dependencies, blocker distance, long arrows, bends, regions, interweaving, releases, readability and excessive complexity. Knowing the properties of the tools is not the same as knowing how to compose them into an excellent level.

The next problem is not how to generate ArrowSpark levels automatically. It is whether we can intentionally compose what we have learned into one level that delivers a compelling sequence of discovery, understanding, execution, release and renewed discovery.
