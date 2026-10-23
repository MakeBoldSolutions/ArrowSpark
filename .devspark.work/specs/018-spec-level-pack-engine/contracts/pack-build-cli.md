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
2. Runs `level_pack_build.gd` with `-- --recipe <path>`, which:
   - loads every other pack with `PuzzlePackFormat.load_catalog("res://levels", skip_pack = <recipe pack>)`. The target pack is skipped whether or not its file exists, so a first build works; any other load error fails the build.
   - for each recipe level, in order: calls `PuzzleGenerator.generate(profile, seed)` and requires `ok` (which includes the playable cap)
   - runs `PuzzlePackFormat.audit_levels` over the other packs plus the new levels: validity, solvability, content-version match, duplicate ids and boards, and known group
   - prints, per level, the structural-report entry through the shared printer, a profile line (`profile: <name> seed=<n> score=<s> attempts=<k> misses=<metric value [min,max]>...`) and a line `level: <id> <content_version>`
3. Godot prints `PACK_BUILD_FAILURES=<n>`. When it is 0, it also prints the serialized pack between lines `PACK_BEGIN` and `PACK_END`.
4. The launcher:
   - exits non-zero, writing nothing, if Godot fails, prints a script or parse error, or reports failures greater than 0
   - in write mode, writes the exact bytes between the markers to `levels/packs/.<pack>.json.tmp`, flushes and `fsync`s it, then `os.replace`s it onto `levels/packs/<pack>.json`. On any error the temp file is deleted and the destination is untouched.
   - in `--check` mode, compares those bytes with the committed file and never writes

## Output guarantees

- Same recipe → byte-identical pack and identical `level:` lines in every independent process (FR-020, SC-004).
- No partial pack is ever written, and a failed or interrupted build leaves an existing pack byte-identical (FR-019).
- Each failing level is named with its reason: profile miss with metrics, profile rejected, invalid, unsolvable, duplicate id, duplicate board (FR-019), or pack not listed in `levels/catalog.json`.
