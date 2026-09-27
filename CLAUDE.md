# ArrowGame Development Guidelines

<!-- BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com -->

Auto-generated from all feature plans. Last updated: 2026-09-27

## Active Technologies

- GDScript / Godot 4.4, Maaack's Game Template addon; Python 3.11+ headless regression launchers

## Project Structure

```text
scripts/puzzle/     # domain: PuzzleDefinition, PuzzleState, PuzzleSolver, PuzzleAnalyzer, PuzzleCatalog
scripts/             # PuzzleSession and other project scripts
scenes/              # presentation/menus (Godot scenes)
tests/               # GDScript headless checks + Python launchers (run_*.py)
addons/              # Maaack's Game Template
.knowledge/          # durable architecture/product/governance docs
.devspark.work/      # temporary specs/plans/tasks (ephemeral, never referenced by durable code)
```

## Commands

`python tests/run_puzzle_regressions.py --godot <executable>` and
`python tests/run_regressions.py --godot <executable>` — the two required headless regression
gates. Godot validation (`--headless --editor --quit`) and a desktop smoke test are also required
for gameplay changes (constitution Principle V).

## Code Style

GDScript: snake_case for new script filenames and functions (Godot-required names excepted);
prefer explicit types where they aid clarity; keep changes small and justify new abstractions.

## Recent Changes

- Added `PuzzleAnalyzer` (headless structural/dependency-graph analysis sibling to `PuzzleSolver`), six new experimental `PuzzleCatalog` puzzles (8 → 14), an extended catalog regression gate, and a non-gating developer comparison report — no gameplay rule, rendering, or persistence changes.

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
