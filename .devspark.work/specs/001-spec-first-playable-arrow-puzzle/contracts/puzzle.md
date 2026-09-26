# Puzzle Interfaces and UI Contract

## Core boundary

- PuzzleDefinition: cardinal Direction enum; factory supplying the immutable fixed board dimensions and cell/direction entries.
- PuzzleState: initialize from a validated definition; is_blocked(cell) for active arrows; select_arrow(cell) returns IGNORED, BLOCKED or REMOVED; get_snapshot() returns copied counters/active data; get_results() exposes total, mistakes, score and accuracy for completed state. Querying blocking on an absent cell returns false; selection still returns IGNORED.
- Selection is synchronous; every accepted active-cell request accounts once. Core has no Node, mouse, tween, persistence or UI dependencies. A touch adapter can later supply the same cell selection request.
- Controller owns state; views receive copied data and cannot mutate it. Views signal selection intent; controller applies state before starting visual effects.

## User interface

Play opens the fixed board at N remaining / zero mistakes. Empty clicks do nothing. Blocked feedback is brief, non-color-only, repeatable without locking input. Clear arrows immediately stop blocking and animate outside the board. All departures finish before results appear. HUD remains readable while resizing and uses board-local input mapping.

Results show Total arrows, Mistakes, Score, Accuracy formatted to one decimal percent, Replay and Main Menu. Replay has initial keyboard/gamepad focus. Existing ui navigation/remapped controls activate buttons; no new board-navigation input scheme is required. UI actions never count as puzzle taps. Results absorb background input and do not permit a second completion or pause overlay.

Pause uses the existing pause menu: resume preserves state, restart confirmation reloads the puzzle with fresh counters, options respect existing settings, Main Menu leaves without changing unrelated saves. Cancelled restart keeps the attempt. Return from options restores usable focus. Scene changes and replay cancel or invalidate stale callbacks.

No network, filesystem or external-service interface is added.
