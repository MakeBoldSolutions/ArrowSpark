# Contract: `arrowspark.attemptCompleted` (contractVersion 1)

**Producer:** the Godot Web build (a web-only GDScript emitter in the puzzle controller layer).
**Consumer:** `web/src/scripts/game-bridge.ts` on the Play page.
**Direction:** one way, game → hosting page. The page never sends anything to the game, and the game never waits for, reads or depends on the page.

## Transport

- The game runs in a **same-origin iframe** served from `/game/`.
- On attempt completion, the game calls `window.parent.postMessage(<JSON string>, window.location.origin)` through `JavaScriptBridge`. The call happens only when `OS.has_feature("web")` is true.
- It is fire-and-forget. If the call fails, or nobody is listening, the game is unaffected.
- On desktop and in headless runs the emitter is a no-op.

## Message data (JSON string, at most 1 KB)

```json
{
  "type": "arrowspark.attemptCompleted",
  "contractVersion": 1,
  "puzzleId": "reference_knot",
  "puzzleVersion": "g1-0123456789ab",
  "mistakes": 2,
  "openMoveAssists": 2,
  "score": 103,
  "elapsedSeconds": 1260
}
```

| Field | Rule |
|---|---|
| `type` | exactly `"arrowspark.attemptCompleted"` |
| `contractVersion` | exactly `1` |
| `puzzleId` | catalog id of the completed puzzle; 1-64 chars, `^[a-z0-9_-]+$` |
| `puzzleVersion` | puzzle content version from `PuzzleContentVersion.of(definition)`: `"g1-"` + 12 lowercase hex (geometry hash; not the app version) |
| `mistakes` | `PuzzleState.get_results().mistakes`, integer ≥ 0 |
| `openMoveAssists` | `get_results().open_move_assists`, integer ≥ 0 |
| `score` | `get_results().score`, integer ≥ 0 |
| `elapsedSeconds` | whole seconds of wall-clock time from attempt start (`_start_new_attempt`) to logical completion (the removal that completes the puzzle), pauses included; integer ≥ 0 |

**Never included:** a player, visitor, session or device identifier, any timestamp, any data about unfinished attempts, accuracy, or anything else.

## When it is emitted

- Exactly once per completed attempt, when results are shown (`_show_results()`, after the session scoreboard records the attempt).
- Replays and other puzzles emit again; the page keeps only the latest.
- An attempt left by Back, Main Menu or a reload emits nothing.

## Consumer validation (all must hold, otherwise the message is ignored silently)

1. `event.origin === window.location.origin`.
2. `event.source === gameIframe.contentWindow`.
3. `typeof event.data === "string"` and its length is at most 1,024.
4. `JSON.parse` succeeds and the result has exactly the eight properties above, each passing its rule.

A valid event is stored in page memory only (a module variable). It is never written to browser storage, never sent anywhere except as the `attempt` object of a game reaction the visitor chooses to submit (`reactions-api.md`), and never shown back to the game.

## Mapping to the reactions API

`attempt = { puzzleId, puzzleVersion, mistakes, openMoveAssists, score, elapsedSeconds }`, copied unchanged. `type` and `contractVersion` are not forwarded.
