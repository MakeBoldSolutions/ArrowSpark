---
title: "The Playtest That Beat the Dashboard"
part: 5
slug: playtest-beat-the-dashboard
description: "A catalog, a Level Select that a review saved from a keyboard dead end, an analyzer, and six experiments that hit every structural target. Then one playtest rated them 2 out of 5, and the project learned where difficulty actually lives."
spoiler: true
status: published
sources:
  - label: "Spec 005 merged"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/6aaf79d15fd9d82b6ebf83d77244c7bf6834c3d4
  - label: "Analyzer and structural report"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/207bc2e058ed1a74b86e92783e7a2c512127f920
  - label: "Spec 006 report with the playtest"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/7edd8e11a1c5fe75ace7b2e5976ea7544e20603e
  - label: "Analyzer (knowledge)"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/blob/6e60e117acc175a47feb55f52a3a8da1c6cedaab/.knowledge/architecture/arrow-puzzle.md
updated: 2026-10-02
---

By the time I had a solver, arrows that unwound, and a proven guarantee, I had a different problem. I had one puzzle.

## Spec 005: from a demo to content

Spec 005 replaced the single hard-coded puzzle with a **catalog**: eight authored puzzles with stable IDs and titles, a Level Select menu, Replay, Next Puzzle, and puzzle identity in the HUD and results screen. It was specified at 00:47 on September 27th, planned at 00:59, given twenty-six tasks across three user stories at 01:01, and implemented by 08:50 the same morning. Every puzzle was confirmed solvable by the solver with a zero-mistake witness.

### The clock: fourteen minutes from idea to task list

Look at those timestamps again. The specification landed at 00:47. Clarifications followed at 00:53, the plan at 00:59, and the task list at 01:01. **Fourteen minutes** from a first specification to twenty-six sequenced tasks, on a feature that touches menus, session state, content, and the results screen. Then I went to sleep. The implementation commit and the merge both landed at 08:50, with a Level Select focus refinement at 08:08 in between.

The fourteen minutes has a mundane explanation. It's what specification looks like when the constitution, the architecture boundary, and the product principles are already written down: the spec doesn't have to re-argue them, so it can be short and precise. Those decisions were already recorded from the prior day. The whole spec, from first line to merge, took under eight hours of wall clock, and the largest part of that was an overnight gap between the task list at 01:01 and the next commit at 08:08.

Two decisions here are worth pausing on.

**I didn't use the template's level system.** Maaack's template comes with level and progression machinery, and reusing it would have been the path of least resistance. But it assumes persistent, scene-per-level progression and win/loss semantics, which is the opposite of what ArrowSpark was. A reusable scene loading puzzle *data* was a better fit, and selection would be session-only. Inheriting something for free isn't free if it drags in the wrong assumptions.

**Critic found a bug in a plan.** This is the most game-specific catch in the project. The spec required that the Level Select menu work with a keyboard or gamepad. The plan said the inherited menu machinery would handle that. Critic didn't take the plan's word. It read the template's code and found that opening a sub-menu shows it but never gives anything keyboard focus, and that the recovery path re-focuses a *hidden* button. A keyboard-only player would open Level Select and land nowhere.

That's a defect specific to games and UI, and the kind ordinary "the tests pass" checks miss, because nothing looks wrong on screen. The fix was small (explicitly grab focus on the first entry, and assert it in an automated test) and it was made *before* implementation. It also gave me a lasting lesson: a requirement that says "accessible" isn't the same as one that says *who owns focus when this appears.*

## Spec 006: let's measure difficulty

With eight puzzles that all worked, I wanted to know why some were more interesting than others. The honest answer was that I didn't know, and the temptation was to reach for a generator and let it produce puzzles by the hundred.

I resisted that, because I'd have been teaching a generator to optimize things I hadn't yet shown mattered.

Instead, a research pass came first. It re-implemented the solver's own logic in Python and ran it across the eight puzzles. Its findings were structural, not opinion. Three of the eight used a bent arrow at all. None combined density with real dependency depth. And no puzzle contained an arrow whose removal unlocked more than one other, so the "cascade" moment, a strong candidate for a satisfying *aha*, was completely untested.

So Spec 006 built a laboratory:

- **`PuzzleAnalyzer`**, a headless, deterministic sibling of the solver. It reports board scale, arrow geometry, legal-move structure, a dependency graph, unlock cascades, and blocker distance. It reads every blocking fact straight from the game's own rules rather than becoming a second rules engine.
- **Six experimental puzzles**, each designed on paper against a numeric target and *then* verified against the analyzer: a nested chain, a cascade with a key arrow, a dense unravel, a bent network, a long-range blocker, and a composed diamond.
- **A comparison report** answering questions like "which puzzle has the deepest chain?", deliberately outside the pass/fail gate, because it reports facts and not verdicts.

The plan went through Analyze and Critic before any code was written. Nine findings came back, three of them critical: a knowledge-graph relationship the plan described that didn't actually exist in the repository, and an undefined meaning of "dependency depth" when a candidate puzzle contains a cycle. All nine were resolved first. (The cycle answer: the longest *simple* path through the graph, which is provably finite.)

Then came the implementation, and it went well. 39 of 39 tasks. 122 analyzer assertions passing. One real GDScript gotcha caught along the way (in GDScript, `==` binds tighter than `as`). Every experimental puzzle hit its target exactly.

Result so far: all targets met.

The clock says something worth noticing here too. The analyzer, the six puzzles and their tests first appear in the log at 11:51 on September 27th, and the Spec 006 report that includes the playtest results is committed at 13:36: **1 hour 45 minutes** of visible trail. (Planning for that spec began earlier, so treat this as the implementation-to-report window, not the whole spec.) That's roughly twenty-seven hours after the very first commit of the project. In under twenty-seven hours the project had gone from an empty repository to a measured, falsified design hypothesis.

## Then I played them

I sat down and played all six in one sitting, one session, recorded in the [Spec 006 report](https://github.com/MakeBoldSolutions/ArrowSpark/commit/7edd8e11a1c5fe75ace7b2e5976ea7544e20603e). Here's what I said afterward, unedited:

> "Scoring is good, gameplay is good, variety on levels is not good — all still very simple. I'm looking for more long arrows mixed together so you have to really think about how to sort it out. … too many single arrows which can get boring."

Perceived challenge: **2 out of 5.** Scanning load: low. And the puzzle built specifically to test a cascade, an analyzer-confirmed arrow whose removal unlocks three others, produced no *aha* at all when I was asked about it directly.

The verdicts, honestly recorded:

| Puzzle | Structural target | Verdict |
|---|---|---|
| Nested Chain | Depth 3, corner to corner | Contradicted |
| Cascade / Key Arrow | Fan-out of 3 on removal | **Contradicted, directly** |
| Dense Unravel | 67% occupied, depth 3 | Contradicted |
| Bent Network | Two bent arrows, tail-sourced edges | Inconclusive |
| Long-Range Blocker | Blocker seven cells away | Contradicted |
| Composed / Shaped | 47-edge diamond of 25 arrows | Inconclusive |

## What the dashboard couldn't see

The pattern across every "contradicted" row was one thing. The puzzles were built almost entirely from single-cell arrows.

The analyzer measured the *dependency graph*, and the graph was real. A depth-3 chain is a depth-3 chain. But an edge between two single-cell arrows requires no tracing at all. You see both arrows at a glance; you see the blocker at a glance; the "dependency" is visible without thought. The graph was deep. The experience was shallow.

I wrote the lesson down, and it's the sentence I'd most like readers to keep:

> **A puzzle can be structurally complex without being perceptually complex.**

Spec 006 hadn't failed. It had *worked*: it disproved my assumption cheaply, in a controlled setting, before I built anything that depended on it. A failed hypothesis from a well-built experiment is progress, and I'd had the instruments to know precisely which hypothesis failed.

## Geometric entanglement

My own reaction had contained the answer. *More long arrows mixed together.*

Arrows aren't just nodes in a graph. They're shapes that occupy space. A long, bent arrow forces the player to answer several visual questions before making a move: where is its head, which line segments belong to it, where does it turn, which other arrows are crowded around it, what is in its head's forward ray? When several long arrows overlap a region, those questions interact.

I started calling this **geometric entanglement**, meaning the amount of visual tracing needed to understand who owns what and what blocks whom. It isn't the same as density. Thirty single-cell arrows are busy, not entangled. Twelve long, bent arrows can be far harder to read and far more satisfying to remove, because pulling one clears a substantial part of the board.

That's where the metaphor from [Part 4](/story/making-it-feel-right/) clicked into place. This was a game about **untangling a knot**.

I was careful not to turn this into a formula. The design notes are explicit: these are research concepts, not production metrics, and I shouldn't prematurely encode them into a difficulty score. The lesson of Spec 006 is precisely that a formula can hit its target and miss the experience.

## What I'd take from this

- **Build the experiment to be falsifiable, then believe the result.** All six puzzles passing analysis was the engineering success. The human verdict was the finding.
- **Instruments describe; people experience.** Analyzer metrics are descriptive, not experiential.
- **Don't build the generator yet.** Generation optimizes whatever you give it. I didn't yet know what to give it.
- **Ask what your reviewers would find if they actually read the code.** Critic's focus finding came from opening the addon, not from trusting the plan.

To make harder puzzles, I now needed to make *two* commitments: a promise to the player that harder wouldn't mean unfair, and an environment big enough to hold a real knot. Next.

---

## Receipts

Every claim above about timing or sequence can be checked against the repository history. Times are local (US Central), as recorded in each commit; each hash links to the commit on GitHub. Subjects are quoted from the log, except that internal planning identifiers are replaced by a short description.

```text
git show --stat <hash>      # what a commit changed
git log --reverse --format='%h %ad %s' --date=format:'%Y-%m-%d %H:%M'
```

| Commit | Time | Subject |
|---|---|---|
| [`7eca512`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/7eca51230a2e391552b5cfbccaa06677291c54d1) | 2026-09-27 00:47 | feat(spec): add Spec 005 — multiple authored puzzles, session-only selection |
| [`5e47dfe`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/5e47dfe1e5928e60ea6e2c6ce0f170b872c7e0d3) | 2026-09-27 00:53 | docs(spec): clarify pause-menu Restart and keyboard/gamepad nav for Spec 005 |
| [`91635f1`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/91635f1ca481d275cd5b2b69b3dc7a930168bec8) | 2026-09-27 00:59 | feat(spec): plan Spec 005 — puzzle catalog, session selection, Level Select |
| [`fe388e9`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/fe388e9ec42b1b7759583b44e41dddcb6ad6a000) | 2026-09-27 01:01 | feat(spec): generate tasks.md for Spec 005 (26 tasks, 3 user stories) |
| [`e9cf351`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/e9cf351b837016b71fd768314c5ce72b039bda80) | 2026-09-27 08:08 | feat(spec): enhance Level Select with focus handling and clarify HUD puzzle identity |
| [`0c8572d`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/0c8572d8831789059f541a7f85444b0d05914521) | 2026-09-27 08:50 | feat(spec): implement Spec 005 — puzzle catalog, session selection, Level Select, Next Puzzle |
| [`6aaf79d`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/6aaf79d15fd9d82b6ebf83d77244c7bf6834c3d4) | 2026-09-27 08:50 | Merge branch '005-spec-multiple-puzzles' |
| [`3bfc26f`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/3bfc26fd28b39a9420b2f94b19e00204c1f578fd) | 2026-09-27 11:51 | feat: Add PuzzleAnalyzer and new puzzles for structural analysis |
| [`207bc2e`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/207bc2e058ed1a74b86e92783e7a2c512127f920) | 2026-09-27 13:17 | Add PuzzleAnalyzer tests and structural report |
| [`7edd8e1`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/7edd8e11a1c5fe75ace7b2e5976ea7544e20603e) | 2026-09-27 13:36 | docs(spec): add Spec 006 report summarizing implementation and playtest findings |
