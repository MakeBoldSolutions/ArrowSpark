# ArrowSpark Product Philosophy

## Core Identity

ArrowSpark is increasingly best understood as an **untangling puzzle**,
not merely an arrow-clearing puzzle.

The player is presented with a field that initially appears complicated.
The task is to inspect the geometry, trace arrows, discover which one
can leave, remove it, and watch the structure become simpler.

The emotional target is not panic, scarcity, or punishment.

It is:

**confusion → understanding → release → simplification → mastery**

## Foundational Principles

### Hard is good. Unsolvable is not.

ArrowSpark should be allowed to become genuinely difficult.

A player may need time to scan the field. They may follow the wrong
line. They may attempt blocked arrows. They may need assistance.

But the game should never manufacture difficulty by placing the player
into a logically impossible state.

Every shipped puzzle must be structurally valid and solver-confirmed
solvable.

Because legal removals are monotonic, legal play must preserve
solvability.

### Mistakes cost score, not play.

A blocked tap is information.

The player thought an arrow might be open. They tried it. The game tells
them it is blocked. The mistake counter increases and score potential
decreases.

Then play continues.

There is no need to punish curiosity with: - lives; - forced restart; -
attempt caps; - waiting; - ads; - payment; - artificial failure screens.

### Completion is expected; efficiency is scored.

ArrowSpark separates **finishing** from **mastering**.

Finishing means the player successfully untangled the puzzle.

Score measures how efficiently they did so.

This allows a player to struggle, use assistance, make mistakes, and
still receive the satisfaction of completion.

Replay is the mastery loop.

### There is always a way out. The challenge is seeing it.

This statement captures the relationship between the solver, monotonic
rules, and player experience.

If the player cannot see the way out, ArrowSpark can identify one open
move.

That does not solve the puzzle. It restores momentum.

### Assistance is expensive, but never scarce.

The hierarchy is:

-   **Look** --- free.
-   **Try a blocked arrow** --- one mistake penalty.
-   **Show Me an Open Move** --- five-mistake-equivalent score penalty.
-   **Keep playing** --- always allowed.

Assistance therefore affects mastery, not permission.

### The session is the memory boundary.

ArrowSpark currently has no concept of a durable player identity.

A running session may remember: - completed levels; - best score per
level; - overall score; - current attempt.

When the session ends, that gameplay history ends.

There is no: - profile; - login; - account; - anonymous persistent
player ID; - cross-session score history; - durable performance record.

This is a product decision, not merely an implementation shortcut.

## The Gordian Knot Metaphor

The emerging metaphor is **untangling a Gordian knot**.

A good ArrowSpark board should be able to produce the reaction:

> "That looks impossible."

followed by:

> "Wait... I think this one can come out."

and then:

> "Oh! Look how much that cleared."

The ideal rhythm is:

`Knot → loose thread → pull → opening → new insight → pull again`

This metaphor explains why long arrows matter.

## Why Long Tails Matter

Long tails create both **challenge** and **reward**.

### Challenge

A long, bent arrow requires the player to: - identify its head; - trace
its path; - distinguish it from neighboring geometry; - understand where
its cells occupy the board; - evaluate blockers in its escape direction.

When several long arrows occupy the same visual region, the player must
mentally separate them.

That is geometric reasoning.

### Reward

Removing a long arrow clears a meaningful portion of the field.

A single-cell arrow disappears with little visual consequence.

A twelve-cell, four-bend arrow can unwind through the puzzle and leave a
visible opening.

The player can see progress.

Therefore:

> **Density should come primarily from meaningful geometry, not merely
> arrow count.**

And:

> **A successful removal should make the knot feel more untangled.**

## The Role of Single-Cell Arrows

Single-cell arrows are not inherently bad.

They can be useful as: - punctuation; - obvious entry moves; - small
blockers; - a key that releases a larger structure; - a short recovery
beat after difficult tracing.

The problem is when they become the dominant substance of a dense board.

A field of many tiny independent arrows can become visual gravel:
numerous taps with little transformation.

ArrowSpark should prefer meaningful geometry where possible.

## Puzzle Size and the Viewport

The puzzle should not be designed around a single physical screen.

Large puzzles should remain large.

The correct solution is not to shrink arrows until everything fits.

Instead: - the puzzle defines its logical world; - the viewport shows
part or all of that world; - the player zooms and pans.

This enables a macro/micro rhythm:

**Zoom out:** understand the knot.\
**Zoom in:** trace a local structure.\
**Remove:** pull a thread out.\
**Zoom out:** observe the simplification.

## What ArrowSpark Is Not

At this stage ArrowSpark is explicitly not trying to become: - a
life-based mobile retention loop; - an ad-supported retry game; - a
competitive leaderboard product; - a profile/account system; - a
progression economy; - a star/medal collection game; - an adaptive
difficulty engine; - a procedural generator before "good puzzle" is
understood.

The development philosophy is to understand the core experience before
surrounding it with systems.

## Product North Star

A strong future ArrowSpark puzzle should satisfy this description:

> The board initially looks tangled enough that I am not sure where to
> begin. I can inspect it without being rushed. I find one arrow I
> believe is open. When I remove it, I watch a substantial thread unwind
> from the knot. The board becomes easier to read. If I become stuck, I
> can ask to see one open move at a meaningful score cost. I always
> finish. If I care about mastery, I replay and try to do it with fewer
> mistakes and less assistance.

That is the experience the architecture should serve.
