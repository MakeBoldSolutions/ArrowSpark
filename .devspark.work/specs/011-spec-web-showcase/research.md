# Phase 0 Research: ArrowSpark Web Showcase

**Written:** 2026-10-02 by `/devspark.plan`. Temporary planning material; nothing durable may cite it.
**Builds on:** [showcase-research.md](showcase-research.md) §1-16 (pre-spec research, content-source map, theme analysis). This file resolves only the remaining technical dependencies. Fixed decisions from the spec (Astro + TypeScript, static-first, the Make Bold theme, Azure Static Web Apps at `arrow.makeboldspark.com`, Godot Web, the existing MakeBoldSpark API, anonymous reactions, durable MD/MDX, desktop-first) are not re-opened.

**Status:** no `NEEDS CLARIFICATION` remains. One item (R1) is desk-confirmed and has a gated empirical check as the first implementation task.

---

## R1. Godot version

**Decision:** pin **Godot 4.4-stable**, the exact build CI already downloads and SHA-512-verifies in `.github/workflows/godot-regression-tests.yml`, for the web export, both regression launchers and the documented build. The local 4.7.2 editor is not used for anything that produces evidence or a release artifact.

**Rationale (desk evidence, 2026-10-02):**
- `project.godot` declares `config/features = 4.4` and `rendering_method = gl_compatibility`. That is the renderer the Web platform requires, already set for desktop and mobile.
- No C# project, no GDExtension, and no `Thread`/`Mutex`/`WorkerThreadPool` use in `scripts/`, `scenes/` or `addons/`, so a **single-threaded ("no threads") web export** is possible. That variant needs no cross-origin isolation headers, so Azure Static Web Apps serves it without special COOP/COEP configuration.
- The Maaack template already branches on `OS.has_feature("web")` for Quit, fullscreen, video options and the loading screen.
- The one web-relevant risk is the template's `SceneLoader`, which uses `ResourceLoader.load_threaded_request`. A single-threaded web build runs threaded loading on the main thread. This should work, but it must be observed.
- Pinning 4.4-stable changes nothing for CI and nothing for the constitution's declared target.

**Empirical confirmation:** not yet performed. No 4.4 editor or export templates are installed locally.

**Gate (first implementation task, S-1):** install the 4.4-stable editor and export templates from the official release, verifying the SHA-512 sums. Export the Web/no-threads preset, serve it locally, and play the Reference Knot through to the results screen.
- **Pass:** 4.4 is confirmed.
- **Fail with a concrete engine defect:** stop. A version change becomes an explicit prerequisite under FR-023, with its own task, a regression run on the new version and a constitution Technology update. Implementation does not continue on an unconfirmed engine.

**Alternatives considered:**
- **4.4.1-stable:** a patch release, but no concrete web-export reason to move has been found, and it would change CI.
- **4.7.2:** the local editor. Moving would be an engine upgrade, which the spec rules out without a blocker.

---

## R2. Godot → page bridge

**Decision:**

- **Hosting:** the Godot Web export is served under `/game/` on the same origin as the site and embedded in the Play page in a **same-origin `<iframe>`**.
- **Sending:** on attempt completion, a small web-only GDScript emitter posts one message to the parent window:

  ```gdscript
  # web-only; no-op on every other platform
  if OS.has_feature("web"):
      var window := JavaScriptBridge.get_interface("window")
      if window != null and window.parent != null:
          window.parent.postMessage(JSON.stringify(payload), window.location.origin)
  ```

  - `payload` is a Dictionary built by a pure, headless-testable function.
  - The message is a **JSON string**, because Godot's `JavaScriptObject` does not marshal Dictionaries into JS objects.
  - `targetOrigin` is the frame's own origin, so the message can only be delivered to a same-origin parent.
  - The call is fire-and-forget: there is no return value, no await and no listener in the game.
- **Receiving:** the TypeScript bridge (`game-bridge.ts`) listens for `message` events and accepts one only when all of these hold:
  1. `event.origin === window.location.origin`;
  2. `event.source` is the game iframe's `contentWindow`;
  3. `event.data` is a string of at most 1 KB;
  4. it parses as JSON matching the `attemptCompleted` v1 schema exactly (contracts/attempt-completed-event.md).
  Anything else is ignored silently. The bridge keeps only the most recent valid event, in a module variable for the page visit; no browser storage is used.
- **Where the emitter is called:**
  - `scenes/puzzle/arrow_puzzle.gd` `_show_results()`, after `PuzzleScoreboard.record_attempt(...)`, in the presentation/controller layer.
  - `_start_new_attempt()` records `Time.get_ticks_msec()`, and the REMOVED branch that sets `_awaiting_completion` records the completion tick. `elapsedSeconds` = whole seconds between them (wall clock, pauses included, as the spec says).
  - `PuzzleState`, `PuzzleSolver`, `PuzzleAnalyzer` and the scoring rules are not touched.
- **Puzzle content version:** a new pure static helper, `scripts/puzzle/puzzle_content_version.gd`, `PuzzleContentVersion.of(definition) -> String`.
  - It serializes the geometry canonically: width, height, then every head sorted by (y, x) with its direction and ordered tail.
  - It returns `"g1-"` plus the first 12 hex characters of the SHA-256 of that text.
  - It changes if and only if geometry changes, and is independent of the app version.
  - `tests/puzzle_catalog_check.gd` pins the Reference Knot's value as a literal constant (FR-009).

**Rationale:**
- Godot's documented `JavaScriptBridge` is part of the standard 4.x web templates.
- `postMessage` with an exact target origin, plus an origin/source check on receipt, is the standard browser contract between frames.
- The iframe keeps Godot's generated loader and canvas intact, isolates engine globals from the site, gives a natural fullscreen target, and matches the "click inside the game once" focus model.
- **Desktop builds are unchanged:** the emitter returns immediately when `OS.has_feature("web")` is false.
- **No page-to-game path exists:** the game never registers a callback or reads anything from the page.

**Alternatives considered:**
- **Embed the canvas directly in the page:** the engine's globals and keyboard capture would leak into site pages, and fullscreen and focus are harder to scope.
- **`JavaScriptBridge.eval` of a dispatch string:** works, but evaluating string code is broader than needed.
- **A `CustomEvent` on the iframe document:** needs parent code to reach into the frame, which is a page-to-game coupling.
- **Polling the game for results:** that would be a page-to-game dependency.

**Test boundary:**
- The payload builder and content-version helper are covered by headless GDScript checks in the existing launchers.
- The bridge's validation is covered by TypeScript unit tests.
- The real `postMessage` hop is observed in the browser smoke test.

---

## R3. API deployment model → storage

**Finding:**
- The API README documents **Azure App Service Linux B1** and SQLite at `/home/data/makeboldspark.db`.
- The repository contains **no infrastructure-as-code or configuration that guarantees a single instance**: no instance count, no scale lock.
- App Service can also run **two worker processes briefly during restarts and deployments** (overlapped recycling). An in-process single-writer lock therefore cannot be relied on.
- The single-instance condition is **not guaranteed**.

**Decision:** use the **existing SQLite mechanism**, exactly as the spec's fallback (FR-031) requires.
- One new append-only table in the existing `MakeBoldSparkDbContext`, added by an EF Core migration through that repository's established migration and backup procedure (the WAL convention, `bold-docs/system/decisions/0002-sqlite-default.md`; the deployment steps used in `bold-docs/system/family-memories-api.md`).
- The table holds the same record shape the JSONL design specified: `RecordId` (random GUID, primary key), `SchemaVersion`, `ReceivedUtc` (truncated to the minute), `ReactionType`, and `Payload` (the validated, canonically re-serialized reaction JSON).
- Insert-only. No public read, update, delete, list or export endpoint.
- The owner reads the table directly with SQLite tooling for the closeout, using the API repo's backup procedure.

**Rationale:** SQLite handles concurrent writers itself; WAL mode is already the platform default. No new database or platform is introduced. JSONL in a shared `/home` file with overlapping processes would need cross-process locking, which the spec forbids building.

**Alternatives considered:**
- **JSONL with an in-process lock:** unsafe under overlapped recycling.
- **JSONL with file locking:** this is "distributed file locking", which is excluded.
- **A new storage account or database:** a new platform, which is excluded.

---

## R4. Cross-repo API work

**Owning repository:** `MakeBoldSolutions/MakeBoldSpark.com`. That repo uses its own **Bold** workflow (`AGENTS.md`, `bold-docs/backbone.md`, `bold-docs/features/NNNN-*`). The endpoint is planned and built there as its own feature, expected to be `0007-arrowspark-reactions`, through `/bold-plan`. It is **not** built from this repository, and no MakeBoldSpark code is committed here.

**Contract first:** [contracts/reactions-api.md](contracts/reactions-api.md) is the single contract both repositories implement against. Its version is `schemaVersion` 1.

**Base URL:** `https://makeboldspark.com`, confirmed by the owner 2026-10-02. The full endpoint is `https://makeboldspark.com/api/public/arrowspark/reactions`.
- The site reads it from a **build-time** setting (`PUBLIC_REACTIONS_URL`), following the API repo's documented consumer pattern ("build-time setting; changing it requires rebuilding").
- The API's own docs also name `api.markhazleton.com`. Which hostname serves the API at deploy time belongs to that repo's deployment, so the site depends only on the build-time setting.

**Implementation order:**
1. Contract (this plan). Both sides now build independently.
2. **ArrowSpark side**, unblocked from day one: the reaction UI and client against the contract, tested with
   - (a) a contract-fake mode in unit tests,
   - (b) a local mock server script used only in development (`web/scripts/mock-reactions.mjs`: validates per the contract and returns 202, 400 or 503 on demand), and
   - (c) the **unavailable** path, which is the default when `PUBLIC_REACTIONS_URL` is unset.
3. **MakeBoldSpark side** (feature 0007 in that repo): the endpoint, CORS policy, rate-limit policy, validation, migration and tests, built and deployed on that repo's schedule.
4. **Integration:** after 0007 is deployed, the showcase is built with `PUBLIC_REACTIONS_URL` set, and the browser smoke test submits one game and one story reaction from `https://arrow.makeboldspark.com`. The owner confirms the rows exist with the expected fields only.

**Integration test boundary:**
- ArrowSpark proves its client sends contract-valid requests and handles each response class.
- MakeBoldSpark proves its endpoint enforces the contract (its own test suite, `dotnet test`).
- Only the final smoke test crosses the boundary.
- Neither repository's CI calls the other's.

**Publication does not wait on the API:** the site may go public with the reaction feature showing "Feedback is temporarily unavailable". The learning window still opens on publication (FR-020). If 0007 lags, observed sessions still count; unobserved reactions are lost for that period, which is recorded as an accepted limitation.

---

## R5. Safari environment

**Finding:** the owner confirmed (2026-10-02) that a **macOS machine with current Safari is available**.

**Decision:** the release smoke test runs on three browsers: a Chromium-based desktop browser (on Windows), Firefox desktop (on Windows), and Safari on that Mac. Each is recorded separately, with its browser and OS version. If the Mac is not available on release day, Safari is recorded as **not performed**, never inferred.

---

## R6. Supporting decisions (no open questions)

| Topic | Decision | Rationale |
|---|---|---|
| Node / package manager | Node 22 LTS and npm with a committed lockfile; CI pins Node 22 | Matches the API repo's CI (`setup-node` 22); local Node 26 is compatible with Astro's supported range |
| Astro version | Current stable Astro major at implementation time, exact version pinned by the lockfile; static output (`output: 'static'`); no SSR adapter | FR-024, FR-028 |
| Islands | Plain TypeScript `<script>` modules in Astro components; no UI-framework integration | FR-028 (no React); the islands are small |
| Content | Astro content collections (`chapters`) with a Zod schema; YAML data collections for `beats`, `journey`, `evidence`, `facts`, `lessons` | FR-029; one source per fact |
| Icons | Lucide icons as inline SVG via the pinned `lucide-static` package, imported at build time; no CDN | Theme chose Lucide; FR-027 pins it; no runtime JS |
| Fonts | Theme TTFs converted to WOFF2 once with a documented command, self-hosted with their OFL licence texts; TTF originals kept in the durable theme copy | Web performance; licence compliance |
| Site tests | `astro check` (types), `vitest` for the bridge/client/validators, and a Node content-validation script (`web/scripts/check-content.mjs`) run in CI | Smallest set covering the spec's automated checks |
| Deployment | GitHub Actions in this repo: run both Godot gates on 4.4-stable, export the Web build with 4.4-stable templates, build Astro, and deploy to Azure Static Web Apps with its official deploy action. The SWA resource, deploy token secret and custom-domain DNS are created by the owner | FR-023 (one pinned version everywhere); static hosting |
| SWA config | `staticwebapp.config.json`: MIME types for `.wasm` and `.pck`, long cache for hashed engine files, `no-cache` for HTML, a CSP allowing `connect-src` to the reactions host only, and no cookies set | Correct engine serving; privacy |
| Trackpad / page zoom | The Play page stops ctrl+wheel (trackpad pinch) and Ctrl/Cmd +/- page zoom from zooming the page while the pointer or focus is on the game frame; game zoom is unchanged | Spec edge case; verified in the browser smoke |
| Spoiler-word scan | `check-content.mjs` scans built HTML for the landing, Play and loading surfaces, and the game's menu scene text (`scenes/menus/**/*.tscn`, `scenes/loading_screen/**`), against the FR-005 word list | SC-003 automated |
| Permanent links | Evidence URLs must match `https://github.com/MakeBoldSolutions/ArrowSpark/(blob|tree|commit)/<40-hex sha>/…` or be internal site paths; no `.devspark.work` substring anywhere in content or build output | FR-013, FR-029, SC-004 |
| "4,000+ assertions" (mockup) | Replaced by a figure produced by a documented command over launcher output, or omitted | FR-013 |

## R7. Findings classified (convergence rule)

| Finding | Class |
|---|---|
| R1: 4.4 web export not yet observed | **Prerequisite** (S-1 gate) |
| R3: single instance not guaranteed, so SQLite instead of JSONL | **Learning / Changed Assumption** (allowed by FR-031; no scope change) |
| R4: API repo has its own workflow (Bold) and host naming | **Learning**; dependency recorded, no scope change |
| R4: publication may precede API deployment | **Accepted Limitation** if it happens |
| `SceneLoader` threaded loading on single-threaded web | Risk checked in S-1; **Blocking Defect** only if observed failing |
| Constitution Technology lacks Astro/TypeScript | **Prerequisite** P1 |
| No new blockers | none |
