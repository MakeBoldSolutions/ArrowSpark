# ArrowSpark Development Guidelines

<!-- BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com -->

Auto-generated from all feature plans. Last updated: 2026-09-27

## Active Technologies

- GDScript / Godot 4.4, Maaack's Game Template addon; Python 3.11+ headless regression launchers
- Static showcase site in `web/`: Astro + strict TypeScript (static output), Node/npm, Vitest; Godot Web export (no threads)

## Project Structure

```text
scripts/puzzle/     # domain: PuzzleDefinition, PuzzleState, PuzzleSolver, PuzzleAnalyzer, PuzzleCatalog
scripts/             # PuzzleSession and other project scripts
scenes/              # presentation/menus (Godot scenes)
tests/               # GDScript headless checks + Python launchers (run_*.py)
addons/              # Maaack's Game Template
web/                 # static showcase site (Astro + TypeScript); vendored Make Bold theme in web/theme/
.knowledge/          # durable architecture/product/governance docs
.devspark.work/      # temporary specs/plans/tasks (ephemeral, never referenced by durable code)
```

## Commands

`python tests/run_puzzle_regressions.py --godot <executable>` and
`python tests/run_regressions.py --godot <executable>` — the two required headless regression
gates. Godot validation (`--headless --editor --quit`) and a desktop smoke test are also required
for gameplay changes (constitution Principle V); web builds also need a browser smoke test.
Site: `cd web && npm ci && npm run check && npm run build`.

## Code Style

GDScript: snake_case for new script filenames and functions (Godot-required names excepted);
prefer explicit types where they aid clarity; keep changes small and justify new abstractions.

## Recent Changes

- Puzzle catalog now has purpose groups (Foundations, Puzzle Lab, ArrowSpark Levels) driving
  Level Select sections, group-relative numbering and group-scoped Next Puzzle, plus a
  hand-composed Reference Knot that Play starts — metadata only, no rule changes.

- Spec 007 (in progress): extends `PuzzleState` with a deterministic Open Move
  lookup/assist counter and a revised score formula, and adds a new
  session-lifetime `PuzzleScoreboard` class for per-puzzle best scores and an
  overall session score — no new persistence, no second rules engine.

- Added `PuzzleAnalyzer` (headless structural/dependency-graph analysis sibling to `PuzzleSolver`), six new experimental `PuzzleCatalog` puzzles (8 → 14), an extended catalog regression gate, and a non-gating developer comparison report — no gameplay rule, rendering, or persistence changes.

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->


<!-- DEVSPARK SHARED CONTEXT:START -->
# AGENTS.md

## BSW.DevSpark

- BSW.DevSpark framework files live in `.devspark/`.
- Temporary plans and team overrides live in `.devspark.work/`.
- Determine `{git-user}` from `git config user.name`: lowercase, replace spaces with hyphens, and strip non-alphanumeric/hyphen characters.
- Resolve BSW.DevSpark commands through the first existing file:
  1. `.devspark.work/{git-user}/commands/devspark.{name}.md`
  2. `.devspark.work/commands/devspark.{name}.md`
  3. `.devspark/defaults/commands/devspark.{name}.md`
- Preserve user work in `.devspark.work/` and `.knowledge/`; upgrades refresh `.devspark/` only.
- Project principles and technology are defined in `.knowledge/governance/constitution.md`.

## Active Technologies

- Godot 4.4 and GDScript with Maaack's Game Template; Python 3.11+ regression launchers.
- Puzzle rules use RefCounted classes independently of scenes and input. Preserve this boundary when extending the rule core.
- Run `python tests/run_puzzle_regressions.py --godot <executable>` and `python tests/run_regressions.py --godot <executable>` for isolated regression checks; gameplay changes also require Godot validation and desktop smoke testing.

<!-- DEVSPARK SHARED CONTEXT:END -->
