---
title: "My First Game Loop: Spec 001 Through a Business Developer's Eyes"
part: 2
slug: first-game-loop
description: "The smallest game that could be a game: a fixed board, eight arrows, one product decision that every later spec depends on, and rules kept out of the scenes so they can be tested without a screen."
spoiler: false
status: published
sources:
  - label: "First playable (Spec 001)"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/0ec2dda8a4748c40b8bf42d8ed769a7a7d855236
  - label: "Gate fix: test-first split"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/eb55fb6a226826288ad4dbd73d4dedbe74cbfe70
  - label: "Rule layer (knowledge)"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/blob/6e60e117acc175a47feb55f52a3a8da1c6cedaab/.knowledge/architecture/arrow-puzzle.md
updated: 2026-10-02
---

If you ask a room of developers what a game needs, most will say "a game loop" and start thinking about frames and physics. Mine turned out to be much smaller. It was a table, some arrows, and a question the code answers each time you click: *is anything in the way?*

The first DevSpark spec for ArrowSpark asked for exactly that and nothing more.

## The smallest game that could be a game

Spec 001 defined a fixed board, five columns by four rows, holding eight arrows. Each arrow had one of four directions. Selecting an arrow had one of two outcomes:

- If its path to the board edge was clear, the arrow left.
- If another arrow blocked the path, the arrow stayed and the mistake counter went up.

Clear all eight arrows and the puzzle is complete. A results screen shows total arrows, mistakes, score, and accuracy. The score formula was as plain as it gets: `max(total_arrows - mistakes, 0)`.

That's it. No levels, no menus beyond what the template provided, no animation worth mentioning. The point was to prove the *interaction* was worth building on.

## The first product decision

The moment a spec exists, you have to say what happens when a player is wrong. In a puzzle game that's the most consequential sentence in the document.

The obvious options are the industry's usual ones: lives, a retry limit, a forced restart. I wrote the opposite into the requirements:

> A mistake should not stop play.

No lives. No failure screen. No attempt cap. A blocked tap increments a counter and the game keeps going.

I want to be careful about how I describe this, because it sounds like a small UX choice. It isn't. It's a product stance that later constrained the architecture, the scoring system, the difficulty design, and the assistance feature. Every subsequent article traces back to this one sentence. It was easy to write in a spec and would have been very hard to retrofit into a game built the other way around.

This is what specification-first is *for*. You make the load-bearing decision while it's still a sentence.

## Where the rules live

The second decision was about structure, and here my business-software instincts did real work.

Game tutorials tend to put everything in the scene: the click handler decides whether the arrow can move, the animation runs, the score changes. That works until you want to test whether the rule is right, and then you discover you need a running game to do it.

I kept the rules out of the scenes. The first architecture had five pieces:

| Piece | Responsibility |
|---|---|
| `PuzzleDefinition` | The authored puzzle: board size, arrows, directions |
| `PuzzleState` | The rules: is an arrow blocked, what happens when one is removed, is the puzzle complete |
| `PuzzleBoard` / `ArrowView` | Presentation: drawing and hit-testing |
| A controller | Coordination: state, animation, HUD, completion |
| Results formatting | Turning a finished attempt into text |

The rule classes are plain `RefCounted` objects, GDScript's lightweight base type, with no scene, no input, and no rendering. That means a headless test can construct a puzzle, call the same methods the game calls, and assert on the outcome in milliseconds.

If you've written a service layer that doesn't know about HTTP, this will feel familiar. The project's agent-instruction files still say it in one line: *puzzle rules use RefCounted classes independently of scenes and input; preserve this boundary when extending the rule core.* It has held through all ten specs.

## Testing a game from a script

The other habit I carried over was regression discipline, and the project has had it from the first spec. The tests are GDScript checks that run headless, without a window, and Python launchers that start Godot, run them, and look for failure markers. A green run prints lines like `PUZZLE_FAILURES=0`. The constitution names two launchers as required gates, and continuous integration was added on the same day to run both on every push and pull request.

I'll be blunt about proportion. Counting the lines today, there is more test code than game code in this repository. That's a business-software reflex, and I think it's the reason five days of fast, AI-assisted development didn't produce a pile of unverifiable code. (At the end of Spec 010: 3,820 lines of GDScript in the game against 5,340 in its tests.)

## The clock: 3 hours 14 minutes, and most of it wasn't coding

Here is the timeline for Spec 001, straight from the commit log:

| Time | Step |
|---|---|
| 11:45 | Constitution updated to require verification and gameplay validation |
| 12:26 | Tasks and verification gates for the first playable |
| 12:53 – 13:04 | Plan, quickstart and tasks refined; automated tests for the no-reset guarantee, HUD layout and feedback duration added to the plan |
| 13:13 | Analyze and Critic re-run against the plan |
| 13:19 | Analyze finding resolved (test-first split) |
| 13:55 | First playable implemented |

The implementation commit landed 36 minutes after the last gate fix and 3 hours 14 minutes after the repository was created. Roughly two and a half of those hours were governance, specification, planning and review.

That ratio is the story. A developer improvising would have started with the click handler and spent the afternoon rediscovering, one bug at a time, decisions that the spec had already made. A disciplined one spends the time up front, on the questions where wrong answers are expensive, and lets the implementation be the short, boring part. When the AI implements against a reviewed plan with tests specified first, "boring" means fast.

## What the gates caught

Between the spec and the first implemented arrow, DevSpark ran its review steps. Two of the outcomes are small enough to be instructive.

- **One task was really two.** The Analyze gate noticed a task that bundled "write the tests" and "write the implementation" into a single item. It was split so the test comes first. That's a five-minute fix that prevents a familiar failure: tests written to match whatever the code already does.
- **A note said the wrong thing.** A re-run of Analyze and Critic found a requirement note whose wording didn't match the requirement it annotated. Nobody would have been hurt by it. But documentation that slightly contradicts the spec is how teams end up debating what the spec "really meant" six weeks later.

Neither finding was a bug. Most of what a review gate does is *routine cleanup that never becomes a bug*. You don't see the value because the problem never happens.

## Specs are temporary, and that matters

One structural idea from DevSpark deserves a mention, because it shaped where everything lives.

The working documents (spec, plan, tasks, research, gate reports) live in a temporary folder. The durable record lives in `.knowledge/`, the code, and the tests. Durable files are never allowed to point back at the temporary ones.

That felt like bureaucracy on day one. By day four it had become one of the more useful rules in the project, and a later audit caught me breaking it. I'll come back to that in [Part 7](/story/pulling-the-thread/).

## What Spec 001 taught me

The loop worked. It was small enough to understand completely, and it already contained the product's principles. The result was less exciting than the process behind it: a decision made early, a boundary drawn early, and tests that existed from the start.

But the puzzle was trivial. Eight arrows that each point at a wall is not a game anyone would keep playing. The next spec made the arrows interesting, and it introduced the idea that would carry the whole project: a **guarantee** that every puzzle can be solved.

Next: giving arrows tails, and proving you can't get stuck.

---

## Receipts

Every claim above about timing or sequence can be checked against the repository history. Times are local (US Central), as recorded in each commit; each hash links to the commit on GitHub. Subjects are quoted from the log, except that internal planning identifiers are replaced by a short description.

```text
git show --stat <hash>      # what a commit changed
git log --reverse --format='%h %ad %s' --date=format:'%Y-%m-%d %H:%M'
```

| Commit | Time | Subject |
|---|---|---|
| [`b020e47`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/b020e47d4ad58afff11289fedd80087ecc8ab44f) | 2026-09-26 12:26 | Implement first playable arrow puzzle tasks and verification gates |
| [`8ef1b11`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/8ef1b112bf2af6265d10d8e84580fe6d7c9915b9) | 2026-09-26 12:45 | Add new command files for user input processing and prompt resolution |
| [`ad57a4b`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/ad57a4b668f4e393fbd09c5a63c4f94b3ed8fd26) | 2026-09-26 12:53 | Update implementation plan, quickstart, and tasks for first playable arrow puzzle; refine specifications, enhance test descriptions, and ensure menu routing aligns with session-only gameplay. |
| [`50d6ff7`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/50d6ff767c233f7eb4791bfbf7f385685e4539cd) | 2026-09-26 13:04 | Refine implementation plan, quickstart, and tasks for first playable arrow puzzle; enhance automated testing for no-reset guarantee, HUD layout, and feedback duration; add critic gate for remediation review. |
| [`f05e27b`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/f05e27b85fe2a485bcb071d43836c7e3a6bc7ff3) | 2026-09-26 13:13 | Re-run analyze/critic gates on arrow puzzle plan; fix a requirement note wording |
| [`eb55fb6`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/eb55fb6a226826288ad4dbd73d4dedbe74cbfe70) | 2026-09-26 13:19 | Resolve an analyze finding by splitting a task into test-first and implementation tasks |
| [`0ec2dda`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/0ec2dda8a4748c40b8bf42d8ed769a7a7d855236) | 2026-09-26 13:55 | Implement first playable arrow puzzle (spec 001) |
