# Data Model: Transient Puzzle Viewport

No durable schema or domain rule changes. No singleton, Config, GlobalState, PuzzleSession or PuzzleScoreboard camera fields.

## PuzzleViewportTransform (RefCounted, presentation)

| Field | Type / meaning | Invariant |
|---|---|---|
| board_size | Vector2i, complete definition dimensions | positive |
| viewport_size | Vector2, board Control area | valid only when each axis >32 |
| cell_pixels | float, displayed pixels/cell | finite, fit_s <= value <= max(192,fit_s) |
| center_cells | Vector2, logical focal point | per-axis bounded after each mutation |
| fit_mode | bool | true after setup/fit, false after effective user navigation |
| layout_valid | bool | false while area invalid; conversions return no hit |
| last valid projection | transient values above | retained through invalid area |

Canonical visual cell size 64; fit margin 16. Helper has no PuzzleDefinition dependency: configure from positive dimensions, then resize from measured available area. One transform is authoritative for projection and inverse mapping. Never round centers during pan/zoom; floor only when resolving a hit cell.

## Board interaction state

- World: passive child Control; fixed board extent D*64, position/scale from helper.
- DepartureClip: passive clipped Control at World origin, extent D*64; owns departing views.
- Active and departing maps: retain canonical head keys and existing lifecycle.
- pan_mode: session/attempt-only bool; false on setup. Gesture capture stores active button and last board-local pointer; cancel resets capture and suppresses any same-gesture selection.
- navigation_enabled: controller false when results cover board; eligibility additionally checks visibility, tree/window focus and overlays. Focused directional polling requires board focus.
- suggestion/pending reveal: one canonical head or null; valid layout applies reveal without new assist accounting. Selection/setup/replacement clears it.

## Lifecycle

setup -> dispose prior active/departing work -> configure D and canonical geometry -> fresh Select mode + fit_mode -> valid overview (or wait for nonzero area).

fit -> fit_mode, centered original bounds. Effective user zoom/pan -> manual mode. Valid resize -> refit only in fit_mode; otherwise preserve absolute cell_pixels/center then clamp. Invalid resize -> keep last valid state, suspend hit testing and departure advancement; valid recovery -> apply stored-mode policy.

request assistance -> controller increments assist once and chooses head -> reveal if needed -> existing pulse. Reveal changes neither arrow ownership nor gameplay counters. Successful selection -> immediate state removal -> move view to DepartureClip -> cell-distance advancement -> existing full-board clearance -> exactly-once finished -> controller barrier.

Pause/hidden/window focus loss -> cancel gesture/clear hover; pause also freezes departures as today. Results -> disable navigation and focus overlay. Replay/new puzzle -> new state and view; no restored viewport.

## Validation content

Append canvas_validation, 40x30, 12 explicitly authored arrows. Require >=3 bent paths with 20–60 cells, all cardinal directions, a tail dependency, an initially open target near top-left and occupied corner regions. Preserve original fourteen definition snapshots. Solver validation and witness completion are fixture acceptance conditions; no random generation or rule changes.
