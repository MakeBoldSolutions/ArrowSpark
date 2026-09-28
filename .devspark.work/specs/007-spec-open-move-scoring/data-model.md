# Phase 1 Data Model: Core Gameplay Contract, Open Move Assistance, and Session Scoring

**Spec**: [spec.md](spec.md) | **Research**: [research.md](research.md)

All entities below are in-memory only (`RefCounted` classes / GDScript
`Dictionary` values held in static vars), scoped to the current running game
session, per spec FR-015/FR-016. None is a Godot `Resource`, none is written
to `user://`, and none is reachable from `GlobalState`/`GameState`.

## Completed Attempt Result

One finished play-through of one puzzle. Produced by `PuzzleState.get_results()`
(extended), consumed by `puzzle_results.gd` and `PuzzleScoreboard`.

| Field | Type | Notes |
|---|---|---|
| `total_arrows` | int | Fixed for the attempt; unchanged by this feature. |
| `mistakes` | int | Count of blocked-arrow attempts this attempt. Unchanged by this feature. |
| `open_move_assists` | int | **New.** Count of valid "Show Me an Open Move" requests this attempt. |
| `score` | int | **Changed.** `max(total_arrows - (mistakes + open_move_assists * 5), 0)`. |
| `accuracy` | float | `successful_removals / total_taps`, or `0.0` at zero taps. Unchanged: `request_open_move()` never increments `total_taps`. |

Validation rules:

- `open_move_assists >= 0`; never decreases within an attempt.
- `score` is always `>= 0` (explicit floor) and `<= total_arrows`.
- A perfect attempt (`mistakes == 0 and open_move_assists == 0`) always yields
  `score == total_arrows` (spec FR-008).

State transitions: created fresh (all fields zero except `total_arrows`) on
attempt start; `mistakes`/`open_move_assists` only ever increase during an
attempt; the dictionary snapshot returned by `get_results()` is only
meaningful once `completed == true`. A replay/restart/next-puzzle fully
discards the old `PuzzleState` (existing scene-reload mechanism) and
constructs a fresh one — no explicit "reset" method is needed for these new
fields, matching how `mistakes`/`total_taps` already reset today.

## Session-Best Result

The best Completed Attempt Result recorded so far for one puzzle, during the
current session. Owned by `PuzzleScoreboard`.

| Field | Type | Notes |
|---|---|---|
| `puzzle_id` | String | Stable `PuzzleCatalog` id (the dictionary key, not a field inside the stored value). |
| *(all Completed Attempt Result fields)* | — | The exact dictionary shape above, stored verbatim for the best-scoring attempt at this puzzle so far this session. |

Validation rules:

- Exists only for a puzzle completed at least once this session (spec Edge
  Cases: an in-progress, not-completed attempt establishes nothing).
- Replaced only when a new completed attempt's `score` is strictly greater
  than the currently stored value's `score` (spec FR-012). Never replaced on
  an equal or lower score.

State transitions: absent → established (first completion) → replaced
(strictly higher score) → replaced (strictly higher score) → ... Never
transitions back to absent, and never mutates in place except by wholesale
replacement of the stored dictionary.

## Overall Session Score

A derived value, not separately stored: `PuzzleScoreboard.get_overall_score()`
sums `["score"]` across every currently stored Session-Best Result. A puzzle
with no Session-Best Result entry (never completed this session) contributes
`0` implicitly by being absent from the sum (spec FR-014).

## Open-Move-Assist Request

Not a stored entity — a transient event. Each valid `request_open_move()`
call on `PuzzleState`:

1. Increments `open_move_assists` by 1 (contributing `* 5` to the score
   penalty once the attempt completes).
2. Returns the same `Vector2i` head `find_open_move()` would return for the
   current state (or `null` only if no active arrow remains, which cannot
   occur for an unfinished attempt per the FR-017 invariant).
3. Never mutates `total_taps`, `successful_removals`, or `mistakes`.

## Relationships

```text
PuzzleCatalog (existing)
  └─ id ──────────────┐
                       │ (String key)
PuzzleState (existing, extended)
  └─ get_results() ──> Completed Attempt Result (dict)
                              │
                              │ record_attempt(puzzle_id, result)
                              ▼
                       PuzzleScoreboard (new)
                              │
                              ├─ get_best(puzzle_id) ──> Session-Best Result (dict) | null
                              └─ get_overall_score() ──> int
```

`PuzzleSession` (existing, unchanged) continues to own only "which puzzle id
is currently selected" and has no dependency on `PuzzleScoreboard` or vice
versa — the two static-var classes are independent, matching research.md § 5.
