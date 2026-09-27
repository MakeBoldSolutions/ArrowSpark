# Verification Record: Rich Arrow Model and Solvability Foundation

## Current completion status — 2026-09-26

Complete. Earlier outstanding-check statements below describe the original verification session and are retained as history. The later integrated evidence in `../../003-spec-continuous-arrow-visuals/gates/verification.md` and `../../003-spec-continuous-arrow-visuals/gates/verify.md` covers the current implementation, including automated regressions, rendered checks, navigation, and Godot 4.4 validation.

The user's report, "/devspark.implement my user testing was good", closes the overlapping hands-on acceptance checks. This is user-reported acceptance; no per-device, per-resolution, or individual-step transcript was supplied, and no additional agent-observed physical gamepad test is claimed.

Completion audit: the 41-file verified source manifest matches current content, allowing only CRLF/LF differences in four font resource files. No implementation changes or new runtime test results are claimed by this audit. Historical analyze/critic reviews pass with no open blockers; their original reviewed hashes are preserved, not presented as fresh reviews of these completion-only edits.

## Environment

- **Godot version used**: 4.7.2.stable (official) — `Godot_v4.7.2-stable_win64.exe`, resolved via `winget` install at `C:\Users\markh\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe`.
- **Discrepancy disclosed**: `project.godot` declares `config/features=PackedStringArray("4.4")` and the constitution names Godot 4.4; no 4.4.x executable is installed on this machine, only 4.7.2. All validation and regression runs in this bundle use 4.7.2. No 4.4-specific incompatibility was observed in any run; this is disclosed per Constitution Principle V rather than silently substituted.
- **Isolation**: `tests/run_puzzle_regressions.py` and `tests/run_regressions.py` redirect `APPDATA`/`XDG_DATA_HOME` to disposable temp directories; no player save/settings data on this machine is touched by any run recorded here.

## Baseline (pre-implementation, T001)

Captured before any Spec 002 code change, against the pre-existing single-cell puzzle:

| Command | Result | Marker |
|---|---|---|
| `python tests/run_puzzle_regressions.py --godot <godot>` | exit 0 | `PUZZLE_FAILURES=0`, `PUZZLE_LAYOUT_FAILURES=0` |
| `python tests/run_regressions.py --godot <godot>` | exit 0 | `REGRESSION_FAILURES=0` |

`run_regressions.py`'s output includes several `ERROR:`/`push_error` lines after `REGRESSION_FAILURES=0` — these come from the suite's own deliberate corrupt-save/backup-failure fixtures (e.g. "corrupt save blocks writes," "backup failure preserves original") and are expected stderr noise from those intentional-failure paths, not unhandled failures; the PASS lines for every named check and the `0` failure markers are the authoritative result.

## Godot import/validation and regression runs (T024)

All commands run with the Godot 4.7.2 executable and disclosed discrepancy noted above.

| Command | Result | Marker |
|---|---|---|
| `godot --headless --path . --editor --quit` (full project import/validation) | exit 0, no parser/resource errors or warnings | — |
| `python tests/run_puzzle_regressions.py --godot <godot>` | exit 0 | `PUZZLE_FAILURES=0`, `PUZZLE_LAYOUT_FAILURES=0` (443 PASS lines across both headless checks) |
| `python tests/run_regressions.py --godot <godot>` | exit 0 | `REGRESSION_FAILURES=0` (42 PASS lines) |

`run_regressions.py`'s deliberate corrupt-save/backup-failure fixtures still print expected `ERROR:`/`push_error` stderr noise after `REGRESSION_FAILURES=0`, as disclosed in the baseline section above — this is unchanged from baseline and not a new failure.

All 27 code-bearing tasks (T003-T023) implementing FR-001 through FR-016 are complete, with `code_ref`/`knowledge_ref` populated on each. No outstanding failures.

## Desktop smoke test (T025)

**Outstanding / not runnable in this environment.** This session has no
display or input-injection capability (no GUI, mouse, or window access) —
identical to the limitation already disclosed for Spec 001's equivalent
smoke test. The interactive desktop matrix (opening/start/play/completion/
Replay/Main Menu, head/tail clicks, rapid departures, resize, pause/resume,
Restart cancel/confirm, options) has NOT been performed and is not claimed
as passing. The headless checks in T024 (`tests/puzzle_regression.gd`,
`tests/puzzle_layout_check.gd`) are the automated proxy for the numeric/
geometric constraints this smoke test would otherwise cover interactively,
per the spec's own Quickstart guidance — they are not a substitute for it.
A human with desktop access must run this matrix before release.

## Keyboard/gamepad and saved-progress verification (T026)

**Partially outstanding.** The saved-progress and settings-persistence
portion (progress/settings values surviving puzzle entry/menu routing,
including a seeded keyboard/gamepad remap) is covered headlessly and
passing — see T023's additions to `tests/save_input_regression.gd`
(`REGRESSION_FAILURES=0`). The interactive portion — actually navigating
menus/pause/results with a real keyboard and gamepad, confirming focus and
activation work by hand — has the same display/input-injection limitation
disclosed under T025 and has NOT been performed. A human with keyboard and
gamepad hardware must run this interactive pass before release; this
session discloses the gap rather than claiming it passed.
