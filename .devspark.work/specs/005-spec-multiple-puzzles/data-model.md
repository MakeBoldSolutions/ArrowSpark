# Data Model: Multiple Authored Puzzles and Session-Only Puzzle Selection

No persistent/save-data changes. All new state here is either pure content (the catalog,
rebuilt identically every run) or process-lifetime, in-memory-only session state.

## PuzzleCatalog (new, RefCounted, `scripts/puzzle/puzzle_catalog.gd`)

Static registry; no instances are created. Holds an ordered list of entries, each:

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Stable, human-chosen (e.g. `"intro"`), independent of array position, title, or any filesystem path. Unique across the catalog — enforced by the automated gate (FR-014), not by a runtime uniqueness check on every access. |
| `title` | `String` | Short display title (e.g. `"Simple Introduction"`). Presentation-only; never used as identity. |
| `build` | `Callable` | Zero-argument static function returning a freshly constructed `PuzzleDefinition`. Called anew on every `get_definition(id)` request — no caching, no shared instance. |

Operations (all static):

- `count() -> int`
- `id_at(index: int) -> String`
- `title_at(index: int) -> String`
- `index_of(id: String) -> int` — returns `-1` if not found.
- `ids() -> Array[String]` — ordered, independent copy.
- `get_title(id: String) -> String`
- `get_definition(id: String) -> PuzzleDefinition` — constructs and returns a fresh definition; the returned instance is exactly as isolated from prior calls as `PuzzleDefinition.create_fixed()` already is today (a new literal construction each call, no shared substructure).

Invalid `id` requests (`index_of`/`get_definition`/`get_title` for an unknown ID) return
explicit sentinel values (`-1` / `null` / empty string) rather than silently falling back to
puzzle 1 — callers (`PuzzleSession.get_current_id()`) are responsible for validity fallback, not
the catalog itself, keeping the catalog a pure lookup with no session-state opinion.

## PuzzleDefinition (existing, unchanged in shape)

No new fields. Continues to hold only: `width`, `height`, `arrows` (head→direction), `tails`
(head→ordered cell path). `PuzzleCatalog` entries construct these exactly as
`PuzzleDefinition.create_fixed()` does today (arrows/tails dictionary literals passed to
`PuzzleDefinition.new(...)`), one static builder function per catalog entry.

## PuzzleSession (new, RefCounted static holder, `scripts/puzzle_session.gd`)

Process-lifetime, in-memory-only. Never serialized; never touches `GlobalState`/`GameState`/
`user://global_state.tres`.

| Field | Type | Notes |
|---|---|---|
| `_current_id` (static, private) | `String` | Empty until first set or read. |

Operations (all static):

- `get_current_id() -> String` — if `_current_id` is empty or no longer a valid catalog ID (defensive: catalog is fixed at 8 known-good entries, but this keeps the accessor total), resets it to `PuzzleCatalog.id_at(0)` and returns that.
- `set_current_id(id: String) -> void` — sets `_current_id` directly; caller (New Game, Level Select selection) is responsible for passing a valid catalog ID.
- `advance_to_next() -> bool` — if a next entry exists in catalog order, sets `_current_id` to it and returns `true`; otherwise leaves `_current_id` unchanged and returns `false`.
- `has_next() -> bool` — `true` iff `index_of(get_current_id()) + 1 < PuzzleCatalog.count()`.

State transitions:

```
(process start) → _current_id = "" (unset)
  → get_current_id() [first read, e.g. New Game before session sets it] → defaults to id_at(0)
  → set_current_id(chosen_id)      [New Game explicit, or Level Select selection]
  → advance_to_next()              [Next Puzzle] → moves forward one position, no-op at last entry
  → (scene reload: Replay / pause-menu Restart) → _current_id UNCHANGED (static var survives reload)
  → (app relaunch) → _current_id = "" (unset) again — never persisted
```

## Controller and Presentation Touchpoints (existing files, no new entities)

- `scenes/puzzle/arrow_puzzle.gd::_start_new_attempt()`: replaces
  `PuzzleDefinition.create_fixed()` with
  `PuzzleCatalog.get_definition(PuzzleSession.get_current_id())`; sets a new HUD puzzle-identity
  label from `PuzzleSession.get_current_id()` + `PuzzleCatalog`.
- `scenes/puzzle/puzzle_results.gd`: gains a `next_puzzle_requested` signal, a
  `%NextPuzzleButton`, and a puzzle-identity label; `show_results()` gains a parameter (or sibling
  call) indicating whether Next Puzzle should be shown/enabled.
- `scenes/menus/main_menu/main_menu_with_animations.gd`: gains a `new_game()` override that sets
  `PuzzleSession` to `PuzzleCatalog.id_at(0)` before delegating to the base implementation; gains
  a `puzzle_selected(id)` handler wired from the new Level Select sub-menu.
- New: `scenes/menus/main_menu/puzzle_select_menu.gd` + `.tscn` — a minimal, keyboard/gamepad-
  navigable list bound to `PuzzleCatalog.ids()`/`title_at()`, emitting `puzzle_selected(id: String)`.

None of these touchpoints introduce new persistent fields, new save-file schema, or new
cross-scene data beyond the two new static-registry/session classes above.
