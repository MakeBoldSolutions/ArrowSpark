# Level Outline (working note)

Progression from just above the Foundations to just below the Reference Knot (46x32, 115 arrows). Titles are the spec's illustrative ones. Every level is a literal-data board found by a seeded search against its profile, proven by the game's solver, with no single-cell arrows.

| # | Id | Title | Distinct primary challenge | Board | Arrows |
|---|---|---|---|---|---|
| 1 | first_knot | First Knot | First step up: long bent arrows, shallow chains | 9x7 | 9 |
| 2 | two_neighborhoods | Two Neighborhoods | Two clusters that depend on each other across a gutter | 15x9 | 15 |
| 3 | the_bridge | The Bridge | One long arrow linking arrows on either side of it | 17x9 | 14 |
| 4 | false_simplicity | False Simplicity | Few playable arrows hidden in open-looking space; forced runs | 14x11 | 17 |
| 5 | the_rescan | The Rescan | Releases that free nothing nearby, forcing whole-board rescans | 20x12 | 23 |
| 6 | major_release | Major Release | One search-then-release that frees five arrows at once | 22x14 | 30 |
| 7 | dense_weave | Dense Weave | Density from interleaved short bent arrows, deep chains | 26x16 | 68 |
| 8 | almost_a_knot | Almost a Knot | Last step: long arrows, high fill, many multiply-blocked arrows | 36x24 | 93 |

Size ramp in arrow count: 9, 15, 14, 17, 23, 30, 68, 93, then 115 (Reference Knot). Level 3 is slightly smaller than level 2 in arrow count; its challenge is structural, not size. The jump from level 8 to the Reference Knot is the one most likely to feel like a cliff (depth 12 to 33, average length 7.4 to 11.7); judge by play.

Measured structure per level: `.knowledge/reference/progression-design-learning.md`.
