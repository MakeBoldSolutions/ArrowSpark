---
id: arrowgame-constitution
type: governance
title: ArrowGame Constitution
appliesTo:
  - project.godot
  - scripts/**
  - scenes/**
  - resources/**
  - assets/**
  - addons/**
---

# ArrowGame Constitution

Adapted from the BSW.DevSpark constitution seed for this project's agreed defaults.

## Core Principles

### I. Simple, Maintainable Code

Prefer clear GDScript, focused scenes, and Godot conventions. Keep changes small and
avoid abstractions or dependencies without a concrete need. Keep game-specific
behavior in project scripts and scenes where practical.

### II. Accessible Controls

Preserve keyboard and gamepad support, configurable inputs, and usable menus.
Provide readable feedback and respect player settings. Check affected navigation
and input paths when changing controls or UI.

### III. Responsive Gameplay

Keep player input and gameplay feedback responsive. Avoid blocking work in the
frame loop. Investigate performance issues with measurements and validate changes
in the affected game scenes.

### IV. Validate Gameplay Changes

Validate changed scripts and scenes with the available Godot tools. Play through
affected behavior, including relevant menu, pause, restart, and level transitions.
Use focused automated checks when they provide useful regression protection.
Report checks performed and any validation that could not be completed.

## Technology

- Godot 4.4 and GDScript.
- Godot scenes and resources (`.tscn` and `.tres`).
- Maaack's Game Template under `addons/maaacks_game_template/`.
- Git for source control.
- BSW.DevSpark for specification and development workflows, with PowerShell and
  Bash framework scripts installed for cross-platform use.
- Knowledge-index tooling uses Python 3.11+ with PyYAML.

## Development Workflow

- Match planning and verification effort to the scope of the change.
- Preserve existing behavior unless a requested change intentionally alters it.
- Keep current project guidance in `.knowledge/` and temporary planning or command
  overrides in `.devspark.work/`.
- Refresh stock framework files from BSW infrastructure; preserve project knowledge
  and team or personal overrides during upgrades.
- Review changes against the core principles and record relevant verification.

## Governance

This constitution defines project-wide principles for ArrowGame. Amendments must
state the change and its reason, be reviewed by the project owner, and update this
document and its version. Framework updates must preserve this project constitution.

**Version**: 1.0.0 | **Ratified**: 2026-09-26 | **Last Amended**: 2026-09-26
