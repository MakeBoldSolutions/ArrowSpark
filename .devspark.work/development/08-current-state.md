# Current State --- 2026-09-28

## Summary

| Spec | State |
|---|---|
| 001--007 | **Complete.** Spec 007 was merged into the main line (`f534691`). |
| 008 Large Zoomable Puzzle Canvas | **Planned, implementation not started.** |
| 009, 010 | Roadmap only. See [13-roadmap-008-010.md](13-roadmap-008-010.md). |

## Branch and Repository State

Active feature branch: `008-spec-large-zoomable-canvas`.

The main branch is `main`. It was renamed from `master` when the repository
moved to https://github.com/MakeBoldSolutions/ArrowSpark.

## Spec 007: Complete

Open Move assistance and session scoring are implemented, verified, and merged.

### Manual verification

The five manual desktop checks that were outstanding when this document set was
first written (T009, T017, T023, T032, T035) were run on a desktop build on
2026-09-28 and passed. They covered blocked arrows, Open Move, the Results
screen, replay and relaunch, and the absence of saved progress. T036 linkage
confirmation was closed afterward. The spec status is `Complete`.

### What 007 delivered

`PuzzleState` includes `find_open_move()`, `request_open_move()`, and
`open_move_assists`. The score is:

`max(total_arrows - (mistakes + open_move_assists * 5), 0)`

The in-memory `PuzzleScoreboard` remembers each puzzle's best completed score
and the overall session score. It never touches saved progress.

The UI has a keyboard/gamepad-focusable **Show Me an Open Move** button, a
pulsing highlight on the selected open arrow, the assist count in Results, a
session-best comparison, and the overall session score.

Knowledge added or updated: `.knowledge/product/gameplay-contract.md` (new) and
`.knowledge/architecture/arrow-puzzle.md`.

### Recorded implementation deviations (still true)

- **Keyboard/gamepad test.** T012 verifies focus eligibility and signal wiring,
  not simulated headless key presses. Simulated key presses were
  nondeterministic headlessly. Real interaction is a manual acceptance concern.
- **Open Move highlight clearing.** The highlight clears on any accepted
  selection or a fresh attempt, not on hover. Hover is presentation exploration;
  an accepted selection changes interaction state.
- **Knowledge type correction.** The knowledge index builder rejects
  `type: product`. `branding.md` and the new gameplay contract use
  `authoritative-reference`. This is a DevSpark schema/documentation
  improvement candidate: either support `product` or make the allowed types
  explicit so agents do not invent metadata.
- **Test-only viewport ordering bug.** A new end-to-end test ran before
  viewport sizing had occurred. The test was fixed; no production code changed.

## Spec 008: Large Zoomable Puzzle Canvas (in progress)

Stage: **planned; no implementation task has been executed.**

Working bundle: `.devspark.work/specs/008-spec-large-zoomable-canvas/`.

| Artifact | State |
|---|---|
| spec.md | Present. Status field still `Draft`. |
| plan.md, research.md, data-model.md, contracts, quickstart.md | Present. |
| tasks.md | Generated; 0 of 33 tasks complete. |
| Requirements checklist | Passed, 26/26. |
| Analyze gate | Pass. 22 of 22 requirements covered, no open findings. |
| Critic gate | Pass. Risk posture green, no open findings. |
| End-to-end verification | Required and not yet run. It needs a human on real hardware. |

Risk profile: full-spec, high risk, customer-facing game, brownfield.

Known caveats recorded by the gates:

- The installed Godot is 4.7.2 and the project targets 4.4. T001/T029 record
  this as outstanding.
- Physical verification will be done on Windows 11 with mouse and keyboard.
  Gamepad is recorded as outstanding (T030).
- Touch input is out of scope for 008.

The design keeps view state as presentation only, using a single parent
transform. The rule, solver, analyzer, and scoring authorities are unchanged
(DP-021).

## Automated Gates (required for gameplay changes)

- `python tests/run_puzzle_regressions.py --godot <executable>`
- `python tests/run_regressions.py --godot <executable>`
- Godot headless editor validation and a desktop smoke test.

Failure markers that must report zero: `PUZZLE_FAILURES`,
`PUZZLE_ANALYZER_FAILURES`, `PUZZLE_CATALOG_FAILURES`,
`PUZZLE_SCOREBOARD_FAILURES`, `ARROW_DEPARTURE_GEOMETRY_FAILURES`,
`PUZZLE_LAYOUT_FAILURES`, `PUZZLE_PRESENTATION_FAILURES`, and
`REGRESSION_FAILURES`. Spec 008 adds its own suites, all of which must be green
at its final task.

## Immediate Next Steps

1. Run `/devspark.implement` for Spec 008 and work through the tasks.
2. Complete the required end-to-end verification on real hardware.
3. Set Spec 008 to `Complete`, then `/devspark.create-pr`, review, merge.
4. Run the post-008 checkpoint in [13-roadmap-008-010.md](13-roadmap-008-010.md).
5. Specify Spec 009 (Gordian Knot Experiments).

## Product Direction

Do not add another scoring or progression system. The constraint being removed
now is physical board size. After that, return to content research with large,
long-tail, geometrically entangled puzzles.

## Manual Review Emphasis for 008

Beyond pass/fail mechanics, pay attention to:

- whether pan is clearly distinct from arrow selection (no accidental
  selection);
- whether Fit Puzzle reliably restores the overview;
- whether Open Move visibly reveals an off-screen arrow without altering
  gameplay state;
- whether departure animation stays correct while the view changes;
- whether small existing puzzles still feel natural without camera work.
