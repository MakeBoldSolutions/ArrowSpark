---
title: "Pulling the Thread: Knot Experiments and the Audit That Caught Me"
part: 7
slug: pulling-the-thread
description: "Six hand-built knot experiments, recorded with unusually honest evidence, produced a vocabulary rather than a recipe. Then an audit caught the project breaking its own rule about temporary planning notes."
spoiler: true
status: published
sources:
  - label: "Six knot experiments"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/pull/2
  - label: "Experiment report (knowledge)"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/blob/6e60e117acc175a47feb55f52a3a8da1c6cedaab/.knowledge/reference/gordian-knot-experiments.md
  - label: "Audit fixes"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/pull/3
updated: 2026-10-02
---

In [the first chapter](/story/finding-the-gap/) I said ArrowSpark had two jobs: be a good puzzle, and be an honest test of a method. This chapter is where both jobs met hard evidence: six experiments that turned out to be a vocabulary rather than a recipe, and an audit that caught the project breaking its own rule.

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

The Spec 009 implementation commit landed at 07:37 on September 29th. The pull request ([#2](https://github.com/MakeBoldSolutions/ArrowSpark/pull/2)) was merged at 09:17. **One hour forty minutes**, for six puzzles, report tooling, evidence, and a pull-request review that found and fixed a planning reference in a knowledge document before merge. (The large commit surely contains earlier work, so read this as commit-to-merge, not effort.) It's the fastest turnaround of any spec, and it's fast for a reason: the canvas, the contract, the analyzer and the solver were already there. Each earlier spec had made this one cheaper.

## The audit that caught me

DevSpark has an audit command, and I ran it against the merged Spec 009 work. Overall health: **needs attention, no confirmed gameplay defect.** Zero critical findings, one high, two low. Both regression launchers passed.

The high finding is the one I want to talk about. It wasn't runtime. It was that **temporary review identifiers had escaped into durable code**: a comment in a menu script and a test citing an internal critic finding ID, plus a line in the test README. I had built a project around one rule (durable files must never point back at temporary planning) and I'd broken it, three times, in comments that explained *why* a menu grabs focus.

The repair was to keep the behavior and the explanation and delete the citation. Instead of pointing at a review ID, the comment says what's true: the inherited submenu mechanism doesn't move focus, so this menu focuses its first entry itself. A comment that stands on its own is worth more than one that sends you looking for context that will be archived.

The same audit found a plain **documentation drift**: the test README said "15 catalog entries" and "eight independent checks" while the code asserted 21 entries and ran nine puzzle suites. The tests were fine; the words were stale. Both fixes shipped as a chore pull request ([#3](https://github.com/MakeBoldSolutions/ArrowSpark/pull/3)). A PR review earlier had already caught a planning reference in a knowledge document, which I fixed and re-verified before merging Spec 009.

I take two things from this. First, a rule you don't audit is a wish. Second, the *checks* that caught it, a repo-wide reference scan and a review command, were written by the same process I was testing. It works when it's allowed to find fault with itself.

At this point the game had twenty-one puzzles, a toolbox of knot ingredients, and no level I would yet hand to a stranger. [Next](/story/the-reference-knot/): one level, composed by hand and judged by a person.

---

## Receipts

Every claim above about timing or sequence can be checked against the repository history. Times are local (US Central), as recorded in each commit; each hash links to the commit on GitHub. Subjects are quoted from the log, except that internal planning identifiers are replaced by a short description.

```text
git show --stat <hash>      # what a commit changed
git log --reverse --format='%h %ad %s' --date=format:'%Y-%m-%d %H:%M'
```

| Commit | Time | Subject |
|---|---|---|
| [`c621817`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/c62181768282b6371ae40b0d6a41a89e45ab510d) | 2026-09-29 07:37 | Spec 009: add six Gordian Knot experiment puzzles, report tooling and evidence |
| [`bd61aa8`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/bd61aa80023508c8a6389cc2a5003e22b00939dc) | 2026-09-29 07:50 | feat: add summary documentation for Spec 008 - Large Zoomable Puzzle Canvas and implement run-app script |
| [`973bc93`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/973bc9350cf681fd1012f047c4ab86d4e04df985) | 2026-09-29 08:38 | fix: clarify the impact of structural and geometric puzzle experiments on level composition |
| [`1ea93a8`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/1ea93a806323686229f202cb1450f268dd5a16d6) | 2026-09-29 09:15 | feat: add detailed PR review documentation for six Gordian Knot puzzles and structural experiments |
| [`8a00239`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/8a00239b2fdb2a05ccbbb11a0ac96fab28353914) | 2026-09-29 09:17 | Merge pull request #2 from MakeBoldSolutions/009-spec-gordian-knot-experiments |
| [`b4864ed`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/b4864edeae36bef180d6cdc8b5fa0d86cd5c1bf6) | 2026-09-29 10:49 | Add regression and structural audit logs for September 29, 2026 |
| [`498e714`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/498e714239f008d6556e1950c4eef49baf4a4fc5) | 2026-09-29 20:50 | feat: add pull request review documentation and site audit evidence |
| [`312b0c7`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/312b0c7d72471912598dc7017c83b3f2f9fe3e7f) | 2026-09-29 20:50 | Merge pull request #3 from MakeBoldSolutions/chore/address-site-audit-2026-09-29 |
| [`e5cc3cb`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/e5cc3cbc9cc83f55a8a29b8d539d19914cc96624) | 2026-09-29 20:59 | feat: add initial specification and requirements for the ArrowSpark Reference Puzzle |
| [`dd82a9b`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/dd82a9b0968f742787c50954efa16ebf7c5414f5) | 2026-09-29 21:07 | feat: update requirements and clarifications for the ArrowSpark Reference Puzzle |
