---
pr: 9
devspark_version: "9.1.0"
reviewed_commit: 776ae49719f8af1b8ee4f387c4f57b24009cc50d
revision: 2
findings:
  critical: 0
  high: 0
  medium: 1
  low: 2
  con: 0
max_severity: medium
risk_rating: medium
risk_score: 6
risk_escalated: false
---

# Pull Request Review: Center any board point, add eight progression levels, start Play at the first

- **PR**: #9 — 013-spec-progression-pack → main — @markhazleton — OPEN
- **Reviewed Commit**: 776ae49719f8af1b8ee4f387c4f57b24009cc50d
- **Review Date**: 2026-10-14 12:32:22 UTC (last updated 2026-10-14 12:32:22 UTC)
- **Constitution Version**: 2.2.0

## Revision Log

| Rev | Commit | Date | Critical | High | Medium | Low | CON | Test Command | Result |
|-----|--------|------|----------|------|--------|-----|-----|--------------|--------|
| 1 | 776ae49 | 2026-10-14 | 0 | 0 | 1 | 2 | 1 | `python tests/run_puzzle_regressions.py` and `python tests/run_regressions.py` (Godot 4.4-stable, from an export of the PR head) | pass |
| 2 | a85cb09 | 2026-10-14 | 0 | 0 | 1 | 2 | 0 | no code changed; `build_knowledge_index.py --check` and knowledge-integrity pass; the two gates were not re-run | pass |

## Stats

| Metric | Value |
|--------|-------|
| Files changed | 198 (196 at rev 1; the platform sample returned only 100, all framework files; the 21 durable game, test and knowledge files were reviewed directly from the diff) |
| Commits | 5 |
| Lines | +8898 −1601 (durable game, test and knowledge delta: +762 −91 in 21 files) |
| Tiers (P0/P1/P2/P3) | script sample: 0 / 1 / 0 / 99, not representative; own assessment of the durable delta: game logic P1, tests P2, knowledge P3 |
| Risk | medium (6) — production_without_tests, large_diff, unmapped_production; the first and third come from the unrepresentative sample and were kept, never lowered |

## Executive Summary

**Overall Assessment**: A small, well-bounded presentation change (camera clamp, unclipped departures) plus eight new literal-data levels, with tests, knowledge and verification that agree with each other. No blocking findings; two minor documentation points and one governance suggestion. The script's risk factors came from a 100-file sample that contained only framework files, so the rating was kept at medium rather than lowered or recomputed.

- Constitution: PASS (6/6 principles checked) · Durable delta: PASS (0 open PRD findings)
- Security: 0 issues · Quality: 2 recommendations · Testing: PASS (both gates 0 failures on Godot 4.4 from the PR head) · Docs: PASS
- Constitution Improvements: 1 CON finding (resolved at rev 2)
- The change is verified as the author's closeout describes: `gates/closeout.md` is `complete`, 0 blocking defects, 0 unclassified, deferred items point at existing records.

## Action Items

### Immediate Actions (Blocking — must resolve before merge)

None found.

### Recommended Improvements

- [ ] **M-01** `.devspark.work/specs/013-spec-progression-pack/gates/closeout.md` (CO-003) — the accepted-limitation names the owner, but the owner confirmed the camera behavior generally and has not reviewed the specific exception. Ask for a one-line confirmation of the exception and record it.
- [ ] **L-01** `.knowledge/reference/progression-design-learning.md:34` — several per-level measurements (cross-gutter dependency counts, bridge degrees, key-arrow blocking, the nearest-arrow rescan count) came from an offline script that is not in the repository, so a reader cannot reproduce them.
- [ ] **L-02** commit `206c10a` — the subject "Refactor puzzle feedback and testing structure" does not describe what it contains (the camera clamp, unclipped departures and the eight levels). Use a squash merge with the PR title.

### Constitution Improvements (Non-blocking — feed into `/devspark-evolve-constitution`)

- [x] **CON-01** — *Fixed in a85cb09: Principle V now defines the supported desktop browsers (constitution 2.3.0)* — Principle V requires browser verification "in each supported desktop browser" but nothing defines the supported set, so the verification record cannot be checked against it.

## Findings Detail

### Critical Issues (Blocking)

None found.

### High Priority Issues

None found.

### Durable Delta Consistency Findings (Blocking)

None found. Checked: the clamp, the unclipped departure and margin, the catalog and Play-target statements in `arrow-puzzle.md`, `game-visual-system.md` and `save-progression.md` were compared with the code (`puzzle_viewport_transform.gd::_clamped_center`, `puzzle_board.gd`, `puzzle_feedback.gd`, `main_menu_with_animations.gd`, `puzzle_catalog.gd`); no stale clip or 0.001-margin claim remains in `.knowledge`; no spec, task or requirement identifier or `.devspark.work` path appears in the added durable lines; `build_knowledge_index.py --check` exits 0 at the PR commit with `stale_entities: []`.

### Medium Priority Suggestions

| ID | Status | Principle | File:Line | Issue | Recommendation |
|----|--------|-----------|-----------|-------|----------------|
| M-01 | 🔴 Open | Closeout contract §4 (accepted-limitation needs a real acceptor) | .devspark.work/specs/013-spec-progression-pack/gates/closeout.md (CO-003) | The recorded acceptor confirmed the desired camera behavior after play but did not review the zoom exception (the pointer point is not held when the camera-center bound or the Fit lock binds). The artifact says so honestly; it is not yet an explicit acceptance. | The owner confirms the exception in one line (PR comment or the artifact), then update `accepted_by`. |

### Low Priority Improvements

| ID | Status | File:Line | Issue and recommendation |
|----|--------|-----------|--------------------------|
| L-01 | 🔴 Open | .knowledge/reference/progression-design-learning.md:34 | The "checked directly" bullets rest on an uncommitted analysis script; add one sentence saying they come from an offline script not kept in the repo, or turn the cheap ones into assertions in the catalog check. |
| L-02 | 🔴 Open | commit 206c10a | Misleading subject for a commit that carries the feature; squash-merge with the PR title so main's history reads correctly. |

### Constitution Improvements

| ID | Status | Section | Observation | Suggested Amendment |
|----|--------|---------|-------------|---------------------|
| CON-01 | ✅ Resolved | §V Practical Gameplay Verification | The PR verifies Chrome, Firefox and two embedded browsers on desktop plus Chrome on one Android phone, but "each supported desktop browser" has no definition. | Add a short list of supported desktop browsers (or a minimum such as "current Chrome and Firefox") so the claim can be checked. |

## Constitution Alignment Details

**Passing**: 6 of 6 principles (N/A: 0)

I (simple code, snake_case: new helpers `_from_shapes` and the test functions comply), II (project-level change, no addon edit), III (input mapping untouched; keyboard menus confirmed), IV (constant-time math, no frame-loop work added), V (Godot validation, desktop and phone smoke recorded, gaps disclosed), VI (no saved data touched) all hold.

## Testing

**Status**: ADEQUATE — both gates pass on Godot 4.4 from an export of the PR head.

| Test file | Change |
|-----------|--------|
| tests/puzzle_viewport_transform_check.gd | old edge-margin clamp assertions replaced; corner reach, Fit lock and anchor stability added |
| tests/puzzle_canvas_check.gd | corner to center, held-key bounds, unclipped departure, every-catalog-size corner reach (23 sizes, 176 cases) |
| tests/puzzle_catalog_check.gd | counts, group order, pinned ids, titles, sizes and content versions of the eight levels |
| tests/puzzle_analyzer_check.gd | each level valid and solvable |
| tests/puzzle_presentation_check.gd | completion budget derived from the finish distance |
| tests/save_input_regression.gd | Play target |

Removed tests: none; two assertions were replaced because their premise (the old clamp, a 0.6 s departure) is intentionally changed.

## Changed Files

*Script output, pasted verbatim. The platform sample covered only the first 100 of 196 files and all of them are framework files; the durable game, test and knowledge delta is summarized under Testing and Durable Delta Consistency Findings, and the 21 files in it were reviewed directly from the diff.*

| File | Tier | Changes | Type |
|------|------|---------|------|
| .devspark/BSW.DevSpark.version | P1 | +2 -2 | Modified |
| .claude/commands/devspark-add-application.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-address-pr-review.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-analyze.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-checklist.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-clarify.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-closeout.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-commit-audit.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-constitution.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-context-projection.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-create-pr.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-critic.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-discover-constitution.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-discover-knowledge.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-evolve-constitution.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-explain.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-implement.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-list-applications.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-merge-from-main.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-migrate-knowledge-entities.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-migrate-registry.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-next.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-personalize.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-plan.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-planning-review.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-pr-review.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-quickfix.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-release.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-repo-story.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-site-audit.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-specify.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-tasks.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-taskstoissues.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-update-pr.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-upgrade.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-validate-registry.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-verify.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-workitem-create.md | P3 | +15 -0 | Added |
| .claude/commands/devspark-workitem-review.md | P3 | +15 -0 | Added |
| .devspark.work/specs/013-spec-progression-pack/checklists/requirements.md | P3 | +48 -0 | Added |
| ... 60 more P2/P3 files not listed | | | |

## Behavioral Changes

| Change | Before | After | Intentional? | Risk |
|--------|--------|-------|-------------|------|
| `_clamped_center` | camera kept the viewport edge inside the board; corners unreachable | center limited to the board rectangle above Fit; locked at Fit | Yes (PR description) | Zoom anchor can settle at the bound; documented, in M-01 |
| `EXIT_CLEARANCE_MARGIN_CELLS` | 0.001 | 6.0 | Yes | About 0.6 s more before Results |
| `DepartureClip.clip_contents` | true | false | Yes | Departing views draw past the board edge, still bounded by the board's own clip |
| `new_game()` target | `reference_knot` | `first_knot` | Yes | Play no longer opens the largest puzzle first |

## Deployment & Handoff Notes

### Deployment Notes

- The Web export must be built with Godot 4.4 and its templates (the CI does this); a 4.7 editor was not used for the shipped build.

### Handoff Notes

- Phone menu and Results readability (UI scale on small screens) and the admission-rule "too small" message are recorded as deferred work in `web-showcase.md`; owned by whoever takes the next phone-UI change.

### Observations

- The platform file sample stopped at 100 of 196 files and contained only framework files, so its risk tables were not pasted; they would have described the framework upgrade, not the game change.
- The framework upgrade (7.8.0 to 9.1.0) rides in this PR as earlier commits and is disclosed in the PR body; it is not part of the game change and inflates the file count.
- A test assertion (`does not step back in size`) encodes a design preference on level order; it is redundant with the pinned order and harmless.
- The departure margin at extreme zoom-out with the camera at an edge was not exercised in a browser; recorded as a learning in the closeout, not a defect.

## Approval Decision

**Recommendation**: ✅ APPROVE — no blocking findings; the two recommended items are documentation and merge-hygiene points that do not need to hold up the merge.

*Approval depends only on the durable delta, validation evidence, constitution, and unresolved findings.*

---

*Re-review after fixes: `/devspark-pr-review #9 re-review`. Address findings with `/devspark-address-pr-review 9`; commit the review file on its own.*
