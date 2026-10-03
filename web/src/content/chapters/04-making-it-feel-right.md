---
title: "Making It Feel Right: Unwinding Arrows and What Tests Can't See"
part: 4
slug: making-it-feel-right
description: "Specs 003 and 004 turn cells into continuous arrows that feed out along their own path, and show how the method handles what tests can't see: test the math, look at the pixels, and write down which you did."
spoiler: false
status: published
sources:
  - label: "Continuous arrow visuals merged"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/287a5f009cf67773b7e9425ea0c0f4ba45ab5352
  - label: "Path-following departure merged"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/commit/92fba25b4ac4f8bcecbafa54d37649393464f89e
  - label: "Visual system (knowledge)"
    url: https://github.com/MakeBoldSolutions/ArrowSpark/blob/6e60e117acc175a47feb55f52a3a8da1c6cedaab/.knowledge/architecture/game-visual-system.md
updated: 2026-10-02
---

By the end of Spec 002 the game was correct and ugly. Arrows were cells. A bent arrow looked like a scatter of adjacent squares.

There's a version of spec-driven development that's convincing for APIs and unconvincing for anything with a screen. It says: write the requirement, generate the code, test it. That's fine until the requirement is "it should look like a single continuous arrow" or "it should feel like it's being pulled out." What do you assert?

Specs 003 and 004 were where I found out.

## Spec 003: make the geometry look like geometry

The goal was modest: draw each arrow as one continuous line with a real arrowhead, so a bend *reads* as a bend. A single-cell arrow got a short synthetic tail so it still looks like an arrow rather than a dot.

Two design choices inside it mattered more than they looked.

**State precedence.** An arrow can be departing, blocked, hovered, or normal, and sometimes more than one at once. The spec fixed an explicit order: `departure → blocked → hover → normal`. If you've ever debugged CSS specificity you know why that line is worth writing down. Without it, two effects fight and you get flicker that only shows up in one situation.

**A visual identity that recedes.** A small palette went in here: a cream background, dark neutral arrows, an ember hover, a rust accent, and green for success, with restrained borders and text. Typography leaned on Be Vietnam Pro and Inter Tight. Later, a branding pass named the product ArrowSpark, part of a "Make Bold Spark" family from Make Bold Solutions. The rule I set was that branding belongs on application-level surfaces, and active gameplay should *prove* the brand rather than repeatedly display it. During a puzzle, the player should see arrows, not logos.

## Spec 004: the departure that changed the game

Here's the detail I nearly treated as polish.

When you select a legal arrow, it leaves. The obvious animation is to slide the whole shape in the direction of its head. For a straight arrow, that's fine. For a long arrow with three bends, it looks wrong: a rigid L-shape or S-shape sliding sideways through space its tail never occupied, like a piece of cardboard.

What you expect from a snake or a rope is that it **feeds through its own path**. The head moves forward, the tail follows through every bend, and each bend disappears as the tail passes it.

The requirement was written from that image:

> The arrow's head begins moving forward. The rest follows through its existing ordered path. Existing bends remain fixed in their original board locations while the arrow material feeds through them.

### The implementation is smaller than the idea

The research settled on one scalar. Take the arrow's route as an immutable polyline: from the tail's end, through the tail cells, to the original head, and then straight along the escape ray past the board edge. Let `d` be how far the arrow has travelled. The tail is at position `P(d)` along that route; the head is at `P(L + d)`, where `L` is the arrow's length. Each frame you rebuild the visible line from the route segment between the two, keeping every original vertex in between so you never draw a diagonal shortcut across a bend.

One number, animated. Everything else falls out of it.

### The invariant that keeps it honest

The single most important rule in that spec is a separation I'd already made in Spec 001: **logical removal happens immediately.** The rules engine removes the arrow the instant it's selected. The animation is presentation that follows, asynchronously. Completion of the puzzle waits for departures to finish, but the *state* never does.

This is why the animation can be wrong without the game being wrong. A visual glitch can't corrupt a score or leave an arrow half-removed in the rules. It's also why the spec could later be extended to survive resizing the window mid-departure, or run under zoom and pan, without touching the rules.

## The clock: two specs, about 6.5 hours, finished at 00:40

Both of these specs landed on the evening and night of day one:

| Spec | Started | Merged | Wall clock |
|---|---|---|---|
| 003 Continuous arrow visuals | 17:49 (spec and checklist) | 21:25 | 3h 36m |
| 004 Path-following departure | 21:33 (verification complete on 003) | 00:40 | about 3h |

Within Spec 003 the sequence was spec at 17:49, plan artifacts at 17:58, Analyze and Critic gates at 18:53, and then a gap until a font commit at 20:42 and user acceptance at 21:25. Spec 004 went implementation at 22:12, a refinement pass on the manual acceptance criteria and gates at 22:30 to 22:34, implementation completed at 23:03, and close-out at 00:40.

Notice where the human time went. The code for 004 arrived within an hour. The remaining time was gates and a real person looking at a real screen, which is exactly the part that can't be compressed and shouldn't be. Speed came from the parts a process can make cheap. The parts that need judgment kept their time.

## How do you test feel?

This is the part I'd want to read if I were skeptical.

DevSpark's answer, as practiced here, has layers:

1. **Geometry is tested.** The departure math (route sampling, interval extraction, bend retention) has its own headless check. If a bend goes missing or a diagonal appears, a test fails.
2. **Rendering is captured.** The gate folder for Spec 003 holds screenshots at 1280×720 and 960×540 for gameplay, hover, blocked, departure, and results. Someone (me) looks at them.
3. **Feel is verified by a human, and recorded as such.**

The third layer is notable for what the record declines to claim. The tasks for the final rendered checks were listed as remaining. I played it and reported that my testing was good. DevSpark recorded exactly that: *"user-reported acceptance … no per-device, per-resolution, or individual-step transcript was supplied; no additional agent-observed hardware test is claimed."*

That sentence is unglamorous, and I think it's exactly right. The tool didn't upgrade my sentence into a test matrix. It wrote down what happened. A separate fix along the way, keeping the manual visual fixture open and visible so a person could actually look at it, is a small example of the same principle: when the verifier is a human, make sure the human can see something.

The constitution's Principle V is the backbone here: gameplay changes need *practical* verification, and results, or the limits on them, get recorded. Not "tests pass." Not "looks fine." What was checked, how, and what wasn't.

## The metaphor that arrived by accident

I built path-following departure because rigid sliding looked cheap. I didn't build it to define the game.

But a few specs later, when I started designing puzzles with long, bent arrows woven through each other, the animation stopped being polish. Pulling a long arrow out of a crowded board and watching it thread its way through every turn *looks like pulling a thread out of a knot.* That image, of untangling, became the language for everything that followed: the design philosophy, the research hypothesis, the puzzle experiments.

I didn't plan it. What I did do, from the first spec, was keep presentation cleanly separated from rules and write down the intent behind the animation rather than just its pixels. That's what made it possible to notice, later, that the intent was bigger than I'd thought.

## What to take from this

- **Separate logical and visual state.** The rules answer "what is true." The screen answers "what does it look like it's doing." Never let the second delay the first.
- **Test the math; look at the pixels; write down which you did.**
- **Specify intent, not only appearance.** "Feeds through its own path" carried more than any pixel measurement could.
- **Polish can be product.** Pay attention to the small decisions that end up doing more work than you asked of them.

The game now looked and moved like something. But it still had one puzzle, and I still didn't know what made a puzzle *good*. Next: the catalog, a review that caught a hidden focus bug, and the playtest that humbled my dashboard.

---

## Receipts

Every claim above about timing or sequence can be checked against the repository history. Times are local (US Central), as recorded in each commit; each hash links to the commit on GitHub. Subjects are quoted from the log, except that internal planning identifiers are replaced by a short description.

```text
git show --stat <hash>      # what a commit changed
git log --reverse --format='%h %ad %s' --date=format:'%Y-%m-%d %H:%M'
```

| Commit | Time | Subject |
|---|---|---|
| [`8ab3b7c`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/8ab3b7c17af6ae76d3b18b27504d163f71062b55) | 2026-09-26 17:49 | feat(spec): add comprehensive specification and quality checklist for continuous arrow visuals |
| [`85bf6c9`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/85bf6c9d8267db5b337c791d4d597db46fddee96) | 2026-09-26 17:58 | Add implementation verification quickstart, research, and tasks for continuous arrow visuals |
| [`23292e1`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/23292e1ce413ad26f6102a153ec91b9faf4f37ba) | 2026-09-26 18:53 | feat(spec): add analyze and critic gates for continuous arrow visuals with full analysis and metadata warnings |
| [`8e8e5e5`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/8e8e5e52a9a498f41dc2b4522da8d31fa97e5959) | 2026-09-26 20:42 | Add Inter Tight font and licensing information |
| [`479027e`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/479027e5c0d991bb923c4f910408aa3a35f5c262) | 2026-09-26 21:25 | Record user acceptance and complete continuous arrow visuals spec |
| [`287a5f0`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/287a5f009cf67773b7e9425ea0c0f4ba45ab5352) | 2026-09-26 21:25 | Merge continuous arrow visuals into master |
| [`9270b21`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/9270b218af45cd6719f1f8cd92d349236a802d77) | 2026-09-26 21:33 | feat(verification): update completion status and integrate user acceptance for multi-arrow visuals |
| [`f553ff9`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/f553ff978e3a6cb05a5533fdd53b445bf810429e) | 2026-09-26 22:12 | feat: Implement path-following arrow departure feature |
| [`a3bd9ee`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/a3bd9ee5ef5f5f44b978f73693c4aba3787ff813) | 2026-09-26 22:30 | fix(spec): clarify manual visual acceptance criteria and harden task linkages |
| [`4a8a28d`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/4a8a28dec0ca363d69806e5e3c6b60da7ab3b05c) | 2026-09-26 22:34 | chore(gates): refresh analyze/critic gate reports after spec/tasks revision |
| [`d136d18`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/d136d18af780b5021968385ef66b6428d4cd380e) | 2026-09-26 23:03 | feat: Implement path-following arrow departure (US1-US3) |
| [`15db141`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/15db1415b861f159d171cd137af5cb0d88ee1236) | 2026-09-27 00:34 | fix(tests): keep the manual visual fixture open and visible |
| [`63dd3f5`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/63dd3f5982074505daf4809208b7ae31d73c2381) | 2026-09-27 00:40 | chore(spec): close out a task/a task via user acceptance and mark spec complete |
| [`92fba25`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/92fba25b4ac4f8bcecbafa54d37649393464f89e) | 2026-09-27 00:40 | Merge branch '004-spec-path-following-departure' |
| [`316d09c`](https://github.com/MakeBoldSolutions/ArrowSpark/commit/316d09c62cdc0f42a8301abe6bae2e0b7a75f2c7) | 2026-09-27 09:23 | feat(branding): update product identity and branding hierarchy in project files |
