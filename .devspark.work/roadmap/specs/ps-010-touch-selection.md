---
id: ps-010
title: Easier arrow selection on touch
status: proposed
depends_on: []
delivery: []
---

# ps-010: Easier arrow selection on touch

## Outcome

Tapping the arrow you meant is reliably easy on a phone, at least as comfortable as the arrow games
players already know.

## Current Reality

A rough iPhone test on 2026-11-08 ended with the game judged playable. One passing comment was that
touch felt a little harder than other arrow games the player knew, naming Easybrain's. What exactly
felt harder was not recorded, and one comment from a rough test is a lead, not a finding.

The code suggests where to look. These are hypotheses, not findings:

- A tap resolves to the exact cell under the finger (`PuzzleViewportTransform.cell_at`), with no
  allowance for a near miss. A tap just off an arrow does nothing, and a tap landing on a neighboring
  blocked arrow counts as a mistake.
- A tap acts on release and becomes a pan once the finger drifts 32 physical pixels
  (`scenes/puzzle/puzzle_board.gd`). On a high-density phone that may be a short distance, so a tap
  with a small drift could turn into a pan and do nothing.
- Dense boards at Fit scale can have cells smaller than a fingertip, so the player has to zoom first.

## Scope and Independence

In scope: finding what makes selection harder, then the smallest change to tap handling that fixes
it, verified on real phones.

Out of scope: rule or scoring changes, new input modes, and copying another game's controls or look.

Standalone boundary: with later items canceled, touch selection is measurably better and mouse,
keyboard and gamepad behave exactly as before.

## Future Health

Any forgiveness must resolve in the one existing hit-test path, not a second one. A near-miss rule must
never pick a different arrow than the player could see they were aiming at, because a wrong pick costs
score. ps-005 and ps-006 add denser boards, where this matters more.

## Dependencies and Decisions

No delivered prerequisites. Confirm in the later iPhone testing (ps-007) that the difficulty is real
before starting. Open question: what felt harder, such as missed taps, the wrong arrow being chosen,
or having to zoom in first.

## Completion Expectations

The specific complaint is identified and addressed. On a real Android phone and a real iPhone, taps on
small and dense boards select the intended arrow, and drags and pinches still pan and zoom. The player
who raised it, or another player, agrees it feels better. Required gates and touch checks pass.
