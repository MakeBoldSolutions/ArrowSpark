# Audit Remediation Plan â€” 2026-09-29

Status: PROPOSED â€” awaiting user confirmation. No remediation executed.

Source: `.devspark.work/audit/2026-09-29_results.md` at main revision 8a00239.

## Objective

Address all three audit findings with focused comment and documentation changes, and an explicit disposition for the allowed taxonomy override. Preserve gameplay, test assertions, player data, and existing audit evidence.

## Approval and Branch

Current branch: `main`.
Proposed implementation branch: `chore/address-site-audit-2026-09-29`.

Approval of this plan authorizes creating and switching to that branch and executing the steps below. Existing untracked audit artifacts and this plan will remain in the working tree and carry onto the branch. No commit, push, or PR is included in this plan.

## Steps

### 1. Remove escaped review references (DELTA4)

Intent: comments must explain the current focus behavior without depending on temporary review records.

- Rewrite the focus explanation in `scenes/menus/main_menu/puzzle_select_menu.gd` to describe the inherited show/hide behavior and explicit first-entry focus.
- Rewrite the related comment in `tests/puzzle_layout_check.gd` and matching prose in `tests/README.md`.
- Remove `critic-001`, command attribution, and any adjacent planning-only labels in the touched comment blocks, such as `US2`.
- Remove the adjacent unsupported statement that Options/Credits have no keyboard/gamepad MUST requirement; keep the explanation scoped to this menu's actual behavior.
- Preserve all executable statements, assertions, signals, and focus logic.

Acceptance: touched explanations are self-contained and no longer cite temporary workflow identifiers.

code_ref: scenes/menus/main_menu/puzzle_select_menu.gd; tests/puzzle_layout_check.gd
knowledge_ref: n/a â€” current behavior and knowledge remain unchanged.
Other durable output: tests/README.md

### 2. Correct regression documentation (DOC1)

Intent: the documented command should accurately describe the suites and catalog it verifies.

- Update `tests/README.md` and the module docstring in `tests/run_puzzle_regressions.py` to describe nine suites: rules, analyzer, catalog/session, scoreboard, departure geometry, viewport transform, layout, canvas, and presentation.
- Reconcile numbering with the actual launcher execution and include the missing analyzer/scoreboard descriptions wherever absent.
- Correct current full-catalog claims to 21 entries: eight baseline puzzles, six structural experiments, one large-canvas fixture, and six Gordian Knot experiments.
- Preserve legitimate references to the original 14-entry fingerprint baseline and the large-canvas puzzle at position 15.
- Correct adjacent stale file paths in these descriptions, including `scripts/puzzle_session.gd`.

Acceptance: both overviews agree with executed suites and current catalog assertions; historical baseline counts retain their intended meaning.

code_ref: tests/run_puzzle_regressions.py (docstring only)
knowledge_ref: n/a â€” the existing knowledge already describes 21 entries.
Other durable output: tests/README.md

### 3. Disposition the taxonomy advisory (KNOW-ADVISORY)

Recommended decision: retain `type: authoritative-reference` in `.knowledge/reference/gordian-knot-experiments.md` as an intentional override. The document combines objective measurements with explicitly qualified human observations and current design vocabulary; changing its type merely to eliminate an advisory is not necessary.

- Record the rationale and accepted advisory in a remediation section of the audit report.
- Preserve the historical finding and tool output; distinguish accepted/dispositioned from mechanically eliminated.
- Do not modify the taxonomy registry or generated knowledge artifacts for this decision.

Acceptance: the advisory has an explicit reasoned disposition. The tool may continue to emit it; that is expected and must be reported honestly.

code_ref: n/a â€” metadata disposition only.
knowledge_ref: .knowledge/reference/gordian-knot-experiments.md (reviewed; unchanged)

## Validation

- Review the diff to verify that only comments, module docstrings, documentation, and temporary audit records changed.
- Search the touched durable files for escaped workflow identifiers and stale current-catalog/suite claims; inspect matches rather than replacing historical numbers blindly.
- Compare the documented nine suites against the launcher's actual functions and invocation paths and the 21-entry catalog assertion.
- Compare the Python launcher's AST before/after with its module docstring excluded; verify GDScript changes are comment-only.
- Run `git diff --check`.
- Run `python .devspark/scripts/build_knowledge_index.py --repo-root . --check`.
- Run the knowledge-integrity check with archive pruning before traversal if needed; report the expected taxonomy advisory and any other output. Preserve stock framework files; do not silently repeat the audit's known root-rglob traversal limitation.
- Do not add tests or rerun gameplay suites for these comment/documentation-only edits. Retain the audit's passing regression evidence and its explicit Godot 4.4/desktop limitations. If executable changes prove necessary, stop and revise the plan before expanding scope.

## Completion Record

Append a dated remediation section to the audit report with changed paths, validation results, and dispositions: DELTA4 resolved, DOC1 resolved, KNOW-ADVISORY accepted intentionally. Mark this plan complete only after validation succeeds. Keep original audit findings and logs intact as historical operational evidence.

## Out of Scope

Gameplay changes; addon updates; framework scanner repairs; dependency upgrades; broad refactors; new performance or security audits; Godot 4.4 installation and desktop/controller release validation; commit/push/PR actions.

## Confirmation Requested

Approve this plan, including creating and switching from `main` to `chore/address-site-audit-2026-09-29` and retaining the intentional taxonomy override, before implementation begins.

## Execution Record

Completed 2026-09-29 14:33:12 UTC on `chore/address-site-audit-2026-09-29`. All three steps completed with the approved taxonomy disposition. Validation and changed-path evidence are recorded in the audit report remediation section. No commit or push performed.
