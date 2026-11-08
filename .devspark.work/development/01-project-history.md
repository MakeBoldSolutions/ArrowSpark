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
This became the subject of Spec 008.

## 12. Spec 008 --- Large Zoomable Puzzle Canvas (2026-09-28)

Spec 008 was implemented and merged as PR #1 (`faa4575`). It separated four
ideas that had been conflated: board size, geometric density, viewport and
zoom.

- A new presentation authority, `PuzzleViewportTransform`, maps logical grid,
  board-local and screen coordinates. Its math is unit-tested apart from
  rendering.
- Zoom, pan and **Fit Puzzle** work by mouse, keyboard and gamepad. View state
  is transient: no camera state is persisted, and each replay starts at Fit.
- Open Move now brings an off-screen target into view without changing its
  contract (one deterministic target, one cost, no removal).
- Departures stay correct under navigation and complete on full logical
  clearance, not on viewport clipping.
- A 52-arrow `canvas_validation` puzzle (40x30) exercised all of this.
- Level Select gained a scroll container after 15 entries clipped at 960x540.

Verification passed on Godot 4.4 and 4.7.2. The verify gate was `warn`: some
scenarios (gamepad hardware, and others) were accepted as outstanding and not
claimed as passed. Touch input was deliberately left out.

The same day added `.knowledge` integrity validation and, on 2026-09-28,
the rebrand of repo-facing docs to **ArrowSpark / Make Bold Solutions**
(`0ea27a6`).

## 13. Spec 009 --- Gordian Knot Experiments (2026-09-29)

Spec 009 answered the Spec 008 follow-up question with content: six
hand-authored experimental puzzles (PR #2, `8a00239`), taking the catalog from
15 to 21 entries.

Puzzles: Long Geometry, Interwoven Paths, Dense Core, Distinct Regions,
Single Release, Boundary Knot. Each is solver-confirmed solvable, passes the
catalog gate, and has a recorded structural report from `PuzzleAnalyzer`
(descriptive only; nothing gates on difficulty). Findings are in
`.knowledge/reference/gordian-knot-experiments.md`.

Human evidence is thin and stated as such: one aggregate author session across
all six puzzles, with per-puzzle detail not recorded. The aggregate reaction
supported the geometric-entanglement hypothesis (long, bent removals are
satisfying; tail-based dependencies create reasoning challenge). It is one
tester who knew the designs, so it is evidence and not proof.

The spec also added a structural-report launcher and a playtest guide, and was
re-verified on Godot 4.4.1.

## 14. Codebase Audit (2026-09-29)

A `devspark.site-audit` run found no gameplay defect. Its one high finding was
escaped planning references (temporary review ids) in durable comments, plus
stale test documentation. PR #3 (`312b0c7`) recorded the audit and the PR
review documentation. Audit evidence is in `.devspark.work/audit/`.

## 15. Spec 010 --- Reference Puzzle and Level Groups (2026-09-29 to 2026-10-01)

**The numbering moved.** The 2026-09-28 roadmap reserved "Spec 010" for a Web
Playtest Build. The number was spent on a different question instead: *what
does the intended ArrowSpark experience feel like in one composed level?*
The Web work moves down a slot (see [13-roadmap-008-010.md](13-roadmap-008-010.md)).

Delivered (PR #4, `6e60e11`, merged 2026-10-01):

- **Purpose groups** in `PuzzleCatalog`: Foundations (8), Puzzle Lab (13),
  ArrowSpark Levels (1). Groups are metadata only and own no gameplay.
- **Accordion Level Select**, group-relative numbering, group-scoped Next
  Puzzle (never wraps or crosses groups), and a Back button.
- **Reference Knot** (`reference_knot`): a hand-composed 46x32 board with 115
  arrows, 1348 of 1472 cells occupied, 207 bends, longest arrow 43. Main-menu
  Play now starts it. Solver confirms it solvable; its witness replays with zero
  mistakes.
- Analyzer longest-chain search was reworked to a linear-time acyclic path so
  dense boards stay tractable.
- A temporary F3 cell-size readout was added, then removed during PR review.
- The design report is durable knowledge:
  `.knowledge/reference/reference-puzzle-design-report.md`.

Human playtest: the designer played the final version and answered all fifteen
questions with an unqualified yes. Learning that changed an assumption:

- "Some freedom is good; too many simultaneously obvious moves feels like
  clicking." About ten obvious moves in the middle "starts to feel old."
- Neighborhoods emerge from cleared white space during play rather than from the
  starting layout.
- SC-005 as originally written was too absolute and was amended with the
  original wording preserved. Against the original wording it is **not met**;
  this is recorded, not hidden.

Documented limitations at close: familiar tester only; no independent player;
SC-009 (fresh-player discovery of the ArrowSpark Levels group) **not
performed** and deferred; desktop smoke test not run as a manual pass.
PR review went three revisions to approve with no blocking findings.

## 16. Spec 011 --- Web Showcase

Merged as PR #5 on 2026-10-03 (UTC). The game gained a Web export, a puzzle
content version and a completion hand-off to the host page. A static site in
`web/` (Astro, strict TypeScript, no server code) hosts the playable game at
`https://arrow.makeboldspark.com`, tells the build story in chapters, and
carries a reactions client for anonymous feedback to a separate API. The
constitution moved to 2.1.0 to allow the Web target. The deployment pipeline is
a single Azure Static Web Apps workflow. A dependency audit runs in CI with a
reasoned advisory allowlist. See `.knowledge/architecture/web-showcase.md`.

## 17. Spec 012 --- Mobile Web Play

The plan was a real-device spike followed by touch controls sized to 44 px, but
the work was cut to a beta by owner decision.

- **PR #6, merged 2026-10-03 (UTC): mobile web beta.** The Play page decides
  admission from viewport and input capability, not the user agent (desktop:
  fine pointer and at least 960 x 540; touch: landscape and at least 640 x
  320). The finding was that the engine already turns touch into the existing
  click path, so a usable beta needed an admission change, not new input code.
  Portrait shows a rotate message. The constitution moved to 2.2.0.
- **PR #8, merged 2026-10-11 (UTC): modeless touch.** Pinch failed on a real
  Pixel 7 Pro in the beta, so `PuzzleBoard` now handles touch directly: a tap
  acts on release, one-finger drag pans (no Pan mode needed) and two-finger
  pinch zooms. The Play stage also sets `touch-action: none`; the leading
  explanation for the pinch failure is that Chrome combines `touch-action`
  across the iframe boundary. That is a hypothesis. Design and Godot practices
  are in `.knowledge/reference/touch-gestures.md`.

Verified: one real Android phone (Pixel 7 Pro), emulated phones and tablets,
the site check and build, and both Godot regression gates. **Not verified:**
the modeless touch change on any real device, and any iPhone. Closed out as a
public beta with documented limitations; 44 px touch targets, touch scaling
and touch-appropriate in-game help are deferred.

## 18. Spec 013 --- Progression Pack (2026-10-11 to 2026-10-14)

Merged as PR #9. Two stories, both from play. **World canvas:** any board point,
corners included, can be centered; departing arrows are no longer clipped at the
board edge and travel a fixed margin past it. **Progression:** eight levels
(9, 15, 14, 17, 23, 30, 68 and 93 arrows) lead to the Reference Knot, and New Game
now starts `first_knot`. The boards came from a seeded offline search in reverse
solve order and were confirmed by the solver; first-draft intent claims that
overstated the measured structure were rewritten. The owner played every level on
desktop and on the Pixel 7 Pro in Chrome. The same closeout recorded that modeless
touch (pinch and one-finger drag) worked on that phone. Playtest notes are aggregate.
The Beck retrospective, published 2026-10-14 under `/devspark/`, records where
this spec's process was loose.

## 19. Spec 014 --- Codebase Consolidation (2026-10-15)

Merged as PR #10. No behavior change was the requirement. All 30 catalog entries
were pinned first (`a25849f`); a probe of validity, witness orders, Open Move
trails and analyzer reports was byte-identical before and after (195,273 bytes);
a deliberate one-coordinate mutation made the gate fail. Head ordering and
direction steps gained single definitions, and unreachable template examples
were removed. Branch diff: 44 files, +95/-861. Level data files and a generator
were written down as separate future work. Quickfix 015 (PR #11) cleaned up
three leftovers.

## 20. Spec 016 --- Game UI Improvements (2026-10-16 to 2026-10-17)

Merged as PR #13. Every non-gameplay surface took on one Make Bold look and
scales with the screen; branded launch, hero Main Menu, Level Select cards,
restrained motion and sounds. Gameplay was held fixed, and regression
expectations did not change. Owner sign-off covered Chrome, Firefox and two
other Chromium-based browsers. Real-phone verification was removed from the spec
by owner decision and is an open intake item.

## 21. Spec 017 --- Mobile Portrait Play (2026-10-18)

Merged as PR #14. Portrait is admitted (at least 360 x 640). Status sits at the
top and Menu, Open Move and Fit form a bottom strip in portrait touch layouts; the
board has at least 75 percent of the usable area. Persistent Zoom In, Zoom Out and
Pan buttons were removed because gestures made them duplicates. Real-phone
acceptance was deferred post-deploy and closed on 2026-11-08, when the owner reported
playing on the Pixel in both orientations.

## 22. Spec 018 --- Level Pack Engine (2026-10-23, merged 2026-10-31)

Merged as PR #16. All 30 levels moved from catalog builder functions to committed
JSON packs with unchanged ids, order, versions and structure (snapshot-neutral
diff empty). A seeded `PuzzleGenerator` (reverse solve order, center-outward
layering, an initial-playable cap, profiles of analyzer ranges) and a one-command
pack build added a four-level Generated Levels sample. Same recipe and seed give
a byte-identical pack. This reverses the earlier stated order that generation
would wait for human evidence: the generator exists, as developer tooling, and
makes no claim about quality.

## 23. Current Moment

At this documentation snapshot (2026-11-08, `main` at `1a1ee67`, 214 commits):

- **Specs 001--014 and 016--018 and quickfix 015 are complete and merged.** There is
  no active feature branch.
- The catalog has **34 puzzles in four groups**.
- The game is playable in a browser on desktop and, as a beta, on touch screens
  in both orientations. CI on `1a1ee67` passed with every failure marker at zero.
- The fresh-player validation protocol is still not performed; the owner is the only
  tester so far.
- The article series lives on the site as twelve chapters
  (`web/src/content/chapters/`), all published. The copies in `arrowspark-series/` are superseded early
  drafts of parts 1--8.

The project has moved through six phases:

**Phase 1 --- Prove the game works.** Specs 001--005.

**Phase 2 --- Learn what the game actually is.** Spec 006 and the
playtesting/design discussion.

**Phase 3 --- Establish the contract and remove artificial constraints.**
Specs 007 and 008.

**Phase 4 --- Author content and find what a good knot is.** Specs 009 and 010.

**Phase 5 --- Put it in front of people.** Specs 011 and 012: the web
showcase and the mobile web beta.

**Phase 6 --- Turn one level into a game.** Specs 013--018: a progression, a
tidier codebase, a finished look, portrait play, and levels as data.

The eventual goal is still not simply "more levels." Levels are now cheap to
produce; knowing which ones are worth playing is not. The evidence base is still
one recorded tester, and that is the next thing to change.
