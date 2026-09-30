---
title: "Pulling the Thread: Knots, Audits, and What DevSpark Learned from a Game"
series: "Building ArrowSpark with DevSpark"
part: "7 of 7"
slug: pulling-the-thread
status: first-draft
author: Mark Hazleton
date_drafted: 2026-09-30
theme: "Synthesis and honesty: the Gordian-knot experiments, the audit that caught the project breaking its own rule, the level that isn't done until a human wants to share it, and what the method learned about itself."
description: "Six knot experiments recorded with unusually honest evidence, a site audit that found leaked planning references, the Reference Puzzle spec with its human completion bar, and a set of lessons for DevSpark and for developers entering a new domain."
wall_clock: "Spec 009: implementation commit 2026-09-29 07:37 to PR #2 merge 09:17 (1h40m). Whole project: first commit 2026-09-26 10:41, nine specs merged by 2026-09-29 09:17 (70h36m elapsed), last commit 21:07 (82h26m); about 19h of commit-bracketed session time."
purpose: "Close the series by returning to the original premise (a puzzle that never punishes, built by a non-game developer using DevSpark), assessing what was proved and what was not, and leaving the reader with transferable lessons and an honest picture of what is still unfinished."
audience: "The full series audience; especially readers deciding whether to try spec-driven, AI-assisted development in a domain where they are a beginner."
specs_covered: ["009-spec-gordian-knot-experiments", "010-spec-reference-puzzle (specified, not implemented)", "site audit 2026-09-29 and PR #3"]
evidence_sources:
  - .knowledge/reference/gordian-knot-experiments.md
  - .devspark.work/specs/010-spec-reference-puzzle/spec.md
  - .devspark.work/audit/2026-09-29_results.md
  - .devspark.work/pr-review/pr-2.md
  - .devspark.work/development/12-devspark-lessons.md
  - .devspark.work/development/13-roadmap-008-010.md
  - .knowledge/guides/repo-story/repo-story-2026-09-30.md
  - "git log: c621817, 973bc93, 8a00239 (PR #2), b4864ed, 312b0c7 (PR #3), e5cc3cb, dd82a9b"
key_takeaways:
  - "Record what you did not measure as 'unknown', never as 'zero' or 'inconclusive verdict'."
  - "Your own process needs auditing; the audit caught the project breaking its own temporary-vs-durable rule."
  - "A definition of done can be a human's honest answer: 'I want someone else to play this.'"
  - "Sequence matters: understand rules, contract, viewport, hand-authored knots, human evidence; and only then consider generation."
open_items_for_author:
  - "UPDATE this article once Spec 010's Reference Puzzle passes or fails its human playtest bar."
  - "Decide whether to publish the honest limits (one author, one session, familiar with the design) in the article body or a callout."
  - "Add a closing personal paragraph on what you would do differently."
next_article: "none (series end)"
---

# Pulling the Thread: Knots, Audits, and What DevSpark Learned from a Game

In the first article I said ArrowSpark had two jobs: be a good puzzle, and be an honest test of a method. This last article grades both, and the honest grade is *partial, and here's precisely how.*

## Spec 009: tying the knots

With a contract (Spec 007) and a canvas (Spec 008) in place, I finally wrote the puzzles Spec 006 had pointed toward. Spec 009 added six hand-authored **Gordian knot** experiments, taking the catalog from fifteen puzzles to twenty-one. Each began with a stated hypothesis:

| Puzzle | Hypothesis it tested |
|---|---|
| Long Geometry | Long bent paths may satisfy even without much interweaving |
| Interwoven Paths | Nearby winding paths may raise tracing demand |
| Dense Core | Concentrated adjacent geometry may be challenging yet readable |
| Distinct Regions | Separated regions may make a large puzzle approachable |
| Single Release | Removing one prominent long arrow may visibly simplify the board |
| Boundary Knot | Too much winding may tip into tedium while staying completable |

The last one was deliberate. The design notes call for a puzzle that is probably *too* entangled, not to ship it but to locate the boundary where challenging tracing turns into visual spaghetti. It's a 48×36 board with 28 arrows, more than 500 occupied cells, and 51 dependency edges, all solver-confirmed completable.

### How the results were recorded

Every puzzle has objective measurements from the analyzer and solver: board size, occupancy, arrow lengths, bends, legal-move counts, dependency edges, cascade fan-out, the full witness. Those are facts.

Then there's the human evidence, and it's small, and the document says so with unusual bluntness. It's **one aggregate author play session across all six puzzles.** Per-puzzle completion, mistakes, assists, and zoom use were not recorded. The document marks them **unknown, not zero.** Each entry ends with limits: *one author, one session, familiar with the design, play order not recorded.*

The verdicts follow that honesty. Long Geometry, Interwoven Paths, and Single Release came out *Supported* by the session. Dense Core, Distinct Regions, and Boundary Knot came out *Inconclusive*. That's not a failure; it's a refusal to pretend. The documented bottom line is that the six experiments produced **a vocabulary and a toolbox, not a recipe.**

The vocabulary is the lasting output: *meaningful density*, *neighborhood*, *cross-neighborhood dependency*, *bridge arrow*, *insight chain*, *discovery beat*. They're words for design discussion, explicitly not analyzer metrics and not gameplay state. The strongest emerging insight is about rhythm: the best moments weren't finding one legal arrow, but understanding *several consequences at once*, then executing briefly, watching the board change, and having to stop and rethink. One giant discoverable sequence turns the player into an executor. Re-scanning the whole board after every move is exhausting. A good level alternates.

### The clock: an hour and forty minutes

The Spec 009 implementation commit landed at 07:37 on September 29th. The pull request was merged at 09:17. **One hour forty minutes**, for six puzzles, report tooling, evidence, and a pull-request review that found and fixed a planning reference in a knowledge document before merge. (The large commit surely contains earlier work, so read this as commit-to-merge, not effort.) It's the fastest turnaround of any spec, and it's fast for a reason: the canvas, the contract, the analyzer and the solver were already there. Each earlier spec had made this one cheaper.

## The audit that caught me

DevSpark has an audit command, and I ran it against the merged Spec 009 work. Overall health: **needs attention, no confirmed gameplay defect.** Zero critical findings, one high, two low. Both regression launchers passed.

The high finding is the one I want to talk about. It wasn't runtime. It was that **temporary review identifiers had escaped into durable code**: a comment in a menu script and a test citing an internal critic finding ID, plus a line in the test README. I had built a project around one rule (durable files must never point back at temporary planning) and I'd broken it, three times, in comments that explained *why* a menu grabs focus.

The repair was to keep the behavior and the explanation and delete the citation. Instead of pointing at a review ID, the comment says what's true: the inherited submenu mechanism doesn't move focus, so this menu focuses its first entry itself. A comment that stands on its own is worth more than one that sends you looking for context that will be archived.

The same audit found a plain **documentation drift**: the test README said "15 catalog entries" and "eight independent checks" while the code asserted 21 entries and ran nine puzzle suites. The tests were fine; the words were stale. Both fixes shipped as a chore pull request. A PR review earlier had already caught a planning reference in a knowledge document, which I fixed and re-verified before merging Spec 009.

I take two things from this. First, a rule you don't audit is a wish. Second, the *checks* that caught it, a repo-wide reference scan and a review command, were written by the same process I was testing. It works when it's allowed to find fault with itself.

## Where it stands: Spec 010

As I write this, the game has twenty-one puzzles and no level I would yet hand to a stranger.

Specs 001 to 009 produced a working game, a scoring contract, a large canvas, and a toolbox of knot ingredients, but no single level that shows what ArrowSpark is *supposed* to feel like. Spec 010 is specified but not built. It asks for exactly one **Reference Puzzle**: a hand-crafted knot with several distinct *aha* moments, regions that can be mostly cleared but not finished until you understand something elsewhere, a few bridge arrows that visibly unwind, and a collapse at the end that isn't tedious cleanup.

It also adds lightweight groups (Foundations, Puzzle Lab, and ArrowSpark Levels) so the reference level isn't lost among twenty-one research puzzles. That's metadata only, with no rule changes, and it deliberately implies no quality ranking.

What I like most is its definition of done. The spec includes a fifteen-question playtest questionnaire, asked after play so the questions don't reveal the discoveries. Question 15 is: *"Is this a level you want someone else to play? Why or why not?"* The spec is explicit that **green automated checks alone do not complete it.** It's finished when a human honestly wants to hand this level to someone else.

A definition of done that ends in a person's honest answer is unusual in a software spec. It fits a game.

## The whole clock

Here's the entire project on one page. Times are local, from the commit log.

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

Nine specs in about seventy hours of elapsed time. Grouping commits into sessions (a new session after a gap of ninety minutes) gives thirteen sessions and about nineteen hours of visible activity. Seventy commits, forty-one touching tests, three merged pull requests.

I want to be careful with what these numbers do and don't prove.

- **They are not a timesheet.** Elapsed time includes nights. Commit timestamps miss work before a session's first commit.
- **They don't prove the game is good.** They prove the *process* was fast and inspectable, and that its output was checkable at every step.
- **They aren't a solo-typist's numbers.** AI ran the specification, planning, gating and implementation steps. My part was the decisions, the reviews, the playtests, and the acceptance. That division is the entire point of the method.
- **They can't be compared to a baseline I haven't stated.** I'm deliberately not claiming a speed-up multiple.

<!-- TODO(Mark): State your real hours and your honest estimate of the same scope without DevSpark, in your own words. This is the paragraph readers will quote. -->

What the numbers *do* support is narrower and, I think, more useful. A developer with no game experience produced, in three and a half days, a puzzle game with a proven solvability guarantee, a documented design philosophy, forty-one test-touching commits, two required regression gates running in CI, and a body of honestly recorded evidence about what works and what doesn't. That is not what an improvised weekend project looks like. It's what a disciplined expert's process looks like when the tool removes the friction from the discipline.

## What DevSpark learned

From the notes I kept along the way, here's what the method took from a game:

1. **The lifecycle transfers, but the risk surface differs.** Focus, input modes, animation lifecycle, node cleanup, resize, pause, and "logical vs. presentation state" barely appear in API work. A game-aware Critic should carry a checklist of *questions* (does a newly opened menu establish focus? can a tween outlive its node?) that produce hypotheses to investigate, not automatic defects.
2. **Never claim structure that doesn't exist.** If the tool says it traversed a dependency, that dependency must be real. Analyze caught this twice.
3. **Discoverability is correctness.** A correct document that no future agent will find is effectively missing.
4. **Severity needs a second axis.** "Critical" once meant a context-integrity defect and not a runtime disaster. Separating *severity* from *impact domain* would prevent alarm and complacency alike.
5. **Manual verification is a legitimate outcome.** Say what was automated, what was checked by hand, and what wasn't checked.
6. **Human evidence can outrank a green experiment.** Spec 006 is the canonical case.
7. **Small specs preserve learning.** Jumping from solver to generator would have skipped visual geometry, departure behavior, the session contract, and the viewport, each of which changed what a generator would need to optimize.
8. **Explore loosely, ship precisely.** Metaphors, hypotheses, and unusual experiments belong in planning. Rules, solver validation, and deterministic tests belong in production. "Vibe in planning, not in production."

## What's still open

What is unresolved:

- **The reference level doesn't exist yet.** Everything above is preparation for it.
- **The evidence is thin.** One author, familiar with the design, one aggregate session. I need outside players, and a web build that lets someone play from a link is the sensible way to get them, along with an anonymous feedback path that keeps the no-identity rule.
- **Generation is deliberately last.** The order is: rules, contract, viewport, hand-authored knots, human evidence, *then* maybe a generator that encodes what people actually enjoyed. Otherwise I'd teach a machine to optimize numbers no human cares about.
- **"Hard but never unsolvable" is a claim I can prove, but "satisfying" is one I can only test on people.**

## Back to the gap

I started with a puzzle app problem: too much machinery between the player and the puzzle. Three and a half days later I have a game that keeps a promise, *you can always keep going; the only cost of being wrong is score*, and a proof that the promise holds for every puzzle in the catalog.

Whether it's good is not something the tests can tell me. That question needs human players.

The most valuable thing I did wasn't write code. It was ask, after every step, *what did we just learn, and what's the smallest next question?* DevSpark gave me a structure for asking. The game gave me a place where the answers were surprising. If you're a business developer standing at the edge of some unfamiliar domain, that combination is the thing I'd recommend: **a method that makes you write down what you believe, and a project that's willing to prove you wrong.**

Now I need someone else to play it.

---

## Receipts

Every claim above about timing or sequence can be checked against the repository history. Times are local, as recorded in the commit.

```text
git show --stat <hash>      # what a commit changed
git log --reverse --format='%h %ad %s' --date=format:'%Y-%m-%d %H:%M'
```

| Commit | Time | Subject |
|---|---|---|
| `c621817` | 2026-09-29 07:37 | Spec 009: add six Gordian Knot experiment puzzles, report tooling and evidence |
| `bd61aa8` | 2026-09-29 07:50 | feat: add summary documentation for Spec 008 - Large Zoomable Puzzle Canvas and implement run-app script |
| `973bc93` | 2026-09-29 08:38 | fix: clarify the impact of structural and geometric puzzle experiments on level composition |
| `1ea93a8` | 2026-09-29 09:15 | feat: add detailed PR review documentation for six Gordian Knot puzzles and structural experiments |
| `8a00239` | 2026-09-29 09:17 | Merge pull request #2 from MakeBoldSolutions/009-spec-gordian-knot-experiments |
| `b4864ed` | 2026-09-29 10:49 | Add regression and structural audit logs for September 29, 2026 |
| `498e714` | 2026-09-29 20:50 | feat: add pull request review documentation and site audit evidence |
| `312b0c7` | 2026-09-29 20:50 | Merge pull request #3 from MakeBoldSolutions/chore/address-site-audit-2026-09-29 |
| `e5cc3cb` | 2026-09-29 20:59 | feat: add initial specification and requirements for the ArrowSpark Reference Puzzle |
| `dd82a9b` | 2026-09-29 21:07 | feat: update requirements and clarifications for the ArrowSpark Reference Puzzle |
