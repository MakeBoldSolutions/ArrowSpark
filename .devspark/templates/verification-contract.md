# Verification Contract

<!-- BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com -->

Use this contract whenever a workflow declares, produces, or consumes a `verify` gate (`gates/verify.md`).

Installed repos should resolve this file from `/.devspark/templates/verification-contract.md`.
Source repos should resolve it from `templates/verification-contract.md`.

## 1. Why This Exists

The document gates (`checklist`, `analyze`, `critic`) validate that artifacts are internally consistent and that risks are named. None of them require demonstrating that the change actually works. This contract closes that gap: it converts empirical-proof practices (baseline-before-change, golden renders, regression-pinned tests, shadow agreement, end-to-end drive-through) from one-off spec prose into a declared, checkable gate.

Findings in `gates/verify.md` are **evidence**, not opinions: every claim MUST be backed by a command that was actually run and its actual output (or a reference to a committed artifact/log), not a description of what *should* happen if run.

## 2. Proof Modes

A spec declares which proof mode(s) it requires via `required_gates: verify:<mode>` in its frontmatter (see §3). `/devspark.specify`'s route classification assigns a default mode per route (see `specify.md`); the user or `/devspark.plan` may add or override it explicitly.

| Mode                | Use when…                                                                 | Minimum evidence required                                                                                                                                     |
| -------------------- | -------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `snapshot-neutral`   | Pure refactor — behavior must not change                                  | Baseline output captured **before** the change, the same probe re-run **after** the change, and a diff of the two shown to be empty (or containing only the intentionally-frozen deltas, each named and justified) |
| `golden`             | Prompt/template/rendering change where output shape is the contract       | Byte-identical (or intentionally-diffed-and-justified) render comparison for each golden fixture, before vs. after                                            |
| `regression-pinned`  | Bugfix — the defect must be provably fixed and provably absent before      | A test that fails on the pre-fix code (shown failing via `git stash`/checkout-old-code run) and passes on the fixed code                                      |
| `shadow-agreement`   | Routing/engine/model swap where old and new must agree on live/replay traffic | An agreement-rate measurement against a defined traffic sample or replay set, with the threshold declared and the actual measured rate reported              |
| `end-to-end`         | New feature — the real flow must be demonstrably exercised                 | The actual commands/steps used to drive the flow end-to-end, and their actual results (not a description of expected behavior)                                |

A spec MAY require more than one mode (e.g., a migration might need both `regression-pinned` and `shadow-agreement`). List all required modes; the gate is not satisfied until every declared mode has its own evidence block.

## 3. Frontmatter Contract

Specs that require verification MUST include `verify` in `required_gates`, qualified by mode:

```yaml
required_gates: checklist, analyze, critic, verify:snapshot-neutral
```

Multiple modes are comma-separated within the same `verify:` token set is not valid YAML scalar syntax — list each mode as its own `verify:<mode>` entry, e.g. `required_gates: checklist, analyze, critic, verify:regression-pinned, verify:shadow-agreement`.

Validation rules:

- If `required_gates` names one or more `verify:<mode>` entries, `/devspark.implement`'s gate pre-flight (see `implement.md`) MUST refuse to proceed until `gates/verify.md` exists, its `modes:` list is a superset of the ones required, and every listed mode's `status` is `pass`.
- A `verify` requirement is never satisfied by document review alone — `/devspark.critic` and `/devspark.analyze` MUST NOT mark it resolved.

## 4. Gate Artifact Shape

`/devspark.verify` (or a manual/CI-produced equivalent) writes `FEATURE_DIR/gates/verify.md`:

```yaml
gate: verify
status: pass | warn | fail
blocking: true | false
summary: "<concise outcome>"
modes:
  - mode: snapshot-neutral | golden | regression-pinned | shadow-agreement | end-to-end
    status: pass | fail
    evidence: |
      <actual commands run and actual output/results — not a plan to run them>
```

## 5. Non-Negotiables

- **Never fabricate evidence.** If a proof mode can't be executed in this environment (no test runner, no traffic sample, no baseline artifact), the gate status is `fail` with the reason stated — not a hypothetical pass.
- **Re-run on drift.** Like `analyze`/`critic` (see the gate-staleness convention in those commands), `verify` evidence is tied to the code state it was captured against; if the implementation changes materially after verification, re-run before `/devspark.create-pr`.
- **Evidence over narration.** A finding that says "this should work because X" is not evidence. A finding that shows the command, its output, and the pass/fail conclusion is.
