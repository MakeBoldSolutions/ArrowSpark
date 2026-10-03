# Showcase Story Plan: One Story for the ArrowSpark Website

**Written:** 2026-10-01
**Status:** in progress. 2026-10-01: section 5 facts applied to `arrowspark-series/00-series-outline.md`; Chapter 8 drafted as `arrowspark-series/08-the-reference-knot.md`. Remaining: split Article 7, write the closing chapter, light pass on Articles 1-7.
**Goal:** merge the development history (this folder) and the article series (`arrowspark-series/`) into one story. That story becomes the content of the website that hosts the game for evaluation, and it shows what DevSpark development buys.

## 1. What exists today

There are two tellings of the same five days, and they have drifted apart.

| | Article series (`arrowspark-series/`) | Development docs (`01`-`13`) |
|---|---|---|
| Voice | First person, narrative, "show the receipts" | Third person, reference, decision records |
| Audience | Developers weighing spec-driven AI work | Future agents and the author |
| Coverage | Specs 001-009; Spec 010 as "specified, not built" | Specs 001-010, current to `6e60e11` |
| Strength | Arc, clock, honesty rules, lessons | Facts, principles (DP-001 to DP-025), current state |
| Staleness | Article 7, the outline's facts and the clock end on 2026-09-29 | `09`, `10` and parts of `03`/`04` are pre-implementation snapshots |

Where they overlap (the same material told twice):

| Topic | Series | Dev docs |
|---|---|---|
| Chronology | Articles 1-7 | `01-project-history.md`, `04-spec-evolution.md` |
| The four-line contract and knot metaphor | Articles 1, 4, 6 | `02-product-philosophy.md`, `11-design-principles-and-decisions.md` |
| Spec 006 reversal | Article 5 | `05-puzzle-design-research.md`, `01` section 8 |
| Scoring and Open Move | Article 6 | `06-scoring-assistance-session.md` |
| Process lessons | Article 7 "What DevSpark learned" | `12-devspark-lessons.md`, `07-testing-and-devspark-process.md` |
| What's next | Article 7 "What's still open" | `08-current-state.md`, `13-roadmap-008-010.md` |

## 2. The recommendation: one spine, two layers

Don't merge everything into one long document. Keep **one narrative** and **one fact layer**, and make the narrative cite the facts.

- **Narrative layer = the article series, re-cut into chapters.** It is the better story and already has the honesty rules the showcase needs. It becomes the website's "How it was made."
- **Fact layer = the development docs.** They stay the source of truth for numbers, principles and status. Chapters link to them instead of restating them. `01-project-history.md` becomes the chronological index both layers share.
- **Sync rule:** every chapter's frontmatter already lists `specs_covered` and `evidence_sources`. At each spec checkpoint, a chapter whose specs or sources changed gets flagged for update. Add that as one line to the revision protocol in `13-roadmap-008-010.md`.

This keeps the docs and the series in step, which is the point of moving the series into this folder.

## 3. The website, play first

The site exists so outside players can evaluate the game. That makes one constraint decisive, and it comes from the project's own evidence rules: the deferred fresh-player protocol (`specs/010-spec-reference-puzzle/deferred-to-next-spec.md`) says players must **not** be taught the internal design vocabulary (neighborhoods, bridge arrows, discovery beats) before they play.

The story is full of that vocabulary. So **the story must not stand between a new visitor and the game.**

Proposed structure:

1. **Home: Play.** One sentence of premise, a Play button, and nothing that spoils the Reference Knot. This is the first-exposure page SC-009 needs.
2. **After you play: tell us.** The manual feedback link (no account, no telemetry, matching DP-005 and DP-006). Offer it on the Results screen and on the site.
3. **How it was made.** The chapters below. Reached from the home page by a plain link, with a note: "Play first if you can; the later chapters discuss the puzzle's design."
4. **The receipts.** Clock table, gate reports, PRs, the playtest records with their stated limits. The DevSpark case lives here, as checkable evidence.
5. **The method.** A short DevSpark explainer: the lifecycle, what each gate is for, what the human owned and what the AI ran.

A reader who comes for DevSpark lands on 3 to 5 and is then invited to play. A player who comes to play is never spoiled. Either way the site produces what the project currently lacks: players other than the designer.

## 4. Chapter map

Eight chapters plus a closing. Existing articles keep most of their text. "New" means it has to be written.

| # | Chapter | Built from | Work needed |
|---|---|---|---|
| 1 | Finding the Gap | Article 1, `02` Core Identity | Light edit. Author still owes the origin moment and market examples. |
| 2 | My First Game Loop | Article 2 | Light edit. |
| 3 | Provably Solvable | Article 3, DP-003, DP-017 | Light edit. |
| 4 | Making It Feel Right | Article 4 | Light edit. |
| 5 | The Playtest That Beat the Dashboard | Article 5, `05`, `spec-006-report.md` | Light edit. |
| 6 | The Contract Before the Difficulty, the Canvas Before the Content | Article 6, `06`, `08`'s Spec 008 summary | Light edit. Add Spec 008's actual result (merged, verify `warn`). |
| 7 | Pulling the Thread: Knots and the Audit | Article 7 minus the Spec 010 and "whole clock" sections | Moderate: split the article. |
| 8 | **The Reference Knot** | `01` section 15, the Spec 010 closeout, `.knowledge/reference/reference-puzzle-design-report.md`, PR #4 review | **New.** Covers the composed level, groups, the fifteen-question playtest, SC-005 failing its original wording and being amended, SC-009 deferred. Gate it as a spoiler chapter. |
| Close | **Now It's Your Turn** | Article 7's "What DevSpark learned", "What's still open" and "Back to the gap"; `12`; `08` | **New, mostly assembled.** The updated whole clock and lessons, ending in a direct ask: play it, then tell us. The story's open question (does anyone but the designer enjoy this?) is answered by the reader. |

Chapter 8 is the strongest showcase material in the repository and it isn't written yet. A spec whose definition of done was a human's honest answer, then a recorded failure against the original wording, then an amendment that preserves that wording, is exactly what "discipline, not vibe coding" means.

## 5. Facts that must be refreshed before anything is published

From `git log` on 2026-10-01 (local time):

| Fact | Series says | Now |
|---|---|---|
| Last milestone | Spec 010 specified, 09-29 20:59 (82h 18m) | Spec 010 merged (PR #4), 10-01 11:51 (**121h 10m**) |
| Specs complete | Nine (001-009) | **Ten** (001-010) |
| Commits | 70 | **91**. Per day: 34 / 15 / 11 / 10 / 9 / 12 |
| Merged PRs | Three | **Four** (#4 is Spec 010) |
| Sessions (gap > 90 min) | 13 sessions, about 19h | **17 sessions, about 22.9h** |
| Catalog | 21 puzzles | **22, in three groups** |
| Commits touching tests | 41 | `git log -- tests` gives 19, so the series counted differently. Recount with one documented command and print it next to the number. |
| Code vs test lines | ~3,470 vs ~5,040 (2026-09-30) | Recount; Spec 010 added tests. |

Write the clock's derivation commands into the Receipts page so a reader can reproduce every number. The series outline's honesty rules already require this.

## 6. Retire or fold the overlap

Once the chapters exist:

- **Keep as the fact layer:** `01` (chronology), `02`, `03`, `08`, `11`, `12`, `13`.
- **Fold into chapters, then mark as source-only:** `05`, `06`, `07`, `04`.
- **Mark historical** (pre-implementation snapshots): `09-spec-008-direction.md`, `10-roadmap.md`, `source-*-007.md`, `arrowspark-conversation-timeline-2026-09-30.md`.
- `00-series-outline.md` becomes the editorial guide for the merged story. Update its "Facts the series can rely on" from section 5 above.

## 7. Where the website sits in the roadmap

This plan and the next spec are the same piece of work. The roadmap's next step, **Web Showcase & Playtest**, needs a hosted Web build and a feedback path, and it inherits SC-009. Treat the site content as part of that spec's scope:

- the play-first home page is the SC-009 test environment;
- the story chapters are content, not code, so they don't touch the regression gates;
- what to show from Puzzle Lab, and whether Play opens the Reference Knot or Foundations, are already open questions in the roadmap checkpoint. Answer them in `/devspark.specify`, not here.

## 8. What only the author can supply

Carried over from the outline and still open:

1. Real hours spent, and an honest estimate without DevSpark. This is the paragraph readers will quote.
2. The origin moment for Chapter 1.
3. Two or three named commercial arrow-puzzle apps, or drop the comparison.
4. Personal Godot moments as a C#/.NET developer.
5. Screenshots (candidates under `specs/003-*/gates/` and `specs/008-*/evidence/`; Spec 009 has `previews/`).
6. Confirmation of the human/AI role split as described.
7. **New:** how you want Chapter 8 to handle the familiar-tester limitation. Recommendation: state it in the body, not a callout, because it is why the site asks the reader to play.

## 9. Suggested order of work

1. Refresh the facts (section 5) in `00-series-outline.md`.
2. Split Article 7; draft Chapter 8 and the closing chapter.
3. Light pass on Chapters 1-6 for dates and status.
4. Settle the site structure in the Web Showcase spec, then turn the chapters into pages.
