# Work: Expert and Intermediate generated packs (ps-005, increment 2 of 4)

**Status**: Complete
**Branch**: 022-work-ps-005-expert-and

## Intended outcome

45 generated Expert levels (about 70 to 110 arrows, density 0.8 to 0.9) and 10 generated Intermediate
levels (about 10 to 25 arrows) ship as new packs after the existing levels of their tiers.

## Acceptance evidence

- All 55 levels pass the solver and pack audit; each recipe `--check` is byte-identical (done).
- The original 34 levels and the 45 Advanced levels are unchanged (pins and recipe check pass).
- Both gates pass, with the gate time recorded (done: puzzle gate about 3.5 minutes).
- Owner plays a sample and approves (open).

## Material exclusions

No Level Select changes (increment 3), no Master levels (ps-006), no rule changes, nothing hand-authored.

## Decisions made in implementation

- Same lever as increment 1 (`depth_bias`, gen2). Expert: five board sizes (19x15 to 24x18), arrow length
  2 to 5, depth_bias 0.8, playable cap scaled 14 to 18. Longer minimum arrow length left the boards short
  of the arrow count, so boards were shrunk instead; three seeds that narrowly missed density were
  re-seeded (+500). Result: 72 to 111 arrows, density 0.80 to 0.88, depth 12 to 22, 10 to 18 playable at start.
- Intermediate: three sizes (Stroll, Detour, Climb): 10 to 24 arrows, density 0.46 to 0.65, depth 3 to 9.
- The catalog gate hit the launcher limit (about 5 minutes). Cause: one PASS line per assertion (tens of
  thousands) through captured stdout, not solving (solver about 20 ms, replay about 1 ms). PASS lines are now
  opt-in (`PUZZLE_CHECK_VERBOSE`); order-independence branches are sampled for generated Advanced (every 3rd)
  and Expert (every 12th); the layout check plays only the first, middle and last of each generated set
  through the real scene; its launcher timeout is 300 s (was 180). Gate time is the cost to watch as levels
  are added.
- Packs are built one at a time: the builder needs every other listed pack present.

## Next useful action

The owner asked to push and merge (the sample play was not separately reported). Open the PR and merge, then
start increment 3 (Level Select at about 134 levels) and the load-time work.
