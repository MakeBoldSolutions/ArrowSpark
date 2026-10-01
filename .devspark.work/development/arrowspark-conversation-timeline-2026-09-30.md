# ArrowSpark Conversation Timeline

**Project:** ArrowSpark\
**Period covered:** September 26--30, 2026\
**Prepared:** September 30, 2026\
**Purpose:** Chronological record of the ArrowSpark design conversation,
including implementation milestones, experiments, gameplay discoveries,
and the emerging roadmap.

> **Timestamp note:** Exact timestamps are included where available from
> conversation history. Where only the date or sequence is available,
> the entry is labeled by date rather than inventing a precise time.
> Converted timestamps use Central Daylight Time (CDT).

------------------------------------------------------------------------

## 2026-09-26 --- From Idea to Playable Game

### 10:53 CDT --- Arrow-clearing game direction established

ArrowSpark began as a learning project inspired by arrow-clearing games
such as Arrow Away / Tap Away / Arrow Escape. The product direction
deliberately rejected lives, fail states, forced restarts, timers, and
forced ads. Mistakes would reduce score rather than prevent completion.

> **Hard is fine. Unsolvable is not.**

The stack settled on Godot 4, GDScript, Windows as the initial
development/reference platform, Git/GitHub, Maaack's Game Template, and
DevSpark. The starter Godot repository ran successfully before puzzle
development began.

### 11:56 CDT --- Spec 001: First Playable Arrow Puzzle

Spec 001 defined the smallest complete loop: one handcrafted 5×4 puzzle
with 8 arrows, four directions, blocking/removal, unlimited mistakes,
score, accuracy, Results, Replay, and Main Menu. `PuzzleDefinition` /
`PuzzleState` separated logical rules from presentation.

### 14:00 CDT --- Spec 001 complete

The first playable slice was reported working with the RefCounted rule
core, headless tests, menu integration, successful manual play, and 189
puzzle-suite passes.

### 14:01 CDT --- Spec 002: Rich Arrow Geometry

Spec 002 introduced ordered multi-cell tails, right-angle bends, unique
cell ownership, blocking by any occupied cell of another active arrow,
atomic removal, validation, deterministic solving, and witness
solutions.

A fundamental property emerged: legal removal is monotonic. Removing an
arrow cannot create a new blocker. This pushed the design problem toward
perception and understanding rather than strategic dead ends.

### Evening --- Specs 003--004: Make arrows feel like arrows

**Spec 003 --- Continuous Arrow Visuals** introduced continuous
`Line2D`/`Polygon2D` arrows, bent-path rendering, hover/blocked
feedback, and the Make Bold visual foundation.

**Spec 004 --- Path-Following Departure** made bent arrows unwind
through their own paths instead of translating rigidly. Logical removal
remained immediate while presentation animated the departure. This later
became central to the "pulling a thread from a knot" metaphor.

------------------------------------------------------------------------

## 2026-09-27 --- From Mechanics to Puzzle Research

### Early morning --- Spec 005: Multiple Authored Puzzles

Spec 005 added `PuzzleCatalog`, eight handcrafted solver-validated
puzzles, stable IDs, `PuzzleSession`, Level Select, Replay, Next Puzzle,
and Main Menu, with no persistent progression.

> **Catalog chooses the puzzle. PuzzleDefinition describes the puzzle.
> PuzzleState plays the puzzle.**

### Morning --- First major design problem

Playing the first eight levels showed that they were too easy. Removal
was monotonic, only 3/8 puzzles used bends, and structural dependency
alone did not create much perceptual challenge.

The working recommendation became:

> **Measure before automating.**

### 09:35 CDT --- Pre-Spec 006 research

The project began separating objective structural complexity from felt
difficulty. Candidate characteristics included dependency depth, legal
starting choices, branching, blocker distance, density, cascade
behavior, long-range relationships, and bent geometry.

### Late morning / afternoon --- Spec 006: Puzzle Structure, Challenge, and Character

Spec 006 added `PuzzleAnalyzer` and six experiments: Nested Chain,
Cascade/Key Arrow, Dense Unravel, Bent Network, Long-Range Blocker, and
Composed/Shaped Puzzle. The catalog grew from 8 to 14. The
implementation reported 39/39 tasks and 122 analyzer assertions passing.

### Spec 006 human playtest --- Major conceptual turning point

The experiments hit their structural targets but mostly still felt easy.

> **Structural complexity does not equal perceptual complexity.**

Single-cell-heavy puzzles could have interesting graphs while remaining
visually trivial. Long and bent arrows were more interesting. Dense
fields of isolated singles were boring. The desired experience began to
resemble untangling a Gordian knot.

> **Geometry may be the puzzle, not merely its display.**

The mental loop became:

> **Trace → understand → untangle → remove → simplify → repeat.**

And a key principle emerged:

> **Density should come primarily from arrow geometry, not arrow
> count.**

### Spec 007 --- Open Move Assistance and Session Scoring

Spec 007 introduced **Show Me an Open Move**: identify one legal arrow
without removing it or exposing the whole solution. Each use costs the
equivalent of 5 mistakes.

Score became:

`max(total_arrows - (mistakes + open_move_assists × 5), 0)`

The memory boundary became explicit:

> **ArrowSpark remembers only the game you're playing right now.**

No login, profile, persistent score history, cross-session identity, or
persistent anonymous player ID.

### Late September 27 --- Large-board direction

Long arrows and denser knots exposed the screen-size limitation.

> **The puzzle board is a world/canvas, not a screen-sized layout.**

Board size, geometric density, viewport, and zoom became separate
concepts. Larger puzzles should use a camera, not smaller arrows.

------------------------------------------------------------------------

## 2026-09-28 --- Spec 008: Large Zoomable Puzzle Canvas

Spec 008 added `PuzzleViewportTransform` as the authority mapping
logical grid ↔ board-local visual ↔ viewport/screen. Importantly,
`PuzzleState`, `PuzzleSolver`, `PuzzleAnalyzer`, and `PuzzleScoreboard`
required no changes.

Added bounded zoom, pan, Fit Puzzle, mouse/keyboard/gamepad navigation
coverage, off-screen Open Move reveal, correct departures during
navigation, and transient viewport state.

### Puzzle 15 --- Canvas validation fixture

A 52-arrow fixture with long bent geometry exercised both-axis overflow,
long departures, overlapping departures, off-screen assistance, and
working-scale navigation. The catalog grew from 14 to 15.

It was explicitly a validation fixture, not evidence of ideal gameplay.

### Verification

On the 52-arrow fixture with eight overlapping departures:

-   handler p95: 0.091 ms;
-   frame p95: 17.11 ms;
-   longest frame: 19.9 ms.

Regression gates passed on the Godot 4.4 declared target and
supplementary 4.7.2 runs. A Level Select scrolling issue at 960×540 was
also found and fixed.

> **The puzzle defines the world. The screen is only a window into it.**

------------------------------------------------------------------------

## 2026-09-29 --- ArrowSpark becomes a game-design research project

### Spec 008 merged

Spec 008 merged via PR #1. The development story now looked like:

-   Specs 001--005: build the machinery;
-   Spec 006: structural complexity ≠ felt challenge;
-   Spec 007: make harder puzzles safe for the player;
-   Spec 008: remove the physical-screen constraint.

The next question became:

> **What actually makes a knot satisfying to untangle?**

### Spec 009 conceived --- Gordian Knot Experiments

Spec 009 was framed as an experiment, not a content-production spec.

Primary hypothesis: challenge comes substantially from **geometric
entanglement** --- the tracing and spatial reasoning required to
understand long, bent, interwoven arrows.

Secondary hypothesis: substantial arrows provide both reasoning
challenge and visual reward because their removal visibly simplifies the
board.

The project deliberately deferred generators, difficulty formulas,
entanglement scores, and level-builder tooling.

------------------------------------------------------------------------

## 2026-09-30 --- Spec 009 results and the emerging design grammar

### Morning --- Spec 009 implementation status

Six new handcrafted experiments took the catalog from 15 to 21:

  -----------------------------------------------------------------------
  Puzzle                              Experimental purpose
  ----------------------------------- -----------------------------------
  `knot_long_geometry`                Long bent paths without much
                                      interweaving

  `knot_interwoven_paths`             Nearby winding paths and tracing
                                      demand

  `knot_dense_core`                   Concentrated adjacent geometry

  `knot_regions`                      Separated regions / neighborhoods

  `knot_single_release`               One prominent long-arrow release

  `knot_boundary`                     Deliberately excessive winding /
                                      spaghetti boundary
  -----------------------------------------------------------------------

Automated work was essentially complete: all six valid and solvable,
puzzle and full regressions green, deterministic structural reporting,
Analyze/Critic clean, checklist 19/19.

Notable measurements included dependency edges from 2 to 51,
`knot_regions` average blocker distance around 12.9, a 101-cell arrow in
`knot_single_release`, and `knot_boundary` at 28 arrows / 508 occupied
cells / 32 bends / 51 dependency edges.

The Verify gate correctly remained blocked until human evidence existed.

### Spec 009 playtest --- The toolbox conclusion

The human playtest produced the next major realization:

> **We have good conceptual knowledge of gameplay, but we still don't
> have the "perfect level."**

Each experiment demonstrated a skill or concept, but none composed
everything into one excellent experience.

> **We have a good toolbox, but we haven't built anything yet.**

That became the bridge to Spec 010.

### Meaningful density clarified

A grid full of single-cell arrows can be technically dense and still be
terrible gameplay.

The conversation distinguished:

**Occupancy density** --- how much of the board is occupied.

**Meaningful density** --- density created by substantial geometry that
must be traced and understood.

Likewise, blocker distance is only interesting when discovering the
relationship requires meaningful tracing or spatial reasoning.

> **Metrics describe ingredients. They don't describe the recipe.**

### Neighborhoods emerge

A major idea from the regional experiment was to create recognizable
areas that are substantially solvable locally but leave a few unresolved
arrows dependent on another neighborhood.

This creates two reasoning scales:

**Local:** "What can I untangle here?"

**Global:** "Why can't I finish this area, and where does the blocker
come from?"

Neighborhoods should emerge naturally from geometry, whitespace,
clustering, bends, long arrows, and dependencies --- not explicit boxes
or labels.

### Bridge Arrows

A **Bridge Arrow** connects neighborhoods through geometry or
dependency. The ideal reaction is:

> **"Aha! That's what was holding these two areas together."**

Its removal can unwind across the board and release progress elsewhere,
combining long geometry, blocker distance, tail dependencies, regional
structure, visual payoff, and path-following departure.

### Insight Chains --- the real reward

The user identified the moment that keeps the game engaging:

> **The aha moment is when you suddenly see the next three steps.**

The reward is not merely finding one legal move. It is understanding a
short consequence chain:

> "This one comes out, which frees that one, which lets me pull that
> one."

This was named an **Insight Chain**. The exact number of moves is not
important; the phenomenon is prediction followed by satisfying
execution.

### Discovery Beats --- the hook

The next refinement: the whole puzzle must not become one long A-to-Z
chain after the first discovery.

The desired cycle became:

> **Confusion → Investigation → Aha → Insight Chain → Execute → Payoff →
> New Uncertainty**

This was named a **Discovery Beat**.

A strong level needs multiple Discovery Beats. After enjoying a short
period of mastery, the changed board should eventually require the
player to stop and rethink.

> **Alternate uncertainty with mastery.**

Too fragmented:

> Think → one move → think → one move → think → one move.

Too linear:

> One aha → A → B → C → D → E → F → finish.

Desired:

> Aha → several moves → rethink → aha → several moves → rethink → major
> release → rethink → final collapse.

### Spec 010 direction --- The Reference Puzzle

Spec 010 became **The ArrowSpark Reference Puzzle**: one crafted level
combining everything learned rather than another collection of isolated
experiments.

The intended experience curve:

1.  **The Knot** --- substantial but approachable.
2.  **First Understanding** --- find a foothold.
3.  **Local Progress** --- open a neighborhood.
4.  **Local Wall** --- progress stops for a reason.
5.  **Global Discovery** --- trace the dependency elsewhere.
6.  **Insight Chain** --- see several consequences.
7.  **Execution** --- enjoy acting on that understanding.
8.  **Major Release** --- substantial geometry unwinds.
9.  **Renewed Uncertainty** --- the changed board poses another
    question.
10. **Repeated Discovery Beats** --- alternate uncertainty and mastery.
11. **Final Understanding** --- solve the last conceptual barrier.
12. **Satisfying Collapse** --- finish without tedious cleanup.

The qualitative success criterion:

> **This is a level I want someone else to play.**

Automated verification alone must not be allowed to declare Spec 010
successful.

### Level groups proposed

With 21 historical/research puzzles and future polished levels, a flat
list no longer represents the catalog's meaning.

Proposed groups:

**Foundations** --- early puzzles that established mechanics, geometry,
solver behavior, rendering, and gameplay.

**Puzzle Lab / Experiments** --- research content from Specs such as 006
and 009, valuable even when intentionally not ideal gameplay.

**ArrowSpark Levels** --- player-facing levels intentionally designed
against the mature gameplay standard, beginning with the Spec 010
Reference Puzzle.

> **A valid puzzle is not necessarily a game-quality level.**

Grouping should remain metadata, preserve stable IDs, and not affect
gameplay rules.

### Spec 011 proposed --- Web Showcase & Playtest

The proposed roadmap became:

**009 --- Gordian Knot Experiments**\
Learn the tools.

**010 --- Reference Puzzle + Level Groups**\
Demonstrate craftsmanship.

**011 --- Web Showcase & Playtest**\
Put the Reference Puzzle in front of people who did not design it.

**012 --- Extract the Design Grammar**\
Compare analyzer facts, designer intent, and outside-player experience.

**013+ --- Level Builder / Generator Research**\
Only after understanding what successful handcrafted levels actually
have in common.

The Web Showcase should remain narrow:

> **Playable URL + Reference Puzzle + lightweight anonymous playtest
> feedback.**

No login, profiles, persistent player identity, durable gameplay memory,
leaderboard, or monetization infrastructure.

Useful observations could include completion, mistakes, Open Move usage,
replay, improvement, completion time, and zoom/pan usage, plus
lightweight explicit feedback on challenge, satisfaction, willingness to
play another level, and optional comments.

The strongest test would be giving a new player the Reference Puzzle
without teaching them terms such as Neighborhood, Bridge Arrow, Insight
Chain, or Discovery Beat, then seeing whether they independently
describe those experiences.

------------------------------------------------------------------------

## 2026-09-30 09:14 CDT --- Current state

ArrowSpark has moved through three broad phases.

### Phase 1 --- Build the game

Specs 001--005 established rules, geometry, solver, rendering,
departures, catalog, and Level Select.

### Phase 2 --- Learn what makes the game interesting

Specs 006--009 established that:

-   structural complexity alone is insufficient;
-   geometric entanglement matters;
-   density must be meaningful;
-   long geometry can create challenge and reward;
-   large boards need a viewport rather than smaller arrows;
-   assistance permits difficulty without punishment;
-   neighborhoods can create local/global reasoning;
-   bridge arrows connect those neighborhoods;
-   Insight Chains create temporary mastery;
-   Discovery Beats renew curiosity;
-   one giant solution chain is undesirable;
-   the desired rhythm alternates uncertainty and mastery.

### Phase 3 --- Build the actual game experience

  -----------------------------------------------------------------------
  Spec                                Purpose
  ----------------------------------- -----------------------------------
  **009**                             Close out Gordian Knot experiments
                                      and preserve the toolbox/lessons

  **010**                             Craft the first Reference Puzzle
                                      and introduce meaningful level
                                      grouping

  **011**                             Web Showcase and outside-player
                                      playtesting

  **012**                             Extract an evidence-based
                                      ArrowSpark design grammar

  **013+**                            Investigate level-builder /
                                      procedural-generation approaches
  -----------------------------------------------------------------------

The central question has changed from:

> **"Can we generate harder arrow puzzles?"**

to:

> **"Can we repeatedly create knots that reward the player for
> understanding them?"**

The current gameplay theory is:

> **Create uncertainty.\
> Let the player earn understanding.\
> Let them enjoy that understanding.\
> Change the knot.\
> Make them curious again.**

The immediate milestone is deliberately human rather than algorithmic:

> **Build one ArrowSpark level good enough that we want to hand it to
> someone else and say, "Try this."**
