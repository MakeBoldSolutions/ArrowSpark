# Current State --- 2026-10-11

## Summary

| Spec | State |
|---|---|
| 001--007 | **Complete.** Rules, visuals, departure, catalog, analysis, Open Move and session scoring. |
| 008 Large Zoomable Puzzle Canvas | **Complete.** Merged as PR #1 (`faa4575`). |
| 009 Gordian Knot Experiments | **Complete.** Merged as PR #2 (`8a00239`). |
| 010 Reference Puzzle and Level Groups | **Complete, with documented limitations.** Merged as PR #4 (`6e60e11`). |
| 011 Web Showcase | **Complete.** Merged as PR #5 (2026-10-03). Playable Web build, story site and reactions client at arrow.makeboldspark.com. |
| 012 Mobile Web Play | **Complete as a public beta, with documented limitations.** PR #6 (2026-10-03) admitted touch landscape screens; PR #8 (2026-10-11) made touch modeless. |
| Next | **Not yet specified.** Candidates: 44 px touch targets and in-game touch help, fresh-player validation, anonymous feedback review. See [13-roadmap-008-010.md](13-roadmap-008-010.md). |

## Repository State

- Branch `main` at `dece281`, working tree clean, 140 commits. No active feature
  branch.
- Repository: https://github.com/MakeBoldSolutions/ArrowSpark (local directory
  `ArrowGame`). Merged PRs: #1 (008), #2 (009), #3 (audit follow-up), #4
  (010), #5 (011), #6 (012 beta), #8 (012 modeless touch).
- Stack: Godot 4.4 target, GDScript, Maaack's Game Template. Python 3.11+
  launchers. Validation has also been run on Godot 4.7.2.
- Constitution 2.2.0. BSW.DevSpark 7.8.0.

## Catalog: 22 puzzles in three groups

| Group | Count | Contents |
|---|---|---|
| Foundations | 8 | The baseline set, from Simple Introduction to Subtle Blockers. |
| Puzzle Lab | 13 | Six structural experiments, `canvas_validation` (52 arrows, 40x30) and six Gordian Knot experiments. |
| ArrowSpark Levels | 1 | `reference_knot`: 115 arrows on 46x32, density 0.92. Main-menu Play starts it. |

Groups are presentation metadata. Stable puzzle ids are unchanged. Level
Select is an accordion by group, numbering restarts at 1 in each group, and
Next Puzzle stays within the group and never wraps.

## What the game does today

- Multi-cell bent arrows leave along their own path; blocked selections count as
  mistakes.
- Open Move highlights one legal arrow for the cost of five mistakes.
  `score = max(total_arrows - (mistakes + open_move_assists * 5), 0)`.
- Session-only scoreboard: per-puzzle best and overall session score, never
  persisted. Only settings and input remaps persist.
- Zoom, pan and Fit Puzzle by mouse, keyboard and gamepad. View state is
  transient.
- Pure-RefCounted rule core (`PuzzleDefinition`, `PuzzleState`, `PuzzleSolver`,
  `PuzzleAnalyzer`, `PuzzleCatalog`) independent of scenes and input.

## Evidence quality (read this before drawing conclusions)

- **One tester.** Every human observation so far comes from the designer, who
  knew the designs. No independent player has played any puzzle on record.
- Spec 009's human evidence is one aggregate session across six puzzles;
  per-puzzle detail was not recorded.
- Spec 010's Reference Knot playtest answered all fifteen questions with an
  unqualified yes, from a familiar tester.

## Open limitations and deferred work

- **SC-009 not performed.** Whether a first-time player finds the ArrowSpark
  Levels group unaided is untested. Deferred to the Web Showcase spec; protocol
  in `.devspark.work/specs/010-spec-reference-puzzle/deferred-to-next-spec.md`.
- **SC-005 not met against its original wording.** Amended with the original
  preserved. The roughly ten simultaneously obvious moves in the middle of the
  Reference Knot are an accepted limitation.
- Numeric on-screen cell size at tracing time was never captured (FR-008).
- Spec 010's desktop smoke test was not performed as a manual run (physical
  keyboard and gamepad, live scene changes, frame time).
- Spec 008's gamepad hardware check and some other scenarios were accepted as
  outstanding by its verify gate.
- **Touch is a beta.** Tap (on release), one-finger pan and pinch zoom exist but the modeless touch change (PR #8) has not been tried on a real device; pinch failed on the one real phone (Pixel 7 Pro) before it. iPhone Safari is admitted by capability but never verified. Controls are about 17 CSS px tall on the Pixel (44 px targets deferred), and in-game help still shows desktop wording.
- Flaky Godot first-import validation in CI (intermittent, passes on re-run); no work item yet.
- Saved progress is out of scope by design (see the session-memory boundary in
  README.md).
- The Reference Knot's order-independence check samples every sixth branching
  state, because the full check exceeds the launcher time limit.
- Framework note from the audit: planning ids must not escape into durable
  comments. PR #3 addressed the first round; keep checking.

## Automated gates

- `python tests/run_puzzle_regressions.py --godot <executable>`
- `python tests/run_regressions.py --godot <executable>`
- `godot --headless --editor --quit`, plus a desktop smoke test for gameplay
  changes.
- Non-gating: `python tests/run_puzzle_structural_report.py --godot <executable>`.

Failure markers that must report zero: `PUZZLE_FAILURES`,
`PUZZLE_ANALYZER_FAILURES`, `PUZZLE_CATALOG_FAILURES`,
`PUZZLE_SCOREBOARD_FAILURES`, `ARROW_DEPARTURE_GEOMETRY_FAILURES`,
`PUZZLE_VIEWPORT_FAILURES`, `PUZZLE_LAYOUT_FAILURES`, `PUZZLE_CANVAS_FAILURES`,
`PUZZLE_PRESENTATION_FAILURES` and `REGRESSION_FAILURES`. All were zero at the
PR #4 re-review (2026-10-01).

## Durable knowledge (`.knowledge/`)

Architecture: `arrow-puzzle`, `game-visual-system`, `save-progression`, `web-showcase`.
Product: `branding`, `gameplay-contract`. Reference: `gordian-knot-experiments`,
`reference-puzzle-design-report`, `touch-gestures`. Governance: `constitution`.

## Immediate Next Steps

1. Test the modeless touch change on a real phone (pinch is the open question).
2. Run the SC-009 fresh-player protocol with genuinely new players through the
   live site. The project's central risk is still a one-person evidence base.
3. Decide the next spec: touch ergonomics (44 px targets, in-game help) or
   something the first outside players surface.

## Product Direction

Do not add another scoring or progression system. The viewport constraint is
gone and the content question has a first answer. The open question is now
whether anyone but the designer finds the Reference Knot satisfying.
