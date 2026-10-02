---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
classification: full-spec
risk_level: medium
target_workflow: specify-full
required_artifacts: spec, plan, tasks
recommended_next_step: plan
required_gates: checklist, analyze, critic, verify:end-to-end
route_intent: full-spec
depends_on: []
supersedes: []
archetype: game
risk_profile: public
change_type: brownfield
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Feature Specification: ArrowSpark Web Showcase — Try the Game / Built with DevSpark

**Feature Branch**: `011-spec-web-showcase`
**Created**: 2026-10-02
**Status**: Draft <!-- Valid: Draft | In Progress | Complete -->
**Input**: User description: "Create Spec 011: ArrowSpark Web Showcase — Try the Game / Built with DevSpark. Treat the game and the DevSpark methodology as two equal showcase subjects… The visitor should leave with two independent opinions: 'What did I think of the game?' and 'What did I think of the way it was built?'"

> This specification is temporary working state. It remains in `.devspark.work/` until `/devspark.release` archives it, and durable code, tests, knowledge or published site content must never reference it. Pre-spec research, including the required content-source map, is in [showcase-research.md](showcase-research.md) in this bundle.

## Product Owner TLDR

ArrowSpark has one level we believe is good, the Reference Knot. Only the person who designed it has played it. This spec puts a public page in front of real people. The page lets them **play the game** in a desktop browser with no install or account. With equal weight, it lets them **see how the game was built with DevSpark**, told through the project's own evidence: what worked, what failed and what changed our minds. We want two honest answers back from visitors: what they thought of the game, and what they thought of the way it was built. Success means getting those answers and recording them as given, even if they are negative. A browser build alone is not success.

## Clarifications

### Session 2026-10-02

- Q: Where should the showcase be hosted? → A: A static site at `arrow.makeboldspark.com` (FR-024).
- Q: Where do anonymous reactions go? → A: One small anonymous public endpoint on the existing Make Bold API platform (FR-017, External Contracts).
- Q: How do objective results reach a reaction? → A: The game hands a completed attempt's results to the page, one way, with no identifier (FR-019).

## Rationale Summary

### Core Problem

Every human observation of ArrowSpark so far comes from one person, the designer, who knew the designs. The Spec 010 fresh-player check (does a first-time player find and enjoy the intended level unaided?) was deferred because no fresh players existed. Separately, the DevSpark story of how the game was made exists only as internal drafts that are partly stale and full of design vocabulary that would spoil a first play. The game is not reachable without installing a desktop build, and the story is not reachable at all.

### Decision Summary

Build one lightweight public showcase with a shared landing page and two equal paths, Try the Game and Built with DevSpark, that rejoin at a short development journey. Ship the existing Reference Knot unchanged as a desktop-browser build. Carry the Spec 010 fresh-player protocol forward as observed sessions. Add a minimal anonymous reaction channel for unobserved visitors. Build the story from the existing article series and development documents rather than writing it from scratch. The approved theme and technical direction are fixed constraints, not planning questions (see Technical Constraints / Implementation Direction):
- the supplied Make Bold theme is the visual foundation;
- a static-first Astro + TypeScript site on Azure Static Web Apps at `arrow.makeboldspark.com`;
- durable Markdown/MDX story content;
- the existing Godot project exported for the Web;
- a one-way `attemptCompleted` hand-off;
- one narrow reaction endpoint on the existing MakeBoldSpark API, appending JSON Lines.

### Key Drivers

- The project's central risk is a one-person evidence base (current-state report, Spec 010 closeout).
- The Spec 010 deferral of fresh-player validation names this spec as its home.
- The showcase is also the DevSpark case study: the method claims "evidence changes the next decision", and this is how it collects evidence from people other than the designer.
- Most story content already exists (series chapters 1-8, development docs 01-14). The work is selection, refresh and spoiler control, not authorship from scratch.

### Source Inputs

- [showcase-research.md](showcase-research.md): answers to the 15 required research questions, the content-source map, the cleanup classification and the contradictions found.
- `.devspark.work/development/*`, especially `14-showcase-story-plan.md`, `08-current-state.md`, `02-product-philosophy.md`, `12-devspark-lessons.md` and the `arrowspark-series/` chapters 00-08.
- `.devspark.work/specs/010-spec-reference-puzzle/deferred-to-next-spec.md` (inherited fresh-player protocol).
- `ArrowSpark mockup with DevSpark theme.zip` (in this bundle): the Make Bold Solutions design system (tokens, fonts, peak mark, component contracts) and an ArrowSpark showcase mockup. Analysed in showcase-research.md §16.
- MakeBoldSpark.com API conventions (feature-scoped `/api/public/<feature>` groups, per-feature single-origin CORS policies, in-memory fixed-window rate limiting, error filters that never log submitted text).
- `.knowledge/product/gameplay-contract.md`, `.knowledge/product/branding.md`, `.knowledge/reference/reference-puzzle-design-report.md`, `.knowledge/reference/gordian-knot-experiments.md`, `.knowledge/governance/constitution.md` (2.0.1).

### External Contracts

- **MakeBoldSpark.com API (owning repo: `MakeBoldSolutions/MakeBoldSpark.com`):** one new anonymous endpoint, `POST /api/public/arrowspark/reactions`. The exact segment follows that repo's conventions and is confirmed in plan. The request schema, allowed values, limits and responses are fixed by FR-026, and the stored record by FR-031. It sets no cookie, issues no identifier, returns no record id, and keeps no network address or similar correlation data in the stored record (FR-018).
  - Drift policy: if that endpoint's shape changes, treat it as breaking and re-run analyze and critic before merge.
- **Azure Static Web Apps at `arrow.makeboldspark.com`:** static hosting for the Astro build and the Godot Web export (FR-024). The DNS, custom domain and hosting configuration are owned outside this repository.
- **Game → page event contract (internal, but crosses two authorities):** `attemptCompleted`, version 1 (FR-019). It is changed only together with the page bridge.

### Tradeoffs Considered

- **Play-first home page** (`14-showcase-story-plan.md`): rejected. It makes DevSpark secondary, which conflicts with equal billing. Its protective intent survives as spoiler notes on design-discussing pages.
- **One long combined page:** rejected. Players would scroll past design vocabulary before playing, and developers would have to wade through instructions.
- **Two separate sites:** rejected. The point is that the game and the method are one story, and two sites would make one of them feel bolted on.
- **Mobile/touch support now:** rejected for the first release. There is no intentional touch model, and relying on mouse emulation would be pretending.
- **A full SPA, or React / Next.js / Blazor:** rejected. The site is editorial with a few interactive islands. The theme's React components are small enough to re-express as Astro components.
- **A database or CMS for articles:** rejected. Markdown/MDX content collections are enough and stay reviewable in Git.
- **A new feedback service or database:** rejected. One endpoint on the existing API, with append-only JSON Lines.
- **Selected:** one site, shared landing page, two equal paths that rejoin; desktop-browser-first; the existing game unchanged except for honest labels, corrected text and the completion hand-off. Built with Astro + TypeScript on the Make Bold theme.

### Architectural Impact

- Adds a browser build of the existing game and a small public site around it. The puzzle rules, scoring, solver, analyzer, catalog groups and session boundary are unchanged.
- The game gains only: corrected menu text; one honest description line per Level Select group; and a one-way hand-off of a *completed* attempt's results to the hosting page (FR-019).
- Published story content becomes durable site content. It must stand alone after the working documents are archived.
- Three separate authorities (FR-030): **Astro** owns the site shell and content; **Godot** owns gameplay; the **MakeBoldSpark API** owns validating and storing a reaction. No layer duplicates another's authority.
- **New technology in this repository:** an Astro/TypeScript site and its Node build. The constitution's Technology section lists only Godot, GDScript and Python tooling, so a constitution amendment is a Prerequisite (see Technical Constraints).
- No new persistence, identity or tracking. The only new stored data is anonymous reaction records in the existing API's storage.

### Reviewer Guidance

Check five things:
1. Equal billing is real on the landing page, not just claimed.
2. No design vocabulary appears anywhere a visitor passes before first play.
3. Every factual claim in the story can be traced to repository evidence.
4. Failures and limitations are stated as plainly as successes.
5. The application and its data model do not identify or track anyone, the endpoint is bounded (FR-026), and the game works when feedback or the hand-off is unavailable.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A fresh player plays the Reference Knot from a link (Priority: P1)

Someone who has never heard of ArrowSpark opens the showcase on a desktop or laptop browser, chooses to play, and is playing within moments: no install, no account, no tutorial about what to look for. They untangle as much of the Reference Knot as they want, using zoom, pan, Fit Puzzle and Open Move if they choose. They can finish, or leave whenever they like.

**Why this priority**: This is the only way to get evidence from anyone other than the designer, which is the project's central open question.

**Independent Test**: Give the link to someone who has never seen the game, say only "Here's a puzzle game", and observe whether they can start and engage with the Reference Knot without help.

**Acceptance Scenarios**:

1. **Given** a visitor on a supported desktop browser, **When** they choose to play from the landing page, **Then** the game loads with visible progress and they reach the Reference Knot through Play without installing or signing in to anything.
2. **Given** the Reference Knot in the browser, **When** the player selects, zooms, pans, fits, uses Open Move, makes blocked selections and completes, **Then** every behavior matches the desktop game: same rules, same score formula, mistakes never stop play, no fail state.
3. **Given** a visitor arriving on the landing page or the Play page, **When** they read everything shown before first play, **Then** none of the internal design vocabulary appears (neighborhood, bridge arrow, insight chain, discovery beat, major release, meaningful density, spaghetti boundary, zone) and nothing hints at what the level contains.
4. **Given** the player reloads or closes the page, **When** they return, **Then** gameplay scores start fresh, and the Play page told them this beforehand.

---

### User Story 2 - A developer understands how it was built without playing first (Priority: P1)

Someone interested in spec-driven or AI-assisted development opens the showcase and goes straight to Built with DevSpark. In a few minutes they understand what DevSpark is, see how it shaped ArrowSpark through concrete moments where evidence changed the next decision, read what worked and what didn't, and can check the evidence themselves. They are invited to play, but not forced to.

**Why this priority**: Equal billing. The method is a showcase subject, not a footnote to the game.

**Independent Test**: Ask a developer unfamiliar with DevSpark to read only the Built with DevSpark path, then explain in their own words what the method is, one place it helped and one place it failed.

**Acceptance Scenarios**:

1. **Given** the landing page, **When** a visitor chooses Built with DevSpark, **Then** they reach a method overview explained through ArrowSpark events, not as an abstract framework description.
2. **Given** the method path, **When** the visitor reads the development journey, **Then** each step shows what was believed, what evidence arrived and what decision followed, ending with the open question only outside players can answer.
3. **Given** the What Worked and What Didn't sections, **When** a skeptical visitor reads them, **Then** failures are concrete and unsanitized: the playtest that rated engineered puzzles 2/5, a success criterion failed against its original wording and amended in the open, a deferred check, leaked planning references found by audit, verification tooling that became scope and was removed, and a one-person evidence base.
4. **Given** any factual claim on the method path (a date, count, result or quotation), **When** the visitor follows its evidence link, **Then** it leads to a permanent, checkable source in the public repository or a published chapter.
5. **Given** a page that discusses the Reference Knot's design, **When** a visitor opens it, **Then** a short note invites them to play first, without blocking them from reading.

---

### User Story 3 - Visitors leave short, anonymous reactions (Priority: P2)

After playing, a player can say in under a minute how satisfying it was, whether they would play another, whether they read the story first, and what they noticed in their own words. After the story, a reader can say whether it made sense and whether they'd use a process like it. Nobody has to identify themselves, and nothing follows them.

**Why this priority**: Unobserved visitors are the larger audience. Without a reaction path, their experience is lost. It is P2 because observed sessions (Story 4) remain the stronger evidence.

**Independent Test**: Submit both reactions from a fresh browser session, confirm they arrive with no identifying information, then make the channel unavailable and confirm the game and site still work.

**Acceptance Scenarios**:

1. **Given** a player who has played, **When** they open What did you notice?, **Then** they see no more than five short questions, all optional, including whether they read the story before playing.
2. **Given** a story reader, **When** they reach the end of the method path, **Then** they are offered no more than four short, optional questions.
3. **Given** the feedback channel is unreachable, **When** a visitor plays or submits, **Then** gameplay is unaffected and the visitor sees a plain message that the reaction wasn't sent.
4. **Given** any submission, **When** it is stored, **Then** the stored record contains no account, persistent visitor id, cross-session id, advertising id, tracking-cookie value, network address or similar correlation data, and the application makes no attempt to link it to any other submission.

---

### User Story 4 - The owner runs observed fresh-player sessions (Priority: P2)

The owner sends the link to people who have never seen the game or its design documents and observes them play under the inherited protocol: minimal guidance, no coaching, observe first, then interview one question at a time. Answers are recorded as given, including negative ones.

**Why this priority**: Only observed sessions can answer the discovery questions honestly, including whether the player finds the ArrowSpark Levels group (Spec 010's deferred SC-009).

**Independent Test**: Run one session with a genuinely new player using only the facilitator script, then check that the record contains the player's own words for each checklist question and notes any facilitator influence.

**Acceptance Scenarios**:

1. **Given** a new participant, **When** the session starts, **Then** the facilitator says only that it is a puzzle game, and does not explain controls beyond the on-page instructions, groups, Level Select or what to look for.
2. **Given** play has ended, **When** the facilitator interviews, **Then** questions come one at a time, the facilitator owns the checklist, and the participant is never handed a form to complete.
3. **Given** a session record, **When** reviewed, **Then** it states whether the participant had seen the story first, which entry they started with, whether and when they opened Level Select, and anything the facilitator did that could have guided them.

---

### User Story 5 - The public baseline tells the truth (Priority: P3)

Before the showcase goes public, the player-visible text and durable project knowledge it cites agree with the actual game. The showcase can then honestly claim that code, tests and knowledge agree.

**Why this priority**: The DevSpark half's credibility depends on it, but it is small, bounded work.

**Independent Test**: Compare every player-visible string on the menus touched by the showcase, and every durable knowledge statement the Evidence page cites, against the shipped behavior.

**Acceptance Scenarios**:

1. **Given** the main menu, **When** a player hovers or focuses Play, **Then** its help text describes what Play actually does.
2. **Given** the Evidence page cites solver validation, **When** a reader checks the durable description, **Then** it states accurately which boards are checked exhaustively and which are sampled.

---

### Edge Cases

- **Touch-primary device or very small window:** the site says plainly that the game is designed for desktop browsers. The story pages remain fully readable on phones. The game is not presented as supported on touch.
- **Unsupported or outdated browser:** a clear message names what's supported, instead of a blank or broken frame.
- **Slow connection:** loading shows progress. A visitor can read the story while the game loads, or instead of playing.
- **Audio blocked until interaction:** no error, stall or hidden prompt. Sound starts only after the visitor's first interaction.
- **Keyboard focus:** game shortcuts work once the visitor has clicked into the game, and the instructions say so. Leaving the game area with the keyboard stays possible.
- **Browser zoom gestures:** a trackpad pinch or ctrl+wheel over the game must not unexpectedly zoom the whole page instead of the board.
- **Window resize mid-attempt:** no attempt reset, score change or broken departure. This matches the desktop resize guarantees.
- **Player reaches results but never opens feedback:** nothing nags them. One unobtrusive offer is enough.
- **Visitor submits a reaction twice:** both are accepted as independent observations, within the rate limit (FR-026). There is no de-duplication by identity.
- **Malformed, oversized or off-origin submission:** rejected by the endpoint with a plain error. Nothing is stored, and the visitor's play is unaffected.
- **Hand-off ignored or failing:** the game plays and completes normally. The reaction is sent without attempt data, or not at all.
- **A story visitor plays afterwards and gives a game reaction:** the "read the story first" answer marks it as primed evidence.
- **Recruitment stalls:** the spec still closes at the end of the fixed learning window, with whatever evidence exists, stated as such. The window is not extended automatically (FR-020).
- **One participant, several criteria:** allowed when the session follows the order in FR-020, so first contact comes before any exposure to the story.

## Requirements *(mandatory)*

### Functional Requirements

**Showcase structure and equal billing**

- **FR-001**: The showcase MUST open on a shared landing page that presents **Try the Game** and **Built with DevSpark** as two primary entry points of equal conceptual weight, so that neither appears visually or semantically secondary. Identical dimensions are not required; the design may vary layout as long as neither path reads as the lesser one. The page carries a one-sentence framing that invites the visitor to judge both the game and the process. Final wording is chosen from existing material (see research §5) during planning.
- **FR-002**: The two paths MUST rejoin at a short, spoiler-light Journey: a numbered chronology of milestones, each with what changed and what was learned, readable by both audiences. The paths and each path MUST offer the other at its natural end ("See how it was built" after play; "Now play it" after the story).
- **FR-003**: A visitor MUST be able to understand the method path without playing, and to play without reading anything beyond the short instructions.

**Try the Game**

- **FR-004**: The showcase MUST provide a desktop-browser build of the current game in which Play starts the Reference Knot, playable end to end with no install, account or login, and behaviorally identical to the desktop game: same rules, scoring formula, Open Move behavior and cost, zoom/pan/Fit, Back, session-only scoring, no lives and no fail state.
- **FR-005**: No content shown before first play MUST contain the internal design vocabulary or describe what the Reference Knot contains. That covers the landing page, Play page instructions, loading screen and game menus. Instructions MAY describe only the controls, the basic rule (an arrow leaves if its path is clear), that mistakes cost score but never stop play, and what Open Move does and costs.
- **FR-006**: Level Select MUST remain reachable and show all three groups, each with one honest line describing its purpose. Puzzle Lab MUST be described as development experiments, some deliberately over-tangled. No group label may imply a quality ranking.
- **FR-007**: The Play page MUST state that the game is designed for desktop browsers with mouse or trackpad and keyboard. On touch-primary or undersized screens it MUST say the game is not yet supported there, rather than presenting it as playable, and offer the story instead. Any "play it later on a desktop" affordance MUST NOT collect an email address or other contact detail. Copying the link, or opening the visitor's own mail app, is acceptable.
- **FR-008**: The Play page MUST tell the visitor that scores last only for the visit and a reload starts fresh. Nothing the game stores locally in the browser may be transmitted anywhere.
- **FR-009**: Each puzzle MUST have a **puzzle content version**: an identifier of its geometry (board size, arrows, directions and tails) that changes if and only if that geometry changes. It is separate from the application version, which may change without changing any puzzle. The Reference Knot's content version MUST be fixed for the life of the showcase and checked automatically, so a geometry change cannot go unnoticed. Every observed session record and every submitted completed-attempt reaction MUST name the puzzle content version it refers to.

**Built with DevSpark**

- **FR-010**: The method path MUST explain DevSpark through ArrowSpark events, covering at minimum:
  - specs as temporary contracts, with durable truth in code, tests and knowledge;
  - adversarial review before code;
  - human evidence overturning metrics;
  - measuring before automating (no generator yet);
  - verification without pretending (unperformed checks stay unperformed);
  - the process changing its own assumptions (the amended success criterion with its original kept visible);
  - verification accidentally creating scope (the developer readout added and removed);
  - convergence (a spec is complete when its objective is resolved);
  - review finding real defects after everything was green (the hidden-focus bug and stale durable knowledge).
- **FR-011**: The Built with DevSpark path MUST present the method as a sequence of evidence beats, each "Belief → Evidence → Next decision", from first playable to the outside-player question (research §4). The shared Journey (FR-002) covers the same arc as chronology. Neither may be a list of features or specs.
- **FR-012**: The method path MUST include What Worked and What Didn't sections of comparable weight, with concrete, sourced examples. It MUST state the evidence limits plainly: one tester who designed the level; no independent player before this showcase; the Web-readiness gate (three keeper puzzles and an outside tester) not met.
- **FR-013**: Every factual claim on the method path (dates, durations, counts, results, quotations) MUST link to a permanent source that will still resolve after working documents are archived: a published chapter, or a commit-pinned location in the public repository. Published content MUST NOT depend on working-document paths.
- **FR-014**: Wall-clock and effort figures MUST appear with the caveats already established: elapsed time is not effort; commit-bracketed time is a floor; no speed-up multiple without the author's own baseline. The commands that reproduce each figure MUST be shown.
- **FR-015**: The story MUST be built from the existing chapters and development documents per the content-source map, refreshed so no published figure contradicts the repository. Chapter 7 is split and the closing chapter written as planned in `14-showcase-story-plan.md`. Existing wording MUST be reused where it is accurate. Internal planning material MUST NOT be published merely because it exists.
- **FR-016**: Pages that discuss the Reference Knot's design MUST carry a short play-first note that does not block reading.

**Feedback and evidence**

- **FR-017**: The showcase MUST offer an optional game reaction (at most five questions, including "did you read how it was built before playing?" and an optional free-text "what did you notice?") and an optional story reaction (at most four questions, including an optional free-text comment), delivered to the single reaction endpoint on the existing MakeBoldSpark API (FR-026). The game reaction's free text is labeled "What did you notice?" and carried as `comment`.
- **FR-018**: The showcase application and its reaction data model MUST:
  - require no login or account;
  - create, set or read no persistent visitor id, cross-session id, tracking cookie or advertising id, and perform no intentional fingerprinting;
  - make no attempt to correlate separate submissions with each other;
  - not intentionally retain a network address or similar correlation data in the stored reaction record;
  - treat each submission as an independent observation;
  - never block or degrade gameplay when feedback is unavailable.

  This guarantee covers the application and its data model. It does not claim that hosting or network infrastructure outside the application keeps no metadata of its own, such as transient request logs; the Play page's privacy note says so in plain words.
- **FR-019**: Completion hand-off, a one-way contract from **game → hosting page**:
  - **When:** only on completion of an attempt during the current page visit. If several attempts are completed, the page keeps only the most recent.
  - **Carries exactly** one `attemptCompleted` event (contract version 1) with: `puzzleId`, `puzzleVersion` (the puzzle content version, FR-009), `mistakes`, `openMoveAssists`, `score` and `elapsedSeconds`. `elapsedSeconds` is whole wall-clock seconds from the attempt's start to its completion, pauses included. Plan may refine this definition once, before implementation.
  - **Mechanism:** the supported way for the Godot Web build to emit this event to the hosting page is a Phase 0 research decision. A small TypeScript bridge on the Play page receives it, checks its shape, and holds it in page-local memory only.
  - **Never carries:** a player, visitor, session or device identifier, or any data about unfinished attempts. There is no telemetry of play in progress; an unfinished attempt is reported only through the visitor's own "did you finish?" answer.
  - **Direction:** the page sends nothing to the game, and the game never waits for, reads or depends on the page.
  - **Failure:** gameplay MUST remain fully functional, with identical rules, scoring and results, if the hand-off is ignored, unavailable or fails.
  - **Use:** the page attaches the data to that visit's game reaction only if the visitor submits one. The player is never asked to transcribe numbers.
- **FR-020**: The owner MUST run observed fresh-player sessions using the inherited protocol and a facilitator checklist covering the questions in research §13, including the deferred Level Select discovery check. Each session MUST be recorded with the participant's words as given and any facilitator influence noted.
  - **Participant reuse:** the same participant MAY supply evidence for several human-evidence criteria (SC-002, SC-007, SC-008, SC-011) in one session, provided the order preserves first contact: landing-page impression → fresh play → fresh-play interview → Built with DevSpark → DevSpark comprehension and reaction. Separate people are not required merely because the criteria are separate. A participant who sees the story before playing counts for SC-011 but not for SC-007.
  - **Learning window:** the window is 14 days. It starts on the date the public showcase is actually published and reachable at `arrow.makeboldspark.com`, not on the date the spec or build is finished. The start and end dates are recorded.
  - **No automatic extension:** at the window's close, the spec reports whatever evidence exists, as it stands. A recruiting shortfall is recorded as an Accepted Limitation and does not extend the window or the spec.
- **FR-021**: Results MUST be reported in the spec's closeout as evidence tiers that are never merged:
  - observed sessions;
  - unobserved reactions, first-contact;
  - unobserved reactions, read the story first.
  Negative results are recorded as findings, not defects to fix within this spec.

**Truthful baseline and platform**

- **FR-022**: Before publication, the player-visible Play help text and the durable knowledge the Evidence page relies on MUST match shipped behavior (research §7 prerequisites): the Play target, the sampled order-independence check for the densest board, the current catalog size and the Back button's place in the tab order.
- **FR-023**: One engine version MUST be pinned before implementation begins. The web export, the headless regression gates (local and CI) and the documented reproducible build steps MUST all use that same version. The declared 4.4 target is preserved unless Phase 0 web-export research finds a concrete reason to change it. If it changes, the change is an explicit **Prerequisite**, with its own task, regression run and constitution Technology update, completed before showcase implementation. It is never an incidental implementation choice. The existing headless regression gates MUST stay green.
- **FR-024**: The showcase MUST be hosted on **Azure Static Web Apps** at `https://arrow.makeboldspark.com`, under the Make Bold Spark domain that branding names as the public destination. It MUST be reachable by that public link with no sign-in. It stays static-first: no server-side rendering and no site-side server functions unless a concrete requirement appears. The reaction endpoint lives on the existing API, not in the static host.
- **FR-025**: A browser smoke test MUST be run and recorded on three current desktop browsers: a **Chromium-based desktop browser**, **Firefox desktop** and **Safari on macOS**. Safari can only be validated on a Mac. If no Mac is available, Safari is recorded as not performed and published as an untested browser, never inferred from another browser. It covers load, Play to Reference Knot, select, blocked selection, zoom (wheel and trackpad), pan, Fit, Open Move, Back, completion, results, Replay, Level Select, resize, keyboard focus and audio start. It also includes one measured play of the Reference Knot recording load time, transferred size and whether long departures and panning stay smooth. Any check not performed MUST be recorded as not performed.

**Feedback endpoint safety**

- **FR-026**: The reaction endpoint, `POST /api/public/arrowspark/reactions` on the existing MakeBoldSpark API, MUST be bounded as follows. It serves only ArrowSpark showcase reactions. Plan records the final field names in External Contracts and may rename to match the API's conventions, but may not add fields.
  - **Exact request schema** (JSON). Exactly two reaction types, each with only these properties; any other property is rejected. Every answer property is optional.
    - *Game reaction:* `reactionType` = `game`; `readStoryFirst` ∈ {`yes`, `no`}; `finished` ∈ {`finished`, `partway`, `notStarted`}; `satisfaction` ∈ {1, 2, 3, 4, 5}; `playAnother` ∈ {`yes`, `maybe`, `no`}; `comment` (free text); optional `attempt`, present only from the FR-019 hand-off, containing exactly `puzzleId` and `puzzleVersion` (each at most 64 characters of lowercase letters, digits, underscore and hyphen), `mistakes`, `openMoveAssists` and `score` (whole numbers, 0 to 10,000) and `elapsedSeconds` (whole number, 0 to 86,400). The endpoint validates format and range only and holds no copy of the catalog. Matching against published puzzle ids and content versions happens when results are analyzed.
    - *Story reaction:* `reactionType` = `story`; `madeSense` ∈ {`yes`, `partly`, `no`}; `changedView` ∈ {`moreInterested`, `noChange`, `lessInterested`}; `wouldUse` ∈ {`yes`, `maybe`, `no`}; `comment` (free text).
  - **Responses:** `202 Accepted` with no body and no record id on success; a validation problem for invalid input; payload-too-large, unsupported-media-type and too-many-requests responses where those apply. No response reveals anything about other submissions.
  - **Free-text limit:** each free-text field holds at most 1,000 characters. The whole request is limited to a small fixed size, about 4 KB.
  - **Server-side validation:** reject unknown fields, missing or unknown `kind`, values outside the allowed sets or ranges, over-length text and oversized requests. Rejected requests store nothing. Client-side checks are a convenience, never the guarantee.
  - **Safe text handling:** free text is stored as plain text and treated as untrusted. Wherever it is later displayed it is escaped, never rendered as markup or followed as a link.
  - **Origin policy:** a feature-specific CORS policy allows only the `https://arrow.makeboldspark.com` origin, with the POST method and the JSON content-type header. Explicit development origins are allowed only through configuration that rejects wildcards. This follows the API's existing per-feature policy pattern.
  - **Abuse limiting:** a fixed-window per-source rate limit, using the API's existing in-memory limiter pattern, rejects bursts. Source information used for limiting is held only transiently in memory and is never written to the reaction record (FR-018).
  - **Error logging:** failures are logged by exception type and trace id only, never with submitted text, matching the API's existing filter pattern. Responses carry `Cache-Control: no-store`.
  - **Stored record:** defined by FR-031.
  - **Failure isolation:** endpoint failure, rejection, slowness or absence never affects gameplay or the story pages. The visitor sees a plain "not sent" message.

**Theme, stack and storage**

- **FR-027**: **Visual foundation.** The showcase MUST use the supplied Make Bold theme as its visual and branding foundation. Typography (Be Vietnam Pro display, Inter Tight body), palette (rust, ember, ink, cream and their ramps), spacing scale, navigation language, button treatment, content surfaces (white cards on cream, hairline warm borders, low-spread warm shadows, modest radii) and general visual restraint MUST remain recognizably part of the Make Bold family.
  - The showcase MAY extend the theme for the embedded game frame, the evidence beats, the Journey, evidence displays and article presentation, but it MUST NOT introduce a competing visual design system.
  - ArrowSpark's own language is preserved: warm neutral and cream surfaces, dark ink, restrained ember/rust accents. Error red (the theme's critical tone) appears only in invalid, blocked or error contexts.
  - The theme's accessibility patterns are kept: visible ember focus outline, readable contrast on cream, and quick motion with no bounce, reduced under the visitor's reduced-motion preference.
  - It MUST avoid neon or gamer aesthetics, glassmorphism, gratuitous gradients, glowing controls, pixel fonts, sci-fi HUD styling, generic AI/robot imagery, emoji, and Unicode dingbats used as icons.
  - The target is *a Make Bold property that contains a puzzle game*, not a game-marketing site wearing a Make Bold logo.
- **FR-028**: **Static-first site.** The public site MUST be a static-first Astro + TypeScript build: an editorial site with a small number of interactive islands (the game host and bridge, the reaction forms, the spoiler reveal, the desktop-only notice). It MUST NOT be built as a full SPA, and MUST NOT introduce React, Next.js, Blazor or another application framework, or a second major CSS framework, unless Phase 0 records a concrete blocker.
- **FR-029**: **Durable story content.** Published chapters and editorial material MUST be durable Markdown/MDX files in Astro content collections inside the site source, refreshed from the working corpus per showcase-research.md. `.devspark.work/development/*` remains the working editorial source. Published pages and their build MUST NOT read, import or link to any `.devspark.work/*` path.
- **FR-030**: **Separate authorities.** Responsibilities MUST stay separate:
  - **Astro** owns the site shell, landing page, navigation, content, Journey, evidence, article publication, reaction UI and the game host page;
  - **Godot** owns gameplay, rules, score, puzzle state, session best and results;
  - **the MakeBoldSpark API** owns validating and storing a reaction.
  The site never recomputes scores or rules. The game never renders site content or calls the API. The API never interprets gameplay.
- **FR-031**: **Reaction storage.** Each accepted reaction MUST be stored as one independent record, appended to a JSON Lines file (for example `arrowspark-reactions.jsonl`) in the API's existing persistent storage, with a single-writer guarantee. A record holds only:
  - `schemaVersion`;
  - a server-generated UTC timestamp, truncated to the minute;
  - an internal random `recordId` used only for integrity and operations, never returned, never derived from request data and never used to correlate visitors;
  - the validated reaction fields.

  If Phase 0 finds that file-based appends are unsafe in the existing hosting model (for example more than one running instance, or no persistent storage), the smallest storage mechanism already present in MakeBoldSpark infrastructure is used instead. No new database or data platform is introduced. Reactions have no public read path, dashboard or export feature. The owner reads the file directly for the closeout.
- **FR-032**: **Feedback unavailable.** If submission fails, the page MUST tell the visitor plainly that the reaction was not sent, for example "Feedback is temporarily unavailable." Gameplay and story stay fully functional. Plan chooses between:
  - **the minimum fallback**, that message only (recommended in research §16);
  - **a small local pending copy**: only the unsent payload kept in the visitor's browser and clearly marked not yet submitted, with no identifier, never used for tracking, removed after a successful send, and retried only at a bounded moment (the next submission or the next page load).

  Background sync, service workers for retry, retry timers, offline analytics and queue infrastructure are excluded.
- **FR-033**: **No new identity or platform infrastructure.** Spec 011 MUST NOT add authentication, accounts, visitor identity, cross-session tracking, an analytics platform, a dashboard, a generic survey engine, a CMS, or a database for articles or reactions beyond FR-031's fallback rule.

### Technical Constraints / Implementation Direction

These choices are approved and are **not** re-evaluated in planning. Phase 0 confirms the details marked *Phase 0* and records any concrete blocker as a finding.

| Area | Direction | Phase 0 confirms |
|---|---|---|
| Site | Astro + TypeScript, static output; interactive islands only where needed | Astro version; island list |
| Styling | The supplied theme's token CSS reused as-is; components re-expressed as Astro components against the theme's prop contracts (Button, Card, Badge, Eyebrow, Input) | Which mockup pieces become components |
| Fonts and icons | The theme's Be Vietnam Pro and Inter Tight files self-hosted with their OFL notices; outline icons from the theme's chosen set, pinned, never from a moving CDN version | Font format/subsetting |
| Content | Markdown/MDX in content collections with typed frontmatter | Collection schemas |
| Game | Existing Godot project, Web export, engine version per FR-023 (4.4 unless blocked) | Embedding method (iframe or direct), export options, Godot-to-page mechanism |
| Game/page boundary | One-way `attemptCompleted` (FR-019) → TypeScript bridge → page-local state → optional reaction | The exact mechanism |
| Hosting | Azure Static Web Apps, `arrow.makeboldspark.com` | Headers, caching and content types for the engine files |
| Feedback | Existing MakeBoldSpark API, one endpoint (FR-026), JSON Lines (FR-031) | Route segment; single-instance storage safety |
| Responsive | Story pages for desktop, tablet and phone; the game is desktop-browser-first with an honest notice elsewhere | Breakpoint for the notice |

**Prerequisites before implementation** (only these expand the spec):
1. **Constitution amendment (Technology):** add the Astro/TypeScript site and its Node build, and extend Principle V's verification to the browser platform. MINOR version, done through the constitution workflow before site work begins.
2. **Pinned engine version** per FR-023.
3. **Truthful baseline** per FR-022.
4. **Durable theme copy:** the theme ZIP lives in this temporary bundle. Its tokens, fonts, licenses and peak mark are copied into the site source, and the site never references the ZIP.

### Scope Control

The convergence rule from Spec 010 applies to this spec. Every finding raised during planning, gates, implementation or verification is classified as a **Blocking Defect**, **Prerequisite**, **Accepted Limitation**, **Deferred Work** or **Learning / Changed Assumption**. Only Blocking Defects and true Prerequisites expand this spec. A cleanup observation becomes a requirement only if it materially affects public truth, privacy, browser play or one of the two showcase paths; otherwise it is recorded and deferred. Negative learning answers are outcomes, not defects. This spec is complete when its delivery criteria are met and the learning window has closed, not when every observation has been eliminated.

### Key Entities

- **Showcase path**: one of the two equal entry routes (Try the Game, Built with DevSpark). Both rejoin at the Journey.
- **Journey step**: a belief, the evidence that arrived and the decision that followed, with a permanent source link.
- **Published chapter**: a durable, self-contained copy of a story chapter, refreshed against the repository and spoiler-noted if it discusses level design.
- **Game reaction**: one anonymous, independent observation. Optional answers, a first-contact flag and, if the visitor completed an attempt during the visit, that attempt's hand-off data (FR-019).
- **Completion hand-off**: the one-way, identifier-free record a completed attempt sends to the hosting page.
- **Story reaction**: one anonymous, independent observation about the method story.
- **Observed session record**: the facilitator's record of one participant: the order of the session, landing impression, checklist answers in the participant's words, discovery observations, facilitator influence, objective attempt data with the puzzle content version, whether the story was seen first, and any DevSpark comprehension answers.
- **Puzzle content version**: the identity of a puzzle's geometry, independent of the application version. The Reference Knot's value is fixed for the showcase, and all evidence refers to it.

## Success Criteria *(mandatory)*

Applying the Spec 010 lesson, criteria are split. **Delivery criteria** (SC-001 to SC-006) gate completion. **Learning criteria** (SC-007 to SC-011) gate only that evidence was gathered within the fixed window and reported honestly. Their *answers* may be positive or negative, and a negative answer is a valid outcome that never blocks completion. A recruiting shortfall at the end of the window is an Accepted Limitation and does not extend the spec. One participant may serve several human-evidence criteria under the sequencing rule in FR-020.

### Measurable Outcomes

**Delivery: showcase**

- **SC-001**: A first-time visitor on a supported desktop browser can go from the landing page to an interactive Reference Knot in under 30 seconds on a typical home broadband connection, with no install or sign-in. Load time and transferred size are measured and recorded.
- **SC-002**: Three people who were not involved in building the site each look at the landing page and independently say that neither Try the Game nor Built with DevSpark appears visually or semantically secondary. Observed-session participants may supply this as their first step (FR-020).
- **SC-003**: Zero instances of the internal design vocabulary, and zero descriptions of the Reference Knot's contents, appear on any surface a visitor passes before first play (checked by a word-list review of the landing page, Play page, loading screen and game menus).
- **SC-004**: 100% of factual claims on the method path link to a permanent source that resolves. They are checked by following every link once at publication, and once after a simulated archive of the working documents.
- **SC-005**: The browser smoke test (FR-025) is recorded for a Chromium-based desktop browser, Firefox desktop and Safari on macOS, with every check marked passed, failed or not performed. Safari not performed for lack of a Mac is allowed only as a disclosed limitation. No failed check that affects play remains open at publication.
- **SC-006**: Gameplay is unaffected when feedback is unavailable (shown by playing the Reference Knot to completion with the channel disabled), and inspection of stored reactions finds only the FR-031 record fields: no visitor identifier, network address or other correlation data.

**Learning: game half** (answers are evidence; any answer is acceptable)

- **SC-007**: At least 3 observed sessions with genuinely new players (who, before the session, had not seen the game, the story or the design documents) are recorded under the protocol within the learning window, each with the participant's own words for the facilitator checklist. If fewer than 3 occur, the shortfall is reported as an Accepted Limitation, not hidden, and the window is not extended.
- **SC-008**: For every observed session, the record states whether the participant started without guidance, engaged meaningfully (finished, or played at least 10 minutes), used Open Move and understood its cost, and found the ArrowSpark Levels group in Level Select unaided, and how long that took. It also names the puzzle content version played.
- **SC-009**: Game reactions are reported in the three evidence tiers (FR-021), and free-text "what did you notice?" answers are quoted as given, including negative ones.

**Learning: DevSpark half** (answers are evidence; any answer is acceptable)

- **SC-010**: Story reactions report the share of visitors answering yes / partly / no to "did the story make sense?" and "would you use a process like this?". Free-text comments are quoted as given.
- **SC-011**: At least 2 people who were unfamiliar with DevSpark before the session, after reading the method path, are asked to say in their own words what DevSpark is, one place it helped and one place it failed or got in the way. Their answers are recorded verbatim, and where they matched or missed the story's intent is noted. Observed-session participants who played first qualify (FR-020 sequence).

- **SC-013**: The site passes a theme-adherence review. Outside the theme's token files and documented extensions there are no raw color values and no fonts other than the theme's two. Two of the three SC-002 reviewers independently describe the site as recognizably Make Bold, not as a game-marketing site.

**Closure**

- **SC-012**: The spec closes at the end of the 14-day learning window, which starts on the date the showcase is published and reachable at `arrow.makeboldspark.com`. The closeout sorts every item into Passed, Accepted Limitation, Deferred Work, Learning / Changed Assumption or Failed, and states plainly what outside players said about the game and about the process.

## Assumptions

- The Reference Knot ships unchanged. If outside players reject it, that becomes the input to a later content spec, not a fix inside this one.
- Learning window: 14 days, starting on the actual public-availability date (FR-020). The owner may change the length before planning, but not after the window opens.
- Observed-session recruitment is the owner's responsibility. The spec does not require a recruitment platform.
- Locally stored settings and input remaps in the browser are acceptable: they are settings, not gameplay memory or identity, and never leave the visitor's browser (DP-005, DP-006).
- Gamepad works on a best-effort basis in browsers but is not advertised as a supported web input.
- The author supplies the items only they can provide (real hours, origin moment, verified app names, screenshots, confirmation of the human/AI role split). The story publishes without any item that isn't supplied, rather than inventing it.
- Story pages are readable on phones even though the game is desktop-first.
- The repository is public, so commit-pinned links are reachable by any visitor.
- A Mac with current Safari is expected to be available for FR-025. If not, see FR-025.
- The MakeBoldSpark API runs as a single instance with persistent storage, which makes a single-writer JSON Lines file safe. Phase 0 verifies this (FR-031).
- The site source lives in this repository beside the Godot project, so one change can carry the game export and the site together. Plan may revisit this only with a concrete reason.
- The mockup in the theme ZIP is a design reference, not content. Its placeholder text, counts and article list are replaced by sourced content (FR-013, FR-015).
- Context gathering: constitution 2.0.1 loaded; no `.knowledge` node contradicts this request. The stale knowledge statements found are prerequisites, not contradictions of intent.

## Out of Scope

- Puzzle generator; a new Reference-quality level; any change to puzzle rules, scoring, Open Move or groups' gameplay meaning.
- Intentional touch or mobile play, app stores, installable app packaging.
- Accounts, profiles, authentication, persistent or anonymous player identity, cross-session score history, leaderboards, achievements, cloud save, saved progress.
- Analytics platforms, telemetry, tracking, advertising, monetization.
- React, Next.js, Blazor or any other application framework; a full SPA; server-side rendering; a second major CSS framework.
- Service workers, background sync or retry infrastructure for reactions.
- A CMS or general-purpose feedback platform; any feedback capability beyond the single anonymous submission endpoint (no dashboards, accounts, exports or analytics on it).
- Rewriting the article series beyond the refresh, the Chapter 7 split and the closing chapter.
- Changes to DevSpark itself. Framework lessons (for example the unrun-check wording and the severity/impact-domain split) are referred to DevSpark, not fixed here.
- A difficulty score, adaptive difficulty, or any use of analyzer metrics as a quality judgment.
- Reintroducing a developer cell-size readout; removing the unused legacy main menu scene; Spec 010's own unperformed desktop smoke items.
