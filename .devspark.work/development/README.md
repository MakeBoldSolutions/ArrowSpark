# ArrowSpark Development Documentation

**Snapshot date:** 2026-09-28 (updated: Specs 001--007 complete, Spec 008 in progress)\
**Project:** ArrowSpark\
**Family:** A Make Bold Spark Game\
**Creator:** Make Bold Solutions\
**Development approach:** DevSpark / spec-driven, agentic development\
**Engine:** Godot 4 / GDScript

## Purpose

This document set captures the development history, product reasoning,
architecture, experiments, lessons, current implementation state, and
emerging roadmap for ArrowSpark.

It is intentionally more than a conventional technical README.
ArrowSpark has evolved through a sequence of small specifications in
which implementation, automated analysis, human playtesting, and product
thinking have influenced one another. Several of the most important
discoveries were not code discoveries at all: they were discoveries
about what makes the game satisfying.

The project began as a small arrow-clearing puzzle and has increasingly
become an **untangling game**. The emerging experience is less about
clearing many independent arrows and more about looking at a complicated
field, finding a loose thread, pulling a long bent arrow out of the
knot, and watching the field become simpler.

The current product principles are:

> **Hard is good. Unsolvable is not.**

> **Mistakes cost score, not play.**

> **Completion is expected; efficiency is scored.**

> **There is always a way out. The challenge is seeing it.**

> **The session is the gameplay-memory boundary.**

> **Density should come primarily from meaningful geometry, not merely
> arrow count.**

> **A successful removal should make the knot feel more untangled.**

The next architectural direction is:

> **The puzzle defines the world. The screen is only a window into it.**

## Document Map

1.  [01-project-history.md](01-project-history.md) --- chronological
    development history from first playable through the current state.
2.  [02-product-philosophy.md](02-product-philosophy.md) --- the product
    contract and why ArrowSpark rejects punitive puzzle mechanics.
3.  [03-architecture.md](03-architecture.md) --- current technical
    architecture and authority boundaries.
4.  [04-spec-evolution.md](04-spec-evolution.md) --- detailed Spec
    001--008 evolution and what each specification taught us.
5.  [05-puzzle-design-research.md](05-puzzle-design-research.md) ---
    difficulty research, Spec 006 findings, geometric entanglement, and
    the Gordian-knot hypothesis.
6.  [06-scoring-assistance-session.md](06-scoring-assistance-session.md)
    --- mistakes, Open Move, scoring, replay, and session-only state.
7.  [07-testing-and-devspark-process.md](07-testing-and-devspark-process.md)
    --- DevSpark lifecycle, automated gates, Critic/Analyze findings,
    and testing strategy.
8.  [08-current-state.md](08-current-state.md) --- current
    implementation status, known deviations, and branch state.
9.  [09-spec-008-direction.md](09-spec-008-direction.md) --- large
    zoomable puzzle canvas direction and acceptance concerns.
10. [10-roadmap.md](10-roadmap.md) --- near-term and later roadmap,
    including Web playtesting, anonymous feedback, harder puzzles, and
    eventual generation.
11. [11-design-principles-and-decisions.md](11-design-principles-and-decisions.md)
    --- concise decision record of settled principles and explicit
    non-goals.
12. [12-devspark-lessons.md](12-devspark-lessons.md) --- what this
    project has taught us about DevSpark itself.
13. [13-roadmap-008-010.md](13-roadmap-008-010.md) --- living roadmap
    for Specs 008--010 with entry/exit criteria and a revision protocol.
14. [source-spec-007.md](source-spec-007.md) --- captured Spec 007
    source document supplied during this development discussion.
15. [source-analyze-007.md](source-analyze-007.md) --- captured Analyze
    gate output.
16. [source-critic-007.md](source-critic-007.md) --- captured Critic
    gate output.

## Current Executive Summary

ArrowSpark is a Godot/GDScript puzzle game in which arrows occupy grid
cells. An arrow has a head, a direction, and optionally a continuous
ordered tail containing bends. A legal arrow can leave the board when no
occupied cell belonging to another active arrow blocks the strict
forward ray from its head. Removal is monotonic: legal removal cannot
make a previously solvable puzzle unsolvable.

The project now has authored puzzle catalog support, a solver, a
structural analyzer, continuous arrow rendering, path-following
departure animation, session-only scoring, and a player assistance
action called **Show Me an Open Move**.

The most important product discovery so far is that objective dependency
metrics alone did not produce satisfying difficulty. Spec 006
deliberately created puzzles with deeper dependencies, cascades,
density, long-range blocking, and composed shapes. Human playtesting
still found the puzzles too simple. The likely reason was geometric: too
many arrows were single-cell or visually trivial. A dependency graph can
be structurally interesting while remaining visually obvious.

The emerging hypothesis is that ArrowSpark's strongest challenge and
reward come from **geometric entanglement**: long, bent arrows occupying
and crossing visual regions, forcing the player to trace ownership and
dependencies. Removing such an arrow is rewarding because it clears
substantial visual mass. The player is not merely deleting an object;
they are pulling a thread out of a knot.

Spec 007 establishes the safety contract required before making puzzles
significantly harder: unlimited mistakes, no fail state, a costly Open
Move assist, replay for score improvement, and no persistent player
memory. Spec 008 (in progress) removes the next artificial constraint:
puzzle size should no longer be limited by screen size. A large puzzle
should be navigable through zoom, pan, and Fit Puzzle.

This documentation snapshot represents the state after Spec 007 was
completed and merged (automated checks green, manual desktop checks
passed) and while Spec 008 is planned but not yet implemented. Specs
001--007 are complete; Spec 008 is in progress.
