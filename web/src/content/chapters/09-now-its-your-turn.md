---
title: "Now It's Your Turn"
part: 9
slug: now-its-your-turn
description: "The whole clock from first commit to the Reference Knot, what DevSpark learned from a game, the day verification kept creating work after the objective was met, what is still open, and one request: play it, then tell us what you think."
spoiler: false
status: draft
sources:
  - label: "Spec 010 merged (the clock's end)"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/6e60e117acc175a47feb55f52a3a8da1c6cedaab
  - label: "Developer readout added"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/b3aa17ee0f8f528c8315ecc766932638efb23a59
  - label: "Review revision 1"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/4998d18c4f692cc31c13e7bafc04f46c5bacc48c
  - label: "Review revision 2: readout removed, sampled check restored"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/6851baf98101e63957f72f1140ab45d2681faa93
  - label: "Review revision 3: dispositions recorded"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/72e52ead6ecea34f3bec402d16466d9189f084e7
  - label: "Spec 010 pull request"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/pull/4
updated: 2026-10-02
---

In [the first chapter](/story/finding-the-gap/) I said ArrowSpark had two jobs: be a good puzzle, and be an honest test of a method. This last chapter grades both, and the honest grade is *partial, and here's precisely how.*

## The whole clock

Here's the entire project on one page, from the first commit to the merge of the Reference Knot. Times are local, from the commit log.

| Milestone | When | Elapsed since first commit |
|---|---|---|
| First commit | Sep 26, 10:41 | 0 |
| Spec 001 first playable | Sep 26, 13:55 | 3h 14m |
| Spec 002 solver merged | Sep 26, 17:05 | 6h 24m |
| Spec 003 visuals merged | Sep 26, 21:25 | 10h 44m |
| Spec 004 departure merged | Sep 27, 00:40 | 13h 59m |
| Spec 005 catalog merged | Sep 27, 08:50 | 22h 09m |
| Spec 006 analyzer and playtest report | Sep 27, 13:36 | 26h 55m |
| Spec 007 Open Move merged | Sep 28, 07:42 | 45h 01m |
| Spec 008 canvas merged (PR #1) | Sep 28, 15:45 | 53h 04m |
| Spec 009 knots merged (PR #2) | Sep 29, 09:17 | 70h 36m |
| Spec 010 specified | Sep 29, 20:59 | 82h 18m |
| Spec 010 human playtest recorded | Oct 1, 07:51 | 117h 10m |
| Spec 010 merged (PR #4) | Oct 1, 11:51 | 121h 10m |

Ten specs in about 121 hours of elapsed time, nine of them in the first 70. Grouping commits into sessions (a new session after a gap of more than ninety minutes) gives seventeen sessions and about twenty-three hours of visible activity. Ninety-one commits, four merged pull requests. The [Evidence page](/evidence/) lists each figure with the command that reproduces it.

I want to be careful with what these numbers do and don't prove.

- **They are not a timesheet.** Elapsed time includes nights. Commit timestamps miss work before a session's first commit, and some commits batch a day's work. The session figure is a floor, not a measurement.
- **They don't prove the game is good.** They prove the *process* was fast and inspectable, and that its output was checkable at every step.
- **They aren't a solo typist's numbers.** AI ran the specification, planning, gating and implementation steps. My part was the decisions, the reviews, the playtests, and the acceptance. That division is the entire point of the method.
- **They can't be compared to a baseline I haven't stated.** I'm deliberately not claiming a speed-up multiple.

What the numbers *do* support is narrower and, I think, more useful. A developer with no game experience produced, in five days, a puzzle game with a proven solvability guarantee, a documented design philosophy, more test code than game code, two required regression gates running in CI, and a body of honestly recorded evidence about what works and what doesn't. That is not what an improvised weekend project looks like. It's what a disciplined process looks like when the tool removes the friction from the discipline.

## The day verification kept creating work

There's one more story the earlier chapters don't tell, because it only became clear at the very end.

On the morning of October 1st the Reference Knot had its answer. I had played it to the end and said I'd happily hand it to a friend. The objective of the spec was met. What followed was four hours of verification, and a good part of it was work the verification had created for itself.

**A readout added for evidence.** To record a measured on-screen cell size instead of an estimate, an F3 developer readout was [added](https://github.com/MakeBoldSolutions/ArrowSpark/commit/b3aa17ee0f8f528c8315ecc766932638efb23a59) that morning, with tests that drove a real key event through the input system. The tests passed. On the real desktop the readout never appeared. Now there was a new open question, *why doesn't the readout show?*, that had nothing to do with whether the level was good.

**A review that went through three revisions.** The pull-request review did its job and found real problems: three statements in the durable knowledge that contradicted the new code, and a focus bug where reopening Level Select could leave keyboard focus on a hidden button. [Revision 1](https://github.com/MakeBoldSolutions/ArrowSpark/commit/4998d18c4f692cc31c13e7bafc04f46c5bacc48c) fixed those. It also restored the full order-independence check for the densest board and raised the test launcher's timeout to make room for it, and it left the readout in place. Four minutes later, [revision 2](https://github.com/MakeBoldSolutions/ArrowSpark/commit/6851baf98101e63957f72f1140ab45d2681faa93) reversed both: the readout was removed, because it existed only to gather one measurement and had never displayed, and the sampled check came back, because sampling was a deliberate, bounded trade-off rather than a defect. [Revision 3](https://github.com/MakeBoldSolutions/ArrowSpark/commit/72e52ead6ecea34f3bec402d16466d9189f084e7) recorded a disposition for every finding and approved.

None of that was wasted. The focus bug was real, and so were the stale statements. But the readout and the timeout show a pattern every reviewer will recognize: each round of checking produced observations, and each observation looked like a reason for another round. Left alone, that loop doesn't end, because a careful reviewer can always find one more thing.

**The rule that ends it.** What came out of that morning is what DevSpark now calls the convergence rule:

> A spec is complete when its stated objective has been resolved and every remaining finding has been classified, not when every observation generated during the work has been eliminated.

A finding becomes work inside the current spec only when it shows the objective failed, a requirement is unmet, an invariant is broken, there's a real defect, or the change caused a regression. Everything else is classified (an accepted limitation, deferred work, or something learned) and carried forward with its reason. The closeout of Spec 010 is sorted exactly that way, and this showcase was planned under the same rule. Discovery doesn't expand the spec on its own say-so.

The rule cuts both ways, and that matters as much as the first half. A finding that *does* hit one of those triggers can't be classified away. The focus bug was a defect, so it was fixed. The pacing criterion failed against its original wording, so it went in the "failed" bucket and stayed there. Classification is how a spec finishes honestly, not how a failure gets retired quietly.

## What DevSpark learned

From the notes I kept along the way, here's what the method took from a game:

1. **The lifecycle transfers, but the risk surface differs.** Focus, input modes, animation lifecycle, node cleanup, resize, pause, and "logical vs. presentation state" barely appear in API work. A game-aware critic should carry a checklist of *questions* (does a newly opened menu establish focus? can a tween outlive its node?) that produce hypotheses to investigate, not automatic defects.
2. **Never claim structure that doesn't exist.** If the tool says it traversed a dependency, that dependency must be real. Analyze caught this twice.
3. **Discoverability is correctness.** A correct document that no future agent will find is effectively missing.
4. **Severity needs a second axis.** "Critical" once meant a context-integrity defect and not a runtime disaster. Separating *severity* from *impact domain* would prevent alarm and complacency alike.
5. **Manual verification is a legitimate outcome.** Say what was automated, what was checked by hand, and what wasn't checked.
6. **Human evidence can outrank a green experiment.** [Part 5](/story/playtest-beat-the-dashboard/) is the canonical case.
7. **Small specs preserve learning.** Jumping from solver to generator would have skipped visual geometry, departure behavior, the session contract, and the viewport, each of which changed what a generator would need to optimize.
8. **Explore loosely, ship precisely.** Metaphors, hypotheses, and unusual experiments belong in planning. Rules, solver validation, and deterministic tests belong in production.
9. **A definition of done can be a person's answer.** When the product is a feeling, green checks can say it's correct but not that it's good.
10. **Verification can create scope.** Classify what it finds; let only real blockers become more work.

## What's still open

- **One person has played the Reference Knot to the end, and it's the person who designed it.** No independent player has validated it. That's the most important open fact in this whole series.
- **Nobody new has tried to find it.** Whether a first-time player opens Level Select and finds the ArrowSpark Levels group without help was deferred to this showcase.
- **Mobile web is a beta.** The game now plays on phones and tablets in landscape, with taps and the on-screen zoom, Fit and Pan controls. Pinch to zoom is not reliable yet, touch targets are small, and it has been tried on very few real devices. Desktop is still the best way to play.
- **Generation is deliberately last.** The order is: rules, contract, viewport, hand-authored knots, human evidence, *then* maybe a generator that encodes what people actually enjoyed. Otherwise I'd teach a machine to optimize numbers no human cares about.
- **"Hard but never unsolvable" is a claim I can prove. "Satisfying" is one I can only test on people.**

## Back to the gap

I started with a puzzle-app problem: too much machinery between the player and the puzzle. Five days later I had a game that keeps a promise, *you can always keep going; the only cost of being wrong is score*, a proof that the promise holds for every puzzle in the catalog, and one level I wanted someone else to play.

Whether it's good is not something the tests can tell me.

The most valuable thing I did wasn't write code. It was ask, after every step, *what did we just learn, and what's the smallest next question?* DevSpark gave me a structure for asking. The game gave me a place where the answers were surprising. If you're a developer standing at the edge of some unfamiliar domain, that combination is the thing I'd recommend: **a method that makes you write down what you believe, and a project that's willing to prove you wrong.**

## Now it's your turn

So here is the request. [Play the Reference Knot](/play/). You don't need to read anything first, and if you have already read this far, that's fine too; the reaction form asks which.

Then tell us two things, honestly: what you thought of the game, and what you thought of the way it was built. A "no" is as useful as a "yes". The reactions are optional and anonymous: no account, no tracking, nothing that identifies you.
