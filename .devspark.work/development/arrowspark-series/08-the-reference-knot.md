---
title: "The Reference Knot: A Level Judged by a Human"
series: "Building ArrowSpark with DevSpark"
part: "8 of 8 (plus closing chapter)"
slug: the-reference-knot
status: first-draft
author: Mark Hazleton
date_drafted: 2026-10-01
theme: "Composition, not ingredients: one hand-built level whose definition of done was a person's honest answer, and what happened when that answer came back mostly yes."
description: "Spec 010 composed the Reference Knot, a 115-arrow level, through three versions and two playtests, grouped the catalog by purpose, and closed with one success criterion failed against its original wording and one deferred. The critic gate predicted three of the limitations it ended with."
wall_clock: "Spec 010: specified 2026-09-29 20:59, implementation commit 2026-09-30 15:38, human playtest recorded 2026-10-01 07:51, PR #4 merged 2026-10-01 11:51 (38h52m elapsed; about 3h42m of commit-bracketed sessions). Whole project at merge: 121h10m elapsed, 17 sessions, about 22.9h."
purpose: "Show the DevSpark discipline at its most useful: a spec that could not be finished by green checks, gates that anticipated where it would fall short, and a closeout that records failure and deferral instead of rounding them up."
audience: "Readers deciding whether spec-driven, AI-assisted development holds up when the acceptance test is a human feeling, not a test result."
spoiler_note: "Discusses the Reference Knot's design. On the website this chapter sits behind a play-first note."
specs_covered: ["010-spec-reference-puzzle"]
evidence_sources:
  - .knowledge/reference/reference-puzzle-design-report.md
  - .devspark.work/specs/010-spec-reference-puzzle/spec.md
  - .devspark.work/specs/010-spec-reference-puzzle/gates/critic.md
  - .devspark.work/specs/010-spec-reference-puzzle/gates/verify.md
  - .devspark.work/specs/010-spec-reference-puzzle/deferred-to-next-spec.md
  - .devspark.work/pr-review/pr-4.md
  - "git log: e5cc3cb, c15564c, f9b0e61, 47bc1ab, 26cd921, 4aba5e7, 6941414, 6851baf, 6e60e11 (PR #4)"
key_takeaways:
  - "A definition of done can be a human answer, and the spec can refuse to close on green checks alone."
  - "Write the failure next to the amendment. Changing a criterion after the evidence arrives is legitimate only if the original wording stays visible."
  - "The critic's job is to predict where you will fall short. Here it did, three times."
  - "Not running a check is acceptable; claiming you ran it is not. Deferral needs a home, a reason and a protocol."
open_items_for_author:
  - "Confirm the 'I' statements: you composed by direction and played; the AI authored coordinates, ran gates and conducted the interview."
  - "Add your own paragraph on what it felt like to play version 3 the first time (the quotes cover it, but a sentence in your voice now would help)."
  - "Decide whether to name the 'ten obvious moves' stretch as a known weakness on the website's play page, or leave it for players to find."
  - "Screenshot candidates: the Reference Knot at Fit Puzzle, and the accordion Level Select."
next_article: "Closing chapter: Now It's Your Turn (not yet written)"
---

# The Reference Knot: A Level Judged by a Human

*If you haven't played the Reference Knot yet, play it first. This chapter discusses how it was designed, and knowing what to look for changes the experience.*

At the end of Spec 009 the game had twenty-one puzzles, a solvability proof, a scoring contract, a camera that let a puzzle be bigger than the screen, and six knot experiments that told me which ingredients worked.

It did not have a level I'd hand to a friend.

Every puzzle in the catalog had been built to answer a question: does this rule work, does this structure measure the way we think, does the canvas hold up at fifty arrows, does long bent geometry feel good. None of them had been built to be *played*. Spec 010 asked for exactly one that was.

## A spec that green checks could not finish

The spec's Product Owner summary ends with this sentence:

> The spec is only finished when a human playtester genuinely wants to hand this level to someone else; green automated checks alone do not complete it.

That is an unusual thing to put in a software specification, and it changed how everything downstream worked. The solver could prove the level solvable. The regression gates could prove nothing else broke. Neither could say whether it was any good.

So the spec defined fifteen questions to ask after play, worded so they don't reveal what the player is supposed to notice. They cover first impressions, tracing, whether distinct areas appeared, aha moments, stalls, the ending, and boredom or frustration. The last one is the acceptance test:

> 15. Is this a level you want someone else to play? Why or why not?

The spec also fenced off the easy way out. **FR-010** forbids new mechanics: no locks, keys, colored regions, timers, scripted unlocks, or anything that encodes the intended order in code. Any sequencing has to come from the existing rule that an arrow leaves only if its path is clear. **FR-029** forbids generators, difficulty formulas and quality scores. The analyzer could describe a candidate, but it couldn't judge one.

Alongside the level, the spec grouped the catalog by purpose so the new level wouldn't be lost among twenty-one research boards: **Foundations** (8 rule-teaching puzzles), **Puzzle Lab** (13 experiments, including the canvas validation board), and **ArrowSpark Levels** (the Reference Knot). The groups are metadata only. They change Level Select, numbering and which puzzle "Next" leads to, never a rule. The spec also says the names must not imply a ranking: Puzzle Lab is not "worse," it exists for a different reason.

## The gates predicted the ending

Before any code, the analyze gate found eight problems in the planning artifacts and the critic gate found eleven, eight of them high. All were addressed in the spec and tasks before implementation started.

Most were ordinary planning fixes. Three are worth reading now, because they describe how this spec would end almost two days before it did:

- **critic-005:** the planned Level Select would give initial focus to a group header that can't take focus, leaving keyboard and gamepad users with nothing selected. The plan was fixed. A variant of the same bug, focus landing on an entry hidden inside a collapsed group, surfaced again in the PR review (H-02) and was fixed there with a regression test.
- **critic-007:** "One tester with growing familiarity supplies every discovery-based criterion. The 'want someone else to play' claim cannot be trusted as first-contact evidence." The suggested fix was a fresh tester or a recorded limitation. It ended as a recorded limitation.
- **critic-008:** the check that the puzzle can be solved in any valid order grows roughly quadratically with arrow count and might not fit the test launcher's time limit on a large board. It didn't fit. The check now samples every sixth branching state for this one board.

None of these was a surprise when it arrived. That is what a critic is for: not to stop the work, but to tell you in advance where you'll have to make a call, so that when you make it you're making a decision rather than discovering a problem.

## Three versions, two playtests

The level was composed through an author, validate, measure, play, revise loop. I directed and played; the AI wrote the coordinates, ran the solver and analyzer on every candidate, and kept the record. The full history is in the design report. In short:

| Version | Board | What changed | Human result |
|---|---|---|---|
| 1 | 25 arrows, density 0.24 | First composition around a hand-built skeleton | Played informally. Liked it; wanted far less empty space. |
| 2 | 59 arrows, density 0.69 | Long bent arrows added around the skeleton | Not played. |
| 3 | 115 arrows on 46×32, density 0.92 | Packed to under 10% empty cells, long arrows first | Played to completion. Kept. |

The first playtest was a paragraph typed straight after playing, quoted here unedited:

> "for feedback, the reference puzzle is good, would like less whitespace, really fill i tup with arrows, longer is better than shorter, would like a back button instead of being forced to finish every level to contiue, maybe a saved progress? i like the grouping would be nice if the grouping was collapsible like an accordion menu as it grows."

That one paragraph produced two new requirements on 2026-09-30. **FR-034** added a Back button that leaves a puzzle without finishing it and records no score. **FR-035** made Level Select groups collapsible. Saved progress was declined in writing and left for a future spec, because the session-memory boundary from Spec 007 still stands. The playtest changed the spec, and the spec recorded the change with a date instead of quietly growing.

Version 3 is the one that mattered. It has 115 arrows, 207 bends, a longest arrow of 43 cells, and only 6 legal moves at the start. The analyzer reports 661 dependency edges and a depth of 33. Those numbers are diagnostics. They describe the board, and nothing in the project uses them to decide whether it's good.

One of them did cause work. The analyzer's search for the longest dependency chain was exhaustive, and on a board this dense it couldn't finish. It was replaced with a linear-time search for acyclic dependency graphs that gives identical results, with new tests (`47bc1ab`). A content spec forced a tooling fix, which is the normal order of things here: tools grow when real content needs them, not before.

## The playtest that answered fifteen questions

The final playtest was run as a conversation. I played to completion, then the AI asked the fifteen questions one at a time and mapped my answers to the questionnaire, recording them verbatim. The game recorded the objective part: completed once, 2 mistakes, 2 Open Move assists, score 103 out of 115, played with mouse and wheel zoom.

A few answers carry most of the story. (Spelling is corrected in the quotes below for readability; the unedited answers are in the design report.)

On first sight: *"this is what I have been looking for, can't wait to dive in."*

On distinct areas, the answer contradicted the design. The level had been composed from named neighborhoods, a comb, a gate chain and a bridge. I didn't see any of them. What I saw instead:

> "a 'zone' gets created when you clear up a bunch of white space around a grouping of arrows … it only takes a bit of white space for your eyes to start seeing zones and your brain thinks about how do I clear this zone"

Neighborhoods weren't in the starting layout for the player. They **emerged** as arrows left. That is now recorded as a candidate design principle, and as a correction to how the level was designed.

On the strongest moment: a long arrow on the far right that "could not be taken out until the bottom row was resolved." Asked what changed when it went: "I saw 5 arrows I could click quickly, very satisfying." The design report notes this wasn't the bridge arrow the design intended. It was the one the player actually found.

On the ending: *"there were blocks all the way to the end … there was always something to try and figure out."*

On question 15: *"yes, I would be happy to have a friend play this level, it has achieved what I had in mind for an arrow puzzle game."* The interviewer confirmed it as an unqualified yes.

By the spec's own definition of done, it was done. Almost.

## The criterion that failed

**SC-005** said the playtest must record *no* stretch of following an obvious sequence for too long, *no* full-board rescans, and *no* tedious cleanup.

The answers recorded a mild obvious stretch in the middle (*"if you see 10 different arrows you can click on to clear, it starts to feel old"*) and a few rescans. Against the wording as written, SC-005 is not met.

But the same answers said the rescans were *liked*: they were what started the next discovery, and the Open Move hint made them a choice between quick and cheap. A short obvious run after a real insight felt like mastery. A small collapse at the end felt good. The criterion had treated each of those behaviors as a defect, when the evidence said only their *excess* hurts.

So the criterion was amended on 2026-10-01, and this is the part I'd point a skeptical reader to: **the original wording was kept above the amendment, and the disposition says plainly that against the original wording, SC-005 is not met.** Against the amended wording the rescanning and the ending pass, and the roughly ten simultaneously obvious moves in the middle "sit at the boundary of excess." That stretch is recorded as an accepted limitation, not a pass. I decided not to redesign for it.

Changing a test after the results come in is usually how people fool themselves. The defense isn't to never change one. It's to change it in the open, keep the old version next to the new one, say what failed under the old one, and give the reason the evidence supplied.

## The criterion that wasn't run

**SC-009** asked that someone other than me confirm a first-time visitor can find the ArrowSpark Levels group in Level Select without guidance.

It wasn't done. The project has one active designer and tester, and recruiting someone only to satisfy a development gate would have produced a weak test anyway. Instead it was deferred to the next spec, the Web Showcase, where genuinely new players can find the game on their own.

The deferral wasn't a line in a status field. It got its own file, `deferred-to-next-spec.md`, which preserves the test protocol: don't teach players the design vocabulary, don't coach, don't explain Level Select, observe first and then interview one question at a time, and record their words as given, including negative ones. It also states what this spec can and cannot claim:

> The Reference Puzzle was tested by its designer, who was familiar with earlier versions. No independent player has yet validated the experience.

That sentence appears in the spec, the design report, the verify gate and the current-state notes. It's critic-007's prediction, now a recorded fact.

## What "pass" was allowed to mean

The verify gate passed, and it says exactly what that pass covers:

> PASS means the evidence required to accept the feature is sufficient, no blocking verification failure remains, and every item that was not observed has an explicit accepted or deferred disposition. PASS does not mean those items were observed.

Then it lists them: no manual desktop smoke run, no physical keyboard or gamepad traversal, no numeric on-screen cell size, no independent player.

The pull request review took this seriously rather than rubber-stamping it. In three revisions it fixed three places where the durable knowledge contradicted the new code, fixed the hidden-focus bug, and removed an F3 developer readout. The readout had been added to measure on-screen cell size, never appeared on my desktop, and so hadn't achieved its purpose. The remaining items were carried with explicit dispositions. One of them, **CON-01**, is a finding about DevSpark itself: the constitution allows disclosing a check that *cannot* be run, but says nothing about an owner's decision *not* to run one. Depending on how you word it, the same shortfall reads as a violation or as a pass. The review referred that back to the framework as an improvement rather than bending the wording to fit.

The spec's closeout sorts every item into one of five buckets: passed, accepted limitation, deferred work, learning, failed. "Failed" has one entry, SC-005 against its original wording, and it stays there.

## The clock

| Milestone | When | Since Spec 010 began |
|---|---|---|
| Spec 010 specified | Sep 29, 20:59 | 0 |
| Analyze and critic findings resolved | Sep 30, 08:38 | 11h 39m |
| Groups, Level Select and Reference Knot committed | Sep 30, 15:38 | 18h 39m |
| Analyzer longest-chain fix | Sep 30, 16:59 | 20h 00m |
| Human playtest of version 3 recorded | Oct 1, 07:51 | 34h 52m |
| Spec closed with limitations | Oct 1, 09:01 | 36h 02m |
| PR #4 merged | Oct 1, 11:51 | 38h 52m |

About 39 hours of elapsed time, overnight gaps included. Grouped into sessions (a new session after a 90-minute gap), the commits bracket about 3 hours 42 minutes of visible activity. That figure undercounts this spec more than any other: the three versions and both play sessions happened between commits, and the 15:38 commit batches a day's composition work into four commits at the same minute. Treat it as a floor.

<!-- TODO(Mark): How long did you actually spend playing and directing versions 1-3? That's the human cost this spec cannot measure from git. -->

## What I'd take from this

1. **Put a human in the definition of done when the product is a feeling.** Green checks told me the level was correct. Only a person could tell me it was good, and the spec refused to close until one did.
2. **Let the critic tell you where you'll fall short, then decide on purpose.** All three predictions came true. None was a surprise, so each became a choice with a recorded reason.
3. **Amend criteria in the open.** Keep the original, say what failed under it, cite the evidence that changed your mind.
4. **Defer with a home.** A deferred check needs a file, a reason and a protocol, or it's just a check you skipped.
5. **The player's model beats the designer's model.** I designed neighborhoods; I experienced zones. The design report now says so.

## What's still open

One person has played the Reference Knot to the end, and it's the person who designed it.

That is the most important fact in this chapter, and the reason the next step is a website rather than another level. Everything in this series so far was built so that a stranger could open a link and play a hard puzzle that never punishes them. Whether it's satisfying is a claim I can only test on people who didn't build it.

---

## Receipts

Every claim above about timing or sequence can be checked against the repository history. Times are local, as recorded in the commit.

```text
git show --stat <hash>      # what a commit changed
git log --reverse --format='%h %ad %s' --date=format:'%Y-%m-%d %H:%M' e5cc3cb~1..6e60e11
```

| Commit | Time | Subject |
|---|---|---|
| `e5cc3cb` | 2026-09-29 20:59 | feat: add initial specification and requirements for the ArrowSpark Reference Puzzle |
| `dd82a9b` | 2026-09-29 21:07 | feat: update requirements and clarifications for the ArrowSpark Reference Puzzle |
| `cbdd11e` | 2026-09-30 08:28 | fix: resolve analyze findings for reference puzzle planning artifacts |
| `e0d2fc3` | 2026-09-30 08:38 | fix: resolve critic findings for reference puzzle planning artifacts |
| `c15564c` | 2026-09-30 15:38 | feat(catalog): add purpose groups and the Reference Knot |
| `f9b0e61` | 2026-09-30 15:38 | feat(menu): group-scoped play flow, accordion Level Select and Back button |
| `38f5ff4` | 2026-09-30 15:38 | docs(knowledge): describe level groups, accordion Level Select and Back |
| `c982e68` | 2026-09-30 15:38 | chore(planning): record implementation progress for the reference puzzle |
| `47bc1ab` | 2026-09-30 16:59 | Add tests for longest chain search and puzzle analysis |
| `b3aa17e` | 2026-10-01 07:51 | feat(puzzle): add F3 developer readout of on-screen cell size |
| `26cd921` | 2026-10-01 07:51 | chore(planning): record the human playtest of the Reference Puzzle |
| `4aba5e7` | 2026-10-01 08:01 | chore(planning): defer fresh-player validation to the next spec |
| `6941414` | 2026-10-01 09:01 | docs(spec-010): close Reference Puzzle with documented limitations |
| `313d5e6` | 2026-10-01 11:08 | chore(planning): record verify gate as pass with limitations preserved |
| `4998d18` | 2026-10-01 11:27 | fix(pr-4): address PRD1-01, PRD1-02, PRD1-03, H-02, M-01 |
| `6851baf` | 2026-10-01 11:31 | fix(pr-4): remove F3 readout and restore bounded order-independence check |
| `72e52ea` | 2026-10-01 11:32 | review(pr-4): rev 3 — dispositions recorded, re-review approves |
| `6e60e11` | 2026-10-01 11:51 | Merge pull request #4 from MakeBoldSolutions/010-spec-reference-puzzle |

Omitted from the range as unrelated to Spec 010: `8101b00` (articles 5–7 of this series), `95a96ab` (an addon return-type fix, noted in the PR review as L-01), `8b11dec` (knowledge note for the F3 readout), `6462da0` and `6a57eb6` (PR review bookkeeping).

Evidence files: the spec and its closeout table (`.devspark.work/specs/010-spec-reference-puzzle/spec.md`), the critic and verify gates (`gates/critic.md`, `gates/verify.md`), the deferral protocol (`deferred-to-next-spec.md`), the PR review (`.devspark.work/pr-review/pr-4.md`), and the durable design report with the verbatim playtest answers (`.knowledge/reference/reference-puzzle-design-report.md`).
