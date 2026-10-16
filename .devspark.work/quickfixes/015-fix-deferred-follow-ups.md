---
classification: one-off-fix
risk_level: low
target_workflow: quickfix
required_artifacts: quickfix-record
recommended_next_step: implement
required_gates:
---

# Quickfix Record: 015-fix-deferred-follow-ups

## Metadata

- **ID**: 015-fix-deferred-follow-ups
- **Created**: 2026-10-16T04:26:02Z
- **Author**: Mark Hazleton
- **Branch**: 015-fix-deferred-follow-ups
- **Classification**: bug-fix
- **Risk Level**: LOW (the script suggested MEDIUM from the word "fix"; lowered because the three edits are a runner's output handling, one array entry and one tooltip string, with no gameplay or data change)
- **Max Effort**: 4 hours

## TLDR (Product Owner)

- **WHAT (the problem)**: Three small leftovers from the codebase consolidation.
  1. When a headless regression check fails, the gate prints a Python traceback instead of the
     failing check's own "FAIL:" lines, so you can't see what broke.
  2. The website's pre-play content check still lists a game folder that no longer exists.
  3. The main menu's New Game tooltip says "Starts the Reference Knot", but New Game actually
     starts the first ArrowSpark level.
- **WHY (the root cause)**:
  1. The runners call `subprocess.run(check=True, capture_output=True)`, which raises on a
     non-zero exit before the captured output is printed.
  2. `scenes/loading_screen/` was removed as unreachable template content, but
     `web/scripts/check-content.mjs` and its description in `web-showcase.md` still name it.
  3. The tooltip text was not updated when New Game moved from the Reference Knot to the first
     progression level.
- **HOW (the fix)**:
  1. Use the pattern already present in `tests/run_puzzle_regressions.py`: run with `check=False`,
     print stdout and stderr, then call `result.check_returncode()`. Apply it at the three
     `check=True` sites there and the one in `tests/run_regressions.py`, so a failing gate shows its
     FAIL lines and still exits non-zero.
  2. Drop `scenes/loading_screen` from the scan list and from the doc sentence.
  3. Change the tooltip to "Starts the first ArrowSpark level. Existing level progress (Continue)
     is preserved even though it's hidden here." Update the quote in `save-progression.md`.

## Affected Components

- `tests/run_puzzle_regressions.py` (three runner functions)
- `tests/run_regressions.py` (one runner loop)
- `web/scripts/check-content.mjs` (pre-play scan folder list)
- `scenes/menus/main_menu/main_menu_with_animations.tscn` (`NewGameButton` tooltip)
- `.knowledge/architecture/web-showcase.md`, `.knowledge/architecture/save-progression.md`

## Context Resolution

- web-showcase (knowledge, direct): describes the pre-play scan folders
- save-progression (knowledge, direct): quotes the New Game tooltip and owns the runner/save-gate description

## Constitution Compliance

| Principle | Status | Notes |
| --- | --- | --- |
| I. Simple, Maintainable Code | PASS | Reuses the runner's existing `check=False` + `check_returncode()` idiom; no new abstraction |
| III. Accessible, Configurable Controls | CONDITIONAL | The tooltip is on a menu control: verify the main menu tooltip and keyboard/mouse navigation in a desktop smoke |
| V. Practical Gameplay Verification | CONDITIONAL | Godot editor validation; both headless gates (plus a forced-failure run that proves the FAIL lines now print); `npm run check`; a desktop smoke of the main menu. The web build carries the new tooltip, so check it in one supported browser and record untested ones |
| VI. Preserve Saved Progress and Settings | PASS | No save or settings code touched |

## Validation Checklist

- [x] Change addresses stated problem (code_ref: tests/run_puzzle_regressions.py (run_rule_regressions, run_geometry_regressions, run_viewport_transform_regressions), tests/run_regressions.py, web/scripts/check-content.mjs, scenes/menus/main_menu/main_menu_with_animations.tscn (NewGameButton tooltip_text) | knowledge_ref: .knowledge/architecture/web-showcase.md, .knowledge/architecture/save-progression.md, .knowledge/index.json)
- [x] No unintended side effects identified (both gates, editor validation and `npm run check` green; see Implementation Notes)
- [x] Relevant tests updated/added (if applicable) (code_ref: tests/run_puzzle_regressions.py, tests/run_regressions.py (runner output handling; proven by a forced-failure run) | knowledge_ref: n/a)
- [x] Documentation updated (if applicable) (code_ref: n/a | knowledge_ref: .knowledge/architecture/web-showcase.md (scan list), .knowledge/architecture/save-progression.md (tooltip quote), .knowledge/index.json)
- [x] Manual smoke: main menu New Game tooltip and menu navigation on desktop, and the tooltip in one supported browser. Reported passed by the developer on 2026-10-16 ("looks good"); the browser used was not named, so other supported browsers are recorded as not tested (code_ref: n/a: manual check | knowledge_ref: n/a: manual check)

## Gate Acknowledgements

## Implementation Notes

- 2026-10-16: Route escalation check. Signal: several unrelated concerns bundled into one fix.
  Examined with the developer, who chose to keep one quickfix with one commit per concern; each
  edit is a few lines and none touches architecture, contracts, schema or saved data.
- `tests/run_regressions.py` was added to the scope of item 1 because it has the same defect at
  the same idiom, and it is the other required gate.
- 2026-10-16: verification on Godot 4.4.1 (`/tmp/ArrowGame-Godot-4.4.1/...console.exe`).
  - Forced failure, using the safe procedure: the catalog was `CLEAN`; line 515
    (`_build_knot_regions`) was changed from `Vector2i(12, 5)` to `Vector2i(12, 6)`. Puzzle gate
    exit 1, and its output now shows
    `FAIL: entry `knot_regions` keeps its geometry g1-d2398acdb422 (got g1-3b9bb8570e77)` and
    `PUZZLE_CATALOG_FAILURES=1`, followed by the CalledProcessError (before the fix there was only
    the traceback). The edit was undone by hand, and `git diff --quiet` printed `RESTORED`.
  - `run_puzzle_regressions.py` exit 0 (9 markers `=0`); `run_regressions.py` exit 0
    (`REGRESSION_FAILURES=0`); `--headless --editor --quit` exit 0 with no errors.
  - `npm run check`: astro check 0 errors; vitest 5 files / 58 tests passed; `check-content: ok`.
  - `git grep 'Starts the Reference Knot'` outside planning bundles: no matches.
  - Web export with Godot 4.4-stable (the only version with web templates installed), build
    `568b07d`; `npm run build` exit 0; served by the existing preview on port 4329.

## Completion

- **Completed**: 2026-10-16
- **Commit**: 568b07d (last fix commit; fixes in 62b6138, d001f45, 568b07d)
- **PR**:

---

Generated by /devspark-quickfix v1.0.
