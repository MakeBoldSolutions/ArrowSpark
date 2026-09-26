# Implementation Verification Quickstart

**Repository**: `C:/GitHub/MakeBoldSolutions/ArrowGame`
**Feature evidence**: `C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/003-spec-continuous-arrow-visuals/gates/verification.md`

These are future implementation checks, not results already obtained during planning. Record actual engine version, command exit codes, markers, screen sizes, and outstanding hardware checks. Godot 4.4 is the declared baseline; record any substituted version explicitly.

## Baseline and final automated checks

Use the resolved Godot executable with these commands from the repository root:

```text
<godot> --version
<godot> --headless --path . --editor --quit
python tests/run_puzzle_regressions.py --godot <godot>
python tests/run_regressions.py --godot <godot>
```

Run import/validation and scene checks with APPDATA/XDG_DATA_HOME redirected to disposable test data, never player data. Existing launchers already isolate user data. The planned puzzle-launcher extension adds clean-project import preparation and a third presentation suite; before implementation only the two existing puzzle markers are expected. Final success requires exit zero and PUZZLE_FAILURES=0, PUZZLE_LAYOUT_FAILURES=0, PUZZLE_PRESENTATION_FAILURES=0, REGRESSION_FAILURES=0. Negative save-corruption fixture diagnostics are expected only when their explicit assertions/markers pass.

Do not call scene tests directly against personal user data. Use a fresh temporary data root for interactive play as well; do not delete existing user data or repurpose HOME/CODEX_HOME.

## Focused presentation checks

| Area | Required evidence |
|---|---|
| Shape | Straight, single-cell, multi-turn, all directions; exactly ordered points; no nonconsecutive-adjacency shortcut |
| Sizing | Geometry/head/body ratios scale with extent; no normal shape protrudes into a neighbor cell; bounding box stable at both sizes |
| Hover | Head, tail, blank occupied-cell space; same-owner transition continuity; empty/outside/focus-loss clearing; stationary pointer after removal/resize |
| Events | Synthetic InputEventMouseMotion/Button through GUI input or viewport dispatch, not only direct cell signal emission; release/held behavior unchanged |
| State isolation | Snapshot counters/active heads unchanged by hover; accepted clicks retain domain outcomes |
| Feedback | Red and whole-view pulse; repeated pulse replacement; hover movement during pulse; immediate ember resumption at end if eligible |
| Normalization | Progress pulse to rising/peak/falling, then call exit and assert ONE and ink immediately before awaiting a frame; repeat during hover interpolation |
| Lifecycle | Stale feedback ignored; one exit signal; mixed concurrent departures awaited; completed clicks ignored; fresh reconstruction clears effects |
| Fonts/theme | Real family/weight resources load, no intended role falls back silently; numeric support checked on actual font; theme does not reach inherited pause/options |

Prefer deterministic Tween.custom_step where appropriate for phase positioning; test actual properties on the visual components, not only timing constants. Use isolated definitions for visual fixtures without editing create_fixed or domain expectations.

## Rendered desktop smoke

At 1280×720 and 960×540, and while resizing between them:

1. Launch through opening/New Game. Confirm unchanged puzzle, light background, ink arrows, no tiles/grid, correct heads, continuous bends, rounded ends, separation, readable HUD.
2. Hover head/tail/blank portions; move across one arrow then another; leave board/window and return. No per-cell flicker, stale highlight, or counter mutation.
3. Press blocked arrows repeatedly. Confirm red, restrained pulse, no lock or disabled appearance. Keep pointer stationary to verify immediate ember return; move away during pulse to verify ink return.
4. Block B, remove A, and immediately remove B during feedback. Confirm departure starts at normal scale/ink and moves the complete rigid object. Repeat with other interruption phases and hover transitions.
5. Remove multiple arrows rapidly. Confirm immediate unblocking, no duplicate taps, and results only after all exits. Resize/pause during departure and resume; no stranded completion.
6. Review fonts, exact color roles, score/accuracy and success cue. Use Replay physically and verify identical clean board. Return to menu and re-enter.
7. Pause during feedback, resume, visit options/back, cancel Restart and verify intact attempt; confirm Restart and verify fresh state. Navigate pause/results with keyboard and gamepad and inspect visible focus. Verify remap and progress/settings survival with isolated seeded data.

Capture representative gameplay/hover/blocked/results images under the feature evidence directory and record conclusions. Smooth joins, aliasing, seam visibility, long-arrow pulse crowding, and typography require rendered judgment. Missing display/gamepad access leaves the corresponding task unchecked.

## Durable consistency and review

Check production rule/solver/definition/arithmetic files and domain-test expectations are unchanged. Run the repository's knowledge-index/coverage tooling after updating current knowledge. Run check-planning-references and git diff --check. Verify every completed task has actual code_ref/knowledge_ref or justified n/a. Do not delete/archive the bundle during implementation; release owns archival. Analyze and critic must run as separate review commands before implementation readiness is asserted.
