# Current State --- 2026-09-28

## Branch / Completion State

Current feature branch:

`007-spec-open-move-scoring`

Spec 007 implementation is complete except for five manual desktop
checks.

The feature is therefore **not fully complete** and the spec correctly
remains:

`In Progress`

Nothing has been committed at this snapshot. Changes remain uncommitted
on the feature branch.

## Automated Status

The automated implementation is green.

### Godot

Headless editor check exits with code 0.

### Failure markers

All report zero: - `PUZZLE_FAILURES=0` - `PUZZLE_ANALYZER_FAILURES=0` -
`PUZZLE_CATALOG_FAILURES=0` - `PUZZLE_SCOREBOARD_FAILURES=0` -
`ARROW_DEPARTURE_GEOMETRY_FAILURES=0` - `PUZZLE_LAYOUT_FAILURES=0` -
`PUZZLE_PRESENTATION_FAILURES=0` - `REGRESSION_FAILURES=0`

The puzzle suite has been run repeatedly and passed.

The planning-references check is clean.

## Spec 007 Implementation

### Open Move Assist

`PuzzleState` now includes: - `find_open_move()`; -
`request_open_move()`; - `open_move_assists`.

Score:

`max(total_arrows - (mistakes + open_move_assists * 5), 0)`

### Session Scoring

New in-memory `PuzzleScoreboard`.

Responsibilities: - remember each puzzle's best completed score during
the running session; - calculate overall session score; - never touch
saved progress.

### UI

Added: - keyboard/gamepad-focusable **Show Me an Open Move** button; -
pulsing highlight for the selected open arrow; - assist count in
Results; - session-best comparison line; - overall session score.

### Knowledge

Added: - `.knowledge/product/gameplay-contract.md`

Updated: - `.knowledge/architecture/arrow-puzzle.md`

## Remaining Manual Desktop Checks

Tasks still open: - T009 - T017 - T023 - T032 - T035

These must be completed by a human at a real desktop following
`quickstart.md`.

T036 linkage confirmation cannot fully close until those manual checks
are complete.

## Recorded Implementation Deviations

### Keyboard/gamepad test

T012 verifies focus eligibility and signal wiring rather than simulated
headless key presses.

Reason: simulated key presses proved nondeterministic headlessly.

Real interaction remains a manual acceptance concern.

### Open Move highlight clearing

Highlight clears on: - any accepted selection; - a fresh attempt.

It does not clear merely on hover.

This is arguably a stronger semantic boundary: hover is presentation
exploration, while an accepted selection changes interaction state.

### Knowledge type correction

The knowledge index builder rejects `type: product`.

An existing `branding.md` used that type, which prevented index
regeneration.

The implementation changed: - `branding.md`; - new gameplay contract doc

to:

`authoritative-reference`

This was the only branding document change.

This should be considered a DevSpark schema/documentation improvement
candidate: either `product` should be a supported type or the allowed
types should be sufficiently explicit that agents do not invent
unsupported metadata.

### Test-only viewport ordering bug

A new end-to-end test encountered a test-ordering problem because
viewport sizing had not occurred yet.

The test was fixed.

No production code changed for this issue.

## Immediate Next Steps

1.  Run the five manual desktop checks.
2.  Record results.
3.  Run `/devspark.implement` to finish linkage and close remaining
    implementation bookkeeping.
4.  Set Spec 007 to `Complete` only after checks pass.
5.  Run `/devspark.create-pr`.
6.  Review/merge according to normal DevSpark workflow.
7.  Begin Spec 008 planning/specification for the large zoomable puzzle
    canvas.

## Manual Review Emphasis

Beyond pass/fail mechanics, pay attention to: - whether Open Move is
easy to reach with keyboard/gamepad; - whether the highlight is obvious
but not obnoxious; - whether the five-point-equivalent cost is
understandable; - whether attempt score vs. session best vs. overall
score is immediately comprehensible; - whether replay feels like mastery
rather than recovery from failure.

## Current Product Direction After 007

The next work should not add another scoring/progression system.

The next constraint to remove is physical board size.

Spec 008 should make puzzle dimensions independent of screen dimensions
through: - zoom; - pan; - Fit Puzzle; - robust coordinate transforms; -
off-screen Open Move reveal; - departure-animation compatibility.

After that, the project should return to content research with large,
long-tail, geometrically entangled puzzles.
