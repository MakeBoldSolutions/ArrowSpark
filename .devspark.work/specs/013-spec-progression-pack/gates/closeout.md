```yaml
gate: closeout
devspark_version: "9.1.0"
generated: "2026-10-14T13:05:00Z"
status: pass
blocking: false
produced_by: verify
objective: achieved
decision: complete
summary: "The showcase lets any board point be centered, ships eight proven levels leading to the Reference Knot, and was confirmed good by the owner on desktop and phone; no blocking defects and nothing unclassified."
criteria:
  - {id: FR-001, kind: requirement, outcome: satisfied, evidence: "tests/puzzle_catalog_check.gd::_check_progression_levels (eight levels, group of nine, before reference_knot); Level Select seen in the browser"}
  - {id: FR-002, kind: requirement, outcome: satisfied, evidence: "PUZZLE_CATALOG_FAILURES=0 and PUZZLE_ANALYZER_FAILURES=0 on Godot 4.4: every level solver-confirmed solvable with a replayed zero-mistake witness"}
  - {id: FR-003, kind: requirement, outcome: satisfied, evidence: "git diff scope reviewed: only the camera clamp, departure clip and margin, catalog, Play target, tests and knowledge changed"}
  - {id: FR-004, kind: requirement, outcome: satisfied, evidence: "stable ids and titles pinned in tests/puzzle_catalog_check.gd; design-intent comment on each builder in scripts/puzzle/puzzle_catalog.gd"}
  - {id: FR-005, kind: requirement, outcome: satisfied, evidence: "eight distinct primary challenges in the builder comments, checked against measured structure in .knowledge/reference/progression-design-learning.md; owner judged the boards good"}
  - {id: FR-006, kind: requirement, outcome: satisfied, evidence: "arrow counts 9, 15, 14, 17, 23, 30, 68, 93 then 115; owner reports a good progression"}
  - {id: FR-007, kind: requirement, outcome: satisfied, evidence: "tests/puzzle_catalog_check.gd::_check_progression_levels asserts no single-cell arrows in any level"}
  - {id: FR-008, kind: requirement, outcome: satisfied, evidence: "run_puzzle_structural_report.py output captured in .knowledge/reference/progression-design-learning.md"}
  - {id: FR-009, kind: requirement, outcome: satisfied, evidence: "recorded as descriptive data; no numeric threshold set"}
  - {id: FR-010, kind: requirement, outcome: satisfied, evidence: "both gates zero on Godot 4.4 and 4.7.2"}
  - {id: FR-011, kind: requirement, outcome: satisfied, evidence: "gates/verify.md end-to-end: all nine levels to Results, Next Puzzle, Back to Level Select, Replay (owner), and one valid completion message per level"}
  - {id: FR-012, kind: requirement, outcome: satisfied, evidence: "owner aggregate playtest notes recorded in the learning record; not per level"}
  - {id: FR-013, kind: requirement, outcome: satisfied, evidence: ".knowledge/reference/progression-design-learning.md with observed facts, designer judgments and open questions; no generator work"}
  - {id: FR-014, kind: requirement, outcome: satisfied, evidence: "findings classified in this artifact and in the plan Verification Record"}
  - {id: FR-015, kind: requirement, outcome: satisfied, evidence: "ORIGINAL_ENTRIES fingerprints and the Reference Knot version pin g1-7ce0942d4a5e pass in tests/puzzle_catalog_check.gd"}
  - {id: FR-016, kind: requirement, outcome: satisfied, evidence: "arrow-puzzle.md, save-progression.md, web-showcase.md and touch-gestures.md updated with no planning identifiers; check-planning-references reports only pre-existing matches"}
  - {id: FR-017, kind: requirement, outcome: satisfied, evidence: "tests/save_input_regression.gd (new_game starts first_knot); browser: New Game opens 1. First Knot"}
  - {id: FR-018, kind: requirement, outcome: satisfied, evidence: "tests/puzzle_viewport_transform_check.gd::_test_corner_reach; tests/puzzle_canvas_check.gd corner-to-center on the large board; browser screenshots; owner hands-on"}
  - {id: FR-019, kind: requirement, outcome: satisfied, evidence: "_test_pan_clamping asserts part of the board stays in view; held-key pan stops at the corner in tests/puzzle_canvas_check.gd"}
  - {id: FR-020, kind: requirement, outcome: satisfied, evidence: "_test_fit_lock and _test_reveal_cell in tests/puzzle_viewport_transform_check.gd pass; Fit unchanged at start in the browser"}
  - {id: FR-021, kind: requirement, outcome: accepted, evidence: "_test_edge_anchor_stability measures the in-bounds case; the bound exception is stated in the amended FR-021 and accepted under CO-003"}
  - {id: FR-022, kind: requirement, outcome: satisfied, evidence: "change confined to scripts/presentation/puzzle_viewport_transform.gd and scenes/puzzle/puzzle_board.gd; old clamp assertions replaced"}
  - {id: FR-023, kind: requirement, outcome: satisfied, evidence: "tests/puzzle_canvas_check.gd asserts the departure clip is off; browser screenshot sequence shows the arrow past the board edge; margin 6.0 cells in scripts/puzzle/puzzle_feedback.gd"}
  - {id: SC-001, kind: requirement, outcome: satisfied, evidence: "eight levels playable from Level Select in order ahead of the Reference Knot"}
  - {id: SC-002, kind: requirement, outcome: satisfied, evidence: "all failure markers 0 on Godot 4.4"}
  - {id: SC-003, kind: requirement, outcome: satisfied, evidence: "all nine levels to Results on desktop by script and by the owner; owner played all levels on a Pixel 7 Pro in Chrome"}
  - {id: SC-004, kind: requirement, outcome: satisfied, evidence: "intent note and structural characteristics for every level; playtest notes are aggregate (see CO-005 and the learning record)"}
  - {id: SC-005, kind: requirement, outcome: satisfied, evidence: "distinct intents; none relies on single-cell arrows (test)"}
  - {id: SC-006, kind: requirement, outcome: satisfied, evidence: "owner reports a good progression and did not report a cliff, including into the Reference Knot"}
  - {id: SC-007, kind: requirement, outcome: satisfied, evidence: "learning record exists; no generator code added"}
  - {id: SC-008, kind: requirement, outcome: satisfied, evidence: "only the camera clamp and departure presentation changed in the engine; no rule, scoring, hint, persistence, controls or site-contract change"}
  - {id: SC-009, kind: requirement, outcome: satisfied, evidence: "tests/puzzle_canvas_check.gd::_check_corner_reach_for_every_catalog_size: 23 distinct sizes, 176 cases, 0 misses; hand-confirmed on desktop and on the phone", test_ref: "tests/puzzle_canvas_check.gd::_check_corner_reach_for_every_catalog_size"}
  - {id: SC-010, kind: requirement, outcome: satisfied, evidence: "_test_edge_anchor_stability (worst drift under one pixel while the bound does not bind); owner confirmed wheel zoom and phone pinch"}
  - {id: SC-011, kind: requirement, outcome: satisfied, evidence: "tests/save_input_regression.gd and the browser: Play starts first_knot"}
  - {id: SC-012, kind: requirement, outcome: satisfied, evidence: "browser screenshot sequence of a departure with the board edge at the screen center; last click to Results measured at 0.86 to 2.99 s; owner reports no problem"}
findings:
  - id: CO-001
    classification: deferred-work
    summary: "Menus and Results screens between levels are very small and hard to read on the phone, especially in fullscreen."
    rationale: "Fixing it is UI scaling, which this work excludes (no UI redesign or touch-target work); it fails no stated criterion, violates no invariant and is not caused by this change, so it hits no expansion trigger."
    captured_as: ".knowledge/architecture/web-showcase.md (Mobile web beta: remaining limitations on the phone)"
  - id: CO-002
    classification: deferred-work
    summary: "The Play page admission rule measures the visible page area, so a landscape phone with the address bar showing can be told the screen is too small until the bar hides."
    rationale: "Existing behavior of the admission rule, outside this work scope; no expansion trigger."
    captured_as: ".knowledge/architecture/web-showcase.md (Mobile web beta: remaining limitations on the phone)"
  - id: CO-003
    classification: accepted-limitation
    summary: "Zoom does not hold the pointer board point when the camera-center bound or the Fit lock leaves no way to (for example zooming out with a board corner at the center); the view settles at the bound."
    rationale: "Inherent to a bound on the camera center; the in-bounds case is within one pixel and tested. FR-021, SC-010 and the scenario were amended to state the exception, so no requirement as written is violated. Hits no expansion trigger."
    accepted_by: "Mark Hazleton (owner), who confirmed the camera behavior as the desired behavior after hands-on desktop and phone play on 2026-10-14; the exception itself was not separately reviewed by them and is flagged for their confirmation in the verify report"
  - id: CO-004
    classification: learning
    summary: "A fixed 6-cell departure margin hides removal at normal zoom, but with the camera at a board edge and fully zoomed out the visible area beyond the edge spans many cells."
    rationale: "A refined assumption about a cosmetic detail; no criterion fails and no invariant is violated."
    original_expectation: "A fixed margin of cells would hide removal in the common zoomed-in view, with extreme zoom-out accepted as a bounded cosmetic limit."
    revised_understanding: "Confirmed at normal zoom by screenshot and the owner play; the extreme zoom-out case was not exercised, and a fade-out is the likely refinement if it matters."
  - id: CO-005
    classification: learning
    summary: "The step from almost_a_knot to the Reference Knot is structurally large, and playtest notes are aggregate, not per level."
    rationale: "The owner judged the progression good and reported no cliff; no criterion fails."
    original_expectation: "That step might feel like a cliff and would need judging by play."
    revised_understanding: "The owner reported a good progression without singling it out; the experience of that step for a first-time player is untested."
  - id: CO-006
    classification: learning
    summary: "Levels were found by a seeded search in reverse solve order; dense boards needed center-outward layering, and first-draft intent notes overstated the structure."
    rationale: "Design learning for later work, recorded in the learning record; fails no criterion."
    original_expectation: "Profiles could be written first and the notes trusted."
    revised_understanding: "Notes must be checked against measured structure; several were rewritten."
  - id: CO-007
    classification: deferred-work
    summary: "Safari, Edge, iPhone and other Android devices were not tested."
    rationale: "Not claimed as supported; no stated criterion requires them, so no expansion trigger."
    captured_as: ".knowledge/architecture/web-showcase.md (Desktop browsers and Mobile web beta verification statements)"
  - id: CO-008
    classification: deferred-work
    summary: "Gamepad input, the pause menu and Open Move at a board edge were not exercised on desktop."
    rationale: "Navigation input mapping was not changed; no criterion fails; disclosed rather than claimed."
    captured_as: ".knowledge/architecture/arrow-puzzle.md (Canvas Navigation source of truth: real mouse, keyboard and gamepad feel needs desktop review)"
regression_gates:
  - "tests/puzzle_viewport_transform_check.gd::_test_corner_reach, _test_fit_lock, _test_edge_anchor_stability (PUZZLE_VIEWPORT_FAILURES=0)"
  - "tests/puzzle_canvas_check.gd::_check_corner_reach_for_every_catalog_size and the corner, held-key and unclipped-departure checks (PUZZLE_CANVAS_FAILURES=0)"
  - "tests/puzzle_catalog_check.gd::_check_progression_levels and the Reference Knot version pin (PUZZLE_CATALOG_FAILURES=0)"
  - "tests/puzzle_analyzer_check.gd::_check_progression_levels_analyze (PUZZLE_ANALYZER_FAILURES=0)"
  - "tests/save_input_regression.gd Play-target assertion (REGRESSION_FAILURES=0)"
unclassified: []
```
