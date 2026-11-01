# Data Model: Level Pack Engine

All files are UTF-8 JSON, committed, read-only at runtime. Coordinates are integers. Readers reject non-integer numbers, because `JSON.parse_string` yields floats and the reader must convert them to `int`.

## Catalog manifest — `levels/catalog.json`

```json
{
  "format": "arrowspark-catalog/1",
  "packs": ["foundations", "puzzle_lab", "arrowspark_levels", "generated_sample"]
}
```

- `packs` lists pack names in catalog order. Each name resolves to `levels/packs/<name>.json`.
- Catalog order is the manifest order, then the level order within each pack.
- Errors: unknown `format`, a missing pack file, or a duplicate pack name. Each is reported in `load_errors()`.

## Level pack — `levels/packs/<pack>.json`

```json
{
  "format": "arrowspark-pack/1",
  "pack": "foundations",
  "levels": [
    {
      "id": "first_bend",
      "title": "First Bend",
      "group": "foundations",
      "width": 4,
      "height": 3,
      "content_version": "g1-9d0fcfd77be0",
      "provenance": {"kind": "hand-authored"},
      "notes": "Mostly straight, edge-facing single-cell arrows plus exactly one tail with a single right-angle bend.",
      "arrows": [
        ["right", [[1, 1], [0, 1], [0, 0]]],
        ["up", [[3, 0]]],
        ["right", [[3, 2]]],
        ["left", [[0, 2]]]
      ]
    }
  ]
}
```

### Level record fields

| Field | Type | Rule |
|---|---|---|
| `id` | string | Non-empty and unique across all packs. Stable identity. |
| `title` | string | Non-empty. |
| `group` | string | One of `PuzzleCatalog` `GROUP_*` ids. |
| `width`, `height` | int | Positive. |
| `content_version` | string | Must equal `PuzzleContentVersion.of()` recomputed from the geometry (checked by the gate, not at runtime). Unique across all packs. |
| `provenance` | object | `{"kind": "hand-authored"}` or `{"kind": "generated", "generator": "gen1", "profile_name": str, "profile": {…}, "seed": int}`. |
| `notes` | string, optional | Design note. Migrated levels carry their former builder doc comment here. |
| `arrows` | array | Each item is `[direction, vertices]`. `direction` is one of `up`, `down`, `left`, `right`. `vertices[0]` is the head, followed by each turning cell, then the tail end. A single-cell arrow is `[head]`. |

### Conversion rules

- **Record → definition**: `arrows[head] = direction`, and `tails[head]` is the vertex path expanded cell by cell (the former `_tail_along`). Consecutive vertices must differ and share a row or column; a diagonal or zero-length step is a parse error. The result must pass `PuzzleDefinition.get_validation_errors()`. A record that fails is reported in `load_errors()` and not added.
- **Loading**: `PuzzlePackFormat.load_catalog(root, skip_pack := "")` reads `<root>/catalog.json` and each listed pack, returning `{levels, errors}`. A listed pack whose file is missing is an error, unless it is `skip_pack`. Errors name the pack, and the level id or index when one is known.
- **Auditing**: `PuzzlePackFormat.audit_levels(levels, known_groups)` returns the invariant violations below. The catalog gate and the build tool share it.
- **Definition → record** (migration, build tool): heads in `PuzzleDefinition.head_less_than` order. Each tail is compressed to its turning points plus the last cell.
- **Serialization** is deterministic: a fixed key order (`id, title, group, width, height, content_version, provenance, notes, arrows`), two-space indent, and one arrow per line. A trailing newline. Provenance profile keys are sorted.

### Domain invariants enforced by the gate

- The ids and the content versions are each unique across the union of all packs.
- Every level is valid, solvable, and in a known group.
- Its stored `content_version` equals the recomputed one.
- `CATALOG_PINS` matches index-for-index (34 entries after this change).

## Profile (generator input; embedded in recipes and in generated provenance)

```json
{
  "width": 12, "height": 9,
  "arrows": [12, 16],
  "density": [0.5, 0.7],
  "initial_playable": [2, 5],
  "depth": [3, 6],
  "components": [1, 3],
  "bends": [10, 30],
  "max_length": [4, 12],
  "average_length": [3.0, 7.0],
  "placement": {"layering": "center_out", "initial_playable_cap": 5, "arrow_length": [2, 10]},
  "attempts": 200
}
```

- `width` and `height` are an int or an `[min, max]` range. A range is resolved per candidate by the RNG.
- Metric ranges are inclusive `[min, max]`. An omitted metric is unconstrained. Each maps to an analyzer key:

| Profile key | `PuzzleAnalyzer.analyze()` value |
|---|---|
| `arrows` | `board.arrow_count` |
| `density` | `board.density` |
| `initial_playable` | `legal_move_structure.initial_legal_count` |
| `depth` | `dependency_graph.depth` |
| `components` | `dependency_graph.component_count` |
| `bends` | `geometry.total_bends` |
| `max_length` | `geometry.max_length` |
| `average_length` | `geometry.average_length` |

- `placement.layering` is `center_out` (the default) or `uniform`. `arrow_length` is the per-arrow cell-count range, default `[1, 8]`.
- `placement.initial_playable_cap` is an optional int of at least 1. It is a **hard acceptance constraint**: a candidate whose measured `initial_legal_count` exceeds it gets a `misses` entry with metric `initial_playable_cap`, adds to the score, and is never `ok`, whether or not `initial_playable` is set.
- `attempts` is the candidate budget, 1–5000, default 200.
- **Rejected before searching** (detectable contradictions only; result has `profile_errors`, `attempts_used == 0`):
  - any range with `min > max`
  - an out-of-range value: a dimension under 2, density outside (0, 1], `arrow_length.min` under 1, a cap under 1, or `attempts` outside 1–5000
  - no feasible board size: no permitted (width, height) satisfies `width × height ≥ arrows.min × arrow_length.min`
- Otherwise the generator draws (width, height) only from the feasible pairs, enumerated in (height, width) ascending order. A profile whose structural targets cannot all be met is not rejected; it ends with `ok == false` and `misses`.
- **Bounded construction**: at most `MAX_HEAD_TRIES` head attempts per arrow; a tail walk stops at its drawn length or a dead end; an arrow shorter than `arrow_length.min` is discarded and counts as a failed head try.

## Generator result

`PuzzleGenerator.generate(profile, seed) -> Dictionary`:

| Key | Meaning |
|---|---|
| `ok` | `true` when the best candidate meets every profiled range and the playable cap |
| `profile_errors` | Non-empty when the profile was rejected; no search ran |
| `definition` | Best `PuzzleDefinition`, or `null` if none was valid |
| `metrics` | Profiled metric → measured value for the best candidate |
| `misses` | `[{metric, value, min, max}]` for each out-of-range metric (empty when `ok`) |
| `score` | Sum of normalized out-of-range distances. 0 means it meets the profile. |
| `attempts_used` | Candidates tried |

## Recipe — `levels/recipes/<pack>.json`

```json
{
  "format": "arrowspark-recipe/1",
  "pack": "generated_sample",
  "group": "generated",
  "profiles": {"small": { /* Profile */ }},
  "levels": [
    {"id": "gen_sample_01", "title": "Spark One", "profile": "small", "seed": 101}
  ]
}
```

- Every level's `profile` must name a key in `profiles`. Ids must be unique within the recipe and must not exist in any other pack.
- The built pack carries the full resolved profile inline in each level's provenance.
- The pack must already be listed in `levels/catalog.json`, or the build fails with a message to add it, so a built pack is never orphaned. On a first build the listed pack's file does not exist yet; the build skips it rather than reporting it missing.

## Sample pack (FR-021, FR-022)

Four levels in the `generated` group, rising from about 7×6 with 6 arrows to about 15×10 with 20 arrows, all with `center_out` layering and a playable cap. Exact profiles and seeds are chosen during implementation so that each meets its profile within the default budget. Titles are curated by hand.
