---
id: gameplay-contract
type: authoritative-reference
title: ArrowSpark Core Gameplay Contract
appliesTo:
  - scripts/puzzle/puzzle_state.gd
  - scripts/puzzle_scoreboard.gd
  - scenes/puzzle/puzzle_results.gd
  - scenes/puzzle/puzzle_results.tscn
---

# ArrowSpark Core Gameplay Contract

ArrowSpark challenges the player to see the solution, never to earn permission
to continue playing. This document states the resulting behavioral contract
and its architectural consequences; the product principles it captures are
not scattered through implementation comments.

## Mistakes cost score, not play

Hard is good. Being stuck is okay. Unsolvable is not. Attempting to remove a
blocked arrow is normal gameplay: the arrow stays, the attempt continues
immediately, and the mistake reduces the attempt's score, never the player's
ability to keep playing. There is no attempt limit and no life system.
Completion is expected of every playable puzzle; only efficiency is scored.

This is possible because the puzzle rules are monotonic (see
`.knowledge/architecture/arrow-puzzle.md`'s Rule Layer): every unfinished,
valid puzzle always has at least one legal move. An unfinished playable
puzzle with none is defective content, never a player failure.

## If you cannot see an open move, ArrowSpark can show you one

"Show Me an Open Move" answers exactly one question — "show me one arrow
that can leave right now" — using the same legal-move rules that govern
normal play (`PuzzleState.find_open_move()`/`request_open_move()`). It never
solves the puzzle, never reveals a sequence, and never claims optimality. The
player must still select the identified arrow themselves. Because the rules
are monotonic, any arrow it identifies is always safe to take. Using it costs
five times a mistake's score penalty, tracked as a separate `open_move_assists`
count so `7 mistakes + 2 assists` and `17 mistakes` remain distinguishable
even though their score penalty is equal.

## The session is the current gameplay-memory boundary

ArrowSpark remembers a completed attempt's score, and the best score reached
per puzzle, only for the currently running game session. A session begins
when the application starts and ends when it ends or reloads. There is
currently no cross-session persistence of gameplay performance: no save-file
entry, no player profile, no anonymous persistent identity, no account. The
persistent unit today is nothing — gameplay performance ends with the
session. If durable player progression is ever wanted, that is a separate
future product decision, not an incremental extension of this contract.

## Replay is for improving a level's score, not recovering from failure

A player is never told "you lost," told to wait, or asked to pay/watch an ad
to continue. Replay exists for one purpose: beat this puzzle's own
session-best score. Each replay is a completely fresh attempt (mistakes,
assists, and score all reset); a worse or tied replay never lowers the
puzzle's session-best or the overall session score, and a better replay
raises both by exactly the improvement (`PuzzleScoreboard`, see
`.knowledge/architecture/arrow-puzzle.md`'s Open Move Assistance and Session
Scoring section). The overall session score answers only "how well have I
done across the levels I've played this session" — it is not a ranking,
rating, or leaderboard, and none is planned as an extension of it.
