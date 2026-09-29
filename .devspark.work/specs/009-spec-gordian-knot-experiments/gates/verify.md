---
gate: verify
status: fail
blocking: true
summary: "Automated gameplay flows pass, but desktop input checks and six required human play sessions are absent."
modes:
  - mode: end-to-end
    status: fail
    evidence: |
      User selected end-to-end for this run; spec.md declares no verify:<mode> gate.

      Command: python -c "import subprocess,sys; p=subprocess.run(['godot','--headless','--path','.','--script','res://tests/puzzle_layout_check.gd'],capture_output=True,text=True,timeout=60); lines=(p.stdout+'\n'+p.stderr).splitlines(); print('\n'.join(x for x in lines if any(y in x for y in ('knot_', 'Level Select', 'Replay/pause-menu', 'Next Puzzle', 'PUZZLE_LAYOUT_FAILURES')))); print('EXIT='+str(p.returncode)); sys.exit(p.returncode)"
      Actual output (selected lines from the command's filtered output):
        PASS: catalog entry 'knot_long_geometry': the witness clears with zero mistakes
        PASS: catalog entry 'knot_interwoven_paths': the witness clears with zero mistakes
        PASS: catalog entry 'knot_dense_core': the witness clears with zero mistakes
        PASS: catalog entry 'knot_regions': the witness clears with zero mistakes
        PASS: catalog entry 'knot_single_release': the witness clears with zero mistakes
        PASS: catalog entry 'knot_boundary': the witness clears with zero mistakes
        PASS: Level Select lists exactly one entry per catalog puzzle
        PASS: Replay/pause-menu Restart reload the currently selected puzzle, not puzzle 1 (PuzzleSession survives the reload)
        PASS: Next Puzzle advances to the following catalog entry
        PASS: Next Puzzle is not shown on the last catalog puzzle's results
        PUZZLE_LAYOUT_FAILURES=0
        EXIT=0

      Command: python -c "import subprocess,sys; p=subprocess.run(['godot','--headless','--path','.','--script','res://tests/puzzle_canvas_check.gd'],capture_output=True,text=True,timeout=60); lines=(p.stdout+'\n'+p.stderr).splitlines(); print('\n'.join(x for x in lines if any(y in x for y in ('knot_', 'PUZZLE_CANVAS_FAILURES')))); print('EXIT='+str(p.returncode)); sys.exit(p.returncode)"
      Actual output (selected lines from the command's filtered output):
        PASS: experiment 'knot_long_geometry' accepts a transformed legal selection
        PASS: experiment 'knot_interwoven_paths' accepts a transformed legal selection
        PASS: experiment 'knot_dense_core' accepts a transformed legal selection
        PASS: experiment 'knot_regions' accepts a transformed legal selection
        PASS: experiment 'knot_single_release' accepts a transformed legal selection
        PASS: experiment 'knot_boundary' accepts a transformed legal selection
        PUZZLE_CANVAS_FAILURES=0
        EXIT=0

      Command: python -c "import subprocess,sys; p=subprocess.run(['godot','--headless','--path','.','--quit-after','60'],capture_output=True,text=True,timeout=30); x=p.stdout+p.stderr; print('\n'.join(s for s in x.splitlines() if ('ERROR' in s or 'WARNING' in s or 'Godot Engine' in s))); print('EXIT='+str(p.returncode)); sys.exit(p.returncode)"
      Actual output (excerpt):
        Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
        WARNING: res://scenes/menus/main_menu/main_menu_with_animations.tscn:4 - ext_resource, invalid UID: uid://bjv2v4jhmcukd - using text path instead: res://scenes/menus/main_menu/main_menu_with_animations.gd
        WARNING: 1 ObjectDB instance was leaked at exit (run with `--verbose` for details).
        EXIT=0
      The launch above followed a successful `godot --headless --path . --import`.
      An earlier direct headless launch printed resource parse errors despite EXIT=0;
      they did not recur after import. Exit code alone is not treated as proof.

      Command: rg -c 'Pending actual human completion' .knowledge/reference/gordian-knot-experiments.md
      Actual output: 6

      Blocker: No human completion/experience observations exist for the six
      experiments, so the feature's play -> compare flow cannot be verified.
      Desktop mouse/keyboard/gamepad, remapping, readability, and window-size
      smoke checks remain open in tasks.md (T011, T024). Headless automated
      scene tests do not establish those outcomes. The installed Godot is 4.7.2;
      the project targets 4.4, which was not exercised in this run.
---

# Addendum 2026-09-29

The blocker above (no human observations) was resolved by the owner accepting aggregate session evidence; see verification.md. Godot 4.4.1 was exercised. The desktop input and resolution matrix and gamepad hardware were not independently verified. The status above is retained as the record of the earlier run.
