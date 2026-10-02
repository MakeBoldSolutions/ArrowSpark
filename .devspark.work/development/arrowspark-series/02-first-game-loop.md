---
title: "My First Game Loop: Spec 001 Through a Business Developer's Eyes"
series: "Building ArrowSpark with DevSpark"
part: "2 of 7"
slug: first-game-loop
status: first-draft
author: Mark Hazleton
date_drafted: 2026-09-30
theme: "Method meets a new domain: taking the DevSpark lifecycle from CRUD-shaped work to the smallest playable game, and learning where the architecture boundary matters most."
description: "How the first specification produced a 5x4 board with eight arrows, one unbreakable product decision, and an architecture that keeps game rules out of scenes, all in 3h14m of wall-clock time, most of it spent on governance and planning rather than code."
purpose: "Show concretely what spec-driven development looks like on a first game feature, and make the first timing case: front-loading decisions and review is what let implementation be fast. Demonstrate that the value lies in the decisions the process forces early and in gates that catch small flaws before code."
wall_clock: "2026-09-26 10:41 to 13:55: 3h14m from empty repository to first playable; about 2.5h of it governance, spec, plan and gates; implementation commit 36 minutes after the last gate fix."
audience: "Application developers curious how a spec-driven, AI-assisted workflow handles an unfamiliar framework; readers of Article 1 who want to see the method in motion."
specs_covered: ["001-spec-first-playable-arrow-puzzle"]
evidence_sources:
  - .devspark.work/specs/001-spec-first-playable-arrow-puzzle/spec.md
  - .devspark.work/specs/001-spec-first-playable-arrow-puzzle/tasks.md
  - .devspark.work/development/01-project-history.md
  - .devspark.work/development/03-architecture.md
  - "git log: b020e47, ad57a4b, 50d6ff7, f05e27b, eb55fb6, 0ec2dda"
key_takeaways:
  - "Decide what the game will never do before deciding what it will do."
  - "Rules as plain RefCounted classes let you test a game without a screen."
  - "Analyze and Critic gates earn their keep on tiny findings: a task that hid two jobs, a note with the wrong wording."
open_items_for_author:
  - "Add one or two real Godot-learning stumbles (signals, scene tree, node lifecycle)."
  - "Confirm how long Spec 001 took wall-clock; the log only shows it was day one."
next_article: "03-provably-solvable.md"
---

# My First Game Loop: Spec 001 Through a Business Developer's Eyes

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

If you've written a service layer that doesn't know about HTTP, this will feel familiar. The project's agent-instruction files still say it in one line: *puzzle rules use RefCounted classes independently of scenes and input; preserve this boundary when extending the rule core.* It has held through nine specs.

<!-- TODO(Mark): One or two honest Godot-learning moments here. What did the scene tree, signals, or node lifecycle do that surprised a C# developer? -->

## Testing a game from a script

The other habit I carried over was regression discipline, and the project has had it from the first spec. The tests are GDScript checks that run headless, without a window, and Python launchers that start Godot, run them, and look for failure markers. A green run prints lines like `PUZZLE_FAILURES=0`. The constitution names two launchers as required gates, and continuous integration was added on the same day to run both on every push and pull request.

I'll be blunt about proportion. Counting the lines today, there is more test code than game code in this repository. That's a business-software reflex, and I think it's the reason three and a half days of fast, AI-assisted development didn't produce a pile of unverifiable code.

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

<!-- TODO(Mark): How much of that 3h14m was your hands-on time versus waiting on the tool? -->

## What the gates caught

Between the spec and the first implemented arrow, DevSpark ran its review steps. Two of the outcomes are small enough to be instructive.

- **One task was really two.** The Analyze gate noticed a task that bundled "write the tests" and "write the implementation" into a single item. It was split so the test comes first. That's a five-minute fix that prevents a familiar failure: tests written to match whatever the code already does.
- **A note said the wrong thing.** A re-run of Analyze and Critic found a requirement note whose wording didn't match the requirement it annotated. Nobody would have been hurt by it. But documentation that slightly contradicts the spec is how teams end up debating what the spec "really meant" six weeks later.

Neither finding was a bug. Most of what a review gate does is *routine cleanup that never becomes a bug*. You don't see the value because the problem never happens.

## Specs are temporary, and that matters

One structural idea from DevSpark deserves a mention, because it shaped where everything lives.

The working documents (spec, plan, tasks, research, gate reports) live in a temporary folder. The durable record lives in `.knowledge/`, the code, and the tests. Durable files are never allowed to point back at the temporary ones.

That felt like bureaucracy on day one. By day four it had become one of the more useful rules in the project, and a later audit caught me breaking it. I'll come back to that in the last article.

## What Spec 001 taught me

The loop worked. It was small enough to understand completely, and it already contained the product's principles. The result was less exciting than the process behind it: a decision made early, a boundary drawn early, and tests that existed from the start.

But the puzzle was trivial. Eight arrows that each point at a wall is not a game anyone would keep playing. The next spec made the arrows interesting, and it introduced the idea that would carry the whole project: a **guarantee** that every puzzle can be solved.

Next: giving arrows tails, and proving you can't get stuck.

---

## Receipts

Every claim above about timing or sequence can be checked against the repository history. Times are local, as recorded in the commit.

```text
git show --stat <hash>      # what a commit changed
git log --reverse --format='%h %ad %s' --date=format:'%Y-%m-%d %H:%M'
```

| Commit | Time | Subject |
|---|---|---|
| `b020e47` | 2026-09-26 12:26 | Implement first playable arrow puzzle tasks and verification gates |
| `8ef1b11` | 2026-09-26 12:45 | Add new command files for user input processing and prompt resolution |
| `ad57a4b` | 2026-09-26 12:53 | Update implementation plan, quickstart, and tasks for first playable arrow puzzle; refine specifications, enhance test descriptions, and ensure menu routing aligns with session-only gameplay. |
| `50d6ff7` | 2026-09-26 13:04 | Refine implementation plan, quickstart, and tasks for first playable arrow puzzle; enhance automated testing for no-reset guarantee, HUD layout, and feedback duration; add critic gate for remediation review. |
| `f05e27b` | 2026-09-26 13:13 | Re-run analyze/critic gates on arrow puzzle plan; fix FR-013 note wording |
| `eb55fb6` | 2026-09-26 13:19 | Resolve analyze-F2 by splitting T009 into test-first and implementation tasks |
| `0ec2dda` | 2026-09-26 13:55 | Implement first playable arrow puzzle (spec 001) |
