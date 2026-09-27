# Spec 006 Report — Puzzle Structure, Challenge, and Character

A measurement toolkit, six experimental puzzles, and what one real playtest immediately taught us
about all of it — 2026-09-27.

**Status**: 39/39 tasks complete · 14 catalog puzzles · 122 analyzer assertions, 0 fail · 9 gate
findings, all resolved · full regression suite green · no leaked planning references.

## Why this spec existed

ArrowSpark's eight shipped puzzles all worked, but they were easy for a provable reason: the
removal rule is monotonic, so no legal move can ever backfire, and none of the eight puzzles
combined more than one structural feature at a time. A dedicated pre-spec research pass
re-implemented the solver's own logic in Python and ran it against all eight catalog puzzles. The
finding was structural, not a matter of taste: because removing an arrow only ever *deletes*
occupied cells, a legal move can never re-block another arrow or turn a solvable puzzle
unsolvable. Strategic difficulty — a choice that can go wrong — is impossible under the current
rules, full stop. Whatever challenge ArrowSpark has is perceptual: finding a legal arrow, tracing a
bent tail, noticing a distant blocker.

The research also found the eight puzzles under-used even that perceptual space. Three of eight
ever used a bent arrow. None combined density with real dependency depth. No puzzle anywhere had
an arrow whose removal unlocked more than one other — the "cascade" moment was completely
untested. The mandate for Spec 006: measure before automating, and build a small laboratory to
find out what actually creates challenge before generation is even on the table.

## What we built

### PuzzleAnalyzer

A new headless, deterministic class sitting beside `PuzzleSolver` — never inside it, and never a
second rules engine. Every blocking fact it reports is read directly off `PuzzleState.is_blocked`
or derived from the same forward-ray geometry the game already uses. It returns board scale, arrow
geometry, legal-move structure, a dependency graph, cascade/unlock detection, and blocker-distance
proxies for any puzzle definition, valid or not.

The trickiest piece was defining what "dependency depth" even means when a candidate puzzle
contains a geometric cycle — something the validation rules allow even though no shippable puzzle
should have one. The answer: the longest *simple* path through the dependency graph, provably
finite for any graph because a path can never revisit a node it's already on. That guarantee is
now backed by a synthetic test mixing a real three-arrow chain with a fully separate two-arrow
cycle, checked against an exact expected depth.

### Six experimental puzzles

Each one was designed on paper against a specific numeric target, then verified against the real
analyzer before being written into the catalog — not authored and hoped for.

| Puzzle | Structural target |
|---|---|
| **Nested Chain** | Dependency depth 3, spanning opposite corners of the board rather than one obvious row |
| **Cascade / Key Arrow** | One bent arrow whose removal unlocks three others in the same step — fan-out 3 |
| **Dense Unravel** | 67% occupied, only 25% legal at the start — density paired with real depth, not just clutter |
| **Bent Network** | Two bent arrows, each blocking a target through its tail cell rather than its head |
| **Long-Range Blocker** | A blocker sitting seven cells down its target's ray, reached through a tail, not a head |
| **Composed / Shaped** | A 25-arrow filled diamond on a 7×7 board, still carrying 47 real dependency edges |

### A non-gating developer report and a gate remediation pass

A separate script enumerates the full catalog and answers nine comparison questions (deepest
chain, largest cascade, highest density, and so on) — deterministic, verified byte-identical
across two runs, and deliberately outside the pass/fail regression gate since it reports facts,
not a verdict.

The plan itself went through a full `analyze` + `critic` review before any code was written. Nine
findings came back — three critical, including a hallucinated knowledge-graph reference and an
undefined semantic for cyclic dependency graphs — and all nine were resolved and re-verified before
implementation started.

## Building it, and one thing we caught ourselves doing

**Hand-derive, then verify against the real thing.** Every synthetic test fixture was worked out by
hand first — exact expected edge counts, depths, unlock sequences — then checked against the
actual implementation. All 122 assertions passed on the corrected first run, catching a real
GDScript operator-precedence bug (`==` binds tighter than `as`) along the way.

**A leaked reference, caught by the project's own backstop.** A repo-wide check exists specifically
to stop planning identifiers — spec numbers, task IDs, branch names — from leaking into durable
code and knowledge docs. It caught exactly that: comments across several new files cited `FR-###`
requirement numbers and one literal file path back into the spec folder, and the project's own
agent-context file named the branch three times. Every instance was reworded to describe the
behavior directly, with nothing pointing back at the spec that produced it.

**A quiet documentation bug in the plan itself.** While implementing, a genuine ambiguity surfaced
in the plan's own design: should the dependency graph be computed at all for a structurally
*invalid* puzzle, given some of its fields are purely geometric? Fixed before writing the affected
code — invalid input now zeroes everything except board and geometry, matching the solver's own
existing contract, while a valid-but-unsolvable puzzle still gets its full static graph.

## What one real playtest taught us

Every one of the six puzzles hit its analyzer-confirmed target exactly. None of that translated
into felt challenge.

> "Scoring is good, gameplay is good, variety on levels is not good — all still very simple. I'm
> looking for more long arrows mixed together so you have to really think about how to sort it
> out. … too many single arrows which can get boring."
>
> — Real play session, six new puzzles, one sitting

Perceived challenge landed at 2 out of 5. Scanning load was reported low. And the one puzzle built
explicitly to test a cascade — a confirmed fan-out of three, exactly the untested "aha" mechanic
the original research flagged as the single most promising lever — produced no aha at all when
asked directly.

| Puzzle | Structural target | Verdict |
|---|---|---|
| Nested Chain | Depth 3, corner-to-corner spread | Contradicted |
| Cascade / Key Arrow | Fan-out 3 on removal | **Contradicted, directly** |
| Dense Unravel | 67% density + depth 3 | Contradicted |
| Bent Network | 2 bent arrows, tail-sourced edges | Inconclusive |
| Long-Range Blocker | Blocker distance 7 | Contradicted |
| Composed / Shaped | 47-edge diamond, 25 arrows | Inconclusive |

The pattern across every "contradicted" verdict is the same one thing: the puzzles are built
almost entirely from single-cell arrows. Depth, density, and cascade fan-out are all real,
analyzer-confirmed properties of the dependency *graph* — but a graph edge between two single
points doesn't require tracing anything. Bent Network came closest to the player's own instinct
(longer, shaped arrows) but only two of its four arrows are actually bent, and its two dependencies
never interact with each other — it tested a weaker version of its own hypothesis rather than the
real one.

One structural finding came along for free: the game was launched against the real save file
rather than an isolated test copy, on purpose, so the player could just play. Before and after, the
save's `states = {}` stayed empty and nothing else in it changed except the "last opened" timestamp
every launch already updates — the no-reset guarantee held even outside the usual isolated test
harness.

## What this points to next

- Arrow geometry — length, bends, and especially **multiple long arrows whose tails actually cross
  into each other's rays** — looks like a stronger lever on felt challenge than graph depth or
  cascade count computed mostly over single-cell arrows.
- A structurally real cascade does not guarantee a felt one. The key arrow itself may need to be
  harder to find, not just guaranteed to unlock several others once it's found.
- Geometric proxies like blocker distance may only matter on a busy board. A distance-7 blocker on
  a two-arrow puzzle apparently doesn't force any scanning, because there's nothing else to scan
  past.
- The next experiment worth trying: several long, bent arrows tightly interleaved with each other,
  not the "one long arrow blocks one single-cell arrow" pattern this round used throughout.

None of this is filed as settled product truth, a difficulty score, or a generator design — it's
evidence, from one player in one session, handed to whatever comes next.

---

Spec 006 · 39 of 39 tasks complete · full regression suite green · no leaked planning references ·
one disclosed manual check remaining (keyboard-only / gamepad-only Level Select navigation)
