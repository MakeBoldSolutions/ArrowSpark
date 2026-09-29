---
gate: pr-review
status: warn
blocking: false
severity: warning
summary: "PRD4-01 resolved in published commit 973bc93; L-01 withdrawn. Desktop verification limitations remain disclosed."
---

# Pull Request Review: Add six Gordian Knot puzzles and structural experiment reporting

## Review Metadata

- **PR Number**: #2
- **Source Branch**: 009-spec-gordian-knot-experiments
- **Target Branch**: main
- **Review Date**: 2026-09-29 13:16:18 UTC
- **Last Updated**: 2026-09-29 14:15:21 UTC
- **Reviewed Commit**: 973bc9350cf681fd1012f047c4ab86d4e04df985
- **Publication Verified**: GitHub PR #2 head matches reviewed commit 973bc93; merge state CLEAN.
- **Reviewer**: devspark.pr-review
- **Constitution Version**: 2.0.1
- **Base Commit**: 0ea27a6a376ee95f39d6f3f434508ac8ea2c1c4d
- Source is not behind target. Remote head was rechecked during review.

## Revision Log

| Rev | Commit | Date | Critical | High | Medium | Low | CON | Test Command | Result |
|-----|--------|------|----------|------|--------|-----|-----|--------------|--------|
| 1 | bd61aa8 | 2026-09-29 | 0 | 0 | 1 | 1 | 0 | python tests/run_puzzle_regressions.py --godot godot; python tests/run_regressions.py --godot godot; python tests/run_puzzle_structural_report.py --godot godot | PASS (all three commands exit 0) |
| 2 | bd61aa8 hosted / 973bc93 local fix | 2026-09-29 | 0 | 0 | 1 pending publication | 0 | 0 | python tests/run_puzzle_regressions.py --godot godot; python tests/run_regressions.py --godot godot; python tests/run_puzzle_structural_report.py --godot godot | PASS (all three commands exit 0) |
| 3 | 973bc93 published | 2026-09-29 | 0 | 0 | 0 | 0 | 0 | Same commands as revision 2, exact same commit | PASS retained; GitHub publication verified |

## PR Summary

- **Author**: @markhazleton
- **Created**: 2026-09-29T12:51:20Z
- **Status**: OPEN, draft
- **Files Changed**: 55
- **Commits**: 3
- **Lines**: +20950 -39

## Stats

| Metric | Value |
|--------|-------|
| Files changed | 55 |
| Lines added | +20950 |
| Lines removed | -39 |
| Net lines | +20911 |
| Commit snapshot | 973bc93 |

Collected from Git numstat/shortstat and hosted context. Review concentrated on ten durable changed files and relevant launchers; temporary planning contents and archives were not used as review evidence. Below the 25-file and eight-follow-up-read limits.

## Executive Summary

- **Constitution Compliance**: PARTIAL; all six principles checked, desktop verification remains outstanding.
- **Durable Delta Consistency**: PASS; PRD4-01 is resolved in published commit 973bc93. No open PRD findings.
- **Security**: No issues identified in inspected durable delta.
- **Code Quality**: No runtime defect identified; L-01 withdrawn following explicit owner acceptance.
- **Testing**: PASS: puzzle regressions, persistence/input regressions, and structural report.
- **Documentation**: PASS; the hosted PR includes the verified planning-identifier correction.
- **Constitution Improvements**: None.

**Overall Assessment**: The six authored additions preserve the pure RefCounted rule boundary and existing catalog content. The authoritative knowledge paragraph now uses self-contained experiment descriptions.

**Approval Recommendation**: APPROVE. This is a local advisory recommendation, not a submitted GitHub review.

## Action Items

### Immediate Actions (Blocking — must resolve before merge)

- [X] **PRD4-01** `.knowledge/reference/gordian-knot-experiments.md:269` — Replace “Specs 006 and 009” with self-contained terminology such as “The structural and geometric puzzle experiments”. Preserve the actual design conclusions. FIXED - spec references are removed

### Recommended Improvements

- [x] **L-01** — Accepted as-is by the owner; not an issue and no action required. The summary stays in this PR.

### Constitution Improvements

None found.

## What's Good

- Existing fifteen puzzle definitions remain protected by geometry fingerprints.
- Full-catalog solver witness replay and alternate-legal-choice checks exercise all 21 entries.
- New canvas checks verify fit, transformed selection, and unchanged rule state during navigation.
- Measurements and aggregate human impressions are explicitly separated; no difficulty score is inferred.

## Findings Detail

### Critical Issues (Blocking)

None found.

### High Priority Issues

None found.

### Durable Delta Consistency Findings (Blocking)

| ID | Status | Type | File:Line | Issue | Fix |
|----|--------|------|-----------|-------|-----|
| PRD4-01 | Resolved | Planning-identifier leak; medium severity | .knowledge/reference/gordian-knot-experiments.md:269 | The original prose began “Specs 006 and 009 taught us about individual ingredients”. Temporary planning identifiers are prohibited in durable knowledge by shared preamble §0 and pr-review §6.5. | Published commit 973bc93 uses “The structural and geometric puzzle experiments”; no further action required. |

This is an explicit workflow rule, not an invented constitution violation; no constitution severity code applies. The constitution has no dedicated planning-identifier principle and no severity registry was present. A governance amendment is unnecessary to apply the existing workflow contract.

### Medium Priority Suggestions

No additional items. The original medium-severity PRD finding is resolved; no open medium findings remain.

### Low Priority Improvements

| ID | Status | Principle | File:Line | Issue | Recommendation |
|----|--------|-----------|-----------|-------|----------------|
| L-01 | Withdrawn | Review scope contract §1b | .devspark.work/specs/008-spec-large-zoomable-canvas/summary.md:1 | Owner explicitly accepts this summary in the PR as-is; not an issue. | No action required. |

Scope evidence is the changed path and the explicit second commit subject, not an inspection or assessment of the previous planning bundle. The owner accepted this scope on 2026-09-29. L-01 is withdrawn; its row remains for traceability.

### Constitution Improvements

None found.

## Constitution Alignment Details

| Principle | Status | Evidence | Notes |
|-----------|--------|----------|-------|
| I. Simple, Maintainable Code | Pass | Catalog builders use snake_case and the existing literal geometry construction pattern. | No dependency or unrelated abstraction added. |
| II. Prefer Project-Level Template Customization | Pass | Changes stay in project code/tests; no addon modification. | Existing template integration reused. |
| III. Accessible, Configurable Controls | Partial verification | Existing controls and remapping code unchanged; new canvas checks exercise all six boards. | “When changing input or menus, verify affected controls and navigation paths using the supported input methods (MUST).” Hardware/resolution evidence is incomplete and disclosed. |
| IV. Responsive Gameplay | No defect identified | Static catalog construction and existing rendering/input paths retained. | Headless checks cannot establish felt responsiveness. |
| V. Practical Gameplay Verification | Partial verification | Fresh automated validation plus aggregate human evidence described in current knowledge and PR body. | “Gameplay changes MUST receive Godot validation of affected scripts/scenes and a smoke test of affected gameplay.” Desktop matrix remains outstanding under the required-check disclosure rule. |
| VI. Preserve Saved Progress and Settings | Pass | Existing ids/order preserved; persistence/input regressions pass. | No save format or persistence behavior change. |

## Security Checklist

- [x] No hardcoded secrets identified in inspected durable additions.
- [x] No new untrusted input surface; launcher arguments use PowerShell argument forwarding.
- [x] Authentication/authorization: not changed.
- [x] SQL injection: no SQL changes.
- [x] XSS: no web output changes.
- [x] Dependencies: no new dependency manifest changes.

Temporary output artifacts were excluded from deep review; this is not a repository-wide secret audit.

## Testing Coverage

**Status**: Automated coverage proportionate to catalog/data changes; desktop coverage incomplete.

Update review reran the same three commands on local commit 973bc93: all exit 0; all nine puzzle counters and REGRESSION_FAILURES are zero, and the structural report has 21 valid/solvable entries. Logs: local temp files arrowspark-pr2-update-puzzle.log, arrowspark-pr2-update-save.log, arrowspark-pr2-update-report.log. Planning-reference scan, diff whitespace check, and knowledge-index check also pass. Hosted scope remains 55 files, +20950/-39; the local fix changes one line only and leaves aggregate branch churn unchanged.

Fresh execution uses Godot 4.7.2.stable.official.ed1daf0bf. Full launcher execution is justified by repository AGENTS.md requiring both regression launchers; the puzzle launcher has no file-selection CLI.

- `python tests/run_puzzle_regressions.py --godot godot`: exit 0; all nine failure counters zero. The null-definition analyzer assertion is intentionally exercised by tests/puzzle_analyzer_check.gd:368; it is not a new runtime failure. The launcher also completed real-project import and scene checks.
- `python tests/run_regressions.py --godot godot`: exit 0, REGRESSION_FAILURES=0. Corrupt save/config parse messages are expected negative-case recovery checks, not failed tests.
- `python tests/run_puzzle_structural_report.py --godot godot`: exit 0; all 21 entries valid/solvable. All six documented measurement blocks match current output line-for-line after indentation normalization. Solvability remains a catalog regression assertion, not merely a report exit-code inference.
- `python .devspark/scripts/build_knowledge_index.py --check`: exit 0. Index current; no entity documents are touched, so the entity-specific generation gate is not applicable.
- Godot 4.4.1 was not independently rerun in this review; earlier results are reported by current knowledge and the PR description.

Execution logs are in the local temp directory: `arrowspark-pr2-puzzle-tests.log`, `arrowspark-pr2-save-tests.log`, and `arrowspark-pr2-structural.log`.

## Test Inventory

Counts are `_check_*` functions, excluding runners, assertion helpers, and report-formatting functions.

| File | Main | Branch | Delta | Justification |
|------|------|--------|-------|---------------|
| tests/puzzle_catalog_check.gd | 11 | 12 | +1 | New catalog-entry checks; existing assertions extended. |
| tests/puzzle_canvas_check.gd | 25 | 26 | +1 | Navigation/selection checks for six additions. |
| tests/puzzle_structural_report.gd | 0 | 0 | 0 | Non-gating developer report. |
| **Total** | **36** | **38** | **+2** | No test functions removed. |

The old “canvas_validation is final” assertions were intentionally replaced by continuation checks. Generic last-entry no-op checks remain at tests/puzzle_catalog_check.gd:380.

## Documentation Status

**Status**: ADEQUATE; PRD4-01 correction verified in the hosted PR. Other inspected behavioral claims align with code and executable results. Aggregate human judgments are qualified as hypotheses, not validated universal laws. Flat knowledge nodes do not use structured entity evidence metadata; absence alone is not a finding.

## Changed Files Summary

| File | Tier | Changes | Type | Findings |
|------|------|---------|------|---------|
| scripts/puzzle/puzzle_catalog.gd | P1 | +175 -3 | Modified | None |
| run-app.ps1 | P2 | +17 | Added | None |
| tests/puzzle_canvas_check.gd | P2 | +30 -2 | Modified | None |
| tests/puzzle_catalog_check.gd | P2 | +39 -11 | Modified | None |
| tests/puzzle_structural_report.gd | P2 | +5 -2 | Modified | None |
| .knowledge/architecture/arrow-puzzle.md | P3 | +55 -18 | Modified | None |
| .knowledge/architecture/save-progression.md | P3 | +1 -1 | Modified | None |
| .knowledge/reference/gordian-knot-experiments.md | P3 | +271 | Added | PRD4-01 |
| .knowledge/index.json | P3 | +32 -1 | Generated | None |
| .knowledge/ontology/coverage.json | P3 | +1 -1 | Generated | None |
| Previous feature summary | P3 | +108 | Added | L-01 withdrawn; accepted as-is |
| Current feature temporary bundle (44 files) | P3 | Remaining delta | Added | Excluded from durable review; expected lifecycle placement. |

## Behavioral Changes

| Change | Before | After | Intentional? | Risk |
|--------|--------|-------|-------------|------|
| Catalog count | 15 | 21 | Yes | New data validated by full-catalog checks. |
| Next after canvas_validation | No next entry | First geometric experiment | Yes | Generic final-entry protection retained. |
| Structural report | Existing measures | Adds validity, occupancy, mean length, witness | Yes | Developer-readable output; no removed field. |
| Local app launch | Direct Godot invocation | Optional root PowerShell wrapper | Yes, second commit | Passes project path and arguments to Godot. |

## Deployment & Handoff Notes

### Deployment Notes

- Complete and record outstanding desktop mouse/keyboard/gamepad, remapping, readability, responsiveness, and window-size checks. Headless execution does not prove these. Under Finding Legitimacy Check §4C, a verify-only action stays here rather than becoming an inflated code finding.
- PR body predates the second commit: it still says 53 files and excludes two files now included in the 55-file delta. Update the body to reflect the current scope.
- Current feature planning artifacts are expected through merge under the shared preamble and review §1b; their presence is not a defect. The earlier create-pr lifecycle warning should not be carried forward as a review finding.

### Handoff Notes

None.

## Approval Decision

**Recommendation**: APPROVE

**Reasoning**: Hosted PR #2 now includes the verified repair in commit 973bc93. PRD4-01 is resolved and no new findings were introduced. L-01 remains withdrawn by owner instruction. Desktop validation remains explicitly incomplete and must not be represented as independently verified.

**Estimated Rework Time**: No further documentation rework needed. Desktop verification time unknown.

## Shared Review Resolution Contract

```yaml
findings:
  - finding_id: PRD4-01
    severity: medium
    description: Durable knowledge references temporary spec numbers at line 269.
    recommended_action: No action required; fix is published and verified.
    execution_mode: auto
    status: resolved
    outcome: "Fix verified in published commit 973bc93; GitHub PR head matches."
  - finding_id: L-01
    severity: low
    description: The changed previous-feature summary is outside this PR's feature bundle.
    recommended_action: No action required; retain the summary as-is.
    execution_mode: selective
    status: withdrawn
    outcome: "Owner accepted as-is on 2026-09-29; not an issue, no action required."
```

## Current Review State

PR #2 head is 973bc9350cf681fd1012f047c4ab86d4e04df985, matching the previously tested fix. PRD4-01 is resolved. L-01 remains withdrawn on explicit owner acceptance; no action required. No open findings remain. Recommendation: APPROVE, with disclosed desktop/input verification limitations retained. Existing passing tests apply to this exact commit; no redundant rerun was performed. No hosted review submission was made. Keep this report commit separate from code fixes.

