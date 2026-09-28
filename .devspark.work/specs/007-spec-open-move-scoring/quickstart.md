# Quickstart: Manually Verifying Spec 007

**Spec**: [spec.md](spec.md)

Run after automated checks pass (`python tests/run_puzzle_regressions.py --godot
<godot>` and `python tests/run_regressions.py --godot <godot>`), per
constitution Principle V. This is a desktop smoke test, not a replacement for
those automated gates.

1. Launch the project, start a puzzle (New Game or Level Select any catalog
   entry).
2. **Blocked attempts never block play**: click a blocked arrow repeatedly.
   Confirm the arrow never disappears, the mistake count on the HUD rises
   each time, and you can keep clicking other arrows immediately.
3. **Show Me an Open Move**: with the puzzle in progress, trigger the new
   Open Move control via mouse, then again via keyboard-only navigation
   (Tab/arrow focus + Enter/gamepad confirm), then again via gamepad.
   Confirm each time exactly one arrow is visually distinguished, no arrow is
   removed automatically, and the indicator is visible without a mouse hover.
4. **Repeated request, same state**: trigger it twice in a row without
   playing the shown arrow or making any other move. Confirm the same arrow
   is indicated both times.
5. **During departure**: remove an arrow, then — while its departure
   animation is still visibly sliding off-board — trigger Show Me an Open
   Move. Confirm it responds immediately against the already-updated logical
   state (per the resolved clarification), not delayed until the animation
   finishes.
6. **Play the indicated arrow**: click/select the arrow Open Move indicated.
   Confirm normal removed/blocked handling applies.
7. **Results screen**: complete the puzzle with a mix of mistakes and at
   least one Open Move use. Confirm the results screen shows total arrows,
   mistakes, open-move-assist count, score, and accuracy as five distinct
   values, and confirm the score matches
   `max(total_arrows - (mistakes + assists * 5), 0)` by hand.
8. **Perfect run**: replay the same puzzle with zero mistakes and zero Open
   Move uses. Confirm score equals total arrows and both counts show zero.
9. **Session-best comparison**: replay the puzzle worse, then better, then to
   an exact tie. Confirm the Results screen states, each time, whether that
   attempt established / improved / tied / failed to improve the session
   best, and confirm a worse or tied replay never changes the displayed
   session-best or overall session score, while a better replay increases
   both by exactly the improvement.
10. **Overall session score**: complete two or three different catalog
    puzzles. Confirm the displayed overall session score equals the sum of
    each completed puzzle's best score, and that puzzles never attempted
    contribute nothing.
11. **Session boundary**: fully quit and relaunch the application (or use the
    game's normal restart/reload path that ends the process). Confirm no
    session-best or overall score from the prior run is shown — every puzzle
    starts as never-completed-this-session.
12. **No accidental persistence**: confirm existing saved level progress and
    settings (Continue, input remaps, options) are unaffected by any of the
    above — unchanged from before this feature, per constitution Principle VI.
