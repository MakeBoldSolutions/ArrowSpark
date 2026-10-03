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
- Static showcase site in `web/`: Astro and strict TypeScript (static output only), Node/npm, Vitest; the game ships to it as a Godot Web export (no threads). Run `npm run check` in `web/` for site changes; web builds also need a browser smoke test.
- Puzzle rules use RefCounted classes independently of scenes and input. Preserve this boundary when extending the rule core.
- Run `python tests/run_puzzle_regressions.py --godot <executable>` and `python tests/run_regressions.py --godot <executable>` for isolated regression checks; gameplay changes also require Godot validation and desktop smoke testing.
