---
classification: full-spec
risk_level: medium
risk_profile: internal
change_type: brownfield
target_workflow: specify-full
required_artifacts: spec, plan, tasks
recommended_next_step: plan
required_gates: checklist, analyze, critic
route_intent: full-spec
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
status: Draft
---

# Feature Specification: Continuous Arrow Visuals and Game Visual Foundation

**Feature Branch**: `003-spec-continuous-arrow-visuals`
**Created**: 2026-09-26
**Status**: Draft
**Input**: Replace disconnected arrow tiles with continuous arrows, add whole-arrow hover and normalized feedback, and establish the supplied Make Bold light visual system while preserving established puzzle behavior.

## Product Owner TLDR

The working puzzle should look like recognizable, continuous arrows instead of disconnected square blocks. Straight, bent, and single-cell arrows will share a restrained ink-on-light appearance, with whole-arrow hover and brief red feedback for invalid moves. Palette, typography, spacing, shapes, and motion will establish a reusable game visual language. The puzzle, rules, generous click targets, scoring, and replay experience remain unchanged.

## Rationale Summary

### Core Problem

The user has manually played the existing game successfully, but its occupied-cell rectangles obscure the identity of multi-cell arrows. Adjacent tiles do not clearly communicate which body belongs to which head. Presentation lacks a durable game-specific visual language, and an interrupted blocked pulse can leave an arrow enlarged when it begins departure.

### Decision Summary

Show each ordered arrow path as one continuous body with rounded stroke joins, a rounded tail endpoint, and a clear directional head. Establish the user-supplied Make Bold semantic visual system and temporary interaction states without changing domain behavior or expanding game content.

### Key Drivers

- Make complete arrow ownership and direction readable at a glance.
- Preserve the successfully played domain model and established regression expectations.
- Keep whole-cell clicking generous even when visible geometry becomes slender.
- Make interaction feedback responsive, temporary, and consistent across an entire arrow.
- Give future work reusable visual decisions instead of arbitrary local styling.

### Source Inputs

- User attachment titled “Continuous Arrow Visuals and Game Visual Foundation,” supplied with the specify request: its palette, typography, motion, scope, and rendering preference are authoritative inputs.
- User confirmation of full-spec, medium risk and permission to create and switch branches.
- [Project constitution](../../../.knowledge/governance/constitution.md), especially maintainability, project-level customization, accessible controls, responsive feedback, gameplay verification, and settings/progress preservation.
- [Current puzzle architecture](../../../.knowledge/architecture/arrow-puzzle.md) and [save/progression architecture](../../../.knowledge/architecture/save-progression.md).
- Prior [first-playable specification](../001-spec-first-playable-arrow-puzzle/spec.md) and [multi-cell/solvability specification](../002-spec-multi-arrow-solvability/spec.md), plus the source assessment and rendering research in this conversation.
- Current presentation evidence: [ArrowView](../../../scenes/puzzle/arrow_view.gd), [PuzzleBoard](../../../scenes/puzzle/puzzle_board.gd), and [session controller](../../../scenes/puzzle/arrow_puzzle.gd).

### Tradeoffs Considered

- Rounded stroke joins instead of true curved elbows preserve the orthogonal cell-center path and avoid introducing corner-radius path geometry.
- Common ink and negative space instead of per-arrow colors communicate ownership through connection; semantic colors communicate interaction.
- Invisible logical cells retain generous hit targets rather than narrowing selection to the visible stroke.
- Apply a small visual foundation to the puzzle rather than broadly redesigning inherited menus or results.

### Architectural Impact and Supplied Constraints

This change is confined to presentation and integration with existing outcomes. The user’s preferred implementation is a Line2D body with rounded joins and tail cap plus a Polygon2D head, both owned by the existing ArrowView. Preserve this preference for planning; it does not authorize changes to geometry, occupancy, or rules. Ordered cells remain the geometry input, and one logical arrow remains one unit for feedback and departure completion.

Current knowledge describes square tiles, a 1.3× pulse, and no hover. Replacing those behaviors is explicitly authorized, and their descriptions must be updated during implementation. The documented gameplay boundary remains authoritative. No game visual-system document was identified in the reviewed knowledge; the supplied values are the source for the new durable visual language, without requiring an external design-system lookup.

Medium risk reflects hover ownership, interrupted animation, resizing, and styling across presentation responsibilities. This is a feature with deliberate visible changes, not a behavior-neutral refactor. Standard full-spec gates apply; no additional empirical gate mode is introduced.

### Reviewer Guidance

Review continuity at bends and head/body junctions, whole-arrow hover, pulse interruption before departure, negative space, desktop layouts, and preservation of domain behavior. Check that reusable styling and durable documentation stand alone without this spec. Passing headless checks does not establish rendered visual approval or physical keyboard/gamepad verification.

### Assumptions and Scope Interpretation

- Context gathering found both prior specifications and reported no skipped sources. Its constitution summary contained metadata; the full constitution was read separately and governs this draft.
- Existing desktop acceptance remains 1280×720 down to 960×540; no new minimum size or mobile target is introduced.
- Touched presentation includes the board/background, HUD, and existing completion overlay/buttons. Apply applicable palette and typography while retaining information, actions, and basic layout. Do not restyle every inherited menu, pause, options, or credits screen solely for consistency.
- Blocked feedback temporarily overrides hover; after baseline restoration, an arrow still under the pointer resumes hover. Without hover it returns to ink. “Return to normal” means no residual blocked treatment or disabled appearance, not suppression of eligible hover. This precedence is confirmed by the user: restore normal scale and resume ember hover immediately when the pointer remains over the arrow; no pointer exit/re-entry is required.
- Departure overrides interaction states and starts at normal ink and scale, even if the pointer remains over a removed cell. Success green is used in completion presentation rather than overriding this invariant.
- Exact medium/slender proportions and pulse peak within the requested range are tuned and recorded during implementation. Palette, typography roles, join type, and invisible grid are already decided.
- Manual play confirms core gameplay, not the entire earlier desktop/gamepad matrix or declared Godot 4.4 compatibility. New verification records must state the actual engine used.

### Out of Scope

No procedural generation, difficulty classification, solution counting, additional puzzles or levels, progression, new persistence, achievements, Android/mobile-specific work, sound effects, music, broad main-menu redesign, broad results-screen redesign, dark mode, per-arrow color themes, curved-elbow geometry, or new gameplay mechanics. No changes to authored puzzle definitions, geometry validation, solver behavior, witnesses, scoring, or accuracy. No unrelated domain cleanup is authorized.

### Artifact Lifecycle

This draft and checklist are temporary planning artifacts under `.devspark.work/`, retained through implementation and required verification until `/devspark.release` archives the bundle. Production code, tests, and durable knowledge must not reference this spec, its identifiers, or planning paths. Durable visual-system knowledge is an implementation deliverable, not a claim that the new visuals already exist.

## Clarifications

### Session 2026-09-26

- Q: After blocked feedback ends while the pointer remains over the arrow, should hover resume immediately or require pointer exit/re-entry? → A: Resume ember hover immediately at normal scale; no exit/re-entry is required.

## User Scenarios & Testing

### User Story 1 - Read a Continuous Arrow (Priority: P1)

As a player, I can identify each arrow’s complete body and direction without interpreting disconnected blocks.

**Why this priority**: Recognizable arrow shapes are the primary goal.

**Independent Test**: Inspect the unchanged board and isolated straight, single-cell, and multi-bend presentation fixtures in all four directions at both supported sizes.

**Acceptance Scenarios**:

1. **Given** a straight multi-cell arrow, **When** displayed, **Then** its body has no cell-boundary gaps and connects to its head without a visible seam.
2. **Given** multiple right-angle turns, **When** displayed, **Then** the ordered body remains connected through round stroke joins with a rounded tail endpoint, without curved-elbow centerlines.
3. **Given** neighboring cells not consecutive along the same path, **When** rendered, **Then** no extra connection, branch, or closed loop is inferred from adjacency.
4. **Given** a single-cell arrow in any cardinal direction, **When** displayed, **Then** a compact shaft and recognizable head remain inside that cell without new logical occupancy.
5. **Given** neighboring resting arrows, **When** inspected at either size, **Then** visible negative space separates their silhouettes, normal arrows share ink color, and no filled cell tiles or normal grid lines appear.

### User Story 2 - Identify and Select the Whole Arrow (Priority: P1)

As a player, I can hover or click any occupied cell and interact with its complete arrow without needing to hit its narrow visible stroke.

**Why this priority**: Narrower visuals must preserve generous interaction and clarify ownership.

**Independent Test**: Move across head/tail cells and click both the stroke and blank space inside occupied cells while checking outcomes and counters.

**Acceptance Scenarios**:

1. **Given** an active arrow, **When** the pointer enters any occupied cell, **Then** its complete body and head transition to hover color without changing state or counters.
2. **Given** a hovered multi-cell arrow, **When** the pointer crosses its cells, **Then** whole-arrow highlight remains continuous without cell-level flicker or restarting solely because the cell changed.
3. **Given** a hovered arrow, **When** the pointer moves to a different owner, empty cell, outside the board, or leaves the window, **Then** obsolete hover clears and only a currently eligible owner may gain it.
4. **Given** blank visible space within an occupied cell, **When** clicked, **Then** selection resolves exactly as clicking that arrow’s head or shaft, once per discrete press.
5. **Given** a departing arrow remains visible under the pointer, **When** hovered or clicked, **Then** its removed cells produce no hover, selection, taps, or mistakes.

### User Story 3 - Receive Clear Feedback and Clean Departures (Priority: P1)

As a player, I receive brief invalid-move feedback and can immediately continue, while successful arrows depart as complete objects from a consistent appearance.

**Why this priority**: Preserve responsiveness and fix the known pulse/departure interaction.

**Independent Test**: Select a blocked arrow, remove its blocker, then select it at different pulse phases; inspect the first departure frame and completion behavior.

**Acceptance Scenarios**:

1. **Given** a blocked selection, **When** accepted, **Then** the full arrow briefly uses critical red and restrained non-color feedback, mistakes increments once, and input remains enabled.
2. **Given** active blocked feedback, **When** another blocked press occurs, **Then** feedback replaces the old transient effect without accumulating scale and each accepted press counts once.
3. **Given** blocked feedback finishes, **When** the arrow remains active, **Then** normal scale and baseline appearance return; eligible hover may resume, but no disabled-looking, enlarged, gray, or red residual state persists.
4. **Given** an arrow becomes removable during a pulse or hover transition, **When** removal is accepted, **Then** logical removal is immediate and its first departure frame has normal scale and ink, with transient feedback stopped.
5. **Given** a departing arrow, **When** a stale blocked/hover request arrives, **Then** it cannot restart feedback, recolor, or rescale that departure.
6. **Given** concurrent departures, **When** the final logical removal occurs, **Then** results wait for every pending departure exactly as before.

### User Story 4 - Experience a Coherent Light Visual System (Priority: P2)

As a player, I see consistent, readable styling throughout gameplay and completion without learning different navigation or result behavior.

**Why this priority**: Establish an intentional game context and reusable visual foundation.

**Independent Test**: Inspect gameplay/completion at both sizes, then use Replay, Main Menu, pause/options, and Restart with existing supported controls.

**Acceptance Scenarios**:

1. **Given** the puzzle, **When** inspected, **Then** background, normal arrows, labels, numeric values, and buttons follow the supplied semantic palette and applicable typography roles.
2. **Given** completion, **When** results appear, **Then** a restrained green cue communicates success while all result fields, formulas, actions, focus, and basic layout remain intact.
3. **Given** either supported size or resizing between them, **When** the HUD/results are visible, **Then** required text and controls remain readable and uncropped and the HUD does not overlap the board.
4. **Given** existing settings, progress, and remapped controls, **When** entering, pausing, resuming, restarting, replaying, or returning to menu, **Then** unrelated saved values and navigation/remapping behavior remain unchanged.
5. **Given** Restart during feedback, **When** cancelled, **Then** the attempt remains intact; **When** confirmed, **Then** the identical board has fresh counters and no residual effects.

### User Story 5 - Reuse the Game Visual Language (Priority: P2)

As a future contributor, I can find authoritative visual decisions and reuse semantic styling rather than inventing local colors, fonts, spacing, or timings.

**Why this priority**: Durable knowledge is explicitly requested and keeps this foundation useful beyond the current change.

**Independent Test**: Review current knowledge and shared styling after implementation without consulting temporary planning artifacts.

**Acceptance Scenarios**:

1. **Given** completed implementation, **When** current visual knowledge is read, **Then** palette, typography, spacing, shape, motion, and their intended usage are documented.
2. **Given** a supplied token not needed onscreen, **When** the vocabulary is recorded, **Then** its role remains available without adding an unnecessary element to demonstrate it.
3. **Given** no access to this planning bundle, **When** following durable documentation and shared styling, **Then** visual decisions remain understandable without specification identifiers or links.

### Edge Cases

- Single-cell decorative shafts must not introduce logical tail cells.
- All four directions, repeated bends, and adjacent nonconsecutive path cells need correct rendering.
- Head/body overlap must avoid gaps, protruding caps, or detached heads at supported sizes.
- Pointer movement within/between owners, blank occupied-cell space, window exit, and a stationary pointer over a departing arrow must not leave stale highlights.
- Repeated blocked clicks, hover changes during red feedback, and removal at any pulse phase must not accumulate scale or leave transient colors.
- Pause/resume during effects and restart during feedback must preserve lifecycle semantics.
- Resize during departure must not cancel/duplicate completion signals, strand results, or change logical outcomes.
- Long shapes may expand toward neighbors; inspect crowding while tuning the restrained pulse.
- Numeric and percentage text, headings, and controls must remain readable on gameplay and completion surfaces.

## Requirements

### Functional Requirements

- **FR-001**: Each arrow MUST read as one connected body and head derived from its ordered cells. Connect consecutive path cells only. Straight sections and multiple 90-degree bends MUST use connected rounded stroke joins and a rounded tail endpoint. True curved-elbow centerlines MUST NOT be introduced.
- **FR-002**: Heads MUST clearly communicate all four directions and connect seamlessly to their bodies. Single-cell arrows MUST have compact shaft-and-head visuals within their existing cell, without occupancy changes.
- **FR-003**: Arrows MUST have consistent medium/slender weight and visible negative space between different resting arrows at supported sizes. Large filled occupied-cell tiles and normally visible grid lines MUST be removed. Normal arrows MUST share ink color; no per-arrow palette is permitted.
- **FR-004**: The light-only presentation MUST establish reusable semantic styling using the exact palette below across touched puzzle surfaces, HUD, and completion controls. Rust and ember MUST remain accents rather than default arrow colors.
- **FR-005**: Hover over any active occupied logical cell MUST highlight the complete owner in arrow_hover without gameplay mutation. Movement within one owner MUST preserve continuous highlighting. Owner changes, pointer exit, and logical removal MUST clear stale hover. Body/head visuals MUST NOT become independent hit targets.
- **FR-006**: Selection MUST preserve whole-cell targets, including blank space within occupied cells and equal head/tail selection. Empty/departed cells, held buttons without new presses, and UI actions MUST retain existing accounting behavior. Hover MUST NOT introduce persistent selection state.
- **FR-007**: Each blocked attempt MUST briefly color the entire arrow critical red and provide non-color-only feedback through a whole-arrow scale pulse peaking within 1.08–1.12×. Target approximately 150ms, retain the existing 300ms maximum, keep input enabled, and replace rather than accumulate repeated feedback. Final tuning within this range MUST be recorded in durable styling/knowledge.
- **FR-008**: Blocked feedback MUST temporarily override hover, then restore normal scale/baseline appearance and immediately resume ember hover if eligible, without requiring pointer exit/re-entry. No persistent gray/disabled appearance is allowed. Pointer changes, interruption, and pause/resume MUST NOT leave stale effects.
- **FR-009**: Before departure, mark the view departing, stop active transient feedback, synchronously restore scale 1.0×, arrow_normal ink, and other transient properties to ordinary baseline, then start departure. Departing views MUST ignore subsequent blocked/hover requests. The first departure frame MUST satisfy the baseline at every interruption phase.
- **FR-010**: Logical removal MUST remain immediate. The entire connected visual arrow MUST translate rigidly in its head direction, without swept-body collision, tail-following, or snake movement. Preserve one completion notification per arrow and the all-departures barrier. Retain 250ms departure unless a documented visual evaluation justifies adjustment within 200–250ms.
- **FR-011**: Touched puzzle presentation MUST use the typography roles below, scale readably across the existing desktop range, and keep required HUD/results content and controls visible and uncropped. Numeric text MUST use tabular figures where supported. Broad inherited-screen typography conversion is excluded.
- **FR-012**: Reusable styling MUST establish the supplied spacing, radius, border, shadow, and motion tokens without requiring all tokens onscreen. Use smooth ease-out motion without bounce. Hover/lightweight transitions target approximately 120ms and MUST be interruptible without stale final states.
- **FR-013**: Completion MUST have a restrained game_success cue while retaining existing information, actions, focus, and basic layout. Positive color MUST NOT override first-departure-frame normalization. No broad results redesign is permitted.
- **FR-014**: Preserve puzzle definitions, geometry rules, head/tail semantics, ownership, blocking, PuzzleState behavior, solvability, witnesses, scoring, accuracy, mistake counting, unlimited attempts, completion, replay, immediate removal, whole-cell targets, and the departure barrier. Existing domain regression expectations MUST NOT be weakened or rewritten merely for presentation.
- **FR-015**: Preserve existing menu/pause/results keyboard/gamepad navigation, focus, remapping, saved progress/settings compatibility, Replay, and confirmed/cancelled Restart. No new persistence or gameplay input method is introduced.
- **FR-016**: Implementation MUST add/update current project knowledge for palette, typography, spacing, shape, motion, state precedence, and intended usage, and correct obsolete presentation descriptions. Shared styling MUST expose reusable named roles. Durable outputs MUST stand alone without specification identifiers or planning backlinks.
- **FR-017**: Acceptance MUST include Godot validation, unchanged domain and save/input regression expectations, focused presentation checks, and rendered desktop smoke covering affected lifecycle/navigation paths. Record actual engine version, results, and limitations; unavailable physical/visual checks MUST remain outstanding.

### Semantic Palette

| Token | Value | Intended role |
|---|---|---|
| game_background | #F8F6F2 | Light game background |
| game_surface | #FFFFFF | Content surfaces where used |
| arrow_normal | #1E1E1E | Common normal arrow ink |
| arrow_hover | #C6620C | Whole-arrow mouse hover, ember |
| game_accent | #982407 | Primary accent, rust |
| game_success | #2F6F4C | Positive/completion feedback |
| text_primary | #1E1E1E | Primary text |
| text_secondary | #56544F | Supporting text |
| text_on_accent | #F8F6F2 | Text on accent surfaces |
| critical | #A8321A | Temporary invalid-move feedback |
| surface_border | #DDD9D0 | Surface borders where used |

### Typography Roles

| Role | Family and weight |
|---|---|
| Major/game headings | Be Vietnam Pro ExtraBold 800 |
| Secondary headings | Be Vietnam Pro Bold 700 |
| Interface labels and buttons | Inter Tight 600 |
| General UI/supporting text | Inter Tight 400 |
| Numeric values | Inter Tight 600; tabular figures where supported |

### Supporting Visual Tokens

- Small radius: 6px; large panel radius: 10px; borders: 1px.
- Spacing: 4, 8, 12, 16, 24, 32, 48px.
- Medium shadow: offset (0,4), size 12, rgba(30,30,30,0.08).
- Hover/lightweight interaction: approximately 120ms.
- Blocked feedback: approximately 150ms, no more than 300ms.
- Meaningful transitions: approximately 200–250ms; departure remains 250ms by default.
- Smooth ease-out; no bounce. Establish the vocabulary without requiring every token to be displayed.

### Verification Boundaries

Domain suites remain authoritative for rules and arithmetic. Presentation checks additionally cover ordered connectivity, owner-wide hover without mutation, normalized first-departure appearance after interruption, and exactly-once departure completion. Rendered review inspects seams, direction, caps, adjacent silhouettes, font roles, and readability at 1280×720 and 960×540 and during resizing.

Desktop smoke includes physical head/tail/blank-within-cell clicks, rapid blocked selections, removal during a pulse, concurrent departures, completion, Replay, pause/resume, Restart cancel/confirm, options, and return to menu. Check affected keyboard/gamepad focus/navigation and remap survival; disclose missing hardware. Use isolated presentation fixtures as needed, without changing production puzzle definitions.

## Success Criteria

### Measurable Outcomes

- **SC-001**: At both supported sizes, every arrow on the existing board reads as one connected silhouette without occupied-cell squares; visual fixtures also pass straight, single-cell, and multi-bend forms in all four directions without unintended adjacency connections.
- **SC-002**: Every tested head/tail/blank-within-cell hover identifies exactly its complete active owner, with no cell-level flicker within an owner and zero gameplay counter changes from hover alone.
- **SC-003**: Repeated blocked presses remain responsive; feedback finishes within 300ms of the last press, peaks within 1.08–1.12×, and leaves no persistent invalid/disabled treatment. Eligible hover may resume.
- **SC-004**: Departures triggered during rising, peak, and falling pulses or hover transitions all begin at 1.0× scale and normal ink. Stale feedback cannot alter departure, and each departure completes exactly once.
- **SC-005**: Completing/replaying the existing puzzle with the same accepted click sequences produces unchanged outcomes, counters, score, and accuracy; no domain regression expectation is altered to secure a pass.
- **SC-006**: Gameplay/completion visibly use the supplied light palette and applicable font roles at both sizes with required text/actions readable and uncropped and no HUD/board overlap. Navigation and settings/progress checks pass or have explicitly outstanding limitations.
- **SC-007**: Current visual knowledge contains every supplied palette token, typography role, spacing/shape token, and motion rule with intended usage and shared-style references, understandable without this planning bundle.
