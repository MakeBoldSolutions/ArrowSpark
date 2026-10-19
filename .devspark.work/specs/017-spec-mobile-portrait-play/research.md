---
devspark_version: "9.2.0"
---

# Planning Questions

## Q1 - How do phone targets keep their CSS size across device density?

**Why it matters**: FR-003, FR-008 and FR-009 cannot be met by simply admitting portrait while shrinking a wide scene.
**Evidence needed**: Existing stretch settings, theme target sizes, scene widths and an available engine sizing seam.
**Answer**: project.godot uses canvas_items/expand from 1280x720. AppTheme installs the shared theme before scenes; theme buttons are at least 48 logical units high, with supporting text 16. A 360-wide CSS frame cannot shrink that baseline while maintaining 44-pixel targets. Main Menu assumes a 40% hero, Level Select two fixed 300-unit cards, and game options a 400-unit minimum.
**Evidence pointers**: project.godot [display], scripts/app_theme.gd, scripts/presentation/game_visual_style.gd, scenes/menus/main_menu/main_menu_with_animations.tscn, puzzle_select_menu.gd, scenes/menus/options_menu/game/game_options_menu.tscn. [Godot 4.4 Window reference](https://docs.godotengine.org/en/4.4/classes/class_window.html#class-window-property-content-scale-size) defines content_scale_size as the base content size; [JavaScriptBridge reference](https://docs.godotengine.org/en/4.4/classes/class_javascriptbridge.html) provides access to the iframe's own browser measurements.
**Resolution**: On touch web, AppTheme sets logical content size to the actual iframe CSS dimensions, with factor 1 and current high-density rendering. Reflow project scenes to those units. Retain wide fine-pointer desktop policy. Do not change global button/fonts to compensate for one fixed desktop design and do not add a parent/game message channel. Rendered DPR fixtures and physical-device acceptance must verify the actual mapping; API availability alone proves no layout outcome.

## Q2 - Which boundary should open the new Menu action?

**Why it matters**: FR-007 and FR-011 need one paused/focus-safe lifecycle without duplicate overlays.
**Evidence needed**: Current controller, project pause extension, nested Options behavior and Results lifecycle.
**Answer**: Addon PauseMenuController only opens on ui_cancel and captures focus; OverlaidMenu owns pause restoration and focus on close. Project pause_menu.gd is a thin extension. arrow_puzzle.gd disables the controller for Results. PuzzleSession already exposes request_level_select, consumed by the main menu.
**Evidence pointers**: addons/maaacks_game_template/base/scripts/pause_menu_controller.gd, base/scenes/overlaid_menu/overlaid_menu.gd, scenes/overlaid_menus/pause_menu.gd, scenes/puzzle/arrow_puzzle.gd, scripts/puzzle_session.gd.
**Resolution**: Add a narrow project controller subclass with one guarded open_menu path used by Menu and ui_cancel. Keep existing overlay pause/focus ownership and nested Options lifecycle. Add help/Level Select in the existing project overlay; avoid global synthetic input and addon edits.

## Q3 - Can browser resizing cancel a touch safely today?

**Why it matters**: FR-005 and FR-010 forbid accidental selections during cancellation/rotation.
**Evidence needed**: Raw-touch release path and valid-to-valid board resize path.
**Answer**: Board resize currently calls resize_view and projection but does not always cancel active touches; raw release computes was_tap without an explicit cancelled guard. Pause/focus paths already clear touch state.
**Evidence pointer**: scenes/puzzle/puzzle_board.gd::_notification, _handle_touch, _cancel_drag and _touch_slop; scripts/presentation/puzzle_viewport_transform.gd::resize_view.
**Resolution**: Cancel drag/touches on any resize before reprojection; handle explicit touch cancellation before tap-release logic. Preserve existing 32-physical-pixel slop and transform. Add focused cancelled-release and interrupted-resize checks, without replacing gesture handling.

## Q4 - How does the host use portrait height without a new configuration channel?

**Why it matters**: FR-001/002/010 require browser-chrome responsiveness and retained state.
**Evidence needed**: Admission, iframe initialization, stage CSS and fullscreen target.
**Answer**: GameFrame already sets src once; stage CSS fixes 16:9, coarse landscape alone makes the header non-sticky, fullscreen targets the bare iframe. Existing shell handles adaptive canvas sizing and touch-action.
**Evidence pointers**: web/src/components/play/GameFrame.astro, web/src/scripts/play-admission.ts, web/src/styles/arrowspark.css and web/game-shell/shell.css.
**Resolution**: Keep src-once; use touch host block-size 100dvh and grid rows for measured-by-layout host bar plus remaining stage. Keep stage touch-action and normal scrolling outside it. Observe visual viewport changes for admission and apply the same CSS host/safe-area bounds when host fullscreen is requested. No polling, backend, game messages or inline style/CSP relaxation.

All material planning questions are resolved. Empirical rendering and physical acceptance remain implementation verification, not claims made by this research.
