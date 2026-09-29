# Spec 008 Summary — Large Zoomable Puzzle Canvas

**Status**: Complete (merged via PR #1, 2026-09-28)
**Branch**: `008-spec-large-zoomable-canvas`
**Type**: full-spec, high risk, customer-facing, brownfield

## What we set out to do

The existing presentation always fit the entire board into the visible screen area, so larger
authored puzzles just produced smaller arrows instead of a larger world to explore. Spec 008
separated four concepts that had been conflated — **board size** (authored dimensions),
**geometric density** (arrow count/complexity), **viewport** (visible region), and **zoom**
(visual scale) — and added bounded zoom, pan, and an explicit **Fit Puzzle** action as transient
presentation capabilities, without letting camera concepts leak into rule, solving, analysis, or
scoring authorities.

## What was accomplished

- **New presentation authority**: `PuzzleViewportTransform`
  ([scripts/presentation/puzzle_viewport_transform.gd](../../../scripts/presentation/puzzle_viewport_transform.gd))
  became the single place that maps logical grid ↔ board-local visual ↔ viewport/screen
  coordinates, with the transform math unit-tested independent of scene/rendering.
- **Zoom, pan, and Fit Puzzle** implemented in `puzzle_board.gd` and `arrow_puzzle.gd`/`.tscn`,
  reachable via mouse (wheel, drag), keyboard (WASD/Equal/Minus/F), and gamepad (event-dispatch
  tested), all coexisting with the existing configurable-input system.
- **Off-screen Open Move reveal**: requesting help now brings an off-screen legal target into
  view without changing its existing deterministic-target, single-cost, no-removal contract.
- **Departures remain correct under navigation**: long bent-arrow departures keep their authored
  route and progress through zoom/pan/resize, complete exactly once on full logical clearance
  (not viewport clipping), and results/session-best updates still fire on the existing barrier.
- **Transient-only viewport state**: no camera/zoom/pan state is persisted; every replay, puzzle
  change, or new attempt gets a fresh Fit Puzzle overview. Existing saves/settings/remaps are
  untouched (confirmed by storage checks).
- **New validation content**: puzzle 15, a 52-arrow fixture with long bent geometry, added to the
  catalog specifically to exercise both-axis overflow, long departures, and off-screen assistance
  at working scale — catalog grew from 14 to 15 entries.
- **Level Select fix found along the way**: at 960×540 the 15-entry list clipped its first/last
  entries; fixed with a focus-following `ScrollContainer` in `puzzle_select_menu.tscn`.
- **Test coverage added**: `tests/puzzle_canvas_check.gd` (headless behavioral suite, ~1175
  lines), `tests/puzzle_viewport_transform_check.gd` (pure math unit tests), and
  `tests/puzzle_canvas_visual_check.gd` (non-headless rendered-capture + performance probe), all
  wired into `run_puzzle_regressions.py` as new markers (`PUZZLE_VIEWPORT_FAILURES`,
  `PUZZLE_CANVAS_FAILURES`).
- **Knowledge updated**: `.knowledge/architecture/arrow-puzzle.md`,
  `.knowledge/architecture/game-visual-system.md`, and
  `.knowledge/architecture/save-progression.md` now document the viewport/navigation model as
  current architecture.

## Verification results

- Both required regression gates (`run_puzzle_regressions.py`, `run_regressions.py`) passed with
  zero failures on Godot 4.4-stable (declared target) and 4.7.2 (supplementary), each run twice on
  fresh mirrors.
- Performance measured on the 52-arrow fixture with 8 overlapping departures:
  `handler_p95_ms=0.091`, `frame_p95_ms=17.11`, `longest_frame_ms=19.9` — within the declared
  budget (handler ≤ 2.0 ms, frame p95 ≤ 33.3 ms, no frame ≥ 100 ms).
- Critic gate: full re-run after remediation, zero showstoppers/criticals/highs, verdict PROCEED.
- Verify gate: `warn` — end-to-end mode passes on automated + operator evidence, but several
  scenarios were explicitly accepted as outstanding rather than claimed passed (see below).

## What was left outstanding (disclosed, not swept under the rug)

- **Gamepad**: no physical device was available; gamepad zoom/pan/fit/focus-exit is covered only
  by event-dispatch tests, not real hardware.
- **Several operator sub-scenarios not explicitly re-confirmed**: blocked-feedback re-check after
  the color/hold-time change, pause/resume mid-departure, results/Replay/Next view reset, settings
  remap of a zoom action, minimize/restore, and Level Select scrolling at 1920×1080.
- These gaps were reviewed by the operator, who chose to close the spec anyway rather than block
  on hardware/time that wasn't available — a deliberate accept-with-disclosure decision, not an
  oversight.

## Lessons learned

1. **Godot 4.4 headless launch order matters and isn't a product bug.** A fresh project's
   headless `--import` intermittently crashes (access violation), and running
   `--editor --quit` against a project with a stale `.godot/` cache produces `SceneLoader` parse
   errors that poison later runs. The reliable sequence — fresh mirror, `--editor --quit` first,
   *then* the test launchers — should be the default recipe for any future spec that needs to
   validate against the 4.4 target while day-to-day development runs on 4.7.2.
2. **Separating "what changed" from "what's proven" earns trust.** The critic and verify gates
   explicitly distinguish agent-run rendered checks (informational only), automated regression
   evidence, and human operator sign-off — and the operator's own outstanding items (gamepad,
   several sub-scenarios) were recorded as accepted gaps rather than silently marked "pass." This
   discipline (constitution Principle V: disclose, do not claim) is worth continuing on future
   high-risk specs.
3. **A single presentation transform authority avoided authority leakage.** By concentrating
   coordinate mapping in `PuzzleViewportTransform` and keeping it decoupled from rendering, the
   team could unit-test the math (grid ↔ visual ↔ viewport) without needing a live scene tree,
   while `PuzzleState`/`PuzzleSolver`/`PuzzleAnalyzer`/`PuzzleScoreboard` needed zero changes —
   confirmed directly by the "identical logical inputs → identical solver/analyzer results
   regardless of view" acceptance check.
4. **Iterating on real content surfaced a real UI bug.** Adding puzzle 15 as validation content
   (not "difficulty tuning," per the spec's explicit scope guard) is what surfaced the Level
   Select clipping at 960×540 — a bug that abstract test fixtures wouldn't have found. Building at
   least one full-scale, player-facing fixture as part of feature validation continues to pay off.
5. **The critic gate's iterative remediation loop worked as designed.** Twelve prior findings
   (missing frontmatter fields, ambiguous fixture visibility policy, unstated Godot version
   precondition, etc.) were each resolved with a small, traceable planning-artifact edit before
   implementation started, rather than being discovered mid-build.

## Follow-up candidates (not committed, for future specs)

- Physical gamepad verification once hardware is available.
- Explicit operator re-pass on the disclosed outstanding desktop sub-scenarios (pause/resume
  mid-departure, Replay/Next view reset, settings remap flow, 1920×1080 Level Select).
- The critic's one "questionable assumption" flagged that keyboard/gamepad navigation to an
  Open Move target doesn't by itself guarantee keyboard-only *selection* of that target — noted
  as pre-existing and out of scope, but worth tracking for a future accessibility-focused spec.
