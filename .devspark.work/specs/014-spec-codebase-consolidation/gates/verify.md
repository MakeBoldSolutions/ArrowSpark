# Verify Gate: Codebase Organization and Consolidation

```yaml
gate: verify
devspark_version: "9.1.0"
generated: "2026-10-15T19:55:57Z"
status: pass
blocking: false
summary: "snapshot-neutral PASS. The behavior probe over all 30 catalog entries is byte-identical between the pre-change commit 58a8bec (fresh worktree) and HEAD b7f01d2, and the shipped reachable-file set is unchanged. Both headless gates and editor validation are green on HEAD."
modes:
  - mode: snapshot-neutral
    evidence_class: automated
    status: pass
    test_ref: "tests/puzzle_catalog_check.gd::_check_catalog_pins"
    evidence: |
      Engine: Godot 4.4.1.stable.official.49a5bc7b6
        G=/tmp/ArrowGame-Godot-4.4.1/bin/Godot_v4.4.1-stable_win64_console.exe
      Probe: .devspark.work/specs/014-spec-codebase-consolidation/gates/behavior_probe.gd
        (per entry: id/title/group/position, size, arrow count, PuzzleContentVersion,
         PuzzleSolver valid/solvable/witness/metrics, Open Move before every witness move,
         full PuzzleAnalyzer report)

      1) Pre-change baseline, captured fresh in an isolated worktree:
         $ git worktree add --detach $TEMP/s014/wt-58a8bec 58a8bec
         58a8bec Link Beck's talk from the retrospective and lead /devspark with it
         $ "$G" --headless --path <wt> --editor --quit          -> import exit 0
         $ "$G" --headless --path <wt> --script <probe> | sed -n '/^PROBE_BEGIN/,/^PROBE_END/p' > verify_pre.txt
         pre exit 0; 30 entry blocks

      2) After, at HEAD:
         $ "$G" --headless --path . --script <probe> | sed ... > verify_head.txt
         head exit 0 at b7f01d2; 30 entry blocks

      3) Diff:
         $ sha256sum verify_pre.txt verify_head.txt gates/baseline-before.txt
         a5d38d01b0f79e01d63066d4e496ee1f6b9150d5858e0cfd226ac2708c17c616  verify_pre.txt
         a5d38d01b0f79e01d63066d4e496ee1f6b9150d5858e0cfd226ac2708c17c616  verify_head.txt
         a5d38d01b0f79e01d63066d4e496ee1f6b9150d5858e0cfd226ac2708c17c616  gates/baseline-before.txt
         $ diff verify_pre.txt verify_head.txt && echo PROBE_DIFF=EMPTY
         PROBE_DIFF=EMPTY

      4) Shipped reachable set (res://, uid:// and class_name walk from project.godot;
         template removal neutrality):
         $ (cd <wt> && python reach3.py) > reach_pre.txt      -> 127 files
         $ python reach3.py > reach_head.txt                  -> 127 files
         $ diff reach_pre.txt reach_head.txt && echo REACHED_SET_UNCHANGED
         REACHED_SET_UNCHANGED

      5) Gates on HEAD b7f01d2:
         $ python tests/run_puzzle_regressions.py --godot "$G"   -> exit 0
           PUZZLE_FAILURES=0 PUZZLE_ANALYZER_FAILURES=0 PUZZLE_CATALOG_FAILURES=0
           PUZZLE_SCOREBOARD_FAILURES=0 ARROW_DEPARTURE_GEOMETRY_FAILURES=0
           PUZZLE_VIEWPORT_FAILURES=0 PUZZLE_LAYOUT_FAILURES=0 PUZZLE_CANVAS_FAILURES=0
           PUZZLE_PRESENTATION_FAILURES=0
         $ python tests/run_regressions.py --godot "$G"          -> exit 0, REGRESSION_FAILURES=0
         $ "$G" --headless --path . --editor --quit              -> exit 0, 0 error/missing lines
         $ git worktree remove --force <wt>; git status --short -> clean

      Intentional deltas: none. The diff is empty, and no frozen deltas needed justifying.
      Pin sensitivity (recorded in consolidation-record.md, C1): a one-cell change to
      knot_regions made the catalog check fail with exactly
      "FAIL: entry `knot_regions` keeps its geometry g1-d2398acdb422 (got g1-3b9bb8570e77)";
      undoing it restored green.
discovered:
  - "tests/run_puzzle_regressions.py hides a failing check's output (subprocess.run(check=True) raises before printing), so a failing gate shows a traceback, not the FAIL line."
  - "web/scripts/check-content.mjs still lists the removed scenes/loading_screen folder; walk() returns [] for a missing folder, so it passes."
  - "The New Game tooltip (main_menu_with_animations.tscn:389) says 'Starts the Reference Knot', but New Game starts first_knot."
  - "No Godot 4.4.1 web export templates are installed here; the web export used 4.4-stable (templates present)."
  - "DevSpark's semantic hash treats tasks.md 'Checkpoint: Phase complete' lines as semantic, forcing an Analyze recheck when they are added."
  - "Browser smoke ran only in a Chromium-based browser (Perplexity); Firefox and Chrome not tested. Mobile-beta phone check not run (developer choice)."
```
