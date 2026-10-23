```yaml
gate: critic
devspark_version: "9.3.0"
generated: "2026-10-23T06:52:00Z"
planning_review:
  run_id: "pr-20261023T064703Z-b23c59"
status: warn
blocking: false
severity: warning
summary: "Plan is sound against the baseline; one hidden CI coupling means a pack-only change skips the dedicated regression workflow (still gated by the deploy workflow)."
applicability:
  applicable: true
  signals: [persistent-data-shape]
  invoked: automatic
reviewed_artifacts:
  - path: spec.md
    hash: "4ae5a3e4f304a0820cf645ec871c8c2f831695f9"
    semantic_hash: "sem1:5f6bc6aa66ba9fe5e48269dde709109c86b2fd0e2d7344b92071add3c020144c"
  - path: plan.md
    hash: "605e483e9c86c8ecc02915a2bd2814ecab31530a"
    semantic_hash: "sem1:3ff47d123d190502005d56cabe849bf3b797c4e963db79c323ff6122d0ea6517"
  - path: tasks.md
    hash: "a54117246630da4cfc9ecb3396efb789527ea61c"
    semantic_hash: "sem1:40dcf39d4422d18bdfff25b06914ec47eeb5374c143259470d44fccfd4b57f8a"
  - path: .github/workflows/godot-regression-tests.yml
    hash: "563291d204fdb3f1d48bc3f83539a654faf60ddd"
  - path: .github/workflows/azure-static-web-apps-green-bay-09bdc1010.yml
    hash: "0fda2778b4030155af2b97c14fc5fff9c9dc3ff3"
  - path: export_presets.cfg
    hash: "70c06f90a3b7f005f4812004368c133159e3fc44"
  - path: tests/run_puzzle_regressions.py
    hash: "7de428c942d63cf9c4d4cccf0da1703d9801c8fe"
  - path: scripts/puzzle/puzzle_catalog.gd
    hash: "3fe4959699daf91ecffe357722289c39d7cc8171"
```

## Technical Risk Assessment

**Analysis Date:** 2026-10-23T06:52:00Z
**Scope:** FULL
**Pass:** DISCOVERY
**Applicable:** true. Signal: `persistent-data-shape` (a new committed level-pack data format and controlled vocabulary). Invoked: automatic.
**Detected Archetype:** game (desktop and Web export) plus developer tooling (inferred)
**Detected Stack:** GDScript + Godot 4.4 + committed JSON files
**Context Mode:** brownfield (inferred; modifies the existing catalog and launchers)
**Risk Profile:** internal (inferred; no `risk_profile` declared)
**Risk Posture:** GREEN

### Executive Summary

The plan's assumptions hold against the baseline:
- **JSON loading:** `.json` loads under `res://` in a bare temp project, `JSON.parse_string` yields floats (handled in data-model.md), and a Godot 4.4.1 `--editor --quit` creates no sidecar files for `.json` (probe in the session scratchpad).
- **The migration proof:** `CATALOG_PINS` already pins all 30 levels.
- **Analyzer cost:** generated boards are acyclic by construction, so `PuzzleAnalyzer` takes its linear dynamic-programming path for depth.

One material, non-blocking risk remains: CI path coupling. VERDICT: CONDITIONAL, because promoting that fix into this spec is a scope decision for the developer.

### Findings (source of truth)

```yaml
findings:
  - finding_id: critic-001
    owner: critic
    category: ci-coupling
    archetype_applicable: true
    location: plan.md#expected-change-surface
    description: "The dedicated 'Godot Regression Tests' workflow runs only for changes under scripts/, scenes/, tests/, an addon path, project.godot and the workflow itself. After this change, level content lives in levels/ and export_presets.cfg, so a change that only adds or edits a pack (the workflow this feature exists to enable) will not trigger that workflow's pack gate."
    evidence: ".github/workflows/godot-regression-tests.yml on.push.paths / on.pull_request.paths (lines 7-21) omit levels/** and export_presets.cfg. Mitigating fact: .github/workflows/azure-static-web-apps-green-bay-09bdc1010.yml runs tests/run_puzzle_regressions.py and tests/run_regressions.py on every pull request to main (lines 87-91), with no paths filter."
    root_cause: "ci-path-filter-predates-levels-dir"
    intent_cue: ""
    base_severity: medium
    effective_severity: medium
    classification: deferred-work
    least_complex_mitigation: "Add 'levels/**' and 'export_presets.cfg' to both path lists in godot-regression-tests.yml (two lines each). Accepting the limitation is also viable because the deploy workflow already runs both gates on every PR, but that workflow's PR runs depend on a preview environment and are a weaker signal to rely on."
    mitigation_kind: validation
    recommended_action: "Developer decides whether to add the two path entries to .github/workflows/godot-regression-tests.yml in this spec; otherwise accept or defer."
    execution_mode: selective
    status: open
    outcome: ""
```

**Counts:** 1 finding (medium), 0 routed findings, 0 verification obligations. The Web export inclusion of pack files is already an end-to-end obligation in the spec (`verify:end-to-end`, T027), so it is not restated here.

**VERDICT:** CONDITIONAL

**Required Actions Before Implementation:**

1. The developer decides on critic-001: include the CI path-filter fix in this spec, accept the deploy workflow's coverage, or defer.

**Recommended Risk Mitigations:**

- critic-001: two path entries in `.github/workflows/godot-regression-tests.yml`.
