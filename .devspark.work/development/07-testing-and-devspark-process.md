# Testing and DevSpark Development Process

## DevSpark Workflow

ArrowSpark is being developed through the DevSpark lifecycle:

`specify → clarify → plan → tasks → analyze → implement → PR review → merge`

The workflow separates: - intent; - architecture/research; - executable
tasks; - coherence analysis; - adversarial technical criticism; -
implementation; - durable knowledge.

Specs are implementation-time artifacts. Durable understanding belongs
in code, tests, and `.knowledge`.

## Why ArrowSpark Has Been a Useful DevSpark Test

Game development introduces risks that are less common in
API/application work: - focus ownership; - keyboard/gamepad
accessibility; - scene lifecycle; - signals; - tweens; - node
disposal; - resize behavior; - pause behavior; - input ownership; -
logical state vs. presentation state; - animation completion barriers.

Spec 005 exposed this when Critic noticed that a Level Select menu
requirement for keyboard/gamepad use did not guarantee initial focus.

This motivated the idea of reusable Critic risk checklists for
game/Godot projects.

## Testing Layers

### Rule-level tests

Validate: - blocking; - legal removal; - ownership; - counters; -
completion; - solver behavior; - Open Move behavior.

### Structural validation

Validate: - puzzle geometry; - catalog identity; - solver-confirmed
solvability; - analyzer properties.

### Presentation/layout tests

Validate: - scene layout; - arrow geometry; - departure geometry; -
HUD/results behavior.

### Regression checks

Protect: - save behavior; - input behavior; - no accidental progress
reset; - known integration contracts.

### Manual desktop checks

Required where headless automation cannot reliably reproduce: - real
focus navigation; - gamepad behavior; - subjective visual feedback; -
animation feel; - window interactions.

## Spec 007 Analyze Gate

The Analyze gate reported: - 21/21 functional requirements mapped to
tasks; - 100% coverage; - no duplication; - no ambiguity; - no
constitution conflicts.

Two findings were raised.

### Context-resolution labeling defect

The plan described a formal `depends_on` relationship that the
repository's flat knowledge schema did not actually contain.

This was a context-integrity issue, not a product defect.

Lesson:

**DevSpark should never claim a knowledge graph edge that does not
exist.**

### appliesTo coverage gap

New scoreboard implementation/test paths were not reflected in relevant
knowledge-document `appliesTo` metadata.

Lesson:

**Knowledge discoverability is part of implementation correctness.**

## Spec 007 Critic Gate

Critic found no showstoppers and no critical technical risks.

Important findings included:

### Static scoreboard test isolation

`PuzzleScoreboard` uses static session state. Tests in one process could
leak state between cases.

Recommended solution: - use unique synthetic puzzle IDs per test case; -
do not add a production reset method solely for tests.

This is a strong example of protecting production design from test
convenience.

### Completed-state Open Move guard

Critic identified the need to explicitly test Open Move after
completion.

Without the guard, assistance could incorrectly mutate a finished
attempt.

This was a valuable lifecycle finding.

### Scoreboard input sanity

Critic suggested lightweight assertions for the shape/range of completed
result data.

The correct interpretation is: - validate contract sanity; - do not
reimplement scoring/completion rules in the scoreboard.

### Frontmatter metadata

Critic requested explicit: - `archetype: game`; -
`risk_profile: internal`; - `change_type: brownfield`.

These improve repeatability of future gate runs.

## Severity-System Lesson

The gate results exposed a DevSpark design consideration.

A "CRITICAL" finding can mean: - critical context-integrity defect

without meaning: - critical runtime/product risk.

Likewise a "HIGH" metadata finding may not represent high player impact.

A future DevSpark enhancement could separate: - severity; - impact
domain.

For example: - `severity: critical` - `impact_domain: context_integrity`

versus: - `severity: high` - `impact_domain: runtime_correctness`

This is not an ArrowSpark requirement, but it is a useful process
lesson.

## Spec 007 Automated Implementation Results

At the current snapshot: - Godot headless editor check exits 0. -
Failure markers all report zero: - `PUZZLE_FAILURES` -
`PUZZLE_ANALYZER_FAILURES` - `PUZZLE_CATALOG_FAILURES` -
`PUZZLE_SCOREBOARD_FAILURES` - `ARROW_DEPARTURE_GEOMETRY_FAILURES` -
`PUZZLE_LAYOUT_FAILURES` - `PUZZLE_PRESENTATION_FAILURES` -
`REGRESSION_FAILURES` - puzzle suite passed repeatedly; -
planning-reference check is clean.

## Manual vs. Automated Boundaries

One Spec 007 deviation is instructive.

A keyboard/gamepad test originally attempted simulated key presses
headlessly. That proved nondeterministic.

The implementation instead automated: - focus eligibility; - signal
wiring;

and retained real desktop verification for actual navigation.

This is the correct philosophy:

**Automate what the automation can reliably prove. Manually verify what
depends on real interactive behavior.**

Do not turn flaky simulation into false confidence.

## Planning Reference Discipline

The project continues to enforce that temporary spec/planning references
do not leak into durable code/knowledge.

This supports the DevSpark model: - specs guide implementation; -
current knowledge explains the resulting system; - production artifacts
do not depend on archived planning history.

## Future Testing Needs for Spec 008

Large viewport work will add new risk categories: - coordinate
transforms; - input after zoom/pan; - drag vs. click disambiguation; -
focus/navigation of off-screen content; - camera changes during
animation; - resize while transformed; - Fit Puzzle calculations; - Open
Move revealing an off-screen arrow.

These should become first-class Critic questions rather than ad hoc
discoveries.
