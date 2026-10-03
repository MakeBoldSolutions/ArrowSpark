---
title: "The Contract Before the Difficulty, the Canvas Before the Content"
part: 6
slug: contract-before-difficulty
description: "Before making the game harder, Spec 007 wrote down the player's guarantees and added Show Me an Open Move, and Spec 008 made the puzzle bigger than the screen. The verify gate finished as warn, and that was the honest result."
spoiler: false
status: published
sources:
  - label: "Open Move and session scoring merged"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/f53469161728569432837c286791f80b655ca0bd
  - label: "Large zoomable canvas"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/pull/1
  - label: "Gameplay contract (knowledge)"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/blob/6e60e117acc175a47feb55f52a3a8da1c6cedaab/.knowledge/product/gameplay-contract.md
updated: 2026-10-02
---

After Spec 006 I knew where the difficulty was: long, bent, interwoven arrows. The obvious next step was to author some.

I didn't. Two things stood in the way, and the interesting work of Specs 007 and 008 was noticing that they came first.

## Why the promise has to come first

If you set out to make boards that initially look overwhelming, you're implicitly asking the player to trust you. They need to know that "overwhelming" won't become "impossible," and that being stuck won't cost them the game.

In Spec 007 I wrote that trust down as a contract, and the phrasing became the project's spine:

> **Hard is good. Unsolvable is not.**
> **Mistakes cost score, not play.**
> **Completion is expected; efficiency is scored.**
> **There is always a way out. The challenge is seeing it.**

The last line is the hinge. The solver from [Part 3](/story/provably-solvable/) proves a way out *exists*. The player might not be able to *see* it. So the game needed a way to help without taking over.

### Show Me an Open Move

The feature is called **Show Me an Open Move**. It answers exactly one question: *show me one arrow that can leave right now.*

It's deliberately narrow:

- It highlights exactly one legal arrow, deterministically for an unchanged board.
- It does **not** remove the arrow. The player still makes the move.
- It does **not** reveal a sequence, and doesn't claim the move is best.

This is the difference between a hint and a solver button. A solver takes the puzzle away from you. An Open Move gives momentum back to someone who's stuck, and leaves the thinking to them.

### Cost without scarcity

Assistance isn't free, but it's never rationed. The hierarchy is:

| Action | Cost |
|---|---|
| Look at the board | Free |
| Try a blocked arrow | 1 point |
| Show Me an Open Move | 5 points |
| Keep playing | Always allowed |

The score formula reads `max(total_arrows - (mistakes + open_move_assists × 5), 0)`, and mistakes and assists are counted separately. A perfect run scores every arrow. A player who needs help several times can still *finish*, and finishing is expected. Score measures efficiency, not access. Replay becomes the mastery loop rather than a recovery from failure.

The feature also carries a principle worth stating outright: **the player can never be locked out by their own choices.** No lives, no waiting, no watch-to-continue, no pay-to-continue. The spec lists those as explicit non-goals, so a future feature can't sneak one in by accident.

### The session is the memory boundary

The other half of the contract is a decision about what the game remembers. Best score per puzzle and an overall session total exist only for the running session. When it ends, that history ends. There's no profile, no login, no anonymous persistent ID, no cross-session score history.

That's a product decision, not an omitted feature, and it's written down as one. Persistence would have been easy to add. Deliberately leaving it out keeps the game honest about what it is right now, and it kept a new scoreboard class out of the inherited save system. It's also easy to reverse later, and hard to un-ship.

## What the gates found, and how they were handled

The Analyze gate mapped all 21 functional requirements to tasks. Two findings came back, neither about gameplay:

- The plan described a formal `depends_on` relationship that the repository's knowledge schema doesn't contain. That's a *context-integrity* defect: an assistant narrating structure that isn't there.
- The new scoreboard's file paths weren't reflected in the relevant knowledge documents' `appliesTo` metadata, so future agents wouldn't have found them.

The lesson I took: **knowledge that can't be found is effectively missing**, and updating metadata belongs inside the implementation tasks.

Critic found no showstoppers, and its findings are a good tour of what a game-aware review notices:

**Static state leaks between tests.** The scoreboard holds session state in static variables, so one test could pollute another. The tempting fix was a `reset()` method on the production class. Critic's recommendation was better: use a unique synthetic puzzle ID in each test, and leave production alone. Don't bend the shipped design to suit the test.

**Open Move after completion.** Without an explicit guard, someone could request assistance on a finished attempt and mutate it. That's a lifecycle bug waiting for a rare click, and it got a test.

**Sanity checks without duplicated rules.** Validate the shape and range of completed-result data, but never re-implement scoring in the scoreboard.

One deviation is instructive. A keyboard and gamepad navigation test originally simulated key presses headlessly, and it was nondeterministic. The right response wasn't to keep massaging it until it usually passed. The team automated what could be reliably proven, focus eligibility and signal wiring, and kept a real desktop check for the actual navigation. Spec 007 closed with the automated markers at zero and five manual desktop checks passed on September 28th. The line I wrote in the notes is one I'd tell any team: *do not turn flaky simulation into false confidence.*

## Spec 008: the puzzle defines the world

Now the second obstacle. Every puzzle so far was fit to the screen. Make the board bigger and the arrows got *smaller*, which hurts readability, tracing, selection, and accessibility all at once.

If I authored dense, hard knots now, they would be distorted by whatever screen I happened to develop on. So Spec 008 removed the constraint first, under one principle:

> **The puzzle defines the world. The screen is only a window into it.**

The spec separated four things that had been tangled together:

- **Board size**: the logical world defined by the puzzle.
- **Geometric density**: how much meaningful geometry occupies a region.
- **Viewport**: what part of the world is visible.
- **Zoom**: the scale at which you're looking.

A 20×20 puzzle should mean a bigger *world*, not tinier arrows.

### What was built

A single new class, `PuzzleViewportTransform`, became the only place that converts between logical grid, board-local, and screen coordinates, and its math has its own unit tests independent of any scene. On top of it: bounded zoom, pan, and a **Fit Puzzle** button to restore the overview. All of it is reachable by mouse, keyboard, and gamepad, and coexists with the configurable-input system.

The behaviors that turned out to matter:

- **Pan versus select.** Long, bent arrows are easy to mis-click, so dragging to move the view must never select an arrow.
- **Open Move off-screen.** Asking for help brings the target into view, without changing its cost or contract.
- **Departures under a moving camera.** A bent arrow's animation keeps its authored route through zoom, pan, and resizing, and completion is triggered by *logical* clearance, not by leaving the visible area.
- **Camera is presentation only.** No zoom or pan state is persisted, and every replay starts with a fresh Fit Puzzle overview.

To exercise it, the catalog gained puzzle 15: a 52-arrow fixture of long, bent geometry, built specifically to overflow both axes. I measured its performance with eight departures animating at once: handler time p95 of about 0.09 ms against a 2 ms budget, and frame time p95 about 17 ms against 33 ms. Both regression gates passed on Godot 4.4 (the declared target) and 4.7.2, each run twice on fresh mirrors.

One more find along the way. At 960×540, the fifteen-entry Level Select list clipped its first and last entries. It was fixed with a focus-following scroll container. It's the kind of bug you only meet when you run the thing at a real size.

### The verify gate said "warn," and that's fine

Spec 008 merged as the project's first GitHub pull request ([#1](https://github.com/MakeBoldSolutions/ArrowSpark/pull/1)). Its verify gate finished with a **warn**: the end-to-end mode passed on automated and operator evidence, but several scenarios were explicitly accepted as outstanding rather than claimed as passed. I could have written "all verified." The process wouldn't let me, and I don't think it should have.

## The clock: what each of these cost in wall time

| Spec | Trail | Wall clock |
|---|---|---|
| 007 Open Move and scoring | Implementation commit 21:18 on the 27th; completion and merge 07:42 on the 28th | about 10h, overnight included; automated gates green and manual desktop checks recorded by the morning |
| 008 Zoomable canvas | Specification commit 09:07; PR #1 merged 15:45 | **6h 38m** from first spec commit to merged PR, covering spec, plan, tasks, checklist, analyze and critic gates, implementation, roughly 1,175 lines of canvas tests, performance measurement, and the PR |

Read the second row twice. In a single day, a feature that changes how coordinates flow through the presentation layer went from its first spec commit to a merged pull request, with a performance budget met and both regression gates passing on two Godot versions, each run twice. (A direction brief existed beforehand, so this isn't a blank page, but the specification, gates and implementation all sit inside that window.)

That isn't speed from cutting corners. The risks that hurt most if found late (coordinate transforms, drag versus click, focus on off-screen content, camera changes during animation) were written down as first-class questions before implementation, so there were fewer late surprises to absorb time. The time went where an expert would want it.

## Why the order mattered

Look at the sequence again:

1. Spec 006: discover that geometry is the difficulty lever.
2. Spec 007: build the promise that makes harder safe.
3. Spec 008: build the space harder content needs.
4. *Then* author the knots.

Each spec answered one question and removed one constraint. If I'd authored knots first, I'd have distorted them to the screen and had no help for a stuck player. If I'd built a generator first, I'd have optimized the wrong thing. Small specs preserved the learning; I couldn't have ordered them this way if each had been a giant feature.

Next: the knot experiments.

---

## Receipts

Every claim above about timing or sequence can be checked against the repository history. Times are local (US Central), as recorded in each commit; each hash links to the commit on GitHub. Subjects are quoted from the log, except that internal planning identifiers are replaced by a short description.

```text
git show --stat <hash>      # what a commit changed
git log --reverse --format='%h %ad %s' --date=format:'%Y-%m-%d %H:%M'
```

| Commit | Time | Subject |
|---|---|---|
| [`83062c5`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/83062c5c4af9753c720ae114479b1430fbc2b5cd) | 2026-09-27 21:18 | feat: Implement Open Move Assistance and Session Scoring |
| [`0468e54`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/0468e54a3101e04c991915003511e75451a6b053) | 2026-09-28 07:40 | feat: Update status to complete and verify user stories for Open Move Assistance and Session Scoring |
| [`f534691`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/f53469161728569432837c286791f80b655ca0bd) | 2026-09-28 07:42 | Merge 007-spec-open-move-scoring: Open Move assist and session scoring |
| [`0c35c39`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/0c35c3979674f10ebb583fdad901171bb42e79a7) | 2026-09-28 08:04 | feat: Add knowledge integrity validation script and supporting files |
| [`ada2ae2`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/ada2ae24b725cf13b9f5586a7d2f6f15c8b0f6d5) | 2026-09-28 09:07 | Add specification and tasks for Large Zoomable Puzzle Canvas feature |
| [`4070c6e`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/4070c6e159a983495f24993210a2428f073cae0c) | 2026-09-28 09:29 | feat: Update Large Zoomable Puzzle Canvas specifications and tasks for improved clarity and functionality |
| [`4ea159d`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/4ea159d8ab564bd554370f6748ab05e2a4c855bf) | 2026-09-28 09:38 | feat: Enhance Large Zoomable Puzzle Canvas specifications and tasks for improved clarity and functionality |
| [`b165b17`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/b165b1750ab8d3422a710b696a64ea1c69de712b) | 2026-09-28 09:40 | Add full specification, analysis, and critique for Open Move scoring feature |
| [`924280f`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/924280f936733cf1d6b3bc7d4fd1a76d11e11901) | 2026-09-28 11:15 | feat: Update documentation for Spec 008 - Large Zoomable Puzzle Canvas, reflecting current status and implementation details |
| [`a60c171`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/a60c1712f0030a57e9cc03591af29f6b45ccd215) | 2026-09-28 14:23 | Add visual and viewport transform tests for puzzle canvas |
| [`faa4575`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/faa45758a24cc6ed278699a471b5944dbefebfea) | 2026-09-28 15:45 | Merge pull request #1 from MakeBoldSolutions/008-spec-large-zoomable-canvas |
