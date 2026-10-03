# ArrowSpark Architecture

## Architectural Goal

ArrowSpark deliberately separates: - authored puzzle content; - gameplay
rules; - solving/analysis; - presentation; - session scoring; -
transient navigation.

This separation has allowed the project to change its visual identity
and product direction without repeatedly rewriting the rules engine.

## Authority Map

### PuzzleCatalog

**Responsibility:** chooses available authored puzzles.

The catalog owns stable puzzle identity and ordering. It allows a single
reusable gameplay scene to load different puzzle definitions.

It should not own gameplay state, scoring, solving, or camera behavior.

### PuzzleDefinition

**Responsibility:** describes the complete logical puzzle.

A definition contains: - board width/height; - arrow head cells; -
directions; - optional ordered tails.

It is the geometry/content authority.

Validation checks structural correctness: - cells within bounds; -
ownership uniqueness; - tail continuity; - valid relationship between
head direction and first tail; - nonbranching ordered geometry.

PuzzleDefinition should remain independent of: - viewport; - screen
resolution; - score; - player session; - animation.

### PuzzleState

**Responsibility:** active gameplay rules and per-attempt state.

PuzzleState owns: - active arrow ownership; - blocker checks; - legal
removal; - atomic removal; - mistakes; - completion; - current-attempt
results; - Spec 007 Open Move discovery/request behavior; -
`open_move_assists`.

The central interaction is selection of an arrow/cell and classification
as ignored, blocked, or removed.

Spec 007 extends PuzzleState with: - `find_open_move()`; -
`request_open_move()`; - `open_move_assists`.

The Open Move feature must reuse the same legal-move authority as
ordinary play. It must not create a second rules engine.

### PuzzleSolver

**Responsibility:** solvability and witness generation.

The solver operates on puzzle definitions/state independently of
presentation.

It can classify: - invalid; - unsolvable; - solvable.

It returns deterministic witnesses.

Because removal is monotonic, the solver does not need a conventional
adversarial/backtracking search under the current rules.

### PuzzleAnalyzer

**Responsibility:** objective structural characterization.

Added in Spec 006.

It measures puzzle properties useful for design research, such as
dependency relationships, forced/branching states, density, and related
structure.

It is intentionally separate from gameplay assistance.

The analyzer tells us facts about a puzzle. It does not tell us whether
a human will find that puzzle fun.

Spec 006 demonstrated the importance of that distinction.

### PuzzleBoard

**Responsibility:** grid/layout/input presentation.

PuzzleBoard translates logical puzzle geometry into visual cells and
manages the collection of ArrowViews.

The Spec 008 work (complete since 2026-09-28; `PuzzleViewportTransform` is the coordinate authority, see `.knowledge/architecture/`) was to preserve PuzzleBoard's logical
rendering role while introducing a clear viewport/camera transform
around or within the presentation layer.

### ArrowView

**Responsibility:** render and animate one arrow.

ArrowView renders: - continuous body; - triangular head; - hover
state; - blocked feedback; - Open Move highlight; - path-following
departure.

An arrow's visual geometry derives from ordered logical cells.

### Controller / arrow_puzzle.gd

**Responsibility:** coordinate gameplay lifecycle.

The controller connects: - PuzzleDefinition; - PuzzleState; -
PuzzleBoard; - HUD; - results; - pending departures; - session scoring.

Logical removal occurs immediately. Presentation departure can remain in
flight. Completion/results wait for the pending-departure barrier.

### PuzzleScoreboard

**Responsibility:** session-best results only.

Added in Spec 007.

It stores, in memory: - best completed result/score per puzzle; -
overall session score.

Rules: - first completion establishes best; - strictly better score
replaces best; - equal/worse does not lower best; - overall score
derives from stored per-puzzle bests.

PuzzleScoreboard must not: - write saved progress; - create identity; -
survive the running session; - become a general player profile.

## Coordinate Model for Spec 008

The next architectural requirement is explicit coordinate separation.

At minimum:

### Logical puzzle/grid coordinates

Integer cells used by: - PuzzleDefinition; - PuzzleState; - Solver; -
Analyzer.

These must never depend on zoom or pan.

### Board-local visual coordinates

Pixel positions derived from cell size and puzzle geometry.

ArrowView uses this space to render lines, heads, and animations.

### Viewport/screen coordinates

The portion of the board currently visible after camera/viewport
transforms.

Input from the user originates here and must be transformed correctly
into board-local/logical selection.

Spec 008 should establish one clear authority for these transformations
rather than scattering inverse-transform math across UI scripts.

## Immediate Logical Removal vs. Presentation Departure

This is one of the project's strongest architectural decisions.

When a legal arrow is selected: 1. PuzzleState removes it logically. 2.
Other legal-move calculations immediately see the new state. 3.
ArrowView begins its visual departure. 4. The controller tracks the
pending departure. 5. Results wait until all departures finish.

This lets the game remain logically simple while providing expressive
animation.

It also matters for Open Move: an Open Move request during an in-flight
departure should use the current logical state, not stale visual
occupancy.

## Path-Following Departure

For a bent arrow, departure is modeled along an immutable polyline.

The visible arrow is effectively a moving interval of fixed original
path length.

As distance increases: - the head moves through the original head point
and outward along its direction; - the tail advances through the
original bends; - intermediate vertices remain until the tail passes
them.

This prevents a bent arrow from cutting diagonally across corners.

For the future Gordian-knot direction, this animation is a core
experiential feature: long arrows appear to pull themselves out of the
knot.

## Session State vs. Persistence

ArrowSpark currently contains inherited save/progression infrastructure
from its template.

Spec 007 explicitly prevents session scoring from using it.

This distinction must remain clear:

**Existing save/settings infrastructure:** pre-existing
application/template concerns.

**ArrowSpark gameplay performance:** session-only.

The presence of a persistence mechanism is not permission to persist new
gameplay state.

## Viewport Architecture Constraints (Spec 008, complete; written as pre-implementation constraints)

Spec 008 should research whether the best implementation is: - a
camera-like wrapper; - a transformed board container; - direct
PuzzleBoard viewport state; - another Godot-native approach.

Regardless of implementation, the boundaries should be:

**Puzzle rules know nothing about camera state.**

**Solver/analyzer know nothing about camera state.**

**Session score knows nothing about camera state.**

**Viewport state is presentation/navigation state.**

## Performance Philosophy

Do not optimize for hypothetical enormous generated puzzles yet.

The project should support reasonably large authored boards smoothly.

Avoid obvious waste such as rebuilding the complete logical puzzle
unnecessarily on every pan event, but do not introduce: - chunking; -
virtualization; - spatial indexes; - LOD systems; - elaborate caching

without measurement.

The current development philosophy remains:

**measure before adding infrastructure.**
