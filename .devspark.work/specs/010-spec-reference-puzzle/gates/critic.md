```yaml
gate: critic
status: pass
blocking: false
severity: info
summary: "FULL critique re-run after remediation: all 11 findings (8 high, 3 medium) addressed in spec.md and tasks.md. No constitution violations. Residual risks are execution-time: solver-test cost is unmeasured until the first real candidate, and the human gates remain open."
reviewed_artifacts:
  - path: spec.md
    hash: "01168c3491105614741f9d2baf40a61b7e116ab7"
  - path: plan.md
    hash: "3335e49395be56c8bed1c26c63dcad68ac32da66"
  - path: tasks.md
    hash: "003b55b63fd6c605ec6da390ecf8a6755fe38e59"
  - path: research.md
    hash: "dc15a3727b71d381a3834990e3d7badcde4336c7"
  - path: data-model.md
    hash: "15dda00c216a9da7b945a6b725b934651e83227e"
  - path: contracts/level-groups.md
    hash: "78cc4b106926a5945bc39402959c5312f109f229"
```

## Technical Risk Assessment

**Analysis Date:** 2026-09-30T13:31:20Z
**Scope:** FULL
**Detected Archetype:** game (Godot project files; inferred, not declared in frontmatter)
**Detected Stack:** GDScript + Godot 4.4 + in-memory static session state (no persistence)
**Context Mode:** brownfield (inferred: modifies catalog, session, menus, results, and existing tests)
**Risk Profile:** internal (defaulted; spec declares only `risk_level: medium`)
**Risk Posture:** GREEN (after remediation; residual execution-time risks noted below)
**Checklists:** No stack/archetype checklists found in `.devspark/risk-checklists/` or `.devspark.work/risk-checklists/`. Risks were derived from first principles and the universal failure-mode lens. Consider seeding a `game.md` checklist from this run.

### Executive Summary

The plan is sound in shape: group metadata is additive, the rule core is untouched, and the constitution obligations are visibly mapped to tasks. The risks sit around the edges. Several existing regression tests assert the old flat-list menu and are not owned by any task. The results-to-Level-Select path depends on an intro/animation ordering that has not been proven. The "want someone else to play it" claim rests on a tester who may be contaminated. Verdict is CONDITIONAL: none of these needs a spec rewrite, but each needs a task or an amended task before `/devspark.implement`.

### Findings (source of truth)

```yaml
findings:
  - finding_id: critic-001
    category: documentation
    archetype_applicable: true
    location: spec.md#frontmatter
    description: "Spec frontmatter declares `risk_level: medium` but no `risk_profile`. The critic defaulted to `internal`, so severity scaling was not tuned to the project's real stakes."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "Add `risk_profile:` (likely `experimental` or `internal`) to spec.md frontmatter and re-run critic so severity scaling is deliberate."
    execution_mode: selective
    status: resolved
    outcome: "Fixed in planning artifacts"
  - finding_id: critic-002
    category: documentation
    archetype_applicable: true
    location: spec.md#frontmatter
    description: "No `archetype` declared. Godot project files make `game` obvious, but later gates and checklists should not depend on inference."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "Add `archetype: game` to spec.md frontmatter."
    execution_mode: selective
    status: resolved
    outcome: "Fixed in planning artifacts"
  - finding_id: critic-003
    category: documentation
    archetype_applicable: true
    location: spec.md#frontmatter
    description: "No `change_type` declared. The work is brownfield (existing menus, session, results and tests are modified), which raises the weight of regression and rollback risk."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "Add `change_type: brownfield` to spec.md frontmatter."
    execution_mode: selective
    status: resolved
    outcome: "Fixed in planning artifacts"
  - finding_id: critic-004
    category: testing_strategy
    archetype_applicable: true
    location: tasks.md#T006-T007,T016,T022 (vs tests/puzzle_layout_check.gd:567-573,645; tests/puzzle_canvas_check.gd:1126-1135; tests/puzzle_catalog_check.gd:87)
    description: "Existing tests assume a flat, button-only Level Select and 'last catalog entry is knot_boundary'. puzzle_layout_check asserts `list_container.get_child_count() == PuzzleCatalog.count()` and that button text is '%d. %s' % [i + 1, title_at(i)]. puzzle_canvas_check iterates `list.get_child(i)` as a Button. Header Labels (T016) break the count and the Button cast, and group-relative numbering (FR-033) breaks the text assertion. puzzle_catalog_check:87 asserts the last entry is knot_boundary, which appending reference_knot breaks. puzzle_layout_check:645 plays the last catalog entry through Results, which becomes the in-flux reference_knot. T007 only fixes 'hard-coded 21' doc counts, and T006/T022 only cover puzzle_catalog_check, so no task owns these failures. The gates go red when T016 lands, after T007's green checkpoint."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "Add tasks to update puzzle_layout_check and puzzle_canvas_check for grouped Level Select (filter to Button children, expect group_position numbering, count = catalog size), and fix puzzle_catalog_check:87 (last id). Decide which fixed puzzle the 'last catalog puzzle results' test uses (a small, stable one, not reference_knot). Re-run both gates at the end of Phase 4, not only in Phase 2."
    execution_mode: selective
    status: resolved
    outcome: "Fixed in planning artifacts"
  - finding_id: critic-005
    category: error_handling_resilience
    archetype_applicable: true
    location: tasks.md#T016 (vs scenes/menus/main_menu/puzzle_select_menu.gd `_grab_first_entry_focus`)
    description: "`_grab_first_entry_focus()` calls `_list_container.get_child(0).grab_focus()`. After T016 the first child is a non-focusable group header Label (FOCUS_NONE), so the grab fails or errors and keyboard/gamepad users open Level Select with no focus. T016 states the intent ('initial focus on the first button') but does not name this existing line. Constitution III makes keyboard/gamepad navigation a MUST."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "In T016, track the first button explicitly (for example store it when building) and grab focus on that node, not on `get_child(0)`. Add a check to the layout test that focus lands on the Reference Puzzle button after opening Level Select."
    execution_mode: selective
    status: resolved
    outcome: "Fixed in planning artifacts"
  - finding_id: critic-006
    category: concurrency_async
    archetype_applicable: true
    location: tasks.md#T019 (vs scenes/menus/main_menu/main_menu_with_animations.gd `_ready`, `_setup_level_select`, `_open_sub_menu`)
    description: "Opening Level Select from a fresh main-menu load races three things. (1) In `_ready` the AnimationTree playback handle is assigned after `_setup_level_select()`. (2) Level Select is added via `call_deferred`, so it is not in the tree when `_ready` returns. (3) `_open_sub_menu` calls `animation_state_machine.travel('OpenSubMenu')` while the state machine may still be in the 'Intro' node, and a valid Intro->OpenSubMenu transition is not established by any artifact. Failure modes: Level Select opens with the intro still playing, the main menu buttons are hidden with no animation, a stray key skips the intro and re-triggers a transition, or Level Select opens invisible. R7 acknowledges the risk and defers it to a smoke test, but the smoke test cannot catch ordering flakiness."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "Add a headless check (the layout test already instantiates the menu) that sets the request, instantiates the main menu, waits N frames, then asserts Level Select is visible and focused. Define the fallback in T019 up front: on request, call `intro_done()` first, then open Level Select in a deferred call after `animation_state_machine` is initialized. Verify the AnimationTree has an Intro->OpenSubMenu path, or route via OpenMainMenu."
    execution_mode: manual
    status: resolved
    outcome: "Fixed in planning artifacts"
  - finding_id: critic-007
    category: testing_strategy
    archetype_applicable: true
    location: spec.md#FR-013,FR-016,SC-002..SC-006; tasks.md#T011,T014
    description: "The 'level I want someone else to play' verdict and every discovery-based success criterion (aha moments, anticipation, rethink points, no rescan) come from a single primary tester who has watched the level evolve over several candidates. Later iterations are replayed with growing familiarity, so a surprise answer to Q6-Q13 cannot be trusted on the final candidate. The only non-author check is SC-009, which tests menu findability, not the puzzle."
    intent_cue: "The point of Q1-Q15 is to observe first-contact discovery. That requires someone who has not seen this board, or at least this version."
    base_severity: high
    effective_severity: high
    recommended_action: "Amend T014/SC-006: the final playtest MUST be run by someone who has not played this candidate. Record the tester's prior exposure. If only the author is available, record that limitation in the design report and downgrade the completion claim explicitly. Keep the author's iteration sessions as design evidence, not as endorsement."
    execution_mode: manual
    status: resolved
    outcome: "Fixed in planning artifacts"
  - finding_id: critic-008
    category: testing_strategy
    archetype_applicable: true
    location: tasks.md#T006,T009 (vs tests/puzzle_catalog_check.gd `_check_order_independence_at_every_branch`)
    description: "The order-independence helper rebuilds a fresh PuzzleState, replays the witness prefix, forces each alternative legal head, then runs a greedy completion, at every branching step. That is roughly O(steps x alternatives x steps) state operations, plus an O(active arrows) legal scan per greedy step. It has only run on boards of 4-60 arrows. The plan targets ~40-60 x 30-40 cells, likely several hundred arrows. For n=400 and 5 alternatives per branch, this is on the order of a million select_arrow calls and hundreds of millions of blocked checks in interpreted GDScript. This is a hypothesis, not a measurement, but it can turn a fast headless gate into a multi-minute or multi-hour one. The layout/canvas checks also animate every departure to clear the level via `_worst_case_seconds_for`."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "In T005/T008, time `PuzzleSolver.analyze` and the order-independence helper on the candidate and record the cost in verification.md. If the helper exceeds a budget (say 30 s), sample alternatives (for example check the first k alternatives per branch, or every m-th branch) for this board only. The monotonic exchange argument already covers correctness. Keep the full-catalog gate under a stated wall-clock budget."
    execution_mode: selective
    status: resolved
    outcome: "Fixed in planning artifacts"
  - finding_id: critic-009
    category: testing_strategy
    archetype_applicable: true
    location: tasks.md#T008,T012 (authoring loop)
    description: "Candidates are authored as coordinate shape lists with `_tail_along`. The only pre-play feedback is validation errors (overlap/out of bounds) and numeric diagnostics from the structural report. No task provides a way to look at the board without launching the game: no ASCII or image dump of arrows and tails. Illegible geometry (FR-008) and accidental tail crossings are exactly what numbers do not show. Each iteration therefore costs a full game launch, and a bad candidate can reach a human gate."
    intent_cue: ""
    base_severity: medium
    effective_severity: medium
    recommended_action: "Add a small non-gating diagnostic (or a scratchpad-only script) that prints an ASCII render (one glyph per arrow direction, tail cells marked) of `reference_knot`. It must not become a scoring tool and must not appear in durable code unless it is documented as a diagnostic."
    execution_mode: selective
    status: resolved
    outcome: "Fixed in planning artifacts"
  - finding_id: critic-010
    category: concurrency_async
    archetype_applicable: true
    location: plan.md#Technical Context (Performance Goals), tasks.md#T027
    description: "Plan asserts 'no new per-frame work' but the change introduces the largest board in the catalog with many concurrent path-following departures (long, multi-bend arrows in a dense knot). Constitution IV asks for measurement-led investigation. T027 records only pass/fail smoke results, so a frame-time regression during the big collapse would be invisible or anecdotal."
    intent_cue: ""
    base_severity: medium
    effective_severity: medium
    recommended_action: "In T027, record subjective smoothness and a frame-time observation (Godot's monitor or FPS overlay) during the largest multi-arrow departure and during zoom/pan at Fit Puzzle. Note the machine used in verification.md."
    execution_mode: manual
    status: resolved
    outcome: "Fixed in planning artifacts"
  - finding_id: critic-011
    category: testing_strategy
    archetype_applicable: true
    location: tasks.md#T005,T020; Implementation Strategy
    description: "T005 lands a minimal placeholder `reference_knot` and T020 points the main-menu Play button at it, while the human gates (T014, T028) can stay open indefinitely. Nothing stops a PR or merge of the branch with Play launching a throwaway board and with Level Select advertising an 'ArrowSpark Levels' group holding a placeholder. FR-016 keeps only the spec status below Complete, not the code."
    intent_cue: ""
    base_severity: medium
    effective_severity: medium
    recommended_action: "Add a rule to T035/T020: do not merge with Play retargeted while `reference_knot` is still the placeholder. Sequence the Play retarget (T020) to land after T012 converges, or mark the PR as draft until T014 passes. Keep T020's code available earlier on the branch for playtests."
    execution_mode: selective
    status: resolved
    outcome: "Fixed in planning artifacts"
```

### High

| ID | Category | Location | Issue | Impact | Suggestion |
| --- | --- | --- | --- | --- | --- |
| critic-001 | documentation | spec.md frontmatter | No `risk_profile` | Severity scaling not deliberate | Add `risk_profile` |
| critic-002 | documentation | spec.md frontmatter | No `archetype` | Checklists/gates rely on inference | Add `archetype: game` |
| critic-003 | documentation | spec.md frontmatter | No `change_type` | Brownfield regression weight unstated | Add `change_type: brownfield` |
| critic-004 | testing_strategy | puzzle_layout_check:567-573,645; puzzle_canvas_check:1126-1135; puzzle_catalog_check:87 | Legacy tests assert the flat button-only list, i+1 numbering, and "last entry = knot_boundary" | Both gates go red at T016 with no owning task; the last-puzzle Results test would play the in-flux level | Add owning tasks, pick a stable puzzle for the last-entry test, re-run gates after Phase 4 |
| critic-005 | error_handling_resilience | T016 vs puzzle_select_menu.gd | `get_child(0).grab_focus()` targets a FOCUS_NONE header | No initial focus for keyboard/gamepad (Constitution III MUST) | Track the first button explicitly; test focus target |
| critic-006 | concurrency_async | T019 vs main_menu_with_animations.gd | Level Select opens against intro state, deferred add_child, and late playback handle | Level Select invisible, unfocused or mid-intro after Results → Level Select | Headless check; `intro_done()` first; verify Intro→OpenSubMenu transition |
| critic-007 | testing_strategy | FR-013/FR-016/SC-002..006; T011, T014 | One tester with growing familiarity supplies every discovery-based criterion | The "want someone else to play" claim cannot be trusted as first-contact evidence | Require a fresh tester for the final playtest, or record the limitation |
| critic-008 | testing_strategy | T006/T009 vs order-independence helper | Test cost grows roughly quadratically with arrows; only run on ≤60-arrow boards | Regression gate becomes minutes or hours; gets skipped | Time it at T005/T008; sample alternatives for this board; budget the gate |

### Medium (findings table projection)

| ID | Category | Location | Issue | Impact | Suggestion |
| --- | --- | --- | --- | --- | --- |
| critic-009 | testing_strategy | T008/T012 | No way to look at a candidate without launching the game | Slow iterations; illegible geometry reaches human gates | Add a non-gating ASCII render diagnostic |
| critic-010 | concurrency_async | plan Technical Context; T027 | Largest board plus concurrent departures, no frame-time observation | Silent frame-time regression | Record FPS/frame time in T027 |
| critic-011 | testing_strategy | T005/T020 | Play is retargeted to a placeholder while gates stay open | A merge exposes a throwaway level as the first level | Gate merge on T014, or land T020 late |

### Missing Critical Tasks

- **Testing:** owning tasks for the legacy layout/canvas/catalog test updates (critic-004); a focus-target assertion for Level Select (critic-005); a headless results→Level Select flow check (critic-006); solver-test timing and budget (critic-008).
- **Operations:** a merge rule tying Play retarget to the human gate (critic-011).
- **Documentation:** metadata fields in spec frontmatter (critic-001..003); record the tester's prior exposure in the design report (critic-007).
- **Observability:** frame-time observation during the largest departure (critic-010).

### Questionable Assumptions

1. **"The author is the primary playtester" (spec Assumptions)** → Failure mode: the author has seen every candidate, so the discovery beats and "rethink" points on the final level are recalled, not felt. The endorsement is inflated.
2. **"Solvable from every reachable state" is checked by the branch helper (T006/T009)** → Failure mode: the solver's own monotonic argument already proves this for any solvable definition. The expensive helper adds cost without adding correctness on a large board, so it should be sampled, not dropped from the small-board catalog.
3. **"Group is metadata only, so nothing else changes" (FR-027)** → Failure mode: true for rules, false for tests and UI. Numbering, child counts, focus order and the last-entry assumption all read the list shape, which is where the real breakage is (critic-004, critic-005).
4. **"Fallback: load the menu with the intro skipped" (R7)** → Failure mode: the fallback is chosen only after a smoke test finds a problem, and ordering flakiness may not reproduce on the smoke-test day.
5. **"Diagnostics are enough to steer authoring" (T010)** → Failure mode: dependency depth, forced moves and blocker distance do not show tail crossings or unreadable clusters (critic-009).

### Dependency Risk Assessment

| Dependency | Concern | Alternative |
| --- | --- | --- |
| Maaack's Game Template `MainMenu` (`_open_sub_menu`, intro animation tree) | The results→Level Select path depends on internals of an addon menu animation graph that this repo does not own | Keep the fallback: skip the intro on request, or reuse the existing Main Menu path and open Level Select on the first frame after `intro_done()` |
| Static `PuzzleSession` state | One-shot flag lives in a process-wide static. A failed consume (for example the menu never reaches the point where it reads the flag) leaves it set and re-opens Level Select on a later main-menu visit | Clear the flag on read and on `set_current_id`; test consumed-once behavior (T021 already asks for this) |
| Human availability | The project cannot be complete without a second person (SC-009, and per critic-007 the final playtest) | Name the second tester before the final playtest; plan an async "send the build" path |

### Estimated Technical Debt at Launch

- **Code:** minimal if the plan holds. Group metadata is small. Watch for two ways to compute display numbers surviving (menu vs in-game label vs results).
- **Operational:** the solver-test cost on the largest board, if not budgeted, becomes debt that gets "solved" by skipping the helper.
- **Documentation:** the design report is the deliverable. Its honesty depends on the tester context (critic-007).
- **Testing:** legacy tests that assume a flat list will carry stale assertions if only patched to pass (critic-004).

### Metrics

- Showstopper / Critical / High counts (effective): 0 / 0 / 8
- Medium: 3
- Findings by category: testing_strategy 5, documentation 3, concurrency_async 2, error_handling_resilience 1
- Missing operational tasks (FULL): 4 buckets (see above)
- Findings overflow: 0

**VERDICT:** PROCEED

**Required Actions Before Implementation (all applied):**

1. Add owning tasks for the legacy test changes (critic-004) and make the Phase 4 checkpoint require both gates green.
2. Amend T016 to track and focus the first button explicitly, with a test (critic-005).
3. Amend T019 with the intro-first fallback and a headless open-Level-Select-from-request check (critic-006).
4. Amend T014/SC-006 so the final playtest uses a fresh tester, or state the limitation in the completion claim (critic-007).
5. Add frontmatter `archetype`, `risk_profile` and `change_type` to spec.md (critic-001..003).

**Recommended Risk Mitigations:**

- Time the solver and order-independence checks on the first real candidate and set a wall-clock budget (critic-008).
- Add an ASCII render diagnostic for authoring (critic-009).
- Record frame time during the largest departure (critic-010).
- Do not merge with Play retargeted to a placeholder (critic-011).
- Seed `.devspark.work/risk-checklists/game.md` from this run.

### Remediation Notes

- critic-001..003: `archetype: game`, `risk_profile: internal`, `change_type: brownfield` added to spec.md frontmatter.
- critic-004: new T007a (layout/canvas test update, stable puzzle for last-entry scenario), T006 replaces the `knot_boundary`-is-last assertion, Phase 4 checkpoint requires both gates green.
- critic-005: T016 tracks the first button and no longer focuses `get_child(0)`.
- critic-006: T019 calls `intro_done()` first, waits for the playback handle and deferred child, clears the flag on read, and adds a headless open-Level-Select check. Verified the AnimationTree has no direct Intro to OpenSubMenu transition; `travel` would route through OpenMainMenu, so the intro-first approach is the safer path.
- critic-007: T014 and SC-006 record tester exposure, prefer a fresh tester, and require disclosure of a familiar-tester limitation (not made an absolute block, since tester availability is the owner's call).
- critic-008: T009 times the solver and order-independence checks and allows sampling for this board past ~30 s.
- critic-009: T008 adds a scratchpad-only ASCII render.
- critic-010: T027 records frame-time observation.
- critic-011: T020/T035 keep the PR in draft and forbid merging with Play on a placeholder.

Where you are: critic gate complete (PROCEED); planning artifacts remediated
Next: run `/devspark.analyze` to confirm the edited artifacts stay consistent, then `/devspark.implement`
