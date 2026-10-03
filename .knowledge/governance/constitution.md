---
id: arrowgame-constitution
type: governance
title: ArrowSpark Constitution
appliesTo:
  - project.godot
  - scripts/**
  - scenes/**
  - resources/**
  - assets/**
  - addons/**
  - export_presets.cfg
  - web/**
---

<!--
Sync Impact Report
Version: 2.0.1 -> 2.1.0
Rationale: MINOR. The project now ships a static showcase website alongside the
game, so the Technology section names its stack, and Principle V extends
practical verification to web builds played in a browser.
Modified principles:
- V. Practical Gameplay Verification: adds browser verification for web builds.
Modified sections:
- Technology: adds the static showcase site (Astro, TypeScript, Node build) and
  the Godot Web export.
Sync validation:
- Updated: CLAUDE.md and AGENTS.md Active Technologies.
- Reviewed: README.md (no technology claims affected).
Follow-up TODOs: none.
-->

<!--
Sync Impact Report
Version: 2.0.0 -> 2.0.1
Rationale: title-only rename from "ArrowGame" to "ArrowSpark" to match the
project's actual name (project.godot config/name, ATTRIBUTION.md,
.knowledge/product/branding.md); no principle text changed.
Sync validation: none required; non-semantic clarification only.
-->

<!--
Sync Impact Report
Version: 1.0.0 -> 2.0.0
Rationale: removal of separate owner approval redefines amendment governance.
Modified principles:
- I. Simple, Maintainable Code: adds naming rules and typing guidance.
- II. Accessible Controls -> III. Accessible, Configurable Controls: explicit MUST rules.
- III. Responsive Gameplay -> IV. Responsive Gameplay: retained.
- IV. Validate Gameplay Changes -> V. Practical Gameplay Verification: required validation.
Added principles:
- II. Prefer Project-Level Template Customization.
- VI. Preserve Saved Progress and Settings.
Removed requirements: separate project-owner review of constitution amendments.
Added governance guidance: semantic versioning and compliance review expectations.
Sync validation:
- Updated: .devspark/templates/plan-template.md (project constitution gates).
- Updated: .devspark/templates/spec-template.md (applicable requirements).
- Updated: .devspark/templates/tasks-template.md (mandatory verification vs automated tests).
- Updated: .devspark/defaults/commands/devspark.tasks.md (same distinction).
- Reviewed: AGENTS.md, README.md, Codex shims, and stock command constitution references.
- No existing governance decision documents or amendment proposals require propagation.
Applied Amendments: none; direct formalization of user-confirmed discovery decisions.
Follow-up TODOs: none. Performance budgets and CI requirements intentionally deferred.
-->

# ArrowSpark Constitution

## Core Principles

### I. Simple, Maintainable Code

- Prefer clear GDScript, focused scenes, and Godot conventions (SHOULD).
- Keep changes small and justify new abstractions or dependencies with a concrete
  need (SHOULD).
- New script filenames and new functions MUST use snake_case, except names
  required by Godot.
- Prefer explicit types where they improve clarity and correctness (SHOULD).
  Full parameter and return annotations are not required for every new function.
- Existing naming exceptions do not require an unrelated bulk rename.

### II. Prefer Project-Level Template Customization

- Game-specific behavior SHOULD live in project scripts and inherited scenes.
- Addon edits are allowed when justified; document why the addon change is useful
  and consider its effect on future template updates.
- Extending template behavior is a preference, not an absolute ban on addon edits.

### III. Accessible, Configurable Controls

- Preserve keyboard/gamepad navigation and input remapping (MUST).
- When changing input or menus, verify affected controls and navigation paths
  using the supported input methods (MUST).
- Provide readable feedback, usable menus, and respect player settings (SHOULD).

### IV. Responsive Gameplay

Keep player input and gameplay feedback responsive. Avoid blocking work in the
frame loop. Investigate performance issues with measurements and validate changes
in affected game scenes.

No platform-specific frame-rate target or frame-time budget is mandated.

### V. Practical Gameplay Verification

- Gameplay changes MUST receive Godot validation of affected scripts/scenes and
  a smoke test of affected gameplay.
- Include relevant menu, pause, restart, level-transition, and input paths in the
  smoke test when those behaviors are affected.
- Add focused automated tests where they provide useful regression protection;
  automated tests are not mandatory for every new gameplay function.
- Record checks performed and their results. If a required check cannot be run,
  disclose that limitation and leave it outstanding rather than claim completion.
- Web builds MUST also be verified in a browser: the affected gameplay is
  smoke-tested in each supported desktop browser, and the results, including
  checks not performed, are recorded the same way.

### VI. Preserve Saved Progress and Settings

- Changes MUST preserve existing saved progress and settings, or provide an
  explicit migration/reset plan when compatibility will break.
- Breaking changes MUST describe the affected data and how migration or reset
  will be handled. Silent, unexplained loss of progress is not acceptable.

## Technology

- Godot 4.4 and GDScript; `.tscn` scenes and `.tres` resources; the Godot Web
  export (no threads) for the browser build.
- A static showcase website in `web/`: Astro and strict TypeScript with static
  output only, built with Node and npm (versions pinned by `package-lock.json`),
  tested with Vitest. No server-side rendering and no application framework.
- Maaack's Game Template under `addons/maaacks_game_template/`.
- Git for source control; BSW.DevSpark for specification and development workflows.
- Framework scripts are available for both PowerShell and Bash.
- Knowledge-index tooling uses Python 3.11+ and PyYAML.

## Development Workflow

- Match planning and verification effort to the scope of the change.
- Preserve existing behavior unless a requested change intentionally alters it.
- Keep current guidance in `.knowledge/`; keep temporary planning and command
  overrides in `.devspark.work/`.
- Refresh stock framework files from BSW infrastructure while preserving project
  knowledge and team/personal overrides.

## Governance

Constitution amendments MUST document the change and its reason and update the
constitution version. There is no separate constitution-approval requirement.
This does not remove any independently configured repository review controls.
Framework updates must preserve the project constitution.

Amendment versions use semantic versioning: MAJOR for incompatible governance or
principle removals/redefinitions, MINOR for new principles or materially expanded
guidance, and PATCH for non-semantic clarifications.

Changes MUST be reviewed for compliance with applicable principles. Record required
verification results and outstanding checks. SHOULD guidelines allow a documented,
reasoned exception; MUST rules require compliance with their stated alternatives.

No recurring review schedule, automated CI gate, or test coverage threshold is mandated.

**Version**: 2.1.0 | **Ratified**: 2026-09-26 | **Last Amended**: 2026-10-02
