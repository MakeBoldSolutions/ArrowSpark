---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
description: Trace "how is X done?" against current code and .knowledge/, verifying sync/accuracy/completeness and updating or drafting knowledge as needed
handoffs:
  - label: Repo-Wide Audit
    agent: devspark.site-audit
    prompt: Run a full audit now that this topic's knowledge is in sync
  - label: Sweep Unrelated Stale Content
    agent: devspark.release
    prompt: Clean up unrelated stale work products or knowledge noticed during this trace
  - label: Spec the Missing Behavior
    agent: devspark.specify
    prompt: This topic revealed genuinely unimplemented behavior, not just undocumented behavior
scripts:
  sh: .devspark/scripts/bash/explain-context.sh $ARGUMENTS --json
  ps: .devspark/scripts/powershell/explain-context.ps1 $ARGUMENTS -Json
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty). The input is a free-text
topic or question, e.g. "how is authentication done" or "explain the release packaging flow".

## Purpose

Answer "how is X done?" grounded in current code, while verifying that the `.knowledge/` content
covering that topic — an existing entity/flat doc, or the absence of one — stays in sync, accurate,
and complete with the code. Reuses `/devspark.site-audit`'s DELTA/KNOW finding taxonomy, scoped to
this one topic instead of the whole repository.

Load and obey the shared preamble contract at `/.devspark/templates/command-preamble-contract.md`
(installed repos) or `templates/command-preamble-contract.md` (source repos) before step 1.

## Lifecycle Position

Ad-hoc utility, alongside `/devspark.release` and `/devspark.site-audit` — not a step in the
`specify → plan → tasks → analyze → critic → implement → pr-review` gate chain. Usable any time a
developer or an agent needs a grounded answer instead of guessing, and doubles as a lightweight,
on-demand knowledge-sync check for one topic.

**Scope**: documents *existing* functionality only. Never creates a `.devspark.work/` planning
record and never implements new code — if the trace reveals genuinely unimplemented behavior, hand
off to `/devspark.specify` instead of drafting knowledge for code that doesn't exist.

## Dual-Audience Contract

Every run produces exactly three sections, in this order, so the same run serves a human reader
and a chaining agent without maintaining two representations that could drift apart:

- **`## Answer`** — human prose explaining how the topic works today. Every nontrivial claim is
  cited with a `path:line` reference. This is the direct answer to the question asked.
- **`## Findings`** — the DELTA/KNOW-coded table (id, severity, evidence, remediation), scoped to
  this topic, in the same format `/devspark.site-audit` uses. If resolution is `in-sync`, collapse
  this to one line ("No findings — matched knowledge verified against code") instead of an empty
  table with headers.
- **`## Agent Summary`** — a fenced JSON block, generated last and derived only from what the
  Answer/Findings already state (never an independent claim): `{topic, resolution, matched_ids[],
finding_ids[], applied, trace_saved, trace_path}` where `resolution` is one of `in-sync`,
  `corrected`, `drafted-new`, `proposal-pending`, `no-match-found`.

## Options

| Flag        | Behavior                                                                                                                           |
| ----------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| no flag     | Interactive: propose fixes/new drafts and ask before writing (see Outline step 7)                                                  |
| `--dry-run` | Always propose-only; never ask to write, never write — for CI or agent-chained contexts with no interactive confirmation available |

## Outline

1. Run `{SCRIPT}`, parse JSON: `TOPIC`, `KEYWORDS`, `INDEX_FRESH`, `MATCHED_KNOWLEDGE[]`,
   `MATCHED_ENTITIES[]`, `CANDIDATE_CODE_HITS[]`, `SUMMARY`.
2. **KNOW1 gate**: if `INDEX_FRESH` is false, regenerate via
   `python3 scripts/build_knowledge_index.py --repo-root .` and re-run step 1 once before
   continuing — never trust a stale index for the findings below.
3. Branch on `MATCHED_KNOWLEDGE` / `MATCHED_ENTITIES`:
   - **Has matches** → for each matched node, verify against the code at its
     `source_of_truth`/`appliesTo` paths (already resolved with existence + last-commit-date in
     `source_status`), producing topic-scoped findings using site-audit's exact codes:
     - `DELTA1`/`DELTA2` — code and knowledge contradict each other.
     - `DELTA3` — the described behavior lacks proportionate test coverage. Check `tests/` (and
       any test dirs) for coverage of the matched code itself, not only what the doc happens to
       cite — this is broader than DELTA5 below.
     - `DELTA5` — if the doc cites `verified_by: execution` or a `type: test` evidence entry,
       re-run that test now; a failure or missing test is the finding.
     - `KNOW2` — `last_verified` is older than the newest `source_status[].last_commit_date`.
     - `KNOW3` — a `source_of_truth`/`appliesTo` path's `exists` is false.
     - `KNOW4` — a matched `governance-decision`'s `constrains` has an entity whose
       `constrained_by_reciprocal` is false, or a matched entity's `constrained_by` doesn't
       resolve to a real decision.
   - **No match, or a matched entity has `missing_layers` covering this topic** → this is a
     KNOW6-equivalent gap. Use `CANDIDATE_CODE_HITS` plus direct code reading to draft the missing
     content — an entity/layer doc per `.knowledge/tooling/developer-guide.md`'s "Adding a new
     entity" steps, or a flat doc per `.knowledge/tooling/content-lifecycle.md`'s "Where does my
     new content go?" table. Draft only; never fabricate a claim, a `source_of_truth` path, or a
     test citation without evidence in `CANDIDATE_CODE_HITS` or direct code reading.
   - **Clarify before drafting when needed** → if the evidence does not establish the owning
     knowledge node, the correct layer/type, the intended scope, or whether a code delta is
     intentional, ask targeted clarification questions before proposing a durable update. Do not
     guess between competing nodes or turn an unresolved question into current truth.
   - **Knowledge update requirement** → every confirmed `DELTA` or KNOW6-equivalent gap MUST result
     in a proposed update to the owning `.knowledge/` document, its `source_of_truth`/`appliesTo`
     references, or a new typed node when no owner exists. The proposal MUST include only evidence
     from durable code and tests, and MUST remove or correct stale claims. After explicit confirmation,
     write the knowledge document and rebuild the index; never put a spec, plan, task, quickfix,
     `.devspark.work/`, or `.archive/` reference into durable knowledge.
4. Compose `## Answer` from steps 1–3's evidence — cite `path:line` for every nontrivial claim, do
   not restate the Findings mechanics here.
5. Compose `## Findings` (see Dual-Audience Contract above for the collapse-when-clean rule).
6. If any finding has a concrete remediation (a corrected doc body, a bumped `last_verified`, or a
  brand-new doc's full content, including corrected durable references where needed) **and**
  `--dry-run` was not passed: show the full proposed
   file content/diff, then ask one explicit confirmation. When a remediation exists, combine it
   with the trace-save prompt (step 8) into one question: "Apply fix and save trace? [Y/n]".
   - Yes → write the file(s), run `python3 scripts/build_knowledge_index.py --repo-root .` to
     regenerate `index.json`/`coverage.json`, and re-verify the specific finding now resolves
     before reporting success.
   - No → leave as a proposal only (`resolution: proposal-pending`); do not write anything.
7. If `--dry-run` was passed, or there was no remediation to apply, skip straight to step 8's
   trace-save question on its own ("Save trace for the record? [Y/n]") — never silently skip it,
   but `--dry-run` still means "never write," so under `--dry-run` do not ask either; report
   `trace_saved: false` unconditionally.
8. Ask (or reuse the combined step-6 prompt) whether to save this trace to
   `.devspark.work/explain/<topic-slug>-<date>.md` (never under `.knowledge/`
   — this is a work product, not durable truth). Default recommendation is yes.
   Write only on explicit confirmation; the saved file contains the same Answer/Findings/Agent
   Summary shown inline. Saved traces are ordinary `.devspark.work/` artifacts and are swept by
   `/devspark.release`'s normal retention rules like any other work product.
9. Emit `## Agent Summary` per the Dual-Audience Contract.
10. Preamble §6 next-step footer, choosing among the handoffs declared above based on what this
    run found (repo-wide follow-up, unrelated stale content noticed, or genuinely missing code).

## Constraints

- Never invents a `source_of_truth` path or test citation without evidence from
  `CANDIDATE_CODE_HITS` or direct code reading — same rule as site-audit's KNOW6.
- Never writes a knowledge file or a trace report without the explicit confirmation in steps 6–8.
- Always checks `last_verified`/path existence even when the matched content "looks right" —
  confidence is not evidence.
- Reuses `scripts/build_knowledge_index.py` for all frontmatter/git-log/index logic; never
  duplicates it (constitution Principle VI: single source of truth across languages).
- Never creates a `.devspark.work/specs/` or `.devspark.work/quickfixes/` planning record — a
  genuinely missing behavior is a signal to hand off to `/devspark.specify`, not something this
  command implements itself.
