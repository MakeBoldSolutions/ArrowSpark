# Experiment Interfaces and Evidence Contract

## Catalog and gameplay interface
Append the six stable IDs from plan.md to the existing registry, preserving the first fifteen entries. count becomes 21, id/title/index lookup retain their current semantics, get_definition returns fresh isolated data and unknown IDs retain existing behavior. Dynamic Level Select exposes every entry; Next traverses canvas_validation into knot_long_geometry and stops at knot_boundary. New Game still starts at the first entry.

Selection, blocking, assistance, departure completion and scoring all use the existing runtime contract. Mouse selection remains the supported arrow-selection mechanism. Keyboard/gamepad retain menu/toolbar focus and remappable navigation controls; this change does not promise a new arrow-selection input system.

## Canvas interface
Existing fit_puzzle/zoom_in/zoom_out/pan and Open Move reveal operate over full authored dimensions. Fit shows the full board; zoom/pan permits inspection and selection of every occupied region. Selection and assistance at transformed positions use existing logical coordinates, with unchanged scoring. Pause/restart/replay/Next reset or preserve state exactly as current contracts specify. Navigation during departures stays responsive. Readability complaints in the boundary case are evidence, but missing/unselectable arrows and broken navigation are defects.

## Developer report interface
Run tests/run_puzzle_structural_report.py with --godot. Keep existing catalog enumeration and comparison sections. Add explicit validity/solvability, occupied cells, average length and full ordered (x,y) witness from existing PuzzleAnalyzer output. Coordinate order must be unambiguous and repeatable. Successful process exit means the report ran, not that the puzzles are good or the gameplay regression gate passed. Solver/catalog regressions remain the correctness gate.

## Human report interface
For every new ID, record purpose, actual dimensions/scale, objective fields, pre-play hypothesis, validity/solvability and full zero-mistake witness, followed by every observation field in data-model.md. Distinct headings must separate Measurements, Observed in this session, and Interpretation. Human completion is required even when assistance is heavy or reaction is negative.

Synthesis explicitly addresses: longer paths and satisfaction; interweaving and challenge/tracing; dense geometry and readability; regions and approachability; the big release and visible simplification; the boundary of excessive geometry; actual navigation use/usefulness; and objective-versus-subjective agreement or contradictions. State single-session/author-familiarity/play-order limits. No general difficulty formula or recommendation to generate puzzles follows from these observations.

Durable report evidence cites production/test files and actual sessions, never temporary spec/plan/task IDs or paths. Runtime stores no new player identity or gameplay data.
