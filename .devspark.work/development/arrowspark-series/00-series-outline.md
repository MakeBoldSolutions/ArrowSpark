---
title: "Building ArrowSpark with DevSpark — Series Outline"
series: "Building ArrowSpark with DevSpark"
part: outline
status: first-draft
author: Mark Hazleton
date_drafted: 2026-09-30
date_facts_refreshed: 2026-10-01
theme: "A business-software developer with no game experience uses spec-driven development to fill a gap in arcade puzzle apps, and learns what the game actually is by testing his own assumptions."
description: "Index, story arc, and editorial notes for an eight-chapter series (plus a closing chapter) on the development of ArrowSpark, a Godot puzzle game built with DevSpark between 2026-09-26 and 2026-10-01."
purpose: "Give the author one page to steer the series: what each article is for, how the story escalates, which evidence backs each claim, and what the author still has to supply."
---

# Building ArrowSpark with DevSpark: Series Outline

## The one-sentence story

I found a gap in arcade puzzle apps (a puzzle that never punishes you), had no game-development background, and used DevSpark's specify → plan → tasks → gate → implement loop to learn Godot and find out what the game really was. The most important discoveries were about design, not code.

## The thesis: discipline is what made it fast

This is **not** a "vibe coding" story, and the series must never read like one. It is the story of a seasoned engineer applying what he already knew (contracts, invariants, tests-first, review gates, separating rules from presentation) through DevSpark to get productive in an unfamiliar domain in days instead of months.

The argument rests on **wall-clock time**, so every article carries a "clock" beat. The claim to defend: *the process overhead (constitution, spec, plan, tasks, analyze, critic, verify) was not a tax on speed. It was the reason the speed was safe.* Evidence: on day one the first playable arrived 3h14m after the first commit, with twelve commits of governance, recovery, specification, planning and gates *before* the implementation commit.

## Voice: show the receipts

The series is a look over the author's shoulder. Nothing in it should need to be taken on faith, and nothing should be dressed up.

- **Facts before commentary.** State what happened, when, and where the evidence is. Interpretation comes after, and is labeled as interpretation.
- **Every timing or sequence claim has a receipt**: a commit hash and timestamp, a gate report, a PR, or a named file. Each article ends with a Receipts table generated from `git log`.
- **No humble-brag, no exaggeration.** No superlatives, no "in just N hours!" No speed-up multiple. Numbers are stated with what they do and don't include.
- **Say what is unknown.** If evidence is missing (per-puzzle playtest data, real hours), write "unknown" and say why.
- **Show the misses.** The 2/5 playtest, the leaked review IDs, the stale test README, the verify gate that finished as *warn* all stay in.
- **Reproducible.** A reader can rerun `git log --reverse --format='%h %ad %s' --date=format:'%Y-%m-%d %H:%M'` and get the same table.

Receipts already in the repo besides commits: `.devspark.work/specs/*/gates/` (analyze, critic, verify), `.devspark.work/pr-review/`, `.devspark.work/audit/`, `.devspark.work/research/spec-006-report.md`, `.knowledge/reference/gordian-knot-experiments.md`, `.knowledge/reference/reference-puzzle-design-report.md`, and `.knowledge/guides/repo-story/`.

### Wall-clock evidence (from `git log`, local time, 2026-09-26 to 2026-10-01)

| Milestone | Timestamp | Elapsed since first commit |
|---|---|---|
| First commit (template) | 09-26 10:41 | 0 |
| Spec 001 first playable implemented | 09-26 13:55 | 3h 14m |
| Spec 002 solver merged | 09-26 17:05 | 6h 24m |
| Spec 003 continuous visuals merged | 09-26 21:25 | 10h 44m |
| Spec 004 path-following departure merged | 09-27 00:40 | 13h 59m |
| Spec 005 catalog + Level Select merged | 09-27 08:50 | 22h 09m |
| Spec 006 analyzer, 6 experiments, report | 09-27 13:36 | 26h 55m |
| Spec 007 Open Move + scoring merged | 09-28 07:42 | 45h 01m |
| Spec 008 zoomable canvas merged (PR #1) | 09-28 15:45 | 53h 04m |
| Spec 009 Gordian Knot experiments merged (PR #2) | 09-29 09:17 | 70h 36m |
| Spec 010 specified | 09-29 20:59 | 82h 18m |
| Spec 010 implementation (groups, Reference Knot) | 09-30 15:38 | 100h 57m |
| Spec 010 human playtest recorded | 10-01 07:51 | 117h 10m |
| Spec 010 merged (PR #4), last commit | 10-01 11:51 | 121h 10m |

- Nine specs merged in about **70.5 hours of elapsed time** (roughly 2 days 22 hours), including overnight gaps. All ten were merged at **121 hours** (about 5 days).
- Splitting the log into sessions (a new session starts after a gap over 90 minutes) gives **17 sessions totalling about 22.9 hours of commit-bracketed activity** (13 sessions and about 19 hours up to 2026-09-29). Day one alone was two long sessions (8.2h and 2.4h).
- 91 commits; four merged GitHub PRs. 19 commits touch files under `tests/` (13 up to 2026-09-29).
- **Correction (2026-10-01):** earlier drafts said "41 of which touch tests". Neither `git log -- tests` (19) nor counting any path containing "test" (24) reproduces 41, so the figure is withdrawn. Most commits bundle code and tests together, so this count says little about test discipline; the line counts below say more.

### Reading these numbers honestly

- Elapsed time is not effort. Overnight gaps are included in the first figure and excluded in the second.
- Commit timestamps undercount: work before a session's first commit is invisible, and some commits batch earlier work. The 19-hour figure is a *lower bound on visible activity*, not a timesheet.
- Much of the writing and gate-running was AI-executed. That is the point, but say it plainly: the human owned the decisions, the reviews, the playtests, and the acceptance.
- **Mark: replace or supplement these with your own actual hours.** That figure is the strongest number in the series, and only you have it.

## The arc

| Act | Articles | What happens | Emotional register |
|---|---|---|---|
| I. Premise | 1–2 | A need is spotted; a method is chosen; the first game loop exists | Plain statement of scope |
| II. Craft | 3–4 | The rules become provable; the game starts to feel like something | Verification |
| III. Reversal | 5 | Every metric is green and a human says "too easy" | Surprise, correction |
| IV. Contract | 6 | The game earns the right to be hard | Discipline |
| V. Composition | 7–8 | Knot ingredients, the audit, then one composed level judged by a human | Honesty under a human bar |
| VI. Invitation | Closing | The whole clock, the lessons, and the ask: play it | Reflection, then a request |

## The chapters

| # | Working title | Theme | Specs / evidence | File |
|---|---|---|---|---|
| 1 | Finding the Gap: A Puzzle That Never Punishes You | Origin and premise | Constitution, first commits | [01](01-finding-the-gap.md) |
| 2 | My First Game Loop: Spec 001 Through a Business Developer's Eyes | Method meets a new domain | Spec 001 | [02](02-first-game-loop.md) |
| 3 | Provably Solvable: A Solver and a One-Paragraph Proof | Engineering rigor as a design promise | Spec 002 | [03](03-provably-solvable.md) |
| 4 | Making It Feel Right: Unwinding Arrows and What Tests Can't See | Feel, presentation, manual verification | Specs 003, 004, branding | [04](04-making-it-feel-right.md) |
| 5 | The Playtest That Beat the Dashboard | Evidence overturns metrics | Specs 005, 006 | [05](05-playtest-beat-the-dashboard.md) |
| 6 | The Contract Before the Difficulty, the Canvas Before the Content | Sequencing and player trust | Specs 007, 008 | [06](06-contract-before-difficulty.md) |
| 7 | Pulling the Thread: Knots, Audits, and What DevSpark Learned | Ingredients and honest evidence | Spec 009, audit | [07](07-pulling-the-thread.md) (to be split: Spec 010 and closing sections move out) |
| 8 | The Reference Knot: A Level Judged by a Human | Composition, a human definition of done, recorded failure | Spec 010, PR #4 | [08](08-the-reference-knot.md) |
| Close | Now It's Your Turn | The whole clock, lessons, the request to play | All; `12-devspark-lessons.md` | not yet written |

## Recurring motifs (use consistently)

- **The four-line contract**: *Hard is good. Unsolvable is not. Mistakes cost score, not play. There is always a way out.*
- **The clock.** Each article states how long its specs took on the wall clock and what the discipline bought in that time.
- **Expert, not improviser.** The author's decisions come from experience (invariants, boundaries, verification), and the tool amplifies them. Never "I just asked the AI."
- **Build → observe → question → specify a smaller next step.**
- **Specs are temporary; code, tests, and knowledge are durable.**
- **Automate what automation can prove; verify the rest by hand and say so.**
- **The knot metaphor**: find a loose thread, pull it, watch the field open.

## Facts the series can rely on (from the repo)

- Repository: 91 commits, first at 2026-09-26 10:41, latest 2026-10-01 11:51. Commits per day: 34 / 15 / 11 / 10 / 9 / 12.
- Ten specs complete (001–010). Spec 010 closed on 2026-10-01 with documented limitations.
- Four merged GitHub PRs (#1 Spec 008, #2 Spec 009, #3 site-audit chore, #4 Spec 010); earlier specs merged locally.
- Catalog grew 1 puzzle → 8 → 14 → 15 → 21 → 22, now in three groups (Foundations 8, Puzzle Lab 13, ArrowSpark Levels 1).
- Two required headless regression launchers plus a non-gating structural report; CI runs both on push/PR.
- 3,820 lines of GDScript in `scripts/` and `scenes/` against 5,340 lines in `tests/*.gd` (counted 2026-10-01 with `cat $(git ls-files 'scripts/*.gd' 'scenes/*.gd') | wc -l` and the same for `tests/*.gd`; excludes the addon). The 2026-09-30 count was about 3,470 and 5,040.
- One human playtest quote, verbatim, in [`spec-006-report.md`](../../research/spec-006-report.md).

## What the author must supply (nothing here was invented on your behalf)

0. **Your real hours, and your own baseline.** How many hours did you actually spend, and how long would you have expected the same scope to take without DevSpark (or in C#/.NET)? The drafts leave that estimate blank on purpose; do not let anyone else invent it.
1. **The origin moment.** The repo documents *what* the gap is, not *when or how you noticed it*. Article 1 has marked spots for the real story.
2. **Market evidence.** The claim that commercial arrow-puzzle apps lean on lives, ads, and retry loops comes from the design docs ("examples of dense commercial arrow puzzles"). Name two or three real apps or drop the comparison to something you can defend.
3. **Personal Godot moments.** Where you were confused as a C#/.NET developer. The repo shows decisions, not frustrations.
4. **Screenshots.** Good candidates exist under `.devspark.work/specs/003-*/gates/` (1280×720 and 960×540 captures) and `.devspark.work/specs/008-*/evidence/`.
5. **Human-role accounting.** The Spec 010 header lists owner and reviewer as human, planner, implementer, critic, and scribe as AI. Confirm that is how you want the split described.

## Editorial cautions

- The whole history spans about 5 days (121 hours first commit to the Spec 010 merge). Say so early and plainly, and lead with the clock; it is the case for DevSpark. Articles 1–7 still say "three and a half days" and "82 hours"; update them in the light pass.
- Never describe the work as improvised. Show the discipline: constitution first, tests first, gates before code, humans accepting the result.
- Do not claim a speed-up multiple unless you supply the baseline yourself.
- Spec 009's human evidence is **one aggregate author session**, per-puzzle detail *unknown, not zero*. Do not upgrade it to "playtesting proved".
- Spec 004's visual acceptance and Spec 008's verify gate contain **user-reported or explicitly outstanding** items. The drafts say so; keep that.
- Spec 010 passed its human bar with **one familiar tester** (the designer). SC-005 failed its original wording and was amended; SC-009 (a fresh player finding the level) was not performed. Chapter 8 must keep all three facts in the body.
- Chapter 8 discusses the Reference Knot's design (neighborhoods, bridge arrows, beats). On the website it goes behind a "play first" note so it cannot spoil a fresh player's first exposure.
- Any time a draft says "I", check it against what you actually did.
