# Research: Reference Puzzle and Level Groups

No `NEEDS CLARIFICATION` markers remain (spec clarified 2026-09-29). Decisions below settle planning-level choices the spec deferred.

## R1. Group identifiers and names (FR-022)
- **Decision**: ids `foundations`, `puzzle_lab`, `arrowspark_levels`; display titles "Foundations", "Puzzle Lab", "ArrowSpark Levels".
- **Rationale**: Matches the spec's names; titles describe why content exists, not rank (FR-028). "Puzzle Lab / Experiments" shortened to "Puzzle Lab" for menu width.
- **Alternatives**: "Experiments" (less inviting, overlaps Foundations "validation"); numbered tiers (implies ranking — rejected).

## R2. Where group data lives (FR-024, FR-027)
- **Decision**: Add a `"group"` key to each `PuzzleCatalog._entries` dictionary and static helpers on `PuzzleCatalog`.
- **Rationale**: Metadata beside id/title; no definition duplication; no new file, so isolated-project launchers (fixed script copy lists) need no change; `PuzzleAnalyzer`/`PuzzleSolver`/`PuzzleState` never read it.
- **Alternatives**: separate `PuzzleGroups` class or `.tres` resource (new file → launcher edits, more surface); reordering the array by group (breaks index-based tests).

## R3. Reference Puzzle placement and identity (FR-001, FR-026)
- **Decision**: Append at catalog index 21 with stable id `reference_knot` and a provisional title (final title chosen at end of iteration; id never changes). Group `arrowspark_levels`.
- **Rationale**: Appending preserves every existing index/id and the test "Next from fourteenth → canvas_validation". Iteration versions (v1, v2…) live only in the design report / scratch definitions, never as catalog entries.

## R4. Initial classification (FR-023)
- **Decision** (subject to per-entry purpose review recorded in the design report):
  - Foundations: the original eight (`intro`, `first_bend`, `multi_bend`, `dependency_chain`, `forced_sequence`, `multiple_choices`, `dense_board`, `subtle_blockers`).
  - Puzzle Lab: six Spec 006 experiments (`nested_chain`, `cascade_key_arrow`, `dense_unravel`, `bent_network`, `long_range_blocker`, `composed_shaped`), `canvas_validation` (clarified), and six Spec 009 knots (`knot_*`) = 13.
  - ArrowSpark Levels: `reference_knot`.
- **Counts**: 8 + 13 + 1 = 22 (SC-008).
- **Order in Level Select**: ArrowSpark Levels, Foundations, Puzzle Lab (mature level findable first, SC-009; order is presentation only, not a quality claim).

## R5. Display numbering (FR-033)
- **Decision**: `PuzzleCatalog.group_position(id)` = 1-based position among that group's entries in catalog order. Used by Level Select, the in-game puzzle label and Results. Stable ids untouched.
- **Rationale**: One helper replaces three copies of `index_of(id) + 1`.

## R6. Group-scoped progression (FR-031)
- **Decision**: `PuzzleCatalog.next_in_group(id)` returns the next id in the same group, or `""` at the end (no wrap, no cross-group). `PuzzleSession.has_next()`/`advance_to_next()` delegate to it.
- **Rationale**: Existing call sites (`arrow_puzzle.gd`, `puzzle_results.gd` via `has_next`) keep their shape.

## R7. Level Select from Results at group end (FR-031)
- **Decision**: Results shows a "Level Select" button in the Next Puzzle slot when `has_next` is false. It emits `level_select_requested`; `arrow_puzzle.gd` sets an in-memory one-shot flag on `PuzzleSession` (`request_level_select()`), then loads the main menu. `main_menu_with_animations.gd` consumes the flag after `_setup_level_select()`/intro and opens Level Select via the existing `_open_sub_menu`.
- **Rationale**: Reuses the existing menu and sub-menu mechanism; no persistence; the same Main Menu path already exists.
- **Risk**: Menu intro animation state machine (`_is_in_intro`, deferred level-select add). Mitigation: open via `call_deferred` after intro is skipped; verify by desktop smoke test. **Fallback**: if the intro interferes, Level Select button loads the menu with the intro skipped — decision recorded in the verification notes.
- **Alternatives**: a dedicated in-game Level Select overlay (new UI, violates "no major redesign"); reusing Main Menu button only (fails FR-031).

## R8. Main-menu Play (FR-032)
- **Decision**: `new_game()` sets `PuzzleSession` to `reference_knot`. Existing no-`GlobalState.reset()`/no-`GameState.start_game()` guarantee is retained; `save_input_regression.gd` assertion updated from "catalog position 0" to the reference id.

## R9. Level Select layout and navigation (FR-025)
- **Decision**: Keep the single `VBoxContainer`; insert a non-focusable group header `Label` before each group's buttons (`focus_mode = FOCUS_NONE`). Buttons remain in one contiguous focus chain so keyboard/gamepad up/down traverses every entry across groups; initial focus goes to the first button (the Reference Puzzle).
- **Rationale**: Simplest approach consistent with the existing menu; no tabs/sub-menus.

## R10. Authoring and evidence workflow (FR-011–FR-016)
- **Decision**: Iterate by editing `_build_reference_knot` in place (ids are stable, and iteration versions live only in the draft report, never as catalog entries) using the existing `run_puzzle_structural_report.py`; record each candidate's diagnostics, playtest answers (all fifteen questions for the final) and decisions in the design report draft under `.devspark.work/`, and publish the durable version to `.knowledge/reference/reference-puzzle-design-report.md` at the end.
- **Design guardrails carried from the knot experiments**: prefer long/medium bent arrows as the skeleton; single-cell arrows sparingly; keep blocker distance meaningful and tails as a source of cross-region dependency; keep arrows traceable (avoid boundary-knot repetition).
- **Human gate**: Marks the puzzle task incomplete until a human playtest supports "a level I want someone else to play" and a non-author verifies SC-009. AI cannot self-certify these. Amendment 2026-10-01: the owner reviewed the playtest and deferred the non-author SC-009 check to the next spec (Web Showcase & Playtest) because only one tester is available; it was not performed and is not represented as passed.

## R11. Analyzer/regression coverage
- **Decision**: Extend `tests/puzzle_catalog_check.gd`: 22 entries; every entry has exactly one valid group; group counts 8/13/1; ids unchanged/original definitions fingerprint-unchanged; `group_position`/`next_in_group` semantics incl. end-of-group; `reference_knot` valid + solvable + witness replays + order-independent; no difficulty/quality labels. Structural report remains non-gating.
