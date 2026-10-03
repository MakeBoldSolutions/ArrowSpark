# Pull Request Review: feat(web): ArrowSpark web showcase — playable Web build, story site and reactions client

```yaml
gate: pr-review
devspark_version: "7.8.0"
generated: "2026-10-03T02:45:00Z"
status: pass
blocking: false
severity: info
summary: "Re-review at e4733b3: H-01 resolved (single Azure-named build-and-deploy workflow with the existing secret; first green preview deploy). Owner approved after reviewing the preview. L-01/L-02 remain optional."
```

## Review Metadata

- **PR Number**: #5
- **Source Branch**: 011-spec-web-showcase
- **Target Branch**: main
- **Review Date**: 2026-10-03 02:45:00 UTC
- **Last Updated**: 2026-10-03 03:25:00 UTC
- **Reviewed Commit**: e4733b3
- **Reviewer**: devspark.pr-review
- **Constitution Version**: 2.1.0

## Revision Log

| Rev | Commit | Date | Critical | High | Medium | Low | CON | Test Command | Result |
|-----|--------|------|----------|------|--------|-----|-----|--------------|--------|
| 1 | 778ce6c | 2026-10-03 | 0 | 1 | 0 | 2 | 0 | `cd web && npx vitest run && npx astro check` | pass (50/50 tests; 0 errors) |
| 2 | e4733b3 | 2026-10-03 | 0 | 0 | 0 | 2 | 0 | `cd web && npx vitest run && npx astro check` + CI | pass (CI: Build and Deploy, Synthetic Check (deployment), regressions all green) |

Godot regression gates were not run locally in this review (no 4.4 binary in the review environment); CI `regressions` and `Showcase / build` were still pending at review time.

## PR Summary

- **Author**: @markhazleton
- **Created**: 2026-10-03
- **Status**: OPEN (merge state UNSTABLE: one failing check)
- **Files Changed**: 246 (≈120 durable, remainder `.devspark/` framework upgrade, `.claude/` commands and this feature's `.devspark.work/` bundle)
- **Commits**: 14 (+ 1 merge of `main`)
- **Lines**: +20,209 −432

## Stats

| Metric | Value |
|--------|-------|
| Files changed | 246 |
| Lines added | +20,209 (of which 5,986 `web/package-lock.json`) |
| Lines removed | −432 |
| Net lines | +19,777 |
| Commit snapshot | `778ce6c` |

*Collected via `git diff --numstat origin/main...HEAD`.*

## Executive Summary

- ✅ **Constitution Compliance**: PASS with one outstanding MUST check (5/6 principles pass; V partial — browser smoke on supported desktop browsers disclosed as not yet performed)
- 🔄 **Durable Delta Consistency**: PASS (0 open PRD findings)
- 🔒 **Security**: 0 issues found
- 📊 **Code Quality**: 2 low recommendations
- 🧪 **Testing**: PASS (Vitest 50/50, `astro check` 0 errors; Godot gates pending in CI)
- 📝 **Documentation**: PASS
- 🏛️ **Constitution Improvements**: 0 CON findings

**Overall Assessment**: A carefully bounded change — the game↔page bridge is one-way, origin- and source-checked, and strictly validated; the reactions client sends no identifiers and its queue is bounded and well tested; knowledge mirrors the code precisely. The blocker is CI: the deploy job references a secret that does not exist, and the Azure-generated workflow merged in from `main` fails on every run.

**Approval Recommendation**: ✅ APPROVE
*Note: approval depends only on the durable delta, validation evidence, constitution, and unresolved findings.*

## Action Items

### Immediate Actions (Blocking — must resolve before merge)

- [x] **H-01** ✅ Resolved in b6148b5, 545f585, bdb5352, e4733b3 — `.github/workflows/showcase.yml:158` — Deploy secret name does not exist; duplicate Azure-generated workflow fails on every PR/push
  - **Broken code**:
    ```yaml
    # showcase.yml:158 and :201
    azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
    # .github/workflows/azure-static-web-apps-green-bay-09bdc1010.yml (now on the branch via main)
    app_location: "/" # App source code path
    output_location: ""
    ```
  - **Fix**: delete `.github/workflows/azure-static-web-apps-green-bay-09bdc1010.yml` and use the secret that exists (or add an `AZURE_STATIC_WEB_APPS_API_TOKEN` repo secret holding the same token and leave the YAML as is):
    ```yaml
    azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN_GREEN_BAY_09BDC1010 }}
    ```
    If the YAML changes, update the secret name in `.knowledge/architecture/web-showcase.md:317-318` in the same commit.

### Recommended Improvements

- [ ] **L-01** `scripts/presentation/web_attempt_emitter.gd:24` — clamp `elapsedSeconds` to the 86,400 contract maximum so a very long attempt is not silently dropped by the page
- [ ] **L-02** `web/src/scripts/pending-queue.ts:136` — claim-based flush (no Web Locks) loses claimed entries if the tab closes mid-flush

### Constitution Improvements (Non-blocking — feed into `/devspark.evolve-constitution`)

None.

## What's Good

- `web/src/scripts/game-bridge.ts:58-61` checks origin **and** `event.source === iframe.contentWindow`, caps message length, and requires exactly the eight contract keys — a tight trust boundary for `postMessage`.
- `scripts/presentation/web_attempt_emitter.gd` is a pure, fire-and-forget `RefCounted` sibling that no-ops outside Web builds, preserving the rule-core/scene boundary; `PuzzleContentVersion` names directions by string so enum reordering cannot change a version.
- `web/scripts/build-csp.mjs` fails the build if any page carries inline script/style the strict CSP would block, hashes only the Godot bootstrap, and derives `connect-src` from the same `PUBLIC_REACTIONS_URL` the site uses — directly closes the critic's CSP risk.
- `web/src/scripts/reaction-client.ts` sends `credentials: 'omit'`, `referrerPolicy: 'no-referrer'`, `no-store`, with an exact status classification; the queue never evicts, is capped at 5, expires at 7 days, and is covered by `web/tests/pending-queue.test.ts`.
- New GDScript behavior has focused tests: content-version sensitivity (tail, direction, size), payload rounding/clamping at 0, emit no-op off-Web, results overlay sizing without resize, Level Select descriptions.

## Findings Detail

### Critical Issues (Blocking)

None found.

### High Priority Issues

| ID | Status | Principle | File:Line | Issue | Fix |
|----|--------|-----------|-----------|-------|-----|
| H-01 | ✅ Resolved | V. Practical Gameplay Verification (§V.HIGH — the required browser smoke test on the preview cannot happen while the preview cannot deploy) | .github/workflows/showcase.yml:158, :201 | `secrets.AZURE_STATIC_WEB_APPS_API_TOKEN` is not defined (`gh secret list` shows only `AZURE_STATIC_WEB_APPS_API_TOKEN_GREEN_BAY_09BDC1010`), so `deploy` and `close-preview` will fail authentication and `synthetic-preview` never runs. Separately, the Azure-portal workflow merged from `main` uploads the repo root unbuilt and already failed on this PR (run 37090692586: "Could not detect the language from repo… Failed to find a default file in the app artifacts folder (/)"). Two workflows also target the same Static Web App on every push to `main`. | Delete the Azure-generated workflow; point `showcase.yml` (both uses) at the existing secret or create the expected secret; keep `web-showcase.md` in step with the secret name. |

### Durable Delta Consistency Findings (Blocking)

None found. `.knowledge/architecture/web-showcase.md` matches the bridge contract (`game-bridge.ts:23-50`), queue bounds (`pending-queue.ts:10-11`), client classification, CSP directives (`build-csp.mjs:65-81`) and the deploy design. `arrow-puzzle.md`, `save-progression.md`, `branding.md` and the constitution were updated alongside the code. Knowledge index is current. Planning-identifier scan of durable files: the only hit is `.knowledge/index.json:13`, the framework's root declaration of the `.devspark.work/` directory — a convention, not a reference to a planning document.

### Medium Priority Suggestions

None found.

### Low Priority Improvements

| ID | Status | Principle | File:Line | Issue | Recommendation |
|----|--------|-----------|-----------|-------|----------------|
| L-01 | 🔴 Open | I. Simple, Maintainable Code | scripts/presentation/web_attempt_emitter.gd:24 | `maxi(0, roundi(elapsed_msec / 1000.0))` has no upper bound, but `game-bridge.ts:50` and `reaction-schema.ts:59` reject `elapsedSeconds > 86_400`. An attempt left open across a day (tab left overnight) is silently discarded by the page, so the following game reaction carries no attempt. | `clampi(roundi(elapsed_msec / 1000.0), 0, 86_400)` and one more assertion in `_check_web_attempt_payload`; or document the drop in `web-showcase.md`. |
| L-02 | 🔴 Open | — (reliability; no constitution section) | web/src/scripts/pending-queue.ts:131-145 | Without Web Locks, `flushByClaiming` writes `[]` before sending; if the tab closes during the sends, unsent claimed entries are gone. Only affects browsers lacking `navigator.locks` (all current supported desktop browsers have it). | Acceptable as-is; optionally note the trade-off in the module comment or `web-showcase.md`. |

### Constitution Improvements

None found.

## Constitution Alignment Details

| Principle | Status | Evidence | Notes |
|-----------|--------|----------|-------|
| I. Simple, Maintainable Code | ✅ Pass | `puzzle_content_version.gd`, `web_attempt_emitter.gd` | snake_case filenames/functions, explicit types, small focused classes |
| II. Prefer Project-Level Template Customization | ✅ Pass | no `addons/` changes | All behavior in project scripts/scenes |
| III. Accessible, Configurable Controls | ✅ Pass | `puzzle_select_menu.gd:38-44` | New description labels are `FOCUS_NONE`, so keyboard/gamepad focus order is unchanged; covered by `_check_level_select_group_descriptions` |
| IV. Responsive Gameplay | ✅ Pass | `arrow_puzzle.gd:215` | Emit is a single non-blocking `postMessage` at results time; no frame-loop work |
| V. Practical Gameplay Verification | ⚠️ Partial | PR body "Not yet run" | Godot validation, both regression gates (4.4-stable) and headless Chromium play recorded. The MUST "smoke-tested in each supported desktop browser" is disclosed as outstanding (Chromium, Firefox, Safari on the preview) — compliant disclosure, but not yet met; blocked in practice by H-01 |
| VI. Preserve Saved Progress and Settings | ✅ Pass | `save-progression.md` | No save-format change; Web storage limited to the pending-reaction key, separate from game saves |

## Security Checklist

- [x] No hardcoded secrets or credentials — secrets referenced only via `secrets.*`; `PUBLIC_REACTIONS_URL` is a public build variable
- [x] Input validation present where needed — `postMessage` data and reaction bodies validated against exact schemas
- [x] Authentication/authorization checks appropriate — none introduced by design (anonymous, no accounts)
- [x] No SQL injection vulnerabilities — no database
- [x] No XSS vulnerabilities — only `set:html` is `Icon.astro:41` rendering repository SVG files; free text is never rendered back
- [x] Dependencies reviewed for vulnerabilities — CI runs `npm audit --audit-level=high`

Workflow `permissions: contents: read` is least-privilege; deploy is limited to same-repository PRs.

## Testing Coverage

**Status**: ADEQUATE

Vitest (local, this review): 4 files, 50 tests passed — `game-bridge`, `pending-queue`, `reaction-client`, `reaction-schema`. `astro check`: 0 errors, 0 warnings, 1 hint. GDScript additions covered in `tests/puzzle_catalog_check.gd`, `tests/puzzle_layout_check.gd`, `tests/puzzle_presentation_check.gd`. Godot gates not executed locally; CI pending at review time.

## Test Inventory

| File | Main | Branch | Delta | Justification |
|------|------|--------|-------|---------------|
| `tests/puzzle_catalog_check.gd` | — | +1 check fn | +1 | content-version pin |
| `tests/puzzle_layout_check.gd` | — | +2 check fns | +2 | results overlay sizing, group descriptions |
| `tests/puzzle_presentation_check.gd` | — | +1 check fn | +1 | Web attempt payload |
| `web/tests/*.test.ts` | 0 | 50 | +50 | new |

Removed tests: none.

## Documentation Status

**Status**: ADEQUATE — new `web-showcase.md` node; `arrow-puzzle.md`, `save-progression.md`, `branding.md`, `tests/README.md`, `CLAUDE.md`, `AGENTS.md`, constitution 2.1.0 updated.

## Changed Files Summary

| File | Tier | Changes | Type | Findings |
|------|------|---------|------|---------|
| .github/workflows/showcase.yml | P0 | +228 | Added | H-01 |
| web/src/scripts/game-bridge.ts | P0 | +84 | Added | None |
| web/scripts/build-csp.mjs | P0 | +92 | Added | None |
| web/staticwebapp.config.json | P0 | +27 | Added | None |
| web/src/scripts/reaction-client.ts | P1 | +60 | Added | None |
| web/src/scripts/pending-queue.ts | P1 | +190 | Added | L-02 |
| web/src/scripts/reaction-schema.ts | P1 | +117 | Added | None |
| scripts/presentation/web_attempt_emitter.gd | P1 | +37 | Added | L-01 |
| scripts/puzzle/puzzle_content_version.gd | P1 | +37 | Added | None |
| scenes/puzzle/arrow_puzzle.gd | P1 | +9 | Modified | None |
| scenes/puzzle/puzzle_results.gd | P1 | +4 | Modified | None |
| scenes/menus/main_menu/puzzle_select_menu.gd | P1 | +21 −1 | Modified | None |
| web/src/components/play/GameFrame.astro | P1 | +99 | Added | None |
| tests/*.gd, web/tests/*.ts | P2 | +~600 | Added/Modified | None |
| .knowledge/** | P3 | +~500 | Added/Modified | None |
| web/src/content/**, web/theme/** | P3 | +~3,000 | Added | None (not deep-reviewed) |

## Behavioral Changes

| Change | Before | After | Intentional? | Risk |
|--------|--------|-------|-------------|------|
| Play/New Game tooltip | "Starts the first catalog puzzle" | "Starts the Reference Knot" | Yes (text now matches existing behavior) | None |
| Results panel layout | relied on parent layout pass | explicitly `PRESET_FULL_RECT` before show | Yes (Web build fix) | None; tested |
| Level Select | headers + entries | headers + one description line per group | Yes | Focus order unchanged |

## Deployment & Handoff Notes

### Deployment Notes

- Repository variable `PUBLIC_REACTIONS_URL` is not set (`gh variable list` empty). Until it is, `connect-src` is `'self'` only and every reaction waits in visitors' local queues. Owner: repository admin, before production publish.
- Browser smoke test on Chromium, Firefox and Safari against the SWA preview with production headers, plus the load-time measurement, are still outstanding (Principle V). Run once H-01 lets the preview deploy.
- Confirm CI `regressions` and `Showcase / build` complete green on `778ce6c` or its successor.

### Handoff Notes

- Reactions endpoint — owned by the separate MakeBoldSpark API project — client tolerates it deploying later.
- Custom domain `arrow.makeboldspark.com` and DNS — owned by the site owner in Azure.

## Approval Decision

**Recommendation**: ✅ APPROVE

**Revision 2 (e4733b3)**: H-01 resolved. Deployment now runs only through the Azure-named workflow `azure-static-web-apps-green-bay-09bdc1010.yml`, which builds the site (regressions, fresh-copy editor validation tolerant only of five exact headless-Linux template parse reports reproduced identically on `main`, Web export, audited site build) and uploads prebuilt `web/dist` with the existing `AZURE_STATIC_WEB_APPS_API_TOKEN_GREEN_BAY_09BDC1010` secret. The dependency audit allows exactly GHSA-ch52-4w7c-c8xp (no patched release; build-time only). First preview deploy succeeded at https://green-bay-09bdc1010-5.centralus.5.azurestaticapps.net with production CSP headers; synthetic check passed. The owner reviewed the preview and approved the merge on 2026-10-03; per-browser versions for the Principle V smoke test were not supplied in this review and should be recorded in the browser-smoke evidence. L-01 and L-02 remain optional.

**Revision 1 reasoning**: The durable code, tests and knowledge are consistent and the trust boundaries are well designed. H-01 must be fixed first: the deploy workflow names a secret that does not exist, and the Azure-generated workflow fails on every run, so no preview can be produced — which in turn blocks the Principle V browser smoke test this Web build still owes. L-01 and L-02 are optional.

**Estimated Rework Time**: < 1 hour (H-01), plus the browser smoke session.

---

*Review generated by devspark.pr-review v1.2*
*Constitution-driven code review for ArrowSpark*
*To re-review after fixes: `/devspark.pr-review #5 re-review`*
*When addressing these findings, run `/devspark.address-pr-review 5`. The review file must be committed on its own — this rule is enforced by the prompt and can also be enforced by the optional pre-commit hook.*

---

## Current Review State

Replace this report on re-review. Keep stable finding IDs and current resolution outcomes; do not
append prior report bodies. Git and the hosting platform retain prior review history.

```yaml
findings:
  - finding_id: H-01
    severity: high
    description: showcase.yml references secrets.AZURE_STATIC_WEB_APPS_API_TOKEN, which does not exist; the Azure-generated workflow merged from main deploys the repo root unbuilt and fails on every run.
    recommended_action: Delete azure-static-web-apps-green-bay-09bdc1010.yml; use AZURE_STATIC_WEB_APPS_API_TOKEN_GREEN_BAY_09BDC1010 in showcase.yml (lines 158, 201) or add the expected secret; update web-showcase.md if the name changes.
    execution_mode: selective
    status: open
    outcome: ""
  - finding_id: L-01
    severity: low
    description: WebAttemptEmitter does not clamp elapsedSeconds to 86,400, so the page silently drops attempts longer than a day.
    recommended_action: clampi(roundi(elapsed_msec / 1000.0), 0, 86_400) plus a test assertion.
    execution_mode: auto
    status: open
    outcome: ""
  - finding_id: L-02
    severity: low
    description: Claim-based flush without Web Locks can lose claimed entries if the tab closes mid-flush.
    recommended_action: Document the trade-off; no code change required.
    execution_mode: manual
    status: open
    outcome: ""
```
