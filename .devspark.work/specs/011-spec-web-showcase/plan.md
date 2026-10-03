---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Implementation Plan: ArrowSpark Web Showcase — Try the Game / Built with DevSpark

**Branch**: `011-spec-web-showcase` | **Date**: 2026-10-02 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/.devspark.work/specs/011-spec-web-showcase/spec.md`

This plan is temporary working state. It remains in `.devspark.work/` until `/devspark.release` archives it, and no durable code, test, knowledge or published content may reference it.

## Rationale Summary

### Core Problem

Only the designer has played ArrowSpark, and the DevSpark story exists only as stale internal drafts. The spec fixes *what* to put in front of people and *with which stack*. This plan fixes *how*, in dependency order across two repositories, without re-opening those decisions.

### Decision Summary

- Pin **Godot 4.4-stable** everywhere, gated by a first-task export spike.
- Embed the Web export in a **same-origin iframe** that `postMessage`s one JSON `attemptCompleted` event to a validating TypeScript bridge.
- The reaction endpoint and its storage (one JSON file per reaction, never in a repo, purged after closeout) are a **separate API project spec**. Spec 011 builds only the client, which must work with the API unavailable and keep unsent reactions in a small local pending queue (FR-032).
- Port the Make Bold theme into a **static Astro + TypeScript** site under `web/`.
- Publish the story as **content collections**, with one source per fact.

### Key Drivers

- Get outside players, under the inherited first-contact protocol, within a fixed 14-day window.
- One pinned engine version for the export, the gates and the build (FR-023).
- Privacy at the application and data-model level (FR-018), with a bounded endpoint (FR-026).
- Two repositories that cannot ship atomically, so contract first and independent tests.

### Source Inputs

- [spec.md](spec.md), [showcase-research.md](showcase-research.md) (§1-16), [research.md](research.md) (Phase 0, R1-R7).
- [contracts/](contracts/): reactions API, attempt event, content collections. [data-model.md](data-model.md), [quickstart.md](quickstart.md).
- Owner answers (2026-10-02): a Mac with Safari is available; the API base is `https://makeboldspark.com`.
- The MakeBoldSpark.com repository conventions (feature folders, per-feature CORS, the in-memory limiter, the Bold workflow).

### Tradeoffs Considered

- **Server storage:** out of Spec 011 scope. The owner's choice of one JSON file per reaction is recorded in FR-031 for the API spec. A shared JSONL file was rejected (overlapped recycling), and so was a database.
- **Direct canvas embed:** rejected. The engine's globals and keyboard capture would leak into the site, and fullscreen and focus are harder to scope.
- **Building the API change from this repository:** rejected. That repo has its own workflow and review, and one PR can't span both repos.
- **Selected:** the iframe + `postMessage` bridge, a contract-first boundary with the separate API spec, a client that works with the API absent (pending queue), and site publication that does not wait for the API.

### Architectural Impact

- **New in this repo:**
  - `web/` (Astro + TypeScript, static);
  - `export_presets.cfg` (Web, no threads);
  - two small GDScript files: the content-version helper and the web-only emitter;
  - one CI workflow for the export, build and deploy.
- **Changed in this repo:**
  - `arrow_puzzle.gd`, which records attempt timing and calls the emitter;
  - the Level Select group description lines and the Play tooltip text;
  - tests that pin the content version and the payload builder;
  - knowledge and test docs (truthful baseline).
- **Unchanged:** the puzzle rules, solver, analyzer, scoring, scoreboard, catalog content and groups' gameplay meaning, and the session boundary.
- **New in MakeBoldSpark.com:** delivered by the separate API project spec, not this plan.
- **Desktop builds:** behaviour is identical. The emitter is a no-op off the web.

### Reviewer Guidance

- Check that `PuzzleState`, the solver and the scoring are untouched.
- Check that the emitter is web-gated and fire-and-forget.
- Check that the bridge validates origin, source and exact shape.
- Check that no identifier appears anywhere in the event, the request or the record.
- Check that published content cannot reach `.devspark.work`.
- Check that the theme tokens are copied unchanged and extensions are documented.
- Check that the two repositories are tested independently against one contract.

## Summary

The deliverable is a public, static showcase at `https://arrow.makeboldspark.com`, built from the Make Bold theme, with two equal entry points (Try the Game, Built with DevSpark) rejoining at a Journey. The Play page hosts the unchanged Reference Knot as a Godot 4.4 Web export in a same-origin iframe. Completion posts a one-way, identifier-free result to the page, and visitors can optionally send a short anonymous reaction to one endpoint on the existing MakeBoldSpark API, which is built by a separate API project. Until that endpoint is live, unsent reactions wait in a small pending queue in the visitor's own browser. The story is published as durable Markdown and YAML content collections refreshed from the working corpus. Observed fresh-player sessions and unobserved reactions are gathered for 14 days from publication, then reported as they stand.

## Technical Context

**Language/Version**:
- GDScript on **Godot 4.4-stable** (pinned; the web export, both gates and the build docs all use it);
- TypeScript (strict) for the site;
- C# / .NET 10 in the API repository (its own stack, unchanged);
- Python 3.11+ for the existing launchers.

**Primary Dependencies**:
- Astro (current stable major, pinned by lockfile, static output);
- `lucide-static` (pinned; inline SVG icons);
- Vitest;
- the Make Bold theme tokens and fonts (vendored into `web/`);
- Godot 4.4-stable export templates (Web, no threads);
- Maaack's Game Template (unchanged).

**Storage**:
- None in the site or game beyond the existing local settings.
- The visitor's browser holds at most 5 unsent reaction bodies (the pending queue, FR-032).
- Server-side reaction storage is the separate API spec's: one JSON file per reaction, purged after closeout (FR-031).

**Testing**:
- **Existing:** `tests/run_puzzle_regressions.py`, `tests/run_regressions.py` and `--headless --editor --quit`, all on 4.4-stable.
- **New, game side:** a content-version pin and payload-builder checks inside the existing check scripts.
- **New, site side:** `astro check`, `vitest` and `web/scripts/check-content.mjs`.
- **API repo:** `dotnet test`.
- **Browsers:** a Chromium-based browser on Windows, Firefox desktop on Windows, and Safari on macOS (available).

**Target Platform**: desktop browsers (Chromium, Firefox, Safari on macOS). Story pages also target tablet and phone. Hosting is Azure Static Web Apps.

**Project Type**: an existing desktop game plus a new static web front end. A cross-repo API addition lives elsewhere.

**Performance Goals**: from the landing page to an interactive Reference Knot in under 30 s under the SC-001 profile (≥ 25 Mbps downstream, ≤ 50 ms RTT, cold browser cache). Load time and transferred size are measured once and recorded, with no speculative optimization.

**Constraints**:
- no SSR;
- no React or another application framework;
- no second CSS framework;
- no `.devspark.work` dependency in published output;
- no identifiers;
- desktop-first;
- the convergence rule.

**Scale/Scope**:
- 7 site pages, plus 9 chapter pages;
- 1 game embed;
- 2 reaction forms;
- 1 endpoint;
- a 14-day experiment with low volume (tens of reactions expected).

## Constitution Check

*Pre-design gate (constitution 2.0.1), re-checked after Phase 1 design. Result: **PASS**, with one prerequisite amendment that is required before site implementation (P1). No waiver is needed.*

| Principle | Assessment | Status |
|---|---|---|
| I. Simple, maintainable code | Two small GDScript files (snake_case), with no new abstractions in the rule core. The site uses the smallest stack that meets the spec: islands, no framework | Pass |
| II. Prefer project-level template customization | No addon edits planned. The emitter lives in project code; the template's existing web branches are reused | Pass |
| III. Accessible, configurable controls | Game keyboard, gamepad and remapping are unchanged. Site: keyboard-reachable navigation and forms, ember `:focus-visible` ring, reduced-motion respect (FR-027). The iframe focus model is documented on the Play page | Pass |
| IV. Responsive gameplay | The emitter runs once, at results time, fire-and-forget. The reaction UI is outside the game frame and never blocks it | Pass |
| V. Practical gameplay verification | Both gates and editor validation on the pinned version; the browser smoke test (FR-025) extends the "smoke test of affected gameplay" to the new platform; not-performed checks are recorded as such | Pass. **P1** records browser verification in the constitution text |
| VI. Preserve saved progress and settings | Desktop `user://` data is untouched. Web builds get their own browser-local storage, which is a new location, not a migration. No gameplay memory is added | Pass |
| Technology section | Lists Godot, GDScript and Python only. Astro, TypeScript and Node are new | **Prerequisite P1:** MINOR amendment adding the static showcase site technology and browser verification, done through the constitution workflow before Phase 2 |

**Post-design re-check (after contracts and data model):** unchanged. No contract introduces identity, persistence of gameplay memory or rule duplication. Server-side reaction storage belongs to the separate API spec and is governed by that repository, not this constitution. The browser pending queue holds only unsent contract bodies (no identity, no gameplay memory), so Principle VI and DP-005/DP-006 are unaffected.

## Context Resolution

The `.knowledge/` set is flat; the nodes have no `relations[]`, `constrains` or `links.references`. Context Projection (2 hops, 7 seeds) returned only the hop-0 seeds, and the `branding` seed resolves as `product-branding`.

```yaml
context_resolved:
  - id: arrow-puzzle
    via: direct (lexical seed: PuzzleDefinition, catalog, arrow_puzzle.gd, order-independence wording, tab order)
    hop: 0
  - id: save-progression
    via: direct (lexical seed: New Game / Play target, tooltip, Level Select entry count)
    hop: 0
  - id: gameplay-contract
    via: direct (lexical seed: mistakes, Open Move cost, session boundary wording on Play page)
    hop: 0
  - id: game-visual-system
    via: direct (lexical seed: palette parity with the theme, fonts, blocked red is in-game only)
    hop: 0
  - id: reference-puzzle-design-report
    via: direct (lexical seed: Reference Knot facts, evidence limits, spoiler-gated content)
    hop: 0
  - id: product-branding
    via: direct (lexical seed: makeboldspark.com destination, ArrowSpark / Make Bold Spark hierarchy)
    hop: 0
  - id: arrowgame-constitution
    via: direct (lexical seed: Technology section amendment P1, Principle V)
    hop: 0
```

`gordian-knot-experiments` is cited by content only, as a permanent link. Its text does not change.

## Project Structure

### Documentation (this feature)

```text
.devspark.work/specs/011-spec-web-showcase/
├── spec.md  showcase-research.md  research.md  plan.md  data-model.md  quickstart.md
├── contracts/  reactions-api.md  attempt-completed-event.md  site-content.md
├── checklists/requirements.md
├── evidence/                 # created during Phases 6-8: smoke results, sessions/, window.md
├── gates/                    # analyze, critic, verify
├── ArrowSpark mockup with DevSpark theme.zip   # source evidence only
└── tasks.md                  # /devspark.tasks
```

### Source Code (this repository)

```text
export_presets.cfg                         # NEW: "Web" preset, threads off, gl_compatibility
scripts/puzzle/puzzle_content_version.gd   # NEW: pure geometry hash (no rule changes)
scripts/presentation/web_attempt_emitter.gd  # NEW: payload builder + web-only postMessage
scenes/puzzle/arrow_puzzle.gd              # CHANGED: attempt start/complete ticks; emitter call in _show_results()
scenes/menus/main_menu/main_menu_with_animations.tscn  # CHANGED: Play tooltip text (truth)
scenes/menus/main_menu/puzzle_select_menu.gd           # CHANGED: one description line per group (FR-006)
tests/puzzle_catalog_check.gd              # CHANGED: Reference Knot content-version pin
tests/puzzle_presentation_check.gd         # CHANGED: payload builder shape/no-identifier checks
tests/README.md, .knowledge/architecture/{arrow-puzzle,save-progression}.md  # CHANGED: truthful baseline
.knowledge/governance/constitution.md      # CHANGED: P1 amendment (constitution workflow)
.github/workflows/showcase.yml             # NEW: gates on 4.4 -> web export -> astro check/build -> SWA deploy

web/
├── package.json  package-lock.json  astro.config.mjs  tsconfig.json
├── staticwebapp.config.json               # MIME (.wasm/.pck), immutable cache for /game/<sha>/, no-cache HTML, Godot-compatible CSP, no cookies
├── THEME.md                               # provenance of the vendored theme + extension rules
├── public/
│   ├── fonts/        # WOFF2 (converted) + licenses/OFL-BeVietnamPro.txt, OFL-InterTight.txt
│   ├── brand/logo-mark.svg
│   └── game/<commit-short-sha>/  # Godot export output under a build-unique path (git-ignored, CI-generated)
├── theme/make-bold/  # DURABLE THEME COPY: tokens/*.css, styles.css, readme.md, fonts/*.ttf, logo-mark.svg (unchanged)
├── src/
│   ├── styles/global.css        # imports theme/make-bold/styles.css (+ WOFF2 @font-face override)
│   ├── styles/arrowspark.css    # documented extensions only (game frame, beats rail, journey)
│   ├── components/
│   │   ├── ui/        Button, Card, Badge, Eyebrow, Input, Icon        # theme prop contracts
│   │   ├── site/      SiteHeader, SiteFooter, EntryCard, PromiseStrip, SpoilerGate
│   │   ├── story/     BeatList, JourneyList, LessonsPair, FactTiles, EvidenceCallout, ChapterList
│   │   └── play/      GameFrame, DesktopOnlyNotice, ReactionForm, StoryReactionForm
│   ├── layouts/       BaseLayout.astro, ArticleLayout.astro
│   ├── content/
│   │   ├── chapters/  01-…09-*.md(x)
│   │   ├── beats.yaml  journey.yaml  evidence.yaml  lessons.yaml  facts.yaml
│   ├── content.config.ts        # Zod schemas per contracts/site-content.md
│   ├── pages/  index.astro  play.astro  devspark.astro  journey.astro  evidence.astro
│   │           story/index.astro  story/[slug].astro
│   └── scripts/  game-bridge.ts  reaction-client.ts  reaction-schema.ts  pending-queue.ts  page-zoom-guard.ts
├── scripts/  check-content.mjs  mock-reactions.mjs  convert-fonts.md (documented one-time command)
└── tests/    game-bridge.test.ts  reaction-client.test.ts  reaction-schema.test.ts  pending-queue.test.ts
```

### Source Code (MakeBoldSpark.com repository)

Not part of this plan. The separate API project spec owns the endpoint, validation, CORS, rate limiting, per-reaction JSON files, purge and disable switch, implemented against [contracts/reactions-api.md](contracts/reactions-api.md).

**Structure decision:** the site lives in `web/` in this repository, so one change can carry the game export and the site that hosts it (spec assumption). The durable theme copy (`web/theme/make-bold/`) is the implementation authority, and the ZIP stays as source evidence in this bundle. The API change lives entirely in its own repository.

## Delivery Phases

Each phase lists its repository and exit evidence. **[A]** = ArrowSpark repo; **[M]** = MakeBoldSpark.com repo; **[O]** = owner action outside both repos.

### Phase 0: Technical dependency confirmation *(done in this plan, except the S-1 gate)*

| # | Item | Result |
|---|---|---|
| 0.1 | Godot version | **4.4-stable** (research R1). Empirical **S-1** export spike is the first implementation task |
| 0.2 | Bridge | Same-origin iframe; JSON-string `postMessage` to the frame's own origin; bridge validates origin, source and shape (R2) |
| 0.3 | API deployment and storage | **Out of Spec 011 scope** (owner clarification). The separate API spec owns them; FR-031 records the choice of one JSON file per reaction, never in a repo, purged after closeout |
| 0.4 | Cross-repo | Contract first. Spec 011 is complete and verifiable with no endpoint; unsent reactions wait in the local pending queue (R4, FR-032) |
| 0.5 | Safari | Mac available, so Safari on macOS is in the smoke test (R5) |

**S-1 [A]:** install the 4.4-stable editor and templates (SHA-512 verified), create the Web preset, export, serve locally, play the Reference Knot to results, and note `SceneLoader` behaviour and load size.
- **Exit:** confirmed, or a version-change prerequisite is raised.
- **Branch gate:** S-1 blocks only the game/Web-integration work: the engine doc pin, the CI export step, gates and re-export on the confirmed engine, the real game in the Play frame, browser performance, the browser smoke test and publication.
- Site, theme, content, the reaction client and queue, session preparation, the truthful baseline, and the GDScript helpers with their headless tests all proceed in parallel. If the version changes, only the GDScript work is re-validated.

### Phase 1: Prerequisites (bounded to the four approved)

| ID | Prerequisite | Repo | Owner | Exit evidence |
|---|---|---|---|---|
| P1 | Constitution MINOR amendment: Technology adds the static showcase site (Astro, TypeScript, Node build); Principle V names browser verification for web builds | [A] `.knowledge/governance/constitution.md` | owner approves; AI drafts via the constitution workflow | version bumped to 2.1.0 with a Sync Impact Report; CLAUDE.md/AGENTS.md Active Technologies updated by the agent-context script |
| P2 | Pin Godot 4.4-stable for the export, gates and docs | [A] CI workflow, quickstart, `tests/README.md` | AI | S-1 passed; the existing CI already uses 4.4-stable; the new workflow uses the same version string |
| P3 | Truthful baseline: Play tooltip; `save-progression.md` (Play target, entry count, tooltip text); `tests/README.md` (Play target, sampled order-independence); `arrow-puzzle.md` (order-independence sampling wording, Back in tab order); article factual refresh (handled in Phase 3) | [A] | AI; owner reviews | both gates green; a grep finds no "first catalog puzzle", "position 0" Play claim, "twenty-one entries" or unsampled "every branching state" claim for `reference_knot` |
| P4 | Durable theme copy: copy the token CSS, `styles.css`, `readme.md`, the TTF fonts and `logo-mark.svg` from the ZIP into `web/theme/make-bold/` unchanged; add `THEME.md` (provenance, version date, extension rules, OFL notices) | [A] | AI | files byte-identical to the ZIP contents (hash list in `THEME.md`); no site file references the ZIP or `.devspark.work` |

Out of scope for Phase 1: the unused `main_menu.tscn`, internal doc tidy-ups, PR-review files.

### Phase 2: Astro foundation and theme port [A]

Order: preserve the tokens and assets, then port the component behaviour, replace inline literals with tokens, pin the icons, self-host the fonts, and replace the Unicode glyphs.

1. Scaffold `web/`: static output, strict TypeScript, Vitest, and `npm run check` (`astro check && vitest run && node scripts/check-content.mjs`).
2. `global.css` imports the theme unchanged. A WOFF2 `@font-face` override points at `public/fonts/`, with the conversion command documented and the TTF kept in the theme copy.
3. Port the primitives as `.astro` components with the theme's prop sets: Button (primary/accent/secondary/ghost/dark × sm/md/lg), Card (padding none–xl, interactive, accent), Badge (7 tones), Eyebrow (accent/brand/muted/onDark), Input (input/textarea; label/hint/error). Use scoped CSS on the tokens only.
4. `Icon.astro` wraps the pinned `lucide-static` SVGs (2px stroke, `currentColor`). Replace ✓ ✕ ⛶ → ≡.
5. Site shell: SiteHeader (mark + "ArrowSpark" + spaced "MAKE BOLD SPARK", nav: Play, Built with DevSpark, Journey, Evidence, Read the Story), SiteFooter (the session-memory note, licences link), BaseLayout (focus-visible, a reduced-motion media query), and the Landing page with twin EntryCards (rust/ink, equal weight) and the PromiseStrip.
6. `arrowspark.css` holds only the documented extensions. A token-literal check in `check-content.mjs` flags raw hex or px outside `theme/` and `arrowspark.css` (SC-013).

**Exit:** `npm run check` passes; the landing page renders with the theme; no React; no CSS framework.

### Phase 3: Durable content publication [A]

Pipeline: working corpus → editorial refresh → durable content → validation. It is **manual editorial work with automated checks**, not a converter.

1. **Facts first:** `facts.yaml`.
   - Reference Knot board facts: 46×32, 115 arrows, 1,348 cells, density 0.92, 207 bends, longest arrow 43, 6 opening moves, 661 edges, and its content version.
   - The clock, cut off at `6e60e11` (the Spec 010 merge): 121h10m, 91 commits, 4 merged PRs, 17 sessions / about 22.9h, plus a test-commit count and code/test line counts.
   - Each item has its reproducing `command` and a commit-pinned `source`. The mockup's "4,000+ assertions" gets a documented command or is dropped.
2. **Structured data:**
   - `beats.yaml`: 12 beats from showcase-research §4, refreshed;
   - `journey.yaml`: 10 milestones (per the mockup, made accurate, spoiler-light);
   - `lessons.yaml`: worked / didn't, each with a source;
   - `evidence.yaml`: the automated items, the human baseline (one tester who designed the level), what is not claimed, and limitations with their classes.
3. **Chapters** (`chapters/`), each refreshed per showcase-research §3 and §5:
   - **01-06:** light pass. Fix the 82h / 70-commit / 21-puzzle / "three and a half days" / "41 test commits" figures; keep accurate prose; replace `.devspark.work` evidence paths with commit-pinned links; remove the TODO comments. Any author-only fact that hasn't been supplied is omitted, not invented. Chapter 05 is marked `spoiler: true` if it keeps entanglement vocabulary.
   - **07 Pulling the Thread:** Spec 009 and the audit only. "Where it stands: Spec 010", "The whole clock", "What DevSpark learned", "What's still open" and "Back to the gap" move out. `spoiler: true` for the knot vocabulary.
   - **08 The Reference Knot:** from the 2026-10-01 draft, `spoiler: true`, links refreshed.
   - **09 Now It's Your Turn** (new): the whole clock (from `facts.yaml`), what DevSpark learned (07 plus `12-devspark-lessons.md`), the **convergence story** (the F3 readout added and removed in `b3aa17e`/`6851baf`, the three PR #4 review revisions, and the closeout rule), what's still open, and the ask to play, then react. The author confirms the convergence framing before `status: published`.
4. **Pages:** `devspark.astro` (beats, the Code/Tests/Knowledge diagram, lessons pair, Reference Knot facts behind the SpoilerGate, convergence callout, "Now form your own opinion" CTA), `journey.astro`, `evidence.astro`, `story/index.astro` (the real 9-part list from the collection), `story/[slug].astro` (ArticleLayout with the play-first note when `spoiler`).
5. **Validation** (`check-content.mjs`): R-1 to R-5 in contracts/site-content.md, covering no `.devspark.work`, commit-pinned links, no author placeholders, the pre-play word scan (including the game menu `.tscn` text) and sourced numbers. Every link is fetched once at publication (SC-004).

**Exit:** all content checks pass; the owner has reviewed chapters 01-09; any author-only gaps are listed in `evidence/author-gaps.md`, not filled.

### Phase 4: Godot Web export and embedding [A]

1. `export_presets.cfg` "Web": threads off, release, canvas resize policy adaptive, a custom HTML shell (`web/game-shell/shell.html`) carrying the in-game zoom/pinch guard and an `engineState` marker, and an export path under the build-unique `web/public/game/<commit-short-sha>/` (git-ignored).
2. `PuzzleContentVersion.of()` plus its pin test, and `WebAttemptEmitter.build_payload(puzzle_id, definition, results, elapsed_ms) -> Dictionary` (pure) with `emit(payload)` (web-gated `postMessage`). Payload tests check the exact key set, integer fields and that no identifier keys exist.
3. `arrow_puzzle.gd`: record the start tick in `_start_new_attempt()`, record the completion tick in the REMOVED branch where `_state.completed`, and call `WebAttemptEmitter` in `_show_results()` after `record_attempt`. Nothing else changes.
4. `puzzle_select_menu.gd`: one honest description line per group (FR-006), with no ranking words, and passing the R-4 scan.
5. Play page:
   - **GameFrame** contains the dark frame, title bar, a Fullscreen button (on the iframe), a loading state with a progress note, and a same-origin `<iframe src="/game/<commit-short-sha>/index.html">` (path set at build) with `allow="fullscreen; autoplay"`.
   - **Focus:** clicking the frame focuses the iframe, and an instruction line says so.
   - **Zoom guard:** in-game ctrl+wheel/pinch and Ctrl/Cmd +/- are suppressed by the custom Godot shell, because iframe events never reach the host. `page-zoom-guard.ts` covers only the surrounding page chrome. Per-browser results are recorded, and suppression a browser disallows is an accepted limitation.
   - **Audio:** audio is not unlocked before a user gesture (browser default), and the first click starts it.
   - **DesktopOnlyNotice:** shown for `(pointer: coarse)` or a viewport under 960×540. It offers the story and copy-link or `mailto:`; there is no email capture.
   - The **session-memory** note.
6. `game-bridge.ts` validates origin, source and shape per the contract and holds the latest attempt in memory; unit-tested with valid, invalid, foreign-origin and oversized messages.

**Exit:** both gates green on 4.4-stable (with the new pin and payload checks); `npm run check` green; a local export plays the Reference Knot in the iframe, and one validated event reaches the bridge.

### Phase 5: Reactions (client only) [A]

The endpoint is not built here. Everything below is verified against the development mock, with the real endpoint absent.
- `reaction-schema.ts` mirrors contracts/reactions-api.md exactly (enums, limits, no extra properties, a 4,096-byte cap).
- `reaction-client.ts`: POST to `${PUBLIC_REACTIONS_URL}/api/public/arrowspark/reactions` with an 8 s timeout. Responses map to `sent`, `invalid` or `pending` (FR-032). An unset URL behaves like an unreachable endpoint.
- `pending-queue.ts`: one browser-storage key; at most 5 entries of `{ body, savedOn }` (`savedOn` a UTC date used only for expiry); entries older than 7 days pruned unsent on load; when full after pruning, the newest attempt is refused with a notice; `flush()` once on each page load and before each new submission; remove on 202 or 400/413/415; keep on 404/405/429/5xx/network/timeout/CORS/CSP and stop flushing; flushes serialized across tabs with the Web Locks API; a Discard control; clear without sending when the build is configured as feedback-closed; and the unavailable-message fallback when storage is blocked. No timers, service worker or background sync.
- **ReactionForm** (game): at most 5 questions, matching the mockup; the attempt is attached only if the bridge holds one.
- **StoryReactionForm** (end of the method path): at most 4 questions.
- `mock-reactions.mjs` (dev only): accept, invalid and unavailable modes, switchable while running, so "unavailable, then available" can be exercised. Tests cover the payload built from form + attempt, the no-identifier rule, every response class, and the queue lifecycle (save, cap of 5, flush on load, removal on 202 and 4xx, keep on 5xx, Discard, blocked storage, feedback-closed clearing). These are the SC-006 and SC-014 checks.

**Not in this plan:** the endpoint and everything server-side are owned by the separate MakeBoldSpark API project, per the external requirements in FR-026 (part B) and FR-031, against [contracts/reactions-api.md](contracts/reactions-api.md). That covers server validation, CORS, rate limiting, logging, storage and purge. The current external storage contract is one JSON file per reaction, never committed to any repository, purged after the closeout.

**Exit:** the client, forms and pending queue pass their tests against the contract and the mock, with no real endpoint.

### Phase 6: Integration and browser validation [A] [O]

- **CI** (`.github/workflows/showcase.yml`): both Godot gates on 4.4-stable, then the web export with 4.4-stable templates (SHA-512 verified), then `npm ci && npm audit --audit-level=high && npm run check && npm run build`, then the SWA deploy (a preview environment on PRs, production on `main`).
- **Browser smoke (FR-025)**, recorded in `evidence/browser-smoke.md` with browser and OS versions, on a Chromium-based browser (Windows), Firefox (Windows) and Safari (macOS). It covers:
  - load time and transferred size;
  - focus on click;
  - wheel and trackpad zoom, and pinch or ctrl+wheel not zooming the page;
  - resize mid-attempt;
  - audio start;
  - Play → Reference Knot;
  - a blocked move, Open Move, Fit, Pan and Zoom;
  - completion and results, Replay, Back, and Level Select with the group lines;
  - one `attemptCompleted` reaching the bridge;
  - reaction submit against the mock;
  - the API unavailable, the game unaffected, the reaction saved as pending;
  - the mock switched to available, reload, the pending reaction sent and cleared;
  - the story pages at phone width;
  - the desktop-only notice on a touch emulation and on a real phone.

  Any check not performed is marked as not performed.
- **Privacy check (SC-006):** inspect the outgoing requests (devtools) and the pending-queue storage value, and confirm only contract fields are present. Server-side record inspection belongs to the API spec.

**Exit:** CI green; the smoke results are recorded; no failed check that affects play is open.

### Phase 7: Publish [O] [A]

- **[O] Owner:** create the Azure Static Web App, the deploy token secret, and DNS plus the custom domain for `arrow.makeboldspark.com`; confirm the API host is `https://makeboldspark.com` at deploy time.
- **[A]:** a production build with `PUBLIC_REACTIONS_URL` set to the agreed endpoint base, then deploy. If the endpoint doesn't exist yet, reactions wait in visitors' pending queues.
- Record `published_reachable_at` in `evidence/window.md` on the day `https://arrow.makeboldspark.com` first serves the showcase, and compute `closes_at` as that date + 14 days.

### Phase 8: 14-day evidence window and closeout [O] [A]

- **[O] Owner:** recruit participants and run observed sessions in the FR-020 order (landing impression → fresh play → interview → Built with DevSpark → DevSpark comprehension). One participant may cover SC-002, SC-007, SC-008 and SC-011. There are no recruitment tasks per criterion. Each session is recorded per data-model.md in `evidence/sessions/`.
- **[A]:** at day 14, take whatever reactions the API project has received in the window (obtained through that project's process; none is an acceptable answer) and report them in three tiers (observed / unobserved first-contact / unobserved read-story-first), quoting free text as given.
- **Close feedback [A]:** after the closeout, rebuild the site in feedback-closed mode. The forms are replaced by "Feedback for this showcase has closed", and each visitor's pending queue is cleared on their next load without sending. Server-side purge and endpoint disable belong to the API spec.
- Delete the raw observed-session notes (private, outside any repo); the anonymized summaries remain in the bundle.
- The spec closeout sorts every item into Passed / Accepted Limitation / Deferred Work / Learning / Failed. The window is **not extended**, and negative reactions are findings for later specs, not fixes here.

## Validation Matrix (layered, with no duplication)

| Layer | Proves | Where |
|---|---|---|
| Automated: Godot | rules unchanged; Reference Knot content version pinned; payload shape with no identifiers; group lines present | existing launchers on 4.4-stable |
| Automated: site | one synthetic headless-browser load check (engine started, no console/CSP errors) on each SWA preview and daily against production during the window; types; schemas; bridge rejects foreign or malformed messages; client handles every response class; unavailable isolation; pending-queue lifecycle (SC-014); no `.devspark.work`; commit-pinned links; no placeholders; pre-play word scan; no raw hex or px outside the theme | `npm run check` in CI |
| Automated: API | *not Spec 011*: covered by the separate API spec | that project |
| Browser | real input, focus, zoom, audio, iframe messaging, reaction client and pending queue against the mock | three browsers, recorded |
| Human | equal billing, fresh play, interview, DevSpark comprehension, theme recognition (SC-013) | observed sessions |

Humans are never asked to verify what the automated layers already prove.

## Prerequisites and Owners (summary)

| ID | Prerequisite | Owner | Blocks |
|---|---|---|---|
| S-1 | 4.4 web export spike | AI runs; owner reviews | game/Web-integration branch only (tasks marked [S-1]) |
| P1 | Constitution MINOR amendment | owner approves | Phase 2 onward |
| P2 | Godot 4.4-stable pin everywhere | AI | Phase 4 and 6 |
| P3 | Truthful baseline | AI; owner reviews | Phase 7 (publication) |
| P4 | Durable theme copy | AI | Phase 2 |
| O-1 | SWA resource, secret and DNS | owner | Phase 7 |
| O-2 | Separate API spec delivered and deployed | owner, in the API project | real reactions only; never blocks Spec 011 |

## Deferred

- Intentional touch or mobile play.
- A local pending-reaction queue.
- Any reaction read, export or dashboard endpoint.
- Analytics.
- An engine upgrade.
- Porting the theme's unused UI-kit pieces (Services, ContactCTA, Hero variants) and its deck template.
- Removing the unused `main_menu.tscn`.
- Spec 010's own unperformed desktop smoke items.
- Framework lessons (CON-01, the severity/impact-domain split), referred to DevSpark.
- A second content round, difficulty characterization and the generator.

## Risks

| Risk | Mitigation |
|---|---|
| 4.4 web export fails (for example threaded loading) | The S-1 gate stops work. Any version change becomes an explicit prerequisite |
| Export templates are large in CI | Download only the official `.tpz` with SHA-512 verification and cache it by version |
| The API feature slips past publication | Publication doesn't wait. The "unavailable" state is honest, and lost unobserved reactions are recorded as an accepted limitation |
| Safari-specific iframe, audio or fullscreen behaviour | Safari on macOS is in the smoke test; Safari issues are recorded, and only play-affecting failures block |
| Pinch zoom still reaches the page in some browser | The zoom guard is covered by the smoke test; a residual failure is an accepted limitation if the game stays playable |
| Author-only facts missing at publication | Omit them and list them in `evidence/author-gaps.md`; never invent them |
| Recruitment shortfall | Accepted limitation at day 14; no extension |

## Plan Output Report

1. **Godot version:** 4.4-stable, pinned for the export, gates and docs. The empirical S-1 spike is the first task.
2. **Bridge:** same-origin iframe; a web-gated `JavaScriptBridge.get_interface("window").parent.postMessage(JSON.stringify(payload), window.location.origin)`; the TypeScript bridge validates origin, source and exact shape; fire-and-forget; no page-to-game path; desktop is a no-op.
3. **API single instance / storage:** out of Spec 011 scope. The separate API spec stores one JSON file per reaction, never in a repo, purged after closeout (FR-031).
4. **Cross-repo order:** contract (done). Spec 011 builds the client and pending queue against the mock and ships without the endpoint. The API spec builds and deploys the endpoint on its own schedule, and pending reactions flow once it is live.
5. **Durable theme destination:** `web/theme/make-bold/` (unchanged copy, with hashes in `web/THEME.md`). The ZIP stays as source evidence only.
6. **Astro structure:** `web/` per Project Structure (ui, site, story and play components; content collections; scripts; tests).
7. **Content pipeline:** `.devspark.work/development/*` → manual editorial refresh → `web/src/content/` (chapters 01-09, beats, journey, lessons, evidence, facts) → `check-content.mjs` (R-1 to R-5) and a link check.
8. **Browsers:** a Chromium-based browser and Firefox on Windows, and Safari on macOS (available per the owner).
9. **Prerequisites and owners:** S-1 (AI), P1 (owner approves), P2 (AI), P3 (AI, owner reviews), P4 (AI). Owner actions O-1 (SWA and DNS) and O-2 (API deploy).
10. **Deferred:** as listed above.
11. **Remaining blockers:** none. S-1 is the only gate that could raise one, and it gates only the game/Web-integration branch.

## Complexity Tracking

No constitution violations require justification. The P1 amendment is handled as a prerequisite, not a waiver.

## Implementation Notes

- **2026-10-02 (T002, S-1):** PASS on 4.4-stable; no version change. The spike found a project-side **Blocking Defect**: the results overlay was 0×0 in the Web build because a hidden full-rect Control never receives layout when the canvas never resizes. Fixed in `scenes/puzzle/puzzle_results.gd` (`PRESET_FULL_RECT` before `show()`); behaviour on desktop is unchanged. Evidence: `evidence/s1-export-spike.md`.
- **2026-10-02 (T001):** `export_presets.cfg` was listed in `.gitignore`; that line was removed so the Web preset is committed. `web/.gdignore` keeps Godot from importing the site tree. The export helper `web/scripts/export-game.mjs` runs the export into `web/public/game/<build>/` and copies `shell.css`; the build id is passed to the site as `PUBLIC_GAME_BUILD`. The shell's service-worker branch was dropped (no PWA, no cross-origin isolation needed with threads off).
- **2026-10-02 (T006/T007):** Astro 7.3.5 (current stable), TypeScript 6.0.3 (`@astrojs/check` 0.9.10 does not yet accept TypeScript 7), Vitest 5.0.3, all pinned exactly with `package-lock.json`. `global.css` imports the theme's token files and `base.css` individually rather than `styles.css`, because `styles.css` also pulls `tokens/fonts.css`, whose TTF `@font-face` rules would bundle ~2 MB of TTF into the build; the WOFF2 faces replace exactly that one file. Theme files stay byte-identical. Scripts and styles are never inlined (`inlineStylesheets: 'never'`, `assetsInlineLimit: 0`), and components use no `style` attributes, so the CSP needs no `'unsafe-inline'`.
- **2026-10-02 (T013):** the publication checker is split into source checks (every `npm run check`) and `--dist` checks (run by `npm run build` after `astro build`), because R-1 on `dist/` and R-4 on built pages need the build output. The theme-literal check scopes to `web/src` (the Godot loader shell in `web/game-shell/` cannot load site tokens and is not site source).
