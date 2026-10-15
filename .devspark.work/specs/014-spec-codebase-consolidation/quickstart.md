# Quickstart: Verifying the Consolidation

Run from the repo root in Git Bash. `<godot>` is the Godot **4.4.1** console executable (research
R-02):

```text
G=/tmp/ArrowGame-Godot-4.4.1/bin/Godot_v4.4.1-stable_win64_console.exe   # Git Bash /tmp is %LOCALAPPDATA%\Temp
"$G" --version     # must print 4.4.1.stable.official.49a5bc7b6
```

Never run the `godot` on PATH (4.7.2) against this repository.

## Full gates (C0 baseline, after C5, and final C8)

Intermediate checkpoints use the targeted check from the plan's checkpoint table instead, usually
the first line below (the puzzle gate) plus `git status --short`.

```text
python tests/run_puzzle_regressions.py --godot "$G"
python tests/run_regressions.py --godot "$G"
"$G" --headless --path . --editor --quit
git status --short          # only the intended files may change
```

Expected: every `*_FAILURES=` marker reports 0, the editor run reports no missing dependency or
parse errors, and no engine-written file (`project.godot`, `*.uid`, `.import`) changes
unexpectedly.

## Behavior probe (C0 before, C8 after; also after C2 and C4)

`gates/behavior_probe.gd` is a temporary `extends SceneTree` script that uses only public APIs. For
each catalog index 0..29 it prints one block:

- `index`, `id`, `title`, `group`, `group_position`
- `size`, arrow count, `PuzzleContentVersion.of(definition)`
- `PuzzleSolver.analyze(definition)`: `valid`, `solvable`, `witness`, `metrics`
- Open Move trail: on a fresh `PuzzleState`, before each witness move, record `find_open_move()`,
  then call `select_arrow(witness[i])`, until the board is complete
- `PuzzleAnalyzer.analyze(definition)`, printed with `var_to_str`

Then it calls `quit(0)`. Run it:

```text
P=$(cygpath -w "$PWD/.devspark.work/specs/014-spec-codebase-consolidation/gates/behavior_probe.gd")
"$G" --headless --path . --script "$P" > .devspark.work/specs/014-spec-codebase-consolidation/gates/baseline-before.txt
# ... later, same command into baseline-after.txt ...
diff .devspark.work/specs/014-spec-codebase-consolidation/gates/baseline-before.txt \
     .devspark.work/specs/014-spec-codebase-consolidation/gates/baseline-after.txt && echo PROBE_DIFF=EMPTY
```

Strip the engine banner line before diffing if it differs. A non-empty diff is a behavior change.
Revert the step that caused it; never re-record the baseline.

## C1 mutation demonstration (SC-001)

1. Start from a committed C1. Confirm the catalog has no other edits:
   `git diff --quiet -- scripts/puzzle/puzzle_catalog.gd && echo CLEAN` must print `CLEAN`. If it
   doesn't, stop; never run the demo over uncommitted catalog work.
2. In `_build_knot_regions`, change one tail vertex by one cell, keeping the board valid. Write
   down the exact original and new text of that one line.
3. Run the puzzle gate. It must fail, and the failure must name `knot_regions`.
4. Restore by undoing that single edit (replace the new text with the recorded original). Don't
   use `git checkout`, `git restore` or `git stash`.
5. Prove the restore: `git diff --quiet -- scripts/puzzle/puzzle_catalog.gd && echo RESTORED` must
   print `RESTORED`. Then run the puzzle gate; it must pass.
6. Paste the failing and passing outputs into `consolidation-record.md`.

## C5 reachability re-check

Re-run the reachability walk (R-01 method: follow `res://`, `uid://` and `class_name` from
`project.godot`). The reached set must equal the pre-removal reached set. Then confirm no
dangling references:

```text
git grep -n -E "scenes/(game_scene|end_credits|menus/level_select_menu|loading_screen)/|overlaid_menus/(game_won|level_won|level_lost)_menu|level_list_state_manager" -- . ':!addons' ':!.archive' ':!.devspark.work'
```

Expected: no matches.

## Manual smoke (C8)

Build the web export with the same engine before any browser or phone check, and record the build
tested:

```text
node web/scripts/export-game.mjs --godot "$G"
cd web && npm ci && npm run build
```

- **Desktop**: run the project in the 4.4.1 editor. Use Simple Introduction, Large Canvas
  Validation and Reference Knot, and cover the flows listed in plan.md, Verification, Manual.
- **Browser**: Firefox and Chrome. Play one puzzle from start to results, then use Level Select.
  Record other Chromium browsers as not tested.
- **Phone (conditional)**: when a real Android phone is available, run the mobile beta: tap, drag
  pan, pinch, results. Otherwise record "mobile beta not re-verified on this build". Either way,
  record iPhone as not tested.

Record each result, or "not run" with the reason, under **Manual acceptance** in
`consolidation-record.md`, separately from **Technical completion**. Outstanding desktop or browser
smoke keeps the spec In Progress. An unrun phone check is disclosed but does not block completion.
