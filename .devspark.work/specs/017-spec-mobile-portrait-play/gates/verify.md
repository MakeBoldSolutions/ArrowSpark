```yaml
gate: verify
devspark_version: 9.2.0
generated: '2026-10-19T03:23:54.922279+00:00'
status: pass
blocking: false
summary: End-to-end local proof passed, including owner-reported physical desktop checks; real-phone acceptance
  remains separately post-deploy.
modes:
- mode: end-to-end
  status: pass
  evidence_class: local-integration
  test_ref: tests/run_puzzle_regressions.py::main
  evidence: 'Actual session commands and complete output references are in evidence/verification-run.md.

    python tests/run_puzzle_regressions.py --godot <4.4.1-console>: workspace import crashed, exit 3221225477 (verify-puzzle.log).

    python <clean-current-copy>/tests/run_puzzle_regressions.py --godot <4.4.1-console>: exit 0; verify-puzzle-clean.log.
    Current runtime/tests match the clean copy byte-for-byte (verify-candidate.json).

    PUZZLE_FAILURES=0

    PUZZLE_ANALYZER_FAILURES=0

    PUZZLE_CATALOG_FAILURES=0

    PUZZLE_SCOREBOARD_FAILURES=0

    ARROW_DEPARTURE_GEOMETRY_FAILURES=0

    PUZZLE_VIEWPORT_FAILURES=0

    PUZZLE_LAYOUT_FAILURES=0

    PUZZLE_CANVAS_FAILURES=0

    PUZZLE_PRESENTATION_FAILURES=0

    APP_THEME_FAILURES=0

    PORTRAIT_MENU_FAILURES=0

    python tests/run_regressions.py --godot <4.4.1-console>: exit 0; REGRESSION_FAILURES=0 (verify-settings.log).

    npm run check --prefix web: exit 0; Astro 0 errors, 0 warnings, 1 hint; 59/59 tests (verify-web-check.log).

    PUBLIC_GAME_BUILD=portrait npm run build --prefix web: exit 0 (verify-web-build.log).

    node web/scripts/check-portrait-play.mjs <candidate> <verify-chrome> --chrome: exit 0; 10 fixtures.

    Default Firefox matrix attempts: touch fixtures pass, desktop admission times out because headless pointer:fine
    and any-pointer:coarse are both false; actual verdict is larger (verify-firefox-desktop-capabilities.json).

    node evidence/verify-firefox-fixtures.mjs <candidate> <verify-firefox-configured> --firefox: exit 0; 10 fixtures.
    Wrapper configures a simulated fine pointer only for desktop contexts; production admission is unchanged. Actual
    configured capability probe: fine=true, coarse=false, verdict=play.

    node evidence/browser-journey.mjs [--firefox]: both exit 0, actual exported touch interaction, two rotation
    cycles, height change, retained iframe/status, Menu and Escape/Resume. Both JSON records: statusPixelsRetained=true,
    iframeRetained=true, errors=[].

    Owner replied yes to the requested physical mouse/keyboard/gamepad checks in this verification run; recorded
    as requested checks passed with no failures reported. This interpretation was stated in chat. Models, per-action
    observations and device versions were not supplied; no assistant-observed hardware proof is claimed (desktop-input.md).

    '
discovered:
- Workspace Godot import crashed; clean-copy import and all eleven puzzle checks passed. Both attempts are retained.
- Default headless Firefox has no pointer; desktop admission correctly rejects it. Explicit fine-pointer desktop
  fixtures pass without changing production code.
- Admission source header still describes the old rotate notice; runtime/tests/player-facing copy correctly admit
  portrait.
- Existing planning child freshness issue remains outside verify ownership.
- Real Pixel/Chrome acceptance remains post-deploy under the existing intake record; no deployment or phone acceptance
  claimed.
```
