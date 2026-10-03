```yaml
gate: critic
status: warn
blocking: false
severity: warning
summary: "FULL run 2 after remediation (c96422a). All 12 prior findings are resolved in the artifacts. The remediation introduced 3 new risks, none critical: the strict CSP (default-src 'self') will also block the inline <style> and <script> that Astro and the Godot shell emit unless the build forbids or hashes them; headless WebGL in CI can make the synthetic check report false outages; and a two-tab Web Locks test under a DOM shim may prove only the shim. Verdict: PROCEED, applying critic-013 before Phase 8 and critic-014/015 when their tasks run."
reviewed_artifacts:
  - path: spec.md
    hash: "ce966a662651a79e53c96d46393cd047d7a764ec"
  - path: plan.md
    hash: "782ebd5588372a92eccef727593c7411d991f3f0"
  - path: tasks.md
    hash: "adad7c3cd3a93a706865b9a8afb74987f3a3889d"
  - path: research.md
    hash: "ac918a74b5fa9563e2b87fb76f6da58cb166954c"
  - path: data-model.md
    hash: "e28cb66e961440e98e968e150d20db25546c01f5"
  - path: contracts/reactions-api.md
    hash: "5dd6eec78c79fd0e217d81cf41d842c0ec886144"
  - path: contracts/site-content.md
    hash: "401813074a19c1d70a47683666840eb0827b4d0d"
```

## Technical Risk Assessment

**Analysis Date:** 2026-10-02
**Scope:** FULL
**Detected Archetype:** game (universal categories applied to the static web front end, as in run 1)
**Detected Stack:** GDScript on Godot 4.4-stable (Web, no threads, custom HTML shell); Astro + TypeScript (static); browser `localStorage` + Web Locks (pending queue); Azure Static Web Apps; the external API is out of scope
**Context Mode:** brownfield
**Risk Profile:** customer-facing (no severity shift)
**Risk Posture:** GREEN-YELLOW

### Executive Summary

The run 1 risks are closed in the artifacts:
- the CSP now accounts for WebAssembly and derives `connect-src` from the build setting;
- the engine lives under per-build paths;
- the zoom guard sits in the document that receives the events;
- every failure status is classified;
- the evidence rule is explicit;
- one synthetic check covers preview and production.

The new risks are second-order effects of those fixes. The tightened CSP's `default-src 'self'` will also block **inline styles and scripts** that Astro and the Godot shell emit, so the site or the loader could break in production in a different way. The other two concern whether the new tests prove what they claim. **Verdict: PROCEED.**

### Prior findings: verification

| ID | Status | Evidence |
|---|---|---|
| critic-001 | resolved | `risk_profile: customer-facing` |
| critic-002 | resolved | FR-026 A, data-model, contract consumer section, T052/T055: only 202 sent; 400/413/415 dropped; everything else kept |
| critic-003 | resolved (see critic-013 for a residual) | T068: `script-src 'self' 'wasm-unsafe-eval'` plus the shell bootstrap hash; `connect-src` from `PUBLIC_REACTIONS_URL`; T072 on the SWA preview with production headers |
| critic-004 | resolved | T001 custom shell guard; T025 limited to page chrome; per-browser record and accepted-limitation rule in T072 |
| critic-005 | resolved | `/game/<commit-short-sha>/` with an immutable cache; second-deploy check in T072 |
| critic-006 | resolved | FR-013 evidence hierarchy; R-1/R-2 ban `.devspark.work` in any URL form; owner decision recorded |
| critic-007 | resolved (see critic-015 for test fidelity) | T054 Web Locks plus claim-before-send fallback; two-context test in T051 |
| critic-008 / critic-011 | resolved (see critic-014 for flakiness) | One synthetic check: T014 builds it, T071 runs it per PR and daily during the window, T073/T076 switch it on and off |
| critic-009 | resolved | Visible-text, whole-word R-4; link fetching pre-publication and scheduled |
| critic-010 | resolved | `licenses.astro` (T010); `npm audit --audit-level=high` (T014) |
| critic-012 | resolved | Sizes in T002; transferred size and `Content-Encoding` on the preview in T070; optimize only on failure |

### Findings (source of truth)

```yaml
findings:
  - finding_id: critic-001
    category: documentation
    archetype_applicable: true
    location: spec.md#frontmatter
    description: "risk_profile was not a registry value."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "none (resolved)"
    execution_mode: auto
    status: resolved
    outcome: "Set to customer-facing (c96422a)."
  - finding_id: critic-002
    category: error_handling_resilience
    archetype_applicable: true
    location: spec.md#FR-026 A
    description: "404/405/CORS failures were unclassified while the API is absent."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "none (resolved)"
    execution_mode: auto
    status: resolved
    outcome: "Exact classification in FR-026 A, data-model, contract, T052/T055 (c96422a)."
  - finding_id: critic-003
    category: error_handling_resilience
    archetype_applicable: true
    location: tasks.md#T068, tasks.md#T072
    description: "CSP lacked script-src for Godot and WebAssembly; production headers were untested; connect-src was not bound to the reactions URL."
    intent_cue: ""
    base_severity: critical
    effective_severity: critical
    recommended_action: "none (resolved); see critic-013 for the inline-style/script residual"
    execution_mode: selective
    status: resolved
    outcome: "T068 defines 'wasm-unsafe-eval' plus the shell hash and derives connect-src; T072 runs on the SWA preview (c96422a)."
  - finding_id: critic-004
    category: concurrency_async
    archetype_applicable: true
    location: tasks.md#T001, tasks.md#T025
    description: "Zoom guard sat outside the iframe that receives the events."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "none (resolved)"
    execution_mode: selective
    status: resolved
    outcome: "Guard moved into the custom Godot shell; per-browser record (c96422a)."
  - finding_id: critic-005
    category: binary_size_perf
    archetype_applicable: true
    location: tasks.md#T068, tasks.md#T014
    description: "Unhashed engine files were long-cached."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "none (resolved)"
    execution_mode: selective
    status: resolved
    outcome: "Build-unique /game/<sha>/ path with an immutable cache; second-deploy check (c96422a)."
  - finding_id: critic-006
    category: documentation
    archetype_applicable: true
    location: spec.md#FR-013, contracts/site-content.md#R-1/R-2
    description: "Evidence lived in planning records that durable outputs may not link to."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "none (resolved)"
    execution_mode: manual
    status: resolved
    outcome: "Owner decision: no exception; FR-013 evidence hierarchy; R-1/R-2 enforce it (c96422a)."
  - finding_id: critic-007
    category: concurrency_async
    archetype_applicable: true
    location: tasks.md#T054, tasks.md#T051
    description: "Multi-tab flushes could double-send queued reactions."
    intent_cue: ""
    base_severity: medium
    effective_severity: medium
    recommended_action: "none (resolved); see critic-015 for test fidelity"
    execution_mode: auto
    status: resolved
    outcome: "Web Locks serialization plus claim-before-send fallback; two-context test (c96422a)."
  - finding_id: critic-008
    category: testing_strategy
    archetype_applicable: true
    location: tasks.md#T014, tasks.md#T071
    description: "Browser-level behavior was verified only manually."
    intent_cue: ""
    base_severity: high
    effective_severity: medium
    recommended_action: "none (resolved); see critic-014"
    execution_mode: selective
    status: resolved
    outcome: "One synthetic headless check on each preview (c96422a)."
  - finding_id: critic-009
    category: testing_strategy
    archetype_applicable: true
    location: tasks.md#T029, tasks.md#T033
    description: "R-4 scan and link fetching would be flaky."
    intent_cue: ""
    base_severity: medium
    effective_severity: medium
    recommended_action: "none (resolved)"
    execution_mode: auto
    status: resolved
    outcome: "Visible-text whole-word scan; fetch pre-publication and scheduled (c96422a)."
  - finding_id: critic-010
    category: dependency_supply_chain
    archetype_applicable: true
    location: tasks.md#T010, tasks.md#T014
    description: "Redistributed licences and npm audit were missing."
    intent_cue: ""
    base_severity: medium
    effective_severity: medium
    recommended_action: "none (resolved)"
    execution_mode: auto
    status: resolved
    outcome: "licenses.astro page; npm audit --audit-level=high (c96422a)."
  - finding_id: critic-011
    category: error_handling_resilience
    archetype_applicable: true
    location: tasks.md#T071, tasks.md#T073, tasks.md#T076
    description: "No signal if the game stopped loading during the window."
    intent_cue: ""
    base_severity: medium
    effective_severity: medium
    recommended_action: "none (resolved); see critic-014"
    execution_mode: selective
    status: resolved
    outcome: "Same synthetic check scheduled daily during the window (c96422a)."
  - finding_id: critic-012
    category: binary_size_perf
    archetype_applicable: true
    location: tasks.md#T002, tasks.md#T070
    description: "WebAssembly compression on SWA was assumed."
    intent_cue: ""
    base_severity: medium
    effective_severity: medium
    recommended_action: "none (resolved)"
    execution_mode: auto
    status: resolved
    outcome: "Raw and transferred sizes and Content-Encoding recorded; optimize only on failure (c96422a)."
  - finding_id: critic-013
    category: error_handling_resilience
    archetype_applicable: true
    location: tasks.md#T068 (CSP), tasks.md#T006 (Astro config), tasks.md#T001 (custom shell)
    description: "The CSP sets default-src 'self' and a script-src that allows only 'self', 'wasm-unsafe-eval' and the shell bootstrap hash. It sets no style-src, so inline <style> falls back to default-src and is blocked. Astro inlines small stylesheets and is:inline scripts by default, and Godot's shell has an inline <style> for the loader. In production only, pages could render unstyled or lose inline behavior. The engine may also need blob: or worker URLs (for example its audio worklet) that the policy doesn't list."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "Edit T006 to set Astro build.inlineStylesheets to 'never' and forbid is:inline scripts (or hash every inline block at build). Edit T001/T068 so the shell's inline <style> is moved to a file or hashed into style-src, and add explicit style-src/img-src/font-src/worker-src directives. Keep the T072 preview check for CSP console violations as the proof, and add any engine-required source it reveals (e.g. blob:) narrowly."
    execution_mode: selective
    status: resolved
    outcome: "Applied in T006/T001/T068: inlining disabled (styles and scripts as files, markdown highlighting off), shell styles moved to shell.css, explicit style/img/font/worker/connect directives, and a build step that fails on any unhashed inline block. Local enforcement found and fixed two real cases (highlighter style attributes; Godot blob: images, allowed in img-src only). SWA-preview confirmation remains part of the browser smoke (2026-10-02)."
  - finding_id: critic-014
    category: testing_strategy
    archetype_applicable: true
    location: tasks.md#T014 (synthetic-check.mjs), tasks.md#T071 (daily schedule)
    description: "The synthetic check waits for engineState=started in a headless CI browser. Hosted CI runners have no GPU, and headless Chromium's software WebGL path is version-dependent, so the Godot Compatibility renderer may fail to start in CI while it works for real visitors. A daily false 'outage' trains the owner to ignore the only live signal."
    intent_cue: ""
    base_severity: medium
    effective_severity: medium
    recommended_action: "In T014, launch the headless browser with an explicit software WebGL backend (e.g. ANGLE/SwiftShader flags for Chromium) and record in evidence which backend ran. Distinguish 'engine failed to start' from 'WebGL unavailable in runner'. Only the former fails the check; the latter is reported as inconclusive."
    execution_mode: selective
    status: resolved
    outcome: "Applied in T014: synthetic-check.mjs launches Chromium with ANGLE/SwiftShader, logs the renderer, and exits 3 (inconclusive, CI warning) when no WebGL2 context exists; only an engine start failure with WebGL2 available, a console error or a CSP violation fails (2026-10-02)."
  - finding_id: critic-015
    category: testing_strategy
    archetype_applicable: true
    location: tasks.md#T051 (two-context test), tasks.md#T054
    description: "The planned unit-test environment (Vitest with a DOM shim) has no real Web Locks or cross-tab storage semantics. A 'two contexts flush once' test there would prove the hand-written lock shim, not that two real tabs never double-send."
    intent_cue: ""
    base_severity: medium
    effective_severity: medium
    recommended_action: "Keep the unit test for the claim-before-send logic, and run the two-tab case once in a real browser: two pages of one browser context in the synthetic-check runner, or a manual step in the T072 smoke. Record the result."
    execution_mode: auto
    status: resolved
    outcome: "Unit test kept for queue logic (lock and claim paths); a real two-tab flush run in Chromium (real Web Locks) against the mock delivered each of 4 entries exactly once in 3 runs, recorded in evidence/browser-smoke.md (2026-10-02)."
```

### High

| ID | Category | Location | Issue | Impact | Suggestion |
|---|---|---|---|---|---|
| critic-013 | error_handling_resilience | T068, T006, T001 | `default-src 'self'` blocks the inline styles and scripts Astro and the Godot shell emit; the engine may need blob:/worker sources | Unstyled or partly broken pages, or loader failures, in production only | Disable inlining in the Astro config or hash inline blocks; move or hash the shell `<style>`; set explicit style/img/font/worker directives; prove on the preview |

### Questionable Assumptions

1. **"script-src is the only CSP directive Godot and Astro need."** Failure mode: inline style and blob or worker sources are blocked (critic-013).
2. **"A headless CI browser renders WebGL like a visitor's browser."** Failure mode: false outage signals (critic-014).
3. **"A DOM-shim test proves cross-tab locking."** Failure mode: it proves only the shim (critic-015).

### Metrics

- Effective: showstopper 0 · critical 0 open (1 resolved) · high 1 open (5 resolved) · medium 2 open (6 resolved)
- Open by category: error_handling_resilience 1, testing_strategy 2
- Missing operational tasks: 0 (all run 1 gaps are now owned by existing tasks)
- No stack/archetype checklists exist yet; run 1's suggestion to seed `game.md` and `web-static.md` stands.

**VERDICT:** PROCEED

**Required before the affected phase:**

1. critic-013 into T006, T001 and T068 before Phase 8 (publication). It is the only finding that could change production behavior.

**Recommended Risk Mitigations:**

- critic-014: pin the headless WebGL backend and separate "inconclusive" from "failed".
- critic-015: one real two-tab run.
