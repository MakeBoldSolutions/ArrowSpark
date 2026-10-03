# Showcase Research: ArrowSpark Web Showcase (pre-spec)

**Written:** 2026-10-02, on branch `011-spec-web-showcase`, base `main` at `6e60e11` plus the uncommitted development-doc refresh carried onto this branch.
**Purpose:** the required research output that comes before the spec. It covers questions 1-15 from the request, the content-source map for `.devspark.work/development/*` and the cleanup classification.
**Status:** temporary planning material. `/devspark.plan` may extend it with Phase 0 technical research in its own `research.md`. Nothing durable may cite this file.

Finding classes used throughout (the convergence rule): **Blocking Defect**, **Prerequisite**, **Accepted Limitation**, **Deferred Work**, **Learning / Changed Assumption**. Only the first two expand Spec 011.

---

## 1. What current game experience should the public see?

The **Reference Knot** (`reference_knot`, ArrowSpark Levels, 46x32, 115 arrows, 1348 of 1472 cells occupied, 207 bends, longest arrow 43 cells, 6 legal opening moves), exactly as it plays today:

- path-following departures;
- blocked selections count as mistakes and never stop play (no lives, no fail state);
- Open Move highlights one legal arrow for five mistakes' worth of score: `score = max(total_arrows - (mistakes + open_move_assists * 5), 0)`;
- session-only best score;
- zoom, pan and Fit Puzzle by mouse, keyboard and gamepad;
- the Back button.

Main-menu **Play** already starts it (`scenes/menus/main_menu/main_menu_with_animations.gd` `new_game()`). No gameplay rule changes are needed or wanted.

Analyzer figures (661 dependency edges, depth 33) are diagnostics. The public site may state them as *descriptions of the board*, never as evidence of difficulty or fun (DP-018).

## 2. Which `.devspark.work/development/*` documents should feed the showcase?

Primary feeds:
- the article series, chapters 1-8 (narrative layer);
- `02-product-philosophy.md` (contract and knot metaphor);
- `12-devspark-lessons.md` and `07-testing-and-devspark-process.md` (method);
- `01-project-history.md` (chronology);
- `08-current-state.md` (evidence quality and limitations);
- `14-showcase-story-plan.md` (editorial plan; this research adopts most of it).

Supporting: `05`, `06`, `11`, `13` (checkpoint section only). Internal or stale: `03`, `04`, `09`, `10`, `MANIFEST.md`, `README.md`, `source-*-007.md`, the conversation timeline. The full map is in section 3.

## 3. Content-source map

Recommendation codes: **S** summarize · **Q** quote selectively · **L** link (to a published page, see C-1 in section 15) · **O** omit · **I** internal only.

| Document | Purpose | Current? | Stale / conflicting points | Strongest reusable material | Showcase section | Rec. |
|---|---|---|---|---|---|---|
| `README.md` (dev set) | Index and executive summary | Mostly (2026-10-01) | Says "working tree clean" in its summary path via 08; document map numbering skips 14 | The seven product principles block; "The puzzle defines the world. The screen is only a window into it." | Landing (one principle), Method | Q |
| `MANIFEST.md` | Byte inventory | No | Byte counts stale (self-admitted) | none | none | O |
| `01-project-history.md` | Chronology 001-010 | Yes | Duplicate sentence at the Spec 008 hand-off ("This is the intended subject…/This became…"); §16 "clean tree" no longer true | Four phases (prove it works → learn what it is → contract and constraints → content); §8 Spec 006; §15 Spec 010 bullets | Journey timeline (spine) | S |
| `02-product-philosophy.md` | Product contract and metaphor | Yes | none found | "confusion → understanding → release → simplification → mastery"; the three reactions ("That looks impossible." / "Wait… I think this one can come out." / "Oh! Look how much that cleared."); Look/Try/Open Move/Keep playing hierarchy; Product North Star paragraph | Landing (contract lines only), What We Learned (game) | Q |
| `03-architecture.md` | Authority map | Partly | "Coordinate Model for Spec 008" and "Viewport Architecture Constraints" written pre-implementation; durable truth is `.knowledge/architecture/*` | "Immediate logical removal vs. presentation departure" in plain terms | Method (one example of rules apart from presentation) | I |
| `04-spec-evolution.md` | Per-spec intent/result/lesson | Partly | Spec 008 section header says complete, status line says "no implementation task executed"; "Planned Spec 009" section obsolete | "build → observe → question → specify smaller next step"; each spec's one-line **Lesson** | Journey (one lesson per beat) | S |
| `05-puzzle-design-research.md` | Entanglement hypothesis | Yes, as history | Spaghetti boundary written as future; it was tested in 009 (Boundary Knot), verdict inconclusive | "A puzzle can be structurally complex without being perceptually complex."; Board A vs Board B; "does the board visibly breathe?" | What We Learned (game); **spoiler-gated** | Q |
| `06-scoring-assistance-session.md` | Mistakes, Open Move, session | Yes | none; its "browser session ends or reloads" line now matters for Web | "Replay is not recovery from failure."; "Feedback exists to improve the game, not to remember the player." (via `04`) | Play instructions (Open Move tradeoff, one line), Feedback privacy note | Q |
| `07-testing-and-devspark-process.md` | Gates, test layers | Yes to Spec 007 | Stops at 007; lists eight failure markers, current count is ten | Severity vs impact-domain lesson; "Automate what the automation can reliably prove. Manually verify what depends on real interactive behavior."; static scoreboard test-isolation example | Method, What Didn't (severity labels) | S |
| `08-current-state.md` | Status, evidence quality | Yes (2026-10-01) | "working tree clean" now false; otherwise accurate | "Evidence quality (read this before drawing conclusions)" block; limitations list | Evidence page (verbatim honesty block) | Q |
| `09-spec-008-direction.md` | Pre-implementation brief | Historical | Marked historical | "Spec 008 succeeds when puzzle authors no longer have to ask 'Can this puzzle fit on the screen?'…" | Journey (one line, optional) | O |
| `10-roadmap.md` | Long-range roadmap | Partly | Superseded by `13` where they differ; Web acceptance says "desktop/mobile browser" (superseded by L-3 below) | "Do not add systems merely because successful games often contain them."; three evidence sources (analyzer / observations / feedback) | What We Learned (process) | S |
| `11-design-principles-and-decisions.md` | DP-001…DP-025 | Yes | DP-021 still says "Proposed Spec 008" | DP-022 "Human playtesting can overturn metrics", DP-024 "Specs are temporary", DP-025 "generator after understanding" | Method (Code/Tests/Knowledge), What We Learned | Q |
| `12-devspark-lessons.md` | Method lessons | Yes to 009 | Has no Spec 010 lessons (convergence, criterion amendment, deferral-with-home) | Lessons 2, 6, 7, 9, 10, 11; "creative exploration can be loose; implementation contracts should be precise." | What Worked / What Didn't, What We Learned (process) | S |
| `13-roadmap-008-010.md` | Living roadmap + checkpoint | Checkpoint section current | Body sections for "Spec 010: Web Playtest Build" (phone browser, touch exit criteria) superseded by this spec | Checkpoint gate table, especially "Web gate: 3 or more keepers and an outside tester: **Not met**", recorded rather than skipped | Evidence (changed plans), What Didn't | Q |
| `14-showcase-story-plan.md` | Editorial plan for the site | Yes (2026-10-01) | Proposes "Play first" home, which conflicts with the equal-billing requirement (see L-1) | One spine (series) + one fact layer (docs); spoiler gating; chapter map; facts to refresh; author-only items | Drives the whole IA | I (adopt) |
| `source-spec-007.md`, `source-analyze-007.md`, `source-critic-007.md` | Captured gate outputs | Historical | none, frozen | Analyze's "never claim a knowledge graph edge that does not exist"; critic's scoreboard isolation finding | Evidence (one real gate excerpt, if any) | I |
| `arrowspark-conversation-timeline-2026-09-30.md` | Conversation chronology | To 09-30 | Ends before Spec 010 closed | Names inspirations: "Arrow Away / Tap Away / Arrow Escape". This partly answers the series' open market-evidence item, but claims about those apps' lives/ads are unverified | Chapter 1 (author to verify) | I |
| Series `00-series-outline.md` | Editorial guide | Facts refreshed 2026-10-01 | none in facts; chapter 7 split still pending | Thesis "discipline is what made it fast"; voice rules ("show the receipts", "say what is unknown", "show the misses"); refreshed wall-clock table; reading-the-numbers caveats | Evidence (clock + caveats), editorial rules for all copy | Q |
| Series 01 *Finding the Gap* | Origin | Body stale | "seventy hours… nine specifications… twenty-one puzzles", "82 hours", "three and a half days", "seven articles"; author TODOs (hours, origin, apps) | "This is not a vibe-coding story" table (12 commits before first playable at 3h14m); "ArrowSpark had two jobs: be a good puzzle, and be an honest test of the method."; what transferred / what didn't (feel, focus, difficulty) | **Landing framing**, Method intro, Chapter 1 | Q + L |
| Series 02 *First Game Loop* | Spec 001 | Minor staleness ("nine specs", "three and a half days") | Author TODOs | Rules-as-RefCounted analogy to a service layer; "Decide what the game will never do before deciding what it will do." | Journey beat 1, Chapter 2 | S + L |
| Series 03 *Provably Solvable* | Spec 002 | Yes | none material | The one-paragraph monotonic proof; "the same proof that guarantees safety also removes strategic difficulty" | Journey beat 2, Evidence (solver), Chapter 3 | S + L |
| Series 04 *Making It Feel Right* | Specs 003-004 | Yes | Palette/font claims need a check against `.knowledge/architecture/game-visual-system.md` | "Automate geometry; verify feel by hand; record which is which."; animation became the metaphor | Journey beat 3, Chapter 4 | S + L |
| Series 05 *Playtest Beat the Dashboard* | Specs 005-006 | Yes | Must keep "one playtest session" caveat | 2/5 challenge result; "Graph complexity is not perceptual complexity."; critic catching menu focus in a plan | **What Didn't** (metrics), **What Worked** (critic), Chapter 5 | Q + L |
| Series 06 *Contract Before Difficulty* | Specs 007-008 | Minor (008 verify `warn` result to add) | none material | "State the player's guarantees before you make the game harder."; "'No persistent identity' is a product decision, not a missing feature." | Journey, What We Learned, Chapter 6 | S + L |
| Series 07 *Pulling the Thread* | Spec 009 + audit + (stale) 010 + close | **Partly stale** | "Where it stands: Spec 010" (says not built), "The whole clock" (ends 82h18m, 70 commits, "forty-one touching tests", a figure the outline withdrew), "three and a half days"; must be split per `14` | "unknown, not zero"; "a vocabulary and a toolbox, not a recipe"; the audit that caught leaked planning IDs ("a rule you don't audit is a wish"); "What DevSpark learned" list | What Didn't (audit), Evidence, Chapter 7 (after split); design-vocabulary parts **spoiler-gated** | Q + L (after split) |
| Series 08 *The Reference Knot* | Spec 010 | Yes (2026-10-01) | Author TODOs; doesn't name the convergence lesson | "A spec that green checks could not finish"; "The gates predicted the ending" (critic-005/007/008); SC-005 amended in the open; SC-009 deferred "with a home"; "What 'pass' was allowed to mean"; CON-01; five-bucket closeout | **Strongest DevSpark case study**: What Worked, What Didn't, Evidence; whole chapter **spoiler-gated** | Q + L |
| Series closing chapter | "Now It's Your Turn" | Not written | none (missing) | Planned assembly of 07's close, `12`, `08` | Read the Story (final), end-of-path ask | to write |

**Bucketing:**
- **Public-narrative content:** series chapters 1-8 and the close (after the light pass); `02`.
- **Supporting case-study content:** `01`, `05`, `06`, `07`, `08`, `11`, `12`, `13` (checkpoint section), plus `.knowledge/reference/reference-puzzle-design-report.md`, `.knowledge/reference/gordian-knot-experiments.md` and `.knowledge/product/gameplay-contract.md`.
- **Internal process material:** `03`, `14`, `source-*-007.md`, the conversation timeline, the gate files, `pr-review/*`, `audit/*`.
- **Stale / superseded:** `MANIFEST.md`, `04` (Spec 008 and Planned 009 sections), `09`, `10` (where `13` differs), `13` (pre-checkpoint body), the article 07 Spec 010 and whole-clock sections, and the old clock figures in articles 01, 02 and 07.

## 4. Clearest public story of DevSpark, using ArrowSpark as evidence

> **We wrote down what we believed, built the smallest thing that could prove us wrong, and let the evidence pick the next step. Sometimes that included evidence that the process itself was wrong.**

Evidence beats. Each one is "what we believed → what happened → what we did next". Each beat has a source.

| # | Belief / plan | Evidence | Next decision | Source |
|---|---|---|---|---|
| 1 | Rules before code | Constitution, spec, plan and two gate rounds came before the first arrow; first playable at 3h14m | Keep gates before implementation | Ch 1, 2 |
| 2 | "Hard is good, unsolvable is not" can be a guarantee | Monotonic removal means a solver can prove every puzzle completable | Unlimited mistakes become safe | Ch 3 |
| 3 | Animation is polish | Path-following departure read as "pulling a thread" | The knot metaphor organizes the design | Ch 4 |
| 4 | A menu requirement is enough | Critic found the plan left keyboard/gamepad users with no focus | Game-specific critic questions | Ch 5 |
| 5 | Deeper dependency graphs mean harder puzzles | Every structural target hit; human rated challenge 2/5 | Pursue geometric entanglement | Ch 5 |
| 6 | Make it harder next | Harder needs a safety net first | Open Move + score-not-play contract before difficulty | Ch 6 |
| 7 | Puzzles must fit the screen | Large knots don't | Zoomable canvas before content | Ch 6 |
| 8 | Experiments yield a recipe | Six knots yielded a vocabulary, with per-puzzle evidence recorded as unknown, not zero | Compose one real level | Ch 7 |
| 9 | We follow our own rules | Audit found planning IDs leaked into durable code | Fix; audit regularly | Ch 7 |
| 10 | Done = green checks | Spec 010's definition of done was a human answer; SC-005 failed its original wording and was amended in the open; SC-009 was deferred with a protocol | This showcase exists to supply the missing outside players | Ch 8 |
| 11 | More verification = more confidence | Verification kept producing work after the objective was resolved: an F3 readout added for evidence and then removed, and three PR-review revisions | The convergence rule: classify findings; only blockers expand scope | Spec 010 closeout; PR #4; (narrative not yet written, see C-6) |
| 12 | The designer's opinion is enough | One tester, who designed it | You play it | Ch 8, close |

**Code / Tests / Knowledge** is the through-line, not a separate page. Every beat ends in one of those three. The site's own "Evidence" page is the proof: the repository is public (`MakeBoldSolutions/ArrowSpark`), so a reader can check every claim.

## 5. What existing material becomes what

| Role | Source |
|---|---|
| **Landing copy** | Ch 1 "two jobs" sentence; two contract lines from `02` ("Mistakes cost score, not play." / "There is always a way out. The challenge is seeing it."); "A Make Bold Spark experiment in game design and spec-driven development." No knot or entanglement vocabulary on the landing page. |
| **Short summaries** | One paragraph per chapter from each chapter's `description` frontmatter (already written and mostly current); `08` evidence-quality block |
| **Timeline content** | `01` four phases plus the 12 beats in section 4; the clock table from `00-series-outline.md` (refreshed 2026-10-01) with its "reading these numbers honestly" caveats |
| **Case-study examples** | Ch 5 (2/5 playtest), Ch 7 (audit), Ch 8 (gates predicted the ending; SC-005; SC-009; what "pass" meant; CON-01); `07`/`12` severity lesson; PR #4 focus bug H-02 and the three stale knowledge statements (PRD1-01..03) |
| **Deep-dive links** | The published chapter pages (Ch 1-8 + close); durable `.knowledge` reports linked through commit-pinned repository URLs; merged PRs #1, #2, #4 on GitHub |

## 6. Minimum web-export work

Findings from the repository (verified 2026-10-02):

| Item | State | Class |
|---|---|---|
| Renderer | `gl_compatibility` for desktop and mobile already. This is what browsers need | no action |
| Export configuration | **No `export_presets.cfg`.** Web export has never been configured | Spec 011 scope |
| Engine version | `config/features` = 4.4; CI uses `4.4-stable`; local editor is **4.7.2**; no export templates installed locally | **Prerequisite**: pin one version before implementation, used by the web export, the gates and the build docs. Keep 4.4 unless Phase 0 finds a concrete web-export reason; a change is its own prerequisite (spec FR-023) |
| Threading | Single-threaded web export (Godot 4.3+) needs no cross-origin isolation headers, so any static host works | plan to confirm against the chosen version |
| Quit / fullscreen on web | Template already handles them: `main_menu.gd:46`, `pause_menu.gd:50`, `video_options_menu.gd:8`, `app_settings.gd:150` check `OS.has_feature("web")` | verify only |
| Audio | Music/UI-sound autoloads present; browsers block audio until a user gesture. The logo/intro click is the first gesture | verify no error or stall |
| Persistence in browser | `user://` maps to browser storage: settings, remaps and the legacy `global_state.tres` persist locally. Gameplay score stays session-only; reload means a new session | acceptable (local only, never transmitted); state it on the Play page |
| Mouse | Click select, wheel zoom, drag/Pan-mode pan exist (`scenes/puzzle/puzzle_board.gd`) | verify in a Chromium-based desktop browser, Firefox desktop and Safari on macOS (Safari needs a Mac; it cannot be validated on Windows) |
| Trackpad | Two-finger scroll arrives as wheel, so it **zooms**, not pans; pinch in browsers usually arrives as ctrl+wheel and may trigger **page zoom** | **Prerequisite (verify)**: if pinch or ctrl+wheel zooms the page instead of the board, the page must stop it |
| Keyboard | Board shortcuts (+, -, F, WASD, Tab) work only after the game area has focus; Tab can leave the game area; browser Ctrl +/- zooms the page | Spec 011 scope: focus on first click/gesture, and say so in the instructions |
| Gamepad | Browser gamepad support needs a button press to activate; not a public input claim | Accepted Limitation (best effort, not advertised) |
| Touch | **No intentional touch model.** Default mouse-emulation turns taps into clicks; there is no pinch zoom and no one-finger pan vs. tap arbitration | Deferred Work; the showcase is **desktop-browser-first** (L-3) |
| Viewport sizing | Project base 1280x720; resize stability tested at 960x540, 800x800, 1280x720 | embed at ≥960x540 with a fullscreen option; below that, say it is unsupported |
| Performance | Reference Knot never measured in a browser | Spec 011 scope: measure once (load time, transferred size, frame smoothness during long departures and pan) on a mid-range laptop. No speculative optimization |
| Asset size | `assets/` ~0.9 MB, addon ~4.2 MB source; the engine runtime dominates the download | measure; no work unless the measurement is poor |
| Hosting | **Decided: `arrow.makeboldspark.com`** (static). Repo is **public**; Make Bold pattern is static-first public sites (Azure Static Web Apps) with an anonymous `/api/public/*` surface on MakeBoldSpark; `.knowledge/product/branding.md` names `makeboldspark.com` the public destination | resolved |

## 7. Repository cleanup before planning

| Item | Finding | Class |
|---|---|---|
| New Game tooltip | `main_menu_with_animations.tscn:389`: "Starts the first catalog puzzle…" but Play starts `reference_knot` | **Prerequisite** (public-facing text is wrong) |
| `save-progression.md` | Says `new_game()` sets `PuzzleCatalog.id_at(0)`; "all twenty-one entries"; quotes old tooltip | **Prerequisite** (truthful durable knowledge; the site claims Code/Tests/Knowledge agree) |
| `tests/README.md` | "New Game always resets `PuzzleSession` to catalog position 0" (now Reference Knot); order-independence described without the sampling | **Prerequisite** (same reason) |
| Order-independence wording | `arrow-puzzle.md` ~L234 and ~L361: "every one of the twenty-two entries… at every branching state", but `reference_knot` is sampled every sixth state (`tests/puzzle_catalog_check.gd:361`) | **Prerequisite**: the Evidence page will cite solver validation |
| Tab order doc | `arrow-puzzle.md` ~L825 omits Back; ~L321 says Back is first | **Prerequisite** (one line; bundle with the above) |
| Godot 4.4 vs 4.7.2 | Target 4.4 (features, CI, constitution), local 4.7.2 | **Prerequisite** (plan decision; the web build must be one pinned version) |
| Reference Knot geometry not pinned | Catalog check pins the original 14 entries' exact content; `reference_knot` is checked for validity/solvability only | **Spec 011 scope** (small): evidence is tied to a **puzzle content version** (a geometry identity, not the app version), so the Reference Knot's content version must be fixed and checked (spec FR-009) |
| Dirty tree / article move | Series moved from `docs/articles/` (staged rename) into `.devspark.work/development/`; 9 docs modified; carried onto this branch | **Prerequisite**: commit on this branch before plan. **Learning:** the series is now ephemeral working material, so the published site needs its own durable copy (C-1) |
| Saved-progress decision | Declined in Spec 010; session boundary (DP-005) stands | **No action**. Restate on the Play page: reload starts fresh |
| Unused `main_menu.tscn` | Not referenced by `opening*.tscn` (both route to `main_menu_with_animations.tscn`); has its own stale tooltip | **Deferred** (unreachable; not public) |
| Stale F3 references | None in durable code or knowledge; mentioned only in `.devspark.work` (010 deferral note, `13` open question) | **No action**. Decision: the web build does not reintroduce a readout (L-5) |
| Stale PR-review state | `pr-review/pr-4.md` says "Status: OPEN (draft)", but PR #4 is merged | **No action** (internal). The site links the merged GitHub PR, not the file |
| Article clock/fact staleness | Ch 1, 2, 7 carry 82h / 70 commits / 21 puzzles / "41 test commits" (withdrawn) | **Spec 011 scope** (content light pass before publication) |
| `01` duplicate sentence; `04` contradictory 008 status | Internal docs | **Deferred** (not published verbatim) |

## 8. Should Foundations and Puzzle Lab be public?

**Option B.** Play leads straight to the Reference Knot, as it does today. Level Select stays reachable, with all three groups and one honest line each:
- **ArrowSpark Levels:** the intended experience.
- **Foundations:** the small boards that teach the rule.
- **Puzzle Lab:** experiments from development, some deliberately too tangled.

Reasons:
- **Against Option A (hide them):** SC-009's original question was whether a fresh player finds the ArrowSpark Levels group unaided. Hiding the groups deletes the question. Foundations is also the natural answer if a cold player bounces off the Reference Knot, and the protocol says not to pre-decide that.
- **Against Option C (full catalog, unlabeled):** Puzzle Lab includes Boundary Knot, which is deliberately over-entangled, and `canvas_validation`, which is a technical fixture. Unlabeled, they would misrepresent the game.
- **Honesty:** the site's DevSpark half references these experiments, so a visitor should be able to play them, labeled as experiments.
- **Cost:** one line of label text per group. No rule change, and nothing about grouping changes.

## 9. What public feedback is actually valuable?

Each question below exists to answer a specific learning question in section 13 or 14. Anything that doesn't is cut.

**After play (game reaction), all optional, under a minute:**
1. Did you finish? (finished / stopped partway / didn't really start)
2. How satisfying was it? (1-5)
3. Would you play another one like it? (yes / maybe / no)
4. Did you read "How it was built" before playing? (yes / no). This separates first-contact evidence from primed evidence.
5. Optional: "What did you notice?" (free text, a few sentences)

Attached automatically when the player finished in this page visit, and only then: puzzle id, puzzle content version, mistakes, Open Move assists, score, elapsed time. This is the one-way game → page hand-off (spec FR-019). It carries no identifier, no data about unfinished attempts, and gameplay never depends on it.

**After the story (DevSpark reaction), all optional:**
1. Did the story of how it was built make sense? (yes / partly / no)
2. Did it change how you see the game? (more interested / no change / less interested)
3. Would you use a process like this? (yes / maybe / no)
4. Optional: "What was most interesting or least convincing?" (free text)

Cut on purpose:
- "How challenging?" (satisfaction plus the free text carries it; challenge invites a difficulty score);
- "Which part of the methodology…" as a multiple choice (the free text covers it without leading);
- recommend-to-a-friend (would-play-another is the stronger signal for one level).

## 10. Preserving unbiased first-contact testing

Two evidence tiers, kept separate. Neither is allowed to impersonate the other.

- **Observed fresh-player sessions** (the inherited protocol, the only evidence that counts for discovery questions):
  - a facilitator sends the link and says only "Here's a puzzle game. Play it however you like.";
  - no coaching, no explaining Level Select or groups, no design vocabulary;
  - observe, then interview one question at a time;
  - the facilitator owns the checklist (section 13);
  - record words as given, including negative ones;
  - record anything the facilitator did that could have guided the player.
- **Unobserved web visitors:** self-reported reactions only, tagged by question 4 (read the story first, or not).

**Participant reuse:** one observed participant may cover the landing impression, game evidence and DevSpark comprehension, provided the session runs in this order: landing impression → fresh play → fresh-play interview → Built with DevSpark → DevSpark comprehension and reaction. Separate people are not needed per criterion (spec FR-020).

Site rules that protect both:
- no design vocabulary anywhere a visitor passes before playing (landing, Play page, game menus);
- the story pages that discuss the Reference Knot's design carry a "play first" note;
- the play instructions say what the controls do, never what to look for.

## 11. Can one showcase serve players and developers?

**Yes, with a shared landing page and two paths that rejoin. Not with one long page.**

- **Shared landing page:** two equal entry points of equal weight. No vocabulary. One sentence of shared framing.
- **Player path:** Play → (optional) What did you notice? → offered: "See how it was built."
- **Developer path:** Built with DevSpark → Journey → What Worked / What Didn't → Evidence → Read the Story. It is offered at the method page and at the end: "Now play it."
- **Rejoin point:** the Journey timeline. It is spoiler-light, and both audiences can read it.

Where it would get muddled, and the fence for each:
- design vocabulary leaks onto shared pages → vocabulary rule (FR-005);
- developer visitors' reactions contaminate first-contact data → feedback question 4;
- the method side becomes a brochure → every method claim must cite a beat from section 4.

The result needs testing too: SC-011 asks visitors directly whether each half made sense.

## 12. Explicitly deferred

- Intentional touch / mobile play model.
- Anonymous feedback **API** beyond the minimal channel chosen in Q2.
- Analytics / telemetry.
- Second content round (only if outside players reject the Reference Knot).
- Difficulty characterization.
- Generator.
- Saved progress.
- Gamepad as an advertised web input.
- Numeric cell-size capture / F3 readout.
- `main_menu.tscn` removal.
- Spec 010's manual desktop smoke items (they stay Spec 010's accepted limitations; this spec runs its own browser smoke).
- Writing missing DevSpark framework fixes (CON-01, severity/impact-domain split), which are referred to DevSpark.

## 13. How we'll know the GAME half worked

The facilitator's checklist for observed sessions. These are questions to answer, not pass thresholds:

1. Did they start without guidance?
2. Did they understand what to do?
3. Could they trace arrows?
4. Did they zoom or pan unprompted?
5. Did zones or areas emerge for them? (Their words, not ours.)
6. Did they have short "I see the next few moves" moments?
7. Did big releases feel satisfying?
8. Did any stretch become mindless clicking?
9. Did they use Open Move?
10. Did they understand its tradeoff?
11. Did the ending stay interesting?
12. Would they play another?
13. Would they recommend it?
14. **Discovery (SC-009):** did they open Level Select and find the ArrowSpark Levels group, and how long did it take?

The half **worked as a showcase** if fresh players can start and meaningfully engage without coaching, and their words were recorded. It **worked as a test** if the answers exist and are reported as given, *whether or not they are positive*. A clear "no" is a valid, valuable result.

## 14. How we'll know the DEVSPARK half worked

From story reactions, and from the DevSpark step at the end of observed sessions (after play and the game interview, per the reuse sequence in section 10):
- could a visitor say in their own words what DevSpark is, where it helped, where it got in the way, and why the human playtest mattered?
- ratio of "made sense" to "partly / no";
- free-text mentions of *specific* evidence (the 2/5 playtest, the amended criterion, the audit) versus generic praise. Specific mentions mean the case study is legible;
- a visitor who distrusts the process says so. That is also valid evidence.

## 15. Contradictions and stale source material found

| ID | Contradiction | Resolution | Class |
|---|---|---|---|
| C-1 | The site must link "deeper documents", but the series now lives in `.devspark.work/`. That area is ephemeral and later archived by `/devspark.release`, and durable outputs may not reference it | Publish chapters as the site's own durable content. Link evidence by **commit-pinned** repository URLs, which survive archival, never by branch-relative `.devspark.work` paths | Prerequisite (shapes FR-013) |
| C-2 | `14-showcase-story-plan.md` makes the home page "Play" first; the request requires equal billing | Shared landing page with two equal entry points; play-first lives on as a *spoiler note*, not a hierarchy | Learning / Changed Assumption (L-1) |
| C-3 | `13-roadmap` Web exit criteria require phone browser + touch pan/pinch | Showcase is desktop-browser-first; touch deferred | Changed Assumption (L-3) |
| C-4 | `13-roadmap` Web gate (≥3 keepers + an outside tester) **not met** | Proceed anyway, because the showcase *is* the outside-tester channel. Say so on the Evidence page | Accepted Limitation |
| C-5 | Article 07 / outline: "41 commits touch tests" vs `git log -- tests` = 19 | Outline already withdrew it; the light pass removes it from 07 | Spec 011 scope (content) |
| C-6 | The convergence lesson (verification generating work after the objective resolved) is in the Spec 010 closeout as a *rule*, but no chapter tells it as a *story* | Write it into the closing chapter from the PR #4 revision log and the F3 add/remove commits (`b3aa17e`, `6851baf`); the author confirms the framing | Spec 011 scope (content) |
| C-7 | Conversation timeline names commercial inspirations; the outline says the author must supply them | Author verifies before any app is named publicly | Accepted Limitation (author item) |
| C-8 | Knowledge says order-independence is checked at every branching state for all 22 entries; the test samples `reference_knot` | Fix wording (section 7) | Prerequisite |
| C-9 | `08-current-state` / `01` §16 say "working tree clean" | Internal; not published | No action |
| C-10 | Verify mode: the conversation proposed `verify:browser-smoke`; canonical modes are `snapshot-neutral, golden, regression-pinned, shadow-agreement, end-to-end` | Use `verify:end-to-end` (the real browser flow driven and recorded) | Learning |

**Changed assumptions recorded here:**
- **L-1:** equal billing replaces play-first.
- **L-2:** the series is ephemeral source; the published site is the durable copy.
- **L-3:** desktop-browser-first.
- **L-4:** two evidence tiers (observed vs unobserved).
- **L-5:** no developer readout on web.
- **L-6 (2026-10-02 cleanup):** privacy is guaranteed at the application/data-model level, not as a claim about infrastructure; one participant may serve several criteria under the first-contact sequence; the learning window starts on actual public availability and never auto-extends.

---

## 16. Theme and technical-architecture research (2026-10-02)

### 16.1 What the ZIP is

**Path:** `.devspark.work/specs/011-spec-web-showcase/ArrowSpark mockup with DevSpark theme.zip` (1.04 MB, 23 files). Inspected from an extracted scratch copy; nothing was extracted into the repository.

It holds two things:

1. **The Make Bold Solutions design system** (`_ds/make-bold-solutions-design-system-…/`):
   - `styles.css`, an `@import` list;
   - six token files under `tokens/`: `fonts`, `colors`, `typography`, `spacing`, `effects`, `base`;
   - Be Vietnam Pro static TTFs (400-900) and Inter Tight variable TTFs (roman and italic);
   - `readme.md` (brand and visual rules);
   - `_ds_manifest.json`;
   - `_ds_bundle.js`, compiled **React JSX** components: Badge, Button, Card, Eyebrow, Input, plus website UI-kit pieces SiteHeader, Hero, Services, ValueStrip and ContactCTA;
   - `_adherence.oxlintrc.json`, lint rules: no raw hex, no raw px, only the DS fonts, and fixed component prop sets.
2. **An ArrowSpark showcase mockup:**
   - `ArrowSpark.dc.html`, a design-canvas document with seven views (Home, Play, Built with DevSpark, Journey, Evidence, Read the Story, Responsive states);
   - `support.js`, the design-canvas runtime, which needs `window.React`;
   - `logo-mark.svg`, the two-peak mark;
   - `.thumbnail`.

### 16.2 Technology the theme uses today

- **Styling:** plain CSS custom properties. Framework-free and directly reusable.
- **Components:** React JSX, compiled into a design-tool bundle.
- **Mockup:** markup with *inline styles* (raw hex and px everywhere) driven by a React-based canvas runtime (`<x-dc>`, `<sc-for>`, `<sc-if>`, `DCLogic`).
- **Icons:** Lucide from `unpkg.com/lucide@latest`.
- **No** Tailwind, Bootstrap or build tool.

### 16.3 Contract / reuse / legacy classification

| Class | Item |
|---|---|
| **Visual / brand contract** (preserve) | Rust `#982407` primary, ember `#C6620C` accent, ink `#1E1E1E`, cream `#F8F6F2` page, white cards; warm ink ramp; muted status colors, with `--critical` only for errors. Be Vietnam Pro display (extrabold/black, tight negative tracking, `text-wrap: balance`), Inter Tight body (line-height 1.55). Spaced uppercase eyebrows (`0.18em`). 4px spacing grid; 1200px container, 68ch prose, fluid gutter and section rhythm. Radii 4-10px; hairline warm borders; tight warm shadows; 3px accent rule as a sparing emphasis. Motion 120/200ms, no bounce. Focus: 2px ember outline with offset. Peak mark untouched, with 1x clear space. Voice: sentence case, plain, no emoji, no hype. Avoid list: gradients, glassmorphism, neon, pill-everything, heavy shadows. |
| **Reusable implementation** (reuse directly) | All six token CSS files plus `styles.css`; font files (self-hosted, with OFL notices); `logo-mark.svg`; component *prop contracts* from the lint rules, to port: Button `primary/accent/secondary/ghost/dark` x `sm/md/lg`, Card `padding none-xl`, `interactive`, `accent`; Badge tones; Eyebrow `accent/brand/muted/onDark`; Input `input/textarea` with `label/hint/error`. Mockup *layouts* worth porting: header lockup (mark + "ArrowSpark" + spaced "MAKE BOLD SPARK"), rust/ink twin entry cards, the four-up promise strip, the dark game frame with title bar and Fullscreen, the loading state, the desktop-only notice card, the reaction form, Belief/Evidence/Next-decision beat cards with a numbered rail, the Code/Tests/Knowledge diagram, paired What worked / What didn't cards, the spoiler gate ("Haven't played yet?"), fact tiles, the Evidence "one human tester" callout, the numbered article list. |
| **Legacy implementation detail** (adapt, don't keep) | The React components and `support.js` runtime (FR-028 bans React), so re-express them as Astro components with scoped CSS on the tokens. Inline styles with raw hex/px, which break the theme's own lint rules, so move them to tokens and component CSS. `lucide@latest` from a CDN, so pin the version or inline the SVGs. TTF-only fonts, so serve WOFF2 for the web. Unicode check, cross, fullscreen, arrow and menu glyphs used as icons, which the DS readme forbids, so use outline icons. The "Responsive states" demo view (design artifact; omit). |

### 16.4 Conflicts between the theme/mockup and the agreed spec or stack

| # | Conflict | Resolution | Class |
|---|---|---|---|
| T-1 | DS components are React; FR-028 forbids React | Port the five primitives and the needed layouts to Astro components against their prop contracts | Learning (adaptation) |
| T-2 | Mockup mobile notice offers **"Email me the link"**, which would collect contact data | Replace with copy-link or a `mailto:` to the visitor's own mail app; nothing collected (FR-007) | Prerequisite (privacy; content-level fix) |
| T-3 | Mockup placeholders: "Score 1,200" in the game frame (max is 115); **"4,000+ assertions"** (unsourced); "Ten milestones, two lessons each" (each has one lesson); Read the Story lists **6 invented parts** instead of the real 8 chapters + close | Replace with sourced figures (FR-013) and the real chapter set (FR-015). Count assertions with a documented command or drop the figure | Spec 011 scope (content) |
| T-4 | Mockup splits the arc into Belief/Evidence/Next-decision **beats** (Built with DevSpark) and a **Journey** of "what changed / what we learned"; old FR-011 put belief-evidence-decision on the Journey | Adopt the mockup's split; FR-002 and FR-011 amended | Learning / Changed Assumption |
| T-5 | Theme readme is written for Make Bold *Solutions* (fractional CFO voice); ArrowSpark sits under Make Bold *Spark* | Keep the visual contract and the voice *rules* (plain, no emoji, sentence case); don't import CFO copy. The header lockup already says "MAKE BOLD SPARK" | No action |
| T-6 | Game's blocked red `#E8221A` (`.knowledge/architecture/game-visual-system.md`) differs from the DS `--critical #a8321a` | Both are error-only, in separate authorities (in-game vs site). No change to the game | No action |
| T-7 | The ZIP lives in a temporary bundle | Copy tokens, fonts, licenses and the mark into the site source; never reference the ZIP | Prerequisite |
| T-8 | Constitution Technology lists Godot/GDScript/Python only | MINOR amendment adding the Astro/TypeScript site and browser verification | Prerequisite |

The game's palette already matches the theme exactly: `game_background #F8F6F2`, `arrow_normal #1E1E1E`, `arrow_hover #C6620C`, `game_accent #982407`, `game_success #2F6F4C` = DS `--positive`. No game restyling is needed.

Pre-play vocabulary check of the mockup's Home and Play views: none of the FR-005 terms appear. "Gordian knot" appears only on Built with DevSpark, which is not a pre-play surface.

### 16.5 Proposed Astro source and content structure (plan may adjust names)

```text
web/                                # site source, in this repository
  astro.config.mjs                  # output: 'static'
  staticwebapp.config.json          # headers, caching, engine-file content types
  public/
    fonts/  brand/logo-mark.svg  licenses/OFL-*.txt
    game/                           # Godot Web export, copied in at build (not committed by hand)
  src/
    styles/make-bold/               # the theme's token files, unchanged
    styles/arrowspark.css           # documented extensions only (game frame, beats, journey)
    components/                     # Button, Card, Badge, Eyebrow, Input (ported);
                                    # SiteHeader, SiteFooter, EntryCard, PromiseStrip,
                                    # GameFrame, DesktopOnlyNotice, ReactionForm, StoryReactionForm,
                                    # BeatList, Journey, EvidenceCallout, FactTiles, SpoilerGate
    layouts/  BaseLayout.astro  ArticleLayout.astro
    content/
      chapters/01-...08-*.md(x), 09-now-its-your-turn.md(x)
      journey.yaml  beats.yaml  evidence.yaml  # structured data with source links
    content.config.ts               # typed schemas: chapter {title, part, description, spoiler, sources[]}
    pages/
      index.astro  play.astro  devspark.astro  journey.astro  evidence.astro
      story/index.astro  story/[slug].astro
    scripts/  game-bridge.ts  reaction-client.ts
```

### 16.6 Proposed Godot Web embedding boundary

- **Recommended:** the Godot export served from `/game/` and embedded in the Play page as a **same-origin iframe**.
  - This keeps Godot's generated loader shell intact, isolates engine globals from the site, and gives a natural fullscreen target and a click-to-focus surface (matching the mockup's "click inside the game once").
  - The game emits `attemptCompleted` to the parent page. The bridge checks the message's origin and exact shape before accepting it.
- **Alternative (Phase 0 may choose it):** embed the canvas directly in the page.
- **Mechanism candidates (Phase 0 decides):**
  - Godot's `JavaScriptBridge`, guarded by the web feature check, posting a message to the parent;
  - dispatching a DOM event.
  Either way the call is fire-and-forget, so the game never awaits a reply.
- **Desktop builds:** unaffected, because the emitter is a no-op outside the web platform.
- **Rule core:** untouched. The emitter reads the finished attempt's results after completion, in the presentation/controller layer.

### 16.7 Proposed completed-attempt event contract

```json
{ "type": "arrowspark.attemptCompleted", "contractVersion": 1,
  "puzzleId": "reference_knot", "puzzleVersion": "<content version id>",
  "mistakes": 2, "openMoveAssists": 2, "score": 103, "elapsedSeconds": 1260 }
```

Sent once per completed attempt. No visitor, session or device identifier, and no in-progress data. The bridge keeps only the latest event, in memory, for the current page visit.

### 16.8 Proposed MakeBoldSpark endpoint contract

`POST /api/public/arrowspark/reactions`

- **Where:** a new feature folder `Features/ArrowSpark/`, matching how `Features/FamilyMemories/` is organized.
- **CORS:** a feature-specific policy with origin `https://arrow.makeboldspark.com`, methods POST, header `Content-Type`. Development origins come from validated configuration with no wildcards, as `FamilyMemoryEndpoints` does.
- **Rate limit:** a fixed-window, per-IP partition, as in `Program.cs` (`login-per-ip`, 20/min). Suggested 10/min, held in memory only.
- **Error filter:** logs exception type and trace id only, with `Cache-Control: no-store`.
- **Request examples:**

```json
{ "reactionType": "game", "readStoryFirst": "no", "finished": "finished", "satisfaction": 4,
  "playAnother": "yes", "comment": "...",
  "attempt": { "puzzleId": "reference_knot", "puzzleVersion": "...", "mistakes": 2,
               "openMoveAssists": 2, "score": 103, "elapsedSeconds": 1260 } }
{ "reactionType": "story", "madeSense": "partly", "changedView": "moreInterested",
  "wouldUse": "maybe", "comment": "..." }
```

- **Responses:**
  - `202` with no body;
  - `400` validation problem (unknown property, bad enum or range, over 1,000 characters);
  - `413` over about 4 KB;
  - `415` not JSON;
  - `429` rate limited;
  - `5xx` failure, which the client shows as "not sent".

### 16.9 Proposed JSONL record shape

One line per accepted reaction, in `arrowspark-reactions.jsonl` in the API's persistent data directory:

```json
{"schemaVersion":1,"receivedUtc":"2026-10-20T14:03Z","recordId":"3f9c...","reactionType":"game","readStoryFirst":"no","finished":"finished","satisfaction":4,"playAnother":"yes","comment":"...","attempt":{"puzzleId":"reference_knot","puzzleVersion":"...","mistakes":2,"openMoveAssists":2,"score":103,"elapsedSeconds":1260}}
```

- **Excluded:** IP address, user agent, referrer, headers and cookies.
- **`recordId`:** random, server-only, never returned.
- **Safety condition:** an in-process single-writer lock makes appends safe *if the API runs as one instance*. The API README describes App Service Linux B1 with persistent `/home` storage, so this is likely true, but plan verifies it.
- **Fallback:** if it is not true, use the API's existing SQLite database with one append-only table. No new platform (FR-031).

### 16.10 Feedback-unavailable recommendation

**Recommended: the minimum fallback**, a plain "Feedback is temporarily unavailable. Your game and the story are unaffected." message.

- The learning window is 14 days and the volume is small, so a queue would rescue very few reactions.
- A local queue stores free text in browser storage, where it can be read by the next user of a shared machine.
- A queue adds extra UI states (pending, retrying, sent) and tests.
- A queue creates a second place where reaction data lives, against the spirit of FR-018 and FR-033.

The queue stays permitted (FR-032) if plan finds it nearly free. It is not recommended.

### 16.11 Blockers

**None.** No finding stops Spec 011.

**Prerequisites:**
- T-7, durable theme copy;
- T-8, constitution amendment;
- FR-023, engine pin;
- FR-022, truthful baseline;
- verifying the API runs as one instance (FR-031).

T-2 (privacy wording in the mockup) is fixed in content.

**Deferred:** porting the theme's website UI-kit pieces that the showcase doesn't need (Services, ContactCTA, Hero variants); the theme's deck template.
