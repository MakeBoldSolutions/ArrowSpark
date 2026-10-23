# Quickstart: Verifying the Level Pack Engine

Executables (this machine): gates and probes use Godot 4.4.1 console (`$LOCALAPPDATA/Temp/ArrowGame-Godot-4.4.1/bin/Godot_v4.4.1-stable_win64_console.exe`). The Web export needs the 4.4-stable editor with installed templates. Never run the PATH `godot` (4.7.2) on the repo. Use a fresh scratch `APPDATA` for any rendered run.

## 1. Snapshot-neutral evidence (`verify:snapshot-neutral`) — capture BEFORE touching the catalog

On the branch before any catalog change:

```bash
python tests/run_puzzle_structural_report.py --godot "$G44" > .devspark.work/specs/018-spec-level-pack-engine/gates/snapshot-before-report.txt
```

and a pins dump: a throwaway probe under `.devspark.work/` that prints, for `i in range(PuzzleCatalog.count())`, the line `i|id|title|group|group_position|next_in_group|PuzzleContentVersion.of(def)` → `snapshot-before-pins.txt`.

After migration (before adding the sample pack, so both runs cover exactly 30 levels), re-run both into `snapshot-after-*.txt` and diff:

```bash
diff snapshot-before-report.txt snapshot-after-report.txt
diff snapshot-before-pins.txt snapshot-after-pins.txt
```

Both diffs must be empty. Record the commands and results in `gates/verify.md`.

## 2. Gates

```bash
python tests/run_puzzle_regressions.py --godot "$G44"
python tests/run_regressions.py --godot "$G44"
"$G44" --headless --path . --editor --quit
```

## 3. Generator and pack build

```bash
python tests/run_level_pack_build.py --godot "$G44" --recipe levels/recipes/generated_sample.json
python tests/run_level_pack_build.py --godot "$G44" --recipe levels/recipes/generated_sample.json --check
```

The second command must exit 0, which proves the build is byte-identical across separate processes (SC-004, SC-005, FR-020). Also run one negative case by hand: a temporary recipe with an unreachable profile must exit non-zero, name the level and write nothing.

## 4. Desktop smoke test (Principle V)

Run the project with a fresh scratch `APPDATA`. Then:

1. Open Level Select. Four sections appear, the fourth being "Generated Levels". Existing sections keep their order and numbering.
2. With mouse, keyboard and gamepad, reach and play one level from each section.
3. Use Next Puzzle within the generated group, and confirm the last level offers no next.
4. Note whether opening Level Select feels any slower than before (SC-007).

## 5. Web end-to-end (`verify:end-to-end`)

```bash
node web/scripts/export-game.mjs --godot "<4.4-stable editor>"
cd web && npm ci && npm run check && npm run build
```

Serve `web/dist`. In Firefox and in a Chromium-based browser, open the Play page and start one level from each of the four groups. Confirm there are no `load_errors` / `push_error` lines in the console. Repeat on at least one real phone in a mobile browser. Record each browser and device as tested or not tested, never as supported unless tested.
