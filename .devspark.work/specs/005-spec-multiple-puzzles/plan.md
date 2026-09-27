# Implementation Plan: Multiple Authored Puzzles and Session-Only Puzzle Selection

**Branch**: `005-spec-multiple-puzzles` | **Date**: 2026-09-27 | **Spec**: [spec.md](spec.md)
**Repository root**: C:/GitHub/MakeBoldSolutions/ArrowGame
**Feature directory**: C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/005-spec-multiple-puzzles

## Rationale Summary

### Core Problem

`arrow_puzzle.gd` hardcodes `PuzzleDefinition.create_fixed()` as its only source of content, even
though `PuzzleDefinition`/`PuzzleSolver` are already generic. Nothing currently proves the engine
supports more than one puzzle, and the inherited template's Level system (scene-per-level,
persistence-first) is architecturally mismatched with this game's reusable-scene, data-driven
design.

### Decision Summary

Insert a small static-registry `PuzzleCatalog` (plain GDScript, 8 entries) between the domain and
the controller, resolved through a process-lifetime `PuzzleSession` static holder instead of the
hardcoded call. Build Level Select and Results' Next Puzzle directly against the catalog, reusing
existing menu scaffolding (button, sub-menu open/close, results panel) rather than the addon's
scene-per-level infrastructure.

### Key Drivers

- Prove the existing domain/solver/rendering/departure pipeline generalizes to real content.
- Preserve the session-only save boundary already established and tested in spec 004.
- Reuse existing, already-accessible menu/results UI scaffolding instead of duplicating it.
- Ship genuinely varied handcrafted content as evidence for later generation/difficulty work,
  without building either system now.

### Source Inputs

The authoritative spec and its clarifications; inspected `arrow_puzzle.gd`,
`puzzle_board.gd`/`arrow_view.gd` (unaffected), `puzzle_results.gd`/`.tscn`,
`main_menu_with_animations.gd`/`.tscn`, the addon's `LevelListManager`/`LevelListLoader`/example
Level Select script, `PuzzleDefinition`/`PuzzleSolver`, existing regression launchers, and
resolved current knowledge below. See research.md for decisions and repository evidence.

### Tradeoffs Considered

See research.md's per-decision Alternatives Considered; summarized: rejected Resource/JSON
authoring (FR-004), rejected a new autoload in favor of the existing `GameVisualStyle` static-var
precedent, rejected building new sub-menu infrastructure in favor of reusing the existing hidden
Level Select scaffolding, rejected in-place attempt reset for Next Puzzle in favor of reusing the
existing scene-reload mechanism Replay already relies on.

### Architectural Impact

One new content layer (`PuzzleCatalog`) and one new session layer (`PuzzleSession`), both plain
`RefCounted` classes with static members — no new autoloads, no new scenes beyond one small Level
Select sub-menu, no changes to `PuzzleDefinition`'s shape, no changes to domain/solver/rendering/
departure behavior. The controller, results panel, and main menu each gain a small, additive
dependency on the catalog/session layer. Test assumption changes: none of the existing test
suites' assumptions about a single fixed board are broken — they continue to exercise
`PuzzleDefinition.create_fixed()` directly (untouched), while new tests exercise the catalog.

### Reviewer Guidance

Check: `PuzzleDefinition` gained no fields; `PuzzleCatalog`/`PuzzleSession` never reference
`GlobalState`/`GameState`; Replay and pause-menu Restart correctness for a non-first puzzle relies
on the static-var-survives-reload mechanism (verify this is actually tested, not just asserted);
Level Select and Next Puzzle are keyboard/gamepad navigable via the pre-existing
`_open_sub_menu`/focus mechanism; the automated catalog gate fails loudly on any malformed/
unsolvable authored puzzle.

## Summary

Replace the controller's hardcoded single-puzzle dependency with a small, plain-GDScript,
8-entry puzzle catalog and a process-lifetime session holder naming the currently selected
puzzle. Add a minimal, catalog-driven Level Select screen (reusing existing hidden menu
scaffolding) and a Next Puzzle results action (reusing the existing scene-reload mechanism that
already gives Replay its fresh-attempt guarantee). No domain, solver, rendering, or departure
behavior changes; no persistent state is introduced.

## Technical Context

**Language/Version**: Godot 4.4 and GDScript; Python 3.11+ regression launchers.
**Primary Dependencies**: Existing Godot `Control`/`Button`/`ItemList`, Maaack's Game Template
(`MainMenu`, `SceneLoader`, pause menu controller); no new dependencies.
**Storage**: Existing progress/settings untouched; all new state (`PuzzleCatalog`,
`PuzzleSession`) is either pure rebuilt-every-call content or process-lifetime in-memory state.
**Testing**: New isolated pure catalog/solver checks (`tests/puzzle_catalog_check.gd`), extended
real-project scene tests (`tests/puzzle_layout_check.gd`), existing rule/presentation/save-input
launchers unchanged, Godot import validation, rendered desktop smoke across all 8 puzzles.
**Target Platform**: Desktop, including Windows development; mobile deployment excluded.
**Project Type**: Godot desktop puzzle game.
**Performance Goals**: Responsive input; catalog/session lookups are O(1)/O(n) over 8 entries;
solver validation runs once per regression pass (test-time), not per frame or per player action.
**Constraints**: `PuzzleDefinition` shape unchanged; no persistent writes from any new code path;
plain-GDScript content only (no Resource/JSON/scene-per-puzzle); no reuse of the addon's
`LevelListManager`/`GameState` level infrastructure; exactly 8 catalog entries this spec.
**Scale/Scope**: One reusable puzzle scene, 8 authored `PuzzleDefinition`s, one new Level Select
sub-menu, one new Results button/label, one new HUD label; catalog API shaped so a future spec can
add more entries without an interface change.

## Constitution Check

Pre-research and post-design: PASS, no waivers.

| Principle | Design and required verification |
|---|---|
| I Simple maintainable code | `PuzzleCatalog`/`PuzzleSession` are small, explicit, static-only classes matching existing codebase precedent (`GameVisualStyle`'s static-var cache, `create_fixed()`'s literal-construction style); no new abstraction beyond what FR-001–FR-007 require |
| II Project-level customization | New Level Select sub-menu is a project script/scene under `scenes/menus/main_menu/`; no addon edits; the addon's own example Level Select script is explicitly not reused |
| III Accessible controls | Level Select and Next Puzzle reuse the base `MainMenu`'s existing keyboard/gamepad-navigable `_open_sub_menu`/focus mechanism and the Results panel's existing button-row focus convention (clarified requirement); manual keyboard/gamepad verification required in quickstart.md |
| IV Responsive gameplay | No blocking work added; catalog/session lookups are O(1)/O(n over 8); Next Puzzle and Restart reuse the existing scene-reload path, introducing no new synchronous heavy work |
| V Practical verification | New automated catalog gate (`PUZZLE_CATALOG_FAILURES=0`), extended scene tests, existing launchers, Godot import validation, desktop smoke across all 8 puzzles including keyboard/gamepad checks |
| VI Save/settings preservation | `PuzzleCatalog`/`PuzzleSession` never touch `GlobalState`/`GameState`/`user://global_state.tres`; existing no-reset-on-entry guarantee (`_test_no_reset_on_puzzle_entry`) remains applicable and is extended to cover Level Select/Next Puzzle |

This is a design compliance check, not a claim that implementation verification has run.

## Context Resolution

```yaml
context_resolved:
  - id: arrow-puzzle
    path: .knowledge/architecture/arrow-puzzle.md
    via: direct appliesTo scenes/puzzle/*.gd/.tscn and the controller/results/board this spec modifies
    hop: 1
  - id: game-visual-system
    path: .knowledge/architecture/game-visual-system.md
    via: arrow-puzzle's gameplay-theme source link -> shared label/theme styling for the new HUD and results puzzle-identity labels
    hop: 2
  - id: save-progression
    path: .knowledge/architecture/save-progression.md
    via: direct appliesTo scenes/menus/main_menu/main_menu_with_animations.gd, which this spec modifies (New Game override, Level Select wiring); documents the exact no-reset guarantee this spec must preserve
    hop: 1
  - id: arrowgame-constitution
    path: .knowledge/governance/constitution.md
    via: direct governance appliesTo scripts/scenes/tests verification policy
    hop: 1
```

Index contains no relation edges or decision entities beyond the direct/textual links above; no
`.knowledge/governance/decisions/` directory exists in this repository. Followed the relevant
arrow-puzzle textual link to game-visual-system, as spec 004's plan did; traversal stops because
no additional relevant node is discovered — `PuzzleCatalog`/`PuzzleSession` are new files with no
existing knowledge node to resolve against (they will be documented as new subsections of
`arrow-puzzle.md` during implementation, not a new standalone node, per the constitution's
"justify new abstractions" principle and to avoid knowledge-node proliferation for a small,
tightly-coupled content layer). Implementation updates `arrow-puzzle.md`'s `appliesTo` to include
the new files; `save-progression.md` needs no rewrite if its documented no-reset contract remains
unchanged (it does — this spec only extends what triggers `load_game_scene()`, never what that
call itself does).

## Project Structure

### Documentation (this feature)

```text
.devspark.work/specs/005-spec-multiple-puzzles/
├── plan.md                          # This file
├── research.md                      # Phase 0 output
├── data-model.md                    # Phase 1 output
├── contracts/catalog-and-selection.md  # Phase 1 output
├── quickstart.md                    # Phase 1 output
├── gates/                           # Gate artifacts from analyze/critic/checklist
└── tasks.md                         # Phase 2 output (/devspark.tasks — not created here)
```

### Source Code (repository root)

All paths below resolve against the absolute repository root above. Godot desktop project — no
frontend/backend split; single project structure.

```text
scripts/puzzle/
├── puzzle_catalog.gd            # new — 8-entry static catalog
├── puzzle_definition.gd         # existing, unchanged shape
├── puzzle_state.gd              # existing, unchanged
├── puzzle_solver.gd             # existing, unchanged
├── puzzle_feedback.gd           # existing, unchanged
└── puzzle_results_format.gd     # existing, unchanged

scripts/
└── puzzle_session.gd            # new — process-lifetime current-puzzle holder

scenes/puzzle/
├── arrow_puzzle.gd              # modified — catalog/session-driven definition selection, HUD puzzle label, Next Puzzle handler
├── arrow_puzzle.tscn            # modified — new HUD puzzle-identity label
├── puzzle_board.gd              # unchanged
├── arrow_view.gd                # unchanged
├── puzzle_results.gd            # modified — Next Puzzle signal/button, puzzle-identity label
└── puzzle_results.tscn          # modified — new button + label

scenes/menus/main_menu/
├── main_menu_with_animations.gd    # modified — new_game() override, puzzle_selected handler
├── main_menu_with_animations.tscn  # modified — LevelSelectButton visible, level_select_packed_scene set
├── puzzle_select_menu.gd           # new — catalog-driven Level Select content
└── puzzle_select_menu.tscn         # new

tests/
├── puzzle_catalog_check.gd      # new — isolated pure catalog/solver validation gate
├── puzzle_regression.gd         # existing, unchanged (still exercises create_fixed() directly)
├── puzzle_layout_check.gd       # extended — New Game/Level Select/Replay/Restart/Next Puzzle scene coverage
├── puzzle_presentation_check.gd # unchanged unless HUD label needs presentation-level assertions
├── run_puzzle_regressions.py    # modified — adds puzzle_catalog.gd to the existing bare-project copy list and a second script invocation
└── README.md                    # modified — documents the new catalog gate

.knowledge/architecture/
├── arrow-puzzle.md              # modified — documents catalog/session/selection architecture
└── game-visual-system.md        # modified only if new label styling needs a source-of-truth note
```

**Structure Decision**: Single Godot project structure (unchanged from specs 001–004). New files
are additive at the presentation/content-layer boundary already established; no new top-level
directories, no new scenes beyond one small Level Select sub-menu, no changes to the domain
(`scripts/puzzle/puzzle_definition.gd`/`puzzle_state.gd`/`puzzle_solver.gd`) or to the departure
presentation layer (`scripts/presentation/`, `scenes/puzzle/puzzle_board.gd`/`arrow_view.gd`) from
spec 004.

## Complexity Tracking

No Constitution Check violations — this section is intentionally empty.

## Delivery and Verification

US1 provides catalog/selection/HUD proof; US2 provides the player-facing Level Select experience; US3 completes the Replay/pause-Restart/Next-Puzzle loop. All three plus final verification are needed for release. Follow quickstart.md. No new implementation tests were run during planning. Required analyze/critic gates follow task generation and are not fabricated here.

Agent-context script ran for `claude`; no `CLAUDE.md` existed in this repo, so it generated one from the generic fallback template (wrong project structure `src/`, wrong commands `pytest && ruff` — neither applies to this Godot/GDScript project). This repo's actual agent instructions live in `AGENTS.md`, which the script did not touch. The generated `CLAUDE.md` was removed rather than committed, mirroring the cleanup spec 004 performed on the equivalent codex-generated noise. No new technology was introduced by this spec that `AGENTS.md` needs updated for.
