# Work: Generator depth lever and the Advanced pack (ps-005, increment 1 of 4)

**Status**: Complete
**Branch**: 021-work-ps-005-generator-depth

## Intended outcome

The generator can build deeper dependency chains, and 45 new Advanced levels ship after the three
original ones. Order of ps-005/ps-006 increments: 1 depth lever + Advanced, 2 Expert + Intermediate,
3 Level Select at about 134 levels, 4 ps-006 Master.

## Acceptance evidence

- 45 levels pass the solver and pack audit; `--check` rebuild is byte-identical (done).
- Existing 34 ids, boards and versions unchanged (catalog pins pass).
- Both regression gates pass; puzzle gate about 28 s with the 45 added (done).
- Owner played a sample and approved the difficulty (done).

## Material exclusions

No Expert, Intermediate or Master levels, no Level Select changes, no rule changes, nothing hand-authored.

## Decisions made in implementation

- `placement.depth_bias` (0 to 1) is the lever: that share of arrows is placed with its head on the forward
  ray of the chain tip (longest wait chain). Scheme is `gen2`; `scheme_for(profile)` keeps `gen1` for
  profiles without it so the four original generated levels stay reproducible.
- Measured first: density is easy (a plain fill reaches 0.87); arrow count needs short arrows (2 to 5)
  and bigger boards; depth and the playable-at-start count are the real levers. The playable cap is
  scaled with board size (6 for about 30 arrows up to 11 for about 66) because about 17 percent of
  arrows are playable at the start at any size.
- Five profiles (Lattice 14x12, Braid 16x14, Mesh 18x14, Thicket 20x15, Sprawl 22x16), nine seeds each.
  Result: 30 to 69 arrows, density 0.5 to 0.8, depth 7 to 16, 5 to 11 playable at the start.
- A second pack, `advanced_generated`, listed after `advanced`, because a recipe builds a whole pack and
  would overwrite the three hand-authored levels.
- The catalog pins cover the original 34 by id and relative order; generated levels are pinned by the
  recipe `--check` and the pack audit.

## Next useful action

Merge, then start increment 2 (Expert and Intermediate).
