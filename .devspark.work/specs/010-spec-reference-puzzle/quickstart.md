# Quickstart: Verifying Spec 010

Replace `<godot>` with the Godot 4.4 executable.

## Automated gates
```powershell
python tests/run_puzzle_regressions.py --godot <godot>
python tests/run_regressions.py --godot <godot>
<godot> --headless --editor --quit          # project validation, expect no script/scene errors
python tests/run_puzzle_structural_report.py --godot <godot>   # non-gating diagnostics incl. reference_knot
```

## Desktop smoke test (record results; disclose anything not run)
1. Launch; main menu → **Play**: Reference Puzzle (`1. <title>`) starts directly.
2. Play with pointer; then with keyboard/gamepad navigation where supported. Exercise zoom, pan, Fit Puzzle, transformed selection, Show Me an Open Move, long-arrow path-following departures.
3. Complete → Results shows score/session best; **Replay** restarts the same puzzle.
4. At group end, Results offers **Level Select** (no Next Puzzle); it opens the main menu with Level Select showing.
5. Level Select: three group sections, Reference Puzzle under ArrowSpark Levels only; every entry launches; numbering restarts at 1 per group; keyboard/gamepad reach every entry.
6. From a Foundations puzzle, Next Puzzle advances within Foundations; last Foundations puzzle offers Level Select, not Next.
7. Main Menu button still works; no settings/progress files changed.

## Human evidence
- Playtest sessions per the fifteen-question questionnaire (final candidate: all 15 answered, unedited) recorded in the design report.
- SC-009: NOT PERFORMED in this spec; deferred to the next spec (Web Showcase & Playtest). Do not record it as passed. Protocol: `deferred-to-next-spec.md`.
