```yaml
gate: critic
status: pass
blocking: false
severity: info
summary: "No SHOWSTOPPER or CRITICAL findings. All three MEDIUM findings from the initial pass were validated and remediated directly in tasks.md (T005, T017, T018) in this run. VERDICT: PROCEED."
reviewed_artifacts:
  - path: .devspark.work/specs/004-spec-path-following-departure/spec.md
    hash: "cee5be947045b056c4d28847ebe6e96568051ef6"
  - path: .devspark.work/specs/004-spec-path-following-departure/plan.md
    hash: "8cbbf2aeed50299b9c516bb4bf60e2e2ef920bf4"
  - path: .devspark.work/specs/004-spec-path-following-departure/tasks.md
    hash: "d7b44acfac9423c1d6ddbfae3ab34e25f6098563"
  - path: .devspark.work/specs/004-spec-path-following-departure/data-model.md
    hash: "82f8649f695f96377865efd94ca2914a82b2d880"
  - path: .devspark.work/specs/004-spec-path-following-departure/contracts/presentation.md
    hash: "dd210271fb57a57c0c59119cd5655488567ab19b"
```

## Technical Risk Assessment

**Analysis Date:** 2026-09-26
**Scope:** FULL
**Detected Archetype:** game (Godot 4.4 project files; no explicit `archetype` frontmatter — inferred with high confidence from `project.godot` + GDScript, no ambiguity finding needed)
**Detected Stack:** GDScript + Godot 4.4 (Maaack's Game Template addon) + local `user://` save files; no network/server/auth surface
**Context Mode:** brownfield (per spec.md frontmatter `change_type`) — regression risk, backward compat, and rollback ease are the emphasis
**Risk Profile:** internal (per spec.md frontmatter `risk_profile`) — no severity shift applied
**Risk Posture:** GREEN

No stack/archetype risk checklists exist yet under `.devspark/risk-checklists/` or `.devspark.work/risk-checklists/`. Findings below were derived from first principles using the universal failure-mode lens (`resource_leaks | error_swallowing | race_conditions | unbounded_growth | missing_timeouts | missing_input_validation | trust_boundary_violations | non_idempotent_retries | silent_data_corruption`), calibrated to the `game` archetype's applicable categories (`dependency_supply_chain`, `testing_strategy`, `documentation`, `secrets_handling`, `trust_boundaries`, `error_handling_resilience`, `concurrency_async`, `binary_size_perf`). `secrets_handling`, `trust_boundaries`, `dependency_supply_chain`, and `binary_size_perf` produced no findings — this feature introduces no new dependency, no network/auth surface, and no asset-size change (confirmed against plan.md's "no new runtime dependency" and Technical Context).

### Executive Summary

This is a well-specified brownfield presentation change to a single-player, offline Godot puzzle game: no trust boundary, no persisted-data migration, and no new dependency. The plan and contract already anticipate the most dangerous failure mode for this kind of change — a departure that visually never finishes and blocks the results screen forever — by deriving the tail-cap clearance radius from `GameVisualStyle.BODY_WIDTH` (not a bare literal) and mandating an assertion that tail-cap dominance still holds. All three findings identified in the initial pass were validated and remediated directly in `tasks.md` in this run (user-requested fix-and-apply): T005 now requires the tail-dominance assumption as a hard runtime `assert()`, T018 now requires safe iteration over `_departing_views` against T014's completion-erase path, and T017 now includes a combined concurrent-departures + pause + resize scenario. **VERDICT: PROCEED.**

### Findings (source of truth)

```yaml
findings:
  - finding_id: critic-001
    category: error_handling_resilience
    archetype_applicable: true
    location: plan.md#Clearance-and-resize; contracts/presentation.md#Boundary-and-clearance; tasks.md#T005
    description: "The finish threshold (d = L + E + r + 0.001, r = BODY_WIDTH/2) correctly derives r from GameVisualStyle.BODY_WIDTH rather than a bare literal, and the contract requires asserting 'L+HEAD_BASE >= -r' (tail dominates rear support). But that assertion is described as something T005's test proves for current ratios, not explicitly as a permanent runtime assert() evaluated every time geometry is constructed. If a future visual-only tweak to GameVisualStyle (e.g., enlarging HEAD_BASE) shifts the rearmost support point to the head without anyone re-running tests/arrow_departure_geometry_check.gd first, departures could finish before the true silhouette has cleared the grid edge — a visible clipping pop, not a crash, but a regression that ships silently if the change lands without triggering the geometry regression suite."
    intent_cue: "This isn't 'add more test coverage' in the abstract — the specific behavioral intent is: any code path that changes which visual constant is rearmost must be unable to finish a departure early, and that guarantee should hold even for someone editing only game_visual_style.gd who doesn't realize it touches departure timing."
    base_severity: medium
    effective_severity: medium
    recommended_action: "In arrow_departure_geometry.gd (or wherever clearance_distance/rear_support is computed), make the tail-dominance check a runtime assert() (or explicit error-path in release builds) evaluated from live GameVisualStyle constants on every construction, not only a one-time unit-test assertion — so a debug build immediately fails if a future style edit invalidates the assumption, independent of whether the regression suite is rerun first."
    execution_mode: selective
    status: resolved
    outcome: "fixed — tasks.md:T005 now requires the tail-cap-dominance check to be a runtime assert() from live GameVisualStyle constants, not only a test-time assertion"
  - finding_id: critic-002
    category: concurrency_async
    archetype_applicable: true
    location: plan.md#Board-layout-and-clipping; plan.md#Completion-and-disposal; data-model.md#PuzzleBoard-collections
    description: "puzzle_board.gd's existing _layout_views() iterates `_views.keys()` directly (scenes/puzzle/puzzle_board.gd:99). The plan extends the same pattern to a new `_departing_views` dictionary for resize (T018), while a separate one-shot completion callback erases entries from that same dictionary (T014) and Godot signal emission is synchronous by default. If a departure's completion signal ever fires during the same call stack as a relayout's iteration over `_departing_views` (e.g., resize and completion coinciding in one frame), mutating a Dictionary while iterating its .keys() risks a skipped or corrupted iteration in GDScript. No task explicitly guards against this."
    intent_cue: "The intent isn't 'never mutate a dictionary' as a rule — it's that relayout and completion-driven removal are two independent triggers on the same collection, and nothing currently serializes them against each other."
    base_severity: medium
    effective_severity: medium
    recommended_action: "In the departing-views relayout loop, iterate over a duplicated key list (`_departing_views.keys().duplicate()`) or defer completion-triggered erasure to the end of the current frame (e.g., via call_deferred), matching the existing safe-iteration pattern already used elsewhere in this file."
    execution_mode: selective
    status: resolved
    outcome: "fixed — tasks.md:T018 now requires iterating _departing_views via a duplicated key list, guarding against T014's one-shot completion callback erasing an entry mid-relayout"
  - finding_id: critic-003
    category: testing_strategy
    archetype_applicable: true
    location: tasks.md#T013,T017,T019
    description: "T013 tests concurrent departures with reversed finish order; T017 tests resize/pause independently; T019 tests cancellation/disposal independently. No task combines concurrent multi-length departures + pause + resize in one scenario, which is exactly the combination most likely to expose an interaction bug (e.g., a paused short-route arrow and a still-moving long-route arrow both relaid out mid-resize while a third departure completes)."
    intent_cue: "Each axis (concurrency, pause, resize) is tested in isolation; the actual production risk is their intersection, which isn't reducible to the sum of the individual tests."
    base_severity: medium
    effective_severity: medium
    recommended_action: "Add one tests/puzzle_layout_check.gd scenario in Phase 5 that starts two+ departures of different route lengths, pauses mid-flight, resizes while paused, resumes, and asserts all finish exactly once with correct final geometry — extending T017 or T019 rather than adding a new task."
    execution_mode: manual
    status: resolved
    outcome: "fixed — tasks.md:T017 now includes a combined scenario (concurrent differing-length departures, paused mid-flight, resized while paused, resumed) asserting exactly-once completion; added FR-010 to T017's Implements list to reflect the exactly-once/no-negative-pending assertion it now also covers"
```

### High

_None — no HIGH findings._

### Missing Critical Tasks

- **Testing:** Resolved in this run — see critic-001, critic-002, critic-003 outcomes above.
- **Observability / Operations / Security:** Not applicable — single-player, offline, local-save desktop game with no network, auth, or telemetry surface in scope for this feature.

### Questionable Assumptions

1. **The tail cap always dominates rear support, so `clearance_distance` can assume tail-based `r` without recomputing from live style constants at construction time.** → Failure mode: a future `GameVisualStyle` edit (e.g., a larger head silhouette) shifts the true rearmost point to the head; departures finish while a sliver of geometry is still inside the grid, a visible-but-not-crashing regression that ships silently if the geometry test suite isn't rerun first (critic-001).
2. **Godot's per-node `_process` scheduling and NOTIFICATION_RESIZED dispatch never nest a departure's one-shot completion signal inside `_departing_views`' relayout iteration.** → Failure mode: if they ever do coincide in one frame, erasing a dictionary entry while iterating its keys can skip an entry or throw, leaving a stale departing view onscreen or a doubled completion count (critic-002).

### Estimated Technical Debt at Launch

- **Testing Debt:** None open — geometry, lifecycle, and concurrency axes are each covered, and the cross-axis combination (critic-003) and runtime-vs-test-time distinction (critic-001) were closed by amending tasks.md.
- **Code Debt:** Low — no shortcuts identified; the plan already avoids `Path2D`/`PathFollow2D`/physics per explicit user constraint and keeps the geometry helper pure.
- **Operational Debt:** None applicable to this archetype/scope.

### Metrics

- Showstopper: 0 | Critical: 0 | High: 0 | Medium: 3 (all resolved) | Low: 0 (effective severity)
- Findings by category: error_handling_resilience (1), concurrency_async (1), testing_strategy (1)
- Missing operational tasks: N/A (archetype has no observability/ops surface in scope)

**VERDICT:** PROCEED

**Required Actions Before Implementation:**

None — no SHOWSTOPPER or CRITICAL findings block starting `/devspark.implement`. All three MEDIUM findings from the initial pass were fixed directly in tasks.md in this run.

**Note on downstream gates:** `tasks.md`'s hash changed as part of this fix (`65b5a5a...` → `d7b44ac...`, see `reviewed_artifacts` above). `/devspark.analyze`'s previously recorded `tasks.md` hash is now stale; rerun `/devspark.analyze` before `/devspark.implement` if strict hash-matching gate pre-flight is enforced, though the edits here only added detail to existing tasks and one FR cross-reference (T017 gained FR-010) — no new/removed requirements or tasks.
```

---
Where you are: Critic gate complete for 004-spec-path-following-departure (FULL scope, VERDICT: PROCEED, 3 MEDIUM findings — all fixed)
Next: rerun /devspark.analyze to refresh its stale tasks.md hash, then run /devspark.implement
