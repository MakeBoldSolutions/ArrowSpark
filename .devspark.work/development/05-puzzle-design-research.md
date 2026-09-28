# Puzzle Design Research and the Gordian Knot Hypothesis

## The Original Difficulty Model

Early ArrowSpark thinking naturally focused on dependency structure.

Possible measures included: - dependency depth; - forced states; -
branching states; - blocker distance; - density; - cascade fan-out; -
composition; - number of legal choices.

These are reasonable objective properties.

Spec 006 built an analyzer and authored experiments to test them.

## What Spec 006 Demonstrated

The experiments successfully produced intended structures.

Yet human playtesting reported: - low perceived challenge; - low
scanning demand; - insufficient variety; - weak "aha" moments; - too
many single-cell arrows.

This is a crucial distinction:

> **A puzzle can be structurally complex without being perceptually
> complex.**

If the player can instantly see every arrow as an independent icon, a
deep dependency graph may still be easy to reason about.

## Geometry as the Missing Dimension

ArrowSpark arrows are not merely nodes in a graph.

They are shapes occupying space.

A long arrow with bends forces the player to visually answer: - where is
its head? - which line segments belong to it? - where does it turn? -
which cells does its tail occupy? - which other arrows occupy nearby
space? - what lies in the head's forward ray?

When multiple long arrows occupy overlapping visual regions, these
questions interact.

This is **geometric entanglement**.

## Working Definition: Geometric Entanglement

Geometric entanglement is the amount of visual tracing and spatial
separation required to understand arrow ownership and blocking
relationships in a puzzle.

It is not equivalent to raw density.

A dense field of isolated single-cell arrows may be visually busy but
not deeply entangled.

A smaller number of long, bent arrows can create greater entanglement
because each shape spans multiple regions and interacts with other
shapes.

## Candidate Characteristics

These are research concepts, not yet required production metrics:

-   long-arrow ratio;
-   average occupied cells per arrow;
-   maximum arrow length;
-   bend count;
-   multi-bend arrow ratio;
-   tail-sourced dependency ratio;
-   spatial overlap/adjacency;
-   neighboring-path ambiguity;
-   dependency-through-tail ratio;
-   visual mass removed per successful move;
-   regional density variation;
-   "unlock" size after a key removal.

Do not prematurely turn these into a difficulty formula.

## Density from Geometry vs. Density from Count

A major design principle emerged from comparing dense example boards:

> **Density should come primarily from meaningful geometry, not merely
> arrow count.**

Consider two boards.

### Board A

30 single-cell arrows.

The board is busy. Each successful tap removes one tiny object. The
field changes slowly.

### Board B

12 long arrows averaging eight occupied cells with multiple bends.

The board may contain comparable or greater visual mass. Each removal
can eliminate a major line through the puzzle.

Board B has the potential to be: - harder to trace; - more satisfying to
solve; - more visibly progressive.

## Visual Payoff per Removal

A useful qualitative design question is:

> **When I finally figure this arrow out and remove it, does the board
> visibly breathe?**

This is not yet a formal metric.

It is a human design heuristic.

A strong removal: - clears substantial geometry; - reveals previously
obscured relationships; - reduces scanning load; - creates a visible
opening; - makes the next move easier to perceive.

## The Gordian Knot Metaphor

The best metaphor so far is **untangling a Gordian knot**.

The initial field should be allowed to look intimidating.

But it must remain traceable.

The desired experience is:

1.  The whole field looks tangled.
2.  The player inspects local structures.
3.  A "loose thread" becomes apparent.
4.  The player removes it.
5.  The path-following animation pulls it through the knot.
6.  A region opens.
7.  New relationships become visible.
8.  The player continues.

This metaphor unifies: - long geometry; - path-following animation; -
monotonic simplification; - Open Move assistance; - zoom/pan; -
score-based mastery.

## The Spaghetti Boundary

There is a likely upper boundary where entanglement stops being
satisfying and becomes unreadable.

A future experiment should deliberately include a puzzle that is
probably **too entangled**.

The purpose is not to ship it.

The purpose is to identify the transition from: - challenging tracing

to: - visual spaghetti.

This is a better research question than simply maximizing arrow count.

## Regional Structure

Large boards may support local neighborhoods: - dense knots; - open
corridors; - long vertical/horizontal structures; - peripheral release
arrows; - central tangles.

Regional structure can give the player intermediate goals without adding
explicit progression mechanics.

The player may effectively "work a corner" of the knot.

## Zoom as Part of Reasoning

A zoomable canvas adds another potential cognitive rhythm:

### Macro view

"What is the overall shape? Where are the dense regions? What changed
after that removal?"

### Micro view

"Which line belongs to this arrow? Is this cell part of its tail? What
blocks its head?"

The player can move between strategic visual understanding and detailed
tracing.

This may become part of ArrowSpark's identity rather than merely a
usability feature.

## Why Generation Is Premature

Procedural generation can optimize whatever metrics we give it.

The danger is optimizing the wrong things.

Spec 006 already demonstrated that hitting objective structural targets
does not guarantee satisfying play.

Therefore generation should wait until human experiments provide
evidence about: - what geometry produces useful challenge; - what
creates satisfying releases; - what becomes tedious; - what becomes
unreadable; - how assistance is used; - how puzzle size affects
experience.

Only then should those insights be encoded into generation constraints
or scoring functions.
