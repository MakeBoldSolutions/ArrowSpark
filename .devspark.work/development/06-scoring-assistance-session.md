# Scoring, Assistance, Replay, and Session State

## Purpose

Spec 007 formalizes ArrowSpark's relationship with mistakes, assistance,
mastery, and memory.

The design deliberately avoids turning difficulty into permission.

## Attempt Scoring

The current completed-attempt formula is:

`score = max(total_arrows - (mistakes + open_move_assists * 5), 0)`

Properties: - a perfect run scores `total_arrows`; - each blocked
attempt costs one point; - each Open Move assist costs five points; -
score cannot become negative; - a zero score does not prevent
completion.

This formula was deliberately kept simple even though small puzzles can
reach zero quickly after assistance.

That is acceptable because the score represents efficiency, not access.

## Mistakes

A mistake occurs when the player attempts a blocked arrow.

Behavior: - arrow remains; - mistake count increments; - play continues
immediately; - there is no limit.

Mistakes are exploratory feedback.

## Show Me an Open Move

The assist answers:

> "Show me one arrow that can leave right now."

It does not answer: - "What is the best move?" - "What sequence solves
the puzzle?" - "Play the move for me."

Requirements: - identify exactly one legal arrow; - deterministic for
unchanged state; - visually highlight it; - player must still select
it; - no automatic removal; - no sequence disclosure; - count assistance
separately; - apply cost once per request.

Repeated requests against the same unchanged state may show the same
arrow again and each request incurs another assist.

## Accuracy

Open Move assistance and accuracy represent different dimensions.

The intended semantics are: - requesting Open Move is not itself an
arrow tap; - it should not directly reduce tap accuracy; - the player's
later selection of the highlighted arrow behaves like a normal
selection; - mistakes and assists remain separately visible.

This allows results such as: - 100% tap accuracy; - several assists; -
reduced score.

That is coherent: the player tapped accurately but needed help locating
legal moves.

## Results

A completed attempt should expose: - total arrows; - mistakes; - Open
Move assists; - score; - accuracy.

The result also compares the attempt with the current session best.

The player should be able to tell whether the attempt: - established a
first best; - improved; - tied; - did not improve.

## Replay

Replay is not recovery from failure.

The puzzle was already completed.

Replay means:

> "I think I can untangle that more efficiently."

A replay: - starts a fresh attempt; - resets mistakes; - resets
assists; - resets attempt score state; - preserves session best for
comparison.

## Session Best

For each puzzle ID, the running session remembers the best completed
result/score.

Rules: - first completion establishes best; - strictly greater score
replaces best; - equal score does not replace/lower; - worse score does
not replace/lower.

The best result is not durable.

## Overall Session Score

Overall session score is:

`sum(best score for each puzzle completed during this session)`

Uncompleted puzzles contribute nothing.

If a replay improves one level by four points, overall session score
increases by four.

A worse replay cannot lower overall score.

## Session Boundary

The session is the deliberate memory boundary.

A session begins when the game starts.

It ends when the running game/browser session ends or reloads.

Gameplay performance does not survive that boundary.

Do not persist: - per-level score; - overall score; - mistake history; -
assist history; - replay history; - gameplay identity.

## No Identity

The project currently rejects: - login; - account; - profile; -
persistent anonymous ID; - cross-session correlation.

Even a future feedback API should not need to know that two sessions
came from the same person.

The feedback service, if built, should receive independent session
observations for game-design learning.

## Relationship to Future Hard Puzzles

The assistance system is what allows ArrowSpark to intentionally become
more challenging without becoming hostile.

A future dense Gordian-knot puzzle may initially overwhelm the player.

They still have choices: - inspect for free; - test an arrow for a small
penalty; - ask for one open move for a larger penalty; - continue until
completion.

This creates a safe difficulty envelope.

Hard puzzles no longer require punitive fail mechanics.
