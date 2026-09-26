---
classification: full-spec
risk_level: medium
risk_profile: internal
change_type: brownfield
target_workflow: specify-full
required_artifacts: spec, plan, tasks
recommended_next_step: implement
required_gates: checklist, analyze, critic
route_intent: full-spec
status: Draft
---

# Feature Specification: First Playable Arrow Puzzle

**Feature Branch**: `001-spec-first-playable-arrow-puzzle`
**Created**: 2026-09-26
**Status**: Draft
**Input**: Create the first playable arrow-clearing puzzle in the existing desktop game, with one manually defined board, unlimited mistakes, live counters, completion results, and replay.

## Product Owner TLDR

Players can start a single arrow puzzle, select arrows whose paths are clear, and watch them leave the board. Blocked selections provide feedback and count as mistakes, but never prevent continued play. Clearing every arrow reveals results and an action to replay the same puzzle. This establishes a complete playable experience while preserving the useful starter functionality.

## Rationale Summary

### Core Problem

The requested vertical slice needs a complete launch-to-replay journey with clear, independently verifiable puzzle rules and no interruption for making mistakes.

### Decision Summary

Use one fixed, solvable rectangular board and four cardinal arrow directions. Keep puzzle decisions and state independent of input devices and animation, while integrating play and results into the existing game.

### Key Drivers

- Demonstrate the complete puzzle loop with desktop mouse input.
- Allow experimentation without lives, failure, or forced restarts.
- Keep scope small enough to verify blocking rules and accurate results thoroughly.
- Preserve starter navigation, input remapping, settings, and saved-data compatibility.

### Source Inputs

- User's First Playable Arrow Puzzle request and confirmed full-spec route.
- [Project constitution](../../../.knowledge/governance/constitution.md), version 2.0.0.
- [Save progression and input settings](../../../.knowledge/architecture/save-progression.md): existing recovery, remapping, and data-preservation behavior remains applicable. No conflicting puzzle rules were found in current knowledge.
- Context gathering found no prior feature specifications and skipped no context sources. The full constitution was read because the context script's summary contained only document metadata.

### Tradeoffs Considered

- Procedural boards and progression would expand content and verification scope; both are explicitly excluded.
- Replacing starter structure would risk unrelated regressions; extend the existing game instead.
- Unlimited mistakes retain an informational score without interrupting the puzzle.
- The main menu's Play/New Game entry now opens the arrow puzzle instead of the sample levels. The starter's Continue and Level Select buttons are hidden because they imply saved level progression that this session-only puzzle does not have. The sample levels, level-select scene and progression scripts stay in source, unreachable from the menu, so they can be restored later. Starting the puzzle no longer resets saved progress.

### Architectural Impact and Constraints

The delivery target is the existing Godot 4.4 desktop application using GDScript and Maaack's Game Template, as required by the user and constitution. These are existing project constraints, not new implementation choices. Core rules and state must be testable without presentation, animations, or mouse events. Touch support is deferred; future touch input must be able to invoke the same selection rules.

No new puzzle persistence is introduced. Existing saved progress, settings, recovery behavior, keyboard/gamepad navigation, and remapping remain compatible. Project-level customization is preferred; any necessary addon changes require justification during planning.

### Working Artifact Lifecycle

This specification and its associated planning/checklist artifacts are temporary working state under `.devspark.work/`. They remain there through implementation and verification until release archival. Durable code, tests, and current knowledge must not reference this specification or its planning identifiers.

### Reviewer Guidance

Focus on direction and distance handling, exactly-once counting during animation, unlimited blocked selections, result arithmetic, replay reset, and preservation of starter controls and settings.

## User Scenarios & Testing

### User Story 1 - Start and Clear the Puzzle (Priority: P1)

As a player, I can launch the existing game, start a puzzle, and select clear arrows with the mouse so that I can empty the board.

**Why this priority**: Starting and clearing a board is the central playable experience.

**Independent Test**: Launch the desktop application, start the fixed puzzle, and follow a valid removal sequence until the remaining count reaches zero.

**Acceptance Scenarios**:

1. **Given** the existing startup/menu flow, **When** the player starts the puzzle, **Then** a rectangular grid displays the same manually defined arrow positions and directions, with remaining count equal to the starting arrow count and mistakes equal to zero.
2. **Given** an active arrow with no active arrow ahead in its row or column, **When** it is selected, **Then** it travels visually off the board in its indicated direction, becomes inactive exactly once, and decreases remaining by one without adding a mistake.
3. **Given** another arrow behind the selected arrow, diagonal to it, or on a different parallel line, **When** the selected arrow has no arrow directly ahead, **Then** those other arrows do not block it.
4. **Given** a removal animation in progress, **When** the player selects the departing arrow again, **Then** no additional removal, tap, or mistake is recorded; other active arrows remain selectable.

### User Story 2 - Learn Through Unlimited Mistakes (Priority: P1)

As a player, I can try blocked arrows repeatedly and continue playing so that mistakes never force me to restart.

**Why this priority**: Uninterrupted experimentation is an explicit requirement of this puzzle.

**Independent Test**: Repeatedly select a blocked arrow, check the counters and feedback, then remove its blocker and finish normally.

**Acceptance Scenarios**:

1. **Given** an active arrow anywhere ahead on the selected arrow's travel line, including across empty cells, **When** the selected arrow is selected, **Then** it remains in its grid position, brief visible feedback occurs, mistakes increases by one, and remaining is unchanged.
2. **Given** a blocked arrow, **When** it is selected 100 consecutive times, including during blocked feedback, **Then** all 100 selections count once each, the board is unchanged, and the player can immediately continue. This is a verification sample, not a limit.
3. **Given** the blocker has been successfully selected and is departing, **When** the previously blocked arrow is selected, **Then** the departing blocker no longer obstructs it.
4. **Given** any mistake count, **When** the player keeps playing, **Then** no lives, failure screen, retry cap, timer, advertisement, or interrupting penalty appears.

### User Story 3 - Review Results and Replay (Priority: P1)

As a player, I can see how I performed and replay the same board so that the first session forms a complete repeatable game loop.

**Why this priority**: Completion feedback and replay are part of the requested success criterion.

**Independent Test**: Complete a run with known mistakes, verify the results, replay, and complete a second run with fresh counters.

**Acceptance Scenarios**:

1. **Given** one active arrow remains with a clear path, **When** it is selected, **Then** remaining reaches zero, its exit animation is allowed to finish, and exactly one completion view shows total arrows, mistakes, score, accuracy, and Replay.
2. **Given** a board with N starting arrows and M mistakes, **When** all N arrows have been removed, **Then** total arrows is N, mistakes is M, and score and accuracy follow FR-010 (at completion, accuracy equals `N / (N + M)`).
3. **Given** a completed puzzle, **When** Replay is activated, **Then** the same positions and directions return, remaining resets to N, mistakes and taps reset to zero, and no previous animation or result affects the new run.
4. **Given** more mistakes than starting arrows, **When** the puzzle is completed, **Then** score is zero and results and replay remain available.

### User Story 4 - Preserve Starter Controls and Settings (Priority: P1)

As an existing player, I retain usable menus and my configured controls and settings while trying the new puzzle.

**Why this priority**: The project constitution mandates preservation of navigation, remapping, and saved data.

**Independent Test**: Exercise affected menus with mouse, keyboard, and gamepad using existing remaps and settings, then start, finish, and replay the puzzle with mouse selection.

**Acceptance Scenarios**:

1. **Given** existing keyboard/gamepad menu bindings, including remapped bindings, **When** the player navigates affected start, pause/resume, results, and replay controls, **Then** applicable navigation and activation remain usable without losing bindings.
2. **Given** existing saved progress and input/audio/window settings, **When** the updated game launches and the puzzle is played and replayed, **Then** existing data remains compatible and settings are respected; replay does not erase unrelated progress or settings.
3. **Given** existing save/settings recovery behavior, **When** startup recovery is needed, **Then** the existing recovery choices remain available and continue to protect recoverable data.

### Edge Cases

- A blocker counts at any distance in the forward row/column, regardless of its own direction; the selected arrow never blocks itself.
- An arrow pointing outward from a board edge is clear unless an active arrow is strictly ahead before that edge.
- Empty cells, background clicks, menu interactions, and selections of inactive/departing arrows do not count as puzzle taps or mistakes.
- Each distinct selection of an active arrow counts once, even during feedback; a held mouse button must not generate repeated selections without new clicks.
- Simultaneous-looking selections are evaluated in accepted order against current active state; departing arrows cannot be removed twice.
- At zero accepted taps, accuracy is defined as zero to avoid division by zero; completion always has at least one successful removal.
- The authored board is nonempty and fully solvable; no circular dependency may leave an uncleared board with no valid move.
- Replay clears pending feedback and animation effects so they cannot alter the new attempt.

## Requirements

### Functional Requirements

- **FR-001**: The existing desktop game MUST offer a start path into one manually defined, nonempty, solvable rectangular grid puzzle. Every arrow MUST occupy one unique grid position and point up, down, left, or right. The board MUST include all four directions and at least one initially blocked and one initially clear selection.
- **FR-002**: The player MUST be able to select an active arrow with a primary mouse click. One discrete click MUST produce at most one selection. Core selection behavior MUST be independent of input device so adding touch later does not change puzzle rules.
- **FR-003**: An arrow MUST be blocked if and only if another active arrow lies strictly ahead on the same row for left/right or the same column for up/down, anywhere between it and the board boundary. Empty cells do not interrupt this check, and blocker direction is irrelevant.
- **FR-004**: A clear selection MUST increment successful removals once, remove the arrow from active blocking and selection immediately, and animate it leaving the board along its direction. Remaining MUST decrease once; mistakes MUST remain unchanged.
- **FR-005**: A blocked selection MUST preserve arrow position, direction, and active status, increment mistakes once, and provide a visible cue that is not solely a color change and lasts no longer than 0.3 seconds. Feedback MUST return the arrow to its normal appearance and MUST NOT block further selections at any time, including while it plays.
- **FR-006**: The puzzle MUST permit unlimited blocked selections and continued play. It MUST have no lives, failure state, retry limit, timer, advertisement, or penalty that interrupts play.
- **FR-007**: During play, counters MUST remain fully visible, uncropped and not overlapping the board at every window size from the 1280x720 default down to 960x540, and MUST show active arrows remaining and mistakes, starting at total arrows and zero respectively and updating after every accepted selection.
- **FR-008**: Total taps MUST count only accepted selections of active arrows, whether clear or blocked. At every state, `total taps = successful removals + mistakes`; inactive-arrow clicks, empty-space clicks, and UI actions MUST leave these counts unchanged.
- **FR-009**: Completion MUST occur exactly once per attempt when no active arrows remain. The final exit animation MUST finish before results obscure the board. Subsequent board clicks MUST leave the completed result unchanged.
- **FR-010**: Completion MUST display starting total arrows, mistakes, `score = max(total arrows - mistakes, 0)`, `accuracy = successful arrow removals / total taps`, Replay, and Main Menu. Accuracy MUST be shown as a percentage rounded to one decimal place, with exact ties rounded half away from zero (for example, 6.25% displays as 6.3%); zero taps MUST yield zero accuracy.
- **FR-011**: Replay MUST start the identical board as a fresh attempt, resetting mistakes, successful removals, taps, completion state, and visual effects while retaining the original total arrow count and unrelated player settings. The existing pause-menu Restart, once confirmed, MUST likewise start a fresh attempt; cancelling Restart MUST leave the current attempt unchanged.
- **FR-012**: Puzzle rules and state MUST be independent of rendering, animation, and input event handling, allowing blocking, selection outcomes, counters, completion, score, accuracy, and reset behavior to be verified without a displayed game or mouse input.
- **FR-013**: Integration MUST preserve the starter's opening/intro, main menu, options (audio, video, input remapping), credits, pause menu, scene loading, and existing keyboard/gamepad navigation and remapping, and compatibility with saved progress/settings and recovery behavior. Affected new menu controls, including Replay, MUST support the existing navigation conventions. Play/New Game MUST open the puzzle without resetting or saving progress. Continue and Level Select MUST be hidden, with their scenes and scripts left in source as described under Tradeoffs Considered, and the main menu MUST show a brief, low-effort note (label or tooltip) stating that existing level progress is preserved even though those entries are hidden. No new puzzle-result persistence or progression MUST be introduced.

### Key Entities

- **Puzzle definition**: Fixed rectangular dimensions and the initial positions and directions of a nonempty set of arrows; reusable unchanged for each attempt.
- **Arrow**: One grid position, one cardinal direction, and current active status.
- **Puzzle attempt**: Initial total, active arrows, successful removals, mistakes, accepted taps, and completion state.
- **Completion result**: Immutable values for the finished attempt's total arrows, mistakes, score, and accuracy.

### Assumptions

- A tap means a selection of an active arrow, not every physical click anywhere in the application.
- A successfully selected arrow becomes inactive immediately; animation depicts the accepted removal and does not govern blocking.
- The exact dimensions and authored layout are implementation choices, provided all four directions, blocked/clear cases, and full solvability are demonstrated.
- Accuracy uses one decimal place, rounding exact ties half away from zero, so the display is readable and deterministic.
- New puzzle arrow selection needs mouse support for this slice; existing keyboard/gamepad navigation is preserved, but new keyboard/gamepad board-selection mechanics are not required.
- No context sources were skipped. No relevant prior puzzle specification was found.

### Out of Scope

- Procedural generation, additional puzzles, level progression, achievements, new puzzle persistence, accounts, online services, and advertisements.
- Lives, failure states, retry limits, timers, or interrupting penalties.
- Android-specific behavior, touch implementation, or a redesign of the starter architecture.

### Required Verification

- Validate affected scripts and scenes in Godot and smoke-test the actual desktop launch/start/play/completion/replay journey. Record results; unavailable required checks remain explicitly outstanding.
- Add an automated regression assertion, not only a manual smoke check, that opening the puzzle from Play/New Game does not call the starter's progress-reset or play-count entry points; this guards FR-013's no-reset guarantee against a future template refresh silently reintroducing either call.
- Verify blocking in all four directions: adjacent and distant blockers, gaps, blockers with different directions, arrows behind/off-axis, outward-facing edge arrows, and inactive blockers.
- Verify exactly-once accounting, rapid repeated clicks, zero-tap handling, nonnegative score, result rounding, final completion, and replay reset. Focused automated rule tests are appropriate regression protection; no blanket test-coverage requirement is imposed.
- Demonstrate a complete valid removal sequence for the fixed puzzle and a second complete run after replay.
- Smoke-test affected menu, pause/resume, restart, and transition paths where integrated, with mouse and existing keyboard/gamepad navigation and remaps. Confirm existing save/settings compatibility and recovery behavior.
- Assert the blocked-feedback cue's duration against its coded constant (FR-005's 0.3-second cap) and the HUD/board layout rects at the 1280x720 and 960x540 window sizes (FR-007's no-overlap requirement) programmatically; manual smoke observation alone is not sufficient evidence for either numeric constraint because sub-second timing and pixel-level overlap are unreliable to judge by eye.

## Success Criteria

### Measurable Outcomes

- **SC-001**: A player can launch the existing application, start the fixed puzzle, remove every arrow through valid selections, view results, and replay that same board without restarting the application.
- **SC-002**: Every case in the four-direction blocking verification matrix yields the specified blocked/clear result, including distant blockers and nonblocking arrows behind or off-axis.
- **SC-003**: After 100 consecutive blocked selections, mistakes increases by exactly 100, remaining is unchanged, and the player can still clear the board without forced restart or interruption; behavior contains no retry threshold.
- **SC-004**: In perfect, mixed, and more-mistakes-than-arrows runs, every live counter and completion value matches the specified formulas; a perfect run has score N and accuracy 100.0%, and a run with N mistakes has score 0 and accuracy 50.0%.
- **SC-005**: After replay, 100% of initial arrow positions/directions are restored, all attempt counters are reset, and a second complete run produces independent results.
- **SC-006**: Rapid clicks and clicks on empty space or departing arrows produce no duplicate removals, extra completion events, or incorrect counters.
- **SC-007**: All affected existing menu navigation paths remain usable with their supported input methods and remapped bindings, and existing settings and saved data remain compatible after play and replay.
