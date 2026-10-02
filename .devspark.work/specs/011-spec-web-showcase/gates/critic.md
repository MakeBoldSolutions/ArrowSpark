```yaml
gate: critic
status: warn
blocking: false
severity: warning
summary: "FULL critique. No showstoppers, 1 critical, 5 high, 6 medium. The design is sound and correctly bounded. The risks sit at the browser/hosting seams the plan only checks by hand, plus one governance tension: the security headers can break the engine only in production; unhashed engine files are long-cached; the page-zoom guard sits outside the iframe that receives the events; 404 and CORS failures are unclassified while the API is expected to be absent; and published content's strongest evidence lives in planning records that durable outputs may not link to. All are fixable by editing existing tasks before or during implementation."
reviewed_artifacts:
  - path: spec.md
    hash: "abd3541be5513f43461bdc16487690f1188dc927"
  - path: plan.md
    hash: "e93ae84b2b010ae6c18bca8c0cd2620eb141fecc"
  - path: tasks.md
    hash: "8bf009f885131693e6b812b78db120c8791a2c92"
  - path: research.md
    hash: "e946c5239bfaf82a112bf309c88a3cf56001b43b"
  - path: contracts/reactions-api.md
    hash: "c17b5c25cb6eceb61853643065ac824366be4df7"
```

## Technical Risk Assessment

**Analysis Date:** 2026-10-02T20:59Z
**Scope:** FULL (spec + plan + tasks; research, data-model, contracts and quickstart also read)
**Detected Archetype:** game (frontmatter). Because this delta is mostly a static web front end hosting a Godot Web export, the universal categories (`trust_boundaries`, `error_handling_resilience`, `testing_strategy`, `dependency_supply_chain`, `documentation`) were applied to the site, along with `concurrency_async` and `binary_size_perf` for the game archetype.
**Detected Stack:** GDScript on Godot 4.4-stable (Web, no threads), Astro + TypeScript (static), browser `localStorage` (pending queue only); hosting on Azure Static Web Apps; the external API is out of scope.
**Context Mode:** brownfield
**Risk Profile:** customer-facing (frontmatter value `public` is not a registry value; see critic-001). Severity shift 0.
**Risk Posture:** YELLOW

### Executive Summary

The artifacts are well bounded: the rule core is untouched, the API is external, the queue is tightly specified, and S-1 is correctly a branch gate. What will go wrong is at the seams the plan verifies only by hand, after the fact:

- the production security headers can stop the Godot engine from starting, and nothing tests them before go-live;
- the engine's unhashed files are long-cached across redeploys;
- the page-zoom guard runs in a document that never receives the iframe's events;
- the "API not deployed yet" state, which the plan deliberately publishes into, returns `404`/CORS failures the client contract doesn't classify.

Separately, the story's best evidence (gate reports, the deferral protocol, PR review files) lives in planning records that DevSpark forbids durable outputs from linking to, so the content check and the governance rule will collide at publication. **Verdict: CONDITIONAL.** Resolve critic-002 through critic-006 by editing existing tasks before the affected phases start.

### Findings (source of truth)

```yaml
findings:
  - finding_id: critic-001
    category: documentation
    archetype_applicable: true
    location: spec.md#frontmatter (risk_profile)
    description: "risk_profile is 'public', which is not a registry value (experimental | internal | customer-facing | revenue-critical | safety-critical | regulated). Gates fall back to defaults, so severity scaling is not deterministic across runs."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "Set spec.md frontmatter risk_profile: customer-facing (a public showcase with anonymous visitors and no revenue)."
    execution_mode: auto
    status: open
    outcome: ""
  - finding_id: critic-002
    category: error_handling_resilience
    archetype_applicable: true
    location: spec.md#FR-026 (part A), tasks.md#T053, tasks.md#T055
    description: "The client maps 202 → sent, 400/413/415 → drop, and 429/5xx/network/timeout → keep, but 404/405 and CORS or CSP rejections are unclassified. These are exactly what a visitor gets while the endpoint is not yet deployed, which the plan deliberately publishes into. If an implementation treats 404 as 'not acceptable', every reaction written before the API ships is silently deleted instead of queued."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "In FR-026 A and data-model.md, classify every status other than 202 and 400/413/415 as 'unavailable → keep' (explicitly including 404, 405, opaque/CORS TypeError and CSP-blocked fetch). Add those cases to the T055 client tests and the T051 queue tests."
    execution_mode: auto
    status: open
    outcome: ""
  - finding_id: critic-003
    category: error_handling_resilience
    archetype_applicable: true
    location: tasks.md#T068 (staticwebapp.config.json CSP), tasks.md#T072 (smoke environment), plan.md#R6 SWA config
    description: "The planned CSP specifies connect-src and frame-ancestors but not script-src. A Godot Web export's generated index.html runs inline bootstrap script and compiles WebAssembly, which a default 'self' script-src blocks: inline scripts need a hash or allowance, and WebAssembly needs 'wasm-unsafe-eval'. These headers exist only in Azure Static Web Apps, not in the local dev server where the smoke checklist is described, so the first time the engine meets them is production. A connect-src not derived from PUBLIC_REACTIONS_URL would also block every submission silently, and each reaction then sits queued until it expires."
    intent_cue: ""
    base_severity: critical
    effective_severity: critical
    recommended_action: "Edit T068 to define script-src 'self' 'wasm-unsafe-eval' plus a hash (or nonce-free allowance) for the Godot shell's inline script, and to generate connect-src from PUBLIC_REACTIONS_URL at build time. Edit T072 so the browser smoke test runs against the deployed SWA preview environment (production headers), with the devtools console checked for CSP violations, not only against a local export."
    execution_mode: selective
    status: open
    outcome: ""
  - finding_id: critic-004
    category: concurrency_async
    archetype_applicable: true
    location: tasks.md#T025 (page-zoom-guard.ts), tasks.md#T026, plan.md#Phase 4 step 5
    description: "page-zoom-guard.ts runs in the Astro host page, but ctrl+wheel (trackpad pinch) and Ctrl/Cmd +/- over the game are dispatched to the iframe's own document and never bubble to the parent. The guard therefore cannot stop page zoom where it matters, and Firefox and Safari differ in whether keyboard zoom can be prevented at all."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "Move the guard into the game document by adding a custom Godot HTML shell (the export preset's custom HTML shell option) with the same listeners. Keep the host-page guard only for the frame border and chrome. Record per browser in T072 whether pinch and keyboard zoom are prevented, and accept residual keyboard zoom as a limitation if a browser disallows preventDefault."
    execution_mode: selective
    status: open
    outcome: ""
  - finding_id: critic-005
    category: binary_size_perf
    archetype_applicable: true
    location: plan.md#R6 SWA config ("long cache for hashed engine files"), tasks.md#T068, tasks.md#T079 (feedback-closed rebuild)
    description: "Godot Web exports use fixed file names (index.wasm, index.pck, index.js) with no content hash. Caching them long-term means any redeploy (a game fix, the feedback-closed rebuild) can serve a fresh index.html with a stale cached .pck or .wasm. That mismatch fails at engine start for returning visitors, who are exactly the ones whose queued reactions the design depends on."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "Choose one in T068/T014: deploy each export under a build-unique path (e.g. /game/<commit-short-sha>/) with long cache, or serve /game/* with Cache-Control: no-cache (ETag revalidation). Add a T072 check: deploy twice, reload, and confirm the new build loads."
    execution_mode: selective
    status: open
    outcome: ""
  - finding_id: critic-006
    category: documentation
    archetype_applicable: true
    location: spec.md#FR-013, contracts/site-content.md#R-1 and R-2, tasks.md#T038-T043, .devspark/templates/command-preamble-contract.md §0
    description: "The story's strongest receipts (Spec 010's critic and verify gates, the deferral protocol, the PR review files, spec-006-report) live under .devspark.work/. R-1 rejects any content containing '.devspark.work', and the DevSpark contract forbids durable outputs from linking to spec, plan or task records 'live or archived'. Authors will either break the rule or silently drop the evidence FR-012/FR-013 call for, and this surfaces at publication time, which is the most expensive time to find it."
    intent_cue: ""
    base_severity: high
    effective_severity: high
    recommended_action: "Decide explicitly before content work (T033-T047). Recommended: published content may cite commits, merged PRs and durable files (code, tests, .knowledge reports) by permalink, and quote short excerpts from planning records with the commit that introduced them, never linking a .devspark.work path. Write this rule into contracts/site-content.md R-1/R-2. If owner prefers direct links, scope an explicit exception into the P1 constitution amendment (T003) instead."
    execution_mode: manual
    status: open
    outcome: ""
  - finding_id: critic-007
    category: concurrency_async
    archetype_applicable: true
    location: spec.md#FR-032, tasks.md#T054 (pending-queue.ts), tasks.md#T051
    description: "flush() runs on every page load. A visitor with two showcase tabs (common for Play next to Built with DevSpark) loads both and each reads the same queue, so both POST the same entries before either removes them. Since the design has no de-duplication by intent, duplicates go straight into a tens-of-reactions evidence set."
    intent_cue: ""
    base_severity: medium
    effective_severity: medium
    recommended_action: "In T054, serialize flush with the Web Locks API (navigator.locks.request('arrowspark-reactions', ...), supported in all three target browsers), or claim entries by removing them from storage before sending and re-adding them on a keep outcome. Add a two-context test to T051."
    execution_mode: auto
    status: open
    outcome: ""
  - finding_id: critic-008
    category: testing_strategy
    archetype_applicable: true
    location: plan.md#Validation Matrix, tasks.md#T014, tasks.md#T072
    description: "Everything the static site cannot prove in unit tests is checked only by the manual three-browser smoke test, once, before publication: engine load under production headers, MIME types, cache behavior, the real postMessage hop, and audio unlock. A later content-only deploy (chapter fix, feedback-closed rebuild) can break the game with no automated signal."
    intent_cue: ""
    base_severity: high
    effective_severity: medium
    recommended_action: "Add to T014 one headless-browser check (e.g. Playwright, or any WebDriver runner) that loads the built site, waits for the Godot canvas to report ready, asserts no console or CSP errors, and receives one attemptCompleted from a scripted test build. Run it against the SWA preview on each PR. Keep the manual smoke test for input feel and Safari."
    execution_mode: selective
    status: open
    outcome: ""
  - finding_id: critic-009
    category: testing_strategy
    archetype_applicable: true
    location: tasks.md#T029 (R-4 scan), tasks.md#T033 (--fetch-links), contracts/site-content.md#R-4
    description: "Two checks will be flaky. The R-4 scan of built HTML will match 'zone' inside script and attribute text (e.g. timeZone), and similar substrings, failing builds for no reason. The --fetch-links mode, if run on every CI push, will hit GitHub's unauthenticated rate limits and fail intermittently."
    intent_cue: ""
    base_severity: medium
    effective_severity: medium
    recommended_action: "Scan visible text nodes only (strip script, style and attributes; match whole words, case-insensitive). Run --fetch-links as an explicit pre-publication step and on a schedule, not on every push."
    execution_mode: auto
    status: open
    outcome: ""
  - finding_id: critic-010
    category: dependency_supply_chain
    archetype_applicable: true
    location: tasks.md#T007 (OFL notices only), tasks.md#T010 (footer licences link), tasks.md#T014
    description: "The web build redistributes the Godot engine (MIT, with bundled third-party licences in the export), Maaack's Game Template and the fonts, but only the font OFL notices are planned. The site's npm dependencies also have no audit step, though the sibling API repository gates on `npm audit --audit-level=high`."
    intent_cue: ""
    base_severity: medium
    effective_severity: medium
    recommended_action: "Extend T010's licences link to a /licenses page listing Godot (with its third-party notices), Maaack's Game Template, Lucide (ISC) and the fonts (OFL). Add `npm audit --audit-level=high` to T014."
    execution_mode: auto
    status: open
    outcome: ""
  - finding_id: critic-011
    category: error_handling_resilience
    archetype_applicable: true
    location: plan.md#Phase 8 (learning window), spec.md#FR-018
    description: "With no telemetry by design, nobody learns during the 14-day window that the game stopped loading for real visitors (a browser update, a CSP or cache regression, an SWA incident) unless an observed participant happens to hit it. A silent multi-day outage would empty the evidence window."
    intent_cue: ""
    base_severity: medium
    effective_severity: medium
    recommended_action: "Schedule the critic-008 headless check to run daily against production during the window. It tracks no visitors, only the owner's own synthetic load. Record its results in evidence/window.md."
    execution_mode: selective
    status: open
    outcome: ""
  - finding_id: critic-012
    category: binary_size_perf
    archetype_applicable: true
    location: spec.md#SC-001, tasks.md#T070, research.md#R6 (SWA config)
    description: "SC-001's 30 s at 25 Mbps assumes the Godot runtime (tens of MB uncompressed) arrives compressed. Azure Static Web Apps' automatic compression is not guaranteed for application/wasm or .pck, so an uncompressed transfer could exceed the target on the cold-cache profile."
    intent_cue: ""
    base_severity: medium
    effective_severity: medium
    recommended_action: "In S-1 (T002) record raw and compressed sizes. In T070 confirm the Content-Encoding actually served for .wasm and .pck on the SWA preview. If uncompressed, add precompressed assets or accept and record the measured time. Don't build optimization infrastructure."
    execution_mode: auto
    status: open
    outcome: ""
```

### Critical

| ID | Category | Location | Risk | Likely Impact | Action |
|---|---|---|---|---|---|
| critic-003 | error_handling_resilience | T068, T072, plan R6 | CSP lacks script-src for the Godot shell and WebAssembly; production-only headers are never tested before go-live; connect-src not tied to the reactions URL | Game fails to start on the live site, or reactions are silently CSP-blocked and stuck in queues | Define script-src (`'wasm-unsafe-eval'` plus a shell hash) and derive connect-src from the build setting; run the smoke test on the SWA preview with production headers |

### High

| ID | Category | Location | Issue | Impact | Suggestion |
|---|---|---|---|---|---|
| critic-001 | documentation | spec frontmatter | `risk_profile: public` is invalid | Non-deterministic severity scaling across gates | Use `customer-facing` |
| critic-002 | error_handling_resilience | FR-026 A, T053, T055 | 404/405/CORS failures are unclassified during "API not yet live" | Reactions written before the API ships may be deleted instead of queued | Classify them as unavailable → keep; test them |
| critic-004 | concurrency_async | T025, T026 | Zoom guard sits outside the iframe that receives the events | Pinch and keyboard page zoom still hit visitors | Put the guard in a custom Godot HTML shell; record per browser |
| critic-005 | binary_size_perf | plan R6, T068 | Unhashed engine files are long-cached | A redeploy breaks the game for returning visitors | Build-unique `/game/<sha>/` path, or `no-cache` with ETag |
| critic-006 | documentation | FR-013, site-content R-1/R-2 | Best evidence lives in planning records that durable outputs may not link to | Rule violation or lost evidence, found at publication | Cite commits, PRs and durable files; quote excerpts; or scope an exception in P1 |

### Missing Critical Tasks

- **Testing:** an automated headless-browser load check of the built site with the engine under production-equivalent headers (critic-008).
- **Operations:** a daily synthetic liveness check during the learning window (critic-011).
- **Documentation / Legal:** a licences page for the redistributed engine, template, icons and fonts (critic-010).
- **Security / Supply chain:** `npm audit` in CI (critic-010); a CSP specification for the engine (critic-003).

### Questionable Assumptions

1. **"The smoke test catches header problems."** Failure mode: it runs on a local export, where Azure Static Web Apps' production headers don't exist (critic-003, critic-008).
2. **"The guard can stop page zoom from the host page."** Failure mode: iframe events never reach the parent (critic-004).
3. **"A missing endpoint looks like a 5xx."** Failure mode: it's a 404 or a CORS TypeError (critic-002).
4. **"Engine files are hashed."** Failure mode: Godot's are not (critic-005).
5. **"Static hosting compresses WebAssembly."** Failure mode: not guaranteed (critic-012).
6. **"Commit-pinned links are always acceptable evidence."** Failure mode: the DevSpark contract bars linking planning records from durable outputs (critic-006).

### Dependency Risk Assessment

| Dependency | Concern | Alternative |
|---|---|---|
| Godot 4.4-stable web templates | Large download in CI; fixed file names; inline bootstrap under CSP | Cache by version (planned); versioned deploy path; shell hash in CSP |
| Azure Static Web Apps | Header, MIME and compression behavior differs from local dev; preview URLs are public | Test on the preview environment; content-only previews are fine |
| Astro (current major at implementation) | Major-version drift between plan and implementation | Lockfile pin (planned); `npm audit` (critic-010) |
| External reactions API | Absent at publication by design | Contract plus queue (planned); classify 404/CORS (critic-002) |

### Estimated Technical Debt at Launch

- **Operational:** no live signal for engine-load failures without critic-011.
- **Testing:** browser-level behavior is manual-only without critic-008.
- **Documentation:** licence attribution gap (critic-010) and the evidence-citation rule (critic-006).
- **Code:** low. The rule core is untouched and the new GDScript surface is two small files.

### Metrics

- Showstopper 0 · Critical 1 · High 5 · Medium 6 (effective; critic-008 sits at medium effective, high base)
- By category: error_handling_resilience 3 (002, 003, 011) · documentation 2 (001, 006) · concurrency_async 2 (004, 007) · binary_size_perf 2 (005, 012) · testing_strategy 2 (008, 009) · dependency_supply_chain 1 (010)
- Missing operational tasks: 4 (headless load check, window liveness check, licences page, npm audit)
- No stack/archetype checklists were found at `.devspark/risk-checklists/` or `.devspark.work/risk-checklists/`; risks were derived from first principles. Consider seeding `game.md` and `web-static.md` from this run.

**VERDICT:** CONDITIONAL

**Required Actions Before Implementation:**

1. critic-006: decide the evidence-citation rule and write it into contracts/site-content.md (owner decision, `manual`) before content tasks start.
2. critic-002: classify 404/405/CORS/CSP failures as unavailable → keep in FR-026 A and data-model.md.
3. critic-001: set `risk_profile: customer-facing`.

**Required before the affected phase (edit existing tasks; no new scope):**

- critic-003 and critic-005 into T068/T014/T072 before Phase 8.
- critic-004 into T025/T026 and the export preset (T001) before US1 completes.
- critic-007 into T054/T051.

**Recommended Risk Mitigations:**

- critic-008/011: one headless load check, run per PR on the SWA preview and daily during the window.
- critic-009: scan visible text only, and run link-fetch pre-publication.
- critic-010: licences page and `npm audit`.
- critic-012: record compression in S-1 and T070.
