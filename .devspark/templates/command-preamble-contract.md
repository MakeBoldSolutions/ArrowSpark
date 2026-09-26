# Command Preamble Contract

<!-- BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com -->

This contract centralizes shared command preamble behavior to reduce prompt bloat and improve consistency.

Commands that reference this contract MUST load and obey it before step 1.

## 0. Plan Temporarily, Review the Delta

Planning is an implementation aid, not a permanent compliance record.

- Authoring routes write temporary specs, plans, tasks, checklists, and gates under
  `.devspark.work/`. Route-specific traceability stays inside that active bundle.
- Implementation updates behavior, affected tests, and the current `.knowledge/` nodes that
  describe that behavior in the same change. Durable code, tests, and knowledge MUST NOT contain
  spec, task, quickfix, feature, or requirement identifiers.
- Traceability is strictly one-directional: the ephemeral spec/plan/tasks/quickfix record links to
  the durable code, test, and knowledge files it produced via its linkage fields (`code_ref` may
  name both production and test files; `knowledge_ref` names current `.knowledge/` files). It is
  never the reverse — durable code, tests, and `.knowledge/` MUST NOT carry a comment, docstring,
  identifier, or link back to any spec, plan, task, quickfix, or feature document, live or archived.
- Every implementation task or checklist item that changes behavior MUST record all affected
  durable production-code, test, and current-knowledge paths in the temporary spec/plan/tasks or
  quickfix record before that item is marked complete. Use `n/a` only when a category was genuinely
  not changed, with a brief reason. This is required traceability in the temporary record, not
  permission for any durable file to reference the temporary record.
- A durable `.knowledge/` node's `source_of_truth` or evidence may cite only durable code or test
  files. It MUST NOT cite a spec, plan, task, gate, quickfix record, `.devspark.work/`, or
  `.archive/` path. Planning artifacts may cite that node, but the node must remain self-contained
  current truth after the planning bundle is deleted or archived.
- After all required verification passes, implementation populates `code_ref`/`knowledge_ref`
  linkage on every item in the planning bundle and leaves it live under `.devspark.work/` — it
  never archives the bundle itself. `/devspark.release` is the sole command that later confirms
  every item's linkage and moves the completed bundle to `.archive/{YYYY-MM-DD}/` (preserving its
  relative path minus the `.devspark.work/` prefix), which can happen across more than one release
  window. It is not released, mined later, or reconstructed by downstream commands from
  `.devspark.work/`.
- **No DevSpark command reads, lists, enumerates, or globs `.archive/`, under any circumstance.**
  It is a write-only destination from every command's perspective — commands move content into it
  and never look back. Purging `.archive/` is a human action only; no command deletes from it on
  any schedule.
- PR creation, review, release, audit, and maintenance evaluate the resulting delta: code,
  current `.knowledge/`, tests, verification evidence, Git history, and host metadata. Missing
  planning records under `.devspark.work/` are normal and MUST NOT be reported as a defect or
  recovered from there.
- `.knowledge/` contains current authoritative truth only. Update or delete obsolete content;
  never retain decision logs, rationale archives, supersession chains, lifecycle states, or
  historical copies there. Git is the sole history for `.knowledge/` — the `.archive/{YYYY-MM-DD}/`
  convention above applies only to retired `.devspark.work/` planning artifacts, never to `.knowledge/`.

### Four-Root Placement

| Root | Owner | Purpose |
|---|---|---|
| `.devspark/` | Framework | Installed stock prompts, scripts, templates, and schemas |
| `.devspark.work/` | Repository | Temporary planning plus operational work products and overrides |
| `.knowledge/` | Repository | Current authoritative architecture, governance, reference, patterns, and operations, plus published user-facing guidance under `.knowledge/guides/` |
| `.archive/` | Repository | Landing place for all old work products, grouped by release; write-only, sole writers are `/devspark.release`, `/devspark.constitution`, and `/devspark.evolve-constitution` |

Install and upgrade may refresh `.devspark/` only. Migration between major layouts is an explicit,
human-confirmed operation and is never performed by install or upgrade.

## 1. User Input Rule

If `$ARGUMENTS` (or equivalent user input) is non-empty, you MUST consider it before proceeding.

## 2. Multi-App Scope Resolution

If `.devspark.work/devspark.registry.json` exists with `mode: "multi-app"`:

- Check for `--app <id>` in user input.
- Resolve work products from `{app.path}/.devspark.work/`, current knowledge from
  `{app.path}/.knowledge/`, and published guidance from `{app.path}/.knowledge/guides/` when app
  context is provided.
- Print resolved scope (app name, doc root) at the start of output.

If no app context is provided, fall back to repository-root `.knowledge/guides/` as before, but print a visible deprecation warning: "multi-app repos should pass `--app <id>`; this will require confirmation in a future release." (Phase 1 of a two-phase rollout — the fallback becomes a hard STOP asking which app in a later, separately-dated release, never silently in a patch.)

## 3. Script Resolution (2-tier override)

Before running any stock script declared in command frontmatter:

- If `.devspark.work/scripts/powershell/<filename>` (PowerShell) or `.devspark.work/scripts/bash/<filename>` (Bash) exists, run that override instead.
- Preserve all original arguments.
- Team overrides in `.devspark.work/scripts/` always take priority over `.devspark/scripts/`.

## 4. Shell Quoting Reminder

For single quotes in arguments like `I'm Groot`, use `I'\''m Groot` or double quotes when possible.

## 5. Metrics Emission Contract (Disabled by Default)

Command metrics are temporarily disabled unless the developer explicitly sets
`DEVSPARK_METRICS_ENABLED=true`. When enabled, append one JSON line after command completion
(success or failure) to:

- `.devspark.work/metrics/devspark-metrics.jsonl`

Each line SHOULD include, when available:

- `ts_utc` (ISO timestamp)
- `command` (e.g., `specify`, `analyze`)
- `status` (`success` | `fail`)
- `duration_ms`
- `branch`
- `feature_dir`
- `classification`
- `route_intent`
- `risk_level`
- `required_gates`
- `findings` object (`showstopper`, `critical`, `high`, `medium`, `low` counts)
- `author` (if available)

Use best-effort writes; metrics logging failures must never block the primary workflow.

## 6. Next-Step Footer Contract

To reduce the cognitive load of remembering which command comes next, every command that references this contract SHOULD end its output with a consistent two-line footer:

```text
Where you are: <short state label>
Next: <the single recommended command, or "run /devspark.next">
```

Guidance:

- Keep it to those two lines — it is a signpost, not a summary.
- When the command cannot confidently name the next step, fall back to `Next: run /devspark.next` so the developer always has one safe move.
- The footer is advisory; it never replaces a command's own gate results or required confirmations.
- Omit the footer only for pure query/list commands where "next" is meaningless.

## 7. Repository Configuration ("set once" facts)

Configuration is split so shared repo facts and per-developer preferences never mix:

- **`.devspark.work/devspark.json`** (committed) holds **repo facts + team policy**: `platform`, `organization`, `project`, `repository`, and `policies.*` (e.g. `protect_main`).
- **`.devspark.work/devspark.user.json`** (git-ignored, per developer) holds **personal preferences**: `assistant.name`, `shell`, and `preferences.*` (e.g. `auto_push`).

Read them via the shared helpers in `common.ps1` / `common.sh` (`Get-DevSparkConfig`, `Get-DevSparkUserConfig`, `Get-AssistantName`, `Get-DevSparkPreference`; bash: `get_devspark_config_value`, `get_devspark_user_config_value`, `get_assistant_name`, `get_devspark_preference`). Resolution precedence is **env var → user file → repo file → default**. Recognized keys:

- `assistant.name` (user) — the developer-chosen name for the guide voice (default `Spark`; env override `DEVSPARK_ASSISTANT_NAME`). Address and sign as this name. When the developer addresses this name in natural language (e.g. "hey Spark, where am I", "Spark, what's next"), treat it as invoking `/devspark.next` and answer with the orientation (repo, branch, platform) plus the next step.
- `platform` (repo) — `github` | `azdo` | `gitlab`. Authoritative host; resolved by `platform.*` (config wins over auto-detection). Never re-probe `gh`/`az` to guess the host when this is set.
- `shell` (user) — `powershell` | `bash`. Preferred script flavor when both `sh:` and `ps:` variants exist. Lets a macOS teammate choose `bash` without touching shared repo facts.
- `preferences.auto_push` (user) — when `true`, the developer has **pre-authorized** pushing the current feature/quickfix branch to its remote after a commit, without asking each time. Treat it like a standing `--auto` for that one action.
- `policies.protect_main` (repo) — team policy: when `true`, never commit or push directly to the default branch; branch first.

Git identity defaults to `git config user.name`. It may optionally be overridden per developer in the user file via `git_user` (env `DEVSPARK_GIT_USER` wins) — useful as a friendlier display name and as the deterministic key for personal `.devspark.work/{git-user}/` prompt and script overrides. Resolve it via `Get-GitUser` / `get_git_user`.

**`git_user` uniqueness (important):** because `git_user` is also the folder key for personal overrides (`.devspark.work/{git-user}/commands/`, `.devspark.work/{git-user}/scripts/`), two developers who set the same `git_user` value — or who copy a teammate's `devspark.user.json` as a starting template without changing it — will silently share the same personal override folder and pick up each other's customized prompts/scripts. Use a value that's unique within the repo (e.g. `firstname-lastinitial` or your actual `git config user.name`, which is already unique per commit author) rather than something generic like a role name or team name.

**Safety rules for `auto_push` (non-negotiable):**

- Only ever push the current topic branch to its own upstream. Never `--force`.
- `auto_push` never overrides `protect_main`: pushing directly to the default branch always requires an explicit human decision.
- Publishing a branch is visible to others but reversible; opening/merging a PR is not covered by `auto_push` and still follows the normal PR flow.

## 8. Branch Safety (non-negotiable)

DevSpark commands MUST NOT create, switch (`git checkout` / `git switch`), rename, `reset`, or otherwise move `HEAD` to a different branch without the developer's explicit, in-the-moment confirmation.

- Before any branch create or switch, show the **current branch** and the **proposed branch** and ask. Wait for an explicit yes before running the git command.
- This confirmation is **required even under `--auto`** and even when `auto_push` is set. Changing the working branch is a context change only a human may approve — it is never auto-bypassed.
- If the working tree has **uncommitted changes**, warn that switching would carry them onto the other branch, and let the developer commit, stash, or decide first.
- Never `git reset --hard`, force-delete a branch, or discard commits/branches without explicit confirmation.
- `policies.protect_main` ("branch first") does **not** authorize an unattended switch: offer to create the branch and wait for the yes.

## 9. Genuine Fix Discipline (anti-gaming)

When a task, gate finding, or automated check (lint rule, static-analysis metric, code-smell warning, test failure) names a specific violation, do not react to the bare metric alone — e.g. "function too complex (11 > 5)" or "bare except". A published pre-registered eval (prompt-vs-metric-eval, comparing bare-metric vs. behavioral-intent phrasing across two Claude models) measured genuine-fix rates as low as 5.6% when the model reacted only to a raw linter number, versus 83% when it was first asked to reason about the underlying intent — and the stronger model gamed the bare metric *more*, not less.

Before fixing, state in one sentence the behavioral intent the check is a proxy for (e.g. "this function should do one thing — what is it, in one sentence?"; "this handler should name and surface the specific error, not swallow it"), then implement a fix that satisfies that intent — not just the number. Before marking the finding resolved, confirm it isn't a gamed fix:

- **Complexity/length findings**: a genuine fix reduces actual branching or splits real responsibilities apart; splitting the same branches into helper functions purely to lower the tool's count is gamed.
- **Exception-handling findings**: a genuine fix names a specific exception type and does something with it (log, re-raise, handle); narrowing the `except` clause while still silently discarding the error is gamed.
- **Any finding**: if a human reviewer would say "this only satisfies the tool without changing behavior," it is gamed, not done.

Applies wherever `/devspark.implement` resolves an `analyze`/`critic` finding, `/devspark.quickfix` implements its root-cause fix, or any code-quality remediation task is performed.

### 9.1 Intent Cues for Common Structural Smells

Stating the behavioral intent from scratch each time invites inconsistent phrasing. For the smells a linter or static-analysis tool most commonly flags, use the intent cue below as the starting sentence, then apply the genuine-fix test in the row before marking the finding resolved:

| Smell (tool-agnostic)                          | Intent cue (say this first)                                                        | Genuine fix looks like                                                         | Gamed fix looks like                                                                  |
| ----------------------------------------------- | ------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| Oversized function / high complexity            | "This function should do one thing — what is it, in one sentence?"                  | Extracting a real sub-responsibility into a named, independently testable unit | Splitting branches into helpers with no real boundary, purely to lower the count       |
| Too many parameters                             | "These parameters travel together — is there a missing object/abstraction?"        | Introducing the missing type and passing it instead of the loose bag           | Wrapping the same list in an untyped `{ ...everything }` bag that renames the coupling |
| Deep nesting                                    | "What is the guard clause or early return that removes this level?"                | Inverting conditions / early-returning so the happy path is flat               | Wrapping the same nested logic in an extra function to hide it from the counter        |
| Duplicated code                                 | "What is the one behavior these copies implement, and where should it live once?"   | Extracting a shared implementation both call sites use                        | Renaming variables/reformatting one copy so a text-diff tool no longer matches it      |
| Swallowed / bare exception                      | "What should the caller learn when this fails, and what should happen next?"       | Naming the specific exception type and logging, re-raising, or handling it     | Narrowing the `except`/`catch` clause while still silently discarding the error        |
| Unused variable / import / dead code            | "Does this code path still get exercised — by whom?"                                | Removing it, or wiring it in if it was meant to be used                       | Prefixing with `_`/adding a suppression comment purely to silence the tool             |
| Oversized file / module                         | "What are the distinct responsibilities living in this file?"                      | Splitting along real seams (one responsibility per file)                       | Moving code to a second file with no coherent boundary just to shrink line counts      |

This table is a starting point, not a substitute for judgment — a smell not listed still requires stating intent before fixing, per the rule above.

**Cross-language note**: the intent cues and the genuine-fix test are language-agnostic. The same gamed patterns appear across ecosystems — an empty `catch (e) {}` / `catch {}` (JS/TS, C#, Java) or a `catch (Exception)` that swallows, and suppressions such as a `_`-prefixed name, `// eslint-disable-next-line`, `# type: ignore`, `#pragma warning disable`, or `[SuppressMessage]` added purely to silence the tool. Apply the same intent test regardless of language: would a reviewer say the behavior changed, or only the tool's verdict?

### 9.2 Citing a Constitution Principle

If the project constitution (`/.knowledge/governance/constitution.md`) declares a genuine-fix / intent-over-metrics principle, a gate command (`/devspark.critic`, `/devspark.analyze`, `/devspark.pr-review`, `/devspark.site-audit`) that flags a gamed fix SHOULD cite that principle ID in the finding, escalating it from process guidance to a constitution violation (which those gates already treat as their highest severity). If no such principle exists, §9 still stands on its own as a non-negotiable process rule — the citation is an escalation hook, not a precondition.
