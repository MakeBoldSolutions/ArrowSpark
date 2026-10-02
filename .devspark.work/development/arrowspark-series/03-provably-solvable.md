---
title: "Provably Solvable: A Solver and a One-Paragraph Proof"
series: "Building ArrowSpark with DevSpark"
part: "3 of 7"
slug: provably-solvable
status: first-draft
author: Mark Hazleton
date_drafted: 2026-09-30
theme: "Engineering rigor as a design promise: using ordinary software discipline (validation, invariants, an independent solver) to make 'hard is good, unsolvable is not' a checkable guarantee."
description: "How long, bent arrows and a small piece of math (removals only ever delete blockers) let ArrowSpark promise that no legal move can trap a player, and why that promise later freed the design to get much harder."
wall_clock: "2026-09-26 14:58 (first commit) to 17:05 (merge): 2h07m, with about 35 minutes of spec-refinement commits before the implementation commit at 16:59."
purpose: "Show the most transferable skill a business developer brings to game design: turning a product promise into an invariant that is validated at build time and proven once. Also plant the seed for Article 5, that this same proof means strategy cannot exist, so difficulty must be perceptual."
audience: "Developers who like correctness arguments; game-curious readers who assume puzzle games need fuzzy design intuition rather than provable properties."
specs_covered: ["002-spec-multi-arrow-solvability"]
evidence_sources:
  - .devspark.work/specs/002-spec-multi-arrow-solvability/spec.md
  - .devspark.work/specs/002-spec-multi-arrow-solvability/research.md
  - .devspark.work/development/01-project-history.md
  - .devspark.work/research/spec-006-report.md
  - "git log: e991f8e, 5ccb25e, 8e7bd5f, 4cf6f44, b98c5af, 990ace6, 7b403ab"
key_takeaways:
  - "Design illegal states out at validation time instead of special-casing them at runtime."
  - "Monotonic removal means a legal move can never make a solvable puzzle unsolvable."
  - "The same proof that guarantees safety also removes strategic difficulty, which is a cost, not just a benefit."
open_items_for_author:
  - "Decide how much of the proof to show. The draft keeps it to one paragraph; some readers will want a diagram."
  - "Consider a small figure of an L-shaped arrow with its forward ray highlighted."
next_article: "04-making-it-feel-right.md"
---

# Provably Solvable: A Solver and a One-Paragraph Proof

Eight arrows pointing at walls is a demo. To become a puzzle, arrows had to interact, and that meant giving them bodies.

Spec 002 changed an arrow from an icon into a shape: **one head cell, one direction, and zero or more ordered tail cells** trailing behind it. Tail cells form a continuous path that can turn any number of right angles. An arrow can now be an L, an S, a long snake through the board.

The escape rule barely changed, and that's what made the design work:

- The **head's direction** decides where the arrow escapes.
- Its own tail never blocks it.
- Any cell occupied by *another* active arrow, anywhere along the strict forward ray from the head to the edge, blocks it.
- A legal removal takes the whole arrow, atomically.

That's the entire rule system. What emerged from it was more interesting than the rules.

## Make the bad state unrepresentable

The first thing I did with this spec is what I'd do in any business domain: decide which malformed inputs to reject, and *where*.

The tricky case was an arrow whose own tail sat on its own forward escape ray, meaning the arrow would block itself. There were two ways to handle it. I could let it exist and add a special case to the blocking check ("ignore your own cells"). Or I could refuse to let it exist.

The research notes say it plainly: reject any shape whose tail occupies a cell on that arrow's own forward ray. It's a **validation failure**, not a runtime case the blocking check has to work around. Considering the alternative, they explain why it's wrong: it would leave the same conflict resolvable in two different places instead of designed out once.

That's an old lesson from domain modeling, and it's the same reason a database has constraints and not just careful application code. The rule "head is the leading edge" became a build-time guarantee. The other validation rules follow the same instinct: positive board dimensions, in-bounds cells, tails that connect by unit steps, no repeated cells, and no cell owned by two arrows.

## The solver, and the proof that makes it small

A promise that every puzzle is solvable needs something that checks it. I added `PuzzleSolver`, a class that takes a definition and either returns a complete removal order, called a *witness*, or reports that the puzzle is invalid or unsolvable.

I expected a clever algorithm. The algorithm is short:

1. Sort the active arrows by position.
2. Find the first arrow that can legally leave.
3. Remove it.
4. Repeat until the board is empty or nothing can move.

No backtracking. No search tree. No memoization. The research notes justify this in a paragraph, and it's worth quoting in spirit:

> Removal deletes occupied cells and adds none. So every other legal move stays legal. If any successful ordering exists, then moving any currently legal arrow to the front of that ordering and deleting its later occurrence still works, because occupancy only ever decreases.

In plain English: **removing an arrow can only unblock things.** It can never block anything new, because arrows don't move into other arrows' paths. They only leave.

I call this property *monotonic*, and it has two consequences that changed the whole project.

**Consequence one: you can't get stuck by playing legally.** If a puzzle is solvable to begin with, any legal move keeps it solvable. There is no wrong order. That's the technical foundation for "mistakes cost score, not play": the *only* way to make a mistake is to try a blocked arrow, and that changes nothing except a counter.

**Consequence two: the solver is cheap and can stay honest.** Because a greedy walk is provably sufficient, the solver stays small, deterministic, and independent of the gameplay controller. It is a checker, not a participant.

Every puzzle that ships in the catalog is confirmed solvable by that solver, with a zero-mistake witness recorded. "Unsolvable" is defined as *defective content*, not a player failure.

## The cost of the proof

Here's the part I underestimated at the time.

The same argument that makes play safe also means there is **no strategy**. In many puzzle games, choosing the wrong move early can doom you later; the difficulty lives in avoiding that. In ArrowSpark, it can't happen. No legal move can ever back-fire.

I didn't feel this cost in Spec 002. I felt it a few specs later, when a research pass re-implemented the solver in Python, ran it across the catalog, and concluded that strategic difficulty was impossible under the current rules "full stop." Whatever challenge ArrowSpark had would have to be *perceptual*: finding a legal arrow, tracing a bent tail, noticing a distant blocker.

That single sentence set up the most important design discovery of the project. I'll unpack it in Article 5. For now, note that the proof both enabled the safety guarantee and removed strategic difficulty. It also comes with a warning label in the research: if a future rule ever adds a new kind of blocker, the proof breaks and the solver's simplicity has to be reconsidered.

## The clock: 2 hours 7 minutes for a solver

Spec 002 began with its first commit at 14:58 and merged into the main line at 17:05: **2 hours 7 minutes**, on the same afternoon as Spec 001. In that window it produced a new arrow model, formal validation rules, an independent solver, a proof, regression tests, and the project's first CI workflow.

The shape of those two hours matters. From 15:16 to 15:51, six commits refined the specification and its gates. The implementation commit came at 16:59, and the merge six minutes later. So roughly a third of the time went to sharpening the spec against analysis and critique, and the code that followed had very little left to argue about.

A solver with a written proof is the kind of thing that, without a process forcing the proof, often gets "figured out" in a debugger over days. Here the proof was in the research notes *before* the code. The proof existed before the code.

## Spec refinement is not rework

Looking at the history for this spec, a cluster of commits reads like churn: clarifying own-cell exclusion "unconditionally," tightening adjacency rules for multi-cell arrows, revising validation, updating regression tests for multi-turn tails and order independence.

That is the process working as designed. Each of those was a spec-level correction found by analysis and critique *before* it became a behavior bug. The rule that own-cell exclusion must not depend on ownership, for example, is precisely the sort of edge that produces a subtle wrong answer six months from now if it's left ambiguous. It was cheaper to fix in a paragraph than in a debugger.

It also gave me the first CI workflow. The puzzle and save regression suites now run on every push, so the proof isn't just an argument. It's re-checked every time the code moves.

## What I'd tell a business developer

If you're wondering what you can bring to game design without game experience, this is my strongest answer:

- **State the promise as a testable invariant.** "Every puzzle is solvable" is a sentence a solver can check.
- **Validate at the boundary.** Reject bad shapes when they're authored, not when they're played.
- **Keep the checker independent.** A solver that lives inside the game controller can't be trusted to judge it.
- **Notice what your guarantee costs.** The best guarantees usually remove something too.

The rules were now provable. The game still looked like a spreadsheet. Next: making it feel like something.

---

## Receipts

Every claim above about timing or sequence can be checked against the repository history. Times are local, as recorded in the commit.

```text
git show --stat <hash>      # what a commit changed
git log --reverse --format='%h %ad %s' --date=format:'%Y-%m-%d %H:%M'
```

| Commit | Time | Subject |
|---|---|---|
| `e991f8e` | 2026-09-26 14:58 | feat: Add multi-cell arrow model and solvability foundation |
| `6b19ad3` | 2026-09-26 15:16 | refactor: Clarify analysis requirements and enhance specification consistency for solvability metrics |
| `5ccb25e` | 2026-09-26 15:23 | fix(spec): make FR-004 own-cell exclusion unconditional on ownership |
| `990ace6` | 2026-09-26 15:23 | ci: run puzzle and save regression suites on push/PR |
| `8e7bd5f` | 2026-09-26 15:29 | refactor(spec): enhance arrow movement and adjacency rules for multi-cell arrows |
| `64db2b2` | 2026-09-26 15:32 | refactor(spec): enhance validation rules for multi-cell arrows and update documentation |
| `16be02d` | 2026-09-26 15:44 | refactor(spec): update analysis and critic gates to reflect new validation rules and findings |
| `4cf6f44` | 2026-09-26 15:51 | refactor(spec): update puzzle regression tests and documentation for multi-turn tail handling and order independence |
| `b98c5af` | 2026-09-26 16:59 | Implement comprehensive puzzle solver and validation framework |
| `7b403ab` | 2026-09-26 17:05 | Merge branch '002-spec-multi-arrow-solvability' into master |
