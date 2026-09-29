# Implementation Verification and Human Playtest

Run commands from the repository root with the installed Godot 4.4 executable supplied as $godotExe in PowerShell. Use isolated test launcher environments; protect real user saves during desktop checks.

```powershell
python tests/run_puzzle_regressions.py --godot $godotExe
python tests/run_regressions.py --godot $godotExe
python tests/run_puzzle_structural_report.py --godot $godotExe
& $godotExe --headless --path . --editor --quit
& $godotExe --path .
```

Require both regression commands to exit zero with their failure counters zero. Investigate script/import errors rather than treating process launch as validation. The structural report is descriptive, not a pass/fail quality gate. Record actual command, executable version, result and limitations in temporary verification.md; report objective measurements and witnesses in the durable report. No runtime checks were performed during planning.

1. Before changes, capture the current fifteen IDs and exact content fingerprints, including canvas_validation. After changes confirm the original content and ordering survive and all six new IDs are selectable, solve and return fresh definitions.
2. After each authored pair, run and time the existing structural report over the full catalog and record elapsed time and outcome in verification.md. Each subprocess must finish within its existing 45-second timeout before authoring the next pair. On timeout, isolate and diagnose the expensive entry while preserving geometry and metric semantics; do not merely increase the timeout. The early checks do not require the later report-output extensions. For each new puzzle, validate and replay the solver witness with zero mistakes. Check existing catalog-wide alternate-legal-order and assistance coverage; retain old scoring/save/remapping checks. Record complete witnesses in the report.
3. At 960x540, 800x800 and 1280x720, verify all 21 Level Select entries can receive visible focus; select new content and exercise Next through index 14 and the new terminal entry. Check mouse, keyboard and gamepad supported paths with remapping retained.
4. On new dense/regional/boundary puzzles, fit the full dimensions; zoom/pan to all occupied regions; select head and tail cells; request an off-screen Open Move; confirm blocked feedback and counter behavior. Exercise concurrent departures, resize, pause/resume, restart, replay, results, Next and menu return. Record responsiveness/readability and any defect; do not resize authored content merely to make it fit.
5. Human author/reviewer plays ALL SIX puzzles to completion. Record hypotheses before play and build/session provenance; for each completed session capture every data-model observation dimension. Do not show solver witnesses as gameplay guidance. Assistance is allowed and recorded; zero navigation usage and negative reactions are valid evidence. Real human input is required; automated play is not a substitute.
6. Only after all six sessions, write individual verdicts and all synthesis comparisons in .knowledge/reference/gordian-knot-experiments.md, following contracts/experiment-contract.md. Record contradictions, familiarity/order confounders and single-session limits. If geometry changes after play, rerun measurements and repeat that puzzle's session.
7. Review the complete delta for preserved rules, score formula, saved bytes/settings, no telemetry/generator/rating, and no new durable references to planning. Run analyze and critic and resolve findings. Retain temporary linkage/verification for release; missing desktop/gamepad or human checks remain outstanding.
