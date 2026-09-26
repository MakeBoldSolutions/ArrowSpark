---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
description: Produce empirical proof-of-change evidence (not document review) for the declared verification proof mode(s) and persist the verify gate.
handoffs:
  - label: Create Pull Request
    agent: devspark.create-pr
    prompt: Open a PR now that verification evidence is recorded
  - label: Fix Failing Proof
    agent: devspark.implement
    prompt: Address the verify gate failure before re-running verification
    send: true
scripts:
  sh: .devspark/scripts/bash/check-prerequisites.sh --json --include-tasks
  ps: .devspark/scripts/powershell/check-prerequisites.ps1 -Json -IncludeTasks
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Workflow Position

Sits between `/devspark.implement` (code exists) and `/devspark.create-pr` (ship it). Produces empirical proof that the change works — distinct from `/devspark.analyze`/`/devspark.critic`, which review documents, not running code.

- **Owns**: executing the proof mode(s) declared in `spec.md`'s `required_gates` (see `/.devspark/templates/verification-contract.md` or `templates/verification-contract.md` in source repos), recording actual commands + actual output as evidence, writing `FEATURE_DIR/gates/verify.md`.
- **Does NOT own**: re-litigating spec/plan/tasks consistency (`/devspark.analyze`), adversarial risk hypotheses (`/devspark.critic`), writing new tests or code (`/devspark.implement`), the PR itself (`/devspark.create-pr`).

## Definition of Done

Done when every `verify:<mode>` entry declared in `spec.md`'s `required_gates` has a corresponding `modes:` entry in `gates/verify.md` with real evidence and a `pass`/`fail` status. If a mode cannot be executed in this environment, the gate records `fail` with the concrete blocker — never a fabricated pass.

## Non-Negotiable: Evidence, Not Narration

Every evidence block MUST be the actual command(s) run in this session and their actual output (or a reference to a committed artifact, e.g. a CI log or fixture diff). A description of what *should* happen if the command were run is not evidence and MUST NOT be recorded as a `pass`.

## Genuine Fix Guard (command-preamble-contract.md §9)

Load and obey the shared preamble contract at `/.devspark/templates/command-preamble-contract.md` (installed repos) or `templates/command-preamble-contract.md` (source repos) — in particular §9 (Genuine Fix Discipline).

When the change under verification resolved a lint rule, complexity/length metric, or code-smell finding, a green linter run is **not** sufficient evidence of a genuine fix. The recorded evidence MUST also show the behavioral intent changed — e.g. the extracted unit is independently exercised by a probe, the previously swallowed error is now surfaced in output, the flattened path is covered by the same probe. A proof that only shows "the tool's number went down" while the probe's behavior is unchanged is a gamed fix: record that mode `status: fail` with the note "resolves the check, not the intent" and route back to `/devspark.implement`.

## Outline

Multi-app scope and the 2-tier override check for scripts are defined by the shared preamble contract already loaded above.

1. Run `{SCRIPT}` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS. All paths must be absolute.

2. **Determine required proof modes**: Read `required_gates` from `spec.md`'s YAML frontmatter — or, if this branch has no `spec.md` (quickfix route), from the quickfix record's frontmatter at the path `FEATURE_SPEC` resolves to (`.devspark.work/quickfixes/<branch>.md`). Collect every `verify:<mode>` entry. If none are declared:
   - If the user explicitly asked for verification anyway, ask which mode applies (offer the table from the verification contract §2) and proceed with that mode for this run only — do not silently skip.
   - Otherwise, report that no verification is required for this spec and stop.

3. **Load the verification contract**: Resolve `/.devspark/templates/verification-contract.md` (installed repos) or `templates/verification-contract.md` (source repos) and load it for the exact evidence requirements of each declared mode (§2 of that contract).

4. **Execute each declared mode.** For each `verify:<mode>` entry:

   - **`snapshot-neutral`**: Identify (or ask the user for) a deterministic probe that exercises the refactored code path (a test, a script, a CLI invocation, a rendered output). Capture its output at the pre-change commit (checkout/stash if needed), capture it again at the current commit, and diff the two. Record the exact commands and the diff (empty diff = pass; any non-empty diff must be individually justified as an intentional, named change or the mode fails).
   - **`golden`**: For each golden fixture affected by the change, render it before and after and compare byte-for-byte (or via the project's existing golden-test tooling if present). Record the fixture names, the comparison command, and the result.
   - **`regression-pinned`**: Identify the new/updated test(s) that pin the bugfix. Run them against the pre-fix code (via `git stash`, checkout of the parent commit, or a temporary revert) to confirm they fail, then run them against the current code to confirm they pass. Record both runs' actual output.
   - **`shadow-agreement`**: Identify the traffic/replay sample and the agreement threshold (from spec.md or ask the user if undeclared). Run old vs. new side-by-side against that sample, compute the agreement rate, and record the actual measured rate against the threshold.
   - **`end-to-end`**: Drive the real flow the feature enables (the actual CLI commands, API calls, or UI steps — not a description of them) and record the actual results at each step.

   If any mode cannot be executed (missing tooling, no traffic sample, no prior commit to diff against, etc.), record `status: fail` for that mode with the specific blocker — do not mark it `pass` and do not skip it silently.

5. **Persist Gate Artifact**: Write `FEATURE_DIR/gates/verify.md` following the shape in verification-contract.md §4:

   ```yaml
   gate: verify
   status: pass | warn | fail
   blocking: true | false
   summary: "<concise outcome>"
   modes:
     - mode: snapshot-neutral
       status: pass | fail
       evidence: |
         <actual commands + actual output>
   ```

   For every mode that passed by running a named, committed test (not an ad hoc probe), also record
   `test_ref: <path>::<test name>` alongside that mode's evidence. This is the citable pointer
   `/devspark.implement`'s evidence-preference bullet consumes when it records `verified_by:
   execution` on a `.knowledge/` node for this change — record it here, where the actual proof just
   ran, rather than leaving implement to reconstruct which test verified what.

   - `status: pass` only if every declared mode's entry is `pass`.
   - `status: fail` if any declared mode is `fail`; `blocking: true` in that case.
   - Ensure `FEATURE_DIR/gates/` exists; replace the prior `verify.md` artifact if present, don't append.

6. Report the outcome per mode and, if any mode failed, route the user to `/devspark.implement` to address the gap before re-running this command. If all modes pass, note readiness for `/devspark.create-pr`.

**Autonomy override**: `--auto` (or a standing autonomy instruction) does not change the evidence requirement — it never authorizes a fabricated pass. `--auto` only skips the confirmation prompt in step 2 when a mode is ambiguous, defaulting to the most conservative applicable mode from the verification contract's table, and proceeding to execute it.
