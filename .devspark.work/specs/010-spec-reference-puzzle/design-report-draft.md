# Design report draft (working; becomes the durable report)

Candidate in the catalog: `reference_knot`. Iteration versions live only in this draft.

## 1. Structural profile
Current candidate v3 (see the iteration table for v1 and v2): 46x32 board, 115 arrows (3 single-cell,
112 multi-cell), 1348 of 1472 cells occupied (density 0.92), 207 bends (max 9 per arrow), max length 43,
average length 11.72. 6 of 115 arrows legal at the start, 11 forced states, 104 branching states, longest
forced run 3. Dependency graph: 661 edges, depth 33, max in-degree 20, 1 component, largest single unlock
fan-out 5. Blocker distance max 42, average 11.71. (Diagnostics only; no quality score.) The intended
neighborhood and beat descriptions below were written for the v1 skeleton that v2 and v3 build on, and have
not been re-derived for the dense board.

## 2. Intended neighborhoods
- North comb: six long parallel right-pointing arrows stacked in rows, held by vertical gates.
- North-east gate chain: one long arrow along the top edge, a cap, and three vertical gates hanging down.
- Middle bridge: a full-width arrow across the middle, held by one bent arrow at the west edge.
- South-west: two bent arrows whose tails cross each other's paths, plus a downward bent arrow.
- South-east: three bent arrows whose tails and rays cross the middle and the bottom edge.
- East wall and bottom edge: two long tails that hold the comb from the far side.

## 3. Cross-neighborhood dependencies
The comb needs the east wall, which needs the bottom-edge tails, which need the bridge and the
south-east arrows; the south-west arrows need the bridge; the south-east arrows need the south-west
bent arrows. (Model check: acyclic, depth 8.)

## 4. Bridge arrows
The full-width middle arrow: its removal slides 42 cells and frees the southern arrows.

## 5. Expected discovery beats
(Intent, to compare with what a human actually reports.) 1. Top-edge long arrow opens the gate chain.
2. The west-edge bent arrow frees the bridge. 3. The bridge frees the south. 4. The bottom-edge tails
explain why the comb stays stuck. 5. The last unlock releases six long arrows together.

## 6. Insight chains
Top edge -> cap -> gates (north). West-edge bent arrow -> bridge -> bottom-edge tails -> east wall -> comb.

## 7. Major releases
The bridge slide (mid game) and the six-arrow comb release (final).

## 8. Intended experience curve
Several free openers, a mid-game stall until the bridge is understood, a renewed stall on the east
wall, then a short collapse. Expected end: at most a few single-cell removals after the last barrier.

## 9. Iteration history
| Version | Date | What changed | Why | Evidence |
|---|---|---|---|---|
| v1 | 2026-09-30 | First composition in the catalog. | Start the playtest loop. | Solver-confirmed solvable, witness replays, all regression gates green. First human play: liked it, asked for far less empty space. |
| v2 | 2026-09-30 | Kept the v1 skeleton and added long bent arrows around it until about 69% of cells were occupied (59 arrows, average length 17.2, up from 25 arrows and 14.0). | The tester's main request was less whitespace, longer arrows. | Solvable, witness replays, all gates green. Structural diagnostics: density 0.69, 7/59 initially legal, dependency depth 18, 276 edges, max fan-out 7. Not yet replayed by a human. |
| v3 | 2026-09-30 | Packed the board to 91.6% occupied (115 arrows, average length 11.7, longest 43, 3 single-cell) by adding long arrows first and short ones last. | The tester asked for under 10% empty cells. | Solvable, witness replays, all gates green. Stock structural report (after the analyzer fix): density 0.92, 115 arrows, 6 of 115 legal at the start, dependency depth 33, 661 edges, max in-degree 20, max fan-out 5, blocker distance max 42. Not yet played by a human. Average arrow length fell from 17.2 to 11.7, against the tester's preference for longer arrows. |

## 10. Human observations (unedited)

### Session 1 (candidate v1, 2026-09-30, the author; informal feedback, not the fifteen-question form)
Tester's words, verbatim: "for feedback, the reference puzzle is good, would like less whitespace, really fill i tup with arrows, longer is better than shorter, would like a back button instead of being forced to finish every level to contiue, maybe a  saved progress?    i like the grouping would be nice if the grouping was collapsible like an accordion menu as it grows.   game play is good, really enjoyed the reference puzzle, biggest desire is less whitespece in the puzzle (i.e empty grid cells)"

Not recorded for this session: session context (input method, Open Move use, prior familiarity), the on-screen cell size at which arrows were traceable, and answers to the fifteen questions. The final candidate still needs those. No answer to question 15 was given in that form.

Requests outside the puzzle (not part of this spec's scope): a back or exit button during play, saved progress across sessions, collapsible (accordion) groups in Level Select.

### Session template (copy per session)
- Session date / candidate version / tester / prior familiarity / input method / Open Move use:
- Smallest on-screen cell size (pixels) and zoom at which arrows were traceable:
1. What was your first impression of the full board, and where did you see possible starting moves?
   Answer: 
2. Could you trace individual arrows throughout play? Describe any ambiguous geometry and whether zoom, pan or Fit Puzzle helped.
   Answer: 
3. Which distinct neighborhoods did you perceive, and what made them feel separate?
   Answer: 
4. Which neighborhood, if any, could you substantially clear but not finish until you resolved something elsewhere? Describe that dependency.
   Answer: 
5. Where did a distant arrow or its tail block your progress, and how did you discover the connection?
   Answer: 
6. What distinct "aha" moments did you experience? Describe each and where it occurred, even if there were fewer than three.
   Answer: 
7. Which discovery, if any, let you anticipate several upcoming removals, and did those consequences happen as expected?
   Answer: 
8. After a chain of removals, where did you have to stop and rethink? Describe each such point, even if there were fewer than two.
   Answer: 
9. Where did you feel free to choose among useful moves, and where did the order feel rigid or forced?
   Answer: 
10. Which arrow, if any, seemed to connect or hold together separate areas? Describe what changed visually when it departed.
   Answer: 
11. Did any stretch feel like following an obvious sequence for too long? Identify it and describe why.
   Answer: 
12. Did any stretch require a full-board rescan after every move? Identify it and describe what made progress hard to follow.
   Answer: 
13. How did the final portion feel: a satisfying collapse, tedious cleanup, or something else? Describe the remaining work.
   Answer: 
14. Where did the experience become confusing, frustrating or less engaging, and what would you most want changed?
   Answer: 
15. Is this a level you want someone else to play? Why or why not?
   Answer: 

## 11. Intent versus actual
To be filled from playtests.

## 12. Useful and less useful concepts
To be filled: analyzer metrics, long/bent arrows, tail-based blocking, and the six knot experiments,
named by concept only.

## 13. Remaining weaknesses
Known before any playtest: the board is sparse in places (density 0.24 against 0.87 for the densest
existing board); the south-west has few arrows; the north comb's six rows are visually uniform.

## 14. Group classification rationale
Foundations: the eight baseline puzzles, each introducing or confirming one rule idea.
Puzzle Lab: the six structural experiments, the large-canvas validation board and the six knot
experiments; each exists to test a structural idea or the viewport, not as a designed level.
ArrowSpark Levels: the Reference Knot only, designed against the current player-experience standard.
`canvas_validation` is an experimental validation board, so it sits in Puzzle Lab.

## Candidate design principles (level-specific, not universal)
To be filled only from evidence.
