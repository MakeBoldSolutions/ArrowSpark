# Design Principles and Settled Decisions

## Product

### DP-001 --- Completion is always available

Mistakes and assistance may reduce score but do not remove permission to
continue.

### DP-002 --- No lives/fail loop

No life counter, forced restart, waiting, ad-to-continue, or
payment-to-continue.

### DP-003 --- Solvability is content correctness

An unfinished puzzle with no legal move is defective content, not a
player failure.

### DP-004 --- Replay is mastery

Replay exists to improve a completed level's score.

### DP-005 --- Session is the memory boundary

Gameplay performance is remembered only in the running session.

### DP-006 --- No player identity

No profile, login, account, or persistent anonymous identity.

### DP-007 --- Assistance shows one open move

It does not solve, auto-play, or claim optimality.

### DP-008 --- Assistance is costly but unlimited

Open Move costs five mistake-equivalents and remains separately counted.

## Puzzle Design

### DP-009 --- Geometry matters

Arrow paths are part of the puzzle, not merely decoration.

### DP-010 --- Prefer meaningful geometric density

Do not rely on raw arrow count to create challenge.

### DP-011 --- Long tails create reward

Removing substantial geometry should visibly simplify the board.

### DP-012 --- Single-cell arrows are punctuation

They may be useful, but should not dominate dense advanced boards.

### DP-013 --- Gordian-knot metaphor

The player should feel they are finding and pulling loose threads from a
knot.

### DP-014 --- Hard to understand, never impossible to finish

Difficulty should come from seeing relationships.

## Architecture

### DP-015 --- PuzzleDefinition owns authored geometry

No viewport or player-state concerns.

### DP-016 --- PuzzleState owns rules

No duplicate blocker/legal-move logic in UI.

### DP-017 --- Solver is independent

Gameplay controller does not become solver authority.

### DP-018 --- Analyzer is descriptive

Analyzer metrics do not automatically equal human difficulty.

### DP-019 --- Logical removal precedes visual departure

Animation does not delay rule-state updates.

### DP-020 --- Session scoreboard is not persistence

Do not route it through inherited save infrastructure.

### DP-021 --- Camera/view state is presentation state

Proposed Spec 008 must keep zoom/pan out of logical puzzle authorities.

## Development Process

### DP-022 --- Human playtesting can overturn metrics

Spec 006 is the canonical example.

### DP-023 --- Automate reliable facts

Do not replace real interactive testing with flaky simulated input.

### DP-024 --- Specs are temporary

Durable truth belongs in code, tests, and current knowledge.

### DP-025 --- Do not build the generator before understanding good puzzles

Generation is downstream of design evidence.

## Explicit Non-Decisions

The following remain open future product choices: - persistent
progress; - profiles; - leaderboards; - achievements; - monetization; -
daily puzzle systems; - cloud sync; - competitive ranking; - procedural
generation strategy.

They should not leak into current architecture by assumption.
