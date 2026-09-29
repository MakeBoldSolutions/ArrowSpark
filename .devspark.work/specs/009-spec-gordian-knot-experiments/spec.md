---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
classification: full-spec
risk_level: medium
archetype: game
change_type: brownfield
risk_profile: internal
target_workflow: specify-full
required_artifacts: spec, plan, tasks
recommended_next_step: plan
required_gates: checklist, analyze, critic
route_intent: full-spec
depends_on: []
supersedes: []
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Feature Specification: Gordian Knot Experiments

**Feature Branch**: `009-spec-gordian-knot-experiments`
**Created**: 2026-09-28
**Status**: Complete <!-- Valid: Draft | In Progress | Complete -->
**Input**: User description: "Spec 009 — Gordian Knot Experiments: hand-authored geometric-entanglement puzzle experiments with objective structural characterization and required human playtesting, investigating what makes a large, geometrically entangled puzzle satisfying to untangle."

## Product Owner TLDR

ArrowSpark's puzzles have grown from a fixed board to a large, freely
zoomable canvas, but the team still doesn't know what actually makes a big,
tangled puzzle *feel* satisfying to solve rather than merely large. This spec
adds a small, deliberately varied set of hand-authored experimental puzzles —
long arrows, interwoven paths, dense knots, regional structure, one big
payoff release, and a deliberately-too-far "spaghetti" case — measures their
objective structural properties, and requires a real human to actually play
each one and record what happened. The output is evidence, not more content:
a durable report comparing what was measured against what was felt, so the
next puzzle-design decision is grounded in an actual play session instead of
a guess.

## Rationale Summary

### Core Problem

The team does not yet know which forms of geometric complexity in a puzzle
translate into satisfying challenge for a player, versus which forms merely
look complicated or become tedious/unreadable. A prior investigation found
that raw structural complexity alone did not reliably produce felt
difficulty, and a separate change removed the physical screen as a
constraint on puzzle size — but neither result tells the team what kind of
"knot" is actually fun to untangle.

### Decision Summary

Hand-author a small set of experimental puzzles that each isolate one
geometric idea (long arrows, interwoven paths, dense knots, regional
structure, a big payoff removal, and a deliberately excessive case), measure
each one with the existing objective structural-analysis capability, then
have a human actually play every one and record structured observations
before drawing any conclusion.

### Key Drivers

- Product: puzzle-design confidence in what makes ArrowSpark's untangling
  experience satisfying, ahead of any future puzzle-generation investment.
- Prior finding: structural complexity did not, by itself, reliably produce
  felt challenge — this must be tested again with intentionally varied,
  larger-scale, geometry-focused content rather than assumed away.
- Technical enabler: puzzle size is no longer screen-constrained, so
  larger/denser experimental geometry is now presentable without
  compromising readability by forced shrinking.
- Player-safety constraint: every experiment must remain completable and
  assistable exactly as today's puzzles are — difficulty of understanding is
  the thing under test, not difficulty of finishing.

### Source Inputs

- Prior spec learning: objective structural complexity did not by itself
  produce felt challenge (documented lesson driving this investigation).
- Prior spec outcome: puzzle presentation is no longer limited to the visible
  screen; players can zoom, pan, and fit the whole puzzle to view.
- Existing objective puzzle-characterization capability, to be reused for
  measurement rather than duplicated or extended into a difficulty score.
- The existing large-board validation puzzle, authored to prove canvas
  behavior rather than to test this feature's hypotheses — a reference point
  for comparison, not one of this feature's experiments.

### Tradeoffs Considered

- Option A — Build a procedural generator to produce many candidate puzzles
  quickly, then filter by measured properties: rejected. This inverts the
  required investigation order (author → validate → characterize → play →
  compare) into "generate → measure → declare good," which is exactly the
  reasoning failure this feature exists to avoid, and it front-loads
  generator-design cost before the team knows what a generator should even
  optimize for.
- Option B — Skip human playtesting and rely on the objective measurements
  alone to judge each experiment: rejected. The core lesson motivating this
  work is that objective structural measurement did not, by itself, predict
  felt challenge; drawing conclusions from measurement alone would repeat
  that mistake.
- Option C (selected) — Hand-author a small, deliberately varied set of
  puzzles, each isolating one geometric idea, measure them objectively, then
  require a documented human play session before any comparison or
  conclusion is drawn. This is more effort per puzzle than either alternative
  but produces evidence the team can actually trust for the next
  puzzle-design decision.

### Architectural Impact

- Adds new puzzle content to the existing puzzle catalog using its current
  registration approach; no new content-loading mechanism.
- May add a small number of new descriptive structural metrics to the
  existing objective puzzle-characterization capability, strictly
  descriptive (never a single difficulty or entanglement score).
- Produces one new durable experiment report; does not alter any existing
  gameplay rule, scoring formula, assistance behavior, or save/settings
  data.
- No backward-compatibility concerns: this is additive content and
  additive, non-authoritative measurement only.

### Reviewer Guidance

Focus review on: (1) whether the experimental puzzles actually stay
completable and assistable under every existing player-facing guarantee,
never merely "hard to look at"; (2) whether any new structural metric stays
strictly descriptive and never collapses into an implied difficulty ranking;
(3) whether the experiment report honestly distinguishes what was measured
from what one player experienced, and never claims either recommends
generation of more puzzles.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Encounter a hand-authored knot and untangle it (Priority: P1) ✅ Complete

A player selects one of the new experimental puzzles and works through it
using the existing puzzle interactions: inspecting the board, selecting
arrows, receiving normal accepted/blocked feedback, watching removed arrows
depart, and reaching a completed board. The puzzle may look intimidating or
be genuinely hard to read, but there is always a legal move available and
the puzzle always finishes.

**Why this priority**: This is the entire product bet under test — if a
player cannot complete an experimental puzzle exactly like any other puzzle,
nothing else about the experiment is meaningful.

**Independent Test**: Can be fully tested by opening any one experimental
puzzle and playing it to completion using only existing puzzle interactions
(select, remove, receive blocked-move feedback and continue, request assistance), and
delivers a completed puzzle with a recorded result exactly like any existing
puzzle.

**Acceptance Scenarios**:

1. **Given** an experimental puzzle is loaded, **When** the player selects
   any arrow that is not currently legal, **Then** the player receives the
   same blocked feedback as any existing puzzle and the puzzle remains
   unsolved but still fully completable.
2. **Given** an experimental puzzle is loaded, **When** the player removes
   arrows one at a time following any legal order, **Then** the puzzle
   eventually reaches a fully completed state with a recorded result.
3. **Given** a player is unsure which arrow is currently legal, **When** the
   player requests assistance, **Then** the same assistance behavior used by
   every existing puzzle identifies one currently-legal arrow, exactly as it
   does today.

---

### User Story 2 - Use large-canvas navigation to make sense of a dense puzzle (Priority: P1) ✅ Complete

A player facing a visually dense or spread-out experimental puzzle uses
zooming, panning, and "fit to view" to inspect regions of the board closely
and to step back for an overview, the same navigation already available for
any large puzzle.

**Why this priority**: The investigation explicitly wants to observe whether
players actually use large-canvas navigation to reason about entangled
geometry; this only produces evidence if navigation genuinely works on the
new, larger/denser content.

**Independent Test**: Can be fully tested by opening a dense or large
experimental puzzle, using zoom/pan/fit-to-view to inspect it, and confirming
the player can identify and select any arrow anywhere on the board without
the puzzle needing to be artificially shrunk to fit.

**Acceptance Scenarios**:

1. **Given** a dense experimental puzzle is loaded, **When** the player uses
   "fit to view," **Then** the whole authored board is visible at once.
2. **Given** the player has zoomed into a region of a dense experimental
   puzzle, **When** the player pans to another region, **Then** arrows in
   that region remain selectable and their removal behaves identically to
   arrows anywhere else on the board.

---

### User Story 3 - Record a structured human playtest observation for each experiment (Priority: P1) ✅ Complete

After playing an experimental puzzle to completion, a reviewer records a
structured set of observations for that puzzle: perceived challenge,
tracing demand, whether removals felt satisfying, whether important
removals visibly simplified the board, how often assistance was used,
mistakes made, whether navigation was actually useful, whether arrows stayed
readable, and an overall qualitative verdict — clearly separating what was
observed in that one session from any general conclusion.

**Why this priority**: Human playtest observations are the feature's
required deliverable; without them, the objective measurements alone cannot
answer whether geometric entanglement is actually satisfying to untangle.

**Independent Test**: Can be fully tested by completing one experimental
puzzle and producing a recorded observation set covering every listed
dimension for that puzzle, distinguishable from the puzzle's objective
structural measurements.

**Acceptance Scenarios**:

1. **Given** a playtest session on one experimental puzzle has finished,
   **When** the observations are recorded, **Then** the record includes
   perceived challenge, tracing demand, satisfaction of removals, visual
   simplification, assistance usage, mistakes/result, navigation behavior,
   readability, and an overall qualitative verdict for that puzzle.
2. **Given** an experiment report exists, **When** it states whether a
   hypothesis was supported, contradicted, or inconclusive for a puzzle,
   **Then** that statement is visibly distinct from, and does not overstate,
   the single-session observation it is based on.

---

### User Story 4 - Compare objective measurements against human experience across experiments (Priority: P2) ✅ Complete

A reviewer reads the finished experiment report and compares each puzzle's
objective structural characteristics against its recorded human-playtest
observations, then reads a cross-experiment synthesis that answers whether
longer arrows increased satisfaction, whether interwoven geometry increased
challenge, whether regional structure made large boards more approachable,
and similar comparison questions — with any contradictions explicitly
recorded rather than smoothed over.

**Why this priority**: The comparison and synthesis is the actual product
value of this feature; without it, the individual puzzles and playtests are
just content and notes rather than usable design evidence.

**Independent Test**: Can be fully tested by reading the finished report and
confirming every experimental puzzle has both an objective-measurement
section and a human-observation section, plus a synthesis section that
answers the comparison questions and calls out any contradiction between
puzzles.

**Acceptance Scenarios**:

1. **Given** the experiment report is complete, **When** a reviewer reads
   any one puzzle's entry, **Then** it clearly separates objective
   measurements, the stated hypothesis, the human observations, and a
   cautious supported/contradicted/inconclusive verdict.
2. **Given** the experiment report is complete, **When** a reviewer reads
   the cross-experiment synthesis, **Then** it directly answers the
   comparison questions and explicitly notes any case where one experiment's
   evidence contradicts another's.

---

### Edge Cases

- What happens when a player deliberately plays the intentionally
  excessive/"boundary-pushing" experiment and finds it unpleasant to read?
  The puzzle must remain completable and assistable regardless; a negative
  reaction to that specific puzzle is expected, valid experimental evidence,
  not a defect to silently fix by simplifying the puzzle.
- What happens if a player never uses zoom/pan on a dense puzzle and instead
  stays at the default fitted view the whole time? The puzzle must remain
  fully playable either way, and that navigation choice itself is a
  recordable observation.
- What happens if a player relies heavily on assistance on one experimental
  puzzle? That is valid usage and valid evidence, not a failed playtest; the
  puzzle must behave identically to any puzzle at every assistance request.
- What happens if an experimental puzzle's dependencies are not obvious from
  the visible arrow heads alone (a stated goal for the densest experiments)?
  There must still always be at least one currently legal move available at
  every point in the puzzle, exactly as guaranteed for every existing puzzle.
- What happens to the large-canvas validation puzzle already in the catalog
  during this work? It is reviewed for useful prior evidence but is not
  silently relabeled as one of this feature's experiments; if it appears in
  any comparative playtest material, it is explicitly identified as a prior
  validation puzzle rather than one authored to test this feature's
  hypotheses.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The catalog of playable puzzles MUST gain approximately five to
  seven new hand-authored puzzles, each with a single, clearly stated
  experimental purpose distinct from the others (at minimum: a long-geometry
  baseline, an interwoven-paths case, a dense-knot case, a regional-structure
  case, a big-single-release case, and a deliberately excessive
  "boundary" case).
- **FR-002**: Every new experimental puzzle MUST be structurally valid and
  confirmed completable by the same solvability check every existing puzzle
  passes, including a full completion order with zero forced mistakes.
- **FR-003**: Every new experimental puzzle MUST remain completable through
  normal play, remain assistable by the existing "show me a legal move"
  capability, and remain navigable with the existing zoom/pan/fit-to-view
  capability, exactly as every existing puzzle already is.
- **FR-004**: None of the new experimental puzzles' authored size or density
  MUST be reduced merely to make them fit on a single unscaled screen; the
  existing large-canvas navigation capability is the intended way players
  inspect them.
- **FR-005**: Each new experimental puzzle MUST be objectively characterized
  using the existing structural-analysis capability, and that characterization
  MUST be recorded rather than used to decide whether the puzzle is good.
- **FR-006**: If additional descriptive structural measurements are needed to
  describe an experiment's geometry, at most a small number MAY be added to
  the existing structural-analysis capability, and any such addition MUST
  remain a plain descriptive count or ratio — never a single combined
  difficulty or entanglement score, and never used to gate which puzzles ship.
- **FR-007**: Every new experimental puzzle MUST actually be played by a
  human to completion, and that session's observations MUST be recorded
  covering, at minimum: perceived challenge, tracing demand, satisfaction of
  removals, whether important removals visibly simplified the board,
  assistance usage, mistakes and final result, whether navigation was
  actually used and useful, whether individual arrows stayed readable, and
  an overall qualitative verdict.
- **FR-008**: The recorded observations for every experiment MUST explicitly
  distinguish "observed in this playtest session" from any general
  design conclusion, and MUST NOT claim one session establishes a universal
  result.
- **FR-009**: A durable report MUST be produced covering every new
  experimental puzzle with: its purpose, its authored size/scale, its
  objective characteristics, its stated hypothesis, its solvability result,
  its human playtest observations, and a cautious
  supported/contradicted/inconclusive verdict for that puzzle's hypothesis.
- **FR-010**: The report MUST include a cross-experiment synthesis section
  that compares the experiments against each other and explicitly records
  any contradiction found between experiments, rather than resolving
  contradictions by preference.
- **FR-011**: The large-board puzzle already in the catalog from prior work
  MUST NOT be silently reclassified as one of this feature's experiments; if
  referenced anywhere in this feature's comparative material, it MUST be
  labeled as a prior validation puzzle rather than one authored to test this
  feature's hypotheses.
- **FR-012**: This feature MUST NOT change any existing puzzle's gameplay
  rules, the existing mistake/assistance scoring formula, existing
  save/settings data, or any existing puzzle's currently shipped content.
- **FR-013**: This feature MUST NOT introduce automatic puzzle generation,
  an authoritative difficulty formula, adaptive difficulty, player
  identity/profiles, or any persistence of gameplay state beyond the
  existing single-session boundary.

### Key Entities *(include if feature involves data)*

- **Experimental Puzzle**: One hand-authored puzzle layout added to the
  existing puzzle catalog, carrying a stable identity, a descriptive title,
  and a single stated experimental purpose (e.g., "tests whether long-arrow
  removal alone is satisfying before geometry becomes entangled").
- **Objective Structural Characterization**: The set of deterministic,
  non-perceptual structural measurements recorded for a puzzle (e.g., how
  many cells an arrow occupies, how many bends it has, how dense the board
  is) — descriptive facts about the authored geometry, never a difficulty
  judgment.
- **Human Playtest Observation**: The structured record of one person's
  actual play session against one experimental puzzle, covering perceived
  challenge, tracing demand, satisfaction, visual simplification,
  assistance usage, mistakes/result, navigation behavior, readability, and a
  qualitative verdict, explicitly scoped to that one session.
- **Experiment Report**: The durable document comparing every experimental
  puzzle's objective characterization against its human playtest
  observation, plus a cross-experiment synthesis, without declaring a single
  authoritative difficulty or entanglement formula.

### Assumptions and Dependencies

- The human playtest required by this feature is performed by the
  puzzle's author/reviewer during this feature's own development cycle
  (there is no separate external playtester pool or user-research process
  in this project); observations are recorded manually in the experiment
  report rather than through any telemetry or feedback-collection system,
  matching this project's existing no-telemetry, no-player-identity
  boundary.
- The optional "control" experiment (similar density, mostly short/simple
  arrows, for comparison against the geometric-entanglement experiments) is
  included only if it can be authored cheaply alongside the required set;
  its inclusion or omission does not change any other requirement in this
  spec.
- Exact board dimensions, arrow counts, path lengths, and bend counts for
  each experimental puzzle are authoring decisions made during planning and
  implementation, constrained only by this spec's stated purpose for each
  experiment (e.g., "long geometry baseline," "deliberately dense knot") —
  not fixed numeric targets in this spec.
- "A small number of" new descriptive structural metrics means the addition
  stays proportionate to describing this feature's experiments; no fixed
  numeric cap is set here, and any metric added must satisfy FR-006 (plain
  descriptive count/ratio, never a combined score).
- No context items were unavailable during drafting (`skipped_context` was
  empty); constitution constraints and prior-spec numbering were both
  successfully gathered and applied.

### Out of Scope

- Procedural or automatic puzzle generation of any kind.
- An authoritative difficulty score, entanglement score, or any composite
  rating formula declared as product truth.
- Adaptive difficulty, hint sequences beyond the existing single-arrow
  assistance capability, or automatic solving on the player's behalf.
- New arrow movement or blocking rules, or any change to the existing
  monotonic removal rule or existing assistance scoring formula.
- New lives/fail mechanics, persistent gameplay scores across sessions,
  player profiles, accounts/login, leaderboards, achievements, currencies,
  or any progression economy.
- Telemetry, a feedback-collection API, or any durable gameplay memory
  beyond the existing single-session boundary.
- Web or mobile deployment, monetization, advertising, major visual or
  animation redesign, or speculative rendering-performance work not directly
  required to keep the new large/dense experimental puzzles usable.
- Large-scale puzzle-authoring infrastructure beyond what is needed to
  hand-author this feature's small experimental set.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All new experimental puzzles (100%) are confirmed completable
  by the existing solvability check, with a full zero-forced-mistake
  completion order recorded for each.
- **SC-002**: Every new experimental puzzle (100%) is completed at least once
  by a human playtester, with a full structured observation record covering
  every required observation dimension for that puzzle.
- **SC-003**: Every new experimental puzzle (100%) has both an objective
  structural characterization and a human playtest observation recorded in
  the experiment report, allowing side-by-side comparison for every puzzle.
- **SC-004**: The experiment report's cross-experiment synthesis section
  directly answers every comparison question posed by this investigation
  (e.g., whether longer arrows increased satisfaction, whether interwoven
  geometry increased challenge, whether regional structure made large boards
  more approachable) and records any contradiction found between
  experiments rather than omitting it.
- **SC-005**: Zero existing puzzles, existing scoring behavior, existing
  assistance behavior, or existing saved player data change as a result of
  this feature; all pre-existing behavioral regression coverage is preserved
  and passes. Catalog-count and terminal-entry expectations may be updated
  solely to accommodate the appended puzzles; existing puzzle identity and
  geometry assertions remain intact.
- **SC-006**: No new authoritative single difficulty score, entanglement
  score, or procedural puzzle generator exists anywhere in the shipped
  result.
