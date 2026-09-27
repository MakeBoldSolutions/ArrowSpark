# Verification Log — Spec 006

## Clean Baseline (T001) — before any code change

**Date**: 2026-09-27
**Engine**: Godot 4.4.1 (`Godot_v4.4.1-stable_win64.exe`, `/tmp/ArrowGame-Godot-4.4.1/bin/`) — matches the declared 4.4 baseline. A newer 4.7.2 executable is also available on this machine (via winget) but was not used, per the existing disclosed-not-skipped policy of preferring the declared baseline when available.

**Commands**:

```
python tests/run_puzzle_regressions.py --godot /tmp/ArrowGame-Godot-4.4.1/bin/Godot_v4.4.1-stable_win64.exe
python tests/run_regressions.py --godot /tmp/ArrowGame-Godot-4.4.1/bin/Godot_v4.4.1-stable_win64.exe
```

**Results** (exit 0 both):

- `PUZZLE_FAILURES=0`
- `PUZZLE_CATALOG_FAILURES=0`
- `ARROW_DEPARTURE_GEOMETRY_FAILURES=0`
- `PUZZLE_LAYOUT_FAILURES=0`
- `PUZZLE_PRESENTATION_FAILURES=0`
- `REGRESSION_FAILURES=0`

**Timing reference for T017**: full `run_puzzle_regressions.py` (all 5 checks combined) completed in ~18.1s wall-clock. This is a baseline reference point only — T017 measures the specific `run_rule_regressions()` step's timing after the catalog/analyzer expansion, against its own `timeout=45` (per-subprocess) budget, not this aggregate figure.

## T017 Post-Expansion Timing Measurement (US1)

**Date**: 2026-09-27, after implementing `PuzzleAnalyzer` (14 catalog puzzles not yet added — measured against the 8-puzzle catalog plus the new 14-case `puzzle_analyzer_check.gd` suite; the catalog will grow to 14 in US2, re-measured again in T034's final re-run).

**Method**: instrumented `run_rule_regressions()`'s `subprocess.run` calls with per-call wall-clock timing, run against the real 4-call sequence (`--editor --quit`, `puzzle_regression.gd`, `puzzle_analyzer_check.gd`, `puzzle_catalog_check.gd`).

**Result**: per-call times were `[4.28s, 0.27s, 0.28s, 0.27s]` — every individual call finishes in well under 5s against the existing `timeout=45` (seconds) **per-subprocess** budget. Headroom remains >85% on the slowest call (editor validation) and >99% on each script run.

**Decision**: per T017's instruction to measure rather than assume, and to prefer margin over tight tuning — **no change to `timeout=45` is needed**. The added workload (14-case analyzer suite, and later the 14-entry catalog in US2) consumes a small fraction of the existing per-call budget; bumping the timeout now would add unjustified slack rather than address a real risk. This will be re-verified in T034 (Polish phase) once the catalog itself reaches 14 entries, to confirm the conclusion still holds with the full expansion in place.

## T025 Experimental Puzzle Threshold Verification (US2)

**Date**: 2026-09-27. Each of the six new puzzles was constructed and run through `PuzzleAnalyzer.analyze()` (via a throwaway headless harness, not committed) before being added to `PuzzleCatalog`, per spec's Edge Cases ("if a candidate puzzle does not exhibit its intended property, revise before shipping").

| Puzzle (id) | Threshold (data-model.md Operational Acceptance Thresholds) | Measured | Result |
|---|---|---|---|
| `nested_chain` | `depth >= 3`, non-collinear `longest_chain` | depth=3, chain=[(4,0),(4,1),(0,1),(0,4)] | PASS |
| `cascade_key_arrow` | `max_unlock_fan_out >= 2` | 3 | PASS |
| `dense_unravel` | `density >= 0.55`, `initial_legal_ratio <= 0.50` | density=0.667, initial_legal_ratio=0.25 | PASS |
| `bent_network` | dependency edge involving a bent arrow's tail cell, >=2 bent arrows | bent_arrow_count=2; both edges' blocking cells are tail cells | PASS |
| `long_range_blocker` | `blocker_distance.edges[].distance >= 4` on a board `>=5` wide/tall | distance=7 on an 8-wide board | PASS |
| `composed_shaped` | `board.total_cells >= 49`, `edge_count >= 1` | total_cells=49 (7x7), edge_count=47 | PASS |

All six passed on the first authored design — no revision iteration was needed (contrast with the critic gate's own "Questionable Assumption" that the Composed/Shaped puzzle in particular might need several iterations; recorded here as a candidate observation for the Spec 006 findings summary, not asserted as fact until human playtesting confirms or contradicts it).

## T031 Developer Report Determinism (US3)

**Date**: 2026-09-27. `python tests/run_puzzle_structural_report.py --godot <executable>` run twice
back-to-back; `diff` of the two captured outputs reports **identical** (byte-for-byte, including
the Godot engine banner). Grepped for `difficulty|easy|medium|hard|star|tier` — zero matches. The
Catalog Comparison section correctly answers all nine FR-021 questions:

- deepest dependency chain: `composed_shaped` (depth=6)
- fewest initial legal arrows: `dependency_chain` (1/3)
- widest branching: `dense_board` (9)
- largest cascade: `cascade_key_arrow` (max_unlock_fan_out=3)
- longest forced run: `forced_sequence` (5)
- highest density: `dense_unravel` (0.67)
- most bends: `multi_bend` (3)
- longest blocker distance: `long_range_blocker` (7)
- largest board: `composed_shaped` (7x7, 49 cells)

## T034 Final End-to-End Regression Re-run (Polish)

**Date**: 2026-09-27. `python tests/run_puzzle_regressions.py --godot <executable>` and
`python tests/run_regressions.py --godot <executable>`, both exit 0:
`PUZZLE_FAILURES=0`, `PUZZLE_ANALYZER_FAILURES=0`, `PUZZLE_CATALOG_FAILURES=0`,
`ARROW_DEPARTURE_GEOMETRY_FAILURES=0`, `PUZZLE_LAYOUT_FAILURES=0`,
`PUZZLE_PRESENTATION_FAILURES=0`, `REGRESSION_FAILURES=0`. No regression against the T001
baseline; every pre-existing marker still passes with the same meaning, plus the new
`PUZZLE_ANALYZER_FAILURES=0`.

## T035 Negative-Requirement Verification (Polish)

**Date**: 2026-09-27. Verified by inspection (FR-009, FR-010, FR-011, FR-023):

- `grep -riE "difficulty|easy.medium.hard|star_rating"` across
  `puzzle_analyzer.gd`/`puzzle_catalog.gd`/all new test files: every match is either a comment
  documenting the *absence* of difficulty scoring, or the pre-existing
  `_check_no_difficulty_labels()` test itself (unchanged in intent) — no composite score, formula,
  or player-facing rating exists anywhere.
- `git diff --stat scripts/puzzle/puzzle_solver.gd scripts/puzzle/puzzle_state.gd
  scripts/puzzle/puzzle_definition.gd`: **empty output** — all three files are byte-identical to
  their committed state. `PuzzleSolver`'s existing `analyze()` return contract and metrics
  semantics are untouched (FR-010); `PuzzleDefinition` gained no new fields (FR-011).
- `git status --short scripts/puzzle/`: confirms only `puzzle_catalog.gd` (extended) and the new
  `puzzle_analyzer.gd` were touched in that directory.
- No procedural/randomized generation exists anywhere: every new `PuzzleCatalog` entry is a
  literal, hand-authored `PuzzleDefinition` construction, identical in style to the existing eight
  (FR-023).

## T036/T037 Knowledge Update and Index Check (Polish)

**Date**: 2026-09-27. `.knowledge/architecture/arrow-puzzle.md` updated: `appliesTo` gained the
four new files; a new "Structural Analysis (PuzzleAnalyzer)" section documents boundaries, exact
metric definitions, dependency-graph orientation (including the cyclic depth/longest_chain
semantic), and the explicit objective-metrics-vs-perceptual-hypotheses distinction; the catalog
section and its stale "eight" references updated to fourteen throughout.

`python .devspark/scripts/build_knowledge_index.py --repo-root . --check` fails, but on a
**pre-existing, unrelated** issue: `.knowledge/product/branding.md` (type: `product`) is not in
the script's `ALLOWED_TYPES` set. Verified this predates Spec 006 entirely — this branch's
merge-base with `master` is commit `316d09c`, the exact commit that introduced `branding.md`, and
`build_knowledge_index.py` is untouched on this branch (`git diff --stat` empty). Confirmed
`arrow-puzzle.md`'s own frontmatter passes `validate_current()` cleanly in isolation (ran the
function directly against the file). Disclosed rather than silently fixed: correcting
`branding.md`'s knowledge type (or the script's allowlist) is a product/governance concern outside
Spec 006's scope (puzzle structural analysis), not something this spec's implementation should
alter incidentally.

## Finalize: Planning-Reference Backstop (`check-planning-references.sh`)

**Date**: 2026-09-27. First run surfaced 3 real findings (after fixing an unrelated xargs/apostrophe
script quirk triggered by an apostrophe inside one task's own `knowledge_ref` annotation text):

- `CLAUDE.md` referenced the current branch name 3 times (Active Technologies, Project Structure
  example path, Recent Changes entry).
- `scripts/puzzle/puzzle_catalog.gd:205` contained a leaked `FR-012` reference in a code comment.

Both fixed by rewording to describe behavior/content rather than citing the branch name or an
FR-### id. A broader sweep (`grep` across every new/changed file) additionally found `FR-###`
references and one literal `.devspark.work/...` path baked into doc-comments across
`puzzle_analyzer.gd`, `puzzle_analyzer_check.gd`, `puzzle_structural_report.gd`,
`run_puzzle_structural_report.py`, `tests/README.md`, and (most importantly, since it is durable
knowledge) `.knowledge/architecture/arrow-puzzle.md`'s several "Spec 006" mentions — all reworded
to describe the architecture/behavior directly, with no spec/task/branch identifier. Four
pre-existing `FR-###` comments in `tests/puzzle_catalog_check.gd` (lines 17/48/63/86) predate this
branch (confirmed via `git diff`, not part of this feature's changes) and were left untouched —
`tests/` is deliberately excluded from the script's default (non-`--include-tests`) scope for
exactly this kind of pre-existing content, and fixing spec 005's own prior comments is out of this
spec's scope.

Final re-run: `bash .devspark/scripts/bash/check-planning-references.sh` → `No planning-artifact
references found.` (exit 0). `--include-tests` (the stricter audit pass) confirms zero findings in
any file this spec added or touched.

## T032/T033/T039 — Real Human Play Session (US3 completion)

**Date**: 2026-09-27. Launched the actual game non-headlessly (`Godot_v4.4.1-stable_win64.exe
--path .`) so the tester (Mark Hazleton) could play directly. All six new experimental puzzles were
played via Level Select. Full observations recorded in `calibration/records.md` and synthesized in
`calibration/findings-summary.md`.

**Headline result**: every puzzle hit its analyzer-confirmed structural target, but perceived
challenge was rated 2/5, scanning load "low," and the confirmed fan-out-3 cascade produced no felt
"aha" moment. Tester's diagnosis: too many single-cell arrows; real challenge would come from
"tightly coupled longer arrows of varying lengths." This is a genuine, valuable negative finding —
exactly the kind of evidence Spec 006 exists to surface before any generator is designed.

**Save-data check**: the real (non-isolated) `global_state.tres` under
`app_userdata/ArrowSpark/` was inspected before/after the session.
`last_unix_time_opened` updated (expected template behavior — every launch records this), but
`states = {}` remained empty and `first_version_opened`/`last_version_opened` unchanged — confirming
the no-reset guarantee held (no level-progression data written or reset) even though the session
ran against real save storage rather than an isolated temp directory.

**quickstart.md status**: steps 1-6 (automated) fully covered by the records above. "Desktop visual
and input acceptance" is now covered for general play (all six puzzles completed, confirmed good
scoring/gameplay/performance). **Disclosed, not tested**: this session used mouse/keyboard general
play, not specifically keyboard-only or gamepad-only navigation through Level Select — that
narrower check (constitution Principle III) remains an outstanding manual verification, consistent
with this project's disclosed-not-skipped policy for hardware-dependent checks.
