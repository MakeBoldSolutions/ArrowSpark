# Phase 0 Research: Core Gameplay Contract, Open Move Assistance, and Session Scoring

**Spec**: [spec.md](spec.md) | **Branch**: `007-spec-open-move-scoring`

This feature has no external unknowns (no new library, framework, or platform
choice) — it extends an existing GDScript/Godot 4.4 project already fully
described by `.knowledge/architecture/arrow-puzzle.md`. Research here resolves
the placement/strategy questions the spec explicitly deferred to planning,
each stated as Decision / Rationale / Alternatives Considered.

## 1. Where does Open Move selection live?

**Decision**: Add `PuzzleState.find_open_move() -> Variant` (a `Vector2i` head,
or `null` only if no active arrow remains). It iterates the same active-arrow
set `select_arrow()`/`is_blocked()` already use, in the same deterministic
(y, x)-ascending order `PuzzleSolver.analyze()` already walks, returning the
first head for which `_is_head_blocked(head)` is false.

**Rationale**: `PuzzleState` already owns `_is_head_blocked` — the single
blocking check every other gameplay path uses. Adding one read-only method
here reuses that check directly; it introduces zero new blocking logic and
zero new rules engine, satisfying the architectural constraint against a
second solver. Reusing the solver's own tie-break ordering keeps the choice
deterministic without inventing a new comparator.

**Alternatives considered**: A separate `PuzzleAssist`/helper class wrapping
`PuzzleState` — rejected: it would either duplicate `_is_head_blocked` or take
a dependency that adds a layer with no behavior of its own. Delegating to
`PuzzleSolver` — rejected: `PuzzleSolver` operates on a fresh `PuzzleDefinition`
and builds its own internal `PuzzleState`; it has no notion of an in-progress
live attempt's current active-arrow set, so it cannot answer "what's legal
*right now*, in *this* attempt" without either exposing that live state to it
(inverting the dependency direction) or reconstructing it — both worse than a
one-method addition to the class that already holds the live state.

## 2. Where does the open-move-assist request count live?

**Decision**: Add `open_move_assists: int = 0` alongside `mistakes` on
`PuzzleState`, and a `request_open_move() -> Variant` method that increments
it by exactly one per call (skipped only when `completed` is already true,
mirroring `select_arrow()`'s own completed-guard) and returns
`find_open_move()`'s result.

**Rationale**: Per-attempt counters already live on `PuzzleState`
(`mistakes`, `total_taps`, `successful_removals`); the assist count is the
same kind of per-attempt fact and belongs beside them so a fresh attempt
(Replay/Restart/Next Puzzle's existing full scene reload) resets it for free,
with no new reset code path.

**Alternatives considered**: Tracking the count in the scene controller
(`arrow_puzzle.gd`) instead — rejected: that would split per-attempt state
across two owners for no reason, and would require the controller (not the
rules authority) to decide what counts as "still the same request" for
FR-005's determinism guarantee.

## 3. Scoring formula placement and shape

**Decision**: Extend `PuzzleState.get_results()` to add `open_move_assists` to
its returned dictionary and compute
`score = max(total_arrows - (mistakes + open_move_assists * 5), 0)`, replacing
the current `max(total_arrows - mistakes, 0)`. `accuracy` is unchanged
(`successful_removals / total_taps`); `request_open_move()` never increments
`total_taps`, so it can never affect accuracy (spec FR-020/FR-021).

**Rationale**: This is the exact formula the product owner confirmed during
`/devspark.specify` (spec.md § Tradeoffs Considered, Option A). `get_results()`
is already the single place score/accuracy are computed from counters this
class owns; adding one term here keeps the computation in one place with no
new class.

**Alternatives considered**: Already exhausted at the spec stage (Option B,
scaling `total_arrows` by a constant) — explicitly rejected there; not
reopened here per the reviewer's own guidance not to re-litigate a decided
product call absent new evidence.

## 4. Reachable-state "always has a legal move" invariant (FR-017 / SC-001)

**Decision**: Do **not** add exhaustive reachable-state enumeration as a new
test category. Rely on, and make explicit in test naming/comments where
useful: (a) `PuzzleSolver.analyze(definition).solvable == true` for every
catalog entry — already required and tested — as proof a complete legal
clearance order exists; and (b) the existing monotonicity/exchange-property
proof in `.knowledge/architecture/arrow-puzzle.md` ("Why no backtracking is
needed"), which shows any state reachable by legal play from a solvable state
is itself solvable, and a solvable nonempty state has ≥1 legal move by
definition. Together these already establish the invariant for every catalog
puzzle with no new state-space walk. The one gap worth closing: the existing
order-independence regression (`tests/puzzle_regression.gd`, forcing either of
two simultaneously-legal arrows first) currently exercises one hand-built
two-arrow branching case. Extend the *same* technique — at every branching
state visited along a witness walk, force each alternative legal choice next
and confirm the resulting state is still solvable — across every catalog
puzzle's witness, as an extension of the existing catalog regression rather
than a new exhaustive traversal.

**Rationale**: The reviewer's second-pass feedback on the spec was explicit
that exhaustive enumeration would be "mathematically... stronger and simpler"
to replace with the monotonicity argument already documented. This keeps
verification cost bounded (linear in witness length per puzzle, same order as
existing checks) instead of exponential in arrow count, while still directly
testing the one part of the proof that depends on the *actual* rule
implementation (blocking correctness) rather than just the math.

**Alternatives considered**: Full reachable-state-space enumeration (BFS/DFS
over every legal removal order) — rejected as the spec's second-pass review
itself flagged: expensive, and it would encode an implementation/testing
*strategy* as if it were a product requirement. A brand-new standalone
"invariant checker" class — rejected: it would either re-implement
`is_blocked` (a second rules engine, explicitly disallowed) or take a
`PuzzleState`/`PuzzleDefinition` dependency and become indistinguishable from
an extension of the existing regression/catalog-check tests.

## 5. Session-best and overall-session-score storage

**Decision**: A new session-lifetime static-var `RefCounted` class,
`PuzzleScoreboard`, sitting beside `PuzzleSession` (same precedent: a
GDScript static var bound to the running process, reset only by a fresh
engine process, never touching `GlobalState`/`GameState`/`user://`). It holds
one `Dictionary` (`puzzle_id -> Completed Attempt Result dictionary`, i.e. the
exact dictionary shape `PuzzleState.get_results()` already returns) and
exposes: `record_attempt(puzzle_id: String, result: Dictionary) -> String`
(returns one of `"established" | "improved" | "tied" | "not_improved"`,
applying FR-012's replace-only-if-strictly-greater rule, and updating the
stored dictionary only on `"established"`/`"improved"`), `get_best(puzzle_id)
-> Variant` (the stored dictionary or `null`), and `get_overall_score() -> int`
(sum of `["score"]` across all stored entries).

**Rationale (resolves the spec's deferred "score only vs. full result"
assumption)**: Store the full per-puzzle result dictionary, not score alone.
The comparison outcome only needs the prior score, but the dictionary is five
small fields (`total_arrows`, `mistakes`, `open_move_assists`, `score`,
`accuracy`) per puzzle, bounded by the 14-entry catalog — effectively free —
and it means Results can later show the session-best's own breakdown (e.g.
"Best: 7 with 1 assist") without another data-model change, while nothing in
this spec is blocked on that. `PuzzleSession` itself is deliberately left
unchanged: it owns *which puzzle is selected*, a different concern from *how
well each puzzle has been played*, and mixing them would make `PuzzleSession`
responsible for two unrelated lifecycles.

**Alternatives considered**: Extending `PuzzleSession` itself with score
fields — rejected: conflates selection state with performance-history state,
and `PuzzleSession`'s existing single responsibility (documented in
arrow-puzzle.md) would need re-describing for no behavioral gain. Storing
score-only — rejected per the rationale above (the full dictionary costs
nothing extra and keeps a future "show the best breakdown" enhancement from
requiring a data-model change). Routing through `GlobalState`/save
infrastructure — explicitly excluded by the spec (FR-015) and the
architectural constraints.

## 6. Where the "established / improved / tied / not improved" comparison and
   overall score are computed and displayed

**Decision**: `arrow_puzzle.gd` (the existing scene controller, which already
owns the `playing -> draining -> results` lifecycle) calls
`PuzzleScoreboard.record_attempt(...)` exactly once, in `_show_results()`,
after `_state.get_results()` — the same place it already calls
`_results.show_results(...)`. It passes the comparison outcome, the puzzle's
`get_overall_score()`, and the existing results dictionary into an extended
`puzzle_results.gd` `show_results(...)` call. `puzzle_results.gd` gains two
new labels (open-move-assist count, and one short comparison/overall-score
line) alongside the four existing metric labels — no new panel, no
progression dashboard, per the spec's explicit UI constraint.

**Rationale**: Matches the existing division of responsibility exactly:
`PuzzleState` computes attempt facts, the controller sequences when results
are shown, `puzzle_results.gd` is a pure display component. No new node/scene
lifecycle is introduced.

**Alternatives considered**: Having `puzzle_results.gd` call
`PuzzleScoreboard` directly — rejected: it currently has no dependency beyond
`PuzzleCatalog`/`PuzzleResultsFormat` for read-only display formatting;
keeping the mutation (`record_attempt`, which changes stored state) in the
controller preserves "the display component never mutates game state."

## 7. Open Move control: where it lives and how it stays keyboard/gamepad
   accessible

**Decision**: A focusable `Button` (e.g. `%OpenMoveButton`) added to the
existing HUD row (`HUDMargin`) beside `RemainingLabel`/`MistakesLabel`,
wired to a new handler that calls `_state.request_open_move()` and, on a
non-null result, passes the returned head to a new `PuzzleBoard` method
(e.g. `suggest_open_move(head)`) that raises a persistent visual indicator on
that arrow's `ArrowView` until superseded by a departure/blocked/new-hover
event or a fresh attempt. Because it is an ordinary `Control` `Button` in the
existing focus chain (not a raw input-map action), it inherits the addon's
existing keyboard/gamepad focus navigation with no new remap-system entry
required — consistent with constitution Principle III without adding new
input-map surface area to reason about.

**Rationale**: Reuses the accessible-control pattern every other in-scene
button (`ReplayButton`, `MainMenuButton`, etc.) already uses, rather than
introducing a bespoke input action. `PuzzleBoard` already owns view
presentation and precedence ordering (`departing > blocked > hover > normal`,
per arrow-puzzle.md); a suggestion indicator naturally slots in as one more
precedence tier (`departing > blocked > suggested > hover > normal`) rather
than a parallel presentation path, and reuses the existing `arrow_hover`
ember accent token (no new palette entry) per the "recede, don't add
branding/decoration" presentation principle in
`.knowledge/product/branding.md`.

**Alternatives considered**: A keyboard-only shortcut with no visible button
— rejected: constitution Principle III requires *usable* menus/controls, and
an invisible-only shortcut is discoverable to neither a mouse-only nor a
screen-reading player. A brand-new indicator color — rejected: the existing
palette documents "no per-arrow color scheme" and reusing the ember accent
already used for hover keeps the palette closed per its own stated intent.

## Summary of resolved unknowns

No `NEEDS CLARIFICATION` markers remain in Technical Context (see plan.md);
every placement/strategy question the spec explicitly deferred is resolved
above.
