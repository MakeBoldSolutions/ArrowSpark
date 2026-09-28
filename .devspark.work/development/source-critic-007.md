``` yaml
gate: critic
status: warn
blocking: false
severity: warning
summary: "FULL scope. No showstoppers or constitution violations. Two genuine, non-obvious testing-strategy traps found (static-var test isolation in the new PuzzleScoreboard check file; no completed-guard test for the Open Move assist), one defensive-programming gap (PuzzleScoreboard trusts caller-supplied results with no validation), and the three mandatory backward-compatibility findings for missing archetype/risk_profile/change_type frontmatter. VERDICT: CONDITIONAL."
reviewed_artifacts:
  - path: .devspark.work/specs/007-spec-open-move-scoring/spec.md
    hash: "ac74867c9dad4842bd3bd5d23fc9135d8438c157"
  - path: .devspark.work/specs/007-spec-open-move-scoring/plan.md
    hash: "9d0edca0b88bebdbb88dc09102cca38cc7b7db0a"
  - path: .devspark.work/specs/007-spec-open-move-scoring/tasks.md
    hash: "2a6201471b8c3fb5698e440a5c7e02b87161f12a"
```

## Technical Risk Assessment

**Analysis Date:** 2026-09-27 **Scope:** FULL **Detected Archetype:**
game (heuristic: `project.godot`, Godot 4.4 project structure --- no
`archetype` frontmatter present) **Detected Stack:** GDScript + Godot
4.4 + Maaack's Game Template addon; no persistent storage in this delta
**Context Mode:** brownfield (inferred: extends an existing, shipping
puzzle system --- no `change_type` frontmatter present) **Risk
Profile:** internal (default --- no `risk_profile` frontmatter present;
single-player local desktop game, no revenue/safety/regulatory exposure)
**Risk Posture:** YELLOW

### Executive Summary

This is a small, well-scoped, additive change to an existing
single-player offline Godot game --- no network, no auth, no secrets, no
persistent storage added, no concurrency in the traditional (threaded)
sense. Most of the critic registry's categories (`secrets_handling`,
`trust_boundaries`, `auth_authz`, `observability`,
`deployment_rollback`, `data_loss_continuity`, `regulatory_privacy`) are
genuinely not applicable to this archetype/delta and are noted as such
rather than padded with findings. The real risk surface is narrower and
testing-strategy-shaped: a new static-var class (`PuzzleScoreboard`)
with no reset method being unit-tested in a single process, and one
unspecified guard (Open Move after completion) that this codebase's own
existing pattern (`select_arrow()`'s completed guard) suggests should
exist but isn't yet explicitly tested for the new methods.

### Findings (source of truth)

``` yaml
findings:
  - finding_id: critic-001
    category: testing_strategy
    archetype_applicable: true
    location: "tasks.md#T024"
    description: "T024 creates tests/puzzle_scoreboard_check.gd to unit-check PuzzleScoreboard's established/improved/tied/not_improved outcomes and overall-score summation, but PuzzleScoreboard (per contracts/puzzle-state-and-scoreboard.md) exposes no reset method -- only record_attempt/get_best/get_overall_score. Godot check files run assertions as multiple test functions within one process (confirmed: tests/run_puzzle_regressions.py invokes each *_check.gd file as one subprocess, but does not isolate individual test functions within that file). Without a reset hook, later assertions in the same file inherit whatever _best_results state earlier assertions left behind, unless every test case deliberately uses a distinct puzzle_id."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "Amend T024 to require every test case in puzzle_scoreboard_check.gd to use a distinct, test-case-specific puzzle_id string (never a real PuzzleCatalog id, to also avoid accidental collision with catalog-driven tests) so static-state carryover between assertions cannot mask a bug. Do not add a production reset method solely for this -- that would put test-only surface on a class whose contract is otherwise fully described by three methods."
    execution_mode: selective
    status: open
    outcome: ""
  - finding_id: critic-002
    category: testing_strategy
    archetype_applicable: true
    location: "tasks.md#T010, research.md §2"
    description: "PuzzleState.request_open_move() is specified to skip incrementing open_move_assists and return null once completed is already true, 'mirroring select_arrow()'s own completed guard' (research.md §2). T010 lists deterministic-repeat, forced-state, independent-counters, and the 100%-accuracy case, but does not list an explicit post-completion request_open_move() case. Because this guard is easy to omit (it is one extra `if completed: return null` line with no compiler-enforced reminder), a regression here would let an assist request silently increment open_move_assists (and therefore alter score) on an attempt that has already ended -- exactly the kind of 'operates past its logical lifetime' bug the completed-guard exists to prevent."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "Amend T010 to explicitly add: call request_open_move() (and find_open_move()) after a puzzle is already completed and assert both return null with open_move_assists unchanged, exactly mirroring the existing completed-state coverage select_arrow() already has in tests/puzzle_regression.gd."
    execution_mode: selective
    status: open
    outcome: ""
  - finding_id: critic-003
    category: error_handling_resilience
    archetype_applicable: true
    location: "contracts/puzzle-state-and-scoreboard.md, tasks.md#T027"
    description: "PuzzleScoreboard.record_attempt's documented precondition is that the caller's result dict represents a genuinely completed attempt, but the contract explicitly states PuzzleScoreboard 'takes the caller's word for it and does not re-derive completion.' A future wiring bug (a stray call site, a copy-paste error introducing a second record_attempt call, or a refactor that calls it before _state.completed is actually true) would silently corrupt session-best/overall-score data with no error surfaced anywhere -- the bug would only be discoverable by a player noticing an implausible score, since nothing durable or crash-visible is affected."
    intent_cue: "record_attempt should fail loudly in development when handed a result it cannot trust, not silently accept whatever shape it's given."
    base_severity: high
    effective_severity: high
    recommended_action: "Add a debug-time assert in PuzzleScoreboard.record_attempt checking result has the five expected keys (total_arrows, mistakes, open_move_assists, score, accuracy) and score is a nonnegative int <= total_arrows, matching this codebase's existing precondition-assertion style (PuzzleState._init()'s assert(definition.is_valid(), ...)). This is a shape/sanity check, not a re-derivation of completion -- it does not reintroduce a second rules engine."
    execution_mode: selective
    status: open
    outcome: ""
  - finding_id: critic-004
    category: documentation
    archetype_applicable: true
    location: "spec.md frontmatter"
    description: "spec.md's frontmatter has no archetype field. Heuristics (project.godot present) confidently detect 'game', so this did not block or degrade this review, but the gap means a future critic run on this branch (or a differently-configured tool) could detect a different default and silently apply the wrong category registry."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "Add `archetype: game` to spec.md's frontmatter (or the project constitution's Technology section) so future gate runs don't depend on heuristic re-detection."
    execution_mode: auto
    status: open
    outcome: ""
  - finding_id: critic-005
    category: documentation
    archetype_applicable: true
    location: "spec.md frontmatter"
    description: "spec.md's frontmatter has no risk_profile field. Default 'internal' was applied for this review, which is almost certainly correct for a single-player offline game feature, but per this command's backward-compatibility rule the gap itself must be surfaced rather than silently defaulted."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "Add `risk_profile: internal` to spec.md's frontmatter to make the default explicit and stable for future gate runs."
    execution_mode: auto
    status: open
    outcome: ""
  - finding_id: critic-006
    category: documentation
    archetype_applicable: true
    location: "spec.md frontmatter"
    description: "spec.md's frontmatter has no change_type field. 'brownfield' was inferred from this being an additive extension to an already-shipping puzzle system, which is correct, but per this command's backward-compatibility rule the inference itself must be surfaced, not silently relied upon."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "Add `change_type: brownfield` to spec.md's frontmatter to make the inference explicit and stable for future gate runs."
    execution_mode: auto
    status: open
    outcome: ""
```

### Showstoppers

*None.*

### Critical

*None.*

### High

  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  ID           Category                    Location                                   Issue                                      Impact                 Suggestion
  ------------ --------------------------- ------------------------------------------ ------------------------------------------ ---------------------- ---------------------------
  critic-001   testing_strategy            tasks.md#T024                              New `PuzzleScoreboard` static-var test     False pass/fail in the Use a distinct `puzzle_id`
                                                                                      file has no reset hook; test cases can     new scoreboard test    per test case instead of
                                                                                      leak state into each other within one      suite, masking a real  adding a test-only reset
                                                                                      process                                    `record_attempt` bug   method

  critic-002   testing_strategy            tasks.md#T010                              No explicit test for                       A regression could     Add the post-completion
                                                                                      `request_open_move()`/`find_open_move()`   silently let the       case to T010, mirroring
                                                                                      after the attempt is already completed     assist fire (and       `select_arrow()`'s existing
                                                                                                                                 change score) on an    completed-state coverage
                                                                                                                                 attempt that already   
                                                                                                                                 ended                  

  critic-003   error_handling_resilience   contracts/puzzle-state-and-scoreboard.md   `record_attempt` trusts caller-supplied    A future wiring bug    Add a debug-time
                                                                                      result shape with zero validation          silently corrupts      shape/range assert,
                                                                                                                                 session-best/overall   matching this codebase's
                                                                                                                                 score with no visible  existing
                                                                                                                                 error                  precondition-assert style

  critic-004   documentation               spec.md frontmatter                        Missing `archetype` field                  Future gate runs       Add `archetype: game`
                                                                                                                                 depend on re-detection 
                                                                                                                                 instead of a stated    
                                                                                                                                 fact                   

  critic-005   documentation               spec.md frontmatter                        Missing `risk_profile` field               Future gate runs       Add
                                                                                                                                 default silently       `risk_profile: internal`
                                                                                                                                 instead of reading a   
                                                                                                                                 stated fact            

  critic-006   documentation               spec.md frontmatter                        Missing `change_type` field                Future gate runs infer Add
                                                                                                                                 silently instead of    `change_type: brownfield`
                                                                                                                                 reading a stated fact  
  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Missing Critical Tasks

*Observability / Security / Regulatory / Deployment-Rollback /
Data-Loss-Continuity: not applicable to this archetype and delta
(single-player, offline, no network, no persistent storage added, no
accounts) --- omitted rather than padded with findings that don't
apply.*

-   **Testing**: see critic-001/critic-002 above --- the only bucket
    with genuine gaps.

### Questionable Assumptions

1.  **`PuzzleScoreboard.record_attempt` will only ever be called once
    per completed attempt, from `arrow_puzzle.gd`'s `_show_results()`.**
    → Even if this assumption is ever violated (a duplicate call for the
    same attempt), the failure mode is self-limiting by construction: a
    duplicate call with an identical result dict compares as "tied"
    against itself and changes nothing, and `get_overall_score()` sums
    *stored bests* (one per puzzle id), never a running count of calls
    --- so accidental double-invocation cannot double-count the overall
    score. Confirmed safe by design; no finding needed, noted here so a
    reviewer doesn't have to re-derive this.
2.  **A lingering Open Move suggestion indicator is always fully hidden
    once the Results panel is shown.** → Currently true because
    `PuzzleResults` is a `mouse_filter = MOUSE_FILTER_STOP` full-rect
    overlay drawn last. Low probability of ever mattering and low impact
    if it did (a purely cosmetic pulse hidden behind an opaque panel)
    --- per this command's own "ignore low-probability AND low-impact"
    rule, not raised as a formal finding, only flagged here in case a
    future Results redesign makes the panel non-opaque or non-full-rect.
3.  **Godot's single-threaded signal/tween model means the
    in-flight-departure Open Move case (spec Clarifications, FR-021) has
    no true race condition, only a sequencing question already
    explicitly resolved.** → Confirmed: no genuine `concurrency_async`
    finding for this delta despite that category's inclusion in the game
    archetype's registry.

### Dependency Risk Assessment

*No new third-party dependency, addon, or package is introduced by this
feature --- it extends existing project scripts/scenes only. Not
applicable.*

### Estimated Technical Debt at Launch

-   **Code Debt**: Low --- two small new files (`puzzle_scoreboard.gd`,
    `puzzle_scoreboard_check.gd`), targeted additions to four existing
    files.
-   **Operational Debt**: None --- no new deploy/ops surface for a local
    desktop build.
-   **Documentation Debt**: Low, contingent on closing analyze-002
    (knowledge `appliesTo` gap) from the paired `/devspark.analyze` run.
-   **Testing Debt**: Medium until critic-001/critic-002 are addressed
    --- both are cheap (task-description edits, not new architecture).

### Metrics

-   Showstopper: 0 · Critical: 0 · High: 6 · Medium: 0 (effective
    severity)
-   Findings by category: testing_strategy (2),
    error_handling_resilience (1), documentation (3)
-   Missing operational tasks: none beyond the two testing gaps above

**VERDICT:** CONDITIONAL

**Required Actions Before Implementation:**

1.  Amend tasks.md#T024 to specify distinct per-case `puzzle_id`s
    (critic-001).
2.  Amend tasks.md#T010 to add the post-completion
    `request_open_move()`/ `find_open_move()` case (critic-002).

**Recommended Risk Mitigations:**

-   Add the debug-time shape assert to `PuzzleScoreboard.record_attempt`
    per critic-003 (selective --- reasonable to defer to implementer
    judgment if it adds meaningful clarity without over-engineering a
    single-player local class).
-   Add `archetype: game`, `risk_profile: internal`,
    `change_type: brownfield` to spec.md's frontmatter
    (critic-004/005/006) so future gate runs read stated facts instead
    of re-deriving them.
