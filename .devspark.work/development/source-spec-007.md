---
classification: full-spec
participants:
  critic: ai
  implementer: ai
  owner: human
  planner: ai
  reviewer: human
  scribe: ai
recommended_next_step: plan
required_artifacts: spec, plan, tasks
required_gates: checklist, analyze, critic
risk_level: medium
route_intent: full-spec
target_workflow: specify-full
---

# Feature Specification: Core Gameplay Contract, Open Move Assistance, and Session Scoring

**Feature Branch**: `007-spec-open-move-scoring` **Created**: 2026-09-27
**Status**: Draft **Input**: User description: "Spec 007 --- Core
Gameplay Contract, Open Move Assistance, and Session Scoring"

## Product Owner TLDR

Before ArrowSpark gets harder, wider distribution, or new features, its
fundamental player contract must be locked in: mistakes cost score,
never play; a stuck player can always ask to see one legal move; and the
game remembers how well the player did on each puzzle only for the
current play session, never after it ends. This spec adds the "Show Me
an Open Move" assist, extends attempt scoring to account for it, and
introduces a session-scoped best-score-per-level and
overall-session-score so replay has a clear purpose: beat your own best,
this session, with no risk of ever being blocked from finishing.

## Rationale Summary

### Core Problem

ArrowSpark's puzzles are provably always completable (monotonic removal
rules guarantee at least one legal move exists in every unfinished,
valid state), but the game currently has no first-class way for a stuck
player to see that a move exists, and no way to summarize an attempt's
efficiency beyond a bare mistake count. Before investing in harder
puzzles, wider distribution, or procedural generation, the basic
contract --- mistakes cost score not play, completion is never blocked,
and the game's gameplay memory boundary is the current session --- needs
to be explicit, implemented, and protected by tests.

### Decision Summary

Add a single, non-solving "Show Me an Open Move" assist that identifies
one legal arrow on request (never removes it, never reveals a sequence),
track its use as a count separate from mistakes, and extend the existing
attempt-scoring formula with an assist penalty five times a mistake's
penalty. Track each puzzle's best completed score and a summed overall
score, both in-memory for the current session only, with no new
persistence, profile, or identity introduced.

### Key Drivers

-   Product principle: "Hard is good. Unsolvable is not. Mistakes cost
    score, not play."
-   Product principle: the session is the only gameplay-memory boundary;
    no cross-session score history, profile, or identity may exist.
-   Upcoming harder puzzle design, web distribution, and feedback work
    all depend on this basic contract being correct and tested first.

### Tradeoffs Considered

-   **Option A --- Reuse the existing scoring formula unchanged, add an
    assist penalty at 5x a mistake**:
    `score = max(total_arrows - (mistakes + open_move_assists * 5), 0)`.
    Simple, keeps the existing zero-floor behavior players already
    encounter with a high plain-mistake count, and needs no new tunable
    constant.
-   **Option B --- Scale the score's baseline up before applying the
    same penalty** (e.g. `total_arrows * 10`): gives more headroom
    before a small puzzle hits zero after a couple of assists, but
    introduces a new constant and changes what the displayed score
    number means relative to arrow count.
-   **Selected: Option A.** Confirmed with the product owner: reaching
    zero on a heavily-assisted or heavily-mistaken attempt is an
    acceptable, already-precedented outcome --- it never blocks
    completion, it only shows a low score for that attempt. This keeps
    the scoring model exactly as simple as the product principles ask
    for.

### Architectural Impact

-   Extends the existing per-attempt result contract (total arrows,
    mistakes, score, accuracy) with an open-move-assist count, without
    changing what mistakes or accuracy mean.
-   Adds session-lifetime-only memory for a per-puzzle best result and a
    summed overall score; introduces no persistence, save-file schema
    change, player profile, or identity of any kind.
-   Reuses the game's existing legal-move rules to identify the assist
    arrow; does not introduce a second rules engine, solver, or any
    duplicated blocking logic outside that existing rule authority.
-   No change to puzzle content, removal rules, or catalog puzzle
    geometry.

### Reviewer Guidance

Focus review on: (1) the assist and mistake counts staying genuinely
separate end-to-end (never collapsed into one number before scoring),
(2) the session-best and overall-session-score update rules exactly
matching the "never let a worse replay lower anything" contract, (3)
confirmation that no new code path writes gameplay results to any
durable/save storage, and (4) that every catalog puzzle's existing
solvability and no-open-move-defect guarantees remain intact and tested.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Mistakes never block completion (Priority: P1)

A player attempts to remove an arrow that turns out to be blocked. The
arrow stays in place, the attempt continues immediately, and the player
can keep trying --- including making many more mistakes --- until the
puzzle is solved.

**Why this priority**: This is the foundational no-fail-state guarantee
the entire product philosophy depends on. If this is ever wrong, every
other feature in this spec is built on a broken floor.

**Independent Test**: Attempt to remove a blocked arrow repeatedly, then
finish the puzzle anyway. Delivers value on its own: proves mistakes are
purely a scoring concept, never a play-permission concept.

**Acceptance Scenarios**:

1.  **Given** an in-progress puzzle, **When** the player selects a
    currently blocked arrow, **Then** the arrow remains on the board,
    the mistake count increases by one, and the player may immediately
    continue selecting other arrows.
2.  **Given** an in-progress puzzle, **When** the player accumulates
    many mistakes (no upper bound), **Then** the player can still
    complete the puzzle with no forced restart, attempt limit, or life
    lost.

------------------------------------------------------------------------

### User Story 2 - Show Me an Open Move (Priority: P1)

A player who cannot spot a legal move requests assistance. Exactly one
currently legal arrow is visually identified. The player must still
select it themselves to remove it, and no further moves are revealed.

**Why this priority**: This is the feature that makes "there is always a
way out" concrete and actionable for a stuck player, without turning the
game into a solver or a hint system that plays for them.

**Independent Test**: From a puzzle state with no obvious next move,
trigger the assist and confirm one legal arrow is highlighted, still
requires a manual selection to be removed, and requesting it again
(without playing the shown arrow) behaves consistently.

**Acceptance Scenarios**:

1.  **Given** an in-progress, unfinished puzzle, **When** the player
    triggers "Show Me an Open Move," **Then** exactly one currently
    legal arrow is visually identified, no arrow is removed
    automatically, and only that one arrow's legality is revealed (no
    sequence, no "best move" claim).
2.  **Given** the same on-screen puzzle state, **When** the player
    triggers the assist again without playing the shown arrow or making
    any other move, **Then** the same arrow is identified again
    (deterministic result), and a new assist-count increment and penalty
    is recorded for this repeated request.
3.  **Given** an in-progress puzzle, **When** the player plays the
    identified arrow, **Then** normal removal/blocked handling applies
    exactly as if the player had found the move unaided.

------------------------------------------------------------------------

### User Story 3 - Understandable attempt results (Priority: P2)

After completing a puzzle, the player sees a results summary that
explains the attempt: total arrows, mistakes, open-move assists used,
the resulting score, and accuracy.

**Why this priority**: Turns raw counters into something the player can
read and act on, and is the foundation the session-best/overall-score
stories build on.

**Independent Test**: Complete a puzzle with a mix of mistakes and
assists, and confirm the results screen shows all five values
consistently with the counts recorded during play, including a
zero-mistake/zero-assist perfect run showing the maximum possible score
for that puzzle.

**Acceptance Scenarios**:

1.  **Given** a completed attempt with zero mistakes and zero open-move
    assists, **When** results are shown, **Then** the score equals the
    puzzle's total arrow count (the maximum possible score) and both
    counts display as zero.
2.  **Given** a completed attempt with some mistakes and at least one
    open-move assist, **When** results are shown, **Then** mistakes and
    open-move assists are displayed as two distinct counts (never
    combined into a single "mistakes" number) alongside total arrows,
    score, and accuracy.

------------------------------------------------------------------------

### User Story 4 - Replay to improve this session's best score (Priority: P2)

A player replays a puzzle they already completed this session, trying to
beat their own best score for that puzzle. The result of the new attempt
is compared against the session-best, the session-best updates only if
the new attempt is strictly better, and the overall session score
reflects the change.

**Why this priority**: This is the purpose of replay in this product:
improve a level's own best score, not recover from failure or chase a
leaderboard.

**Independent Test**: Complete a puzzle, note its session-best and the
overall session score, replay it worse (session-best and overall score
unchanged), replay it better (session-best and overall score both
increase by the improvement), and replay it to tie the best
(session-best unchanged).

**Acceptance Scenarios**:

1.  **Given** a puzzle completed for the first time this session,
    **When** the attempt finishes, **Then** its score becomes that
    puzzle's session-best and is added to the overall session score.
2.  **Given** a puzzle with an existing session-best, **When** a replay
    finishes with a strictly higher score, **Then** the session-best is
    replaced by the new score and the overall session score increases by
    exactly the improvement.
3.  **Given** a puzzle with an existing session-best, **When** a replay
    finishes with an equal or lower score, **Then** the session-best and
    the overall session score remain unchanged.
4.  **Given** any number of completed and replayed puzzles, **When** the
    game session ends and a new session begins, **Then** every
    session-best and the overall session score start over at "no levels
    completed" / zero, with nothing carried over from the prior session.

------------------------------------------------------------------------

### Edge Cases

-   Requesting "Show Me an Open Move" repeatedly before playing the
    shown arrow: each request is a separate valid request and records
    its own assist-count increment and penalty, even though the
    identified arrow may be the same each time.
-   A puzzle state where only one legal arrow exists (a forced state):
    the assist identifies that same arrow; this is still a normal, valid
    request.
-   A player attempts a blocked arrow after already requesting an assist
    in the same attempt: mistake and assist counts remain independent of
    each other.
-   Navigating away from an in-progress (not completed) attempt: it
    establishes no session-best result for that puzzle; only a completed
    attempt counts.
-   A puzzle never completed during the current session contributes
    nothing to the overall session score.
-   Every catalog puzzle, after this change, remains solver-confirmed
    solvable and structurally valid, and every one of its reachable,
    unfinished states still has at least one legal arrow --- this is
    treated as a content defect to prevent, never as a player-facing
    failure state.
-   Ending or reloading the game session leaves no remembered per-puzzle
    score or overall session score behind; existing saved level progress
    and settings (a separate, pre-existing system) are unaffected by any
    of this feature's behavior.

## Requirements *(mandatory)*

Keyboard/gamepad navigation for the new "Show Me an Open Move" control,
and full compatibility with existing saved level progress and settings,
are treated as mandatory acceptance concerns below, per project
constitution. This feature makes no breaking data change and requires no
migration or reset plan: all new gameplay counts and session state
described here are session-lifetime-only and never touch existing
save/settings storage.

### Functional Requirements

-   **FR-001**: System MUST allow the player to attempt to remove any
    arrow, including a currently blocked one, without removing it,
    ending the attempt, or limiting how many further attempts the player
    may make.
-   **FR-002**: System MUST increment a per-attempt mistake count each
    time the player attempts to remove a currently blocked arrow, and
    MUST never impose a maximum mistake count, attempt limit, or forced
    restart as a consequence.
-   **FR-003**: System MUST provide a player-triggered "Show Me an Open
    Move" action that visually identifies exactly one currently legal
    arrow, without removing it, without revealing any further move, and
    without claiming it is the "best" or "optimal" move.
-   **FR-004**: System MUST identify the open-move arrow using the same
    legal-move rules that govern normal play; it MUST NOT be determined
    by any separate or duplicated rules logic.
-   **FR-005**: System MUST identify the same arrow for the same
    on-screen puzzle state across repeated requests (deterministic
    result) when no move has been played in between.
-   **FR-006**: System MUST record each triggered "Show Me an Open Move"
    request as a count separate from the mistake count, and MUST apply
    its scoring penalty exactly once per valid request --- including a
    repeated request for the same arrow before it is played.
-   **FR-007**: System MUST require the player to select the identified
    arrow themselves; triggering "Show Me an Open Move" MUST NOT remove
    an arrow automatically.
-   **FR-008**: System MUST compute a completed attempt's score as the
    puzzle's total arrow count minus the sum of its mistake count and
    five times its open-move-assist count, floored at zero (\`score =
    max(total_arrows - (mistakes + open_move_assists
    -   5), 0)\`), so a perfect attempt (zero mistakes, zero assists)
        always scores the puzzle's full total-arrow count.
-   **FR-009**: System MUST present, for every completed attempt, its
    total arrow count, mistake count, open-move-assist count, resulting
    score, and accuracy (where accuracy remains part of the existing
    results contract) as five distinct, consistent values.
-   **FR-010**: System MUST allow the player to replay any puzzle an
    unlimited number of times; each replay MUST begin a completely fresh
    attempt with its mistake count, open-move-assist count, and attempt
    score reset to zero.
-   **FR-011**: System MUST remember, only for the duration of the
    current running game session, the best completed-attempt score
    achieved so far for each puzzle the player has completed at least
    once this session.
-   **FR-012**: System MUST replace a puzzle's session-best result when
    a newly completed attempt's score is strictly greater than it, and
    MUST leave the session-best result unchanged when a newly completed
    attempt's score is equal to or lower than it.
-   **FR-013**: System MUST present, after each completed attempt,
    enough information for the player to tell whether that attempt
    established, improved, tied, or failed to improve that puzzle's
    session-best score.
-   **FR-014**: System MUST expose an overall session score equal to the
    sum of the current session-best scores across every puzzle completed
    at least once during the session; a puzzle never completed during
    the session MUST contribute nothing to this total.
-   **FR-015**: System MUST NOT persist any per-puzzle score, the
    overall session score, or any other gameplay-performance history
    beyond the current running game session --- not to disk, not through
    existing save/settings storage, and not through any new durable
    player identity, profile, or account.
-   **FR-016**: System MUST start every new game session (a fresh
    application start, or a session reload/restart) with no remembered
    per-puzzle scores and an overall session score of zero, regardless
    of any prior session's results.
-   **FR-017**: System MUST keep every catalog puzzle solver-confirmed
    solvable and structurally valid, and MUST guarantee that every
    reachable, unfinished state of a playable puzzle has at least one
    legal arrow available; an unfinished state with none is a content
    defect to be prevented, never a player-facing failure.
-   **FR-018**: System MUST make "Show Me an Open Move" reachable and
    usable via keyboard and gamepad navigation, consistent with existing
    input accessibility.
-   **FR-019**: System MUST NOT introduce lives, fail states, forced
    restarts, timers, waiting periods, or any monetization-gated
    continuation as a consequence of mistakes or open-move-assist use.

### Key Entities *(include if feature involves data)*

-   **Completed Attempt Result**: One finished play-through of one
    puzzle during the current session. Represents total arrows,
    mistakes, open-move assists, score, and accuracy for that single
    attempt, and which puzzle it belongs to.
-   **Session-Best Result**: The best Completed Attempt Result recorded
    so far for one puzzle during the current session. Replaced only when
    a later completed attempt at the same puzzle scores strictly higher.
-   **Overall Session Score**: A derived total summing every puzzle's
    current Session-Best Result score. Exists only in memory for the
    current session; a puzzle never completed contributes nothing.
-   **Open-Move-Assist Request**: A player-triggered event during an
    in-progress attempt that identifies one legal arrow and applies a
    fixed scoring penalty. Counted separately from mistakes.

## Success Criteria *(mandatory)*

### Measurable Outcomes

-   **SC-001**: 100% of catalog puzzles remain solver-confirmed
    solvable, structurally valid, and free of any reachable unfinished
    state with zero legal moves, verified by automated checks.
-   **SC-002**: A player can complete any catalog puzzle after any
    number of blocked (mistake) attempts, with zero forced restarts and
    zero attempt limits encountered, verified across repeated-mistake
    test runs.
-   **SC-003**: Every completed attempt's results display shows total
    arrows, mistakes, open-move assists, score, and accuracy as five
    values consistent with what was recorded during play, with zero
    observed discrepancies across test runs.
-   **SC-004**: A worse replay of any previously completed puzzle never
    lowers that puzzle's session-best score or the overall session
    score, verified across repeated replay sequences (better, equal, and
    worse) for every catalog puzzle.
-   **SC-005**: A player who requests "Show Me an Open Move" on any
    reachable, unfinished state of any catalog puzzle receives exactly
    one visually identified legal arrow, with the same arrow identified
    again on an immediate repeated request against the same state, in
    100% of tested states.
-   **SC-006**: Starting a new game session always begins with zero
    completed puzzles remembered and an overall session score of zero,
    with zero carryover from any prior session, verified across repeated
    fresh-session checks.

## Assumptions

-   Scoring formula (confirmed with product owner during specification):
    the existing `score = max(total_arrows - mistakes, 0)` style formula
    is extended in place ---
    `score = max(total_arrows - (mistakes + open_move_assists * 5), 0)`
    --- rather than introducing a scaled baseline. Reaching zero after
    heavy mistake/assist use is an accepted, already-precedented outcome
    and never blocks completion.
-   "Session" is scoped to one running application/browser process from
    start to reload/restart, per existing product-boundary language;
    this spec does not define or change what triggers a session boundary
    beyond that.
-   The smallest useful session-best data model (score only vs. full
    result fields) is an implementation decision left to planning, not
    fixed by this spec, since it does not change any player-observable
    behavior described here.
-   The exact deterministic validation strategy used to prove every
    reachable unfinished state has a legal move (FR-017 / SC-001) is an
    implementation/testing strategy decision left to planning; this spec
    only fixes the required outcome.
-   No new arrow/blocking mechanics, puzzle content, procedural
    generation, telemetry, web distribution, accounts, or persistence
    are introduced; existing save/settings behavior is unaffected
    because none of this feature's state is ever written to it.

## Out of Scope

-   Cross-session score persistence, player profiles, persistent
    anonymous player identity, accounts, authentication, or cloud
    synchronization.
-   Leaderboards, rankings, achievements, stars/medals, or currencies.
-   Lives, fail states, forced restarts, timers, waiting mechanics,
    monetization, advertisements, watch-to-continue, or pay-to-continue.
-   Difficulty ratings or adaptive difficulty.
-   New arrow/blocking mechanics or changes to existing puzzle removal
    rules.
-   Advanced geometric-entanglement puzzle design, procedural puzzle
    generation, or large progression/level-locking systems.
-   Gameplay telemetry, feedback APIs, web deployment/distribution work,
    or analytics.
