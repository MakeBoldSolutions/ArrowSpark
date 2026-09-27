# Presentation Data Model

No persistent or puzzle-domain data changes.

## ArrowDepartureGeometry (RefCounted)

Immutable-after-construction defensive copies: ordered local cell-unit route points, cumulative lengths, original head center, cardinal forward vector, and tail-to-head length L. No Node, PuzzleState, solver, input, score, or persistence reference. It receives presentation points and direction rather than deriving gameplay ownership. Consecutive duplicates are removed; at least two distinct points and positive length are required. Valid single-cell rendering supplies the synthetic 0.30-cell route. Invalid construction is reported explicitly and never silently emits successful departure.

Operations: sample_distance(s), extract_interval(start,end), and clearance_distance(grid_size, head_cell, rear_support, margin). Pure function arguments/results are copies or read-only by convention; mutation of source cell arrays cannot change a route.

## ArrowView transient state

Existing shape offsets and direction remain. Add geometry, departure_distance, finish_distance, layout_valid, and completion_emitted. State transitions: normal/hover/blocked -> departing -> finished -> disposed. Departing is terminal for effects and input. Cancellation -> disposed without completion. Pause and invalid extent suspend advancing without leaving departing. Layout rebuild never resets distance. Completion only from a processable progress update after full clearance.

## PuzzleBoard collections

_views: canonical head -> active view (existing).
_departing_views: canonical head -> departing view; same definition/bbox lookup available for layout, never ownership routing.
DepartureClip: passive Control, positioned at occupied-grid origin, sized to occupied-grid pixel dimensions. Active views remain siblings outside this clip. setup and destruction dispose both collections and disconnect old completion connections.

## Controller state (unchanged contract)

_pending_departures counts starts minus completed live departures; _awaiting_completion reflects logical completion. Results require awaiting plus zero pending. Reset/scene replacement creates a new attempt with no callbacks from old views. Board instances/connection guards prevent stale completion from decrementing fresh counters.
