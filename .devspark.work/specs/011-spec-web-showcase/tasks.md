---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
description: "Task list for Spec 011: ArrowSpark Web Showcase"
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Tasks: ArrowSpark Web Showcase — Try the Game / Built with DevSpark

**Input**: Design documents from `/.devspark.work/specs/011-spec-web-showcase/` (spec.md, plan.md, research.md, data-model.md, contracts/, quickstart.md, showcase-research.md)
**Prerequisites**: plan.md and spec.md (no open clarifications); requirements checklist 28/28 PASS.

**Tests**: included. The spec requires automated checks: the pre-play word scan (SC-003), permanent links (SC-004), no identifiers in requests or queue (SC-006), the queue lifecycle (SC-014), the content-version pin (FR-009) and the theme-literal check (SC-013).

**Organization**: tasks are grouped by user story so each story can be implemented and tested independently.

This task list is temporary working state. It stays in `.devspark.work/` until `/devspark.release` archives it. No durable code, test, knowledge or published content may reference it, the spec, the plan or any task ID.

## Rationale Summary

### Core Problem

Only the designer has played ArrowSpark, and the DevSpark story exists only as internal drafts. Spec 011 puts the game and the story in front of outside people for 14 days and records what they say.

### Decision Summary

- Godot 4.4-stable Web export, embedded in a same-origin iframe with a one-way `attemptCompleted` bridge.
- A static Astro + TypeScript site on the vendored Make Bold theme, with durable content collections.
- A client-only reaction path with a local pending queue. The endpoint and its storage are a separate API project.

### Key Drivers

- Outside-player evidence under the first-contact protocol, gathered within a fixed window.
- One pinned engine version everywhere; a truthful public baseline.
- Privacy at the application and data-model level; nothing personal in the public repo.

### Reviewer Guidance

- Check that the rule core is untouched and the emitter is web-gated.
- Check that the bridge and queue carry no identifiers.
- Check that content cannot reach `.devspark.work`.
- Check that the theme is copied unchanged.
- Check that no task builds the API.

## Format: `[ID] [P?] [Story] Description (Implements: FR-###[, FR-###])`

- **[P]**: can run in parallel (different files, no dependency on an incomplete task).
- **[Story]**: US1-US5 from spec.md.
- **Linkage**: every task ends `(code_ref: pending | knowledge_ref: pending)`, and `/devspark.implement` fills it. Durable files never point back here.
- **[O]** in a description means an owner action outside the repositories. The task records the outcome; the AI does not perform it.

## Plan ↔ task phase map

| plan.md Delivery Phase | tasks.md Phase |
|---|---|
| 0 (S-1 gate) | 1 |
| 1 (prerequisites) + 2 (Astro foundation) | 2, plus 7 (truthful baseline, US5) |
| 3 (content) | 4 (US2) |
| 4 (Web export and embedding) | 3 (US1) |
| 5 (reactions, client only) | 5 (US3) |
| 6 (integration and browser validation) + 7 (publish) | 8 |
| 8 (window and closeout) | 6 (US4 prep), 9 |
| — | 10 (polish and verification) |

## Path Conventions

Game: repository root (`scripts/`, `scenes/`, `tests/`). Site: `web/`. The MakeBoldSpark.com repository is **not touched** by any task here.

---

## Phase 1: Setup (engine confirmation, gate S-1)

**Purpose**: prove Godot 4.4-stable can export and play this project on the Web. **Branch gate:** only tasks marked **[S-1]** wait for this phase.

- [ ] T001 Create `export_presets.cfg` with a "Web" preset (threads off, release, export path supplied at build as `web/public/game/<commit-short-sha>/index.html`) and a **custom HTML shell** `web/game-shell/shell.html` (based on Godot's default shell). The shell adds the in-game zoom/pinch guard listeners (ctrl+wheel; Ctrl/Cmd +/-/0) and sets `document.body.dataset.engineState` to `started` once the engine starts, for the synthetic check. For the production CSP (T068), the default shell's inline loader `<style>` moves to a sibling `shell.css` exported with the game, so the shell keeps only one inline `<script>` (the bootstrap, hashed at build). Add `web/public/game/` to `.gitignore` (Implements: FR-004, FR-023) (code_ref: pending | knowledge_ref: pending)
- [ ] T002 **S-1 export spike.** Install the Godot 4.4-stable editor and export templates from the official GitHub release, verifying the SHA-512 sums (same source as `.github/workflows/godot-regression-tests.yml`). Export with the Web preset headless, serve it locally, and play the Reference Knot from Play to the results screen. Note `SceneLoader` behavior, load time, and raw plus gzip/brotli sizes of `.wasm` and `.pck`. Record versions, hashes, sizes and pass/fail in `.devspark.work/specs/011-spec-web-showcase/evidence/s1-export-spike.md`. **On an engine defect:** raise a version-change prerequisite (FR-023). Only the tasks marked **[S-1]** wait for it (Implements: FR-004, FR-023) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: S-1 passed, so 4.4-stable is the pinned engine and the [S-1] tasks are unblocked.

---

## Phase 2: Foundational (blocking prerequisites P1, P2, P4, plus the site shell)

**Purpose**: the amended constitution, the version pin, the durable theme and the Astro shell that every story builds on.

**⚠️ CRITICAL**: no user-story work begins until this phase is complete, **except** its [S-1] items (T004's version pin, and T014's export step and synthetic-check engine wait), which follow S-1 and never block story work.

- [ ] T003 Draft the constitution MINOR amendment (2.0.1 → 2.1.0) in `.knowledge/governance/constitution.md`: Technology adds the static showcase site (Astro, TypeScript, Node build), Principle V names browser verification for web builds, with a Sync Impact Report. In the same change, update Active Technologies in `CLAUDE.md` and `AGENTS.md`. **Owner approves before T006** (Implements: FR-028, FR-025) (code_ref: pending | knowledge_ref: pending)
- [ ] T004 [P] **[S-1]** Pin the engine version confirmed by S-1 in docs: `tests/README.md` (gate commands name the version) and `.devspark.work/specs/011-spec-web-showcase/quickstart.md`; confirm `.github/workflows/godot-regression-tests.yml` uses the same version (Implements: FR-023) (code_ref: pending | knowledge_ref: pending)
- [ ] T005 [P] Copy the theme from `ArrowSpark mockup with DevSpark theme.zip` into `web/theme/make-bold/` **unchanged** (`tokens/*.css`, `styles.css`, `readme.md`, `assets/fonts/*.ttf`, `logo-mark.svg`). Write `web/THEME.md` alongside it: provenance, a SHA-256 list of every copied file, extension rules (extensions only in `src/styles/arrowspark.css`), OFL notices. Add OFL licence texts under `web/public/fonts/licenses/` (Implements: FR-027) (code_ref: pending | knowledge_ref: pending)
- [ ] T006 Scaffold `web/`: `package.json` (Astro current stable, strict TypeScript, Vitest, `lucide-static`, all pinned with `package-lock.json`), `astro.config.mjs` (`output: 'static'`, no adapter, no UI-framework integration, `build.inlineStylesheets: 'never'` so styles ship as files the CSP allows; site components use bundled `<script>` modules only, never `is:inline`), `tsconfig.json`, an `npm run check` script running `astro check && vitest run && node scripts/check-content.mjs` (Implements: FR-028) (code_ref: pending | knowledge_ref: pending)
- [ ] T007 Convert the theme TTFs to WOFF2 into `web/public/fonts/`, documenting the one-time command in `web/scripts/convert-fonts.md`; `web/src/styles/global.css` imports `theme/make-bold/styles.css` and overrides `@font-face` to the WOFF2 files (Implements: FR-027) (code_ref: pending | knowledge_ref: pending)
- [ ] T008 [P] Port the theme primitives as Astro components with the theme prop sets and token-only scoped CSS: `web/src/components/ui/Button.astro`, `Card.astro`, `Badge.astro`, `Eyebrow.astro`, `Input.astro` (Implements: FR-027, FR-028) (code_ref: pending | knowledge_ref: pending)
- [ ] T009 [P] Create `web/src/components/ui/Icon.astro`, inlining pinned `lucide-static` SVGs (2px stroke, `currentColor`), replacing the mockup's Unicode glyphs (✓ ✕ ⛶ → ≡) (Implements: FR-027) (code_ref: pending | knowledge_ref: pending)
- [ ] T010 Create `web/src/layouts/BaseLayout.astro` (visible ember focus ring, reduced-motion media query, skip link), `web/src/components/site/SiteHeader.astro` (peak mark + "ArrowSpark" + spaced "MAKE BOLD SPARK"; nav: Play, Built with DevSpark, Journey, Evidence, Read the Story; keyboard-reachable mobile menu), `SiteFooter.astro` (session-memory note, licences link) and `web/src/pages/licenses.astro`. The licences page lists the Godot Engine (MIT, with the third-party notices it ships), Maaack's Game Template, Lucide (ISC), Be Vietnam Pro and Inter Tight (OFL), and every other notice the packaged build requires (Implements: FR-027, FR-008) (code_ref: pending | knowledge_ref: pending)
- [ ] T011 Create `web/src/styles/arrowspark.css` for the documented extensions only (game frame, beat rail, journey list), using tokens (Implements: FR-027) (code_ref: pending | knowledge_ref: pending)
- [ ] T012 Create the landing page `web/src/pages/index.astro` with `web/src/components/site/EntryCard.astro` (rust "Try the Game" and ink "Built with DevSpark" cards of equal conceptual weight, side by side, stacking on narrow screens), `PromiseStrip.astro`, and the one-sentence framing, all free of design vocabulary (Implements: FR-001, FR-003, FR-005) (code_ref: pending | knowledge_ref: pending)
- [ ] T013 Create `web/scripts/check-content.mjs` skeleton with rule R-1 (no `.devspark.work` in `web/src`, `web/public` text, or `web/dist`) and the SC-013 literal check (no raw hex or px outside `web/theme/` and `web/src/styles/arrowspark.css`), wired into `npm run check` (Implements: FR-029, FR-027) (code_ref: pending | knowledge_ref: pending)
- [ ] T014 Create `.github/workflows/showcase.yml`, which installs the pinned Godot editor and templates (SHA-512 verified, cached by version) and runs both Godot launchers. It exports Web to `web/public/game/<commit-short-sha>/` (**[S-1]**: the export step is added once S-1 passes; until then the job runs only the launchers and the site build). It then runs `npm ci && npm audit --audit-level=high && npm run check && npm run build` in `web/`. In the same task, create the single **synthetic check** `web/scripts/synthetic-check.mjs`: a headless browser (e.g. Playwright, or any WebDriver runner) that loads `/` and `/play`, waits for the game iframe's `engineState=started`, and fails on any console error or CSP violation. **[S-1]**: the `/play` engine wait depends on the Web export and custom shell (T001), so it is added with the export step; until S-1 passes the check loads `/` and the story pages only. The browser version is pinned by the lockfile and launched with an explicit **software WebGL backend** (Chromium: ANGLE on SwiftShader), and the check logs the WebGL renderer string it got. It first probes for a WebGL2 context: if the runner cannot create one, the result is **inconclusive** (a distinct exit code and a job warning, never a failure or an outage). Only an engine that fails to start while WebGL2 is available, a console error or a CSP violation fails the check. It tracks no visitors and uses no telemetry. Deploy and its scheduling are added in T071 (Implements: FR-023, FR-028, FR-025) (resolves: critic-014) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: amendment approved, theme vendored, the landing page renders, `npm run check` and CI green.

---

## Phase 3: User Story 1: A fresh player plays the Reference Knot from a link (P1) 🎯 MVP

**Goal**: the unchanged Reference Knot is playable in a desktop browser from the Play page, with an honest desktop-only notice, and it emits one identifier-free completion event.

**Independent Test**: give the local or preview link to someone new, say only "Here's a puzzle game", and see that they reach and play the Reference Knot without help. Devtools shows one validated `attemptCompleted` and nothing else.

### Tests for User Story 1

- [ ] T015 [P] [US1] Add the Reference Knot content-version pin to `tests/puzzle_catalog_check.gd`: the literal expected `g1-…` value; content version stable across calls; changes when one tail cell is altered in a synthetic copy; independent of title/group (Implements: FR-009) (code_ref: pending | knowledge_ref: pending)
- [ ] T016 [P] [US1] Add payload-builder checks to `tests/puzzle_presentation_check.gd`: exact eight keys, integer fields, `type`/`contractVersion` values, `elapsedSeconds` rounding, no identifier/timestamp keys, emitter is a no-op when not on web (Implements: FR-019) (code_ref: pending | knowledge_ref: pending)
- [ ] T017 [P] [US1] Add the group-description check to `tests/puzzle_layout_check.gd`: each of the three Level Select groups shows one description line; no ranking words (Implements: FR-006) (code_ref: pending | knowledge_ref: pending)
- [ ] T018 [P] [US1] Write `web/tests/game-bridge.test.ts`: accepts a valid same-origin message from the game frame; ignores foreign origin, wrong `source`, non-string, over 1,024 chars, bad JSON, extra or missing properties, bad types or ranges; keeps only the latest; never touches browser storage (Implements: FR-019, FR-018) (code_ref: pending | knowledge_ref: pending)

### Implementation for User Story 1

- [ ] T019 [P] [US1] Create `scripts/puzzle/puzzle_content_version.gd` (`class_name PuzzleContentVersion`, static `of(definition) -> String`, canonical geometry text per data-model.md, `"g1-"` + first 12 hex of SHA-256). No change to `PuzzleDefinition` or rules (Implements: FR-009) (code_ref: pending | knowledge_ref: pending)
- [ ] T020 [P] [US1] Create `scripts/presentation/web_attempt_emitter.gd`: pure `build_payload(puzzle_id, definition, results, elapsed_ms) -> Dictionary` and web-gated, fire-and-forget `emit(payload)` via `JavaScriptBridge.get_interface("window").parent.postMessage(JSON.stringify(payload), window.location.origin)` (Implements: FR-019, FR-030) (code_ref: pending | knowledge_ref: pending)
- [ ] T021 [US1] In `scenes/puzzle/arrow_puzzle.gd`: record the start tick in `_start_new_attempt()`, record the completion tick in the REMOVED branch when `_state.completed`, and call `WebAttemptEmitter` in `_show_results()` after `PuzzleScoreboard.record_attempt`. Nothing else changes (depends on T019, T020) (Implements: FR-019, FR-004) (code_ref: pending | knowledge_ref: pending)
- [ ] T022 [US1] Add one honest description line per group in `scenes/menus/main_menu/puzzle_select_menu.gd` (ArrowSpark Levels: the intended experience; Foundations: small boards that teach the rule; Puzzle Lab: development experiments, some deliberately over-tangled), with no design vocabulary and focus behavior unchanged (Implements: FR-006, FR-005) (code_ref: pending | knowledge_ref: pending)
- [ ] T023 [US1] **[S-1]** Run both launchers and `--headless --editor --quit` on 4.4-stable. Record the pin value and all failure markers at `0` in `evidence/s1-export-spike.md`; re-export and confirm the Reference Knot still plays (Implements: FR-009, FR-023) (code_ref: pending | knowledge_ref: pending)
- [ ] T024 [P] [US1] Create `web/src/scripts/game-bridge.ts` per contracts/attempt-completed-event.md (origin + source + shape validation, latest-only module state, production builds log nothing) (Implements: FR-019, FR-030) (code_ref: pending | knowledge_ref: pending)
- [ ] T025 [P] [US1] Create `web/src/scripts/page-zoom-guard.ts` for the **surrounding page only** (frame border, title bar, page chrome). The in-game guard lives in the custom Godot shell (T001), because events inside the iframe never reach the host page. Game input is unchanged (Implements: FR-004) (code_ref: pending | knowledge_ref: pending)
- [ ] T026 [P] [US1] Create `web/src/components/play/GameFrame.astro`: dark frame, title bar, a Fullscreen button targeting the iframe, a loading state with progress note, and a same-origin `<iframe src="/game/<commit-short-sha>/index.html" allow="fullscreen; autoplay">`, the path coming from a build-time setting written by CI, with click-to-focus and an instruction line (Implements: FR-004) (code_ref: pending | knowledge_ref: pending)
- [ ] T027 [P] [US1] Create `web/src/components/play/DesktopOnlyNotice.astro`: shown for `(pointer: coarse)` or viewports under 960×540; offers the story and copy-link / `mailto:`; collects no email or contact detail (Implements: FR-007) (code_ref: pending | knowledge_ref: pending)
- [ ] T028 [US1] Create `web/src/pages/play.astro`: heading, controls-only instructions (rule, mistakes cost score not play, Open Move and its cost, click once for keyboard), session-memory and privacy note (FR-018 infrastructure caveat), `GameFrame`, `DesktopOnlyNotice`, `game-bridge` and `page-zoom-guard` wired, and a "See how it was built" link. The page and components can be built and unit-tested before S-1; seeing the real game in the frame is **[S-1]** (Implements: FR-004, FR-005, FR-007, FR-008, FR-002) (code_ref: pending | knowledge_ref: pending)
- [ ] T029 [US1] Extend `web/scripts/check-content.mjs` with rule R-4. It scans **visible text only** (HTML text nodes plus `alt`/`title`/`aria-label`, excluding script, style and other attributes), whole-word and case-insensitive, for the FR-005 word list. It covers every pre-play surface in contracts/site-content.md R-4: built `index.html`, `play/index.html`, the game-loading/pre-play shell, the built Journey page, the site header, footer and desktop-only notice, the text of `scenes/menus/**/*.tscn` and `scenes/loading_screen/**/*.tscn`, and the string literals in `scenes/menus/**/*.gd` (including `puzzle_select_menu.gd`). It does not scan the rest of the repository, and fails the build on any hit (Implements: FR-005) (code_ref: pending | knowledge_ref: pending)
- [ ] T030 [US1] Update `.knowledge/architecture/arrow-puzzle.md`: puzzle content version (what it hashes, independent of app version, Reference Knot pinned), attempt timing, the web-only completion emitter and its one-way contract. (Implements: FR-009, FR-019, FR-006) (code_ref: pending | knowledge_ref: pending)

  In the existing Level Select section, document the group description lines:
  - ArrowSpark Levels: the intended player experience;
  - Foundations: small boards that teach the rule;
  - Puzzle Lab: development experiments, some deliberately over-tangled.

  Keep the rule that group labels describe purpose, not a quality ranking, and cite `tests/puzzle_layout_check.gd` as the source of truth for them. Add `scripts/puzzle/puzzle_content_version.gd`, `scripts/presentation/web_attempt_emitter.gd` and `scenes/menus/main_menu/puzzle_select_menu.gd` to `appliesTo`
- [ ] T031 [US1] Create `.knowledge/architecture/web-showcase.md` (type: architecture; `appliesTo` `web/**`, `export_presets.cfg`, `.github/workflows/showcase.yml`). It covers the site structure, the iframe host, the bridge validation rules, the zoom guard, the desktop-only boundary, the authority split (site / game / external API) and the pinned engine. It also covers the five behaviors added by the gate remediation: the build-unique `/game/<commit-short-sha>/` path and its immutable-cache rule; the Godot-compatible production CSP and its `connect-src` derived from `PUBLIC_REACTIONS_URL`; the custom Godot shell (in-game zoom guard, `engineState` marker); the synthetic load check, its software-WebGL/inconclusive rule and its preview and daily schedule; and the licences page. Each is written from its durable source (`web/game-shell/shell.html`, `web/src/pages/licenses.astro`, `web/scripts/synthetic-check.mjs`, `web/staticwebapp.config.json`, `.github/workflows/showcase.yml`). Items whose source does not exist yet when this task runs (the CSP and caching from T068, the schedule from T071) are added to this node by those tasks. This task completes before T061 extends the node (Implements: FR-028, FR-030, FR-004) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: US1 works on its own. The Play page plays the Reference Knot in a local export and the bridge receives one valid event.

---

## Phase 4: User Story 2: A developer understands how it was built without playing first (P1)

**Goal**: the Built with DevSpark path, the Journey, the Evidence page and the story chapters are published from durable, sourced content, with spoiler notes where needed.

**Independent Test**: a developer unfamiliar with DevSpark reads only the method path and can say what DevSpark is, one place it helped and one place it failed. Every factual claim's link resolves to a permanent source.

### Tests for User Story 2

- [ ] T032 [P] [US2] Create `web/src/content.config.ts` with Zod schemas for `chapters`, `beats`, `journey`, `evidence`, `lessons`, `facts` exactly per contracts/site-content.md. Every `sources[].url` is validated against the R-2 evidence hierarchy, and any URL containing `.devspark.work` is rejected (R-1) (Implements: FR-013, FR-029) (code_ref: pending | knowledge_ref: pending)
- [ ] T033 [US2] Extend `web/scripts/check-content.mjs` with rules R-1 and R-2 (evidence hierarchy, no `.devspark.work` in any URL form), R-3 (no author placeholders) and R-5 (every numeric fact has `source`, and `command` when derived). Add a `--fetch-links` mode that requests every external URL once. It runs pre-publication and on a schedule, **not** on every push (Implements: FR-013, FR-014) (code_ref: pending | knowledge_ref: pending)

### Implementation for User Story 2

- [ ] T034 [US2] Compute the figures for `web/src/content/facts.yaml`, each with its `command` and a commit-pinned `source`: (Implements: FR-013, FR-014) (code_ref: pending | knowledge_ref: pending)
  - the Reference Knot board facts plus its content version (from T023);
  - the clock cut off at `6e60e11`: elapsed time, commits, merged PRs, sessions using the 90-minute gap, test-touching commits, and code vs test line counts;
  - an assertion count from launcher output with a documented command, or the mockup's "4,000+" claim dropped.
- [ ] T035 [P] [US2] Write `web/src/content/beats.yaml`: 12 belief → evidence → decision beats from showcase-research §4, refreshed, each with ≥1 permanent source and `spoiler` set for beats discussing the Reference Knot's design (Implements: FR-011, FR-010) (code_ref: pending | knowledge_ref: pending)
- [ ] T036 [P] [US2] Write `web/src/content/journey.yaml`: 10 milestones (what changed / what we learned), spoiler-light, accurate titles, chapter links. The mockup's "two lessons each" heading is corrected (Implements: FR-002) (code_ref: pending | knowledge_ref: pending)
- [ ] T037 [P] [US2] Write `web/src/content/lessons.yaml`: worked and didn't of comparable weight, each with a source. Must include the 2/5 playtest, SC-005 failed then amended in the open, the deferred check, the audit's leaked planning IDs, the F3 readout added and removed, the one-tester evidence base, and the PR-review focus bug and stale knowledge (Implements: FR-012, FR-010) (code_ref: pending | knowledge_ref: pending)
- [ ] T038 [P] [US2] Write `web/src/content/evidence.yaml`: automated items with commands, the human baseline ("one tester, who designed the level; no independent player before this showcase"), the Web-readiness gate not met, the not-claimed list, and limitations with their classes (Implements: FR-012, FR-013) (code_ref: pending | knowledge_ref: pending)
- [ ] T039 [P] [US2] Refresh chapters 01-04 into `web/src/content/chapters/01-finding-the-gap.md` … `04-making-it-feel-right.md` from `.devspark.work/development/arrowspark-series/`. Every evidence reference is rewritten per the FR-013 hierarchy: links to temporary documents become a short quotation or paraphrase supported by the durable commit or PR (Implements: FR-015, FR-013, FR-014) (code_ref: pending | knowledge_ref: pending)
  - fix stale figures from `facts.yaml`;
  - replace working-document paths with permanent links;
  - remove TODO comments;
  - omit author-only facts that haven't been supplied and list them in `evidence/author-gaps.md`;
  - keep accurate prose.
- [ ] T040 [P] [US2] Refresh chapters 05-06 into `web/src/content/chapters/05-playtest-beat-the-dashboard.md` and `06-contract-before-difficulty.md` the same way. Set `spoiler: true` on either chapter whose final text contains Reference Knot design vocabulary or level-specific design details, per contracts/site-content.md, and add Spec 008's verify result to 06 (Implements: FR-015, FR-016) (code_ref: pending | knowledge_ref: pending)
- [ ] T041 [US2] Split chapter 07 into `web/src/content/chapters/07-pulling-the-thread.md`, containing Spec 009 and the audit only, with `spoiler: true`. Move "Where it stands", "The whole clock", "What DevSpark learned", "What's still open" and "Back to the gap" out (Implements: FR-015, FR-016) (code_ref: pending | knowledge_ref: pending)
- [ ] T042 [P] [US2] Publish `web/src/content/chapters/08-the-reference-knot.md` from the 2026-10-01 draft with `spoiler: true`, refreshed links and figures from `facts.yaml` (Implements: FR-015, FR-016) (code_ref: pending | knowledge_ref: pending)
- [ ] T043 [US2] Write `web/src/content/chapters/09-now-its-your-turn.md` (new). It covers the whole clock (from `facts.yaml`), what DevSpark learned, the convergence story (the F3 readout in `b3aa17e`/`6851baf`, the three PR #4 review revisions, the closeout rule), what's still open, and the ask to play then react. Leave it as `status: draft` until **the owner confirms the convergence framing** (depends on T041) (Implements: FR-015, FR-010) (code_ref: pending | knowledge_ref: pending)
- [ ] T044 [P] [US2] Create the story components in `web/src/components/story/`: `BeatList.astro`, `JourneyList.astro`, `LessonsPair.astro`, `FactTiles.astro` (with the "describe, not judge" note), `EvidenceCallout.astro`, `ChapterList.astro`, and `web/src/components/site/SpoilerGate.astro` (a play-first note that does not block reading) (Implements: FR-016, FR-011, FR-012) (code_ref: pending | knowledge_ref: pending)
- [ ] T045 [US2] Create `web/src/pages/devspark.astro`: beats, the Code/Tests/Knowledge diagram (inline SVG on tokens), lessons pair, Reference Knot facts behind `SpoilerGate`, the convergence callout, and a "Now form your own opinion" link to Play (Implements: FR-010, FR-011, FR-012, FR-002, FR-003) (code_ref: pending | knowledge_ref: pending)
- [ ] T046 [P] [US2] Create `web/src/pages/journey.astro` (the shared rejoin point, linking to both paths) and `web/src/pages/evidence.astro` (automated / human / not claimed / limitations from `evidence.yaml`, plus the Reference Knot content version among the board facts) (Implements: FR-002, FR-012, FR-013) (code_ref: pending | knowledge_ref: pending)
- [ ] T047 [US2] Create `web/src/pages/story/index.astro` (the real 9-part list from the collection, published only) and `web/src/pages/story/[slug].astro` plus `web/src/layouts/ArticleLayout.astro` (prose width, play-first note when `spoiler`, sources list) (Implements: FR-015, FR-016, FR-029) (code_ref: pending | knowledge_ref: pending)
- [ ] T048 [US2] Run `npm run check` and `node web/scripts/check-content.mjs --fetch-links`; record results in `evidence/content-check.md`. The owner reviews chapters 01-09 and confirms the T043 framing (Implements: FR-013, FR-015) (code_ref: pending | knowledge_ref: pending)
- [ ] T049 [US2] Extend `.knowledge/architecture/web-showcase.md` with the content model (collections, one source per fact, the permalink rule, spoiler notes, the pre-play vocabulary rule) (Implements: FR-029, FR-013, FR-016) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: US2 works on its own. The full method path builds from content, and every link resolves.

---

## Phase 5: User Story 3: Visitors leave short, anonymous reactions (P2), client only

**Goal**: the game and story reaction forms send contract-valid, identifier-free requests. With no endpoint, they keep unsent reactions in a small local pending queue and send them later. **No task here builds or deploys the API.**

**Independent Test**: with the dev mock in `unavailable`, submit both reactions and see "saved on this device, not sent yet". Switch the mock to `accept`, reload, and see them sent once and the queue emptied. Gameplay is unaffected throughout.

### Tests for User Story 3

- [ ] T050 [P] [US3] Write `web/tests/reaction-schema.test.ts` from contracts/reactions-api.md: every valid example accepted; every invalid example rejected (unknown property, out-of-range, attempt on story, incomplete attempt, unknown type, 1,001-char comment, over 4,096 bytes) (Implements: FR-026, FR-018) (code_ref: pending | knowledge_ref: pending)
- [ ] T051 [P] [US3] Write `web/tests/pending-queue.test.ts`: (Implements: FR-032, FR-018) (code_ref: pending | knowledge_ref: pending)
  - save on unavailable; cap of 5 refuses the sixth;
  - flush once on load and before a new submission;
  - remove on 202 and on 400/413/415; keep on 404/405/429/5xx/network/timeout/CORS/CSP-blocked, then stop flushing;
  - **two flushers running at once send each entry exactly once** through both the Web Locks path and the claim-before-send fallback. This proves the queue logic only; the test environment has no real cross-tab locks, so the real two-tab proof is in T072;
  - Discard clears; blocked storage falls back to the unavailable state;
  - feedback-closed mode clears without sending;
  - each stored entry is `{ body, savedOn }`, where `body` is the exact contract body and `savedOn` is a UTC date (day precision) used only for expiry and never sent;
  - entries older than 7 days are dropped on load without sending;
  - when the queue is full after pruning, the newest attempt is refused with a notice and nothing older is evicted;
  - no visitor or entry identifier;
  - no timers.
- [ ] T052 [P] [US3] Write `web/tests/reaction-client.test.ts`: request URL and `Content-Type`; body built from form plus the bridge's latest attempt; no cookies or credentials (`credentials: 'omit'`); 8 s timeout; `202` → sent; `400`/`413`/`415` → invalid (dropped); `404`/`405`/`429`/`5xx`/network error/timeout/CORS TypeError/CSP-blocked → pending (Implements: FR-017, FR-019, FR-026, FR-032) (code_ref: pending | knowledge_ref: pending)

### Implementation for User Story 3

- [ ] T053 [P] [US3] Create `web/src/scripts/reaction-schema.ts`, mirroring the contract exactly (enums, limits, no extra properties, byte cap) (Implements: FR-026) (code_ref: pending | knowledge_ref: pending)
- [ ] T054 [US3] Create `web/src/scripts/pending-queue.ts` per FR-032 and data-model.md: one storage key; at most 5 entries of `{ body, savedOn }`; 7-day expiry pruned on load; newest refused when full; bounded flush moments, **serialized across tabs with the Web Locks API** (`navigator.locks.request`; if unavailable, claim entries by removing them before sending and re-adding them on a keep outcome); Discard; blocked-storage fallback; feedback-closed clearing (depends on T053) (Implements: FR-032, FR-018) (code_ref: pending | knowledge_ref: pending)
- [ ] T055 [US3] Create `web/src/scripts/reaction-client.ts`: POST `${PUBLIC_REACTIONS_URL}/api/public/arrowspark/reactions` with `credentials: 'omit'` and an 8 s timeout. It classifies responses exactly per FR-026 A (`202` sent; `400`/`413`/`415` invalid; everything else, including `404`/`405`, CORS and CSP failures, pending), hands pending ones to the queue, and treats an unset URL as unreachable (depends on T053, T054) (Implements: FR-017, FR-026, FR-032) (code_ref: pending | knowledge_ref: pending)
- [ ] T056 [P] [US3] Create `web/src/components/play/ReactionForm.astro`: at most 5 optional questions (finished, satisfaction 1-5, play another, read story first, "What did you notice?"), the one-line notice that comments are anonymous and may be quoted publicly, attempt attached only if the bridge holds one, plus pending / sent / unavailable / not-saved states and a "Discard unsent feedback" control (Implements: FR-017, FR-019, FR-032) (code_ref: pending | knowledge_ref: pending)
- [ ] T057 [P] [US3] Create `web/src/components/play/StoryReactionForm.astro`: at most 4 optional questions (made sense, changed view, would use, comment), the same publish notice and the same states, placed at the end of the method path in `web/src/pages/devspark.astro` (Implements: FR-017, FR-032) (code_ref: pending | knowledge_ref: pending)
- [ ] T058 [US3] Wire `ReactionForm` into `web/src/pages/play.astro` below the game frame (offered, never nagging), and call the queue flush on load in `BaseLayout.astro`. A `PUBLIC_FEEDBACK_CLOSED` build flag replaces both forms with "Feedback for this showcase has closed" and clears queues (Implements: FR-017, FR-032) (code_ref: pending | knowledge_ref: pending)
- [ ] T059 [P] [US3] Create `web/scripts/mock-reactions.mjs` (dev only, not built into `dist`): contract validation, `accept|invalid|unavailable` modes switchable at runtime, CORS for localhost only; add an `npm run mock:reactions` script (Implements: FR-032, FR-026) (code_ref: pending | knowledge_ref: pending)
- [ ] T060 [US3] Write `.devspark.work/specs/011-spec-web-showcase/evidence/api-handoff.md` for the separate API project. It holds the contract reference (contracts/reactions-api.md), FR-018 privacy, FR-026 server-side bounds, FR-031 storage and purge (one JSON file per reaction, never in a repo, purge plus disable after the closeout), and the agreed base URL setting. It is a handoff only, with no API code (Implements: FR-031, FR-026) (code_ref: pending | knowledge_ref: pending)
- [ ] T061 [US3] Extend `.knowledge/architecture/web-showcase.md` with the reaction client: contract-valid requests only, no credentials, the pending-queue rules and its privacy limits, the feedback-closed mode, and the endpoint owned by the external API (Implements: FR-017, FR-018, FR-032) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: US3 works on its own against the mock with no real endpoint. SC-006 and SC-014 are demonstrated.

---

## Phase 6: User Story 4: The owner runs observed fresh-player sessions (P2), preparation

**Goal**: the facilitator has a script, a checklist and private and public record formats ready before publication. The sessions themselves run in the learning window (Phase 9).

**Independent Test**: one dry run with the facilitator script produces a private raw note outside the repo and an anonymized summary in the bundle, with no identifying detail.

- [ ] T062 [P] [US4] Prepare the session kit in `.devspark.work/specs/011-spec-web-showcase/evidence/`: (Implements: FR-020, FR-021) (code_ref: pending | knowledge_ref: pending)
  - `facilitator-script.md`: opening line ("Here's a puzzle game. Play it however you like."), the consent line (anonymized quotes may be published; anyone who declines is paraphrased), the FR-020 order, the 14-item checklist with the discovery check, one-question-at-a-time interview prompts, the DevSpark comprehension questions (SC-011), and what not to say (no vocabulary, no coaching, no explaining Level Select);
  - `sessions/_summary-template.md`: anonymized fields per data-model.md only, with "never record name, contact detail, employer". Raw notes live outside any repo [O];
  - `window.md`: `published_reachable_at`, `closes_at` (+14 days), `api_available_from`, close and purge dates.
  - the opening line ("Here's a puzzle game. Play it however you like.");
  - the consent line (anonymized quotes may be published; decliners are paraphrased);
  - the FR-020 order;
  - the 14-item checklist and the discovery check;
  - one-question-at-a-time interview prompts;
  - the DevSpark comprehension questions (SC-011);
  - what not to say (no vocabulary, no coaching, no explaining Level Select).

**Checkpoint**: session materials ready; no participant needed yet.

---

## Phase 7: User Story 5: The public baseline tells the truth (P3), prerequisite P3

**Goal**: player-visible text and the durable knowledge the Evidence page cites match the shipped behavior. **Must complete before publication (T073).**

**Independent Test**: a grep for the stale claims finds none, and both gates are green.

- [ ] T063 [P] [US5] Fix the Play tooltip in `scenes/menus/main_menu/main_menu_with_animations.tscn` so it describes starting the Reference Knot (no "first catalog puzzle") (Implements: FR-022) (code_ref: pending | knowledge_ref: pending)
- [ ] T064 [P] [US5] Correct `.knowledge/architecture/save-progression.md`: the Play target is `reference_knot` (not `id_at(0)`), the current Level Select entry count and accordion, the new tooltip text; and add that web builds store settings in browser-local storage, not as a migration (Implements: FR-022, FR-008) (code_ref: pending | knowledge_ref: pending)
- [ ] T065 [P] [US5] Correct `.knowledge/architecture/arrow-puzzle.md`: the order-independence wording states the Reference Knot is sampled every sixth branching state, the others exhaustively; the Back button is in the HUD tab-order sentence (Implements: FR-022) (code_ref: pending | knowledge_ref: pending)
- [ ] T066 [P] [US5] Correct `tests/README.md`: Play/New Game targets the Reference Knot, and the order-independence description includes the sampling (Implements: FR-022) (code_ref: pending | knowledge_ref: pending)
- [ ] T067 [US5] Update the Play-target assertion in `tests/save_input_regression.gd` (Reference Knot, not catalog position 0) if it still encodes the old wording; run both gates on 4.4-stable and grep for "first catalog puzzle", "catalog position 0", "twenty-one entries" and unsampled `reference_knot` claims; record in `evidence/baseline-check.md` (Implements: FR-022) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: the truthful baseline is in place.

---

## Phase 8: Integration, browser validation and publication

**Purpose**: CI deploys; three browsers recorded; the site goes public; the window opens.

- [ ] T068 Create `web/staticwebapp.config.json`: (Implements: FR-024, FR-018) (resolves: critic-013) (code_ref: pending | knowledge_ref: pending)
  - MIME types for `.wasm` and `.pck`;
  - `Cache-Control: public, max-age=31536000, immutable` for `/game/<commit-short-sha>/*`, which is safe because every build gets a new path, and `no-cache` for HTML;
  - a **Godot-compatible production CSP** with every directive explicit: `default-src 'self'`; `script-src 'self' 'wasm-unsafe-eval'` plus the SHA-256 of the custom shell's inline bootstrap script, computed at build from the exported `index.html`; `style-src 'self'` (Astro styles are files per T006 and the shell's loader style is `shell.css` per T001); `img-src 'self' data:`; `font-src 'self'`; `worker-src 'self'`; `connect-src 'self'` plus the origin of `PUBLIC_REACTIONS_URL`, generated from the same build setting so the two can't drift; `object-src 'none'`; `base-uri 'self'`; `frame-ancestors 'self'`;
  - a post-build step that generates the header and **fails the build** if any page in `dist` or the exported game contains an inline `<script>` or `<style>` the policy does not hash;
  - no cookies.
  - Any further source the engine needs (for example `blob:` for an audio worklet) is added only to the one directive that needs it, only after the preview shows the violation, and recorded in `evidence/browser-smoke.md`.
  - The policy is verified only on an Azure Static Web Apps preview environment carrying these production headers (the T071 preview synthetic check and T072), never inferred from local dev. When this file exists, add its caching and CSP rules to `.knowledge/architecture/web-showcase.md` (T031).
- [ ] T069 [O] Owner creates the Azure Static Web App, the deploy-token secret in GitHub, and DNS plus the custom domain `arrow.makeboldspark.com`, and confirms the reactions base URL. Record in `evidence/hosting.md` (Implements: FR-024) (code_ref: pending | knowledge_ref: pending)
- [ ] T070 [P] **[S-1]** Measure landing page → interactive Reference Knot against the SC-001 target (under 30 s) under the fixed profile, ≥ 25 Mbps downstream, ≤ 50 ms RTT and cold browser cache, on the **SWA preview**. Throttle in browser devtools, or use a real connection meeting the profile. Record browser, connection profile, cache state, load time, transferred size, the raw and transferred sizes of `.wasm` and `.pck`, and the `Content-Encoding` actually served, in `evidence/browser-smoke.md`. Optimize only if the measured target fails. This is one measurement per browser, not a broader network study (Implements: FR-025) (code_ref: pending | knowledge_ref: pending)
- [ ] T071 Add the deploy job to `.github/workflows/showcase.yml`. It uses the official Static Web Apps deploy action, with a preview environment on PRs and production on `main`, and takes `PUBLIC_REACTIONS_URL` from a repository variable. Run the T014 synthetic check against each PR's preview, and add a scheduled daily run of the same check against production. The scheduled run is enabled by a repository variable only during the learning window. A failed preview check blocks the PR. An inconclusive result (no WebGL2 in the runner, T014) is reported as a warning naming the WebGL backend, never as an outage. Add the schedule and the inconclusive rule to `.knowledge/architecture/web-showcase.md` (T031) (Implements: FR-024, FR-023) (code_ref: pending | knowledge_ref: pending)
- [ ] T072 **[S-1]** Run and record the browser smoke test (FR-025) **on the SWA preview environment with production headers** in `evidence/browser-smoke.md`, for **Chromium-based (Windows)**, **Firefox (Windows)** and **Safari (macOS)**, each with browser and OS versions (Implements: FR-025, FR-004, FR-007, FR-032) (resolves: critic-015) (code_ref: pending | knowledge_ref: pending)
  - every check in plan Phase 6, with the devtools console showing no CSP violations;
  - in-game pinch and keyboard zoom suppression per browser; any suppression a browser disallows is recorded as an accepted limitation;
  - **deploy a second build and reload:** the new `/game/<sha>/` assets load with no stale engine files;
  - the pending queue unavailable → saved → available → sent;
  - **real two-tab flush (Chromium at minimum):** with at least two entries pending, open two tabs of the same browser profile and reload both at once, so both flush together. Run against local `astro preview` with `mock-reactions.mjs` in `accept` mode, because its request log is the proof; Web Locks behavior does not depend on the host. Each entry reaches the mock exactly once and both tabs' queues end empty. Record the browser, the entry count and the mock log;
  - devtools inspection of requests and queue (SC-006);
  - the story pages at phone width;
  - the desktop-only notice on a real phone.

  Mark any check not performed as not performed.
- [ ] T073 **[S-1]** Publish to production. Confirm `https://arrow.makeboldspark.com` serves the showcase, and record `published_reachable_at` and `closes_at` (+14 days) in `evidence/window.md`. Run `check-content.mjs --fetch-links` once as a pre-publication check, and enable the daily synthetic check (T071) for the window. Requires T023, T048, T067, T072 complete, the T071 synthetic check passing on the release preview with production headers (no CSP violation; an inconclusive CI result counts only if T072's manual smoke on the same build passed), and no open play-affecting failure (Implements: FR-024, FR-020) (code_ref: pending | knowledge_ref: pending)
- [ ] T074 Update `.knowledge/product/branding.md` to name `arrow.makeboldspark.com` as the ArrowSpark showcase destination under Make Bold Spark (Implements: FR-024) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: the site is public and the learning window is open.

---

## Phase 9: Learning window (14 days) and closeout

**Purpose**: gather evidence, report it as it stands, close feedback. The window is never extended.

- [ ] T075 [US4] [O] During the window, run observed sessions with genuinely new players using `evidence/facilitator-script.md` in the FR-020 order: landing impression (SC-002 equal billing, SC-013 theme recognition) → fresh play → interview → Built with DevSpark → DevSpark comprehension (SC-011). Raw notes stay private outside any repo; commit one anonymized summary per session in `evidence/sessions/NN.md`. Targets: ≥3 fresh-play sessions, ≥3 landing impressions and ≥2 DevSpark comprehension answers. Recruit extra landing-only reviewers only if fewer than 3 sessions occur. A shortfall is an accepted limitation (Implements: FR-020, FR-001, FR-027) (code_ref: pending | knowledge_ref: pending)
- [ ] T076 Rebuild and deploy with `PUBLIC_FEEDBACK_CLOSED=true`: the forms are replaced by the closed note, and queues are cleared on next load. Disable the daily synthetic check and record its results across the window, along with the date, in `evidence/window.md`. Server-side purge and endpoint disable are the API project's [O] (Implements: FR-032, FR-031) (code_ref: pending | knowledge_ref: pending)
- [ ] T077 [O] Delete the raw observed-session notes and any private copies of reactions after the closeout report is written, and record the dates in `evidence/window.md` (Implements: FR-020, FR-031) (code_ref: pending | knowledge_ref: pending)
- [ ] T078 At day 14, write the closeout. Obtain whatever reactions the separate API project received within the window (none is acceptable) and report them in `evidence/closeout-report.md` in three tiers (observed / unobserved first-contact / unobserved read-story-first). Include the yes/partly/no shares, free text quoted as given under the FR-017 notice, and late arrivals counted separately. Then add the closeout to `spec.md`, sorting every item into Passed / Accepted Limitation / Deferred Work / Learning / Failed and stating plainly what outside players said about the game and about the process. No extension; negative findings are deferred to later specs (Implements: FR-021) (code_ref: pending | knowledge_ref: pending)

---

## Phase 10: Polish and verification

**Purpose**: verification gate, knowledge consistency, no planning references, linkage.

- [ ] T079 [P] Run the planning-reference check across durable outputs (`scripts/`, `scenes/`, `tests/`, `web/src`, `web/scripts`, `web/theme`, `web/THEME.md`, `.knowledge/`, `.github/`, `CLAUDE.md`, `AGENTS.md`): no `.devspark.work` paths, spec or plan names, or `FR-`, `SC-`, `T0` identifiers. Also confirm no authentication, accounts, visitor identity, tracking, analytics, dashboard, survey engine, CMS or database was introduced anywhere in this repository. Rebuild and validate the knowledge index for the new and updated nodes (`web-showcase.md`, `arrow-puzzle.md`, `save-progression.md`, `branding.md`, `constitution.md`) and confirm `appliesTo` covers every new file. Record all three results in `evidence/reference-check.md` (Implements: FR-033, FR-029) (code_ref: pending | knowledge_ref: pending)
- [ ] T080 Write `gates/verify.md` for `verify:end-to-end`, then confirm every completed task has real `code_ref`/`knowledge_ref` values and leave the bundle live in `.devspark.work/` for `/devspark.release`: (Implements: FR-025, FR-023) (code_ref: pending | knowledge_ref: pending)
  - the actual commands and outputs for both gates, the editor check, `npm run check` and the link fetch;
  - the three-browser smoke results;
  - the queue lifecycle against the mock;
  - not-performed items listed as such, never claimed.

---

## Dependencies & Execution Order

### Phase dependencies

- **Phase 1 (S-1)** is a **branch gate**, not a global one. It blocks only the tasks marked **[S-1]**: the engine-version doc pin, the CI export step, re-running gates and re-exporting on the confirmed engine, seeing the real game in the Play frame, browser performance, the browser smoke test, and publication. Everything else proceeds in parallel with S-1: the theme, the Astro shell, the landing page, all content and method pages, the reaction client and queue, session preparation, the truthful baseline, and the GDScript helpers and their headless tests. If S-1 forces a version change, the GDScript work is re-validated on the new version; nothing else is redone.
- **Phase 2** blocks all stories. T003 needs owner approval before T006.
- **US1 (Phase 3)** and **US2 (Phase 4)** can proceed in parallel after Phase 2. US2's T034 uses the content version from T023.
- **US3 (Phase 5)** depends on Phase 2, and on US1's bridge (T024) for attempt attachment. It is otherwise independent and needs no API.
- **US4 prep (Phase 6)** depends on Phase 2 only.
- **US5 (Phase 7)** can run any time after Phase 1, and must finish before T073.
- **Phase 8** needs US1, US2, US3 and US5. T073 also needs T069 [O].
- **Phase 9** starts at T073 and lasts exactly 14 days.
- **Phase 10** runs after T078. T079 and T079 may also run before publication as a pre-check.

### Within stories

Tests are written first and fail first (T015-T018, T032-T033, T050-T052). Then helpers, then the controller hook, components, pages, and knowledge last.

### Parallel opportunities

- Phase 2: T004 and T005 together; then T008 and T009 together.
- US1: T015-T018 together; T019 and T020 together; T024-T027 together.
- US2: T035-T038 together; T039, T040 and T042 together; T044 and T046 together.
- US3: T050-T052 together; T056, T057 and T059 together.
- US4: T062-T062 together. US5: T063-T066 together.

**Example (US1):**

```text
Parallel: T019 puzzle_content_version.gd | T020 web_attempt_emitter.gd | T024 game-bridge.ts | T025 page-zoom-guard.ts
Then:     T021 arrow_puzzle.gd hook -> T023 gates on 4.4 -> T028 play.astro
```

## Implementation Strategy

### MVP (User Story 1)

Complete Phases 1-2, then US1. Stop and validate: a local or preview build plays the Reference Knot in the browser and emits one valid event. That alone is a demonstrable increment.

### Incremental delivery

1. Add **US2**: the method path with sourced content. The site now carries both halves of the equal billing.
2. Add **US3**: reactions with the pending queue, still with no API.
3. Add **US5**, the truthful baseline, which is required before publishing.
4. Run **US4** prep, then Phase 8 (publish), then Phase 9 (window and closeout).

### Scope guard (convergence rule)

A finding during implementation is classified as Blocking Defect, Prerequisite, Accepted Limitation, Deferred Work or Learning. Only blockers and true prerequisites add tasks here. No task builds, deploys or operates the MakeBoldSpark API.
