# Current State --- 2026-10-01

## Summary

| Spec | State |
|---|---|
| 001--007 | **Complete.** Rules, visuals, departure, catalog, analysis, Open Move and session scoring. |
| 008 Large Zoomable Puzzle Canvas | **Complete.** Merged as PR #1 (`faa4575`). |
| 009 Gordian Knot Experiments | **Complete.** Merged as PR #2 (`8a00239`). |
| 010 Reference Puzzle and Level Groups | **Complete, with documented limitations.** Merged as PR #4 (`6e60e11`). |
| Next | **Not yet specified.** Expected: Web Showcase & Playtest. See [13-roadmap-008-010.md](13-roadmap-008-010.md). |

## Repository State

- Branch `main` at `6e60e11`, working tree clean, 91 commits. No active feature
  branch.
- Repository: https://github.com/MakeBoldSolutions/ArrowSpark (local directory
  `ArrowGame`). Four merged PRs: #1 (008), #2 (009), #3 (audit follow-up), #4
  (010).
- Stack: Godot 4.4 target, GDScript, Maaack's Game Template. Python 3.11+
  launchers. Validation has also been run on Godot 4.7.2.
- Constitution 2.0.1. BSW.DevSpark 7.7.1 at the last audit.

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
- Touch input does not exist. Deferred from 008, now due with the Web build.
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

Architecture: `arrow-puzzle`, `game-visual-system`, `save-progression`.
Product: `branding`, `gameplay-contract`. Reference: `gordian-knot-experiments`,
`reference-puzzle-design-report`. Governance: `constitution`.

## Immediate Next Steps

1. Run the post-010 checkpoint in [13-roadmap-008-010.md](13-roadmap-008-010.md).
2. Specify the Web Showcase & Playtest spec, carrying the SC-009 protocol and
   touch input with it.
3. Recruit genuinely new players through that channel. The project's central
   risk is a one-person evidence base.

## Product Direction

Do not add another scoring or progression system. The viewport constraint is
gone and the content question has a first answer. The open question is now
whether anyone but the designer finds the Reference Knot satisfying.
