# Data Model

## Experimental puzzle (existing runtime representation)
PuzzleCatalog entry: stable String id, display title, zero-argument builder Callable. Builder returns a fresh PuzzleDefinition with width, height, head-to-direction arrows and head-to-ordered-tail-cells tails. Six IDs are fixed in plan.md; purpose/hypothesis belong in the report, not a runtime difficulty field.

Validation: positive dimensions, current direction/tail rules, in-bounds disjoint occupancy, no validation errors, solvable true, witness length equals arrow count, witness replay clears with zero mistakes. Preserve original entries 0 through 14 byte-equivalent in authored content; append entries 15 through 20. Runtime transition remains active -> legal removal or blocked feedback -> completed; assistance does not remove an arrow. Fresh attempts reset view and attempt counters; session best behavior stays unchanged.

## Objective characterization (existing analyzer result)
One result per puzzle ID: valid, solvable, board dimensions/total cells/occupied cells/arrow count/density, geometry lengths and bends, legal_move_structure, witness, dependency_graph, unlock_sequence, blocker_distance. Witness is an ordered sequence of integer head coordinates (x,y). Analyzer operates on fresh disposable state. Values and run/build provenance are copied into the report without interpreting them as quality rankings.

## Human observation (manual document record)
Puzzle ID and build/geometry identification; session date; human author/reviewer role without a persistent player profile; completion confirmation; perceived challenge; tracing demand; removal satisfaction; visible simplification including the relevant removal; assistance count; mistakes; final score/accuracy; actual zoom/pan/fit use and usefulness; readability; overall qualitative verdict; contextual limitations such as author familiarity and play order. Zero use and unknown values are explicit, never guessed. A missing required field leaves the record incomplete.

## Experiment report (durable Markdown reference)
Typed frontmatter: id gordian-knot-experiments, type authoritative-reference, title, appliesTo covering catalog and structural-report tooling. One section per new stable ID links purpose, pre-play hypothesis, final scale, characterization, solvability witness, actual observation and separate supported/contradicted/inconclusive interpretation. A synthesis compares all six and records contradictions and confounders. Optional prior references label canvas_validation as prior validation, not a new experiment.

Workflow: authored -> structurally validated -> measured -> human completed/observed -> interpreted -> cross-compared. Invalid geometry returns to authoring; changes after a playtest invalidate that session as evidence for the revised geometry and require replay. An unplayed puzzle remains pending; only an actual completed session can support an inconclusive verdict. No runtime save schema is introduced.
