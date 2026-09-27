```yaml
gate: critic
status: pass
blocking: false
severity: info
summary: "FULL scope, game archetype, brownfield/internal. No constitution SHOWSTOPPER violations. critic-001 (Level Select initial-focus-grab gap) is resolved: T013 now requires puzzle_select_menu.gd to explicitly grab_focus() its first entry on becoming visible, T012 adds an automated focus-placement assertion, and plan.md/research.md/contracts/catalog-and-selection.md no longer claim the inherited _open_sub_menu mechanism provides this for free. No new substantive findings from this re-review."
reviewed_artifacts:
  - path: .devspark.work/specs/005-spec-multiple-puzzles/spec.md
    hash: "a758bff87c06087ef84ad1091c579cda1bc2e1ca"
  - path: .devspark.work/specs/005-spec-multiple-puzzles/plan.md
    hash: "4d3749df9a7d43b8bd0d8566b8c1f5149b2d4569"
  - path: .devspark.work/specs/005-spec-multiple-puzzles/tasks.md
    hash: "7e76eeda7d2a0eaabb3aede9a30dd3c2a71233ba"
  - path: .devspark.work/specs/005-spec-multiple-puzzles/research.md
    hash: "1a23521a180d48f403ec210b3316b9e35b48166f"
  - path: .devspark.work/specs/005-spec-multiple-puzzles/contracts/catalog-and-selection.md
    hash: "9aba627b2f74b276d91f00b51b9c923ee6524e0c"
```

## Technical Risk Assessment

**Analysis Date:** 2026-09-27
**Scope:** FULL
**Detected Archetype:** game (Godot project files: `project.godot`, `config/features="4.4"`)
**Detected Stack:** Godot 4.4 + GDScript + Maaack's Game Template (no server/DB/network stack)
**Context Mode:** brownfield (spec.md frontmatter `change_type: brownfield`)
**Risk Profile:** internal (spec.md frontmatter `risk_profile: internal`; severity shift = 0)
**Risk Posture:** YELLOW

*No stock or team risk checklists found at `.devspark/risk-checklists/` or `.devspark.work/risk-checklists/` — findings derived from first principles using the universal failure-mode lens and the game-archetype registry categories, plus direct inspection of the current codebase's relevant mechanisms (solver algorithm, tween/disposal lifecycle, sub-menu focus handling). Consider seeding `game.md`/`godot.md` checklists from this run.*

### Executive Summary

The spec/plan/tasks bundle is sound on the risks that most commonly sink a brownfield content-layer change: the solver is a proven-correct greedy O(n²) walk (no exponential blowup risk from denser authored boards), tweens are node-bound so full-scene-reload disposal (shared by Replay/Restart/Next Puzzle) is safe by construction, and the process-lifetime static-var session mechanism has a working precedent already used in this codebase (`GameVisualStyle._theme`). This re-review confirms critic-001 (the base `_open_sub_menu` mechanism not grabbing focus on open) is now resolved: T013 requires `puzzle_select_menu.gd` to explicitly `grab_focus()` its first entry when it becomes visible, T012 adds an automated `gui_get_focus_owner()` assertion immediately after Level Select opens, and the plan/research/contract text no longer claims the inherited mechanism provides keyboard/gamepad accessibility "for free." The fix is correctly scoped to the new project-level script only — no addon edits, no Options/Credits changes, no catalog/session/persistence architecture changes.

### Findings (source of truth)

```yaml
findings:
  - finding_id: critic-001
    category: testing_strategy
    archetype_applicable: true
    location: plan.md#Reviewer-Guidance (L64-66), contracts/catalog-and-selection.md#Level-Select-contract (L84-86), tasks.md#T013,T015
    description: "Base MainMenu._open_sub_menu() (addons/maaacks_game_template/base/scenes/menus/main_menu/main_menu.gd:19-22) only calls sub_menu.show()/%BackButton.show()/%MenuContainer.hide() — it never calls grab_focus() on the sub-menu or any child. Godot releases focus from a Control when it becomes invisible, so hiding %MenuContainer after opening Level Select (which contains the just-pressed LevelSelectButton) very likely leaves gui_get_focus_owner() == null. The base _input() only recovers focus via '%MenuButtonsBoxContainer.focus_first()', and only on a ui_accept release while no control has focus — but %MenuButtonsBoxContainer is itself hidden while a sub-menu is open, so that recovery path would (re-)focus a hidden main-menu button instead of any visible Level Select entry. This is a pre-existing template gap (Options/Credits show the identical lack of an explicit focus-grab), not something this spec introduces, but this spec is the first place a MUST keyboard/gamepad-navigation requirement (spec.md Clarifications session 2026-09-27) is pinned directly to it, and the plan explicitly declines to add mitigating code ('no new input-handling code is introduced for this')."
    intent_cue: "A keyboard-only or gamepad-only player who opens Level Select must land on a visible, focused, actionable control without an extra blind keypress — that is the behavioral intent behind the spec's keyboard/gamepad MUST, not merely 'some Control somewhere has GUI focus.'"
    base_severity: critical
    effective_severity: critical
    recommended_action: "Add an explicit grab_focus() call on puzzle_select_menu.tscn's first entry, either in puzzle_select_menu.gd's own show()/_on_visibility_changed override or in main_menu_with_animations.gd::_on_level_select_button_pressed() immediately after _open_sub_menu(level_select_scene) — mirroring puzzle_results.gd's existing _replay_button.grab_focus() convention on show_results(). Extend T012's Level Select scene-test coverage (or add a small T012a) to assert get_viewport().gui_get_focus_owner() is a visible Level Select list entry immediately after opening Level Select, not just that selecting an entry works. Treat this as required evidence before T024's manual keyboard/gamepad pass, not a substitute for it."
    execution_mode: selective
    status: resolved
    outcome: "T013 now requires puzzle_select_menu.gd to explicitly grab_focus() its first entry's control on becoming visible (project-level code in the new script only; addon/Options/Credits untouched). T012 now asserts get_viewport().gui_get_focus_owner() is non-null, visible, actionable, and matches PuzzleCatalog.id_at(0) immediately after Level Select opens. plan.md's Constitution Check (Principle III row) and Reviewer Guidance, research.md's Level Select decision rationale, and contracts/catalog-and-selection.md's Level Select contract were all corrected to state the explicit grab_focus() requirement instead of claiming the inherited _open_sub_menu mechanism provides keyboard/gamepad accessibility for free."
```

_No SHOWSTOPPER or additional CRITICAL findings. No HIGH findings meeting the bar for inclusion (several candidate risks — dense-board solver performance, tween/callback leaks across scene reload, catalog null-definition handling, Level Select overflow at small window sizes, save-progression regression via the new `new_game()` override — were investigated directly against source and found adequately mitigated by existing mechanisms or already-tasked coverage; see Questionable Assumptions and Dependency Risk Assessment below for the ones worth a note without rising to a finding)._

### Critical

_(No open CRITICAL findings — critic-001 resolved above.)_

### Missing Critical Tasks

_(None open — the initial-focus-placement gap is now covered by T012's automated assertion.)_

### Questionable Assumptions

1. **Eight handcrafted puzzles, including a "denser/more-arrow board," won't strain the greedy solver.** → Verified directly: `PuzzleSolver.analyze()` is O(n²) with no backtracking (puzzle_solver.gd:28-93), relying on a documented monotonicity proof that holds regardless of board size/density since it's a property of unchanged `PuzzleState` rules. No failure mode found; noted here only because it was a natural adversarial target that checked out clean.
2. **Closing Level Select (via Back/`ui_cancel`) returns focus to the main menu button row cleanly.** → Not independently verified this pass; `_close_sub_menu()` has the same absence of an explicit `grab_focus()` call as the open path did, but this is pre-existing baseline behavior already shared by Options/Credits (not a regression this spec introduces) and was explicitly out of scope for the critic-001 fix per the correction's scope-protection instructions. Worth a manual spot-check during T024 if time allows, but not elevated to a finding here.

### Dependency Risk Assessment

| Dependency | Concern | Alternative |
| --- | --- | --- |
| Maaack's Game Template `_open_sub_menu`/focus mechanism (existing, reused) | Template-inherited gap in initial focus-grab on sub-menu open (see critic-001); an addon-level fix is out of scope per constitution Principle II preference against unjustified addon edits | Keep the addon untouched; add the grab_focus() call in project-level `puzzle_select_menu.gd` or `main_menu_with_animations.gd` instead, consistent with Principle II |

### Estimated Technical Debt at Launch

- **Testing Debt:** None open — T012 now carries the automated focus-placement assertion that closes critic-001.
- **Code Debt:** None identified beyond the explicit `grab_focus()` call now specified in T013.
- **Operational/Documentation Debt:** None — knowledge updates (T011/T017/T021/T025) already cover the new architecture; no telemetry/observability infrastructure exists elsewhere in this project to be inconsistently skipped here.

### Metrics

- Showstopper: 0 · Critical: 0 · High: 0 (effective severity)
- Findings by category: none open (`testing_strategy` × 1 resolved)
- Missing operational tasks (FULL scope): 0

**VERDICT:** PROCEED

**Recommended Risk Mitigations:**

- When implementing T019's Next Puzzle button, keep `puzzle_results.gd`'s existing `_replay_button.grab_focus()` call as the default (Replay remains available in every state; no change needed), but confirm during T024 that Next Puzzle is still reachable by directional navigation from Replay without a dead end.
- Consider seeding a `game.md` risk checklist under `.devspark/risk-checklists/` from this run's registry categories (`concurrency_async`, `testing_strategy`, `binary_size_perf`) so future ArrowGame specs don't re-derive Godot-specific risk framing from first principles each time.
- Non-blocking, noted for awareness only: `_close_sub_menu()`'s return-focus path has the same pre-existing absence of an explicit `grab_focus()` call as Options/Credits already have (see Questionable Assumptions #2) — out of scope for this correction, worth a manual spot-check during T024.

---

Where you are: Spec 005 critic gate complete (FULL scope, 0 open findings — 1 resolved, VERDICT: PROCEED)
Next: `/devspark.implement`
