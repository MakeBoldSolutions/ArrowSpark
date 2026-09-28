# Specification Evolution: 001--008

## Why This History Matters

ArrowSpark's specifications are not merely a feature list. Each one
changed what the team understood about the game.

The most useful sequence has been:

**build → observe → question → specify smaller next step**

This document records the intent, result, and lesson of each major
specification.

## Spec 001 --- First Playable Arrow Puzzle

### Intent

Prove the core interaction: - fixed grid; - directional arrows; -
blocked vs. removable; - unlimited mistakes; - completion; -
score/results; - replay.

### Result

A complete playable loop existed.

### Lasting decisions

-   mistakes do not stop play;
-   score is floored at zero;
-   gameplay rules live outside presentation;
-   replay starts fresh.

### Lesson

The core mechanic was viable enough to continue.

------------------------------------------------------------------------

## Spec 002 --- Rich Arrow Geometry + Solver

### Intent

Move beyond single-cell arrows and establish formal solvability.

### Result

Arrows gained ordered tails and bends. Solver and validation were added.

### Lasting decisions

-   head direction determines escape;
-   own tail does not block the arrow;
-   another active arrow's occupied cell can block;
-   whole arrow removes atomically;
-   solver operates independently of gameplay controller;
-   legal removal is monotonic.

### Lesson

The rule system was simpler and more mathematically stable than many
puzzle games. This would later justify allowing unlimited exploration.

------------------------------------------------------------------------

## Spec 003 --- Continuous Arrow Visuals

### Intent

Make multi-cell geometry readable and establish visual language.

### Result

Continuous Line2D bodies and polygon heads replaced cell-like
representation.

### Lasting decisions

-   geometry should look continuous;
-   bends matter visually;
-   state feedback has explicit precedence;
-   Make Bold visual system begins here.

### Lesson

Arrow geometry could become part of the product identity.

------------------------------------------------------------------------

## Spec 004 --- Path-Following Arrow Departure

### Intent

Make bent arrows leave naturally.

### Result

Arrows unwind through their own routes rather than translating rigidly.

### Lasting decisions

-   logical removal immediate;
-   animation asynchronous;
-   completion waits for departures;
-   departure progress represented in geometry/cell terms;
-   resize must preserve in-flight behavior.

### Lesson

Animation can reinforce the meaning of the puzzle, not merely decorate
it.

------------------------------------------------------------------------

## Spec 005 --- Multiple Authored Puzzles

### Intent

Move from one demo puzzle to a real content model.

### Result

Eight authored puzzles, catalog, session selection, Level Select, Next
Puzzle, replay, validation gate.

### Lasting decisions

-   catalog chooses;
-   PuzzleDefinition describes;
-   PuzzleState plays;
-   inherited persistent level machinery is not automatically
    appropriate;
-   stable puzzle identity belongs in catalog.

### Gate lesson

Critic identified keyboard/gamepad focus ownership as a real
game-specific risk. The menu needed explicit initial focus.

### Lesson

DevSpark's Critic becomes more useful when it knows game-specific risk
questions.

------------------------------------------------------------------------

## Branding Pass --- ArrowSpark

### Intent

Give the project a coherent product identity.

### Result

ArrowSpark / Make Bold Spark / Make Bold Solutions hierarchy.

### Lasting decision

Branding should recede during active gameplay.

------------------------------------------------------------------------

## Spec 006 --- Puzzle Structure, Challenge, and Character

### Intent

Measure and experiment with what makes puzzles difficult.

### New capability

`PuzzleAnalyzer`.

### Experimental puzzles

-   Nested Chain
-   Cascade / Key Arrow
-   Dense Unravel
-   Bent Network
-   Long-Range Blocker
-   Composed / Shaped Puzzle

### Engineering result

All intended structural targets were achieved.

### Human result

The puzzles were still too easy and insufficiently varied.

### Critical lesson

**Analyzer metrics are descriptive, not experiential.**

Dependency depth over trivial geometry may not feel difficult.

A single-cell arrow connected to another single-cell arrow in a deep
graph still requires almost no tracing.

### New hypothesis

Long, bent, interwoven arrows may be a stronger difficulty lever than
graph depth alone.

------------------------------------------------------------------------

## Spec 007 --- Core Gameplay Contract, Open Move Assistance, and Session Scoring

### Why it came before harder puzzles

If ArrowSpark is going to deliberately create boards that initially look
overwhelming, the player needs a safety contract.

### Product contract

-   hard is fine;
-   unsolvable is not;
-   mistakes cost score;
-   completion remains available;
-   assistance exists;
-   replay is for mastery;
-   memory ends with the session.

### Open Move

"Show Me an Open Move" identifies one legal arrow.

It: - is deterministic for the same state; - does not auto-remove; -
does not reveal a sequence; - costs five mistake-equivalents; - remains
separately counted.

### Session scoring

Best score per level exists only in the running session.

Overall score is the sum of session bests.

### No persistence

No profile, account, login, durable ID, or cross-session gameplay
memory.

### Gate history

Analyze found complete requirement/task coverage and only
context/knowledge metadata issues. Critic found testing isolation,
completed-state guard coverage, defensive scoreboard validation, and
metadata issues.

These were inexpensive, targeted findings rather than reasons to
redesign.

### Current implementation status

**Complete.** Automated implementation was green and the five manual
desktop checks passed on 2026-09-28. The spec was merged into the main
line.

------------------------------------------------------------------------

## Spec 008 --- Large Zoomable Puzzle Canvas (in progress)

Status: specified, planned, and tasked; checklist, analyze, and critic
gates pass; no implementation task executed yet.

### Intent

Remove screen size as a puzzle-design constraint.

### Core principle

**The puzzle defines the world. The screen is only a window into it.**

### Capabilities

-   zoom in/out;
-   pan;
-   Fit Puzzle;
-   keyboard/gamepad navigation;
-   correct input transforms;
-   off-screen Open Move visibility;
-   path-following departure under viewport transforms;
-   resize stability.

### Explicit non-goal

Do not yet build the final Gordian-knot content.

### Why this ordering matters

If large/dense puzzle experiments are authored before the viewport
exists, content will be distorted by today's screen constraints.

Spec 008 should establish the canvas first.

------------------------------------------------------------------------

## Planned Spec 009 --- Gordian Knot Experiments

This is intentionally not yet a finalized specification.

Likely experiment dimensions: - larger boards; - long arrows; - multiple
bends; - dense but traceable geometry; - tails interacting with escape
rays; - regional structure; - few trivial singles; - meaningful visual
clearance per removal; - one deliberately over-entangled/spaghetti case
to locate the usability boundary.

### Hypothesis

Difficulty is driven substantially by **geometric entanglement**.

### Satisfaction hypothesis

Removing a highly entangled arrow should create perceptible
simplification.

### Desired question

Not "Can we make a hard puzzle?"

Instead:

**"What kind of hard puzzle is satisfying to untangle?"**

------------------------------------------------------------------------

## Later --- Web Playtesting and Anonymous Feedback

A future Web build is attractive because it lowers the threshold for
external playtesting:

`send link → play immediately → gather feedback`

Any feedback system should preserve the project's identity boundary: -
no login; - no profile; - no persistent player identity; - no
cross-session recognition.

Feedback exists to improve the game, not to remember the player.

------------------------------------------------------------------------

## Much Later --- Procedural Generation

Generation should come only after enough evidence exists to characterize
good puzzles.

The intended order is:

1.  understand rules;
2.  understand player contract;
3.  remove viewport constraint;
4.  hand-author hard knots;
5.  observe human behavior;
6.  correlate structural/geometric characteristics with experience;
7.  only then consider generation.

This avoids teaching a generator to optimize metrics that humans do not
actually enjoy.
