# Closeout Contract

<!-- BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com -->

Use this contract whenever a workflow classifies a finding, evaluates an acceptance criterion, or decides whether the active route is finished.

Closeout is a **lifecycle phase, not a lifecycle command.** `/devspark.verify` runs it automatically as its second half; §6 defines where it runs and the single advanced entry point that re-runs it by hand.

Installed repos should resolve this file from `/.devspark/templates/closeout-contract.md`.
Source repos should resolve it from `templates/closeout-contract.md`.

## 1. Why This Exists

DevSpark is good at finding things. Gates, audits, and verification reliably surface additional evidence, gaps, improvements, and open questions. What it has been missing is the opposite capability: recognizing that the work is **done**.

The failure mode is a loop:

```text
verify → discover an observation → turn the observation into work
       → verify the new work → discover another observation → repeat
```

Each step is individually defensible, and the net effect is that verification silently expands the specification it was supposed to close. The route never converges, because "no remaining observations" is not a reachable state — any sufficiently careful look at any system produces more observations.

This contract replaces "eliminate every observation" with "classify every observation", which is reachable.

## 2. The Convergence Rule (non-negotiable)

> **A spec is complete when its stated objective has been resolved and every remaining finding has been classified — not when every observation generated during the work has been eliminated.**
>
> **Verification may discover work, but discovery alone does not expand the current specification.**

A finding creates mandatory work **inside the active route** only when it demonstrates one of these five **expansion triggers**:

1. failure of the stated objective,
2. an unresolved requirement,
3. a violated invariant,
4. a correctness defect, or
5. a regression caused by this change.

Absent one of those five, the finding MUST be classified under §4 and the route MUST converge. "This would be better if…", "while we're in here…", and "we should also check…" are never expansion triggers. They are Deferred Work.

The rule cuts both ways. It is not permission to wave away a failed requirement: a finding that *does* hit an expansion trigger is a Blocking Defect and is not negotiable away by classification (§4).

## 3. Acceptance-Criterion Kinds

The convergence rule only works if the route can tell what kind of statement it is evaluating. A failed requirement and a disproven hypothesis look identical in a gate report — "the evidence disagrees with the written criterion" — but one is a defect and the other is a result.

Every acceptance statement therefore declares its kind:

| Kind | Meaning | Completion effect | When evidence disagrees |
|---|---|---|---|
| `requirement` | Must be satisfied for the work to be complete | Unsatisfied → blocks | Blocking Defect |
| `invariant` | A correctness or safety constraint that must remain true | Violated → blocks | Blocking Defect |
| `hypothesis` | A proposition the work intentionally tests | Never blocks on its own | Learning / Changed Assumption — disproving it may be a successful outcome |
| `target` | A desired, measurable outcome | Does not block by itself | Accepted Limitation or Deferred Work, with the measured value recorded |

**Declaring the kind.** Annotate the criterion where it is written, e.g. `**FR-004** *(invariant)*: …` or `**SC-002** *(target)*: …`. An **undeclared criterion is read as a `requirement`** — the strictest reading — so that an unlabeled statement can never be quietly downgraded once the evidence is in.

**The anti-laundering rule (non-negotiable).** A failed `requirement` or a violated `invariant` MUST NOT be reclassified as a `hypothesis` or a `target` after the evidence arrives. The kind is declared when the criterion is written, not when it is judged. §5 allows a criterion's *interpretation* to be amended by evidence, but only with the original text, the evidence, and the revised understanding all left visible — never by silently re-labeling the kind.

## 4. Finding Classifications

Use only these four unless repository evidence proves another category is necessary:

| Classification | Definition | Blocks completion? | Required record |
|---|---|---|---|
| **Blocking Defect** | An objective, requirement, invariant, or correctness condition is not satisfied | **Yes** | What is unsatisfied, and the evidence showing it |
| **Accepted Limitation** | A known limitation consciously accepted for this outcome | No | Who accepted it, and why it is acceptable here |
| **Deferred Work** | Valid work outside the current objective | No | Where it was actually captured |
| **Learning / Changed Assumption** | Evidence disproved or refined an assumption or experimental hypothesis | No, once documented | Original expectation, the evidence, and the revised understanding |

Rules:

- **Blocking Defect is the only classification that creates mandatory work in the current route.** Everything else converges.
- **Every finding open at closeout carries exactly one classification.** An unclassified finding is itself blocking — an unclassified backlog is precisely the state this contract exists to prevent.
- **Classification is a decision, not a label.** Deferred Work with no capture location, or an Accepted Limitation with nobody named, is an unclassified finding wearing a classification's name.
- **Classification MUST NOT dismiss an expansion trigger.** A failed `requirement` or violated `invariant` (§3) is a Blocking Defect by definition. If it is genuinely acceptable to ship without it, the criterion itself must be amended through the authoring route — visibly, with the reason — not reclassified at closeout.

## 5. Experimental and Design Work

> **A disproven hypothesis is a valid outcome. Evidence may amend the interpretation of an acceptance criterion when the criterion encoded an incorrect assumption. The original hypothesis and the evidence that disproved it must remain visible.**

Experimental, design, and research routes exist to produce evidence about propositions nobody could settle in advance. Treating "the evidence contradicted what we wrote down" as an implementation failure makes those routes impossible to finish, and quietly discourages writing down a falsifiable proposition in the first place.

Example of the shape (not a rule to copy):

```text
Hypothesis:  Short, obvious move sequences reduce puzzle quality.
Experiment:  Human play test.
Evidence:    Short, obvious sequences sometimes create satisfying moments of mastery.
Outcome:     Hypothesis refined / disproven.
Result:      A successful experiment — not automatically a failed implementation.
```

The route's objective outcome in that case is `resolved-through-learning` (§7): the stated objective *was* to settle the proposition, and the evidence settled it. That outcome is available only when the objective was genuinely to test something — it is not a softer word for "we did not achieve it."

## 6. Where Closeout Runs

The convergence problem in §1 is a *lifecycle* defect. Solving it by adding a mandatory command would trade one defect for another: a developer who must memorize the framework's internal state machine to finish ordinary work is paying for rigor DevSpark was supposed to absorb on their behalf.

So the two responsibilities stay conceptually separate while sharing one developer interaction:

| Phase | Question | Optimizes for |
|---|---|---|
| **Evidence** | What does the evidence say? | Evidence quality — find freely |
| **Closeout** | Given that evidence, is this work finished? | Correct scope convergence — classify deliberately |

The separation is load-bearing, and not only for tidiness. A verification step that knows every observation it reports becomes work it must then chase has a standing incentive to notice less. Keeping convergence as a distinct phase with its own rules is what makes it safe for verification to stay curious.

**Default execution — automatic.** `/devspark.verify` runs the evidence phase, then runs this contract over the resulting findings and writes `FEATURE_DIR/gates/closeout.md` in the same invocation. The developer types one command and gets both answers. No DevSpark command may instruct a developer to "now run closeout" as a routine next step.

**Advanced entry point — `/devspark.closeout`.** The standalone command exists for reassessment, not for the normal path, and runs the *same* phase defined here — one contract, one set of rules, two ways in. It is the right tool when:

- work continued after verify ran and the completion decision is now stale,
- a human wants to reassess completion without paying for an expensive re-verification,
- a previously blocking limitation has since been explicitly accepted, or
- an experimental result needs a fresh closeout decision.

The artifact records which entry point produced it (`produced_by`), because a closeout written without a fresh evidence phase under it is a weaker claim than one written with it.

## 7. Gate Artifact Shape

The closeout phase writes `FEATURE_DIR/gates/closeout.md` — from inside `/devspark.verify` by default, or from `/devspark.closeout` when re-run by hand. Both write the same shape:

```yaml
gate: closeout
devspark_version: "<installed version, or `unknown`>"
generated: "<ISO-8601 timestamp of this run>"
status: pass | fail
blocking: true | false
produced_by: verify | closeout
objective: achieved | not-achieved | resolved-through-learning
decision: complete | not-complete
summary: "<one-line outcome>"
criteria:
  - id: FR-001
    kind: requirement | invariant | hypothesis | target
    outcome: satisfied | not-satisfied | disproven | accepted | deferred
    evidence: "<gates/verify.md mode, test_ref, or committed artifact>"
findings:
  - id: CO-001
    classification: blocking-defect | accepted-limitation | deferred-work | learning
    summary: "<what was observed>"
    rationale: "<why this classification, naming the expansion trigger it does or does not hit>"
    # classification-specific, required:
    accepted_by: "<accepted-limitation only>"
    captured_as: "<deferred-work only — the spec, quickfix, or work item it now lives in>"
    original_expectation: "<learning only>"
    revised_understanding: "<learning only>"
    # optional, and only ever written on explicit developer instruction (§8):
    promoted_by: "<who asked for this to become current scope, and when>"
regression_gates:
  - "<the named test or check that keeps this outcome true going forward>"
unclassified: []
```

**The stop condition.** This is the one canonical test for "finished", and it is deliberately reachable:

```text
objective resolved (achieved or resolved-through-learning)
AND unresolved blocking defects = 0
AND unclassified findings = 0
AND required regression gates satisfied or explicitly governed
→ decision: complete
```

It does **not** require zero accepted limitations, zero deferred work, zero learnings, or zero remaining improvement ideas. A route carrying three classified findings and no blocking defects is finished; a route carrying one unclassified finding is not.

Otherwise the decision is `not-complete` with `blocking: true`, and the route goes back to `/devspark.implement` for the blocking defects only — not for the classified findings.

**Reporting the decision.** Whichever entry point produced the artifact reports the counts, not the catalogue:

```text
Objective:              ACHIEVED
Blocking defects:       0
Accepted limitations:   1
Deferred work:          2
Changed assumptions:    1
Unclassified findings:  0
Regression gates:       GREEN

CLOSEOUT: READY
Next: /devspark.create-pr
```

## 8. Scope Expansion Requires Developer Intent

Deferred Work is a real finding with a real capture record, and acting on it immediately is a perfectly legitimate choice. What must never happen is that choice being made *for* the developer by the agent that discovered the item.

The two states are different and must stay distinguishable:

| State | Who decided | Effect on the current route |
|---|---|---|
| `discovered` | The agent, while verifying | None. It is captured and classified; the route converges. |
| `promoted` | The developer, explicitly | It becomes current scope and is tracked like any other requirement. |

**Promotion is an explicit act.** A classified non-blocking finding enters the current route only when the developer says so — in `$ARGUMENTS`, in answer to a direct question, or by naming the finding id. The route record (spec, quick spec, or quickfix) gains the work, and the closeout artifact records the finding as `promoted_by: "<who asked, and when>"`. An agent MUST NOT promote on its own authority, and MUST NOT present promotion as the obvious next step.

**No silent re-entry.** A non-blocking finding created during verification or closeout MUST NOT trigger implementation followed by another mandatory verification cycle in the same route unless it was explicitly promoted. Without this rule the loop in §1 simply reappears one level down: minor improvement → implement → re-verify → new minor improvement.

## 9. How PR Review Consumes the Decision

`/devspark.pr-review` reviews whether the convergence decision is **defensible**. It does not restart discovery from zero, and it does not treat a classified finding as unfinished work:

| Closeout state | PR review response |
|---|---|
| Unclassified finding present | **Block** — the route never converged |
| Unresolved blocking defect | **Block** |
| Failed `requirement` or violated `invariant` | **Block**, regardless of how it was classified |
| Accepted Limitation with `accepted_by` | OK |
| Deferred Work with a real `captured_as` | OK |
| Learning with original expectation, evidence, and revised understanding | OK |
| A new non-blocking improvement the reviewer noticed | **Capture, do not reopen** |

A review may absolutely find a genuine defect that nobody caught. If it meets the Blocking Defect bar in §4, it reopens the work — that is the gate doing its job. What must not reopen the work is the mere availability of another improvement, or a disagreement with a documented classification that the evidence supports.

## 10. Non-Negotiables

- **Closeout classifies; it does not discover.** It reads findings that already exist (gate artifacts, verification evidence, the route record, review threads). It MUST NOT open a new investigation, run a fresh audit, or widen the evidence search — doing so re-enters the exact loop §1 describes. If a genuinely new blocking defect is noticed in passing, record it and stop; do not keep looking.
- **Never classify to reach `complete`.** Choosing Deferred Work because Blocking Defect is inconvenient is the same failure as fabricating verification evidence, and is judged the same way.
- **Deferral must be real.** "Captured elsewhere" means a durable record exists at a named location, created before the gate is written.
- **Learning must preserve the original.** Recording the revised understanding while deleting or rewriting the original expectation destroys the only evidence that the experiment happened.
- **`not-complete` is a legitimate, useful result.** A closeout that honestly reports two blocking defects has done its job. A closeout that reports `complete` by classifying them away has not.
