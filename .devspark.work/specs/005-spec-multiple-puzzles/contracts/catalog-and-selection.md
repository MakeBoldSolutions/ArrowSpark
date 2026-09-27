# Catalog and Selection Contract

## PuzzleCatalog interface

`scripts/puzzle/puzzle_catalog.gd`, `class_name PuzzleCatalog extends RefCounted`. All members
static; the class is never instantiated.

```
static func count() -> int
static func id_at(index: int) -> String
static func title_at(index: int) -> String
static func index_of(id: String) -> int          # -1 if unknown
static func ids() -> Array[String]                # ordered, independent copy
static func get_title(id: String) -> String       # "" if unknown
static func get_definition(id: String) -> PuzzleDefinition  # null if unknown
```

Contains exactly 8 entries (spec FR-001). Order is deterministic and fixed at authoring time — no
runtime sort, shuffle, or randomization of any kind (spec's explicit ban on random puzzle
selection). `get_definition` returns a freshly constructed `PuzzleDefinition` on every call — two
calls for the same `id` MUST be structurally equal but MUST NOT share mutable substructure
(mirrors `create_fixed()`'s existing guarantee; verified by the automated gate's repeated-request
determinism check).

## PuzzleSession interface

`scripts/puzzle_session.gd`, `class_name PuzzleSession extends RefCounted`. All members static.

```
static func get_current_id() -> String    # defaults to PuzzleCatalog.id_at(0) if unset/invalid
static func set_current_id(id: String) -> void
static func advance_to_next() -> bool     # false (no-op) at the last catalog entry
static func has_next() -> bool
```

Never reads or writes `GlobalState`, `GameState`, `LevelState`, or `user://global_state.tres`.
State is a process-lifetime static var: unaffected by `SceneLoader.reload_current_scene()`, reset
only by a fresh engine process (spec FR-007).

## Controller contract (`scenes/puzzle/arrow_puzzle.gd`)

- `_start_new_attempt()` MUST resolve its definition via
  `PuzzleCatalog.get_definition(PuzzleSession.get_current_id())`, never
  `PuzzleDefinition.create_fixed()` directly.
- `_start_new_attempt()` MUST set a puzzle-identity HUD label from the same resolved
  `PuzzleSession.get_current_id()`/`PuzzleCatalog.get_title()` pair used to build the definition —
  the label must reflect what actually loaded, not a separately-tracked value.
- Replay (`_on_results_replay_requested`) and pause-menu Restart both continue to call
  `SceneLoader.reload_current_scene()` with **no new code** — correctness depends on
  `PuzzleSession`'s static var surviving the reload (see research.md). A test MUST verify this
  holds for both entry points, not just Replay.
- A new `_on_results_next_puzzle_requested()` handler MUST call `PuzzleSession.advance_to_next()`
  then `SceneLoader.reload_current_scene()`. If `advance_to_next()` returns `false` (already last
  puzzle), this handler MUST NOT be reachable — the results UI never offers it (see below), so
  this is a defensive invariant, not a expected runtime path.

## Results contract (`scenes/puzzle/puzzle_results.gd`)

- New signal: `next_puzzle_requested`.
- New `%NextPuzzleButton`, shown/enabled iff the controller passes `has_next = true` when calling
  results display (exact parameter shape decided at implementation; behavior is the contract).
- New puzzle-identity label reflecting which puzzle was just completed, set from the same
  `PuzzleSession`/`PuzzleCatalog` pair the controller used for that attempt.
- Existing `total_arrows`/`mistakes`/`score`/`accuracy` metrics and existing Replay/Main Menu
  behavior are unchanged (spec FR-012).
- All buttons (Replay, Next Puzzle when present, Main Menu) remain focus-traversable via
  keyboard/gamepad, consistent with the existing Replay-grabs-focus convention.

## Level Select contract (`scenes/menus/main_menu/`)

- New: `puzzle_select_menu.gd` + `puzzle_select_menu.tscn`, instantiated by
  `main_menu_with_animations.gd::_setup_level_select()` in place of the addon example's
  `GameStateExample`-backed script (that script is not reused).
- Lists exactly `PuzzleCatalog.count()` entries in `PuzzleCatalog` order, each showing at minimum
  its 1-based catalog number and `title_at(index)`. No entry is ever locked, hidden, or disabled.
- Emits `puzzle_selected(id: String)` on selection (not the addon example's no-argument
  `level_selected`).
- `main_menu_with_animations.gd` connects `puzzle_selected` to a new handler that calls
  `PuzzleSession.set_current_id(id)` then the existing `load_game_scene()` — never
  `GameState.set_current_level()` or any other template persistence call.
- The existing `LevelSelectButton` (currently `visible = false` in
  `main_menu_with_animations.tscn`) becomes `visible = true`; `level_select_packed_scene` (currently
  `null`) is set to the new `puzzle_select_menu.tscn`.
- The sub-menu is opened/closed via the base `MainMenu`'s existing `_open_sub_menu`/
  `_close_sub_menu` mechanism, which already provides keyboard/gamepad focus handling identical
  to Options/Credits — no new input-handling code is introduced for this.
- `main_menu_with_animations.gd::new_game()` (new override) MUST call
  `PuzzleSession.set_current_id(PuzzleCatalog.id_at(0))` before delegating to the base `new_game()`
  implementation, so New Game always starts catalog position 0 regardless of any prior Level
  Select choice in the same session. The base implementation's existing no-`GlobalState.reset()`/
  no-`GameState.start_game()` guarantee is otherwise untouched.

## Automated catalog validation gate

`tests/puzzle_catalog_check.gd` (new), run in the same isolated bare temp project as
`tests/puzzle_regression.gd` (see research.md). For every catalog entry, in order:

1. ID present (non-empty) and unique across the whole catalog.
2. `PuzzleCatalog.get_definition(id)` constructs without error.
3. `definition.is_valid()` is `true` (existing structural validation, unmodified).
4. `PuzzleSolver.analyze(definition)` reports `solvable == true`.
5. The returned `witness` replays against a fresh `PuzzleState.new(definition)` via
   `select_arrow(head)` for each witness head in order.
6. The replay clears the board (`state.completed == true`) with `state.mistakes == 0`.

Failure at any step for any entry fails the whole gate (`PUZZLE_CATALOG_FAILURES > 0`); the gate
never partially skips a malformed entry to let the rest pass silently.
