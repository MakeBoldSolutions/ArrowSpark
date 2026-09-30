# ArrowSpark

*A Make Bold Spark Game* — created by [Make Bold Solutions](https://makeboldspark.com)

ArrowSpark is a puzzle game about clearing a board of arrows. Every arrow points
one of four cardinal directions and may drag a tail of cells behind it; select
one, and it feeds out along its own path and off the edge of the board. Some
arrows are blocked by others sitting in their path — select one of those and it
stays put, costing you score but never your ability to keep playing. There's no
life system and no attempt limit: every playable puzzle is guaranteed to always
have at least one legal move, so being stuck is a signal to keep looking, not a
failure state.

Larger puzzles are inspected, not just fit to the screen: zoom in for a
comfortable working scale, pan around a board bigger than your window, and use
Fit Puzzle to recover the overview at any time. "Show Me an Open Move" will
point out one arrow that's safe to remove right now — at the cost of some
score — without ever solving the puzzle for you.

## Playing

Open the project in [Godot 4.4](https://godotengine.org/) and run it, or use a
packaged build if one has been provided to you. Controls:

- **Mouse**: click an arrow to select it; wheel to zoom; middle-drag, or the
  Pan toggle plus left-drag, to move around a large board.
- **Keyboard**: Tab between the Open Move button, the zoom/fit toolbar, and the
  board; WASD to pan a focused board; `=`/`-` to zoom; `F` to fit.
- **Gamepad**: D-pad/left stick to navigate and pan; shoulder buttons to zoom;
  `Y` to fit.

All bindings are remappable from the Options menu.

## Project Layout

```text
scripts/puzzle/      # domain: PuzzleDefinition, PuzzleState, PuzzleSolver, PuzzleAnalyzer, PuzzleCatalog
scripts/              # PuzzleSession, PuzzleScoreboard, and other project-level scripts
scripts/presentation/ # presentation-only helpers (viewport transform, departure geometry, visual style)
scenes/               # menus and gameplay scenes (Godot .tscn/.gd)
tests/                # GDScript headless checks plus Python launchers (run_*.py)
addons/               # Maaack's Game Template (menus, settings, input remapping)
.knowledge/           # durable architecture, product, and governance documentation
.devspark.work/       # temporary specs/plans/tasks used during development (not durable)
```

The puzzle rules (`scripts/puzzle/`) are plain `RefCounted` classes with no
scene, input, or persistence dependency, so they can be tested and reasoned
about independently of presentation.

## Development

- **Engine**: Godot 4.4 (GDScript), built on
  [Maaack's Game Template](https://github.com/Maaack/Godot-Game-Template) for
  menus, settings, and input remapping.
- **Tests**: Python 3.11+ launchers drive headless Godot regression suites.
  From the repository root:

  ```powershell
  python tests/run_puzzle_regressions.py --godot <path-to-godot>
  python tests/run_regressions.py --godot <path-to-godot>
  ```

  Both must exit `0` with every printed `*_FAILURES=0` marker. See
  [`tests/README.md`](tests/README.md) for what each suite covers.
- **Workflow**: this project uses [BSW.DevSpark](https://dev.azure.com/bswdev/HealthSource/_git/bsw.devspark)
  for specification, planning, and review; see [`AGENTS.md`](AGENTS.md) and
  [`CLAUDE.md`](CLAUDE.md) for the resolution rules those commands follow, and
  `.knowledge/` for durable architecture and product documentation.
- **Repo story**: [repo-story-2026-09-30.md](.knowledge/guides/repo-story/repo-story-2026-09-30.md)
  is an evidence-based narrative of the development history, contributor patterns,
  and architecture.
- **Continuous integration**: [`.github/workflows/godot-regression-tests.yml`](.github/workflows/godot-regression-tests.yml)
  runs both launchers on every push and pull request to `main`.

## Credits and License

ArrowSpark is built on [Maaack's Game Template](https://github.com/Maaack/Godot-Game-Template),
used under its MIT license. Full attribution for the template, Godot, bundled
fonts, and other tools lives in [`ATTRIBUTION.md`](ATTRIBUTION.md); the
template's own license terms are in [`LICENSE.txt`](LICENSE.txt).
