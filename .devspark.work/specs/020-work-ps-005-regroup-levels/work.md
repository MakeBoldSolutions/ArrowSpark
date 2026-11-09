# Work: Regroup existing levels into difficulty tiers (ps-005, first increment)

**Status**: Complete
**Branch**: 020-work-ps-005-regroup-levels

## Intended outcome

Level Select, group-relative numbering and Next Puzzle follow five difficulty tiers instead of the
build-history groups (Foundations, Puzzle Lab, ArrowSpark Levels, Generated Levels). The Generated
Levels sample is absorbed. Stand-alone: ships without any new levels.

Tiers (working names): Getting Started, Intermediate, Advanced, Expert, Master. Assignment of the 34
existing levels is the approved classification in
`.devspark.work/roadmap/specs/ps-005-first-large-level-pack.md` (13 / 15 / 3 / 2 / 1).

## Acceptance evidence

- Every level is in exactly one tier with the agreed counts; puzzle ids are unchanged.
- A saved profile with finished levels still shows them finished; Continue's `resume_id` still resolves.
- Both regression gates pass, with catalog and layout checks updated for the new groups.
- Desktop smoke test of Level Select and Play.

## Material exclusions

No new levels, no generator work, no Level Select redesign, no rule changes.

## Domain invariant

A level's id and board never change. Only group, order and title move. A regroup must not mark any
finished level unfinished.

## Operating assumptions

Tier names are the working names above. Play should start Getting Started after the regroup (today it
starts the first of the eight ArrowSpark Levels progression); confirm in the menu code.

## Decisions made in implementation

- One pack per tier (`getting_started` to `master`), listed in `levels/catalog.json`; catalog order
  within a tier is the difficulty order. Generated sample levels moved into tier packs with their
  provenance kept; the `generated_sample` recipe and pack were retired (its single `group` could not
  describe levels now in two tiers).
- Play / New Game starts the first catalog level (`intro`, Getting Started), not `first_knot`.
- Next Puzzle still stops at the end of a tier (existing semantics, unchanged).
- The "no ranking words" assertion on Level Select descriptions was removed: tiers are a ranking by design.

## Next useful action

`/devspark-create-pr`. Follow-ups outside this increment: Next across tiers, web story text that
still names the old groups (`web/src/content/evidence.yaml`, chapters), roadmap bookkeeping.
