# Design report draft (working; becomes the durable report)

Candidate in the catalog: `reference_knot`. Iteration versions live only in this draft.

## 1. Structural profile
Candidate v1 (AI-authored composition, not yet played by a human): 46x32 board, 25 arrows
(3 single-cell, 22 multi-cell), 349 occupied cells (density 0.24), 15 bends total (max 3 per arrow),
max length 42, average length 13.96. 6 of 25 arrows legal at the start (0.24), 3 forced states,
22 branching states, longest forced run 2. Dependency graph: 52 edges, depth 8, max in-degree 7,
1 component. Largest single unlock fan-out 6 (the final unlock). Blocker distance max 32, average 14.81.
(Diagnostics only; no quality score.)

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

## 10. Human observations (unedited)

### Session 1 (candidate v1, 2026-09-30, the author; informal feedback, not the fifteen-question form)
Tester's words, verbatim: "for feedback, the reference puzzle is good, would like less whitespace, really fill i tup with arrows, longer is better than shorter, would like a back button instead of being forced to finish every level to contiue, maybe a  saved progress?    i like the grouping would be nice if the grouping was collapsible like an accordion menu as it grows.   game play is good, really enjoyed the reference puzzle, biggest desire is less whitespece in the puzzle (i.e empty grid cells)"

Not recorded for this session: session context (input method, Open Move use, prior familiarity), the on-screen cell size at which arrows were traceable, and answers to the fifteen questions. The final candidate still needs those. No answer to question 15 was given in that form.

Requests outside the puzzle (not part of this spec's scope): a back or exit button during play, saved progress across sessions, collapsible (accordion) groups in Level Select.

### Session template (copy per session)
- Session date / candidate version / tester / prior familiarity / input method / Open Move use:
- Smallest on-screen cell size (pixels) and zoom at which arrows were traceable:
1. First impression of the full board, and where possible starting moves were seen:
2. Could individual arrows be traced; ambiguous geometry; did zoom, pan or Fit Puzzle help:
3. Distinct neighborhoods perceived and what made them feel separate:
4. A neighborhood substantially cleared but not finishable until something elsewhere was resolved:
5. Where a distant arrow or tail blocked progress, and how it was discovered:
6. Distinct "aha" moments, each with where it occurred:
7. A discovery that let the tester anticipate several upcoming removals, and whether they happened:
8. Points where the tester had to stop and rethink after a chain of removals:
9. Where choice felt free and where order felt rigid or forced:
10. An arrow that seemed to hold separate areas together, and what changed visually when it left:
11. A stretch that felt like an obvious sequence for too long:
12. A stretch that needed a full-board rescan after every move:
13. The final portion: satisfying collapse, tedious cleanup or something else; remaining work:
14. Where it became confusing, frustrating or less engaging; what to change first:
15. Is this a level you want someone else to play, and why:

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
