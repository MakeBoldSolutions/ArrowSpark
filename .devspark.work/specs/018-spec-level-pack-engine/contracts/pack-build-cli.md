# Contract: Pack-Build Tool

## Invocation

```bash
python tests/run_level_pack_build.py --godot <executable> --recipe levels/recipes/<pack>.json [--check]
```

| Option | Meaning |
|---|---|
| `--godot` | Godot 4.4.x executable (default `godot`, as for the other launchers) |
| `--recipe` | Recipe path, relative to the repository root |
| `--check` | Build and compare against the committed pack without writing. Exit 0 only when the build passes and is byte-identical (used to prove FR-020). |

## Behavior

1. Copies the puzzle domain scripts, `levels/` and `tests/level_pack_build.gd` into a fresh temp project with an isolated `APPDATA`/`XDG_DATA_HOME`, as `run_puzzle_structural_report.py` does. Builds the class cache with `--editor --quit`.
2. Runs `level_pack_build.gd` with `-- --recipe <path>`. For each recipe level, in order:
   - calls `PuzzleGenerator.generate(profile, seed)`
   - requires `ok`, validity and solvability
   - requires the id and content version to be unique against every other pack (excluding levels of the pack being rebuilt) and against earlier levels in the recipe
   - prints the structural-report entry through the shared printer, plus a profile line: `profile: <name> seed=<n> score=<s> attempts=<k> misses=<metric value [min,max]>...`
3. Godot prints `PACK_BUILD_FAILURES=<n>`. When it is 0, it also prints the serialized pack between lines `PACK_BEGIN` and `PACK_END`.
4. The launcher:
   - exits non-zero, writing nothing, if Godot fails, prints a script or parse error, or reports failures greater than 0
   - in write mode, writes `levels/packs/<pack>.json` with the exact bytes between the markers
   - in `--check` mode, compares those bytes with the committed file

## Output guarantees

- Same recipe → byte-identical pack (FR-020).
- No partial pack is ever written (FR-019).
- Each failing level is named with its reason: profile miss with metrics, profile rejected, invalid, unsolvable, duplicate id, duplicate board (FR-019), or pack not listed in `levels/catalog.json`.
