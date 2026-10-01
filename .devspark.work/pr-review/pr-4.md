```yaml
gate: pr-review
status: warn
blocking: true
severity: warning
summary: "No security or save-data risk and both regression gates are green. Three blocking knowledge/code contradictions (stale statements in the architecture node), one focus-handling bug that leaves keyboard/gamepad focus on a hidden button, and the smoke-test-versus-completion tension with the constitution's verification principle need resolving before merge. The PR is a draft, which is appropriate."
```

# Pull Request Review: Add level groups, accordion Level Select, Back button and the Reference Knot

## Review Metadata

- **PR Number**: #4
- **Source Branch**: 010-spec-reference-puzzle
- **Target Branch**: main
- **Review Date**: 2026-10-01 16:14:06 UTC
- **Last Updated**: 2026-10-01 16:27:17 UTC
- **Reviewed Commit**: 313d5e636b2dd0083a20ef4b7956fbcb45a44cc1
- **Reviewer**: devspark.pr-review
- **Constitution Version**: 2.0.1

## Revision Log

| Rev | Commit | Date | Critical | High | Medium | Low | CON | Test Command | Result |
|-----|--------|------|----------|------|--------|-----|-----|--------------|--------|
| 1 | 313d5e6 | 2026-10-01 | 0 | 2 | 2 | 1 | 1 | `python tests/run_puzzle_regressions.py --godot godot` and `python tests/run_regressions.py --godot godot` | pass (both exit 0, all failure counters 0) |
| 2 | 4998d18 | 2026-10-01 | 0 | 1 | 1 | 1 | 1 | same two commands | pass (both exit 0, all failure counters 0); open rows are owner-accepted or decided (H-01, M-02), history (L-01) and a referral (CON-01) |

## PR Summary

- **Author**: @markhazleton
- **Created**: 2026-10-01
- **Status**: OPEN (draft)
- **Files Changed**: 84
- **Commits**: 17
- **Lines**: +5733 -106

## Stats

| Metric | Value |
|--------|-------|
| Files changed | 84 |
| Lines added | +5797 |
| Lines removed | −116 |
| Net lines | +5681 |
| Code/test lines (scripts, scenes, tests) | +830 −86 |
| Commit snapshot | `4998d18` |

*Collected from the PR context and `git diff --numstat`.*

## Executive Summary

- ✅ **Constitution Compliance**: FAIL (6/6 principles checked: 3 pass, 3 partial — I, III and V)
- 🔄 **Durable Delta Consistency**: FAIL (3 open PRD findings — all stale statements in one knowledge node; no planning-identifier leak found)
- 🔒 **Security**: 0 issues found
- 📊 **Code Quality**: 3 recommendations
- 🧪 **Testing**: PASS (both gates exit 0)
- 📝 **Documentation**: ADEQUATE apart from the stale statements above
- 🏛️ **Constitution Improvements**: 1 CON finding

**Overall Assessment**: A well-scoped, well-tested feature whose behavior change is intentional and additive: groups are metadata, the rule core is untouched, and the analyzer change is equivalence-tested. The blockers are documentation truth (three claims in the architecture node no longer match the code), one reproducible focus bug in the new accordion, and the unresolved question of how to treat the manual smoke test the constitution requires.

**Approval Recommendation**: ⚠️ REQUEST CHANGES
*Note: approval depends only on the durable delta, validation evidence, constitution, and unresolved findings.*

## Action Items

### Immediate Actions (Blocking — must resolve before merge)

- [x] **PRD1-01** `.knowledge/architecture/arrow-puzzle.md:283` — The node says `canvas_validation` is "puzzle 15, reached by Next after puzzle 14". Level Select and the HUD now number it within its group (7th in Puzzle Lab), and Next only advances inside a group. — **Fix**: rewrite as "the seventh Puzzle Lab entry, reached by Next from `composed_shaped`". — *Fixed in 4998d18: canvas_validation text corrected to the seventh Puzzle Lab entry reached from composed_shaped*
- [x] **PRD1-02** `.knowledge/architecture/arrow-puzzle.md:753` — The node says "the last catalog puzzle's results omit `%NextPuzzleButton`". The check now plays the last Foundations entry, and a group's final puzzle shows `%LevelSelectButton` instead. — **Fix**: "a group-ending puzzle's results omit Next Puzzle and show Level Select". — *Fixed in 4998d18: group-ending results now described as omitting Next Puzzle and showing Level Select*
- [x] **PRD1-03** `.knowledge/architecture/arrow-puzzle.md:870` — The node says Level Select stays hidden and is "unreachable from this menu". `main_menu_with_animations.tscn` has `LevelSelectButton` with `visible = true`, and this PR makes Level Select central (Results and Back both return to it). — **Fix**: correct the paragraph; keep the Continue-hidden statement only if it is still true. — *Fixed in 4998d18: Level Select described as visible, with Results and Back returning to it*
- [x] **H-02** `scenes/menus/main_menu/puzzle_select_menu.gd:71` — Focus is sent to a hidden button after the first group is collapsed (see below). — *Fixed in 4998d18: initial focus goes to the first visible entry or first header; layout check for collapse, close, reopen added*
  - **Broken code**: `_first_button.grab_focus()`
  - **Fix**: focus the first visible entry, or the first group's header when its entries are collapsed.
- [ ] **H-01** — Smoke-test gap versus Principle V (see below). **Fix**: either run the manual smoke test and record the result, or keep completion claims below "Complete" and merge only with an explicit, recorded owner acceptance. — *Owner acceptance recorded 2026-10-01 in the PR; the smoke test is NOT performed and not counted as a pass. Not a fix.*

### Recommended Improvements

- [x] **M-01** `tests/puzzle_catalog_check.gd:399` and `tests/run_puzzle_regressions.py:83` — The densest board gets only a sampled order-independence check (every sixth branching state) so the script fits a 45 s timeout. Raising that script's timeout would restore the full check. — *Fixed in 4998d18: full order-independence check restored; launcher timeout raised to 180 s*
- [ ] **M-02** `scenes/puzzle/arrow_puzzle.gd:79` — The F3 developer readout adds an always-on per-frame `_process`, has never been seen working on a real desktop, and was added only to gather evidence that was not collected. Decide whether to keep it; if kept, call `set_process(false)` until the label is shown. — *Left as is by owner decision 2026-10-01; no change made.*
- [ ] **L-01** — Three commits in this PR are unrelated to the feature: an addon return-type/UID fix, three series articles, and a conversation timeline file. — *Not addressed: separating the commits would rewrite history. Noted in the PR.*

### Constitution Improvements (Non-blocking — feed into `/devspark.evolve-constitution`)

- [ ] **CON-01** — Principle V has no way to record an owner-accepted unrun check; see below. — *Referred to /devspark.evolve-constitution; no constitution change made here.*

## What's Good

- Groups are pure metadata: `puzzle_state.gd`, `puzzle_solver.gd`, `puzzle_definition.gd`, scoring and the viewport transform are unchanged (verified from the diff).
- The analyzer change keeps the exhaustive search for cyclic graphs and is checked against it on 200 seeded random acyclic graphs, plus a layered graph the old search could not finish.
- No new persistence: the Level Select request is an in-memory one-shot, and a test asserts progress is untouched.
- Limitations and deferrals are stated plainly in the PR body rather than buried, and the gate file keeps a "not observed" list.
- Planning-identifier hygiene: the planning-reference check reports nothing for the changed code, tests and knowledge files.

## Findings Detail

### Critical Issues (Blocking)

None found.

### High Priority Issues

| ID | Status | Principle | File:Line | Issue | Fix |
|----|--------|-----------|-----------|-------|-----|
| H-01 | 🔴 Open | V. Practical Gameplay Verification ("MUST receive … a smoke test of affected gameplay … If a required check cannot be run, disclose that limitation and leave it outstanding rather than claim completion") | `.devspark.work/specs/010-spec-reference-puzzle/spec.md` status and `gates/verify.md` | Menu, pause-adjacent, results and input paths changed. No manual desktop smoke run, physical keyboard traversal or gamepad check was done (automated input-event checks only). The limitation is disclosed and the PR is a draft, which satisfies the "disclose" half. The planning status says Complete and the verify gate says pass, which sits uneasily with "leave it outstanding rather than claim completion". | Run the smoke test (about 15 minutes; the steps are in the working quickstart) and record the result, or keep the claim below Complete and record an explicit owner acceptance with the PR as the place it is stated. |
| H-02 | 🔴 Open | III. Accessible, Configurable Controls ("Preserve keyboard/gamepad navigation … MUST") | `scenes/menus/main_menu/puzzle_select_menu.gd:71` | Reproduced with a throwaway headless script: collapse the first group, close and reopen Level Select, and `gui_get_focus_owner()` is a hidden button (`visible in tree: false`). A keyboard or gamepad user then has an invisible focus; Enter would activate a hidden entry. | Replace `_first_button.grab_focus()` with a helper that picks the first entry whose `is_visible_in_tree()` is true, falling back to the first group header. Add a layout check for collapse, close, reopen. |

### Durable Delta Consistency Findings (Blocking)

| ID | Status | Type | File:Line | Issue | Fix |
|----|--------|------|-----------|-------|-----|
| PRD1-01 | 🔴 Open | Code/knowledge contradiction | `.knowledge/architecture/arrow-puzzle.md:283` | `canvas_validation` described as puzzle 15 reached after puzzle 14; code numbers it 7th in Puzzle Lab and Next is group-scoped | Update the sentence |
| PRD1-02 | 🔴 Open | Code/knowledge contradiction | `.knowledge/architecture/arrow-puzzle.md:753` | "the last catalog puzzle's results omit `%NextPuzzleButton`" — group-ending puzzles now show Level Select | Update the sentence |
| PRD1-03 | 🔴 Open | Code/knowledge contradiction | `.knowledge/architecture/arrow-puzzle.md:870` | "Level Select stay hidden … unreachable from this menu" contradicts the scene (`LevelSelectButton` visible) and the new Results/Back return path | Correct the paragraph |

### Medium Priority Suggestions

| ID | Status | Principle | File:Line | Issue | Recommendation |
|----|--------|-----------|-----------|-------|----------------|
| M-01 | 🔴 Open | V. Practical Gameplay Verification | `tests/puzzle_catalog_check.gd:399`, `tests/run_puzzle_regressions.py:83` | Sampling the order-independence check for the most complex board reduces the proof where risk is highest, to fit a 45 s per-script timeout | Raise that script's timeout (the sampled run is 36 s, the full one 51 s) and drop the sampling |
| M-02 | 🔴 Open | I. Simple, Maintainable Code ("justify new abstractions") | `scenes/puzzle/arrow_puzzle.gd:79` | F3 readout code runs `_process` every frame even when unused; unverified on a real desktop; its purpose (a cell-size measurement) was not achieved | Remove it, or keep it with `set_process(false)` until shown |

### Low Priority Improvements

| ID | Status | Principle | File:Line | Issue | Recommendation |
|----|--------|-----------|-----------|-------|----------------|
| L-01 | 🔴 Open | II. Prefer Project-Level Template Customization | `addons/maaacks_game_template/base/scenes/menus/options_menu/option_control/option_control.gd` | An addon edit and unrelated docs/timeline commits ride in this PR; Principle II asks that addon edits be justified | Split the unrelated commits into their own PR, or state in the PR body why the addon change is needed |

### Constitution Improvements

| ID | Status | Section | Observation | Suggested Amendment |
|----|--------|---------|-------------|---------------------|
| CON-01 | 🔴 Open | V | The principle allows disclosing a check that "cannot be run" but not an owner-accepted decision not to run it, so the same shortfall reads as a violation or as a pass depending on wording. | Add: an owner-accepted unrun check is recorded as an accepted limitation with a stated reason and does not by itself block completion. |

## Constitution Alignment Details

| Principle | Status | Evidence | Notes |
|-----------|--------|----------|-------|
| I. Simple, Maintainable Code | ⚠️ Partial | `arrow_puzzle.gd:79` | snake_case and typing fine; F3 readout questionable (M-02) |
| II. Prefer Project-Level Template Customization | ✅ Pass | Game logic lives in project scripts and scenes | Unrelated addon commit noted (L-01) |
| III. Accessible, Configurable Controls | ⚠️ Partial | `puzzle_select_menu.gd:71` | Focus bug (H-02); physical input not verified (H-01) |
| IV. Responsive Gameplay | ✅ Pass | No blocking frame-loop work added | Idle `_process` noted (M-02) |
| V. Practical Gameplay Verification | ⚠️ Partial | Gates green; smoke test not run | Disclosed (H-01, M-01, CON-01) |
| VI. Preserve Saved Progress and Settings | ✅ Pass | `tests/save_input_regression.gd` | No persistence added; progress untouched |

## Security Checklist

- [x] No hardcoded secrets or credentials
- [x] Input validation present where needed (catalog helpers return safe values for unknown ids)
- [x] Authentication/authorization checks appropriate (not applicable)
- [x] No SQL injection vulnerabilities (no database)
- [x] No XSS vulnerabilities (no web output)
- [x] Dependencies reviewed for vulnerabilities (none added)

## Testing Coverage

**Status**: ADEQUATE

Both launchers exit 0 on the PR head (`313d5e6`): `run_puzzle_regressions.py` with every failure counter 0, `run_regressions.py` with `REGRESSION_FAILURES=0`. New coverage: catalog groups and group-scoped progression, grouped Level Select and accordion, group-end Results, Level Select request, Back wiring, tab order, analyzer shortcut equivalence, F3 readout. Gaps: collapse-then-reopen focus (H-02), sampled order-independence for the densest board (M-01), no real scene change on Back, no physical-device input.

## Test Inventory

| File | Main | Branch | Delta | Justification |
|------|------|--------|-------|---------------|
| `tests/puzzle_analyzer_check.gd` | 15 | 18 | +3 | N/A |
| `tests/puzzle_canvas_check.gd` | 26 | 26 | 0 | N/A (assertions updated) |
| `tests/puzzle_catalog_check.gd` | 12 | 14 | +2 | N/A |
| `tests/puzzle_layout_check.gd` | 15 | 19 | +4 | N/A |
| `tests/save_input_regression.gd` | 3 | 3 | 0 | N/A (assertions updated) |
| **Total** | 71 | 80 | +9 | |

Removed tests: none (function counts counted by `_check`/`_test` prefix).

## Documentation Status

**Status**: INADEQUATE until PRD1-01 to PRD1-03 are fixed. The new design report and the rest of the architecture node are accurate.

## Changed Files Summary

| File | Tier | Changes | Type | Findings |
|------|------|---------|------|---------|
| `scripts/puzzle/puzzle_catalog.gd` | P1 | +242 | Modified | None |
| `scripts/puzzle/puzzle_analyzer.gd` | P1 | +57 | Modified | None |
| `scripts/puzzle_session.gd` | P1 | +25/−10 | Modified | None |
| `scenes/menus/main_menu/puzzle_select_menu.gd` | P1 | +61 | Modified | H-02 |
| `scenes/puzzle/arrow_puzzle.gd` | P1 | +64 | Modified | M-02 |
| `scenes/puzzle/puzzle_results.gd` / `.tscn` | P1 | +20 | Modified | None |
| `scenes/menus/main_menu/main_menu_with_animations.gd` | P1 | +18 | Modified | None |
| `tests/*` (5 check files, launcher, README) | P2 | +780/−87 total with code | Modified | M-01 |
| `.knowledge/architecture/arrow-puzzle.md` | P3 | edited | Modified | PRD1-01, PRD1-02, PRD1-03 |
| `.knowledge/reference/reference-puzzle-design-report.md` | P3 | new | Added | None |
| `.devspark.work/**` | working records | bundle for this PR's own feature | Added | None (expected to ride in the diff) |

## Behavioral Changes

| Change | Before | After | Intentional? | Risk |
|--------|--------|-------|-------------|------|
| `PuzzleSession.has_next()` / `advance_to_next()` | Next in catalog order | Next within the current group; false at the group's end | Yes (PR description) | Callers outside the puzzle scene would see no next entry at a group's end; none exist |
| Main-menu Play (`new_game()`) | Started the first catalog entry | Starts `reference_knot` | Yes (PR description) | None |
| Results buttons | Next shown unless last catalog entry | Next, or Level Select at a group's end | Yes (PR description) | Covered by checks |
| Puzzle labels and Level Select numbers | Global position | Position within the group | Yes (PR description) | Cosmetic |
| Analyzer longest chain | Exhaustive search | Linear time when acyclic; exhaustive when cyclic | Yes (PR description) | Equivalence tested; none expected |

## Deployment & Handoff Notes

### Deployment Notes

None.

### Handoff Notes

- Gate schema: the DevSpark verify gate defines pass as every declared mode passing and gives `warn` no meaning; it has no field for accepted limitations, and tooling treats any non-pass as pending — owned by the DevSpark framework maintainers — a defined accepted-limitations field.

## Approval Decision

**Recommendation**: ⚠️ REQUEST CHANGES

**Reasoning**: No security, data or rule-core risk, and the automated evidence is strong. Three stale statements in the architecture node (PRD1-01 to PRD1-03) and a reproducible hidden-focus bug in the new accordion (H-02) should be fixed before merge. H-01 is a decision rather than a code fix: the constitution asks that an unrun smoke test be left outstanding rather than counted as completion, so either run it or keep that status honest in the merge record. M-01, M-02 and L-01 are improvements.

**Estimated Rework Time**: about 1–2 hours (knowledge edits, a small focus fix with a test, and a smoke run or a recorded acceptance).

---

*Review generated by devspark.pr-review v1.2*
*Constitution-driven code review for ArrowSpark*
*To re-review after fixes: `/devspark.pr-review #4 re-review`*
*When addressing these findings, run `/devspark.address-pr-review 4`. The review file must be committed on its own.*
