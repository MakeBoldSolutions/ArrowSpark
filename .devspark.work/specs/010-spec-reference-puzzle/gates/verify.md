```yaml
gate: verify
status: warn
blocking: false
severity: info
summary: "end-to-end: the real flow was driven by automated scene checks and by the designer's complete playthrough of the final version; all automated runs pass. Status is warn, not pass, because accepted limitations remain (no manual desktop smoke run, no physical keyboard/gamepad confirmation, numeric cell size not captured, no independent player). Nothing here is represented as a pass beyond the evidence listed."
modes:
  - mode: end-to-end
    status: pass
    test_ref: tests/puzzle_layout_check.gd::_check_all_catalog_puzzles_play_through_real_scene
    evidence: |
      Commands run in this session on commit 4aba5e7 plus uncommitted documentation only (working tree
      code identical to HEAD):

      $ python tests/run_puzzle_regressions.py --godot godot      -> exit 0
        PUZZLE_FAILURES=0  PUZZLE_ANALYZER_FAILURES=0  PUZZLE_CATALOG_FAILURES=0
        PUZZLE_SCOREBOARD_FAILURES=0  ARROW_DEPARTURE_GEOMETRY_FAILURES=0  PUZZLE_VIEWPORT_FAILURES=0
        PUZZLE_LAYOUT_FAILURES=0  PUZZLE_CANVAS_FAILURES=0  PUZZLE_PRESENTATION_FAILURES=0
        (4035 PASS lines)
      $ python tests/run_regressions.py --godot godot             -> exit 0, REGRESSION_FAILURES=0 (78 PASS lines)
      $ godot --headless --editor --quit                          -> exit 0, 0 error/parse lines
      $ python tests/run_puzzle_structural_report.py --godot godot -> exit 0 (whole catalog, about 3 s)

      Flow actually driven through the real scenes (instantiated, not described):
      - Every one of the 22 catalog entries, including reference_knot, is loaded into the real puzzle scene and
        cleared with the solver witness through to the Results panel:
          PASS: catalog entry 'reference_knot': board active view count matches the definition's arrow count
          PASS: catalog entry 'reference_knot': HUD puzzle label shows its group-relative number and title
          PASS: catalog entry 'reference_knot': results appear once every queued departure clears
          PASS: catalog entry 'reference_knot': the witness clears with zero mistakes
          PASS: catalog entry 'reference_knot': a zero-mistake clear scores every arrow
          PASS: catalog entry 'reference_knot': a zero-mistake clear has 100% accuracy
      - Play target and progression:
          PASS: new_game() starts the Reference Knot regardless of a prior Level Select selection
          PASS: Replay/pause-menu Restart reload the currently selected puzzle, not puzzle 1
          PASS: Next Puzzle advances to the following catalog entry
          PASS: Level Select is shown on a group-ending puzzle's results
          PASS: advancing from 'reference_knot' at its group's end is a no-op
          PASS: a pending Level Select request opens Level Select when the main menu loads
          PASS: a requested Level Select open is consumed once
      - Level Select: every entry present, focusable, numbered within its group, accordion collapse/expand,
        initial focus on the first entry; Back button present and wired; HUD tab order includes Back.
      - Solver: reference_knot is valid, solvable, witness replays with zero mistakes, and the sampled
        order-independence check passes (every sixth branching state for this board only).

      Human drive-through: the designer played the final version (115 arrows) to completion with the mouse;
      the Results screen showed Total Arrows 115, Mistakes 2, Open Move Assists 2, Score 103, Accuracy 98.3%,
      "New session best: 103" and Replay / Level Select / Main Menu buttons. Answers are recorded verbatim in
      the design-report draft and the published design report.

      NOT observed, therefore not claimed: a manual desktop smoke run; physical keyboard-only and gamepad
      traversal (only automated input-event checks); the live Back and Level Select scene changes by hand;
      frame-time observation; the numeric on-screen cell size; any independent player.
```
