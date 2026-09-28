# DevSpark Lessons from ArrowSpark

## 1. Spec-Driven Development Works for Games, But the Risks Differ

The basic DevSpark lifecycle translated well from application
development to Godot.

However, game development adds risks that ordinary CRUD/API specs may
not naturally emphasize: - focus; - input modes; - animation
lifecycle; - node cleanup; - resize; - pause; - visual state
precedence; - logical vs. presentation state; - subjective feel.

DevSpark should maintain archetype-specific Critic questions rather than
pretending every project has the same risk surface.

## 2. Critic Should Ask Questions, Not Assume Defects

A useful game checklist might ask: - Does a newly opened menu explicitly
establish focus? - Can hidden controls retain focus? - Can a tween
outlive/disconnect from its node? - What happens during pause? - What
happens during resize? - Can presentation state diverge from logical
state? - Is keyboard/gamepad behavior actually reachable? - Does an
animation completion barrier exist where needed?

The checklist should generate hypotheses for investigation, not
automatic findings.

## 3. Context Integrity Matters

Analyze caught a plan describing a formal `depends_on` relationship that
did not exist in the repository knowledge schema.

This is important.

An agent should not narrate a graph structure merely because it
conceptually feels true.

If DevSpark says a relationship was traversed, that relationship should
exist.

## 4. appliesTo Is Part of Knowledge Quality

A knowledge document can be correct but effectively invisible if its
metadata does not point to the files future agents will modify.

Therefore updating knowledge metadata belongs in implementation tasks.

## 5. Severity and Impact Domain May Need Separation

The Spec 007 gates exposed a terminology issue.

"Critical" can mean: - violation of DevSpark context integrity

without meaning: - severe player-facing defect.

Future output could distinguish: - severity; - impact domain.

Possible domains: - runtime correctness; - data integrity; - security; -
accessibility; - context integrity; - documentation; - test
reliability; - product contract.

## 6. Testability Should Not Pollute Production APIs

Critic's scoreboard finding is a good example.

Static session state complicates unit-test isolation.

The tempting response would be to add `reset()` to production solely for
tests.

The better response was to use distinct synthetic puzzle IDs per test.

DevSpark should favor preserving production contracts when tests can
isolate themselves cleanly.

## 7. Headless Simulation Has Limits

Keyboard/gamepad simulation proved nondeterministic headlessly.

The correct response was not to keep forcing the test until it
occasionally passed.

Instead: - automate focus eligibility and wiring; - retain a manual
desktop acceptance check.

DevSpark should explicitly recognize "manual verification is the correct
test" as a legitimate outcome.

## 8. Knowledge Schema Should Be Discoverable

The implementation discovered that `type: product` was rejected by the
knowledge index builder even though an existing branding document
already used it.

This indicates a DevSpark usability issue: - either `product` should be
supported; - or allowed values should be clearly constrained and
validated earlier.

The system should make invalid metadata hard to create.

## 9. Human Evidence Can Be More Valuable Than a Green Experiment

Spec 006 was an engineering success and a design contradiction.

All six puzzles met their analyzer targets.

The human still said they were too simple.

This is exactly what an evidence-driven workflow should surface.

A failed hypothesis is progress when the experiment is well constructed.

## 10. Smaller Specs Preserved Learning

It would have been easy to jump from: - solver

directly to: - procedural generation.

Instead the project discovered: - visual geometry; - departure
behavior; - content catalog; - structural analysis; - session
contract; - viewport needs.

Each step changed the understanding of what generation would eventually
need to optimize.

That is a strong argument for DevSpark's incremental specification
model.

## 11. "Vibe in Planning, Not Production" Fits Game Design Well

Game ideation benefits from exploration: - metaphors; - visual
references; - hypotheses; - strange experiments.

Production still benefits from: - explicit rules; - solver validation; -
deterministic tests; - architecture boundaries.

ArrowSpark demonstrates the DevSpark principle well:

**creative exploration can be loose; implementation contracts should be
precise.**
