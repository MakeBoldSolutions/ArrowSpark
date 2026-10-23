```yaml
gate: verify
devspark_version: "9.3.0"
generated: "2026-10-23T15:10:00Z"
status: pass
blocking: false
summary: "snapshot-neutral passes (30 migrated levels unchanged); end-to-end passes: Web export ships and loads every pack, all four groups play in a Chromium-based browser (agent-run), and the developer reports Firefox, a real phone and a native desktop run with mouse, keyboard and gamepad passing. Gates re-run green on committed b36c041."
modes:
  - mode: snapshot-neutral
    evidence_class: automated
    status: pass
    evidence: |
      Engine: Godot 4.4.1 console ($LOCALAPPDATA/Temp/ArrowGame-Godot-4.4.1/bin/Godot_v4.4.1-stable_win64_console.exe).

      BEFORE (on the unchanged catalog, branch commit 5e4c2f4 plus spec status edit only):
        python tests/run_puzzle_structural_report.py --godot "$G" > gates/snapshot-before-report.txt   -> 313 lines
        probes/dump_pins.gd (index|id|title|group|group_position|next_in_group|content_version per entry)
          run headless against the real project -> gates/snapshot-before-pins.txt                      -> 30 lines

      AFTER (catalog reads levels/packs/{foundations,puzzle_lab,arrowspark_levels}.json; builders deleted;
      before the sample pack exists):
        python tests/run_puzzle_structural_report.py --godot "$G" > gates/snapshot-after-report.txt    -> 313 lines
        probes/dump_pins.gd in an isolated temp project with scripts/puzzle/*.gd and levels/
          -> gates/snapshot-after-pins.txt                                                             -> 30 lines

      diff gates/snapshot-before-report.txt gates/snapshot-after-report.txt   -> no output (identical)
      diff gates/snapshot-before-pins.txt   gates/snapshot-after-pins.txt     -> no output (identical)

      The report covers every level's board size, density, geometry, legal-move structure, dependency
      graph, unlock sequence, blocker distance and full witness; the pins cover id, title, group,
      group position, next-in-group and content version for all 30 levels.
  - mode: end-to-end
    evidence_class: local-integration
    status: pass
    evidence: |
      Export (Godot 4.4-stable editor with the installed 4.4.stable Web templates):
        node web/scripts/export-game.mjs --godot "<...>/Godot_v4.4-stable_win64.exe" --build levelpacks   -> exit 0, 7 s
        export log "Storing File" lines include res://levels/catalog.json and
        res://levels/packs/{arrowspark_levels,foundations,generated_sample,puzzle_lab}.json;
        no res://levels/recipes/* and no res://tests/* entries were stored.
      Site:
        cd web && npm ci            -> exit 0
        npm run check               -> exit 0 (astro check 0 errors; vitest 5 files, 59 tests passed; check-content ok)
        PUBLIC_GAME_BUILD=levelpacks npm run build -> exit 0 (16 pages; build-csp and check-content ok)
      Served web/dist with `astro preview` on localhost:4321 and drove /play/ in the Claude desktop app's
      built-in browser (Chromium; WebGL 2.0 "OpenGL ES 3.0 Chromium"), viewport emulated at 1280x800:
        - Network: /game/levelpacks/index.html, index.js, index.wasm, index.pck -> 200.
        - Console: "Godot Engine v4.4.stable.official.4c311cbee"; no error-level messages and no
          pack/load messages for the whole session.
        - Level Select lists four sections in order: ArrowSpark Levels (9), Foundations (8), Puzzle Lab (13),
          Generated Levels (4) with "Boards built by the level generator; an untuned first sample." and the
          titles Warm-Up, Tangle, Growing Web, Wide Field.
        - Foundations "1. Simple Introduction": played to completion, 6 arrows, 0 mistakes, accuracy 100.0%.
        - Generated Levels "1. Warm-Up": board matches levels/packs/generated_sample.json; played to completion
          with 0 mistakes, accuracy 100.0%; Next Puzzle opened "2. Tangle" (10 arrows) in the same group.
        - New Game opened ArrowSpark Levels "1. First Knot" (9 arrows).
        - Puzzle Lab "7. Large Canvas Validation" opened with 52 arrows (40x30 board).
      Developer-reported manual results, 2026-10-23 (run by the developer against the same local build, not by
      the agent; device model and browser versions were not specified):
        - Firefox (desktop): smoke test passed.
        - A real phone in a mobile browser: smoke test passed.
        - Native desktop run with mouse, keyboard and a physical gamepad (Level Select's four sections, a
          generated level, Next Puzzle scope): passed.
      Chrome itself was not tested separately from the Chromium-based built-in browser; no browser or device
      beyond those above is claimed.
      Re-run on the committed tree (b36c041), Godot 4.4.1:
        python tests/run_puzzle_regressions.py -> exit 0; all 13 *_FAILURES=0 markers (CATALOG with 34 entries)
        python tests/run_regressions.py        -> exit 0; REGRESSION_FAILURES=0
        python tests/run_level_pack_build.py --recipe levels/recipes/generated_sample.json --check -> exit 0;
          "Check passed: levels/packs/generated_sample.json is byte-identical to a fresh build."
discovered:
  - "A headless --editor --quit against the working repository (whose .godot cache predates this change) did not finish within ~5 minutes and was stopped. The CI-style validation of a fresh copy without .godot/.git/web (two --editor --quit passes, Godot 4.4.1) finished in about 5 s each with 0 script errors, and the layout launcher's --import of the real project passes; tests/README.md already says to validate 4.4 from a copy without .godot when the cache came from another editor."
  - "Fast repeated key presses (Tab or Down x30-40) delivered through the browser automation were mostly dropped by the Web canvas; mouse wheel and clicks worked. Not a product finding: keyboard reachability of every Level Select section is covered by tests/puzzle_layout_check.gd and stays a manual desktop check."
```

## Supporting evidence: SC-004 and FR-019 (build tool)

Engine: Godot 4.4.1 console. Commands:

```text
python tests/run_level_pack_build.py --godot "$G" --recipe levels/recipes/generated_sample.json          # process 1 (write)
python tests/run_level_pack_build.py --godot "$G" --recipe levels/recipes/generated_sample.json --check  # processes 2 and 3
python tests/run_level_pack_build.py --godot "$G" --recipe .devspark.work/specs/018-spec-level-pack-engine/probes/<neg>.json
```

Output:

```text
== SC-004 process 1 (write, T018 rebuild) ==
level: gen_sample_01 g1-23d44324684b
level: gen_sample_02 g1-19d50822c894
level: gen_sample_03 g1-aa8be01658d5
level: gen_sample_04 g1-3980bb152beb
== SC-004 process 2 (--check) ==
exit=0
level: gen_sample_01 g1-23d44324684b
level: gen_sample_02 g1-19d50822c894
level: gen_sample_03 g1-aa8be01658d5
level: gen_sample_04 g1-3980bb152beb
Check passed: levels/packs/generated_sample.json is byte-identical to a fresh build.
== SC-004 process 3 (--check) ==
exit=0
level: gen_sample_01 g1-23d44324684b
level: gen_sample_02 g1-19d50822c894
level: gen_sample_03 g1-aa8be01658d5
level: gen_sample_04 g1-3980bb152beb
Check passed: levels/packs/generated_sample.json is byte-identical to a fresh build.
== negative builds; pack hash before: c1086673ee06aeac91714a923d8b350555d9c675 ==
-- neg_unreachable --
exit=1
Build failed; levels/packs/generated_sample.json was not written.
  profile: deep seed=1 score=0.900 attempts=20 misses=depth 4 [40.0,50.0]
BUILD FAILURE: level 'gen_neg_deep': best board misses its profile: depth 4 [40.0,50.0]
pack hash after: c1086673ee06aeac91714a923d8b350555d9c675
0
-- neg_duplicate_id --
exit=1
Build failed; levels/packs/generated_sample.json was not written.
  profile: starter seed=101 score=0.000 attempts=5 misses=none
BUILD FAILURE: pack 'generated_sample' level 'intro': duplicate id, also in pack 'foundations'
pack hash after: c1086673ee06aeac91714a923d8b350555d9c675
0
-- neg_over_cap --
exit=1
Build failed; levels/packs/generated_sample.json was not written.
  profile: capped seed=7 score=4.000 attempts=20 misses=initial_playable_cap 5 [1,1]
BUILD FAILURE: level 'gen_neg_cap': best board misses its profile: initial_playable_cap 5 [1,1]
pack hash after: c1086673ee06aeac91714a923d8b350555d9c675
0
```

The last number after each negative build is the count of leftover `.tmp` files in levels/packs (0 each time).
