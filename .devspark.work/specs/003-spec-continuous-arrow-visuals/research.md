# Research: Continuous Arrow Visuals and Game Visual Foundation

**Date**: 2026-09-26. Planning research only; no production changes, downloaded fonts, rendered experiments, or runtime validation claimed.

## Continuous renderer

**Decision**: Line2D body and Polygon2D head under the existing ArrowView Control. Rounded joins/cap, same opaque fill, head overlapping the end of the shaft. Ordered offsets become cell centers; only consecutive points connect. Single-cell arrows get an in-cell decorative shaft.

**Rationale**: Current PuzzleBoard preserves order while converting definition cells to view-local offsets and already computes bounding boxes. Line2D supplies joins/caps; a separate head gives predictable direction/proportion. Parent transforms preserve one-arrow feedback/departure. Antialias both components and inspect their seam in the Compatibility renderer.

**Alternatives considered**: Custom composed primitives need seam/join management; a silhouette polygon needs boundary construction; sprites require corner variants; curved centerline elbows are explicitly excluded. No performance need for meshes/shaders at eight arrows. Antialiased Line2D lacks batching, an acceptable initial tradeoff for this board pending rendered verification.

**Primary sources**: [Godot 4.4 Line2D](https://docs.godotengine.org/en/4.4/classes/class_line2d.html), [Polygon2D](https://docs.godotengine.org/en/4.4/classes/class_polygon2d.html), [CanvasItem](https://docs.godotengine.org/en/4.4/classes/class_canvasitem.html). Documented capabilities: local point arrays, join/cap modes, antialiasing, and inherited transforms. Proportions in plan.md are project design decisions, not claims from these sources.

## Owner hover and effect precedence

**Decision**: Board emits raw pointer cells; controller uses PuzzleState.get_arrow_head; board highlights one canonical view. Refresh stationary pointers while eligible and clear on overlay/pause/focus loss/removal. View owns presentation flags only. Departure > blocked > hover > normal. Red completion immediately resumes eligible ember hover at normal scale, as explicitly confirmed.

**Rationale**: No second rule/ownership authority and no selection state. The board's input rectangle already supplies generous whole-cell targets. Deduplicate by owner, not only raw cell, to avoid repeated transitions. Theme/input overlay eligibility must be checked so hidden or covered boards do not retain hover.

**Alternatives considered**: Per-segment picking would shrink targets and fragment ownership. Recomputing legality for hover would couple presentation to rules and imply disabled arrows. A duplicated active occupancy map would drift from PuzzleState.

**Primary source**: [Godot 4.4 Control](https://docs.godotengine.org/en/4.4/classes/class_control.html) documents GUI event filtering and theme inheritance. Exact routing above is inferred from the local board/controller boundary and is a project design choice.

## Interruptible feedback

**Decision**: Separate hover-color and effect handles; cancel both on departure, synchronously normalize scale/color/flags, then begin the position tween. Terminal departing guard rejects later feedback. Retain existing duration authority in PuzzleFeedback, default pulse 1.10, no bounce.

**Rationale**: Current play_exit_animation kills the pulse without resetting scale. A killed tween does not complete its reset phase. Explicit normalization avoids dependence on frame timing or callbacks. One property must not have competing live writers.

**Alternatives considered**: Waiting for pulse completion delays success; normalizing over the exit animation violates the first-frame guarantee; one undifferentiated tween handle allows hover changes to interrupt motion.

**Primary source**: [Godot 4.4 Tween](https://docs.godotengine.org/en/4.4/classes/class_tween.html): kill aborts operations; avoid multiple tweens targeting the same property. This supports explicit cancellation, not implicit rollback.

## Semantic visual source and theme scope

**Decision**: New GameVisualStyle helper centralizes palette and dimensions and constructs a cached Theme using bundled fonts. Assign it only to Layout and PuzzleResults; do not set a global or root theme that propagates to runtime pause/options overlays. Existing results score is the success-green cue. Use semantic constants for backgrounds and arrow colors as well as Theme creation.

**Rationale**: Shared script/theme values avoid arbitrary duplicated literals. Existing scene hierarchy has pause overlays attached to the root, so a root theme would broaden scope unintentionally. Current mixed numeric labels can use the numeric semibold variation without changing their public names or controller updates.

**Alternatives considered**: Global theme would restyle inherited screens; a separate .tres with repeated literal palette values could drift; splitting every label/value into new nodes adds unnecessary layout churn.

**Primary source**: Control documentation above describes theme inheritance. Palette/typography values come from the user's supplied design system, not external web research.

## Fonts and numeric figures

**Decision**: Bundle official Be Vietnam Pro static 700/800 fonts and Inter Tight upright variable font; use FontVariation resources for 400/600 and numeric 600. Keep each family's OFL license and add attribution. Record upstream revision/hash during acquisition. No fonts are currently bundled in the inspected repository.

**Rationale**: FontVariation supports explicit OpenType weight selection; the two font families need no third-party runtime library. The package must work offline. Confirm tnum capability from the actual bundled font and verify digit advances/equal-length numeric strings; family naming alone is not evidence. If absent, retain Inter Tight 600 and document the allowed 'where supported' fallback rather than inventing tabular support.

**Alternatives considered**: Machine fonts are not portable; runtime Google Fonts requests add an unnecessary dependency; generating static instances requires extra build tooling. Use official existing static Be Vietnam files and the official Inter Tight variable binary.

**Primary sources**: [Be Vietnam Pro metadata](https://raw.githubusercontent.com/google/fonts/main/ofl/bevietnampro/METADATA.pb) names BeVietnamPro-Bold.ttf and BeVietnamPro-ExtraBold.ttf; [Inter Tight metadata](https://raw.githubusercontent.com/google/fonts/main/ofl/intertight/METADATA.pb) names InterTight[wght].ttf with a 100–900 weight axis. Retain the [Be Vietnam Pro OFL](https://raw.githubusercontent.com/google/fonts/main/ofl/bevietnampro/OFL.txt) and [Inter Tight OFL](https://raw.githubusercontent.com/google/fonts/main/ofl/intertight/OFL.txt). [Godot 4.4 FontVariation](https://docs.godotengine.org/en/4.4/classes/class_fontvariation.html), [Font supported-feature API](https://docs.godotengine.org/en/4.4/classes/class_font.html), and [Using fonts](https://docs.godotengine.org/en/4.4/tutorials/ui/gui_using_fonts.html) provide the relevant runtime APIs. Verify actual binary support and capture upstream revision/hash during implementation; these branch URLs are research entry points, not pinned assets. The plan workflow's delegated font research found no local font assets and made no changes/downloads.

## Verification strategy

**Decision**: Retain unchanged domain/save expectations; add real-project presentation checks after isolated import and a mandatory rendered/physical smoke matrix. Test interruption phases deterministically using effect progression where useful and assert state immediately after invoking departure before any frame advance. Exercise board _gui_input/viewport dispatch as well as internal signal integration. Fresh-scene tests supplement, not replace, actual Replay/Restart clicks.

**Rationale**: Existing layout tests mostly emit signals and cannot establish mouse dispatch, stroke clarity, fonts, or first-frame appearance. Headless geometry/state checks make timing bugs reproducible; rendered smoke establishes appearance and navigation. Do not create visual fixtures by modifying shipped puzzle data.

**Alternatives considered**: Screenshot-only verification misses accounting/state transitions; only testing named constants does not prove actual effects reset; rewriting domain expectations would hide regressions.

## Resolution

No unresolved functional or technical research questions block planning. Proportions, antialias quality, installed-engine availability, asset tnum support, and desktop/gamepad execution remain explicit implementation validation items with defaults/fallbacks, not unspecified behavior.
