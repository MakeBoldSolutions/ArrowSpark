---
title: "Making It Feel Right: Unwinding Arrows and What Tests Can't See"
series: "Building ArrowSpark with DevSpark"
part: "4 of 7"
slug: making-it-feel-right
status: first-draft
author: Mark Hazleton
date_drafted: 2026-09-30
theme: "Feel and presentation: where spec-driven development meets things that can't be fully specified, and what an honest verification story looks like when a human has to look at the screen."
description: "Continuous arrow visuals, path-following departure animation, and a small brand identity; plus how DevSpark recorded manual acceptance honestly and how an animation detail became the game's central metaphor."
wall_clock: "Spec 003: 2026-09-26 17:49 to 21:25 (3h36m). Spec 004: 21:33 to 2026-09-27 00:40 (about 3h). Implementation for 004 within about an hour; the rest was gates and human acceptance."
purpose: "Address the biggest doubt about spec-driven development for games: what about feel? Show the layered answer (logic first, animation as presentation, geometry tested, feel verified by a human and recorded as such) and reveal how presentation choices quietly defined the product."
audience: "Developers who distrust process for creative or UX work; anyone who has wondered how you 'test' an animation."
specs_covered: ["003-spec-continuous-arrow-visuals", "004-spec-path-following-departure", "branding pass (316d09c)"]
evidence_sources:
  - .devspark.work/specs/003-spec-continuous-arrow-visuals/spec.md
  - .devspark.work/specs/003-spec-continuous-arrow-visuals/tasks.md (User Acceptance section)
  - .devspark.work/specs/003-spec-continuous-arrow-visuals/gates/ (1280x720 and 960x540 captures)
  - .devspark.work/specs/004-spec-path-following-departure/source-brief.md
  - .devspark.work/development/01-project-history.md
  - .knowledge/architecture/game-visual-system.md
  - .knowledge/product/branding.md
  - "git log: 8ab3b7c, 8e8e5e5, 479027e, f553ff9, d136d18, 15db141, 63dd3f5, 316d09c"
key_takeaways:
  - "Keep logical state and presentation state separate: the arrow is removed instantly; the animation only depicts it."
  - "Automate geometry; verify feel by hand; record which is which."
  - "An animation built for polish became the metaphor that later organized the whole design."
open_items_for_author:
  - "Insert screenshots from the spec 003 gates folder (blocked, hover, departure)."
  - "Confirm the fonts and palette description against the current game-visual-system knowledge doc before publishing."
  - "A short GIF of a bent arrow unwinding would carry this article."
next_article: "05-playtest-beat-the-dashboard.md"
---

# Making It Feel Right: Unwinding Arrows and What Tests Can't See

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

Every claim above about timing or sequence can be checked against the repository history. Times are local, as recorded in the commit.

```text
git show --stat <hash>      # what a commit changed
git log --reverse --format='%h %ad %s' --date=format:'%Y-%m-%d %H:%M'
```

| Commit | Time | Subject |
|---|---|---|
| `8ab3b7c` | 2026-09-26 17:49 | feat(spec): add comprehensive specification and quality checklist for continuous arrow visuals |
| `85bf6c9` | 2026-09-26 17:58 | Add implementation verification quickstart, research, and tasks for continuous arrow visuals |
| `23292e1` | 2026-09-26 18:53 | feat(spec): add analyze and critic gates for continuous arrow visuals with full analysis and metadata warnings |
| `8e8e5e5` | 2026-09-26 20:42 | Add Inter Tight font and licensing information |
| `479027e` | 2026-09-26 21:25 | Record user acceptance and complete continuous arrow visuals spec |
| `287a5f0` | 2026-09-26 21:25 | Merge continuous arrow visuals into master |
| `9270b21` | 2026-09-26 21:33 | feat(verification): update completion status and integrate user acceptance for multi-arrow visuals |
| `f553ff9` | 2026-09-26 22:12 | feat: Implement path-following arrow departure feature |
| `a3bd9ee` | 2026-09-26 22:30 | fix(spec): clarify manual visual acceptance criteria and harden task linkages |
| `4a8a28d` | 2026-09-26 22:34 | chore(gates): refresh analyze/critic gate reports after spec/tasks revision |
| `d136d18` | 2026-09-26 23:03 | feat: Implement path-following arrow departure (US1-US3) |
| `15db141` | 2026-09-27 00:34 | fix(tests): keep the manual visual fixture open and visible |
| `63dd3f5` | 2026-09-27 00:40 | chore(spec): close out T025/T026 via user acceptance and mark spec complete |
| `92fba25` | 2026-09-27 00:40 | Merge branch '004-spec-path-following-departure' |
| `316d09c` | 2026-09-27 09:23 | feat(branding): update product identity and branding hierarchy in project files |
