```yaml
gate: analyze
status: pass
blocking: false
severity: info
summary: "FULL re-run after remediation. All 12 prior findings verified resolved. 33/33 requirements covered by 80 tasks, no traceability hallucinations, all 7 context_resolved ids resolve, no constitution violations. 3 new LOW findings, all residual wording: the plan's performance line, a research summary row, and one spec edge case. Nothing blocks /devspark.critic or /devspark.implement."
reviewed_artifacts:
  - path: spec.md
    hash: "abd3541be5513f43461bdc16487690f1188dc927"
  - path: plan.md
    hash: "e93ae84b2b010ae6c18bca8c0cd2620eb141fecc"
  - path: tasks.md
    hash: "8bf009f885131693e6b812b78db120c8791a2c92"
```

## Specification Analysis Report

**Degradation label:** `FULL` (spec + plan + tasks; research, data-model, contracts and quickstart also read). **Date:** 2026-10-02. **Branch:** `011-spec-web-showcase` (uncommitted remediation edits on top of `8120d00`). **Run:** 2nd, replacing the first report.

### Prior findings: verification

| ID | Prior severity | Verified | Evidence |
|---|---|---|---|
| F1 | medium | resolved | spec US3 scenario 3 now branches: storage available → pending queue with the "Saved on this device, not sent yet" notice; storage blocked → plain not-sent message |
| F2 | medium | resolved | Architectural Impact names the bounded client queue (≤5, 7-day expiry, browser only, no ids) and attributes server storage to the external API project |
| F3 | medium | resolved | plan Phase 5 points to FR-026 B / FR-031 / contracts; the plan Summary's SQLite sentence was also corrected. No SQLite or database wording remains in spec, plan, tasks, data-model or contracts |
| U1 | medium | resolved | FR-026 has a part A (client obligation, verified here) and part B (external requirements, not a Spec 011 verify failure) |
| C1 | medium | resolved | the R-4 scope (contract + T029) covers the landing, Play, loading/pre-play shell, Journey, header, footer, notice, menu/loading `.tscn` and `scenes/menus/**/*.gd` literals |
| C2 | medium | resolved | T030 documents the three group descriptions in the existing Level Select section, cites `tests/puzzle_layout_check.gd`, and adds `puzzle_select_menu.gd` to `appliesTo` |
| B1 | medium | resolved | SC-001 and T070 use a fixed profile: ≥25 Mbps down, ≤50 ms RTT, cold cache, with what to record |
| F4 | low | resolved | the plan's queue line matches FR-032 |
| F5 | low | resolved | the validation matrix says "against the mock" |
| F6 | low | resolved | the contract and T040 both use the "contains Reference Knot design detail" rule |
| F7 | low | resolved | tasks.md has a plan ↔ task phase map |
| T1 | low | resolved | every task (including T072, T030) carries `Implements` and linkage on its first line |

### New findings

| ID | Category | Severity | Location(s) | Summary | Recommendation |
|---|---|---|---|---|---|
| B2 | Ambiguity (residual) | LOW | plan.md:116 (Technical Context, Performance Goals) | Still says "under 30 s on typical home broadband (SC-001)". The spec's SC-001 is authoritative and now measurable, so this is drift, not ambiguity in force. | Replace with "under 30 s under the SC-001 profile (≥25 Mbps down, ≤50 ms RTT, cold cache)". |
| D1 | Inconsistency (supporting doc) | LOW | research.md:168 (R6 "Spoiler-word scan" row) | Describes the old, narrower scan scope (landing, Play, loading and menu `.tscn` only). The authority is contracts/site-content.md R-4 and T029, which are correct. | Point the row at contracts/site-content.md R-4, or list the full scope. |
| E1 | Underspecification | LOW | spec.md:223 (Edge Cases, "Malformed, oversized or off-origin submission") | Describes server behavior ("rejected by the endpoint… nothing is stored"), which is now an external requirement (FR-026 B), and doesn't say what the client shows on a `400`/`413`/`415` (data-model: the `invalid` state; FR-026 A: removed, not retried). | Reword it from the client's side: the client validates before sending, so this should not occur; if the endpoint returns 400/413/415, the reaction is dropped (not queued) with "This reaction couldn't be sent". Cite FR-026 B for the server's handling. |

### Coverage Summary Table

| Requirement | Has Task? | Task IDs |
|---|---|---|
| FR-001 | Yes | T012, T075 |
| FR-002 | Yes | T028, T036, T045, T046 |
| FR-003 | Yes | T012, T045 |
| FR-004 | Yes | T001, T002, T021, T025, T026, T028, T031, T072 |
| FR-005 | Yes | T012, T022, T028, T029 |
| FR-006 | Yes | T017, T022, T030 |
| FR-007 | Yes | T027, T028, T072 |
| FR-008 | Yes | T010, T028, T064 |
| FR-009 | Yes | T015, T019, T023, T030 |
| FR-010 | Yes | T035, T037, T043, T045 |
| FR-011 | Yes | T035, T044, T045 |
| FR-012 | Yes | T037, T038, T044, T045, T046 |
| FR-013 | Yes | T032-T034, T038, T039, T046, T048, T049 |
| FR-014 | Yes | T033, T034, T039 |
| FR-015 | Yes | T039-T043, T047, T048 |
| FR-016 | Yes | T040-T042, T044, T047, T049 |
| FR-017 | Yes | T052, T055-T058, T061 |
| FR-018 | Yes | T018, T050, T051, T054, T061, T068 |
| FR-019 | Yes | T016, T018, T020, T021, T024, T030, T052, T056 |
| FR-020 | Yes | T062, T073, T075, T077 |
| FR-021 | Yes | T062, T078 |
| FR-022 | Yes | T063-T067 |
| FR-023 | Yes | T001, T002, T004, T014, T023, T071, T080 |
| FR-024 | Yes | T068, T069, T071, T073, T074 |
| FR-025 | Yes | T003, T070, T072, T080 |
| FR-026 | Yes (part A, client) | T050, T052, T053, T055, T059, T060 (part B external; T060 handoff) |
| FR-027 | Yes | T005, T007-T011, T013, T075 |
| FR-028 | Yes | T003, T006, T008, T014, T031 |
| FR-029 | Yes | T013, T032, T047, T049, T079 |
| FR-030 | Yes | T020, T024, T031 |
| FR-031 | Yes (external) | T060, T076, T077 (handoff and owner close/purge only) |
| FR-032 | Yes | T051, T052, T054-T059, T061, T072, T076 |
| FR-033 | Yes | T079 |

### Constitution Alignment Issues

None. The Technology-section gap remains handled as prerequisite P1 (T003, which the owner approves before T006). Principles I-VI are unchanged from the plan's Constitution Check.

### Context Resolution Validity

All 7 `context_resolved` ids resolve (`arrow-puzzle`, `save-progression`, `gameplay-contract`, `game-visual-system`, `reference-puzzle-design-report`, `product-branding`, `arrowgame-constitution`). All are hop 0 in the flat ontology. No stale entries.

### Cross-Repo Dependencies

| Reference | Type | Body Coverage? | External Contract Evidence? | Notes |
|---|---|---|---|---|
| (none in frontmatter) | n/a | n/a | n/a | `depends_on`/`supersedes` are empty |
| MakeBoldSpark.com reactions endpoint | external contract (body) | Yes (External Contracts, FR-026 A/B, FR-031) | Yes: verbatim schema, enums, limits and responses in FR-026 and contracts/reactions-api.md | Server side explicitly external; Spec 011 verifies only part A |
| Azure Static Web Apps / DNS | external hosting (body) | Yes | n/a (owner action T068) | |

### Unmapped Tasks

None. All 80 tasks carry an `Implements` directive on their first line.

### Metrics

- Requirements: 33 functional, 14 success criteria
- Tasks: 80
- Coverage: 100% (33/33)
- Ambiguity count: 0 in force (B2 is residual plan wording)
- Duplication count: 0
- Traceability hallucinations: 0
- Critical: 0 · High: 0 · Medium: 0 · Low: 3

## Next Actions

- **Pass.** Proceed to `/devspark.critic`.
- The three LOW items are one-line wording fixes in plan.md:116, research.md:168 and spec.md:223. They can be applied now, or folded into critic remediation through a `/devspark.tasks` re-run.

```yaml
findings:
  - finding_id: analyze-F1
    severity: medium
    description: "US3 acceptance scenario 3 contradicted FR-032's pending-queue behavior."
    intent_cue: ""
    recommended_action: "none (resolved)"
    execution_mode: auto
    status: resolved
    outcome: "Scenario now branches on storage availability; verified in run 2."
  - finding_id: analyze-F2
    severity: medium
    description: "Architectural Impact omitted the browser pending queue and assigned server storage to Spec 011."
    intent_cue: ""
    recommended_action: "none (resolved)"
    execution_mode: auto
    status: resolved
    outcome: "Bounded client queue named; server storage attributed to the external API project."
  - finding_id: analyze-F3
    severity: medium
    description: "plan.md Phase 5 described an insert-only database table, contradicting FR-031."
    intent_cue: ""
    recommended_action: "none (resolved)"
    execution_mode: auto
    status: resolved
    outcome: "Replaced with pointers to FR-026 B, FR-031 and the contract; plan Summary's SQLite sentence also corrected."
  - finding_id: analyze-U1
    severity: medium
    description: "FR-026 mixed client and server obligations without marking the server ones external."
    intent_cue: "FR-026 must state which obligations Spec 011 verifies and which are external."
    recommended_action: "none (resolved)"
    execution_mode: selective
    status: resolved
    outcome: "FR-026 split into part A (client, verified here) and part B (external API requirements)."
  - finding_id: analyze-C1
    severity: medium
    description: "R-4 pre-play scan missed menu .gd strings and the Journey page."
    intent_cue: ""
    recommended_action: "none (resolved)"
    execution_mode: auto
    status: resolved
    outcome: "R-4 scope widened in contracts/site-content.md and T029 to every pre-play surface."
  - finding_id: analyze-C2
    severity: medium
    description: "Level Select group description lines had no knowledge-update task."
    intent_cue: ""
    recommended_action: "none (resolved)"
    execution_mode: auto
    status: resolved
    outcome: "T030 documents them in arrow-puzzle.md's Level Select section and adds puzzle_select_menu.gd to appliesTo."
  - finding_id: analyze-B1
    severity: medium
    description: "SC-001 used the unmeasurable 'typical home broadband'."
    intent_cue: "SC-001 must name the measurement connection profile."
    recommended_action: "none (resolved)"
    execution_mode: selective
    status: resolved
    outcome: "SC-001 and T070 use >=25 Mbps down, <=50 ms RTT, cold cache, with recorded fields."
  - finding_id: analyze-F4
    severity: low
    description: "plan.md queue description omitted savedOn, expiry and the full-queue rule."
    intent_cue: ""
    recommended_action: "none (resolved)"
    execution_mode: auto
    status: resolved
    outcome: "Plan line matches FR-032."
  - finding_id: analyze-F5
    severity: low
    description: "Validation matrix claimed browser checks prove the deployed endpoint."
    intent_cue: ""
    recommended_action: "none (resolved)"
    execution_mode: auto
    status: resolved
    outcome: "Now 'reaction client and pending queue against the mock'."
  - finding_id: analyze-F6
    severity: low
    description: "Spoiler rule for chapter 5 differed between the contract and T040."
    intent_cue: ""
    recommended_action: "none (resolved)"
    execution_mode: auto
    status: resolved
    outcome: "Both use the 'contains Reference Knot design detail' rule."
  - finding_id: analyze-F7
    severity: low
    description: "Plan and tasks phase numbering differ."
    intent_cue: ""
    recommended_action: "none (resolved)"
    execution_mode: selective
    status: resolved
    outcome: "Phase map added to tasks.md; no renumbering."
  - finding_id: analyze-T1
    severity: low
    description: "T072's Implements/linkage tail was not on its first line."
    intent_cue: ""
    recommended_action: "none (resolved)"
    execution_mode: auto
    status: resolved
    outcome: "Moved; T030 normalized the same way."
  - finding_id: analyze-B2
    severity: low
    description: "plan.md Technical Context still states the SC-001 target as 'typical home broadband', drifting from the fixed SC-001 profile."
    intent_cue: "The plan's performance goal must reference the SC-001 measurement profile, not a vague connection description."
    recommended_action: "Edit plan.md:116 to 'under 30 s under the SC-001 profile (>=25 Mbps down, <=50 ms RTT, cold cache)'."
    execution_mode: auto
    status: open
    outcome: ""
  - finding_id: analyze-D1
    severity: low
    description: "research.md R6 'Spoiler-word scan' row describes the old, narrower R-4 scope."
    intent_cue: ""
    recommended_action: "Edit research.md:168 to reference contracts/site-content.md R-4 for the scan scope."
    execution_mode: auto
    status: open
    outcome: ""
  - finding_id: analyze-E1
    severity: low
    description: "The spec edge case for malformed/oversized/off-origin submissions describes server behavior now owned by FR-026 B and omits the client's handling of 400/413/415."
    intent_cue: "The edge case must state the client-side outcome (dropped, not queued, with a 'couldn't be sent' message) and cite FR-026 B for server handling."
    recommended_action: "Reword spec.md:223 from the client's perspective and cite FR-026 B."
    execution_mode: auto
    status: open
    outcome: ""
```
