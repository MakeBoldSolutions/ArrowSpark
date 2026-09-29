# Research: Gordian Knot Experiments

## Catalog integration
**Decision:** Append six builders in scripts/puzzle/puzzle_catalog.gd using its existing literal construction and fresh-definition API.
**Rationale:** Existing Level Select and PuzzleSession enumerate the registry; no new loading or selection mechanism is necessary. There are currently fifteen entries, including six earlier structural experiments and canvas_validation at index 14. Preserve all fifteen and append the new set.
**Alternatives considered:** Separate content resources or a generator would add unnecessary infrastructure. Reclassifying prior experiments would not meet the requested new set.

## Preservation checks
**Decision:** Retain original fourteen fingerprints, add an exact pre-change fingerprint for canvas_validation, and update catalog-count and final-entry assertions in tests/puzzle_catalog_check.gd.
**Rationale:** Current assertions hard-code count 15 and canvas_validation as final; additive content requires count 21 and a new terminal entry, while index 14 and its complete geometry remain protected. Preserve every unrelated assertion and verify Next crosses both old and new boundaries.
**Alternatives considered:** Removing positional/content assertions weakens compatibility protection; leaving them unchanged makes the additive requirement impossible.

## Geometry and validity
**Decision:** Hand-author six disjoint grid layouts with the purposes and starting sizes in plan.md. Use PuzzleDefinition validation, PuzzleSolver.analyze and existing witness replay/order-independence checks.
**Rationale:** Removal is monotonic; a valid full witness plus the existing rule guarantee supports any legal order. Solver evidence is not evidence of human enjoyment. Winding tails cannot overlap occupied cells.
**Alternatives considered:** New blocking rules, alternate solvers or automated puzzle generation violate scope.

## Measurements
**Decision:** Add no analyzer metrics. Extend tests/puzzle_structural_report.gd to print existing valid/solvable flags, full coordinate witness and useful existing geometry fields, including occupied cells and average length.
**Rationale:** Current text report omits the witness even though PuzzleAnalyzer already returns it. Existing density/bends/length/dependency/unlock fields suffice. Preserve the report's non-gating meaning and existing output sections.
**Alternatives considered:** A combined score conflates measurements with experience; metric-threshold shipping gates repeat that error. Analyzer execution stays in isolated developer tooling, particularly because longest-simple-path analysis can be costly.

## Human evidence and report
**Decision:** Manual author/reviewer play sessions, recorded in a typed current-knowledge reference document; no application recording UI or telemetry.
**Rationale:** The specification explicitly requires human completion. Capture hypotheses before play, then observations and cautious interpretations separately. Unplayed means pending, never an invented inconclusive result. The AI can prepare and transcribe evidence but cannot stand in for the human.
**Alternatives considered:** Automated solver runs or visual inspection cannot establish perceived satisfaction. Player accounts or feedback services breach scope.

## Verification and workflow
**Decision:** Reuse both regression launchers plus Godot validation and desktop smoke; augment only content-specific regression coverage requested by solvability and preservation outcomes.
**Rationale:** Headless events do not establish real mouse/gamepad feel or rendered readability. Required analyze/critic gates remain subsequent workflow steps.
**Alternatives considered:** Exhaustive new infrastructure is unnecessary; claiming completion before human playtests or required checks would violate the specification and constitution.

All technical choices are resolved from repository code and current knowledge; no external library or new API research is needed.
