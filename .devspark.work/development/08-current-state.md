# Current State --- 2026-11-08

## Summary

| Spec | State |
|---|---|
| 001--007 | **Complete.** Rules, visuals, departure, catalog, analysis, Open Move and session scoring. |
| 008 Large Zoomable Puzzle Canvas | **Complete.** PR #1. |
| 009 Gordian Knot Experiments | **Complete.** PR #2. |
| 010 Reference Puzzle and Level Groups | **Complete, with documented limitations.** PR #4. |
| 011 Web Showcase | **Complete.** PR #5. Playable Web build, story site and reactions client at arrow.makeboldspark.com. |
| 012 Mobile Web Play | **Complete as a public beta.** PR #6 admitted touch landscape screens; PR #8 made touch modeless. |
| 013 Progression Pack | **Complete.** PR #9. World canvas (any board point can be centered), departure past the board edge, eight levels before the Reference Knot, New Game starts `first_knot`. |
| 014 Codebase Consolidation | **Complete.** PR #10. No behavior change, proven by a before/after probe of all 30 entries. |
| 015 Deferred follow-ups (quickfix) | **Complete.** PR #11. Failing gates show their FAIL lines, stale scan folder dropped, New Game tooltip corrected. |
| 016 Game UI Improvements | **Complete.** PR #13. Phone check closed 2026-11-08. App-wide Make Bold theme, screen scaling, branded launch, hero Main Menu, Level Select cards, motion and sound. |
| 017 Mobile Portrait Play | **Complete.** PR #14. Real-phone check closed 2026-11-08. Portrait admission, status on top, Menu/Open Move/Fit bottom strip, persistent Zoom and Pan buttons removed. |
| 018 Level Pack Engine | **Complete.** PR #16. Levels are JSON packs; seeded generator and pack-build tool; four-level Generated Levels sample. |
| Next | **Not yet specified.** See "Immediate Next Steps" below and [10-roadmap.md](10-roadmap.md). |

There is no folder or spec numbered 015 under `specs/`; it is the quickfix record in
`.devspark.work/quickfixes/015-fix-deferred-follow-ups.md`.

## Repository State

- Branch `main` at `1a1ee67`, 214 commits, level with `origin/main`. No active feature
  branch.
- Repository: https://github.com/MakeBoldSolutions/ArrowSpark (local directory
  `ArrowGame`). Sixteen merged PRs: #1--#6 and #8--#17. #3 was the audit follow-up;
  #12 and #15 were DevSpark framework updates; #17 was a site dependency audit fix.
- Stack: Godot 4.4 target, GDScript, Maaack's Game Template. Python 3.11+
  launchers. Astro and strict TypeScript for the showcase in `web/`.
- Constitution 2.3.0 (2026-10-14: defines the supported desktop browsers).
  BSW.DevSpark 9.5.1.

## Catalog: 34 puzzles in four groups

| Group | Count | Contents |
|---|---|---|
| ArrowSpark Levels | 9 | `first_knot` to `almost_a_knot` (9, 15, 14, 17, 23, 30, 68 and 93 arrows), then `reference_knot` (115 arrows on 46x32, density 0.92). |
| Foundations | 8 | The baseline set, from Simple Introduction to Subtle Blockers. |
| Puzzle Lab | 13 | Six structural experiments, `canvas_validation` (52 arrows, 40x30) and six Gordian Knot experiments. |
| Generated Levels | 4 | `gen_sample_01` to `gen_sample_04`; built by the generator, labelled an untuned first sample in the game. |

The table uses Level Select's presentation order. Every level lives in `levels/packs/*.json`,
listed in `levels/catalog.json`, and is read and audited by `PuzzlePackFormat`. Groups are
presentation metadata, stable ids are unchanged, numbering restarts in each group, and Next
Puzzle stays within the group and never wraps.

## What the game does today

- Multi-cell bent arrows leave along their own path and travel past the board edge before
  being removed; blocked selections count as mistakes.
- Open Move highlights one legal arrow for the cost of five mistakes.
  `score = max(total_arrows - (mistakes + open_move_assists * 5), 0)`.
- Session-only scoreboard: per-puzzle best and overall session score, never
  persisted. Only settings and input remaps persist.
- Zoom, pan and Fit Puzzle by mouse, keyboard, gamepad and touch. Any board point can be
  centered. View state is transient.
- Play controls are Menu, Open Move and Fit. In portrait on touch they form a bottom strip.
  Pan mode for single-button mice is inside the menu.
- Pure-RefCounted rule core (`PuzzleDefinition`, `PuzzleState`, `PuzzleSolver`,
  `PuzzleAnalyzer`, `PuzzleCatalog`, `PuzzlePackFormat`) independent of scenes and input.
  `PuzzleGenerator` is developer tooling and never runs in the game.

## Evidence quality (read this before drawing conclusions)

- **One tester.** The owner confirmed on 2026-11-08 that they are the only person who has
  tested the game so far. SC-009 has not been run, and there are no outside reactions to analyze.
- Spec 009's evidence is one aggregate session across six puzzles. Spec 013's evidence is one
  aggregate note across eight levels.
- Spec 010's Reference Knot playtest answered all fifteen questions with an
  unqualified yes, from a familiar tester.

## Open limitations and deferred work

- **Real-phone evidence is one device.** Owner reported on 2026-11-08: played on the Pixel in portrait and landscape; marked complete at the owner's direction. Browser and per-scenario observations were not supplied. This closed the open intake item and the
  phone clauses of Specs 016 and 017.
- **SC-009 not performed.** Whether a first-time player finds the ArrowSpark Levels group
  unaided is untested.
- **SC-005 not met against its original wording.** Amended with the original preserved.
- **iPhone Safari is admitted by capability and has never been run.** Modeless touch is
  verified only on one Pixel 7 Pro in Chrome (recorded 2026-10-14).
- Edge is inside the supported Chromium set but has not been tested individually. Safari on
  desktop is outside the set.
- The generator is not tuned. Its four samples are shown to be valid and solvable, nothing more.
- Numeric on-screen cell size at tracing time was never captured (FR-008).
- Spec 010's desktop smoke test was not performed as a manual run. Spec 008's gamepad hardware
  check was accepted as outstanding.
- Flaky Godot first-import validation in CI (signal 11, passes on re-run); no work item yet.
  Azure Static Web Apps' staging-environment limit can also break PR previews.
- Saved progress is out of scope by design.
- The Reference Knot's order-independence check samples every sixth branching state, because
  the full check exceeds the launcher time limit.
- Keep checking that planning ids do not escape into durable comments.

## Automated gates

- `python tests/run_puzzle_regressions.py --godot <executable>`
- `python tests/run_regressions.py --godot <executable>`
- `godot --headless --editor --quit`, plus a desktop smoke test for gameplay
  changes; web builds also need a browser smoke test.
- Non-gating: `python tests/run_puzzle_structural_report.py --godot <executable>`.
- Pack rebuild check: `python tests/run_level_pack_build.py --godot <exe> --recipe levels/recipes/<pack>.json --check`.

Failure markers that must report zero: `PUZZLE_FAILURES`, `PUZZLE_ANALYZER_FAILURES`,
`PUZZLE_CATALOG_FAILURES`, `PUZZLE_PACK_FORMAT_FAILURES`, `PUZZLE_GENERATOR_FAILURES`,
`PUZZLE_SCOREBOARD_FAILURES`, `ARROW_DEPARTURE_GEOMETRY_FAILURES`, `PUZZLE_VIEWPORT_FAILURES`,
`PUZZLE_LAYOUT_FAILURES`, `PUZZLE_CANVAS_FAILURES`, `PUZZLE_PRESENTATION_FAILURES`,
`APP_THEME_FAILURES`, `PORTRAIT_MENU_FAILURES` and `REGRESSION_FAILURES`. All fourteen were zero,
with 8,306 PASS lines, in the CI run on `1a1ee67` (2026-11-08). That run was read from the CI log,
not repeated locally.

## Durable knowledge (`.knowledge/`)

Architecture: `arrow-puzzle`, `game-visual-system`, `save-progression`, `web-showcase`.
Product: `branding`, `gameplay-contract`. Reference: `gordian-knot-experiments`,
`progression-design-learning`, `reference-puzzle-design-report`, `touch-gestures`.
Governance: `constitution`.

## Story status

The site has twelve chapters, all published as of 2026-11-08. Part 9 covers Spec 011, Part 10
Spec 012, Part 11 Specs 013--018, and Part 12 is the closing chapter.

## Immediate Next Steps

1. Run the SC-009 fresh-player protocol with genuinely new players through the live site.
   The project's central risk is still a one-person evidence base.
2. Decide what the generator should optimize, which depends on step 1.

## Product Direction

Do not add another scoring or progression system. The content pipeline now exists, so the
limit on more levels is no longer authoring cost. The open question is still whether anyone
but the designer finds them satisfying.
