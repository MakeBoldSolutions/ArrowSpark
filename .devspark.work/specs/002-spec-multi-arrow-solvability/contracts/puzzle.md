# Puzzle Interfaces

## Definition and core
PuzzleDefinition.new(width: int, height: int, arrows: Dictionary, tails: Dictionary = {}) preserves old constructors. is_valid() checks ownership/path constraints; get_validation_errors() -> Array[String] provides diagnostics. get_arrow_cells(head: Vector2i) -> Array[Vector2i] and get_cell_owners() -> Dictionary return copies.

PuzzleState.get_arrow_head(cell: Vector2i) -> Variant returns Vector2i or null. is_blocked/select_arrow accept head or tail cells. Preserve outcome enums, counters, results and head-direction snapshot meanings. Whole-shape occupancy removal is synchronous and atomic. Rule scripts extend RefCounted without Node/input/animation/persistence dependencies.

## Analysis
PuzzleSolver.analyze(definition: PuzzleDefinition) -> Dictionary validates before state construction, sorts heads ascending (y,x), collects legal heads using is_blocked, removes first via select_arrow, and returns the data-model result. At most one accepted removal per arrow in the definition (each arrow is removed at most once), followed by a stuck scan when no further legal head remains; no timeout/partial substitute for unsolvability. Never mutate caller definitions or live attempts. Runtime controller does not invoke analysis. Witness heads are accepted by select_arrow. New metric keys are additive.

## Player-facing contract
PuzzleBoard.cell_clicked(cell) remains one event per primary-button press without held-repeat; board emits coordinates and core decides legality. Controller resolves owner before mutation and passes canonical head to play_removed/play_blocked. Every tail cell selects its whole shape. Logically removed cells ignore selections during visual departure.

One ArrowView draws all tail segments and its head, ignores mouse, pulses as a unit and translates along head direction with one completion signal. Preserve feedback/exit duration constants. Visual translation is not swept-shape collision detection. Repeated blocked presses never lock input and count once each.

HUD remains above board at 1280x720 and 960x540. Results await all departures. Replay/Restart reconstruct initial state; cancelling Restart retains current state. Menus/pause/options/results retain keyboard/gamepad focus and remaps. Main Menu preserves saved progress/settings; no new bindings or schemas.
