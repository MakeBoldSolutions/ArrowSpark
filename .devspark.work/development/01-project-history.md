# ArrowSpark Project History

## 1. Origin: Learning Game Development Through DevSpark

ArrowSpark began as an experiment in applying DevSpark to game
development. The initial goal was intentionally modest: build a small,
understandable arrow puzzle in Godot while learning the engine and
testing whether the DevSpark workflow translated well from
application/API development into an interactive game.

The project uses **Godot 4** and **GDScript**. Choosing GDScript was
deliberate even though the developer already had substantial C#/.NET
experience: part of the exercise was to learn Godot on its native
scripting path rather than simply recreating familiar
application-development patterns.

The repository began from `ovrdos/godot-game-template` / Maaack's Game
Template. Its original Git history was removed and a new repository
initialized so ArrowSpark could evolve independently.

DevSpark was then applied using the normal lifecycle:

`specify → clarify → plan → tasks → analyze → implement → PR review → merge`

This became a useful test of one of DevSpark's central ideas: the
specification is temporary implementation context, while code, tests,
and current knowledge become the durable record.

## 2. Spec 001 --- First Playable Puzzle

The first specification created the basic game loop.

The board was a fixed 5×4 grid with eight arrows. Each arrow had one of
four directions: up, down, left, or right. Selecting an arrow caused one
of two outcomes:

-   if its forward path to the edge was clear, the arrow left the board;
-   if another active arrow blocked that path, the arrow stayed and the
    mistake counter increased.

The fundamental product decision appeared immediately:

**A mistake should not stop play.**

There were no lives, no forced restart, and no attempt limit. Clearing
every arrow completed the puzzle. Results showed total arrows, mistakes,
score, and accuracy.

The original score was:

`score = max(total_arrows - mistakes, 0)`

Accuracy was based on successful removals divided by total taps.

The first implementation established the early architecture: -
`PuzzleDefinition` described the authored puzzle. - `PuzzleState` owned
gameplay rules. - `PuzzleBoard` and `ArrowView` handled presentation. -
the controller coordinated state, animation, HUD, and completion. -
results formatting remained separate.

The first regression suite also established a pattern that has
continued: rule-level tests, layout checks, save/input checks, and
manual playtesting all matter.

## 3. Spec 002 --- Rich Arrow Geometry and Solver

The second specification changed ArrowSpark from a collection of
independent arrow icons into a geometry-based puzzle.

An arrow became: - one head cell; - one direction; - zero or more
ordered tail cells.

Tail cells form a continuous, nonbranching orthogonal path behind the
head and can contain any number of right-angle bends.

The important gameplay rule remained simple: the **head direction**
determines escape. The arrow's own tail does not block itself. Any
occupied cell belonging to another active arrow in the strict forward
ray blocks removal.

This specification introduced: - structural validation; - ownership
mapping; - atomic whole-arrow removal; - a solver; - deterministic
solver witnesses; - explicit invalid/unsolvable/solvable analysis.

A key mathematical property emerged: ArrowSpark's removal rules are
**monotonic**. Removing an arrow eliminates occupied cells and therefore
cannot create a new blocker. A legal move cannot make a solvable puzzle
worse.

That property would later become central to the game's product
philosophy.

## 4. Spec 003 --- Continuous Arrow Visuals

Spec 003 made the logical tail geometry visually meaningful.

Instead of rendering arrows as disconnected cells, `ArrowView` began
drawing a continuous line with an arrowhead. Bent tails became visible
paths. Single-cell arrows received a synthetic short tail so they still
read as arrows.

The Make Bold visual foundation was introduced: - cream background; -
dark neutral arrows; - ember hover; - rust accent; - green success; -
restrained borders and text colors; - Be Vietnam Pro / Inter Tight
typography direction.

State precedence was clarified: `departure → blocked → hover → normal`.

This was the first point where ArrowSpark's geometry began to become
part of the game's identity rather than merely a data structure.

## 5. Spec 004 --- Path-Following Departure

A critical presentation insight followed: a bent arrow should not leave
the board as a rigid shape sliding in one direction. It should appear to
**feed through its own path**.

Spec 004 therefore made departure animation path-following.

Logical removal still happens immediately. Presentation then animates a
moving interval along the arrow's immutable polyline. As the head moves
forward along its escape ray, the tail follows through the original
bends.

This produces an "unwinding" effect.

That decision later became unexpectedly important. Once the project
began exploring long, dense, interwoven arrows, the departure animation
was no longer merely polish. It became the visual expression of the
game's emerging metaphor: **pulling a thread out of a knot**.

## 6. Spec 005 --- Multiple Authored Puzzles

Until Spec 005, the game contained one hard-coded puzzle.

Spec 005 introduced: - `PuzzleCatalog`; - eight authored puzzles; -
stable puzzle IDs and titles; - `PuzzleSession` for process-lifetime
selection; - Level Select; - Replay; - Next Puzzle; - puzzle identity in
HUD/results; - catalog validation.

The inherited Maaack level/progression system was deliberately not used
because it assumed persistent scene-per-level progression and win/loss
semantics. ArrowSpark needed reusable scene + data-driven puzzle
selection and, at that point, session-only selection.

All eight puzzles were solver-confirmed solvable with zero-mistake
witnesses.

A Critic finding also exposed a practical game-development risk: opening
a menu does not automatically guarantee useful keyboard/gamepad focus.
Explicit focus ownership was added and tested.

## 7. Branding Pass --- ArrowSpark

The product was named **ArrowSpark**.

The hierarchy became: - ArrowSpark --- the game/product; - A Make Bold
Spark Game --- family; - Created by Make Bold Solutions --- creator; -
makeboldspark.com --- destination.

Branding was intentionally concentrated at application-level surfaces.
Active gameplay should prove the brand rather than repeatedly display
it.

The shorthand became:

**ArrowSpark → product.\
Make Bold Spark → family.\
Make Bold Solutions → creator.\
Gameplay → the proof.**

## 8. Spec 006 --- Puzzle Structure, Challenge, and Character

Spec 006 attempted to answer the first serious game-design question:

**What makes one ArrowSpark puzzle more challenging or interesting than
another?**

A `PuzzleAnalyzer` was created to measure objective structure. Six
experiments were authored: 1. Nested Chain 2. Cascade / Key Arrow 3.
Dense Unravel 4. Bent Network 5. Long-Range Blocker 6. Composed / Shaped
Puzzle

The experiments successfully hit their intended structural targets. That
was the engineering success.

The human playtest was the more important result.

The puzzles still felt too simple. Perceived challenge was about 2/5.
Scanning load remained low. The intended cascade did not produce a
meaningful "aha." Several experiments were contradicted by the play
experience.

The key observation was that many of the supposedly complex dependencies
were still relationships between visually trivial single-cell arrows.

This exposed a distinction:

**Graph complexity is not necessarily perceptual complexity.**

Spec 006 therefore succeeded by disproving an assumption.

## 9. The Geometric Entanglement Hypothesis

The post-Spec-006 discussion changed the design direction.

The player described wanting: - more long arrows; - more bent arrows; -
more arrows mixed together; - less dependence on fields of tiny single
arrows.

This led to the concept of **geometric entanglement**: difficulty
created by the amount of visual tracing required to identify an arrow,
understand its route, and determine whether its escape path is clear.

Long tails have a dual role: 1. they create reasoning difficulty; 2.
they create visual reward when removed.

A dense field of single-cell arrows can feel like cleanup. Removing one
barely changes the board.

Removing one long, multi-bend arrow can clear a large amount of visual
structure. The field visibly opens.

The metaphor became:

**Untangling a Gordian knot.**

The gameplay loop became:

`Knot → find a loose thread → pull it → field opens → find another thread → repeat`

## 10. Spec 007 --- Core Gameplay Contract

Before intentionally making puzzles much harder, the project needed a
stronger player contract.

The guiding principle became:

**Hard is fine. Unsolvable is not.**

Spec 007 added **Show Me an Open Move**.

This is not a solver button. It identifies exactly one currently legal
arrow. It does not remove it. It does not reveal the next sequence. It
makes no claim that the move is "best."

The player still performs the move.

The assistance cost is equivalent to five mistakes, while mistakes and
assists remain separately counted.

The scoring formula became:

`score = max(total_arrows - (mistakes + open_move_assists * 5), 0)`

Spec 007 also established session-best scoring: - first completion
establishes a level's session best; - a better replay improves it; -
equal/worse replays cannot lower it; - overall session score is the sum
of best completed level scores.

Most importantly, the session boundary was made explicit:

**ArrowSpark remembers gameplay only for the currently running
session.**

No profiles. No login. No identity. No cross-session score history. No
durable gameplay memory.

## 11. The Large-Canvas Insight

While examining examples of dense commercial arrow puzzles, another
limitation became obvious: the puzzle should not have to fit on the
physical display.

Large knots should be allowed to be large.

The player should be able to: - zoom out to understand the whole knot; -
zoom in to trace dense geometry; - pan through regions; - return to Fit
Puzzle.

This creates another separation:

-   **Board size** --- logical puzzle world.
-   **Geometric density** --- how much meaningful geometry occupies an
    area.
-   **Viewport scale** --- how much of the world is currently visible.

The new principle is:

**The puzzle defines the world. The screen is only a window into it.**

This is the intended subject of Spec 008.

## 12. Current Moment

At this documentation snapshot: - Spec 007 implementation is
substantially complete. - automated checks are green; - five manual
desktop checks remain; - the spec correctly remains `In Progress`; - no
changes are committed yet on `007-spec-open-move-scoring`; - Spec 008
has been conceptually drafted as **Large Zoomable Puzzle Canvas**; - the
following puzzle-design work is expected to explore **Gordian Knot
Experiments**.

The project has therefore moved through three phases:

**Phase 1 --- Prove the game works.**\
Specs 001--005.

**Phase 2 --- Learn what the game actually is.**\
Spec 006 and the playtesting/design discussion.

**Phase 3 --- Establish the contract and remove artificial
constraints.**\
Spec 007 and proposed Spec 008.

The eventual goal is not simply "more levels."

It is to understand what makes a knot satisfying enough that, only then,
procedural generation might be worth attempting.
