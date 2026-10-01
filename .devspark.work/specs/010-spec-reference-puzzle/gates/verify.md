```yaml
gate: verify
status: pass
blocking: false
severity: info
summary: "end-to-end re-run on commit 6941414 (clean working tree): the real play, Results, Replay, Next, Level Select and Back flows pass under automated scene checks; the Reference Knot clears through the real scene to Results; the designer completed the final version by hand. PASS means the evidence required to accept the feature is sufficient, no blocking verification failure remains, and every item that was not observed has an explicit accepted or deferred disposition (listed below). PASS does not mean those items were observed: no manual desktop smoke run, no physical keyboard or gamepad traversal, no numeric on-screen cell size, and no independent-player behavior were observed."
modes:
  - mode: end-to-end
    status: pass
    test_ref: tests/puzzle_layout_check.gd::_check_all_catalog_puzzles_play_through_real_scene
    evidence: |
      Code state: commit 6941414, working tree clean (git status --short printed nothing).
      Godot 4.7.2 stable (the project targets 4.4).

      $ python tests/run_puzzle_regressions.py --godot godot        -> exit 0 (1m39s, 4035 PASS lines)
        PUZZLE_FAILURES=0  PUZZLE_ANALYZER_FAILURES=0  PUZZLE_CATALOG_FAILURES=0
        PUZZLE_SCOREBOARD_FAILURES=0  ARROW_DEPARTURE_GEOMETRY_FAILURES=0  PUZZLE_VIEWPORT_FAILURES=0
        PUZZLE_LAYOUT_FAILURES=0  PUZZLE_CANVAS_FAILURES=0  PUZZLE_PRESENTATION_FAILURES=0
      $ python tests/run_regressions.py --godot godot               -> exit 0 (78 PASS lines)
        REGRESSION_FAILURES=0
      $ godot --headless --editor --quit                            -> exit 0, 0 error/parse lines
      $ python tests/run_puzzle_structural_report.py --godot godot  -> exit 0
        [reference_knot] valid=true solvable=true; board 46x32 density=0.92 arrows=115 occupied=1348;
        initial legal 6/115; dependency edges=661 depth=33 components=1

      Real flow driven through instantiated scenes (actual PASS lines from the runs above):
        PASS: catalog entry 'reference_knot': board active view count matches the definition's arrow count
        PASS: catalog entry 'reference_knot': HUD puzzle label shows its group-relative number and title
        PASS: catalog entry 'reference_knot': results appear once every queued departure clears
        PASS: catalog entry 'reference_knot': the witness clears with zero mistakes
        PASS: catalog entry 'reference_knot': a zero-mistake clear scores every arrow
        PASS: catalog entry 'reference_knot': a zero-mistake clear has 100% accuracy
        PASS: new_game() starts the Reference Knot regardless of a prior Level Select selection
        PASS: Replay/pause-menu Restart reload the currently selected puzzle, not puzzle 1 (PuzzleSession survives the reload)
        PASS: Next Puzzle advances to the following catalog entry
        PASS: Level Select is shown on a group-ending puzzle's results
        PASS: advancing from 'reference_knot' at its group's end is a no-op
        PASS: a pending Level Select request opens Level Select when the main menu loads
        PASS: a requested Level Select open is consumed once
        PASS: Level Select entry 'reference_knot' is neither locked nor hidden
        PASS: Level Select entry 'reference_knot' shows its group-relative number and title in group order
        PASS: collapsing a group hides its entries and shows the expand marker
        PASS: expanding a group shows its entries again
        PASS: the play HUD has a visible, focusable Back button
        PASS: the Back button is wired to its handler

      Human drive-through (earlier this session): the designer played the final version (115 arrows) to
      completion with the mouse and wheel zoom. Results showed Total Arrows 115, Mistakes 2, Open Move
      Assists 2, Score 103, Accuracy 98.3%, "New session best: 103", with Replay, Level Select and Main Menu
      buttons. Answers are recorded verbatim in the published design report.

      NOT observed, therefore not claimed: a manual desktop smoke run; physical keyboard-only and gamepad
      traversal (automated input-event checks only); the live Back and Level Select scene changes performed by
      hand (the checks never trigger a real scene change); frame-time observation; the numeric on-screen cell
      size; any independent player.

      Disposition of each unobserved item (these are preserved here and in the spec's closeout; none is a pass):
        - Manual desktop smoke, physical keyboard/gamepad traversal, hand-driven live scene changes, frame
          time: ACCEPTED LIMITATION (owner decision; automated event-dispatch and scene checks stand).
        - Numeric on-screen cell size: ACCEPTED LIMITATION (readability rests on the designer's account that
          arrows were very easy to trace and wheel zoom was enough).
        - Independent-player behavior, including finding the ArrowSpark Levels group in Level Select:
          DEFERRED to the next spec (Web Showcase & Playtest); not performed here.

      Why the status is pass: the only declared mode is end-to-end, and its evidence (actual commands, actual
      output, real instantiated scenes, and a completed human playthrough) is above. No blocking verification
      failure exists. The gate schema defines pass as "every declared mode passes" and gives warn no meaning;
      it has no field for accepted limitations, so they are recorded in this evidence text.
```
