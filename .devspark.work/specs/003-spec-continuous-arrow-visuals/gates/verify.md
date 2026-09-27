---
gate: verify
status: fail
blocking: true
summary: "Fresh automated and rendered checks pass; complete end-to-end proof blocked by outstanding physical desktop/keyboard/gamepad acceptance."
selected_for_this_run_only: true
selection_reason: "No verify modes declared; end-to-end selected under standing autonomy as the conservative applicable proof for this visual feature."
verified_at: "2026-09-27T01:12:26.632194+00:00"
engine: "4.7.2.stable.official.ed1daf0bf"
source_manifest: verify-evidence/source-sha256.json
modes:
  - mode: end-to-end
    status: fail
    blocker: "T029/T030 require hands-on desktop and physical keyboard/gamepad checks. No physical-input evidence was supplied or performed; runtime reports JOYPADS=[]. Synthetic events and button signals do not satisfy that requirement."
    evidence: |
      COMMAND: python tests/run_puzzle_regressions.py --godot godot_console
      APPDATA=C:\Users\markh\AppData\Local\Temp\arrow-verify-q_wgik4b
      XDG_DATA_HOME=C:\Users\markh\AppData\Local\Temp\arrow-verify-q_wgik4b
      EXIT: 0
      Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
      Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
      PUZZLE_FAILURES=0
      Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
      Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
      PUZZLE_LAYOUT_FAILURES=0
      Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
      PUZZLE_PRESENTATION_FAILURES=0
      FULL OUTPUT: verify-evidence/puzzle.log
      
      COMMAND: python tests/run_regressions.py --godot godot_console
      APPDATA=C:\Users\markh\AppData\Local\Temp\arrow-verify-z3a1ng4y
      XDG_DATA_HOME=C:\Users\markh\AppData\Local\Temp\arrow-verify-z3a1ng4y
      EXIT: 0
      Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
      Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
      REGRESSION_FAILURES=0
      FULL OUTPUT: verify-evidence/save-input.log
      
      COMMAND: godot_console --path C:\GitHub\MakeBoldSolutions\ArrowGame --rendering-method gl_compatibility --script C:\GitHub\MakeBoldSolutions\ArrowGame\.devspark.work\specs\003-spec-continuous-arrow-visuals\gates\render_check.gd -- C:\GitHub\MakeBoldSolutions\ArrowGame\.devspark.work\specs\003-spec-continuous-arrow-visuals\gates\verify-evidence
      APPDATA=C:\Users\markh\AppData\Local\Temp\arrow-verify-unyiunbt
      XDG_DATA_HOME=C:\Users\markh\AppData\Local\Temp\arrow-verify-unyiunbt
      EXIT: 0
      Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
      JOYPADS=[]
      CAPTURE 1280x720-gameplay 0
      CAPTURE 1280x720-hover 0
      OVERLAY_CLEAR=true
      STATIONARY_RESTORE=(0, 0)
      CAPTURE 1280x720-blocked 0
      CAPTURE 1280x720-hover-restored 0
      CAPTURE 1280x720-departure 0
      CAPTURE 1280x720-results 0
      RESULTS={ "total_arrows": 8, "mistakes": 2, "score": 6, "accuracy": 0.8 } pending=0
      CAPTURE 960x540-gameplay 0
      CAPTURE 960x540-hover 0
      OVERLAY_CLEAR=true
      STATIONARY_RESTORE=(0, 0)
      CAPTURE 960x540-blocked 0
      CAPTURE 960x540-hover-restored 0
      CAPTURE 960x540-departure 0
      CAPTURE 960x540-results 0
      RESULTS={ "total_arrows": 8, "mistakes": 2, "score": 6, "accuracy": 0.8 } pending=0
      CAPTURE 1280x720-fixtures 0
      CAPTURE 960x540-fixtures 0
      FULL OUTPUT: verify-evidence/render.log
      
      COMMAND: godot_console --path C:\GitHub\MakeBoldSolutions\ArrowGame --rendering-method gl_compatibility --script C:\GitHub\MakeBoldSolutions\ArrowGame\.devspark.work\specs\003-spec-continuous-arrow-visuals\gates\navigation_check.gd -- C:\GitHub\MakeBoldSolutions\ArrowGame\.devspark.work\specs\003-spec-continuous-arrow-visuals\gates\verify-evidence
      APPDATA=C:\Users\markh\AppData\Local\Temp\arrow-verify-fzww9w1k
      XDG_DATA_HOME=C:\Users\markh\AppData\Local\Temp\arrow-verify-fzww9w1k
      EXIT: 0
      Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
      PASS: New Game opens puzzle
      PASS: keyboard Escape opens pause during feedback
      PASS: pause retains inherited theme
      PASS: pause clears hover
      PASS: Restart opens confirmation
      PASS: Restart cancellation preserves attempt
      PASS: Options opens within pause
      PASS: resume preserves counters
      PASS: confirmed Restart reconstructs clean puzzle
      PASS: completion focuses Replay
      PASS: keyboard navigates to Main Menu
      PASS: keyboard Replay reconstructs fresh attempt
      PASS: results Main Menu returns to menu
      PASS: seeded remap survives roundtrip
      PASS: saved progress bytes unchanged
      PASS: saved setting retained: VideoSettings/ScreenResolution
      PASS: saved setting retained: InputSettings/move_up
      NAVIGATION_FAILURES=0 JOYPADS=[]
      FULL OUTPUT: verify-evidence/navigation.log
      
---

# End-to-end verification

The mode applies to this invocation only. Spec frontmatter, task completion,
production code and tests were not changed by verification. All evidence above
was rerun in this invocation; earlier implementation logs were not promoted to
fresh proof. Exact argument arrays and isolated data roots are also retained in
[commands.json](verify-evidence/commands.json). The source SHA-256 manifest pins
the working-tree state, including uncommitted new resources and tests.

## Measured results

| Check | Result |
|---|---|
| Puzzle rules | Exit 0; PUZZLE_FAILURES=0 |
| Scene layout/lifecycle | Exit 0; PUZZLE_LAYOUT_FAILURES=0 |
| Presentation/geometry/effect interruption/fonts | Exit 0; PUZZLE_PRESENTATION_FAILURES=0 |
| Save/input regressions | Exit 0; REGRESSION_FAILURES=0 |
| Rendered flows at 1280x720 and 960x540 | Exit 0; both finish with score 6, 2 mistakes, 80% accuracy, pending departures 0 |
| Stationary-pointer overlay clearing/restoration | OVERLAY_CLEAR=true; STATIONARY_RESTORE=(0,0), both sizes |
| Scripted New Game/pause/options/Restart/Replay/Main Menu | Exit 0; NAVIGATION_FAILURES=0 |
| Seeded progress/remap/settings values | Preserved in scripted roundtrip |
| Physical input and complete hands-on desktop matrix | Not executed; no connected gamepad |

Inspected fresh 960x540 hover/results and 1280x720 cardinal fixture captures:
connected shafts/heads, round tails and joins, separated silhouettes, readable
results and visible focus. All fourteen fresh PNGs are under verify-evidence/.
The render driver dispatches synthetic viewport mouse events; the navigation
driver uses synthetic keyboard events, button activation signals and some
controller signals. It exercises real scenes and transitions, but does not
establish physical mouse/keyboard/gamepad operation or the entire hands-on
resize/focus matrix. No golden comparison or pre-fix failure claim is made.

## Diagnostics and limits

Full logs retain expected save-corruption fixture errors. The rendered menu
run also emits existing vendor UID fallback warnings, a legacy property-list
compatibility diagnostic and shutdown resource-leak diagnostics; these are
not erased or treated as clean output merely because assertions pass. No
runtime script exception or failed gameplay assertion was observed in this
verification run. Godot 4.4 was not rerun by this command; its earlier evidence
remains in verification.md and is not claimed as fresh verification here.

There is no passed mode to which the command's committed-test test_ref rule
applies. Supporting tests and ad hoc drivers are identified in the actual
commands, logs and source manifest. Physical acceptance cannot be inferred
from their passing results.

## Next action

Complete and record T029/T030 physical checks through /devspark.implement,
then rerun /devspark.verify. The spec remains In Progress; this gate does not
establish readiness for /devspark.create-pr. No waiver or fabricated pass was
recorded.
