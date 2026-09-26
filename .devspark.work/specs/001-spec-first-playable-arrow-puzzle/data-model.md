# Data Model

## Puzzle definition

Immutable definition: width=5, height=4; map from Vector2i cell to direction UP/DOWN/LEFT/RIGHT. Coordinates start at top left; right increases x, down increases y. Exactly one arrow per occupied cell. Validate positive dimensions, nonempty map, bounds, unique cells and cardinal directions before constructing a state. Reject malformed definitions without starting play; this is an authoring error, not a player failure state.

| ID (documentation only) | Cell | Direction | Initial blocker |
|---|---|---|---|
| A | (0,0) | LEFT | none |
| B | (2,0) | LEFT | A |
| C | (4,0) | DOWN | D |
| D | (4,3) | RIGHT | none |
| E | (0,3) | UP | A |
| F | (2,3) | LEFT | E |
| G | (2,1) | UP | B |
| H | (3,2) | RIGHT | none |

Valid witness sequence: A, B, D, C, E, F, G, H. At each step, the selected arrow is clear. IDs need not be runtime data; cell identifies arrows.

## Puzzle state

RefCounted instance owns a private copy of initial arrows and active arrows. Fields: total_arrows (constant per attempt), successful_removals=0, mistakes=0, total_taps=0, completed=false. remaining is active map size. No serialization, autoload, GlobalState access or persisted record.

select_arrow(cell): ignore absent cells and completed attempts; otherwise increment total_taps once. If blocked increment mistakes; else erase active cell and increment successful_removals. Set completed when remaining==0. Return ignored/blocked/removed outcome and read-only snapshot (copy). Blocked iff any active cell is strictly ahead on the same travel axis. Ignore blocker direction.

Invariants: total_arrows = remaining + successful_removals; total_taps = successful_removals + mistakes; completed iff remaining=0 for valid definitions; counters never decrease within an attempt. Score=max(total_arrows-mistakes,0). Accuracy=0.0 at zero taps, otherwise float(successful_removals)/total_taps. Round only the displayed percentage.

## Presentation lifecycle

Playing -> draining (state completed, departures pending) -> results -> fresh playing via Replay. Pause overlays suspend playing/draining; they do not change state. Controller owns generation token and pending tween count. Results snapshot is fixed for the completed attempt. Reset destroys pending visual work and creates a fresh state from the same definition. Leaving the scene discards session state only.
