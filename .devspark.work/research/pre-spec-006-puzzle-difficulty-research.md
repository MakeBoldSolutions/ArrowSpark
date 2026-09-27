# Research — Preparing for Spec 006: From Solvable Puzzles to Interesting Puzzles

Grounded in the actual code (`scripts/puzzle/puzzle_catalog.gd`, `puzzle_definition.gd`, `puzzle_state.gd`, `puzzle_solver.gd`) and a direct re-implementation of `PuzzleSolver.analyze()` run against all 8 catalog puzzles plus the legacy `PuzzleDefinition.create_fixed()` board. No rule changes, no implementation.

## EXECUTIVE SUMMARY

The eight catalog puzzles are easy not because the rule system is shallow, but because the *content* never combines features. Under the current monotonic-removal rules, a legal move can never make the puzzle harder, never re-blocks another arrow, and never makes the puzzle unsolvable — this is a proven structural property (see Rule-System Implications), not a hypothesis. That means **strategic difficulty (a choice that can go wrong) is impossible under the current ruleset**, full stop. All difficulty available today is perceptual: finding a legal arrow, tracing a bent tail, and recognizing a distant blocker.

Given that, the eight puzzles under-use even the perceptual space the engine already supports. Only 3 of 8 puzzles use a bent arrow at all, and none uses more than one bent arrow. No puzzle combines density with real dependency depth. No puzzle has an arrow whose removal unlocks more than one other arrow (no "cascade" exists anywhere in the catalog). Tellingly, the old, no-longer-shipped `PuzzleDefinition.create_fixed()` board is structurally *richer* than every catalog puzzle (density 0.65 vs. 0.2–0.5, initial legal ratio 0.38 vs. 0.75–1.0) — the team already had proof the engine could do more before Spec 005 chose simpler content.

The most important finding: **we don't yet have a validated model of what makes an ArrowSpark puzzle feel hard**, and building a generator before that model exists risks optimizing for the wrong thing. The cheapest next step is not a generator — it's a small, deliberately varied set of hand-authored puzzles targeting the untested structural axes (cascades, combined density+dependency, multi-bend interaction), instrumented with cheap-to-compute structural metrics, and checked against a few minutes of real playtesting per puzzle.

## CURRENT PUZZLE ANALYSIS

Metrics below were computed by re-implementing `forward_ray_cells`, `PuzzleState.select_arrow`/`is_blocked`, and `PuzzleSolver.analyze`'s greedy (y,x)-ascending walk in Python and running it against each `PuzzleCatalog` builder's literal arrow/tail dictionaries.

| puzzle | board | arrows | density | single-cell | bent (arrows) | total bends | longest arrow | initial legal / total | forced states | branching states |
|---|---|---|---|---|---|---|---|---|---|---|
| intro | 4×4 | 6 | 0.38 | 6 | 0 | 0 | 1 | 6/6 (1.00) | 1 | 5 |
| first_bend | 4×3 | 4 | 0.50 | 3 | 1 | 1 | 3 | 4/4 (1.00) | 1 | 3 |
| multi_bend | 5×5 | 4 | 0.32 | 3 | 1 | 3 | 5 | 3/4 (0.75) | 2 | 2 |
| dependency_chain | 5×3 | 3 | 0.20 | 3 | 0 | 0 | 1 | 1/3 (0.33) | 3 | 0 |
| forced_sequence | 5×2 | 5 | 0.50 | 5 | 0 | 0 | 1 | 1/5 (0.20) | 5 | 0 |
| multiple_choices | 4×4 | 4 | 0.25 | 4 | 0 | 0 | 1 | 3/4 (0.75) | 1 | 3 |
| dense_board | 6×6 | 10 | 0.28 | 10 | 0 | 0 | 1 | 9/10 (0.90) | 1 | 9 |
| subtle_blockers | 5×5 | 4 | 0.28 | 3 | 1 | 1 | 4 | 3/4 (0.75) | 2 | 2 |
| *create_fixed* (legacy, not shipped) | 5×4 | 8 | 0.65 | 5 | 1 | 2 | 4 | 3/8 (0.38) | 2 | 6 |

`states_examined` always equals the arrow count and `witness_len` always equals `states_examined` for every puzzle — an identity of the deterministic, non-backtracking greedy solver, not a difficulty signal by itself.

Qualitative read, puzzle by puzzle:

- **intro** — every arrow legal from the first tap (initial legal ratio 1.00), zero bends, zero dependencies. Purely an execution/onboarding puzzle: no scanning, no reasoning, just tap six obvious things.
- **first_bend** — same "everything already legal" shape as intro, but one arrow has a 2-cell bent tail. The bend is introduced with zero jeopardy — nothing depends on it and nothing blocks it. Player learns to trace an L-shaped tail, but there is no stakes attached to getting it right.
- **multi_bend** — one arrow with a 3-bend, 4-cell tail; one straight single-cell arrow sits on that bent arrow's own forward ray, so removing the bent arrow is what's blocked, not blocked by it (`multi_bend` head is blocked at the start: initial_legal 3/4). This is the closest the catalog gets to "trace a complex shape under a real constraint," but the dependency is a single link, not a chain.
- **dependency_chain** — deliberately linear: A blocks B blocks C, 100% forced states, 0% branching. There is exactly one legal move at every step; the "puzzle" is entirely about recognizing which single arrow is legal, not choosing.
- **forced_sequence** — five single-cell arrows in a row, each blocked by every arrow still active to its own side. Also 100% forced (branching_states = 0). Structurally this is the *same* archetype as dependency_chain (a total order with no real choice) realized with positional blocking instead of explicit tail-based blocking.
- **multiple_choices** — four fully independent single-cell arrows plus one implied dependency; three are simultaneously legal at the start (a real branching state), but since order can't affect solvability, the "choice" has no consequence beyond which order you happen to tap.
- **dense_board** — the highest arrow count (10) and the widest branching factor (avg. 4.9 legal choices per state), but it is 100% single-cell, straight, zero-bend, zero real dependency (initial legal ratio 0.90). It *looks* dense but is mechanically almost trivial — nearly the whole board is already pickable on sight.
- **subtle_blockers** — the puzzle explicitly designed to hide a blocker: a bent tail sits inside another arrow's long forward ray. This is the only puzzle in the catalog built around "the blocker is not visually obvious," and it only does it once, with one bent arrow.
- **create_fixed (legacy)** — not part of `PuzzleCatalog`, but structurally the densest and most interdependent board that exists in the codebase (density 0.65, initial legal ratio 0.38, 6 of 8 states branching). It combines a twice-bent tail, two straight multi-cell tails, and real blocking chains (A blocks B and E; B blocks G) — exactly the kind of composition missing from the shipped eight.

## WHY THE CURRENT PUZZLES ARE EASY

Evidence-based, not assumed:

- **High initial-legal ratios dominate.** intro and first_bend start at 100% legal; multiple_choices, dense_board, multi_bend, subtle_blockers start at 75–90% legal. Only dependency_chain and forced_sequence start low (20–33%). Most puzzles hand the player nearly the whole solution on the first glance.
- **The two "hard-looking" puzzles are actually the least free-form.** dependency_chain and forced_sequence are 100% forced (branching_states = 0) — there is never more than one legal arrow at a time. That is low cognitive load, not high: the player doesn't choose, they just find the one lit-up option.
- **No puzzle combines more than one structural feature.** Bends only ever appear alone (max 1 bent arrow per puzzle, max 3 total bends), never alongside a dependency chain or high density. Density (dense_board) only ever appears without dependency. This means every puzzle isolates a single skill instead of stacking them.
- **No cascades exist.** In every catalog puzzle, removing one arrow unlocks at most one other arrow. There is no "key" arrow whose removal opens up two or three downstream arrows at once — the single most promising "aha" mechanic the ruleset supports is untested.
- **The richest board in the codebase was never shipped.** `create_fixed()` (density 0.65, most branching states, multiple compounding blockers) demonstrates the engine already supports meaningfully harder boards; Spec 005's catalog chose to keep each puzzle to one clean teaching point instead.

## RULE-SYSTEM IMPLICATIONS

`PuzzleSolver`'s own header comment states the monotonicity proof directly: removal only deletes occupied cells, never adds any, so an arrow's legality is a monotone function of the active occupancy set. Working through the specific questions against `PuzzleState.select_arrow`/`_is_head_blocked`:

- **Can a legal move make the puzzle harder?** No. Removing an arrow only shrinks `_cell_owners`' effective active set; it can never place a new cell in another arrow's `forward_ray_cells`.
- **Can a legal move make another legal move illegal?** No, for the same reason — occupancy is monotonically decreasing, and `_is_head_blocked` only checks for occupied cells still in `_active_arrows`.
- **Can a legal move make the puzzle unsolvable?** No. This is the exchange-argument proof already in the code: if a complete order exists, any currently-legal arrow can be chosen first without stranding the rest.
- **Are all legal moves ultimately safe?** Yes, unconditionally, under the current rules.
- **Where can meaningful difficulty come from, if not strategy?** Perception: finding which arrows are currently legal, correctly tracing a bent tail's shape, and recognizing why a given arrow is blocked (mentally projecting its forward ray and checking occupancy against a cell that may be far away or visually non-obvious).
- **Is difficulty primarily perceptual rather than strategic?** Yes, structurally so — not a design choice we could second-guess without changing the rules.
- **Does removal order matter only for efficiency/recognition?** Yes. A player can, in the worst case, brute-force-tap every arrow and eventually clear any solvable puzzle; `mistakes`/`total_taps` (and therefore `score`/`accuracy` in `PuzzleState.get_results()`) are the only things order affects — a *soft* skill-expression layer on top of a rule system with no failure states.
- **Can interesting dependency structures still emerge despite monotonicity?** Yes — nothing about monotonicity limits dependency *depth*, *width*, or *cascade fan-out*. It only rules out strategic jeopardy. A puzzle can still have a long forced chain, wide branching, or a single key arrow that unlocks three others; none of those require non-monotonic rules, and none of the eight puzzles currently push past a chain of depth 3 or a fan-out of 1.

**Do not change the rules.** The ceiling on perceptual richness (chain depth, cascade fan-out, bend combination, density) has not been reached by the current content, so there's no evidence yet that the monotonic model is the limiting factor.

## DEPENDENCY MODEL

A directed graph is a clean, non-forced fit for this rule system:

- **Node** = an arrow (its head cell).
- **Edge A → B** = "A currently blocks B," i.e., some cell A occupies (head or tail) lies in B's `forward_ray_cells`. This is exactly `PuzzleState._is_head_blocked`'s own check, read as a graph edge.
- **Do dependencies change during play?** Edges only *disappear* (when the blocking arrow is removed) — they never appear. This is a monotonically-shrinking graph, which is the graph-theoretic restatement of the solver's monotonicity proof.
- **Can cycles exist?** Geometrically yes — nothing in `get_validation_errors()` forbids A's tail sitting in B's forward ray while B's tail sits in A's forward ray. A cycle among *all* remaining arrows with no external legal arrow is exactly a `no_move_states` deadlock (unsolvable). `PuzzleSolver.analyze` already reports `solvable: false` for this case, so any generator or scorer can lean on the solver's existing acyclicity check rather than reimplementing cycle detection — though a static edge-based cycle check would be useful for cheaply rejecting bad candidates before running the full solver.
- **Depth**: dependency_chain has depth 3 (a genuine A→B→C chain). forced_sequence achieves a depth-5 total order, but by a different mechanism — each arrow is blocked by *every* still-active arrow to its side, not a single upstream link, so it is a fully linear order realized through many simultaneous edges rather than one chain.
- **Width / branching**: multiple_choices and dense_board have wide root sets (many in-degree-0 nodes) and shallow depth — these are graphs that are wide and flat, not deep.
- **Fan-out / cascades**: across all 8 puzzles, no node has out-degree greater than 1 in the observed witness — no single removal ever unlocks more than one other arrow. This is a real, currently-unexercised primitive: a "key" arrow with out-degree 2–3 is fully expressible in the current geometry (just requires two or three other arrows' forward rays to pass through one shared blocker's cells) and hasn't been tried.
- **Is this a useful generation primitive?** Yes — a dependency-first generator would directly target the axes this research identifies as both measurable and currently missing (depth, width, fan-out) rather than hoping random geometry happens to produce them.

## CURRENT SOLVER METRICS

What each metric means in `PuzzleSolver.analyze()`, and how useful it is for predicting *human* difficulty:

| metric | what it actually measures | usefulness for human difficulty |
|---|---|---|
| `states_examined` | number of solver iterations; always equals arrow count for a solvable puzzle (identity of the non-backtracking greedy walk) | **mostly diagnostic** — doesn't vary independently of a trivial count already known from the definition |
| `active_choices_encountered` | sum over all states of remaining active arrows | **potentially useful** as a component of average branching, but a raw sum conflates puzzle size with actual choice richness |
| `legal_choices_encountered` | sum over all states of currently-legal arrows | **likely useful** — the average (`legal_choices_encountered / states_examined`) is a real proxy for "how many things are pickable on average," directly tied to perceptual search cost |
| `forced_states` | count of states with exactly 1 legal arrow | **likely useful** — high forced-state ratio (dependency_chain, forced_sequence are 100%) signals a puzzle with no real choice at any point, a distinct and measurable archetype |
| `branching_states` | count of states with ≥2 legal arrows | **likely useful**, same reasoning as above, inverse signal |
| `no_move_states` | count of states with 0 legal arrows | **misleading for human difficulty** as a *difficulty* metric — it should always be 0 for any puzzle the catalog would ship; its only real job is a correctness gate (detecting unsolvable puzzles), not a difficulty signal |

Overall: the existing metrics measure the **breadth of choice** at each state well, but say nothing about **how hard a choice is to see** (visual scanning, tracing a bent tail, noticing a distant blocker) or about **cascade effects** (how much one removal changes the legal set). They're a legitimate first layer, insufficient alone.

## MISSING METRICS

Split by whether they're objectively computable from `PuzzleDefinition`/`PuzzleState`/`PuzzleSolver` today with no rule changes, versus needing a new heuristic or human data.

**Objectively computable now, no new heuristics:**

- Initial legal move count / ratio (computed above; currently the solver never surfaces the *first* state's numbers on their own, only aggregated totals).
- Minimum and maximum legal-choice count across the run (currently only the sum is exposed, not the extremes).
- Longest forced-move run (consecutive forced states).
- Dependency depth (longest path in the blocker graph, computable statically from geometry — independent of witness order).
- Dependency width (max simultaneous independent legal set, i.e. the max `branching_state` legal count).
- Number of dependency edges (count of blocker→blocked pairs at the initial state, or over the whole run).
- Max blockers per arrow (max in-degree).
- Max cascade / unlock-per-removal (max number of arrows that flip blocked→legal after one specific removal step — computable by diffing the legal set before/after each witness move; this directly measures the "key arrow" effect identified above as missing from the catalog).
- Board occupancy / density, average/maximum arrow length, bend count, average bends per arrow (all computed above — trivial from `PuzzleDefinition`).
- Blocker distance from the blocked head (index of the blocking cell within `forward_ray_cells`, or raw cell distance) — objectively computable.

**Needs a heuristic proxy or human calibration data:**

- "Visually distant" blockers, "amount of board scanning required," "symmetry or visual ambiguity" — these depend on rendered layout, screen distance, and color/contrast, not on `PuzzleDefinition` geometry alone. A cell-distance heuristic (Chebyshev/Euclidean) is a plausible *proxy*, but it is not the same measurement as visual difficulty and should be labeled as an approximation, not fact, until checked against playtesting.

So: the graph/geometry metrics are a cheap, immediate deliverable requiring zero new subjective judgment calls. The perceptual/visual metrics are a genuinely separate track that needs either a distance-based proxy or real human data — don't conflate the two when scoping Spec 006.

## STRATEGIC VS PERCEPTUAL DIFFICULTY

Confirmed structurally (not just observed): strategic difficulty — a choice between legal moves where one is meaningfully worse — is impossible under the current monotonic ruleset. All difficulty available today is perceptual, with one soft strategic layer riding on top: the `mistakes` counter means *reasoning before tapping* is rewarded (higher score/accuracy) even though nothing is ever unsolvable. That's a skill-expression layer, not a branching-difficulty layer.

Testing the "what makes perceptual puzzles satisfying" hypotheses against the actual mechanics:

- **Discovering a hidden legal arrow** — mechanically supported (subtle_blockers proves it works), but used exactly once across 8 puzzles.
- **Tracing a bent arrow correctly** — supported (3 of 8 puzzles have exactly one bent arrow), but never combined with density or with a second simultaneous bent arrow, so the "trace under pressure" version of this satisfaction is untested.
- **Realizing a distant cell is blocking a head** — `forward_ray_cells` can span an entire board dimension, so long-range blocking is fully supported by the rules today; no catalog puzzle uses a genuinely long ray with a single distant blocker on a larger board.
- **Clearing a key arrow that visually unlocks several others** — **not present in any catalog puzzle** (max observed out-degree is 1). This is the most promising untested lever for a memorable "unlock" moment, and it is achievable with the current rules — it just hasn't been designed for yet.
- **Seeing an initially dense board progressively unravel** — dense_board is dense in raw arrow count but mechanically trivial (90% already legal at the start, zero dependencies), so it looks busy but doesn't actually "unravel" — there's nothing to unravel. The satisfying version of this requires density *combined with* real dependency depth, which no puzzle currently attempts.

## PUZZLE CHARACTER

Three measurable axes already explain the 8 puzzles' existing archetypes without inventing new taxonomy:

1. **Dependency depth** (chain-ness) — dependency_chain and forced_sequence score high (3–5, fully forced); everything else scores near 0.
2. **Branching width** (choice-ness) — multiple_choices and dense_board score high; the chain puzzles score 0.
3. **Tracing load** (bends, tail length, blocker distance) — first_bend/multi_bend/subtle_blockers score >0; everything else scores 0.

No existing puzzle scores high on more than one axis at once — each of the 8 puzzles is a near-pure point on exactly one axis (with legacy `create_fixed` as the one example that mixes two). That gap — the *combinations* — is precisely the unexplored design space: "dense but dependency-heavy," "cascade" (a 4th axis: fan-out, currently 0 everywhere), and "deceptive" (looks simple, has a long-range hidden blocker) are all reachable within the current ruleset but not yet realized anywhere in the codebase.

## GENERATION APPROACHES

| approach | fit with current architecture | complexity | solvability likelihood | interestingness control | difficulty/character control | notes |
|---|---|---|---|---|---|---|
| Random construction + validate | Trivial to bolt onto `PuzzleDefinition`/`PuzzleSolver` as-is | Low | Low-moderate (valid+solvable space is a thin slice of random geometry, especially with bends) | Low — no way to aim at depth/width/fan-out | Low | Fast to build, likely to mostly reproduce today's "isolated single feature" puzzles, wastes cycles rejecting |
| Reverse construction (build backward from empty board) | Natural fit — it's literally the reverse of a `PuzzleSolver` witness | Moderate | High by construction (a valid reverse-removal order guarantees solvability) | Moderate — can place blockers deliberately as you build outward | Moderate-high | Good match for the monotonic model; still needs care to avoid trivial "always legal" placements |
| Dependency-first (design graph → realize spatially) | Directly targets the depth/width/fan-out axes this research identifies as missing | High — graph→spatial realization with forward-ray geometry and bends is a real constraint-satisfaction problem | Moderate (some graphs may not be spatially realizable on a given board) | High — the whole point is aiming at specific structure, including cascades | High | Highest ceiling; the only approach that can deliberately create the untested cascade/fan-out primitive |
| Mutation of existing puzzles | Cheap, reuses the 8 (and legacy) puzzles directly | Low | Moderate (small mutations of valid puzzles are often still valid, but must re-validate/re-solve each time) | Low-moderate — explores near neighbors, unlikely to spontaneously invent a cascade from puzzles that have none | Low-moderate | Good secondary/validation tool once metrics exist; poor primary discovery method |
| Search / evolutionary | Requires an objective function to optimize | High | Depends on objective | Depends entirely on having a validated scoring function first | Depends | **Premature now** — we don't have a validated difficulty/character score to optimize toward; would optimize the wrong thing |
| Hybrid (dependency → spatial → solve → analyze → accept/reject) | Matches the "generation stays upstream of `PuzzleDefinition`" constraint cleanly | High | High (solver gate at the end catches anything unrealizable) | High | High | Best long-term shape, but a lot of infrastructure to build before even the basic metrics have been checked against one real playtest |

## HUMAN CALIBRATION

Smallest useful loop, using what's already free from `PuzzleState.get_results()` (mistakes, accuracy) plus a few seconds of self-report per puzzle:

1. Author or select a small set of puzzles that each isolate one *currently untested* axis (a cascade puzzle, a dense+dependency-heavy puzzle, a two-bent-arrow puzzle) against a plain baseline.
2. Before playing, note the puzzle's predicted structural metrics (depth, width, fan-out, tracing load).
3. Play it; `PuzzleState.get_results()` already gives mistakes/score/accuracy for free.
4. Immediately record, per puzzle: perceived difficulty (1–5), whether the solution felt obvious, whether there was a memorable "unlock" moment, and roughly how many times you had to stop and scan the board.
5. Compare the 1–5 rating and "unlock moment" flag against the predicted structural metrics.
6. Adjust which metrics you trust as predictors before investing in a generator or a formal scoring function.

No telemetry, no new infrastructure — this is a five-line manual note per puzzle, reusing data the engine already computes.

## ROADMAP RECOMMENDATION

The evidence does **not** support generation-first (Option A). We don't yet have a validated model of what predicts human-perceived difficulty — we have exactly one human data point ("the eight puzzles are easy") and a set of metrics that measure breadth-of-choice but not perceptual cost or cascade effects. Building a generator now means optimizing toward an unvalidated target.

The evidence also shows the fastest, cheapest next step isn't a full difficulty-analysis subsystem (pure Option B) either — the engine already demonstrably supports richer structure than the catalog uses (the unshipped `create_fixed` board proves it), so a few *hand-authored* puzzles that deliberately hit the missing axes (cascade/fan-out, combined density+dependency, two-bent-arrow interaction) can validate or falsify the metric hypotheses in this report far faster than building generation infrastructure first.

**Recommendation: a hybrid of Option B and Option C.** Spec 006 should be a small, self-contained slice:
1. Add the objectively-computable missing metrics (initial legal ratio, dependency depth/width, max cascade fan-out, tracing-load figures) to `PuzzleSolver.analyze()` or an adjacent analysis module, keeping `PuzzleCatalog`/`PuzzleDefinition`/`PuzzleState`/`PuzzleSolver`'s existing boundaries intact.
2. Hand-author a small number of new puzzles (not a generator) that each deliberately isolate one of the axes this research found untested — especially a cascade puzzle (out-degree ≥2) and a puzzle combining density with real dependency depth.
3. Run the lightweight human-calibration loop above against them.

Defer an actual generator (dependency-first or hybrid, per the comparison above) to a later spec, once the metrics from step 1 have been checked against real playtest impressions from step 3. That ordering creates the smallest possible learning loop and avoids building generation infrastructure against an unvalidated objective.

## SPEC 006 INPUT

- **Rules stay unchanged.** Monotonic removal is proven to make strategic difficulty impossible; ArrowSpark's difficulty is perceptual (finding/tracing/recognizing legal moves) plus a soft scoring layer (`mistakes`/accuracy). Spec 006 should design for perceptual richness, not attempt strategic branching.
- **The real gap is combinatorial, not conceptual.** All 8 catalog puzzles isolate exactly one structural feature (bends, chain, branching, or density). None combine two. None has a cascade (out-degree ≥ 2 blocker). The legacy `create_fixed()` board (density 0.65) proves the engine already supports more than the catalog uses.
- **Concrete missing puzzle archetypes to target:** a cascade/"key arrow" puzzle, a puzzle combining high density with real dependency depth, a puzzle with two or more interacting bent arrows, a puzzle with a genuinely long-range hidden blocker on a larger board.
- **Metrics to add (all objectively computable today, no rule changes, no new heuristics):** initial legal move count/ratio, min/max legal choices per state, longest forced run, dependency depth, dependency width, dependency edge count, max in-degree (blockers per arrow), max cascade/unlock-per-removal (out-degree), board density, average/max arrow length, bend count/average bends per arrow, blocker distance (ray index).
- **Metrics that need a separate track (heuristic proxy or human data, not pure geometry):** visual/perceptual distance, scanning load, symmetry/ambiguity. Don't conflate these with the geometric metrics above when scoping work.
- **Generation approach ranking, if/when a generator is built:** dependency-first or a dependency→spatial→solve→analyze hybrid are the best fits (they directly target depth/width/fan-out); mutation is a good secondary/validation tool; pure random+validate and evolutionary search are premature until the metrics above are calibrated.
- **Architecture to preserve unchanged:** `PuzzleCatalog` (content selection) → `PuzzleDefinition` (geometry) → `PuzzleState` (rules) → `PuzzleSolver` (analysis) → presentation. Any new metrics module or hand-authored content must still produce/consume plain `PuzzleDefinition` objects so gameplay never needs to know whether a puzzle came from the catalog, a generator, or a test.
- **Recommended sequencing:** Spec 006 = structural metrics (extends `PuzzleSolver` or a sibling analysis module) + a small set of hand-authored puzzles targeting the untested axes + a lightweight manual playtest-calibration pass. Defer generator-building to a later spec once these metrics are checked against real play impressions.
