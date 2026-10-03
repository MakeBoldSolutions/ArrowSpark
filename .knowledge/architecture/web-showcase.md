---
id: web-showcase
type: architecture
title: ArrowSpark Web Showcase (Static Site and Browser Build)
appliesTo:
  - web/**
  - export_presets.cfg
  - .github/workflows/showcase.yml
---

# ArrowSpark Web Showcase (Static Site and Browser Build)

The public showcase at `https://arrow.makeboldspark.com` is a static site in
`web/` that lets a visitor play ArrowSpark in a desktop browser and read how
it was built. It has two entry points of equal weight — **Try the Game**
(`/play/`) and **Built with DevSpark** (`/devspark/`) — that rejoin at the
**Journey** (`/journey/`), plus an Evidence page, the story chapters and a
licences page.

## Authorities

Responsibilities never overlap:

- **The site (Astro)** owns the shell, landing page, navigation, published
  content, the Journey and Evidence pages, the reaction forms and the page
  that hosts the game. It never recomputes a score or a rule.
- **The game (Godot)** owns gameplay, rules, score, puzzle state, session
  best and results. It never renders site content and never calls any API.
- **The MakeBoldSpark API** (a separate project) owns validating and storing
  a reaction. It never interprets gameplay.

## Stack and build

- Astro with strict TypeScript, `output: 'static'`, no adapter, no server
  functions and no UI framework (`web/astro.config.mjs`). Interactive parts
  are small bundled module scripts: the game host and bridge, the reaction
  forms, the desktop-only notice's copy button.
- Styles and scripts always ship as files, never inline
  (`build.inlineStylesheets: 'never'`, `vite.build.assetsInlineLimit: 0`),
  and no markup uses `style` attributes, so the production
  Content-Security-Policy needs no `'unsafe-inline'`.
- Markdown syntax highlighting is off, because highlighters emit `style`
  attributes the CSP would block.
- Dependencies are pinned exactly in `web/package.json` and
  `web/package-lock.json`. `npm run check` runs `astro check`, the Vitest
  suite (`web/tests/`) and the source publication checks;
  `npm run build` builds and then runs the publication checks on `web/dist`.
- Build-time settings (`web/src/env.d.ts`): `PUBLIC_GAME_BUILD` (the exported
  game's folder), `PUBLIC_REACTIONS_URL` (the reactions API base URL; unset
  means unreachable) and `PUBLIC_FEEDBACK_CLOSED`.

## Visual foundation

The Make Bold theme is vendored unchanged in `web/theme/make-bold/` (tokens,
base styles, readme, TTF fonts, peak mark); `web/THEME.md` records its
provenance, a SHA-256 list of every file and the extension rules. The site
imports the token files and `base.css` as-is from `web/src/styles/global.css`
and replaces only the theme's font-face file with WOFF2 faces of the same
families, weights and styles in `web/public/fonts/` (conversion documented in
`web/scripts/convert-fonts.md`). ArrowSpark-specific styling — the game
frame, the evidence beat rail, the Journey list and a screen-reader utility —
lives only in `web/src/styles/arrowspark.css`. Components in
`web/src/components/ui/` re-express the theme's Button, Card, Badge, Eyebrow
and Input prop sets in token-only scoped CSS, and `Icon.astro` inlines pinned
`lucide-static` outline icons (stroke width 2, `currentColor`) instead of
Unicode glyphs. The base layout keeps the theme's visible ember focus ring,
adds a skip link, and removes motion under `prefers-reduced-motion`. The
header's navigation collapses into a keyboard-reachable `<details>` menu on
narrow screens.

## The game in the page

- **Export.** `export_presets.cfg` defines one "Web" preset: no threads, no
  extensions, release, adaptive canvas resize, and the custom HTML shell
  `web/game-shell/shell.html`. The engine is pinned to Godot 4.4-stable for
  the export, both regression gates and CI. `web/.gdignore` keeps Godot from
  importing the site tree. `node web/scripts/export-game.mjs --godot <4.4>`
  exports into `web/public/game/<build>/` (git-ignored; `<build>` defaults to
  the commit's short SHA), copies the shell's stylesheet beside it, and prints
  the build id for `PUBLIC_GAME_BUILD`. Every build therefore gets a new
  path, so engine files can be cached as immutable.
- **Shell.** The custom shell is Godot's default loader with three changes:
  its styles live in `web/game-shell/shell.css` (copied next to the export)
  so the shell keeps a single inline script; that script suppresses browser
  page zoom inside the game (ctrl+wheel, trackpad pinch, Safari gesture
  events, Ctrl/Cmd + `+`/`-`/`0`) without stopping game input; and it sets
  `document.body.dataset.engineState` to `loading`, then `started` or
  `failed`, which the synthetic check reads. The service-worker branch is
  removed (no PWA).
- **Host.** `web/src/components/play/GameFrame.astro` renders a dark frame
  with a title bar, a Fullscreen button (on the iframe) and a loading state,
  and a same-origin `<iframe>` whose source is `/game/<PUBLIC_GAME_BUILD>/index.html`
  with `allow="fullscreen; autoplay"`. The iframe source is set by script
  only on supported screens, so phones never download the engine. Clicking
  the frame focuses the game; the Play page says to click once for the
  keyboard. Audio starts on the first click, as browsers require.
- **Page zoom outside the game.** `web/src/scripts/page-zoom-guard.ts`
  suppresses ctrl+wheel and gesture zoom only while the pointer is over the
  game frame's own border and title bar; everywhere else on the page,
  browser zoom works normally. Events inside the iframe never reach the page,
  which is why the shell guards those.
- **Desktop-only boundary.** The game is supported with a fine pointer on a
  viewport of at least 960 × 540 CSS pixels (`web/src/scripts/desktop-query.ts`).
  Outside that, CSS hides the game and `DesktopOnlyNotice.astro` says play
  isn't supported on that screen yet, links to the story, and offers to copy
  the link or open the visitor's own mail app with it. Nothing is collected.

## Completion bridge

When an attempt is completed, the Web build posts one JSON string to the
hosting page (see `.knowledge/architecture/arrow-puzzle.md`, "Attempt timing
and the Web completion hand-off"). `web/src/scripts/game-bridge.ts` accepts a
message only if all of these hold, and otherwise ignores it silently:

1. `event.origin` equals the page's own origin;
2. `event.source` is the game iframe's window;
3. the data is a string of at most 1,024 characters;
4. it parses as a JSON object with exactly the eight contract properties:
   `type` `"arrowspark.attemptCompleted"`, `contractVersion` 1, `puzzleId`
   (`^[a-z0-9_-]{1,64}$`), `puzzleVersion` (`^g1-[0-9a-f]{12}$`), `mistakes`,
   `openMoveAssists` and `score` (integers 0–10,000) and `elapsedSeconds`
   (integer 0–86,400).

The latest valid attempt replaces any earlier one and is held in a module
variable for the page visit only. It is never written to browser storage,
never sent back to the game, and leaves the page only as the `attempt` of a
game reaction the visitor chooses to send. Production builds log nothing;
development builds log accepted attempts. Source of truth:
`web/tests/game-bridge.test.ts`.

## Reactions (client side)

Visitors can leave two optional, anonymous reactions: a game reaction on the
Play page (`ReactionForm.astro`: did you finish, satisfaction 1–5, play
another, read the story first, and "What did you notice?") and a story
reaction at the end of Built with DevSpark (`StoryReactionForm.astro`: made
sense, changed view, would use, and a comment). Beside each free-text box a
line says comments are anonymous and may be quoted publicly. An answer-less
form is not sent. A game reaction carries the bridge's latest attempt only if
the visitor completed one during this page visit.

- **Contract.** `web/src/scripts/reaction-schema.ts` mirrors the reactions
  API request schema exactly (two reaction types, fixed enums and ranges, no
  other properties, comments of 1–1,000 characters after trimming, bodies of
  at most 4,096 bytes). Only valid bodies are sent. Source of truth:
  `web/tests/reaction-schema.test.ts`.
- **Client.** `web/src/scripts/reaction-client.ts` POSTs to
  `${PUBLIC_REACTIONS_URL}/api/public/arrowspark/reactions` with
  `credentials: 'omit'`, no referrer, no headers beyond `Content-Type`, and an
  8-second timeout. `202` means sent; `400`, `413` and `415` mean invalid
  (dropped, never retried); every other outcome — `404`, `405`, `429`, `5xx`,
  network error, timeout, a CORS or CSP block, or an unset URL — means the
  endpoint is unavailable. Source of truth: `web/tests/reaction-client.test.ts`.
- **Pending queue.** `web/src/scripts/pending-queue.ts` keeps reactions the
  visitor tried to send while the endpoint was unavailable, in one
  browser-storage key (`arrowspark.pendingReactions`): at most 5 entries,
  each exactly `{ body, savedOn }`, where `body` is the request as it would
  be sent and `savedOn` the UTC day, used only to drop the entry unsent after
  7 days. A sixth reaction is refused with a notice; nothing is evicted. The
  queue is flushed only once per page load (`web/src/scripts/page-start.ts`,
  from the base layout) and just before a new submission: each entry is sent
  once, removed on sent or invalid, and the flush stops at the first
  unavailable outcome. Flushes are serialized across tabs with the Web Locks
  API; where it is missing, entries are claimed (taken out of storage) before
  sending and put back on an unavailable outcome. There are no identifiers,
  no timers, no service worker and no background sync. A visible "Discard
  unsent feedback" control clears it. If storage is blocked the form says
  feedback is temporarily unavailable; gameplay and the story are never
  affected. Source of truth: `web/tests/pending-queue.test.ts`.
- **Feedback closed.** Building with `PUBLIC_FEEDBACK_CLOSED=true` replaces
  both forms with "Feedback for this showcase has closed" and clears each
  visitor's queue on their next page load without sending it.
- **The endpoint is external.** Validation, storage, rate limiting and purge
  belong to the MakeBoldSpark API. For development,
  `npm run mock:reactions` (`web/scripts/mock-reactions.mjs`, never built
  into `dist`) runs a contract-validating stand-in on `localhost:8787` whose
  mode (`accept`, `invalid`, `unavailable`) can be switched while it runs and
  whose log shows every accepted body in order. It allows localhost origins
  only.

## Content model

Published story and method content lives in Astro content collections
(`web/src/content.config.ts`), one durable source per fact; pages render from
them and never restate a figure a collection holds. Any schema violation
fails the build.

- `chapters` (`web/src/content/chapters/NN-slug.md`): `title`, `part` (1–9),
  `slug`, `description`, `spoiler`, `status` (`draft` | `published`),
  `sources`, `updated`. Only `published` chapters are built; `/story/` lists
  them in order and `/story/<slug>/` renders each with `ArticleLayout.astro`.
- `beats` (`beats.yaml`): the Built with DevSpark sequence, each with an
  optional belief, the evidence, the next decision, at least one source and
  a `spoiler` flag.
- `journey` (`journey.yaml`): the shared, spoiler-light Journey — what
  changed and what was learned, with an optional chapter link shown only
  when that chapter is published.
- `lessons` (`lessons.yaml`): what worked and what didn't, at comparable
  weight, each item with a source.
- `evidence` (`evidence.yaml`): automated evidence (with the reproducing
  command where a number is derived), the human baseline, what is not
  claimed, and limitations classed as accepted limitation, deferred or not
  performed.
- `facts` (`facts.yaml`): Reference Knot board facts (rendered with the note
  that they describe the board and do not judge it) and the project clock,
  each item with the command that reproduces it, cut off at a named commit.

**Permanent sources.** Every source URL must be a permanent link
(`web/src/lib/content-rules.mjs`): a commit-pinned repository file
(`…/blob/<40-hex>/<path>`), a merged pull request, a commit, or an internal
site path. Durable knowledge and code are linked as commit-pinned
permalinks. Links into the temporary planning area are rejected in any URL
form. Temporary planning evidence may appear in prose only as a short
quotation or paraphrase supported by a link to the commit or pull request
that shows the resulting change. Commit subjects quoted in a chapter's
receipts table have internal planning identifiers replaced by a short
description.

**Play-first notes.** A chapter or beat that discusses how the Reference
Knot was designed is flagged `spoiler`, decided from its final text, and is
shown after `SpoilerGate.astro`, a play-first note with a Play link that
never hides or blocks the content. The board facts on the Built with
DevSpark and Evidence pages sit behind the same note.

**Pre-play vocabulary.** Content reachable before play — the landing page,
the Play page, the Journey and the site chrome — must not use the design
vocabulary listed in `web/src/lib/content-rules.mjs`; the publication check
below enforces it.

## Publication checks

`web/scripts/check-content.mjs`, with its shared rules in
`web/src/lib/content-rules.mjs`:

- **No planning links:** nothing in `web/src`, `web/public` text files or
  `web/dist` contains the temporary planning directory's name.
- **Theme literals:** no raw hex color, no `px` size and no font other than
  the theme tokens (or the two theme family names inside `@font-face`)
  anywhere in `web/src` except `web/src/styles/arrowspark.css`.
- **Content rules:** every source in a published chapter, beat, lesson,
  evidence item and fact is a permanent link; no author placeholder
  survives; every numeric fact has a source, and a command when derived.
  `--fetch-links` requests every external URL once; it runs before
  publication and on a schedule, never on every push.
- **Pre-play words:** a list of internal design vocabulary must not appear,
  whole-word and case-insensitive (plurals included), on any surface a
  visitor reaches before playing: the built landing, Play and Journey pages
  (with their header, footer and desktop-only notice), the game's loading
  shell, the text of `scenes/menus/**/*.tscn` and
  `scenes/loading_screen/**/*.tscn`, and the string literals in
  `scenes/menus/**/*.gd`. Only visible text is scanned (text nodes plus
  `alt`, `title` and `aria-label`).

## Hosting headers, caching and the Content-Security-Policy

The site is hosted on Azure Static Web Apps. `web/staticwebapp.config.json`
is a template; after `astro build`, `web/scripts/build-csp.mjs` writes the
deployed `web/dist/staticwebapp.config.json`:

- **Caching.** HTML gets `Cache-Control: no-cache`. Everything under
  `/game/*` and `/_astro/*` gets `public, max-age=31536000, immutable`, which
  is safe because both paths are unique per build (the game's folder is the
  build id; Astro's assets are content-hashed). A new deploy never serves
  stale engine files.
- **MIME types.** `.wasm` is served as `application/wasm`, `.pck` as
  `application/octet-stream`. Other headers: `X-Content-Type-Options:
  nosniff`, `Referrer-Policy: no-referrer`. No cookies are set.
- **Content-Security-Policy**, every directive explicit: `default-src
  'self'`; `script-src 'self' 'wasm-unsafe-eval'` plus the SHA-256 of the
  game shell's single inline bootstrap script, computed from the exported
  `index.html` at build; `style-src 'self'`; `img-src 'self' data: blob:`
  (`blob:` because the Godot runtime hands generated images, such as its
  window icon, to the browser as blob URLs); `font-src`, `worker-src`,
  `media-src`, `frame-src`, `form-action` and `base-uri 'self'`;
  `connect-src 'self'` plus the origin of `PUBLIC_REACTIONS_URL`, read from
  the same build setting as the reaction client so they cannot drift;
  `object-src 'none'`; `frame-ancestors 'self'`.
- **The build fails** if any built page or the exported game contains an
  inline `<style>`, a `style` attribute, or an inline `<script>` other than
  the shell's one hashed bootstrap. That is why Astro never inlines styles or
  scripts and markdown syntax highlighting (which emits style attributes) is
  off.

The policy is verified on a hosted preview carrying these exact headers,
never inferred from local development.

## Licences

`web/src/pages/licenses.astro` lists every redistributed component and its
licence: the Godot Engine (MIT, with a link to its third-party notices), the
Godot logo shown on the opening screen (CC BY 4.0), Maaack's Game Template
(MIT), Lucide (ISC), Be Vietnam Pro and Inter Tight (SIL OFL 1.1, full texts
served from `web/public/fonts/licenses/`) and Astro (MIT). The footer links
to it.

## Continuous integration and the synthetic check

`.github/workflows/showcase.yml` downloads Godot 4.4-stable and its export
templates from the official release, verifies both against the release's
SHA-512 sums, caches them by version, runs both regression launchers,
validates an editor import on a fresh copy without `.godot`, exports the
game, then runs `npm ci`, `npm audit --audit-level=high`, `npm run check`
and `npm run build` in `web/`.

`web/scripts/synthetic-check.mjs` is one headless-browser visit with no
visitor data: it loads `/` and the story pages, then `/play/`, and waits for
the game iframe's `engineState` to become `started`. It fails on any console
error, page error or Content-Security-Policy violation (reported from every
document, including the iframe). The browser is launched with a software
WebGL backend (Chromium's ANGLE on SwiftShader) and logs the WebGL renderer
it got. If the runner cannot create a WebGL2 context at all, the result is
**inconclusive** (exit code 3, reported as a CI warning naming the cause),
never a failure or an outage. CI runs it against a local preview of each
build, then again against the deployment itself.

**Deployment.** After the build job, the same workflow uploads `web/dist` to
Azure Static Web Apps with the official deploy action (secret
`AZURE_STATIC_WEB_APPS_API_TOKEN_GREEN_BAY_09BDC1010`, the deploy token Azure
created for this Static Web App; `PUBLIC_REACTIONS_URL` comes from a
repository variable). This is the only deploy workflow: the build-less
workflow Azure generates when the app is linked to the repository is
deleted, because it would upload the repository root instead of
`web/dist`. Each same-repository pull request gets a preview
environment, closed when the pull request closes, and `main` deploys
production at `https://arrow.makeboldspark.com`. The synthetic check runs
against every deployment; a failure on a preview blocks the pull request. A
scheduled daily run checks production, but only while the repository
variable `SYNTHETIC_DAILY` is `true` (set for the learning window, then
switched off).
