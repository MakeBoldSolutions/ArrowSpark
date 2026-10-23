---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
devspark_version: "9.3.0"
classification: full-spec
risk_level: medium
target_workflow: specify-full
required_artifacts: spec, plan, tasks
recommended_next_step: plan
required_gates: checklist, analyze, critic, verify:snapshot-neutral, verify:end-to-end
route_intent: full-spec
depends_on: []
supersedes: []
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

<!--
  Temporary working state. This spec lives in .devspark.work/ until /devspark-release archives it.
  Durable code, tests and .knowledge/ must never reference it.
-->

# Feature Specification: Level Pack Engine

**Feature Branch**: `018-spec-level-pack-engine`
**Created**: 2026-10-23
**Status**: Draft
**Input**: User description: "Phases 1 and 2 of the level engine plan. Phase 1 — level pack format and loader: move level geometry out of the catalog's code builders into committed data packs (id, title, group/pack, board size, shapes, a pinned content version, provenance), keep the catalog's public behavior, migrate all 30 existing levels with every content version unchanged, and make the Web build include the packs. Phase 2 — an in-repo deterministic seeded generator that reuses the existing rules, solver and analyzer (no second rules engine), placing arrows in reverse solve order with center-outward layering and an initial-playable cap, scoring candidates against profiles of analyzer metric ranges; a headless pack-build tool that builds a pack from a recipe and prints a structural report. Gates: every pack level valid, solvable, content version matches, no duplicate boards; same profile and seed give the same board. Out of scope: difficulty model, persisted progress, Level Select redesign, runtime/daily generation, new content beyond a small sample proving the tool."

## Product Owner TLDR

ArrowSpark's 30 levels are currently written by hand as program code, which makes adding levels slow and keeps the level-finding search that produced the best of them outside the repository. This change stores every level as plain data in level packs, moves the existing 30 across with proof that not a single board changed, and brings a seeded level generator and a pack-building tool into the repository. The existing levels stay exactly as they are, and players also get four generated sample levels in a new Generated Levels section; the bigger payoff is that the next step — producing hundreds of levels — becomes a matter of writing recipes and curating results rather than typing coordinates.

## Rationale Summary

### Core Problem

Adding levels means writing literal geometry into one ever-growing code file, and the search that found the progression levels was never kept, so new levels cannot be reproduced, regenerated or produced at volume.

### Decision Summary

- **Levels become data, not code.** Each level's geometry, identity and provenance live in a committed level pack; the catalog reads packs. The catalog's existing public behavior (ids, titles, groups, order, group-relative numbering, Next Puzzle scope, fresh definitions per request) is preserved, so menus, sessions and the scoreboard need no change.
- **The migration is proven by content version.** Every existing level already has a pinned content version (a fingerprint of its exact geometry) in the catalog regression gate. Migration is accepted only if all 30 fingerprints, ids, titles, groups and positions are unchanged.
- **Generate offline, ship fixed data.** The generator runs as a developer tool; its output is committed and reviewed like any other level. Nothing is generated while a player plays.
- **One rules engine.** The generator builds candidate boards with the existing board definition, and validity, solvability and measurement come only from the existing validator, solver and analyzer.
- **Solvable by construction, checked anyway.** Arrows are placed in reverse solve order so every generated board is solvable by design; the existing solver still confirms every board before it can enter a pack.

### Key Drivers

- The designer's own record says that once a search existed, finding a level for a given profile was cheap, while placing boards by coordinates was slow.
- The progression levels' measured profiles (board size, arrow count, fill, initial playable arrows, dependency depth, components, bends, lengths) give concrete targets a profile can express.
- A data format with a pinned fingerprint per level makes later bulk content reviewable and regression-safe.

### Source Inputs

- `.knowledge/reference/progression-design-learning.md` — how the progression levels were found (reverse-solve-order placement, center-outward layering for density, playable caps) and their measured profiles.
- `.knowledge/architecture/arrow-puzzle.md` — puzzle domain boundaries (rules independent of scenes and input; analyzer is never a second rules engine).
- `.knowledge/governance/constitution.md` — Principles I, IV, V and VI as applied below.

### Reviewer Guidance

- Confirm the migration evidence compares all 30 levels' id, title, group, catalog position and content version before and after, not only a sample.
- Confirm the Web build was actually exercised loading levels from packs, since the packs are a new kind of shipped file the export must include.
- Confirm no rule, solvability or measurement logic was duplicated inside the generator.

## Minimum Sufficient Change

```yaml
minimum_sufficient_change:
  minimum_valuable_outcome: "All 30 existing levels load from committed level packs with identical geometry and catalog behavior, and a developer can build a valid, solvable, reproducible sample pack from a recipe with one command."
  explicitly_not_required:
    - "A difficulty model or difficulty score"
    - "Saved progress, unlocks, or any change to save data"
    - "Any Level Select, menu or gameplay presentation change beyond adding one section for the sample group through the existing section mechanism"
    - "Generating levels at runtime, daily puzzles or endless mode"
    - "Producing new player-facing content packs beyond one small sample proving the tool"
    - "Reaching Reference Knot density (about 92% fill with very few initially playable arrows) through the generator"
    - "A visual level editor"
  acceptable_manual_operations:
    - "Curating, naming and titling generated levels by hand before they are committed"
    - "Running the pack-build tool manually from the command line; no CI job is required to regenerate packs"
```

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Existing levels play exactly as before from level packs (Priority: P1)

A player opens ArrowSpark on desktop or in a browser and plays any of the 30 existing levels. Behind the scenes those levels now come from level packs instead of code, and nothing the player can see or do has changed: same levels, same order, same groups, same numbering, same Next Puzzle behavior, same boards.

**Why this priority**: Every later step builds on the pack format. If migration silently changes even one board, players' experience and the designer's recorded evidence about that board are invalidated.

**Independent Test**: Run the catalog regression gate before and after the migration and compare every level's id, title, group, catalog position and content version; then play levels from each group on desktop and in the Web build.

**Acceptance Scenarios**:

1. **Given** the 30 levels' recorded ids, titles, groups, positions and content versions, **When** the catalog is loaded from level packs, **Then** all 30 match exactly and there are no extra or missing levels.
2. **Given** the Web build, **When** a player opens Level Select and starts a level from each group, **Then** each level loads and plays, proving the packs are included in the exported build.
3. **Given** any level, **When** it is requested twice, **Then** two independent boards are returned and changing one cannot affect the other.
4. **Given** a level in the middle of a group, **When** the player chooses Next Puzzle, **Then** the next level in that same group opens, exactly as before.

---

### User Story 2 - Developer generates a reproducible level from a profile (Priority: P2)

A developer describes the kind of level they want as a profile — target ranges for board size, arrow count, fill, initially playable arrows, dependency depth, components, bends and arrow lengths — plus a seed, and asks the generator for a level. They get a valid, solvable board that falls within the profile, or a clear report of how close the best candidate came. Running again with the same profile and seed gives exactly the same board.

**Why this priority**: The generator is what makes "lots more levels" practical; without reproducibility, generated content cannot be reviewed, regenerated or trusted.

**Independent Test**: Generate from a fixed profile and seed twice and compare content versions; check the result with the solver and analyzer; generate with a deliberately unreachable profile and confirm a clear miss report.

**Acceptance Scenarios**:

1. **Given** a profile and a seed, **When** the generator runs twice, **Then** both runs produce boards with the same content version.
2. **Given** a reachable profile, **When** the generator produces a board, **Then** the board is valid, solvable, and every profiled metric falls within its target range.
3. **Given** a profile asking for a cap on initially playable arrows, **When** the board is produced, **Then** the number of arrows playable at the start does not exceed the cap.
4. **Given** a profile no candidate can satisfy within the attempt budget, **When** the generator finishes, **Then** it reports the best candidate's metrics against each target range and does not claim success.

---

### User Story 3 - Developer builds a level pack from a recipe (Priority: P3)

A developer writes a recipe naming a pack, its group, and a list of levels each with an id, title, profile and seed, then runs one command. The tool writes a level pack ready to commit and prints a structural report for every level, so the developer can curate before committing.

**Why this priority**: It turns single-level generation into a repeatable content workflow and proves the end-to-end path with a small sample pack, which players can play in its own Level Select group.

**Independent Test**: Run the build tool on the sample recipe, confirm the pack is written, the report lists each level's metrics, and the pack passes the pack regression gate; run it again and confirm the pack is byte-identical.

**Acceptance Scenarios**:

1. **Given** a recipe of several levels, **When** the pack-build tool runs, **Then** it writes one level pack containing every level with its pinned content version and its provenance (profile and seed).
2. **Given** the same recipe, **When** the tool runs a second time, **Then** the written pack is identical to the first.
3. **Given** a recipe in which one level's profile cannot be met, **When** the tool runs, **Then** it reports which level failed and why, and does not write a partial pack.
4. **Given** a recipe whose generated board duplicates a board already in any pack, **When** the tool runs, **Then** it reports the duplicate and does not write the pack.
5. **Given** the committed sample pack, **When** a player opens Level Select, **Then** a fourth section for the generated group appears after the existing three, its levels are numbered from 1 within the group, and Next Puzzle from its last level offers no next level.

---

### Edge Cases

- A pack file is missing, unreadable or malformed: the catalog regression gate fails loudly and names the pack; the game never silently drops levels.
- A level in a pack fails validation, is unsolvable, or its stored content version does not match its geometry: the pack regression gate fails and names the level.
- Two levels share an id, or two levels share the same board (same content version), anywhere across all packs: the gate fails and names both.
- A level references a group the catalog does not know: the gate fails and names the level.
- A profile's ranges are contradictory (for example a minimum above its maximum) or a board too small for the requested arrow count: the generator rejects the profile up front with a clear message instead of searching.
- A seed is reused for a different profile: allowed; determinism is defined by the pair of profile and seed.
- A generated board happens to equal an existing hand-authored level: treated as a duplicate and rejected.
- Very large profiles: generation is a developer tool, so it may take noticeable time, but it must finish within a stated attempt budget rather than run unbounded.
- First build of a new pack: the pack is listed in the manifest before its file exists. The build tool checks against every other pack and treats the not-yet-built pack as empty, rather than as a catalog error; the game and the regression gate still treat a missing listed pack as an error.
- A build fails, or is interrupted, while an earlier version of the pack exists: the existing pack file is left byte-identical.

## Requirements *(mandatory)*

### Functional Requirements

**Level packs and loading**

- **FR-001**: The game MUST obtain every catalog level's geometry from committed level packs instead of per-level code.
- **FR-002**: Each level in a pack MUST record its id, title, group, board width and height, every arrow's head, direction and path, its pinned content version, and its provenance (either hand-authored, or the generator profile and seed that produced it).
- **FR-003**: The catalog MUST preserve its existing observable behavior: level ids, titles, groups, catalog order, group order, group-relative numbering, Next Puzzle staying within a group, and a fresh independent board on every request.
- **FR-004**: Looking up a level by id MUST NOT require scanning the whole catalog, so lookup cost does not grow with the number of levels.
- **FR-005**: All 30 existing levels MUST be migrated into packs, and the migration MUST be accepted only if every level's id, title, group, catalog position and content version is identical before and after.
- **FR-006**: The Web build MUST include the level packs, and the exported game MUST load levels from them.
- **FR-007**: Once migrated, a level's geometry MUST exist in exactly one place (its pack); no second copy may remain that could drift from it.

**Pack regression gate**

- **FR-008**: The required puzzle regression gate MUST check, for every level in every pack: structural validity, solvability, that the stored content version equals the content version recomputed from its geometry, a known group, and unique ids across all packs.
- **FR-009**: The gate MUST fail if any two levels across all packs have the same board (the same content version).
- **FR-010**: The gate MUST fail loudly, naming the pack and level, when a pack cannot be read or a level is malformed. This covers at least: malformed JSON, a fractional or non-numeric coordinate, invalid vertices (diagonal or zero-length steps, or an arrow that fails board validation), a pack listed in the manifest whose file is missing, duplicate ids, duplicate boards, and an unknown group. Each of these cases MUST have a negative check proving the diagnostic names the problem and the gate fails.

**Generator**

- **FR-011**: The generator MUST be deterministic: the same profile and seed MUST always produce a board with the same content version on the project's regression engine version.
- **FR-012**: The generator MUST place arrows in reverse solve order so that every candidate is solvable by construction, and MUST support center-outward layering and a cap on the number of arrows playable at the start. The cap is a hard acceptance constraint: a board with more initially playable arrows than the cap is never reported as meeting the profile and never enters a pack, even when the profile sets no initial-playable range.
- **FR-013**: A profile MUST be able to set target ranges on board size, arrow count, fill, initially playable arrows, dependency depth, component count, bends and arrow length; any metric a profile leaves out is unconstrained.
- **FR-014**: The generator MUST score candidates by their distance from the profile's target ranges and keep the best one within a bounded attempt budget. Building each candidate MUST also be bounded, so every run ends even when arrows cannot be placed.
- **FR-015**: The generator MUST report the result with every profiled metric against its target range, and MUST say clearly when no candidate met the profile.
- **FR-016**: The generator MUST reject, before searching and with a message naming the problem, a profile with a detectable contradiction: a range whose minimum exceeds its maximum, a value outside its allowed range, or no permitted board size able to hold the minimum arrow count at the minimum arrow length. Otherwise it MUST generate only from feasible combinations of board size and arrow count. Proving that every combination of structural targets is unreachable is not required; such a profile ends as a reported miss (FR-015).

**Pack-build tool**

- **FR-017**: A headless pack-build tool MUST build one level pack from a recipe naming the pack, its group, and its levels (each with id, title, profile and seed) with a single command.
- **FR-018**: The tool MUST print a structural report for every level built, using the same measures as the existing structural report.
- **FR-019**: The tool MUST NOT write or alter a pack if any level fails its profile, fails validation or solvability, or duplicates an existing board; it MUST name each failing level. A successful build MUST replace the pack file atomically, so a failed or interrupted build leaves any existing pack byte-identical.
- **FR-020**: Running the tool twice on the same recipe MUST produce an identical pack.
- **FR-021**: One small sample recipe and the pack it produces MUST be committed to prove the tool end to end.
- **FR-022**: The sample pack's levels MUST appear to players in their own new group, as a fourth Level Select section after the existing three, using the existing section behavior: a header with title, level count and a one-line description, group-relative numbering, and Next Puzzle staying within the group. The group's title and description are chosen during planning and must make clear these are generated levels.
- **FR-023**: Adding the new group MUST NOT change the order, numbering or Next Puzzle behavior of the existing three groups, and keyboard and gamepad navigation through Level Select MUST continue to reach every section and level (Principle III).

**Constraints**

- **Architectural constraint**: The generator MUST NOT contain its own copy of the game rules. Validity comes only from the existing board validation, solvability only from the existing solver, and measured metrics only from the existing analyzer. What may vary is how candidates are proposed and scored.
- **Architectural constraint**: Generation happens only in developer tooling. The shipped game reads committed packs and never generates levels while running.
- **Domain invariant**: A level's content version identifies its exact geometry. It is independent of the level's id, title, group, pack and catalog position, and moving a level between files or packs never changes it.
- **Domain invariant**: Level ids are stable identities. Migration must not rename, renumber or reorder any existing level.
- **Domain invariant**: Every level that ships is valid and solvable.
- **Constraint (Principle VI)**: No saved progress or settings are read, written or reshaped by this change.
- **Constraint (Principle V)**: Because level loading is on the gameplay path, the change requires Godot validation, both required headless regression gates, a desktop smoke test, and a Web smoke test in Firefox and in a Chromium-based browser plus at least one real phone in a mobile browser; any check not run is recorded as not performed rather than claimed.
- **Constraint (Principle IV)**: Loading packs must not add a noticeable delay to opening Level Select or starting a level.

### Key Entities

- **Level**: One playable board with a stable id, a display title, a group, its geometry (board size and arrows), a content version fingerprinting that geometry, and provenance.
- **Level Pack**: A committed collection of levels that belong together; the catalog is the ordered union of all packs. A pack is the unit the build tool writes and a reviewer reads.
- **Provenance**: How a level came to exist: hand-authored, or produced by the generator from a named profile and seed. It lets any generated level be regenerated and checked.
- **Profile**: A set of target ranges over measured level structure (board size, arrow count, fill, initially playable arrows, dependency depth, components, bends, arrow length) plus placement options (center-outward layering, initial-playable cap).
- **Recipe**: The input to the build tool: a pack name, its group, and an ordered list of levels to generate, each with id, title, profile and seed.
- **Structural Report**: Per-level measured structure printed for review; descriptive only, setting no thresholds of its own beyond the profile.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 30 of 30 existing levels keep identical id, title, group, catalog position and content version after migration (snapshot comparison before vs. after shows zero differences).
- **SC-002**: Both required headless regression gates pass after the change, and the puzzle regression gate checks 100% of levels in all packs for validity, solvability, content-version match and uniqueness.
- **SC-003**: A level from each of the four groups loads and plays in the exported Web build in Firefox, in a Chromium-based browser, and on at least one real phone.
- **SC-004**: Building the same recipe in 3 independent processes yields the same content version for every level all 3 times, and the written pack is byte-identical each time.
- **SC-005**: The sample recipe builds with one command, produces a pack whose levels are 100% valid, solvable and within profile, and a second build is identical to the first.
- **SC-006**: Adding a new level requires no change to program code: only a pack (or a recipe plus one build command) and its regression pin.
- **SC-007**: Opening Level Select and starting a level take no perceptibly longer than before the change on desktop and in the Web build.
- **SC-008**: The sample group's levels are reachable and playable from Level Select with mouse, keyboard and gamepad, and the existing three groups' 30 levels keep their positions and numbering.

## Clarifications

### Session 2026-10-23

- Q: Should the generated sample pack appear in the game? → A: Yes, in its own new group shown as a fourth Level Select section (FR-022, FR-023, SC-008).
- Q: Is the initial-playable cap a preference or a constraint? → A: A hard acceptance constraint, even when no initial-playable range is set (FR-012).
- Q: Which profiles are rejected before searching? → A: Only detectably contradictory ones, including no feasible board size for the minimum arrow count; the generator samples only feasible combinations, and unreachable structural targets end as a reported miss (FR-016).
- Q: What does "no partial pack" mean on disk? → A: Write beside the destination and replace it atomically; a failed or interrupted build leaves an existing pack byte-identical (FR-019).
- Q: How is malformed input proven to fail? → A: Negative checks for each malformed-input case listed in FR-010.
- Q: What evidence satisfies SC-004? → A: Three independent build processes with matching content versions and byte-identical packs (SC-004).

## Assumptions

- Context gathering used the repository directly (constitution, knowledge docs, catalog, regression gates); the write-spec context script was not run.
- Determinism is guaranteed on the project's regression engine version (Godot 4.4.x). A different engine version is not promised to reproduce the same boards; provenance plus the pinned content version detect any drift.
- The existing catalog regression gate's per-level pins (id, title, group, content version) are the "before" snapshot for the migration.
- The existing structural report's measures are sufficient for profiles; no new analyzer measure is required.
- The generator is not expected to reach Reference Knot density; dense, few-playable boards may still need hand-composed skeletons, which is outside this change.
- Hand-curation of titles and acceptance of generated levels remains a human step.
- The existing exhaustive "every branch order" catalog check stays as it is for existing levels; how far it applies to future generated packs is a planning decision.

## Out of Scope

- Difficulty model, difficulty score or curve design.
- Persisted progress, unlocks, completion marks, or any save-data change.
- Level Select redesign, paging, or new menu screens (the sample group's section reuses the existing section mechanism).
- Runtime, daily or endless generation.
- New player-facing content beyond the single sample pack.
- Skeleton-seeded generation for Reference-Knot-class density.
- A visual level editor.
