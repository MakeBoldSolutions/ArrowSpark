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

### Session 2 (candidate v3, 2026-09-30, the author; conversational interview, answers mapped to the fifteen questions by the interviewer)
Context from the system, not asked: completed once; 115 arrows, 2 mistakes, 2 Open Move assists, score 103, accuracy 98.3%, window about 984x697 (from the Results screenshot). Input method: not yet recorded. Cell-size evidence: not captured this session (the F3 readout did not appear for the tester on a keyboard with dedicated function keys, although it works under automated key events; cause unknown).

Verbatim, in order:
- "finished, what a nice experiences"
- (after being asked for first impression and starting points) "this is what I have been looking for, can't wait to dive in, very statifying to see no whitepace but not too many arrors"

- (where did you start, and why) "i start in the uppor left corner and look for up arrows on top"
- (could you trace arrows; did zoom/pan/fit help) "used the mouse wheel, very easy to see, on a deskop screen was plenty big enough to play, zoomed in on some ares, it was a good experience"
- (how did the board open up) "I went arround the permiter, opened up zones looked for cross neghboor depencencies an chains I could run,"
- (a time when you could not finish an area until you did something elsewhere, and how you found the link) "you follow the blocks, it is fun to dicover the next pivot point, the next move that opens up 5 more before you have to start searching again"
- (a stretch that felt mechanical) "maybe a bit, towards the middle, when you see many routes starting to opne up"
- (a stretch needing a full-board rescan after every move) "when there are a small group of arrows on one side that are blocked by a large section on the other side of the board, then you have to figure how to release them, without hitting them by accicdent"
- (the final portion) "i like that there were blocks all the way to the end, I did not open up a large set of arrows I  had to click one by one, instead there was always somethign to try  and figure out"
- (an arrow that held separate areas together) "thee was a long arrow on the far right of the board that block a few zones, and could not be taken out until the bottom row was resolved, it forced me to get it resolved so more o the board could open up, I likeed that game play"
- (what you saw when that arrow left) "I saw 5 arrows I could click quickly, very satisfiying"
- (anything confusing, frustrating or less fun; what to change) "no, same game play and experiecne throughout the game play, never felt board or that the game had become monotonous"
- (best discovery moments) "somtimes a smaller arrow in the middle is hard to tell if it is open, then you click it and voiloa several more moves are ready to go, I also like the every once in a while you get a clear arrow click on it and notihing clears up, time to search more of the puzzle"
- (what made the zones feel separate) "a 'zone' gets crated when you clear up a bunch of white space arround a grouping of arrows, you can have multiple zones on the page at time it only takes a bit of whites psace for yours eyes to start seeing zones and you brain think sabout how do I clear this zone ..."
- (where choice felt free and where forced) "a few times it felt like there was only one sequence that would work, clearing a full line either vertical or horizontal, it is a good feeling, but if you see 10 different arrows you can click on to clear, it starts to feel old"
- (is this a level you want someone else to play) "yes, I would be happy to have a friend play this level, it has achived what I had in mind for an arrow puzzle game, super happy with the scoring and rules"
- (a stretch needing a full-board rescan after almost every move) "a few times, I had to do this, I used the hint to speed up this process, but i knew it would count against my score so it was a nice balance of motivation (quick or cheap )"
- (did you see consequences coming) "a few surpises, which is nice, plus a few where I could see the next 4 moves, nice but I want  to avoid a board with 10 obvious morves, that feels like I'm just clicking not playing"
- (roughly how many arrows did you click in a row at the end without needing to think) "I think at the end there were about 5 obvious left to cick"

Mapping so far: final-barrier count recorded as about 5 obvious clicks at the end (rough, from memory; at the spec's cap of five, and not specifically a count of single-cell arrows). Q7 answered (a few surprises, which he liked; a few times he could see the next 4 moves; he wants to avoid a board with about 10 obvious moves, which feels like clicking, not playing). Recurring theme with Q9 and Q11: he dislikes stretches with many obvious moves. Q12 answered (a few times; used the Open Move hint to speed it up, aware it counts against score; likes that tradeoff). Consistent with the system's 2 recorded Open Move assists. Q15 answered YES in his words (happy to have a friend play it; achieved what he had in mind; happy with scoring and rules). Recorded as given; awaiting his confirmation of the full record. Still lacking evidence: Q12 (full-board rescan after every move), Q7 (whether consequences were anticipated beforehand), the rough final-barrier count (FR-009), and the on-screen cell size (FR-008). Q9 answered (liked the few times only one sequence worked, such as clearing a full line; when about 10 different arrows are all clickable it starts to feel old). Interviewer note: this fits his earlier hedged "maybe a bit, towards the middle, when many routes open up" (Q11); the analyzer reports up to 15 arrows legal at once in the middle of the witness. Q3 answered. Interviewer note, for the intent-versus-actual section: the tester says zones appear as cleared whitespace forms around groups of arrows during play, not from the starting layout; the design intent described neighborhoods in the starting geometry. Not smoothed over here. Q6 answered (a smaller arrow in the middle that is hard to tell is open; clicking it makes several more moves ready), Q7 touched (the same effect: one click readies several moves; whether he anticipated it beforehand was not said), Q8 answered (when an open arrow is clicked and nothing new clears, he has to search more of the puzzle; he likes it). Q14 answered (nothing confusing or frustrating; experience consistent throughout; never bored or monotonous; no change requested in this answer). Note that this answer says nothing about the extra requests from session 1. Q10 now includes what changed visually (about 5 arrows became clickable quickly; "very satisfiying"). Q10 answered with a specific instance (a long arrow on the far right blocking a few zones that could not leave until the bottom row was resolved; resolving the bottom row opened more of the board; liked it). Also gives a specific instance for Q4/Q5. Interviewer note: this matches the east-edge arrow the design intended to be held by the bottom-edge arrows; the tester described it unprompted, without design vocabulary from the interviewer. What changed visually when it departed was not described. Q13 answered (liked that blocks continued to the end; no large set of arrows to click one by one; always something to figure out). This is also relevant to the five-consecutive-single-cell-removals evidence the spec asks for; a rough count was not asked and is not inferred. Q4/Q5 answered with a pattern (a small group of arrows on one side blocked by a large section on the other side of the board; no specific location named); Q12 not clearly answered (he described a hard-to-release situation, not a rescan after every move; not inferred). Q11 answered ("maybe a bit", towards the middle, when many routes opened up; hedged answer, recorded as given). Q5 answered in general terms (found connections by following the blocks; no specific location given), Q6/Q7 partly (enjoyed discovering "the next pivot point", a move that opens up about 5 more), Q8 partly (then "start searching again"). No specific aha moments or locations named yet. Q3 partly answered (perceived "zones"; what made them feel separate not yet said), Q4/Q5 touched on (looked for cross-neighbour dependencies and chains; no specific instance given yet). Q2 answered (arrows easy to trace; mouse wheel zoom used on some areas; plenty big on a desktop screen; no ambiguous geometry reported; Fit Puzzle and pan not mentioned). Input method so far: mouse. Q1 answered (positive first impression; started in the upper-left corner, looking for up-pointing arrows along the top edge). Q15 not yet asked.

### Session 2: confirmation and clarifications (tester, 2026-09-30)
The tester confirmed the mapped record above accurately represents the experience, and added, in substance:
- The roughly 5 obvious clicks at the end are a rough experiential count; he was not counting single-cell arrows. The record does not claim they were single-cell arrows, and the game state was not used to establish that.
- The middle section with roughly 10 available or obvious moves is a weakness worth preserving. He does not think it invalidates the level. Design boundary identified: some freedom feels good; too many simultaneously obvious moves starts to feel like clicking rather than solving.
- He did not experience the starting board as divided into predefined neighborhoods; neighborhoods emerged dynamically as arrows were removed and white space separated the remaining groups. To be preserved as a distinction from the original neighborhood hypothesis.
- Question 15 is an unqualified YES: "This is the first ArrowSpark level I would be happy to hand to someone else and say, 'Try this.' It achieved the experience I had been looking for."
- Decision: do not revise the puzzle merely to remove the middle-section weakness; v3 is preserved as the Reference Puzzle candidate.
- FR-008: tracing and readability passed his human observation. The required numeric cell-size evidence is NOT captured (the F3 readout did not display); it is outstanding and will be captured during the desktop smoke test.

Tester prior exposure: the author, who built and has played earlier candidates (an informal session on v1, session 1 above). This is a familiar-tester result and is disclosed as a limitation of SC-006.

### Success-criteria check against this session (interviewer's reading, not the tester's)
- SC-002: partly evidenced. Anticipating consequences: yes ("could see the next 4 moves"). Distinct aha moments: described pivot discoveries, a small middle arrow that was hard to read as open, and the far-right arrow release, without locating three separate moments. Stop-and-rethink points: described as a type ("clear arrow, nothing clears up, search more"), not located twice.
- SC-003: partly evidenced as a pattern ("a small group of arrows on one side blocked by a large section on the other side"); no specific named area.
- SC-004: largely evidenced. A long far-right arrow held a few zones until the bottom row was resolved; its removal opened about 5 arrows. A "visible simplification" was described as arrows becoming clickable, not as a visual unwinding.
- SC-005: NOT cleanly met. He reported "maybe a bit" of obvious sequence toward the middle, a few stretches of rescanning (eased with Open Move), and about 5 obvious clicks at the end (no tedious cleanup). He judges this does not invalidate the level.
- SC-006: all fifteen questions answered and Q15 is a clear yes; familiar-tester limitation disclosed.
- SC-009: not yet run (outside tester held until now).

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
- Neighborhoods: the design described neighborhoods in the starting geometry. The tester did not experience predefined neighborhoods; he reports neighborhoods emerging during play as cleared white space separated the remaining groups of arrows. Intent and experience differ here, and the experienced version is kept.
- Bridge: the far-right long arrow held until the bottom row was resolved played the held-together role the design intended; he found it unprompted, and its release opened about 5 clickable arrows.
- Middle of the game: the design expects freedom there; the tester found roughly 10 simultaneously obvious moves starting to feel like clicking. Intent and experience partly differ.
- Ending: the design aimed at a collapse without trailing cleanup; he reports blocks to the end and about 5 obvious final clicks, liked.

## 12. Useful and less useful concepts
To be filled: analyzer metrics, long/bent arrows, tail-based blocking, and the six knot experiments,
named by concept only.

## 13. Remaining weaknesses
From the human playtest: the middle of the game offers roughly 10 simultaneously obvious moves, which the tester says starts to feel like clicking rather than solving. He does not consider it invalidating and chose not to revise for it. Also open: the numeric on-screen cell size (FR-008) has not been captured yet.

## 14. Group classification rationale
Foundations: the eight baseline puzzles, each introducing or confirming one rule idea.
Puzzle Lab: the six structural experiments, the large-canvas validation board and the six knot
experiments; each exists to test a structural idea or the viewport, not as a designed level.
ArrowSpark Levels: the Reference Knot only, designed against the current player-experience standard.
`canvas_validation` is an experimental validation board, so it sits in Puzzle Lab.

## Candidate design principles (level-specific, not universal)
Each is supported by this level's single playtest, not a universal rule.
- Some freedom of choice feels good; too many simultaneously obvious moves (about 10) starts to feel like clicking rather than solving.
- Neighborhoods can emerge dynamically from white space opening during play instead of being visible in the starting layout.
- A move that opens several others, alternating with a clear arrow that opens nothing, keeps a long board engaging; blocks continuing to the end avoided a tedious cleanup.
- A long arrow held by a distant region, found by following blockers, gave the strongest release.
