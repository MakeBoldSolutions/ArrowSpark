# Findings Summary

Based on one real play session (2026-09-27, Mark Hazleton) of all six experimental puzzles — see
[records.md](records.md) for the raw observations this summary draws from, including the explicit
disclosure that most fields are an aggregate reaction across all six rather than independently
rated per puzzle. This is evidence from a single tester in a single session, not a validated
conclusion; it is exactly the kind of early signal Spec 006 exists to surface before any generator
is designed.

## Headline finding

**Every one of the six puzzles hit its analyzer-confirmed structural target (depth, cascade
fan-out, density, tail-sourced edges, blocker distance, board/edge count), and none of that
translated into felt challenge.** Perceived challenge was rated 2/5, scanning load "low," and the
Cascade/Key Arrow puzzle's confirmed fan-out-3 cascade produced no "aha" moment at all. The
tester's own diagnosis: the puzzles have "too many single arrows," and what would actually demand
real thought is "tightly coupled longer arrows of varying lengths" mixed together. This is a
direct, first-session challenge to the spec's original hypothesis that dependency
depth/cascade/density are the primary levers of perceptual difficulty — at least not on their own,
independent of arrow geometry.

## Per-experiment verdicts

### Nested Chain — depth 3, dependency spread across board corners

**Contradicted (tentatively).** The hypothesis was that spatial separation of a dependency chain
forces genuine board-tracing. All four arrows are single-cell, so there was nothing to visually
*trace* — only cells to notice-or-not — and scanning load stayed low. Spatial separation of
single-cell *heads* does not appear to be enough on its own; the chain's *links* need to be
followed through geometry (bends, tails), not just recalled by position.

### Cascade / Key Arrow — fan-out 3

**Contradicted, directly.** This is the one puzzle-specific data point explicitly asked and
explicitly answered: no aha/unlock moment, despite the analyzer confirming three arrows becoming
legal in the same step. A structurally real cascade did not read as an experientially real one.
Possible cause (untested here): the key arrow's own bent tail was two cells, small enough that
finding and removing it may not have felt like a "discovery" — the spec's own request specifically
hoped the key arrow "requires some discovery," and this session suggests two bent cells wasn't
enough discovery to earn the payoff.

### Dense Unravel — density 0.667, depth 3 across six parallel single-cell chains

**Contradicted.** All 24 arrows are single-cell; the tester called out exactly this pattern as the
core frustration. High density built from uniform single-cell columns reads as *busy*, not
*complex* — matching the pre-spec research's own warning about the baseline catalog's
`dense_board` puzzle, now shown to also apply to a version with real dependency depth added.
Density plus depth alone, without arrow-geometry variety, may not be sufficient.

### Bent Network — 2 bent arrows, 2 independent tail-sourced dependencies

**Inconclusive.** This is the puzzle closest in spirit to the tester's own stated wish (longer,
shaped arrows), but only 2 of its 4 arrows are bent, and its two dependency pairs are fully
independent of each other rather than interacting — it under-realizes its own hypothesis rather
than testing it at full strength. The tester's explicit ask for arrows "mixed together" suggests
the next iteration should make bent/long arrows' tails cross and interact with *each other*, not
just each independently block one other single-cell arrow.

### Long-Range Blocker — blocker distance 7 via a tail cell

**Contradicted.** Scanning load was reported low despite a long ray. Likely cause: with only 2
arrows total, there is nothing else on the board to search past or get distracted by — a long ray
across mostly empty space may not force scanning the way a long ray across a *busy* board would.
This matches the original research's own caution that `blocker_distance` is a geometric proxy, not
a validated perceptual measurement — this session is a concrete instance of that gap.

### Composed / Shaped — 25-cell diamond, depth 6

**Contradicted on the dependency-unraveling front; inconclusive on memorability.** Same pattern as
Dense Unravel (uniform single-cell, one-directional chains) — the tester didn't call the shape out
positively or negatively at all, suggesting the diamond composition didn't register as a feature
worth mentioning either way in this session.

## What this session suggests, tentatively

- **Arrow geometry (length, bends, and — critically — multiple long arrows whose tails actually
  interact) may be a stronger driver of felt challenge than pure dependency-graph metrics (depth,
  cascade fan-out, density) computed largely over single-cell arrows.** This directly echoes the
  spec's own "Tracing Load" dimension, which this round of puzzles under-weighted relative to
  depth/cascade/density.
- **A structurally confirmed cascade does not guarantee a felt "aha" moment** — the key arrow
  itself may need a more substantial or well-hidden shape to earn the payoff, not just a
  guaranteed fan-out count.
- **Geometric proxies for scanning load (like `blocker_distance`) may depend heavily on overall
  board occupancy** — a long ray on a nearly-empty board apparently does not force scanning the
  way research anticipated a long ray on a busier board might.
- **Recommended next experiment** (not a generator, not implemented here): a puzzle built
  substantially from multi-cell, variously-bent arrows whose tails cross into each other's rays —
  several long arrows tightly interleaved, rather than the "one long arrow blocks one single-cell
  arrow" pattern this round used throughout.

None of the above is asserted as established product truth, a composite difficulty score, or a
generator design — it is this spec's evidence handoff, based on one session with one tester, to
whatever specification investigates puzzle structure next.
