# Research

## Representation
**Decision**: Keep arrows as head-coordinate -> direction and add an optional copied head -> ordered tail array constructor argument. Missing tails are empty. Use head coordinates for witnesses and view keys.
**Rationale**: Existing single-cell constructors and direction-map consumers remain compatible. Copy shape arrays at boundaries; explicitly migrate consumers that need occupancy.
**Alternatives considered**: New IDs, shape Resources and wholesale fixture migration add no required behavior.
Evidence: inspected puzzle_definition.gd, puzzle_state.gd and puzzle_board.gd.

## Validation and rules
**Decision**: Validate positive dimensions, nonempty arrows, cardinal directions, typed/in-bounds cells, tails keyed by existing heads, unit Manhattan adjacency, no repeated cells, and no cross-shape overlap. The first tail cell, when present, must be exactly the cell immediately behind the head, opposite the head's direction of travel; each later cell continues the connected path. Reject any shape whose own tail occupies a cell on that same arrow's own forward escape ray — this is a validation failure, not a runtime case the blocking check has to exclude. Do not impose a one-turn limit or reject harmless nonconsecutive adjacency. Do not invent tail-facing restrictions beyond the formal representation. Different arrows' cells may sit orthogonally adjacent to each other with no validation consequence; only same-cell overlap is rejected. Ignore every own cell when scanning the head-forward ray at runtime — valid content never has one there, so this exclusion is a self-ownership guarantee, not a conflict resolver.
**Rationale**: This enforces the requested ordered connected shape, its fixed origin behind the head, and exclusive ownership, and keeps "head is the leading edge" a build-time guarantee rather than a special-cased runtime check. Swept whole-shape collision would change the explicit head-ray rule.
**Alternatives considered**: Physics collisions or rays from each tail cell change semantics and couple core rules to presentation. Allowing an arrow's own tail ahead of its head and excluding it only at blocking-check time was considered and rejected — it would leave the same self-block conflict resolvable in two different places instead of designed out at validation time.

## Solver correctness
**Decision**: On a fresh PuzzleState, sort active heads by (y,x), evaluate legal heads, remove the first legal head, and repeat until empty or stuck. Publish witness only on complete success.
**Rationale/proof**: Removal deletes occupied cells and adds none, so every other legal move stays legal. Given a successful ordering and any currently legal arrow A, moving A to the front and deleting its later occurrence preserves every subsequent legal step because occupancy only decreases. Induction proves arbitrary legal choices preserve solvability. A nonempty state with no legal move cannot begin a successful sequence. At most N removals and one terminal scan occur. Straightforward occupancy queries cost O(N²D + C) time and O(C + N) memory for maximum dimension D and occupied-cell count C.
**Alternatives considered**: DFS, memoization and exhaustive enumeration are unnecessary. Future rules that add blockers would invalidate this proof and need reconsideration.

## Metrics
**Decision**: Add a nested metrics dictionary counting states and active/legal choices on this deterministic trajectory only. Include a nonempty stuck terminal state, exclude the cleared terminal state.
**Rationale**: Counts are inexpensive during legality collection and do not imply difficulty or full-tree statistics.
**Alternatives considered**: Full-tree counts change scope and cost; difficulty labels lack a requested definition.

## Presentation
**Decision**: One ArrowView per head draws tail centerline segments and an oriented head using local cell offsets and cell extent independent of its bounding rectangle. Board retains hit testing; views ignore mouse. Resolve head before state mutation on tail clicks. Pulse and translate the complete view, with one departure callback per arrow. Exit distance must clear its entire bounds. Resize active shapes consistently; capture geometry for already-departing views until disposal.
**Rationale**: Preserves the existing rule-before-effects and pending-departure drain lifecycle without partial shapes or duplicate completion signals.
**Alternatives considered**: Per-cell tweens complicate accounting and completion.

## Verification approach
**Decision**: Extend existing isolated Python/GDScript suites; add solver to the explicit copied script list. No external framework/API choices are introduced; research derives from repository interfaces and the formal rules.
**Rationale**: Preserves existing regression philosophy, data isolation and practical desktop checks.
**Alternatives considered**: A new test framework is unnecessary.
