---
title: "Finding the Gap: A Puzzle That Never Punishes You"
part: 1
slug: finding-the-gap
description: "Why I set out to build a puzzle game that never traps or punishes the player, why I chose Godot and GDScript over my comfortable C# habits, and why the first playable arrived 3h14m after the first commit only because a constitution, spec, plan and review gates came first."
spoiler: false
status: published
sources:
  - label: "First commit"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/e228500c67b2c0e85cbea72a13e633e79c5480dd
  - label: "Constitution requiring verification"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/ce55cd4e6b7ea8c048428b88433b58962546932d
  - label: "First playable (Spec 001)"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/0ec2dda8a4748c40b8bf42d8ed769a7a7d855236
  - label: "Constitution as of Spec 010"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/blob/6e60e117acc175a47feb55f52a3a8da1c6cedaab/.knowledge/governance/constitution.md
updated: 2026-10-02
---

I build business software. Most of my career has been C#, .NET, APIs, and the unglamorous machinery that keeps organizations running. I have never shipped a game.

In late September 2026 I started one anyway. The first commit landed at 10:41 on a Saturday morning. About 121 hours of wall-clock time later, ten specifications had been designed, reviewed, implemented, verified and merged. The game has a catalog of twenty-two puzzles, a solver that proves each one can be finished, a zoomable canvas, a scoring system, and one level built to be played rather than to answer a research question. It also has a design philosophy I didn't have when I started, and that philosophy is the real product.

I want to be precise about that number, because it's the heart of this series. It is elapsed time, overnight gaps included. It is not a claim that I sat typing for 121 hours, and it is not a claim that the game is finished. It *is* a claim about what happens when an experienced developer applies disciplined process, and a tool built around that process, to a domain he's never worked in.

This is the first of nine chapters about how that happened. It starts with the gap, and then it starts the clock.

## This is not a vibe-coding story

Let me get ahead of a misreading. A five-day game from a developer with no game experience sounds like someone typing prompts and hoping. It wasn't, and the history shows why.

Look at what happened *before* the first playable arrow, all on the first day:

| Time | What landed |
|---|---|
| 10:41 | Fresh repository from a game template |
| 11:45 | A constitution: mandatory verification and gameplay validation |
| 11:59 – 12:08 | Save and settings recovery, with regression tests, before any game existed |
| 12:26 – 13:13 | Specification, plan, tasks, and two rounds of Analyze and Critic gates |
| 13:19 | A gate finding fixed: one task split so tests come before implementation |
| 13:55 | First playable puzzle implemented |

Twelve commits of governance, recovery, specification, planning and review. Then the implementation, 3 hours and 14 minutes after the first commit. The process wasn't a tax on that speed. It was the reason the speed was safe.

What I brought to the table wasn't game knowledge. It was habits: write down the promise before building it, make bad states unrepresentable, keep the rules testable without a screen, ask an adversarial reviewer what could go wrong before the code exists, and refuse to call something verified when it wasn't. DevSpark turns those habits into a repeatable loop that an AI can run at speed while I decide, review and accept. The decisions were mine. The pace was the tool's.

## The gap

The game is called ArrowSpark. The idea is simple. A board is full of arrows. Each arrow points up, down, left, or right. You select one. If nothing is in its way, it slides off the board. If something is in its way, it stays put. Clear the board and you win.

It's a satisfying loop, and I'd seen it in the arcade-style puzzle apps I'd tried. What I kept noticing was everything *around* the loop: lives that run out, timers, "watch an ad to continue," retry walls. The puzzle is the thing I wanted to play, and the surrounding machinery kept getting between me and it.

The gap I saw was not a missing mechanic. It was a missing *stance*: a puzzle that trusts the player. One where a wrong tap is information, not a penalty that ends your turn. One where the hard part is *seeing* the answer, not surviving a system designed to make you stop.

I wrote that stance down early, in the first specification, as a rule the game must obey:

> The puzzle MUST permit unlimited blocked selections and continued play. It MUST have no lives, failure state, retry limit, timer, advertisement, or penalty that interrupts play.

Everything in this series is, in one way or another, an attempt to keep that promise while making the game genuinely hard.

## A second experiment hiding inside the first

There was a second reason to build this, and I'd be dishonest to leave it out.

I've been developing DevSpark, a spec-driven workflow: `specify → clarify → plan → tasks → analyze → implement → PR review → merge`. It separates *intent* from *architecture* from *executable tasks* from *adversarial review*, and it treats the specification as temporary working state while code, tests, and current knowledge become the durable record.

It had been used on APIs and web applications. I wanted to know whether it would survive contact with a domain where the important questions are things like "does this menu grab keyboard focus?" and "does this animation *feel* right?" A game was the most different thing I could think of that I could still finish alone.

So ArrowSpark had two jobs: be a good puzzle, and be an honest test of the method.

## Choosing to be uncomfortable

I could have built this in C#. I'd have been productive on day one.

I chose Godot 4 and GDScript instead, deliberately. If the point was to learn game development, then recreating familiar application patterns with a game-shaped skin would teach me very little. I wanted to learn Godot on its native path: scenes, nodes, signals, and a scripting language that reads like Python.

I didn't start from a blank folder, though. The project began from Maaack's Game Template, which supplies menus, settings, and input remapping. I removed its Git history and initialized a fresh repository so ArrowSpark could evolve independently. That was the first commit, at 10:41 on September 26th.

## The constitution came before the code

Here is what the history shows before any puzzle code.

Before the first arrow appeared on screen, I spent commits on two things that have nothing to do with puzzles:

1. **A constitution.** A short governance document that states what this project will and won't compromise on. It has six principles, including: prefer simple, maintainable code; customize the template at the project level rather than editing the addon; keep controls accessible and configurable; keep gameplay responsive; require *practical* verification of gameplay changes; and preserve saved progress and settings.
2. **Save and settings recovery.** Commits that make a corrupted settings file recoverable, preserve the original when loading fails, and cover it with regression tests, all on day one, before there was a game to save.

That ordering looks strange for a game. It's completely natural for business software, where "don't lose the user's data" is the first rule you write down, not the last. It's also where non-game experience paid off immediately: I knew which boring things would hurt later, and I knew how to make a workflow enforce them.

The constitution isn't decoration. Principle V says gameplay changes require Godot validation, a desktop smoke test, and recorded results. Every later spec had to answer to it. A rule you can't check isn't a rule, and DevSpark's gates exist to check them.

## What I brought, and what I didn't

Working with AI as planner, implementer, and critic while I acted as product owner and reviewer sharpened what was actually *mine* to contribute.

**What transferred cleanly from business software:**

- Writing requirements precisely enough to be tested.
- Separating rules from presentation, so the rules can be verified without a screen.
- Regression discipline, and the habit of asking "what breaks if this changes?"
- Treating documentation and knowledge as part of the deliverable.

**What did not transfer, and had to be learned:**

- *Feel.* Whether an animation reads as natural is not in any spec.
- *Focus and input.* A menu that looks right can leave a keyboard player stranded.
- *Difficulty.* You cannot unit-test whether a puzzle is interesting. I'll spend a whole article on this one.

Those three gaps, feel, focus, and difficulty, account for most of the surprises in the chapters that follow. Each time the method met one of them, either it caught the problem or it honestly admitted it couldn't.

## What's coming

Here's the road ahead:

2. **[My first game loop](/story/first-game-loop/)**: Spec 001 through a business developer's eyes.
3. **[Provably solvable](/story/provably-solvable/)**: a solver, and a proof that legal moves can never trap you.
4. **[Making it feel right](/story/making-it-feel-right/)**: arrows that unwind, and what tests can't see.
5. **[The playtest that beat the dashboard](/story/playtest-beat-the-dashboard/)**: when every metric said "harder" and a human said "too easy."
6. **[The contract before the difficulty](/story/contract-before-difficulty/)**: Open Move assistance, session scoring, and a canvas as big as the knot.
7. **[Pulling the thread](/story/pulling-the-thread/)**: knot experiments, and an audit that caught the project breaking its own rule.
8. **[The Reference Knot](/story/the-reference-knot/)**: one level, judged by a human.
9. **[Now it's your turn](/story/now-its-your-turn/)**: the whole clock, what DevSpark learned, and a request.

Each chapter carries a "clock" beat: how long its specs took on the wall clock, and what the discipline bought in that time. The whole run is about 121 hours from the first commit to the tenth spec's merge, with nine specs merged in the first 70. That's not a boast; it's the evidence. It says the interesting part wasn't typing speed. It was the quality of the questions asked between the steps, and a process that made asking them cheap.

Next: the smallest possible game, and the first product decision.

---

## Receipts

Every claim above about timing or sequence can be checked against the repository history. Times are local (US Central), as recorded in each commit; each hash links to the commit on GitHub. Subjects are quoted from the log, except that internal planning identifiers are replaced by a short description.

```text
git show --stat <hash>      # what a commit changed
git log --reverse --format='%h %ad %s' --date=format:'%Y-%m-%d %H:%M'
```

| Commit | Time | Subject |
|---|---|---|
| [`e228500`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/e228500c67b2c0e85cbea72a13e633e79c5480dd) | 2026-09-26 10:41 | Initial project from Godot game template |
| [`a1abb24`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/a1abb24510fda21ace6c6e301e4f072902405f95) | 2026-09-26 10:53 | Update texture import settings and remapping for various icons and translations |
| [`1fcefa5`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/1fcefa59a8310e69dc4f4c6be1a7d915caa1d0f2) | 2026-09-26 11:33 | Add templates for tasks, verification contracts, and work-item reviews |
| [`ce55cd4`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/ce55cd4e6b7ea8c048428b88433b58962546932d) | 2026-09-26 11:45 | Update ArrowGame constitution and templates to enforce mandatory verification and gameplay validation |
| [`4b69063`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/4b690639326c660d6c562a3b49ba018f57504210) | 2026-09-26 11:59 | Implement save recovery and input restoration features; add regression tests for persistence |
| [`d5e6010`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/d5e6010f6347648b722350b248baa2c7b01a32c0) | 2026-09-26 12:08 | Enhance settings recovery mechanism: preserve original settings on load failure, implement backup/reset options, and ensure temporary settings remain usable |
| [`b020e47`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/b020e47d4ad58afff11289fedd80087ecc8ab44f) | 2026-09-26 12:26 | Implement first playable arrow puzzle tasks and verification gates |
| [`8ef1b11`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/8ef1b112bf2af6265d10d8e84580fe6d7c9915b9) | 2026-09-26 12:45 | Add new command files for user input processing and prompt resolution |
| [`ad57a4b`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/ad57a4b668f4e393fbd09c5a63c4f94b3ed8fd26) | 2026-09-26 12:53 | Update implementation plan, quickstart, and tasks for first playable arrow puzzle; refine specifications, enhance test descriptions, and ensure menu routing aligns with session-only gameplay. |
| [`50d6ff7`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/50d6ff767c233f7eb4791bfbf7f385685e4539cd) | 2026-09-26 13:04 | Refine implementation plan, quickstart, and tasks for first playable arrow puzzle; enhance automated testing for no-reset guarantee, HUD layout, and feedback duration; add critic gate for remediation review. |
| [`f05e27b`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/f05e27b85fe2a485bcb071d43836c7e3a6bc7ff3) | 2026-09-26 13:13 | Re-run analyze/critic gates on arrow puzzle plan; fix a requirement note wording |
| [`eb55fb6`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/eb55fb6a226826288ad4dbd73d4dedbe74cbfe70) | 2026-09-26 13:19 | Resolve an analyze finding by splitting a task into test-first and implementation tasks |
| [`0ec2dda`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/0ec2dda8a4748c40b8bf42d8ed769a7a7d855236) | 2026-09-26 13:55 | Implement first playable arrow puzzle (spec 001) |
