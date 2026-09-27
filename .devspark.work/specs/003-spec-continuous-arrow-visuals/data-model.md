# Presentation Data Model

Root: `C:/GitHub/MakeBoldSolutions/ArrowGame`. No persisted schema or domain-model change.

## Unchanged domain input

PuzzleDefinition supplies head, direction, and ordered `[head, tail...]` cells. PuzzleState remains authoritative for active owner lookup, legality, counters, removal, completion, score, and accuracy. Views never mutate definition/state. Solver and witness contracts are untouched.

## ArrowVisualGeometry (view-local data, not a new domain class)

- Ordered cell offsets: copied Array[Vector2i], head first; no adjacency traversal.
- Head offset and cardinal direction: existing set_shape inputs.
- Cell extent: positive pixel scalar; zero/negative extent yields no geometry until valid layout.
- Body points: tail-to-head centerline ending inside the head; two decorative points for an empty tail.
- Head vertices: tip and two base corners derived from forward/perpendicular and semantic proportions.
- Bounds: existing occupied-cell bounding rectangle; visual stroke/head must fit the normal owned-cell corridor.
- Rendering: one Line2D body plus one Polygon2D head; matching opaque effective color; antialiasing; round tail cap and joins.

Rebuild only when shape or extent changes; parent scale is not board sizing. Cell offsets remain ordered even when nonconsecutive cells happen to be neighbors. Decorative shaft introduces no ownership, geometry-validation, or solver input.

## ArrowVisualState

Fields are `_hovered: bool`, `_blocked_active: bool`, `_departing: bool`, effective Color, hover tween, effect tween, and the parent's scale/position. No legal/blocked cache or rule counter is stored here.

| Event | Transition and visible result |
|---|---|
| Setup | normal ink, scale ONE, no effects |
| Eligible hover enters/leaves | update eligibility; if not blocked/departing, interpolate toward ember/ink |
| Hover moves within same owner | no visual restart |
| Block request while active | kill hover/effect, reset scale, red immediately, pulse to 1.10 then ONE |
| Hover changes while blocked | remember eligibility; red retains precedence |
| Block completes | baseline scale, immediate ember if eligible else ink |
| Removal | terminal departing flag, kill both handles, clear transient flags, scale ONE and ink synchronously, position-only exit |
| Hover/block after departure | ignored |
| Exit completes | one exit_finished; disposal by board |
| Pause | existing effects pause with scene; hover eligibility cleared |
| Resume | re-evaluate eligible pointer; blocked feedback retains priority until it ends |

Repeated blocked pulses replace previous effects; no accumulated scale. No stale callback can override terminal departing state. New attempts use scene reconstruction, so no previous flags/tweens survive.

## Pointer routing data

PuzzleBoard stores last raw pointer cell/sentinel and currently highlighted head/null. Raw coordinates come from board-local pointer position, eligible only when board is visible, unpaused, focused-window, inside its bounds, and not covered by another GUI target. Sentinel `Vector2i(-1,-1)` clears eligibility and is not a new domain cell. Controller calls existing get_arrow_head and passes head/null back. Removed head is erased from view registry, making it unavailable for hover; no duplicate mutable occupancy map is added.

## GameVisualStyle

Presentation-only semantic constants: all eleven palette roles from the spec; spacing array 4/8/12/16/24/32/48; radii 6/10; border 1; shadow offset (0,4), size 12, color rgba(30,30,30,0.08); body/head ratios; hover duration 0.12; pulse amplitude 1.10. Existing PuzzleFeedback owns block 0.15/cap 0.3/exit 0.25 durations. No dependency from PuzzleFeedback or other domain scripts to GameVisualStyle.

Font roles: Be Vietnam Pro 800/700, Inter Tight 600/400 and numeric 600 with tnum when supported. New FontVariation .tres assets are static presentation resources, not player data. A Theme factory maps semantic values to local Control type variations, including focus styling. Theme is shared as immutable presentation configuration by convention; per-view colors are instance state and must not mutate shared theme resources.

## Durable knowledge ownership

Existing `arrow-puzzle` describes integration and lifecycle. New `game-visual-system` describes reusable visual language, font provenance/capability and intended roles. New node type is architecture, with appliesTo for actual source/resources/tests. Requirements and feature traceability stay only inside the temporary bundle; no durable feature/task/requirement nodes.
