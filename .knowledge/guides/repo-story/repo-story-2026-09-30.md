# Repository Story: ArrowGame (ArrowSpark)

> Generated 2026-09-30 | Window: 12 months (history covers 4 days) | Scope: full

## Executive Summary

ArrowSpark is a puzzle game, built in Godot 4.4 (GDScript) on top of Maaack's Game Template, in which the player clears a board of arrows. Each arrow points in one of four directions and slides off the board along its own path. Blocked arrows cost score but never trap the player, and every puzzle is guaranteed to have a legal move. The repository is published as `MakeBoldSolutions/ArrowSpark`; the local folder is named ArrowGame.

The whole history is compressed into a very short window. The repository holds **70 commits** from **2026-09-26 10:41** ("Initial project from Godot game template") to **2026-09-29 21:07** — `history_span_days` is 3, and all 70 commits fall in a single calendar month. Commits per day were 34, 15, 11 and 10, so the pace tapers from an intense bootstrap burst to a steady rhythm of roughly ten commits a day. Only one prior-year baseline month was requested (2025-09) and it has no data, so no baseline comparison is possible.

Delivery is organised as numbered feature specs. Nine are complete (001–009) and a tenth, the ArrowSpark Reference Puzzle, was just specified in the two most recent commits. Between them the specs delivered a first playable puzzle, multi-arrow solvability, continuous arrow visuals, path-following departure, a multi-puzzle catalog with Level Select, a structural puzzle analyzer, Open Move assist with session scoring, a large zoomable canvas, and six "Gordian Knot" experimental puzzles.

Governance is unusually strong for a project this young. There is a versioned constitution (v2.0.1, six principles), **38 of 70 commits (54%)** use conventional-commit prefixes, **10** reference a spec, **3** work landed through GitHub pull requests (#1–#3), and CI runs both regression launchers on every push and PR to `main`. There are no tags or releases yet, so there is no formally versioned delivery evidence; the specs and merges are the milestones.

## Technical Analysis

### Development Velocity

- **70 commits in 4 calendar days** (2026-09-26 to 2026-09-29): 34 / 15 / 11 / 10 commits per day. Front-loaded, then steady.
- The eight largest merges are the real throughput signal, and they are large:
  - Spec 009 Gordian Knot experiments (PR #2): 56 files, +21,197 / −39
  - Continuous arrow visuals: 121 files, +14,491 / −50
  - Spec 008 large zoomable canvas (PR #1): 96 files, +8,135 / −158
  - Site-audit chore (PR #3): 11 files, +7,079 / −68
  - Spec 002 multi-arrow solvability: 131 files, +5,135 / −22
  - Spec 005 multiple puzzles: 57 files, +3,288 / −75
  - Spec 007 open move scoring: 55 files, +3,307 / −41
  - Spec 004 path-following departure: 46 files, +2,399 / −88
- Additions dwarf deletions in every large merge (the largest is 21,197 added against 39 removed). That is a **greenfield, additive** profile with low churn: little is being rewritten. Much of the volume is documentation, evidence and generated assets rather than gameplay code (see file types below).
- Commit subjects classify as: 34 features, 14 tests, 5 docs, 5 fixes, 3 refactors, 1 chore, 1 CI/build, 7 other. Features plus tests make up about 69% of classified work.
- No baseline comparison: `compare_baseline` (2025-09) predates the repository.

### Contributor Dynamics

- Two roles appear in `contributor_census`: **Lead Architect (69 commits, 98.6%)** and **Developer A (1 commit)**. The single Developer A commit is the merge of PR #1.
- **Bus factor is effectively 1.** One person authored 98.6% of the history. The only other identity is a merge-commit committer.
- The "team" did not grow over the window; the project is best read as a solo-developer journey with heavy tool-assisted (spec-driven) leverage.

### Quality Signals

- **33 test files** exist and **41 of 70 commits (59%)** touch tests. Tests are GDScript headless checks (for example `puzzle_regression.gd`, `puzzle_catalog_check.gd`, `puzzle_analyzer_check.gd`, `puzzle_scoreboard_check.gd`, `puzzle_canvas_check.gd`, `save_input_regression.gd`) driven by Python launchers.
- The count of 33 includes each check's `.uid` sidecar, so the number of distinct test scripts is smaller (about 17). Read the ratio as a rough signal.
- **Conventional commits: 38 of 70 (54%)**; informal-commit count reads 0, so the other 32 are non-prefixed but descriptive (e.g. "Add PuzzleAnalyzer tests and structural report"). Prefix diversity in use: `feat`, `fix`, `docs`, `chore`, `test`, `spec`, `branding`.
- Commit messages are descriptive and often carry spec or task context ("generate tasks.md for Spec 005 (26 tasks, 3 user stories)").

### Governance & Process Maturity

- **Merge/PR workflow**: 3 merged GitHub PRs (#1 Spec 008, #2 Spec 009, #3 site-audit chore). Earlier specs (002, 004, 005, 007) merged through local branch merges into `master`; from PR #1 on, work goes through GitHub PRs. That is a visible maturing of process within four days.
- **Branch strategy**: one branch per spec, named `NNN-spec-<slug>` (e.g. `009-spec-gordian-knot-experiments`, `010-spec-reference-puzzle`); a chore branch for audit follow-ups.
- **Tags**: 0. No release discipline yet.
- **Constitution**: present, v2.0.1, 0 recorded amendments in the window.
- **CI**: GitHub Actions workflow `godot-regression-tests.yml` runs both launchers on push and PR to `main`.
- **Verification gates**: specs carry analyze, critic and verification gate reports (e.g. `gates/critic.md`, `gates/verification.md`), and there are a knowledge-integrity validation script and regression/structural audit logs.

### Architecture & Technology

- **Stack**: Godot 4.4 / GDScript, Maaack's Game Template addon (MIT), Python 3.11+ headless launchers, PowerShell and shell scripts for DevSpark tooling. `technical_signals` reports Python, PowerShell, shell and Markdown present; no `package.json`, `pyproject.toml` or Dockerfile; GitHub Actions present.
- **Layering**: rules live in RefCounted domain classes under `scripts/puzzle/` (`PuzzleDefinition`, `PuzzleState`, `PuzzleSolver`, `PuzzleAnalyzer`, `PuzzleCatalog`, `PuzzleScoreboard`) independent of scenes and input; presentation is in `scenes/puzzle/`. This boundary is stated in `CLAUDE.md` and `AGENTS.md`.
- **File-type mix of touched files**: `.md` 674, `.gd` 209, `.png` 145, `.uid` 138, `.tscn` 127, `.json` 37, `.ps1`/`.py`/`.sh` 36 each. Documentation touches outnumber GDScript touches roughly 3 to 1, reflecting the spec-driven workflow and the DevSpark framework files.
- **Knowledge base**: `.knowledge/` holds current architecture, product and governance docs, with an `index.json` and ontology coverage file.

## Change Patterns

Top hotspots by number of commits touching the path:

| Rank | File | Changes | What it suggests |
|---|---|---|---|
| 1 | `.knowledge/index.json` | 14 | Index refreshed nearly every feature; expected for a registry |
| 2 (tie) | `tests/puzzle_layout_check.gd` | 9 | Layout rules evolved with each puzzle/canvas spec |
| 2 (tie) | `tests/README.md` | 9 | Test docs kept in step with new checks |
| 2 (tie) | `tests/run_puzzle_regressions.py` | 9 | Central launcher grows with every new check |
| 2 (tie) | `.knowledge/architecture/arrow-puzzle.md` | 9 | Core architecture doc updated with each gameplay spec |

Next tier (6–7 changes): `.knowledge/architecture/save-progression.md`, `tests/save_input_regression.gd`, `scenes/puzzle/arrow_view.gd`, `scenes/puzzle/puzzle_board.gd`, `scenes/puzzle/arrow_puzzle.gd`.

Observations:

- Change concentration is in **tests and knowledge docs**, not just code. The test launcher and layout check are the natural places new coverage lands, so they are churn hotspots by design rather than instability.
- The presentation trio (`arrow_view.gd`, `puzzle_board.gd`, `arrow_puzzle.gd`) at 6 changes each is the gameplay code hotspot. Those are the files most likely to be touched by the next feature and deserve the most test coverage.
- `.devspark.work/specs/*` files dominate the wider hotspot list, which is planning churn rather than product churn.

## Milestone Timeline

No git tags exist (`total_tags: 0`), so there are no formal releases. Spec completion serves as the delivery timeline:

| Date | Milestone | Evidence |
|---|---|---|
| 2026-09-26 | Project created from Godot game template | First commit |
| 2026-09-26 | Specs 001–004 (playable puzzle, multi-arrow solvability, continuous visuals, path-following departure) | Spec 004 closed out at 2026-09-27 00:40 |
| 2026-09-27 | Spec 005: puzzle catalog, Level Select, Next Puzzle | Merge `6aaf79d` |
| 2026-09-27 | Product branding hierarchy (ArrowSpark / Make Bold) | `316d09c` |
| 2026-09-27 | Spec 006: PuzzleAnalyzer, 8 → 14 catalog puzzles | `3bfc26f`, `207bc2e` |
| 2026-09-28 | Spec 007: Open Move assist and session scoring | Merge `f534691` |
| 2026-09-28 | Spec 008: large zoomable canvas (PR #1) | Merge `faa4575` |
| 2026-09-29 | Spec 009: six Gordian Knot experiments (PR #2) | Merge `8a00239` |
| 2026-09-29 | Site audit follow-ups (PR #3) | Merge `312b0c7` |
| 2026-09-29 | Spec 010 (Reference Puzzle) specified | `e5cc3cb`, `dd82a9b` |

Velocity does not spike before merges so much as flow continuously: specification commits precede implementation commits within hours (for example Spec 005 was specified at 00:47, planned at 00:59, tasked at 01:01 and implemented by 08:50 on the same day).

## Constitution Alignment

The constitution (v2.0.1, `.knowledge/governance/constitution.md`) defines six principles. How well the history reflects them:

| Principle | Evidence in history | Alignment |
|---|---|---|
| I. Simple, Maintainable Code | Rules isolated in RefCounted domain classes; each spec extends existing classes (`PuzzleState`, `PuzzleCatalog`) rather than introducing a second engine | Strong |
| II. Prefer Project-Level Template Customization | `addons/maaacks_game_template/.../app_config.gd` changed 3 times; main menu scenes customised at the project level | Partial: some addon-level edits appear in the hotspot list |
| III. Accessible, Configurable Controls | Spec 005 commits explicitly cover keyboard/gamepad navigation and Level Select focus handling | Good |
| IV. Responsive Gameplay | Spec 004 (path-following departure) and Spec 008 (zoomable canvas) both carry visual/viewport tests | Good |
| V. Practical Gameplay Verification | 41 of 70 commits touch tests, 33 test files, two required regression launchers, CI on push/PR, manual visual acceptance recorded in Spec 004 close-out | Strong |
| VI. Preserve Saved Progress and Settings | `save_input_regression.gd` (7 changes) and `save-progression.md` (7 changes) are among the top hotspots; Spec 005 and 007 are explicitly session-only with no new persistence | Strong |

Gaps: no amendments recorded yet (0), and the constitution has no tag or version history to check drift against. Principle II is worth a review of the `app_config.gd` edits.

## Developer FAQ

### What does this project do?

ArrowSpark is a puzzle game where each arrow slides off the board along its own path. Blocked arrows cost score but never trap the player, and every playable puzzle always has a legal move. The game has a multi-puzzle catalog with Level Select, an "Show Me an Open Move" assist, session scoring, and a zoomable, pannable canvas for large puzzles. It is published by Make Bold Solutions under the "Make Bold Spark" brand.

### What tech stack does it use?

Godot 4.4 with GDScript, built on Maaack's Game Template (MIT, credited in `ATTRIBUTION.md`). Regression tests are headless Godot scripts launched by Python 3.11+ scripts. PowerShell and shell scripts support the DevSpark workflow. CI is GitHub Actions. There is no `package.json`, `pyproject.toml` or Dockerfile.

### Where do I start?

Read `README.md`, then `.knowledge/architecture/arrow-puzzle.md` (9 changes, one of the most-edited docs). The rule core lives in `scripts/puzzle/` (`PuzzleDefinition`, `PuzzleState`, `PuzzleSolver`, `PuzzleAnalyzer`, `PuzzleCatalog`, `PuzzleScoreboard`); the presentation lives in `scenes/puzzle/` (`arrow_puzzle.gd`, `puzzle_board.gd`, `arrow_view.gd`, each changed 6 times). `CLAUDE.md` and `AGENTS.md` describe project conventions.

### How do I run it locally?

Open the project in Godot 4.4 and run it, per the README's "Playing" section. `run-app` scripting was added in commit `bd61aa8`, but check the repo for its exact location before relying on it; I did not verify the script path.

### How do I run the tests?

Run both required headless gates:

```
python tests/run_puzzle_regressions.py --godot <path-to-godot>
python tests/run_regressions.py --godot <path-to-godot>
```

Gameplay changes additionally need Godot validation (`--headless --editor --quit`) and a desktop smoke test (constitution Principle V). CI in `.github/workflows/godot-regression-tests.yml` runs the launchers on every push and PR to `main`. Test descriptions are in `tests/README.md`.

### What is the branching/PR workflow?

One branch per spec, named `NNN-spec-<slug>` (currently `010-spec-reference-puzzle`), merged to the default branch via GitHub pull request. 3 PRs have been merged so far (#1, #2, #3); the earliest specs were merged locally. Note that git history shows local merges into `master` while the repository default is reported as `main`.

### Who do I ask when I'm stuck?

The Lead Architect role authored 69 of 70 commits (98.6%), so they are the primary source of context. Beyond that, the `.knowledge/` docs and each spec's `spec.md`, `plan.md` and `gates/` reports under `.devspark.work/specs/` capture intent and decisions.

### What areas of the code change most often?

1. `.knowledge/index.json` (14 changes)
2. The test suite: `tests/puzzle_layout_check.gd`, `tests/run_puzzle_regressions.py`, `tests/README.md` (9 each)
3. `.knowledge/architecture/arrow-puzzle.md` (9), followed by `scenes/puzzle/` view/board/puzzle scripts (6 each)

### Are there coding standards I must follow?

Yes. From `CLAUDE.md`: snake_case for new script filenames and functions (Godot-required names excepted), explicit types where they aid clarity, and small changes with justified new abstractions. 54% of commits use conventional prefixes (`feat:`, `fix:`, `docs:`, `chore:`), so follow that. The six constitution principles are binding for review. No linter or formatter configuration was detected in `technical_signals`.

### What version is currently released?

None. The repository has 0 tags. The latest commit is `dd82a9b` (2026-09-29, Spec 010 requirements), and the most recent completed feature is Spec 009 (Gordian Knot experiments, merged 2026-09-29 via PR #2).

---

Generated by /devspark.repo-story | BSW.DevSpark v1.6.0 — Adaptive System Life Cycle Development
