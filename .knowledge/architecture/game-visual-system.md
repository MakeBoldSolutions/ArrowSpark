---
id: game-visual-system
type: architecture
title: Game Visual System
appliesTo:
  - scripts/presentation/game_visual_style.gd
  - scripts/presentation/arrow_departure_geometry.gd
  - scripts/presentation/puzzle_viewport_transform.gd
  - resources/fonts/**
  - assets/fonts/**
  - scenes/puzzle/**
  - tests/puzzle_presentation_check.gd
  - tests/puzzle_canvas_check.gd
  - tests/puzzle_canvas_visual_check.gd
  - tests/puzzle_viewport_transform_check.gd
  - tests/arrow_departure_geometry_check.gd
  - tests/arrow_departure_visual_check.gd
---

# Game Visual System

GameVisualStyle is a presentation-only vocabulary; rules never depend on it.
Normal arrows share #1E1E1E ink, no per-arrow colors or cell tiles. Each view
owns a passive antialiased Line2D body and a filled Polygon2D head above it.
Ordered cell centers form the body, with round joins and a round tail cap;
right-angle centerlines are retained. Neighboring nonconsecutive cells do
not connect. Invisible logical cells remain the input targets.

Geometry ratios relative to cell extent: shaft width 0.14, head tip +0.30,
head base -0.06, head half-width 0.22, shaft end -0.02. Single-cell shafts
start at -0.30. The endpoint overlaps the head; normal silhouettes stay
inside their cell corridors and leave negative space. Geometry is built
once at a fixed canonical 64-pixel cell extent and displayed through a
parent `World` transform (scale = displayed pixels per cell / 64), so fit,
zoom, pan and resize never rebuild it and stroke width, head size and
proportions scale together; departure feeds the whole shape through its own stationary route
and out past the grid edge (see Feedback precedence and departures below),
not whole-object translation.

Source of truth: tests/puzzle_presentation_check.gd verifies ordered
geometry, all four directions, copied offsets, head overlap and extent
rebuilds; tests/puzzle_layout_check.gd verifies board bounds and click mapping.
Rendered seam/antialias quality requires desktop review; point assertions
cannot establish it.

## Whole-arrow hover

PuzzleBoard samples a board-local cell through mouse motion and stationary
pointer refresh. The controller resolves only PuzzleState.get_arrow_head,
then returns the active canonical owner to set_hovered_head. Same-owner
cell changes do not restart the 120ms ease-out color tween. Body and head
share ember #C6620C while hovered. Logical whole-cell targets, including
blank space beside the shaft, remain unchanged; hover never selects.

Pause, pointer/window exit, focus loss, hiding, setup and removal clear
hover and invalidate the sampled cell. Per-frame cursor-target refresh prevents cached GUI hover from surviving a
new overlay beneath a stationary pointer. Eligibility requires the
board to be the viewport's actual hovered Control in a focused, unpaused
window. Overlays therefore suppress underlying hover; resume and resize
resample even a stationary pointer. Source of truth:
tests/puzzle_presentation_check.gd (GUI motion/press/release, ownership,
cache invalidation, counters, removal) and scenes/puzzle/puzzle_board.gd.
Code-only for OS pointer eligibility: actual focus/window behavior requires
rendered desktop input and cannot be established by direct headless events.

## Feedback precedence and departures

ArrowView orders presentation as departing > blocked > suggested > hover > normal.
Blocked presses cancel both existing writers, set the entire arrow to
critical #E8221A, restart a 1.00 -> 1.10 -> 1.00 pulse over 150ms, and hold the
red for 600ms in total before returning to normal.
Hover eligibility can change during red feedback without recoloring it.
Completion restores unit scale and immediately assigns ember if eligible,
otherwise ink; there is no extra hover-duration delay. No input lock or
persistent disabled appearance is introduced.

Departure first marks terminal state, kills color/effect tweens, resets
scale/modulation/visibility and ink synchronously, builds a stationary
tail-to-head cell-unit route from the arrow's own ordered shape (or the
existing single-cell synthetic shaft), then advances one scalar cell-unit
distance forward at a centrally configured, shared speed (10 cells/second,
`PuzzleFeedback.EXIT_SPEED_CELLS_PER_SECOND`). Bends stay fixed in board
coordinates and are consumed as the tail passes them; the head continues
analytically along its own forward direction past its original position.
Later hover/block/exit requests are ignored, and repeated start requests are
ignored once departing.

`scripts/presentation/arrow_departure_geometry.gd` (`ArrowDepartureGeometry`,
a pure `RefCounted` helper with no Node/domain dependency) owns the route
math: cumulative-length sampling (`sample_distance`), moving-interval
extraction with every intervening corner retained (`extract_interval`), and
the direction/grid-size-only forward-grid clearance calculation
(`forward_clearance`). It takes the caller's style-ratio offsets (head-base
distance, tail-cap radius) as constructor arguments rather than referencing
GameVisualStyle directly, and asserts the tail-cap-dominance invariant
(`length + head_base >= -tail_cap_radius`) on construction so a future
style-ratio edit that breaks it fails loudly in the editor/regression
pipeline — this assert is stripped from exported release templates, so it is
a dev/test-time guard, not a production safety net; `ArrowView` is the sole
caller and supplies `GameVisualStyle.HEAD_BASE`/`BODY_WIDTH`. `ArrowView`
rebuilds this route once per departure start and re-renders the same cell
distance at its canonical extent, never restarting or recomputing the
route on resize or navigation (only the parent projection changes).

A departure finishes only once cell-distance progress reaches
`length + forward_clearance(...)` (route length plus remaining edge distance
plus the tail-cap radius plus a small tolerance margin), so full-tail
clearance — not head exit — triggers completion, exactly once, guarded
against direct-call bypass of pause/invalid-layout/already-finished state.
`PuzzleBoard` erases active ownership, reparents the view into a passive
`DepartureClip` `Control` (clip_contents, mouse-filter ignore) sized to the
full logical board extent (canonical pixels, at the `World` origin under the
World transform), and connects the one-shot
completion before starting movement. Active and departing views share the one `World` projection; departing
views never restart or recompute their route, only their parent projection
changes, and a departure watched at any zoom (or entirely off-screen) still
clears the full logical board. Pause
suspends advancement with the tree (also enforced by an explicit paused
check so direct test calls cannot bypass it); an invalid (zero, tiny or non-finite) layout suspends
advancement through `ArrowView.set_presentation_layout_valid` without
corrupting or falsely completing it, and advancement resumes from the frozen
progress once the area is valid. `setup()`
replacement cancels and disposes any in-flight departures before clearing
collections, so a replaced attempt never receives a stale completion.
PuzzleFeedback remains the speed/clearance-margin authority, with no font or
style dependency; GameVisualStyle owns pulse amplitude, hover time and the
geometry ratios the route math is built from.

Source of truth: tests/arrow_departure_geometry_check.gd (pure route math:
all four directions, synthetic shaft, straight/one-bend/multi-bend routes,
cumulative length, exact/corner-adjacent sampling, forward-ray extension,
coincident-point and short-segment safety, constant unclipped centerline
length, forward-grid clearance, tail-cap-dominance guard) covers the helper
in isolation; tests/puzzle_presentation_check.gd checks rising/peak/falling
blocked-pulse interruption, immediate properties, repeated pulses, hover
precedence, initial silhouette equivalence, head/body overlap, cardinal
orientation, equal-delta-partition speed and exactly-once full-tail
completion; tests/puzzle_canvas_check.gd checks canonical geometry under
navigation, concurrent long departures under zoom/pan/resize/pause/zero-area,
replacement and exactly-once completion; tests/puzzle_viewport_transform_check.gd
checks the projection math; tests/puzzle_layout_check.gd checks staggered departures, pause,
resize (960x540/1280x720/800x800, including while paused and to zero
extent), a combined concurrent-departure/pause/resize/resume scenario,
setup-replacement disposal, completed-input ignoring and fresh attempts.
Rendered seam/antialias and feeding-motion readability quality require
desktop review (tests/arrow_departure_visual_check.gd is the manual fixture
for shape/direction categories the shipped board omits); point/interval
assertions cannot establish it.

## Typography and local theme

Fonts are bundled offline from Google Fonts revision
23e54b51ddffbc7713c583748e3bd86f62b1fa4a. ATTRIBUTION.md records upstream
links and SHA-256 hashes. Both SIL Open Font License notices remain beside
the fonts and are embedded verbatim in resources/fonts/font_licenses.tres,
a GameVisualStyle dependency retained by exported packs.

| Role / Theme variation | Font | Size |
|---|---|---|
| GameHeading | Be Vietnam Pro ExtraBold 800 | 32 |
| SecondaryHeading | Be Vietnam Pro Bold 700 | 24 |
| InterfaceLabel / PrimaryButton / SecondaryButton | Inter Tight 600 | 20 |
| SupportingText | Inter Tight 400 | 16 |
| NumericText / SuccessText | Inter Tight 600, tnum enabled | 20 |

Inter Tight exposes tnum and the numeric resource gives equal digit advances.
Static ExtraBold's legacy family name is `Be Vietnam Pro ExtraBold`; Godot's
style API reports 700, but the actual font OS/2 table specifies 800. Tests
verify that binary value instead of treating the heuristic as font weight.
Headings are reusable roles; no extra heading is added merely to display them.
Mixed caption/value HUD and results labels use the numeric font as a whole.

The cached theme attaches to ArrowPuzzle's Layout and PuzzleResults only,
never to the game root or project theme. Runtime inherited pause/options
therefore keep their styling. The background ColorRect ignores input. Results
retain four metrics, two actions, Replay focus and full-overlay absorption.
SuccessText gives the existing score a restrained green cue. Focused buttons
have an ember border expanded outside their normal bounds. Body text stays
at readable logical sizes rather than scaling with cells.

Source of truth: tests/puzzle_presentation_check.gd verifies real families,
weights, tabular digits, scoped theme, focus border, result arithmetic and
text/control bounds at 1280x720 and 960x540. Physical navigation and rendered
font quality require desktop checks in addition to those assertions.

## Semantic palette

| Token | Value | Intended usage |
|---|---|---|
| game_background | #F8F6F2 | Light gameplay and completion background |
| game_surface | #FFFFFF | Secondary buttons and optional content panels |
| arrow_normal | #1E1E1E | Shared resting and departing ink |
| arrow_hover | #C6620C | Whole-owner hover and focus/hover border accent |
| game_accent | #982407 | Primary button rust accent |
| game_success | #2F6F4C | Completion score cue |
| text_primary | #1E1E1E | Labels and secondary-button text |
| text_secondary | #56544F | Supporting text |
| text_on_accent | #F8F6F2 | Primary-button text |
| critical | #E8221A | Temporary blocked feedback |
| surface_border | #DDD9D0 | Surface/button outline |

Rust and ember are accents, never the default arrow color. There is one
light system, no per-arrow color scheme and no persistent disabled arrow.

## Spacing, shape and motion vocabulary

Spacing steps are 4, 8, 12, 16, 24, 32 and 48 logical pixels. Use 12 for
compact control gaps and vertical button padding, 16 for horizontal button
padding, 24 for HUD separation. Small radius 6 suits buttons; large radius
10 suits GameSurface panels. Borders are 1 pixel; focus adds a distinct
2-pixel ember outline with 3-pixel outward expansion. Medium panel shadow:
offset (0,4), size 12, rgba(30,30,30,0.08). Optional surface/shadow/heading
roles remain available without adding decorative content to demonstrate them.

Lightweight hover is 120ms. Blocked feedback is a 150ms pulse inside a 600ms red hold (750ms coded cap) with
a quadratic ease-out tween without bounce. Departure instead advances at a
constant, centrally configured cell-distance speed (10 cells/second) rather
than a fixed duration or tween, so travel time scales with route length and
edge distance; per-departure frame work is a bounded interval-extraction
pass, not a blocking wait. All interaction effects are interruptible; no
frame-loop geometry rebuilding beyond that bounded pass occurs. The initial
ratios and 1.10 pulse are retained; rendered acceptance is required before
treating their appearance as approved. Palette and vocabulary authority: scripts/presentation/game_visual_style.gd;
code-only for unused roles because they intentionally have no onscreen consumer.

## Canvas rendering and feedback readability

Working scale is 64 pixels per cell; overview may be smaller and zoom reaches
192 pixels per cell (see `.knowledge/architecture/arrow-puzzle.md`, Canvas
Navigation, for the transform and input contract). Hover, blocked and Open
Move feedback are unchanged in color and pulse amplitude at any zoom. The
board shows a 2-pixel ember focus outline while it owns keyboard/gamepad focus,
and the Pan toggle uses the standard pressed-button vocabulary. Selecting the
head of a long arrow reveals it at a readable scale with padding before the
existing pulse. Antialiased Line2D/Polygon2D readability across zoom levels is a
rendered-desktop review item, not a headless assertion:
tests/puzzle_canvas_visual_check.gd (non-headless, manual) records navigation-
handler and frame times on the large fixture and saves overview/working-scale/
maximum-zoom captures for that review.
