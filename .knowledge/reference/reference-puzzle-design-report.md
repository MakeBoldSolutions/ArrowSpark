---
id: reference-puzzle-design-report
type: authoritative-reference
title: Reference Puzzle Design Report
appliesTo:
  - scripts/puzzle/puzzle_catalog.gd
  - tests/puzzle_catalog_check.gd
  - tests/puzzle_analyzer_check.gd
  - tests/puzzle_structural_report.gd
---

# Reference Puzzle Design Report

The catalog entry `reference_knot` ("Reference Knot") is the one hand-composed level in the ArrowSpark Levels group. It was composed to show the intended ArrowSpark experience: a readable knot, several moments of discovery separated by renewed uncertainty, regions that depend on each other, a long arrow that visibly leaves and releases others, and an ending that does not drag. Objective numbers below come from `PuzzleAnalyzer` and `PuzzleSolver` and are diagnostics only; no score, formula or threshold decides quality. Human observations are quoted from actual sessions; nothing here is inferred from the design.

Evidence status in one place: one tester, the designer, who was familiar with earlier versions, played the final version to completion. No independent player has validated the experience. The numeric on-screen cell size at which arrows were traced was not captured.

## Structural profile (final version)

46x32 board, 115 arrows (3 single-cell, 112 multi-cell), 1348 of 1472 cells occupied (density 0.92). 207 bends in total (at most 9 on one arrow), longest arrow 43 cells, average 11.72. 6 of 115 arrows are legal at the start. Along the solver witness: 11 forced states, 104 branching states, longest forced run 3, up to 15 arrows legal at once. Dependency graph: 661 edges, depth 33, largest in-degree 20, one connected component, largest single unlock 5. Blocker distance: maximum 42, average 11.71. The solver confirms it solvable and its witness replays with zero mistakes; the catalog check also confirms the order-independence property at every branching state.

## Intended neighborhoods

The composition started from a hand-built skeleton on a sparse board, and the neighborhoods below describe that skeleton. Later versions filled the gaps around it, so these are intent, not a description of the final board's visible regions.

- A north comb: six long parallel arrows stacked in rows, held in place by vertical gates and a long wall along the east edge.
- A north-east gate chain: one long arrow along the top edge, a cap, and three gates hanging down.
- A middle bridge: a full-width arrow across the board, held at the west edge by one bent arrow.
- A south-west group and a south-east group of bent arrows whose tails cross each other's paths, with tails along the bottom edge that hold the east wall.

## Cross-neighborhood dependencies

In the skeleton the comb needed the east wall to leave; the east wall needed the bottom-edge tails; the bottom-edge tails needed the bridge and the south-east arrows; the south-west arrows needed the bridge; the south-east arrows needed the south-west bent arrows. The fill added many further dependencies (661 edges in total versus 52 in the skeleton).

## Bridge arrows

Intended: the full-width middle arrow, whose removal slides 42 cells and frees the south. Observed: the tester independently singled out a long arrow on the far right that held several areas until the bottom row was resolved; resolving it opened about five arrows that could be clicked quickly, which they called very satisfying.

## Expected discovery beats and insight chains

Intended beats: the top-edge long arrow opens the gate chain; the west-edge bent arrow frees the bridge; the bridge frees the south; the bottom-edge tails explain why the comb stays stuck; the last unlock releases the comb together. Intended insight chains: top edge, then cap, then gates; west-edge bent arrow, then bridge, then bottom-edge tails, then east wall, then comb. The dense final board was not re-derived beat by beat.

## Major releases and intended experience curve

Intended releases: the bridge slide in the middle and the comb release at the end. Intended curve: a few free openers, a mid-game stall until the bridge is understood, a second stall on the east wall, then a short collapse.

## Iteration history

| Version | What changed | Why | Result |
|---|---|---|---|
| 1 | First composition: 25 arrows, density 0.24. | Start the human loop. | Valid, solvable, replayable. The designer liked it and asked for far less empty space, longer arrows, a way to leave a level without finishing it, saved progress, and collapsible groups in Level Select. |
| 2 | Added long bent arrows around the skeleton: 59 arrows, density 0.69, average length 17.2. | Less empty space, longer arrows. | Valid, solvable. Not played by a human. |
| 3 | Packed to density 0.92 with 115 arrows, long ones first and short ones last. Average length fell to 11.7, longest 43. | Under 10% empty cells. | Valid, solvable. Played to completion by the designer; unqualified yes. Kept as the Reference Puzzle. |

The requests for leaving a level, collapsible groups and the cell-size readout were handled as separate features; saved progress was left for later. A change to the analyzer's longest-chain search (linear time on acyclic dependency graphs, identical results) was needed because the exhaustive search could not finish on the dense board.

## Human observations (unedited)

Informal first session on version 1, verbatim: "for feedback, the reference puzzle is good, would like less whitespace, really fill i tup with arrows, longer is better than shorter, would like a back button instead of being forced to finish every level to contiue, maybe a  saved progress?    i like the grouping would be nice if the grouping was collapsible like an accordion menu as it grows.   game play is good, really enjoyed the reference puzzle, biggest desire is less whitespece in the puzzle (i.e empty grid cells)"

Final session on version 3, conversational interview, answers verbatim and mapped to the fifteen questions by the interviewer. The system recorded: completed once, 115 arrows, 2 mistakes, 2 Open Move assists, score 103, accuracy 98.3%; the tester played with the mouse and wheel zoom.

1. First impression and starting points: "this is what I have been looking for, can't wait to dive in, very statifying to see no whitepace but not too many arrors"; "i start in the uppor left corner and look for up arrows on top".
2. Tracing arrows: "used the mouse wheel, very easy to see, on a deskop screen was plenty big enough to play, zoomed in on some ares, it was a good experience".
3. Distinct areas: "a 'zone' gets crated when you clear up a bunch of white space arround a grouping of arrows, you can have multiple zones on the page at time it only takes a bit of whites psace for yours eyes to start seeing zones and you brain think sabout how do I clear this zone ...". Confirmed afterwards: they did not experience predefined neighborhoods in the starting board; they emerged as arrows were removed and white space separated the remaining groups.
4. An area cleared but not finishable: "when there are a small group of arrows on one side that are blocked by a large section on the other side of the board, then you have to figure how to release them, without hitting them by accicdent" (a pattern; no specific location given).
5. A distant block and how it was found: "you follow the blocks, it is fun to dicover the next pivot point, the next move that opens up 5 more before you have to start searching again"; and the far-right long arrow that "could not be taken out until the bottom row was resolved".
6. Aha moments: "somtimes a smaller arrow in the middle is hard to tell if it is open, then you click it and voiloa several more moves are ready to go"; the pivot moves above. Three separate located moments were not named.
7. Anticipating consequences: "a few surpises, which is nice, plus a few where I could see the next 4 moves, nice but I want  to avoid a board with 10 obvious morves, that feels like I'm just clicking not playing".
8. Stopping to rethink: "I also like the every once in a while you get a clear arrow click on it and notihing clears up, time to search more of the puzzle".
9. Freedom versus forced order: "a few times it felt like there was only one sequence that would work, clearing a full line either vertical or horizontal, it is a good feeling, but if you see 10 different arrows you can click on to clear, it starts to feel old".
10. An arrow holding areas together: "thee was a long arrow on the far right of the board that block a few zones, and could not be taken out until the bottom row was resolved, it forced me to get it resolved so more o the board could open up, I likeed that game play"; what changed: "I saw 5 arrows I could click quickly, very satisfiying".
11. An obvious sequence for too long: "maybe a bit, towards the middle, when you see many routes starting to opne up".
12. Full-board rescan: "a few times, I had to do this, I used the hint to speed up this process, but i knew it would count against my score so it was a nice balance of motivation (quick or cheap )".
13. The final portion: "i like that there were blocks all the way to the end, I did not open up a large set of arrows I  had to click one by one, instead there was always somethign to try  and figure out"; about five obvious clicks at the end, a rough experiential count, not a count of single-cell arrows.
14. Confusing or frustrating moments: "no, same game play and experiecne throughout the game play, never felt board or that the game had become monotonous".
15. Would you want someone else to play it: "yes, I would be happy to have a friend play this level, it has achived what I had in mind for an arrow puzzle game, super happy with the scoring and rules". Confirmed as an unqualified yes: the first level they would hand to someone and say "try this".

## Intent versus actual

- Neighborhoods were designed into the starting geometry; the tester experienced them as emerging during play from cleared white space.
- The long bridge arrow in the design was a full-width middle arrow; the tester's strongest bridge moment was a long far-right arrow, which matches the intended east-wall role.
- The middle of the game was meant to offer freedom; at roughly ten simultaneously obvious moves it began to feel like clicking.
- The ending was meant to collapse without trailing cleanup; the tester found blocks to the end and about five obvious final clicks, and liked it.

## Useful and less useful concepts

- Useful: long and bent arrows as the skeleton; tails as the source of distant dependencies; dependency depth and fan-out as ways to see chains and releases; the path-following departure as the visible payoff of a release; the Open Move hint trading speed against score.
- Less useful: single structural measures as judges of quality (density, edge count and depth do not say whether a board plays well); the starting-layout idea of neighborhoods, which the tester did not perceive; filling to maximum density with short arrows, which shortened the average arrow against the preference for longer ones.
- The earlier knot experiments (long geometry, interwoven paths, dense core, distinct regions, single release, boundary knot) supplied the ingredients; none was designed as a whole level.

## Remaining weaknesses and limitations

- The middle of the game offers roughly ten simultaneously obvious moves, which the tester says starts to feel like clicking rather than solving. They do not consider it invalidating and chose not to redesign for it.
- The tester is the designer and had played an earlier version. No independent player has played it; fresh-player validation, including whether a new player finds the ArrowSpark Levels group in Level Select, has not been done.
- The numeric on-screen cell size and zoom at which arrows were traceable were not captured. Readability rests on the tester's account (very easy to see on a desktop screen; wheel zoom was enough).
- Some of the tester's observations are patterns, not located moments: three separate aha moments and two separate stop-and-rethink points were not each named, and no specific area was named for an area that was cleared but not finishable.
- Physical gamepad play and a frame-time observation were not performed; keyboard and gamepad menu navigation are covered only by automated input-event checks.

## Lessons for judging levels

The playtest corrected a too-absolute assumption about what makes a level good. A short obvious sequence after a real insight lets the player enjoy mastery; some rescanning is what starts the next discovery; a small final collapse can be satisfying. What hurts is excess: an obvious sequence long enough to become mindless clicking, rescanning so often that understanding cannot form, or a long trivial cleanup after the puzzle is effectively solved. A criterion for a level should therefore bound those excesses and not forbid the behaviors.

## Group classification rationale

- Foundations: the eight baseline puzzles, each introducing or confirming one rule idea.
- Puzzle Lab: the six structural experiments, the large-canvas validation board and the six knot experiments; each tests a structural idea or the viewport and was not designed as a level. The large-canvas board is classed here because it is an experimental validation board.
- ArrowSpark Levels: the Reference Knot only, designed against the current player-experience standard. Group names describe why content exists and imply no quality ranking.

## Candidate design principles (supported by this level only, not universal)

- Some freedom of choice feels good; around ten simultaneously obvious moves starts to feel like clicking rather than solving.
- Neighborhoods can emerge during play from white space opening up, instead of being visible in the starting layout.
- A move that opens several others, alternating with a clear arrow that opens nothing, kept a long board engaging; blocks that continue to the end avoided a tedious cleanup.
- A long arrow held by a distant region, found by following blockers, gave the strongest release.
