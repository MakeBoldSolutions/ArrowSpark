# User-Supplied Source Brief (preserved verbatim)

This is the user's original feature description for Spec 005, preserved exactly
as supplied to `/devspark.specify`, including explicit implementation
preferences and verification coverage. Planning and drafting derive from this
text; it is retained here as evidence rather than restated informally.

---

# Spec 005 — Multiple Authored Puzzles and Session-Only Puzzle Selection

## Intent

Expand ArrowGame from one hardcoded puzzle into a small collection of handcrafted puzzles that can be selected and played through the same reusable puzzle scene.

This specification establishes the game's **content model and puzzle-selection flow**.

It should prove that ArrowGame can support multiple independent puzzle definitions without introducing procedural generation, persistent progression, difficulty classification, or scene-per-level architecture.

The core architectural principle is:

> A puzzle is data consumed by the existing puzzle engine. A level is not a separate gameplay scene.

The existing puzzle domain, solver, rendering, scoring, path-following departure, and completion behavior should remain reusable across every authored puzzle.

---

# Player Experience

The game should support eight handcrafted puzzles.

The basic player flow is:

`Main Menu → Puzzle 1`

or:

`Main Menu → Level Select → Selected Puzzle`

After completing a puzzle:

`Results → Replay | Next Puzzle | Level Select | Main Menu`

All eight puzzles are available immediately.

There are:

- no locked puzzles,
- no persistent completion requirements,
- no stars,
- no achievements,
- no campaign save state,
- no difficulty labels.

This is intentionally a **session-only content experience**.

---

# New Game

Preserve the existing simple New Game experience.

Selecting **New Game** from the Main Menu should start the first puzzle in catalog order directly.

Do not force the player through Level Select before playing.

New Game must not reset or mutate inherited/template persistent save data.

---

# Level Select

Expose a simple Level Select experience from the Main Menu.

Level Select should show all eight authored puzzles in deterministic catalog order.

Each puzzle should have enough identity for the player to distinguish it, such as:

- puzzle number
- short title

All puzzles are selectable immediately.

Do not introduce locked/unlocked states.

Do not reuse inherited template level-selection infrastructure if doing so requires:

- one scene per puzzle,
- persistent `GameState` level state,
- `level_won` / `level_lost` semantics,
- writing to existing save storage,
- or other assumptions inconsistent with ArrowGame's data-driven puzzle architecture.

A small ArrowGame-specific selector is preferred.

Do not add Level Select to the pause menu in this specification.

---

# Puzzle Catalog

Introduce a small ArrowGame-specific puzzle catalog.

The catalog should provide:

- stable puzzle identity,
- deterministic ordering,
- short display title,
- construction/access to a fresh `PuzzleDefinition`.

Conceptually, an entry represents:

`Puzzle ID + display metadata + way to obtain PuzzleDefinition`

The exact GDScript structure may be determined during planning, but it should remain small and explicit.

A likely implementation is a plain GDScript presentation/content layer such as:

`scripts/puzzle/puzzle_catalog.gd`

or another appropriately located equivalent.

Do not introduce a large content-management framework.

---

# PuzzleDefinition Remains Structural

Keep `PuzzleDefinition` focused on puzzle structure.

It should continue to represent concepts such as:

- board width and height,
- arrow head locations,
- directions,
- ordered tail geometry.

Do not add progression or catalog concerns such as:

- stable level ID,
- display title,
- level number,
- unlocked state,
- completion state,
- best score,
- difficulty classification.

Those concepts belong outside the structural puzzle definition.

The existing validation and solver should continue to accept an anonymous `PuzzleDefinition`.

---

# Content Representation

For this initial set of eight handcrafted puzzles, prefer **plain GDScript-authored content** consistent with the existing code-driven `PuzzleDefinition` approach.

Do not convert `PuzzleDefinition` into a Godot `Resource` merely to support multiple puzzles.

Do not introduce JSON, external data files, one `.tscn` per puzzle, or one `.tres` per puzzle unless planning discovers a concrete repository constraint requiring it.

The current scale does not justify a generalized content-authoring system.

The implementation should remain:

- source-control readable,
- easy to review,
- directly testable,
- deterministic,
- simple to extend with additional handcrafted puzzles.

Future tooling or data-driven authoring can be considered when there is an actual need.

---

# Eight Handcrafted Puzzles

Create **eight** authored puzzles.

These puzzles serve two purposes:

1. provide actual playable content,
2. provide deliberately varied examples for future puzzle-generation and difficulty-analysis work.

They should therefore not simply be eight arbitrary variations of the same board.

Design the set to exercise meaningfully different structures.

The collection should approximately cover:

1. **Simple Introduction**
   - primarily straightforward arrows
   - obvious legal moves
   - low visual complexity

2. **First Bend**
   - introduces clearly visible bent-arrow behavior

3. **Multiple Bends**
   - exercises multi-turn arrow geometry

4. **Dependency Chain**
   - removing one arrow clearly unlocks another

5. **Forced Sequence**
   - includes states with very limited legal choices

6. **Multiple Choices**
   - presents more than one legitimate legal move at meaningful points

7. **Dense Board**
   - more arrows and/or visual interactions
   - exercises ownership and path readability

8. **Subtle Blockers**
   - requires more careful visual reasoning about which occupied cells block escape paths

These are design goals, not formal difficulty classifications.

Do not label the puzzles Easy, Medium, Hard, etc. in this specification.

Every puzzle must satisfy the existing structural rules and be solver-confirmed solvable.

The exact geometry of each puzzle may be determined during implementation as long as the collection provides useful structural variety.

---

# Stable Puzzle Identity

Each catalog entry must have a stable string ID suitable for internal use.

Examples of the concept:

`intro`

`first_bend`

`dependency_chain`

The exact IDs and titles should be chosen during implementation and then treated as stable catalog identity.

Catalog identity must not depend on:

- array position alone,
- scene filenames,
- resource filenames,
- display title,
- filesystem paths.

Ordering and identity are separate concepts.

The catalog may expose ordered entries while still resolving a puzzle by stable ID.

---

# Current Puzzle Selection

Replace the controller's direct dependency on the single hardcoded:

`PuzzleDefinition.create_fixed()`

with selection of the appropriate definition from the puzzle catalog.

The reusable puzzle scene should be capable of playing any valid catalog puzzle without changing scenes or changing puzzle-specific presentation code.

Puzzle selection should occur before a new attempt is constructed.

---

# Session-Scoped Current Puzzle

Introduce the smallest appropriate mechanism for remembering which puzzle is currently selected during the running application session.

This is needed so that:

- Level Select can choose a puzzle,
- the puzzle scene knows which definition to load,
- Replay loads the same puzzle,
- Next Puzzle can advance through catalog order.

This state must be **session-only**.

It must not write to existing persistent save storage.

Do not use or mutate inherited/template progression state merely because it already contains concepts such as `current_level`.

The implementation may use a small ArrowGame-specific session holder, autoload, or equivalent mechanism if justified by the existing scene-loading architecture.

Keep its responsibility narrow:

> Which catalog puzzle should the reusable puzzle scene currently load?

Do not turn it into a general progression manager.

---

# Replay

Replay must restart the **currently selected puzzle** with a completely fresh `PuzzleState`.

Replay must not silently return to Puzzle 1.

A replayed attempt must reset:

- active arrows,
- mistakes,
- score state,
- accuracy counters,
- completion state,
- presentation/departure state.

It must preserve:

- selected puzzle identity.

Existing fresh-attempt semantics must remain intact.

---

# Next Puzzle

Add a **Next Puzzle** action to Results when another puzzle follows the current puzzle in catalog order.

Selecting Next Puzzle should:

1. select the next catalog entry,
2. start a fresh attempt using its `PuzzleDefinition`.

Do not carry mistakes, score, active state, departure state, or other attempt data between puzzles.

For the final catalog puzzle:

- do not show or enable Next Puzzle.

No additional campaign-completion ceremony is required in this specification.

Replay, Level Select, and Main Menu remain available.

---

# Results

Preserve the existing results experience and metrics:

- total arrows,
- mistakes,
- score,
- accuracy.

Add only the minimum changes necessary for multi-puzzle navigation and identity.

Results should make it clear which puzzle was completed if needed for coherent navigation/testing.

Do not broadly redesign or restyle Results as part of this specification.

Spec 005 is not a general results-screen polish project.

---

# Puzzle Identity in Gameplay

Show a small puzzle identity indicator in the gameplay HUD.

For example:

`Puzzle 3 — Dependency Chain`

or an equivalent concise presentation consistent with the current visual system.

This is useful to the player and provides immediate verification that the requested catalog entry actually loaded.

Do not allow the new label to materially reduce puzzle-board space or interfere with the existing responsive layout.

---

# Automated Catalog Validation

Every authored puzzle must be validated automatically.

Create a permanent content regression gate that enumerates the entire puzzle catalog without loading presentation scenes.

For every catalog entry:

1. verify its stable ID is present and valid,
2. verify IDs are unique,
3. construct a fresh `PuzzleDefinition`,
4. verify structural validity using existing validation,
5. run `PuzzleSolver.analyze(definition)`,
6. verify the puzzle is solvable,
7. obtain the solver witness,
8. replay that witness against a fresh `PuzzleState`,
9. verify the witness clears the puzzle,
10. verify the witness completes with zero mistakes.

This should use the existing domain/solver pipeline rather than duplicate puzzle-validity logic in the catalog.

The catalog regression should fail if any authored puzzle is malformed or unsolvable.

---

# Definition Isolation

Obtaining a puzzle definition from the catalog must provide state suitable for a fresh attempt.

Playing or mutating runtime state for one attempt must not corrupt the catalog definition or future attempts.

Verify that:

- Replay starts cleanly,
- selecting the same puzzle again starts cleanly,
- playing Puzzle A does not mutate Puzzle B,
- requesting a definition repeatedly behaves deterministically.

Preserve the existing separation between immutable puzzle definition and mutable puzzle state.

---

# Existing Solver Metrics

The solver already exposes useful metrics such as:

- states examined,
- active choices encountered,
- legal choices encountered,
- forced states,
- branching states,
- no-move states.

These may be collected or reported by tests/development tooling for the eight handcrafted puzzles if useful.

However:

**Do not turn these metrics into a player-facing difficulty system in Spec 005.**

Do not invent:

- difficulty scores,
- Easy/Medium/Hard thresholds,
- rankings,
- stars,
- challenge ratings.

The handcrafted puzzle set should become useful evidence for later difficulty research.

Formal difficulty analysis belongs in a future specification.

---

# Existing Domain Behavior Must Remain Unchanged

Spec 005 must preserve:

- `PuzzleDefinition` structural semantics,
- ordered arrow geometry,
- head/tail ownership,
- structural validation,
- blocking rules,
- immediate atomic removal,
- `PuzzleState`,
- solver behavior,
- scoring,
- mistake counting,
- accuracy,
- unlimited attempts,
- whole-cell hit testing,
- head/tail input equivalence,
- hover/blocked state behavior,
- continuous arrow rendering,
- path-following departure,
- board-edge clipping,
- pending-departure completion barrier.

A puzzle selected from the catalog must behave exactly like the current fixed puzzle does through the existing engine.

---

# Preserve Spec 004 Departure Behavior

Changing puzzle selection must not regress path-following departure.

In particular:

- logical removal remains immediate,
- visual departure remains presentation-only,
- bent arrows feed through their existing paths,
- departing arrows are not blockers,
- departing arrows cannot be interacted with,
- multiple departures remain independent,
- completion waits for all required visual departures.

The multi-puzzle lifecycle must cleanly dispose of any previous attempt's departing views before another puzzle begins.

---

# Save and Progression Boundary

Do not use Spec 005 to introduce persistent progression.

Specifically, do not add or change persistent state for:

- completed puzzles,
- current puzzle,
- unlocked puzzles,
- best scores,
- best accuracy,
- stars,
- campaign position.

Do not write ArrowGame puzzle selection into inherited/template `GameState`, `GlobalState`, `LevelState`, or `user://global_state.tres`.

Preserve existing saved data.

The inherited template progression infrastructure assumes a scene-per-level and persistence-oriented model that does not match ArrowGame's reusable-scene/data-driven architecture.

Do not adapt the game to that model merely to reuse existing template code.

Persistent ArrowGame progression can be designed later based on the actual needs of the game.

---

# Level Select Architecture

The Level Select UI should consume the ArrowGame puzzle catalog.

It should not derive puzzle identity from scene files.

Conceptually:

`PuzzleCatalog → Level Select`

and:

`selected puzzle ID → session selection → reusable puzzle scene → PuzzleDefinition`

Do not create:

`Level 1 scene`

`Level 2 scene`

`Level 3 scene`

etc.

There should remain one reusable gameplay scene.

---

# Future Procedural Generation Seam

Spec 005 should deliberately preserve this future architecture:

`Authored Content → PuzzleDefinition`

and later:

`Puzzle Generator → PuzzleDefinition`

Both should then share:

`PuzzleDefinition → Validation → PuzzleSolver → PuzzleState → Gameplay`

Gameplay should not need to know whether a definition was:

- handcrafted,
- generated,
- loaded from future content storage.

Do not encode puzzle IDs as scene paths or resource paths in a way that would require future generated puzzles to exist as files.

Procedural generation itself is explicitly out of scope.

---

# Testing

## Domain / Content Tests

Add automated coverage for:

- unique stable catalog IDs,
- deterministic catalog order,
- valid metadata required by the catalog,
- correct definition returned by ID,
- correct definition returned by catalog position where applicable,
- fresh/isolated definitions,
- all eight puzzles structurally valid,
- all eight puzzles solver-confirmed solvable,
- replayable zero-mistake witness for every puzzle.

## Scene / Integration Tests

Verify:

- New Game loads Puzzle 1,
- Level Select loads the selected puzzle,
- HUD shows the correct puzzle identity,
- Replay reloads the same selected puzzle,
- Replay creates fresh attempt state,
- Next Puzzle loads the correct next catalog entry,
- final puzzle has no Next Puzzle action,
- Level Select round-trip loads the requested puzzle,
- Main Menu navigation remains correct,
- switching puzzles does not leak state from the prior attempt,
- prior departing views/callbacks do not survive puzzle replacement,
- results correspond to the puzzle actually played,
- departure completion barrier remains correct with different puzzle definitions,
- inherited saved progress remains untouched.

Continue using isolated user data for tests that could otherwise interact with existing save state.

## Manual Verification

Play all eight puzzles.

Verify:

- every puzzle is understandable and completable,
- the set provides visibly different puzzle structures,
- puzzle identity is clear,
- Level Select is easy to use,
- New Game remains frictionless,
- Replay behavior is intuitive,
- Next Puzzle flow feels natural,
- the final-puzzle results state makes sense,
- navigation does not feel like inherited template behavior,
- continuous arrows remain visually readable across the different boards,
- path-following departure looks correct for the new authored geometry.

Manual play is also the first opportunity to record subjective observations about which puzzles feel easier, harder, more obvious, more confusing, or more satisfying.

Those observations may inform future difficulty work but should not alter Spec 005's scope.

---

# Durable Knowledge

Update project knowledge where necessary to document the durable content architecture.

Knowledge should make clear that:

- `PuzzleDefinition` is anonymous structural puzzle data,
- puzzle identity/order belong to the catalog,
- gameplay uses one reusable puzzle scene,
- current puzzle selection is session-only,
- inherited template persistence is not ArrowGame progression,
- authored puzzles are automatically solver-validated,
- future generated puzzles should enter through the same `PuzzleDefinition` boundary.

Production code must not reference this spec as its source of truth.

---

# Out of Scope

Do not add:

- procedural puzzle generation,
- difficulty classification,
- difficulty scores,
- Easy/Medium/Hard labels,
- persistent puzzle completion,
- persistent current level,
- locked/unlocked levels,
- achievements,
- stars,
- best-score persistence,
- best-accuracy persistence,
- campaign completion,
- daily puzzles,
- random puzzle selection,
- puzzle editor/tooling,
- JSON content format,
- Godot Resource conversion solely for puzzle authoring,
- scene-per-level architecture,
- new puzzle mechanics,
- solver redesign,
- scoring changes,
- audio,
- haptics,
- Android/mobile deployment,
- broad Main Menu redesign,
- broad Results redesign,
- Level Select from the pause menu.

---

# Success

Spec 005 succeeds when ArrowGame is no longer a one-puzzle prototype.

A player can:

- start Puzzle 1 immediately,
- browse and select any of eight handcrafted puzzles,
- play each through the same puzzle engine,
- replay the current puzzle,
- advance to the next puzzle after completion,
- return to Level Select or Main Menu.

Every authored puzzle is automatically proven structurally valid and solvable through the existing domain and solver.

The implementation establishes a clean content boundary:

> **Catalog chooses the puzzle. PuzzleDefinition describes the puzzle. PuzzleState plays the puzzle.**

No persistent progression or procedural generation is introduced.
