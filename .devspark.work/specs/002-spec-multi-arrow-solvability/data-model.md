# Data Model

## PuzzleDefinition
Positive integer width/height; copied arrows dictionary maps head Vector2i to cardinal direction. Optional copied tails dictionary maps head to ordered Array[Vector2i]; omitted tails are empty. A shape is [head] + tail. Validate typed cells, board bounds, distinct cells, unit orthogonal adjacency, existing tail-owner head, and exclusive ownership across shapes. Repeated-cell reversals are invalid; multiple right-angle turns are supported. The first tail cell, when present, MUST equal head minus its direction vector (immediately behind the head, opposite its direction of travel); a tail whose first cell is anywhere else is invalid. No tail cell of an arrow MAY lie on that same arrow's own forward escape ray (the cells strictly between its head and the board edge along its direction); such geometry is an invalid definition, never a runtime exception. Different arrows' cells may be orthogonally adjacent without restriction — only overlap is invalid.

get_arrow_cells(head) and get_cell_owners() return independent copies. Preserve the three-argument constructor and duplicate_arrows() direction-map semantics. Input and snapshot mutation cannot affect active attempts.

## PuzzleState
Own active head-direction, shape and cell-owner dictionaries. get_arrow_head(cell) returns owning head or null. is_blocked(cell) resolves head, then scans strictly ahead in its direction; other active owners block, own cells do not. Empty/inactive cells return false.

| Input | Outcome | Mutation |
|---|---|---|
| Completed or unowned | IGNORED | None |
| Active blocked shape | BLOCKED | taps +1, mistakes +1 |
| Active clear shape | REMOVED | taps +1, removals +1, delete head and all owned cells atomically |
| Last removal | REMOVED, completed | Same mutation, set completion |

Keep total_arrows = remaining + successful_removals and total_taps = successful_removals + mistakes. Score is max(total_arrows - mistakes, 0); accuracy is removals/taps or zero for zero taps. Count arrows, not cells. Preserve snapshot fields; add copied cell_owners and active tails as needed.

## SolvabilityAnalysisResult
Dictionary fields: valid: bool, solvable: bool, witness: Array[Vector2i], validation_errors: Array[String], metrics: Dictionary.

- Valid solvable: complete unique legal head sequence; empty errors.
- Valid unsolvable: valid=true, solvable=false, empty witness and errors. Never expose partial traversal as witness.
- Invalid: valid=false, solvable=false, empty witness, nonempty diagnostics. Validate before constructing state; distinguish invalid from valid-unsolvable.
- Additive metric keys preserve existing field meanings/types. No difficulty fields.

Metrics are nonnegative integers: states_examined; active_choices_encountered (sum of remaining arrows); legal_choices_encountered (sum of legal heads); forced_states (one legal); branching_states (more than one); no_move_states (nonempty with zero). Count each nonempty visited state before selecting; exclude empty terminal. states_examined = forced_states + branching_states + no_move_states. Invalid input yields zero metrics.

## Authored 5x4 board candidate

| Arrow | Head (x,y) | Direction | Ordered tail |
|---|---|---|---|
| A | (0,0) | LEFT | [(1,0),(1,1),(0,1)] |
| B | (2,0) | LEFT | [(3,0)] |
| C | (4,0) | DOWN | [] |
| D | (4,3) | RIGHT | [(3,3)] |
| E | (0,3) | UP | [] |
| F | (2,3) | LEFT | [] |
| G | (2,1) | UP | [] |
| H | (3,2) | RIGHT | [] |

A has multiple turns; B/D have straight tails. A tail blocks B/E, D blocks C, B blocks G, E blocks F. All four directions appear. A,B,D,C,E,F,G,H is a reasoned witness candidate, still requiring implemented solver verification and fresh-state replay. Add a separate tail-only blocker fixture with blocker head off the tested ray: authored A also head-blocks B/E.

## Presentation lifecycle
Resolve selected owner before mutation. One head-keyed view persists only as an ignored-input exit animation after logical removal. Each accepted removal adds one pending departure and each view completes once. Show results only at logical completion and zero pending departures. Replay/Restart reload the scene, clear old callbacks, and reconstruct identical shapes and zero counters. Main Menu preserves saved state.
