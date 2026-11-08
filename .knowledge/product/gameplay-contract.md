---
id: gameplay-contract
type: authoritative-reference
title: ArrowSpark Core Gameplay Contract
appliesTo:
  - scripts/puzzle/puzzle_state.gd
  - scripts/puzzle_scoreboard.gd
  - scripts/player_profile.gd
  - scenes/menus/main_menu/profile_menu.gd
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

## The player profile is the gameplay-memory boundary

ArrowSpark remembers a player's results in a profile that lives on their own
device (`PlayerProfile`): a name they choose, the levels they have finished,
their best result on each, and simple play counts (attempts finished, mistakes
and Open Move assists, summed). Closing the game or reloading the page keeps all
of it, so a returning player keeps their place and their best scores, and
Continue opens the level after the one they most recently finished.

The profile needs no sign-in and sends nothing anywhere: it is stored only in
the game's own device storage (the browser's storage on the Web), is not part of
settings or of the template's legacy save, and there is exactly one per device.
It does not follow the player to another device or browser, clearing the
browser's site data removes it, and the player can delete it from the Profile
screen. There is still no account, no persistent identity and no network call
about play. A server-side account, comparing players or tracking play are
separate future product decisions, not extensions of this contract.

Only a finished attempt is remembered. Abandoning an attempt records nothing,
and an unfinished board is never saved, so a reload mid-attempt starts that
level again. The overall score is the sum of the best score on each finished
level; it is not a ranking, rating or leaderboard.

A best result belongs to the board it was earned on. If a puzzle's geometry
later changes, the old best no longer counts and is replaced by the next finish.

## Replay is for improving a level's score, not recovering from failure

A player is never told "you lost," told to wait, or asked to pay/watch an ad
to continue. Replay exists for one purpose: beat this puzzle's own
best score. Each replay is a completely fresh attempt (mistakes,
assists, and score all reset); a worse or tied replay never lowers the
puzzle's best or the overall score, and a better replay raises both by exactly
the improvement (`PuzzleScoreboard` compares against the saved best, see
`.knowledge/architecture/arrow-puzzle.md`'s Open Move Assistance and Session
Scoring section). The overall score answers only "how well have I done across
the levels I've finished" — it is not a ranking, rating, or leaderboard, and
none is planned as an extension of it.
