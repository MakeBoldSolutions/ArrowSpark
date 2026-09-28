extends SceneTree
## Headless isolated-project unit checks for PuzzleViewportTransform: pure
## numeric presentation math with no scene, rule-class or font dependency.
## Run via tests/run_puzzle_regressions.py in its own bare temporary project.

var failures: int = 0

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func _near(a: float, b: float, tolerance: float = 0.001) -> bool:
	return absf(a - b) <= tolerance

func _near_v(a: Vector2, b: Vector2, tolerance: float = 0.001) -> bool:
	return a.distance_to(b) <= tolerance

func _make(grid: Vector2i, area: Vector2) -> PuzzleViewportTransform:
	var transform := PuzzleViewportTransform.new()
	transform.configure(grid)
	transform.resize_view(area)
	return transform

func _test_fit_margin_and_containment() -> void:
	var transform := _make(Vector2i(10, 5), Vector2(832, 432))
	# min((832-32)/10, (432-32)/5) = min(80, 80)
	check(_near(transform.cell_pixels, 80.0), "fit scale honors the 16-pixel margin on the limiting axis")
	check(transform.fit_mode, "a fresh setup is in fit mode")
	check(transform.layout_valid, "a usable area is a valid layout")
	check(_near_v(transform.center_cells, Vector2(5, 2.5)), "fit centers the complete original board")
	var top_left := transform.logical_to_local(Vector2.ZERO)
	var bottom_right := transform.logical_to_local(Vector2(10, 5))
	check(top_left.x >= 16.0 - 0.5 and top_left.y >= 16.0 - 0.5, "fit keeps the board top-left inside the margin")
	check(bottom_right.x <= 832.0 - 16.0 + 0.5 and bottom_right.y <= 432.0 - 16.0 + 0.5,
		"fit keeps the board bottom-right inside the margin")

	var wide := _make(Vector2i(4, 4), Vector2(1000, 232))
	check(_near(wide.cell_pixels, 50.0), "the shorter viewport axis limits the fit scale")

func _test_inverse_round_trips() -> void:
	var transform := _make(Vector2i(40, 30), Vector2(1000, 600))
	transform.zoom_at(2.0, Vector2(700, 100))
	transform.pan_pixels(Vector2(-120, 75))
	var samples: Array[Vector2] = [Vector2(0.5, 0.5), Vector2(20, 15), Vector2(39.5, 29.5), Vector2(3.25, 17.75)]
	var round_trips_ok := true
	for point in samples:
		var back := transform.local_to_logical(transform.logical_to_local(point))
		if not _near_v(back, point):
			round_trips_ok = false
	check(round_trips_ok, "logical -> local -> logical round trips within 0.001 cell")
	var local_ok := true
	for p in [Vector2(10, 10), Vector2(500, 300), Vector2(990, 590)]:
		if not _near_v(transform.logical_to_local(transform.local_to_logical(p)), p, 0.05):
			local_ok = false
	check(local_ok, "local -> logical -> local round trips")
	var center_screen := transform.logical_to_local(transform.center_cells)
	check(_near_v(center_screen, Vector2(500, 300)), "the focal center projects to the middle of the viewport")

func _test_cell_at() -> void:
	var transform := _make(Vector2i(10, 10), Vector2(532, 532))
	# fit scale 50, fully centered: cell (0,0) spans local (16,16)-(66,66)
	check(transform.cell_at(Vector2(20, 20)) == Vector2i(0, 0), "a point inside the first cell resolves to it")
	check(transform.cell_at(Vector2(65.9, 65.9)) == Vector2i(0, 0), "the far corner of a cell still belongs to it")
	check(transform.cell_at(Vector2(66.1, 20)) == Vector2i(1, 0), "crossing a cell boundary advances the index")
	check(transform.cell_at(Vector2(5, 5)) == Vector2i(-1, -1), "the margin outside the board resolves to no cell")
	check(transform.cell_at(Vector2(-4, 200)) == Vector2i(-1, -1), "a point outside the viewport resolves to no cell")
	check(transform.cell_at(Vector2(540, 200)) == Vector2i(-1, -1), "a point beyond the viewport resolves to no cell")
	check(transform.cell_at(Vector2(515, 515)) == Vector2i(9, 9), "the last cell is reachable")

func _test_zoom_anchor_and_limits() -> void:
	var transform := _make(Vector2i(40, 30), Vector2(1000, 600))
	var fit_scale := transform.cell_pixels
	check(_near(fit_scale, 568.0 / 30.0), "large board fit scale is limited by the height: (600-32)/30")
	var anchor := Vector2(300, 200)
	var before := transform.local_to_logical(anchor)
	check(transform.zoom_at(2.0, anchor), "zooming in reports an effective change")
	check(not transform.fit_mode, "an effective zoom leaves fit mode")
	check(_near(transform.cell_pixels, fit_scale * 2.0, 0.01), "zoom multiplies the scale by the factor")
	check(_near_v(transform.local_to_logical(anchor), before, 0.01), "the pointer anchor keeps its logical point")

	transform.zoom_at(1000.0, Vector2(500, 300))
	check(_near(transform.cell_pixels, 192.0), "zoom in saturates at the 192 pixel maximum")
	var saturated_center := transform.center_cells
	check(not transform.zoom_at(1.2, Vector2(500, 300)), "zooming past the maximum is a no-op")
	check(_near_v(transform.center_cells, saturated_center), "a saturated zoom leaves the view untouched")

	transform.zoom_at(0.0001, Vector2(500, 300))
	check(_near(transform.cell_pixels, fit_scale, 0.001), "zoom out saturates at the fit scale")

	check(not transform.zoom_at(NAN, Vector2.ZERO) and not transform.zoom_at(-2.0, Vector2.ZERO) \
		and not transform.zoom_at(0.0, Vector2.ZERO) and not transform.zoom_at(INF, Vector2.ZERO),
		"nonfinite or nonpositive factors are rejected")
	check(_near(transform.cell_pixels, fit_scale, 0.001), "rejected factors leave the scale unchanged")

func _test_noop_bound_keeps_fit_mode() -> void:
	var transform := _make(Vector2i(40, 30), Vector2(1000, 600))
	check(not transform.zoom_at(0.5, Vector2(100, 100)), "zooming out at the fit scale is a no-op")
	check(transform.fit_mode, "a no-op at a bound does not leave fit mode")
	check(not transform.pan_pixels(Vector2(50, 50)), "panning a board that fits its axes cannot move it")
	check(transform.fit_mode, "a clamped-away pan does not leave fit mode")

func _test_pan_clamping() -> void:
	var transform := _make(Vector2i(40, 30), Vector2(1000, 600))
	transform.zoom_at(4.0, Vector2(500, 300))
	var s := transform.cell_pixels
	var half := (Vector2(1000, 600) - Vector2(32, 32)) / (2.0 * s)
	transform.pan_pixels(Vector2(1.0e6, 1.0e6))
	check(_near_v(transform.center_cells, half, 0.001), "dragging content far right/down clamps to the top-left margin")
	check(_near_v(transform.logical_to_local(Vector2.ZERO), Vector2(16, 16), 0.01),
		"at the top-left extreme the board corner sits on the fit margin")
	transform.pan_pixels(Vector2(-1.0e6, -1.0e6))
	check(_near_v(transform.center_cells, Vector2(40, 30) - half, 0.001), "dragging the other way clamps to the far corner")
	check(_near_v(transform.logical_to_local(Vector2(40, 30)), Vector2(984, 584), 0.01),
		"at the far extreme the board corner sits on the fit margin")

	# per-axis: a board that fits one axis stays centered there while the other pans.
	var tall := _make(Vector2i(4, 60), Vector2(400, 400))
	tall.zoom_at(1.44, Vector2(200, 200))
	var wide_axis_center := tall.center_cells.x
	tall.pan_pixels(Vector2(300, 300))
	check(_near(wide_axis_center, 2.0) and _near(tall.center_cells.x, 2.0),
		"an axis whose board fits the view stays centered while the other axis pans")
	check(tall.center_cells.y < 30.0, "the long axis still pans")

func _test_pan_pixels_sign() -> void:
	var transform := _make(Vector2i(40, 30), Vector2(1000, 600))
	transform.zoom_at(4.0, Vector2(500, 300))
	var before := transform.center_cells
	transform.pan_pixels(Vector2(-40, 0))
	check(transform.center_cells.x > before.x, "dragging content left moves the camera center right")
	check(transform.pan_camera_pixels(Vector2(0, -30)), "camera movement reports an effective change")
	check(transform.center_cells.y < before.y, "camera movement up decreases the center y")

func _test_fit_resets() -> void:
	var transform := _make(Vector2i(40, 30), Vector2(1000, 600))
	var fit_scale := transform.cell_pixels
	transform.zoom_at(3.0, Vector2(100, 100))
	transform.pan_pixels(Vector2(30, 30))
	transform.fit_puzzle()
	check(transform.fit_mode, "fit returns to fit mode")
	check(_near(transform.cell_pixels, fit_scale), "fit restores the fit scale")
	check(_near_v(transform.center_cells, Vector2(20, 15)), "fit re-centers the original bounds")

func _test_resize_policy() -> void:
	var fit_view := _make(Vector2i(20, 20), Vector2(432, 432))
	check(_near(fit_view.cell_pixels, 20.0), "initial fit at 432 x 432")
	fit_view.resize_view(Vector2(832, 832))
	check(_near(fit_view.cell_pixels, 40.0) and fit_view.fit_mode, "a fit view refits when the area grows")

	var manual := _make(Vector2i(40, 30), Vector2(1000, 600))
	manual.zoom_at(4.0, Vector2(500, 300))
	manual.pan_pixels(Vector2(-200, -100))
	var scale_before := manual.cell_pixels
	var center_before := manual.center_cells
	manual.resize_view(Vector2(1200, 700))
	check(_near(manual.cell_pixels, scale_before, 0.001) and not manual.fit_mode,
		"a manual view keeps its absolute cell scale on resize and stays manual")
	check(manual.center_cells.distance_to(center_before) < 1.5, "a manual view keeps roughly the same logical center on resize")

	var shrink := _make(Vector2i(40, 30), Vector2(1000, 600))
	shrink.zoom_at(1.2, Vector2(500, 300))
	shrink.resize_view(Vector2(300, 200))
	check(shrink.cell_pixels >= shrink.fit_cell_pixels() - 0.001, "a manual scale never falls below the new fit scale")

func _test_invalid_size() -> void:
	var transform := _make(Vector2i(10, 10), Vector2(532, 532))
	var scale_before := transform.cell_pixels
	transform.resize_view(Vector2(0, 0))
	check(not transform.layout_valid, "a zero-area viewport is invalid")
	check(transform.cell_at(Vector2(100, 100)) == Vector2i(-1, -1), "hit testing is suspended while invalid")
	check(is_nan(transform.local_to_logical(Vector2(10, 10)).x), "an invalid layout yields no usable logical coordinate")
	check(is_nan(transform.logical_to_local(Vector2(1, 1)).x), "an invalid layout yields no usable local coordinate")
	check(not transform.zoom_at(2.0, Vector2(10, 10)) and not transform.pan_pixels(Vector2(5, 5)),
		"navigation is refused while invalid")
	check(_near(transform.cell_pixels, scale_before), "the last valid scale is retained")
	for bad in [Vector2(32, 400), Vector2(400, 32), Vector2(-5, 400), Vector2(NAN, 400), Vector2(INF, 400)]:
		transform.resize_view(bad)
		check(not transform.layout_valid, "area %s is not a usable layout" % [bad])
	transform.resize_view(Vector2(832, 832))
	check(transform.layout_valid and _near(transform.cell_pixels, 80.0), "recovery re-applies the fit policy")

	var manual := _make(Vector2i(40, 30), Vector2(1000, 600))
	manual.zoom_at(4.0, Vector2(500, 300))
	var kept_scale := manual.cell_pixels
	manual.resize_view(Vector2(10, 10))
	manual.resize_view(Vector2(1000, 600))
	check(_near(manual.cell_pixels, kept_scale) and not manual.fit_mode, "manual state survives an invalid interval")

	var never_valid := PuzzleViewportTransform.new()
	never_valid.configure(Vector2i(0, 5))
	never_valid.resize_view(Vector2(800, 600))
	check(not never_valid.layout_valid, "a nonpositive board size is invalid")

func _test_reveal_cell() -> void:
	var transform := _make(Vector2i(40, 30), Vector2(1000, 600))
	check(transform.cell_pixels < 48.0, "the overview is below the comfortable selection scale")
	check(transform.reveal_cell(Vector2i(2, 3)), "revealing from the overview changes the view")
	check(transform.cell_pixels >= 48.0 - 0.001, "reveal raises the scale to at least 48 pixels per cell")
	var top_left := transform.logical_to_local(Vector2(2, 3))
	var bottom_right := transform.logical_to_local(Vector2(3, 4))
	check(top_left.x >= 8.0 - 0.01 and top_left.y >= 8.0 - 0.01 and bottom_right.x <= 992.0 + 0.01 \
		and bottom_right.y <= 592.0 + 0.01, "the padded head rectangle is inside the viewport")

	var visible := _make(Vector2i(40, 30), Vector2(1000, 600))
	visible.zoom_at(4.0, Vector2(500, 300))
	var center_of_view := visible.local_to_logical(Vector2(500, 300))
	var target := Vector2i(int(floor(center_of_view.x)), int(floor(center_of_view.y)))
	var scale_before := visible.cell_pixels
	var center_before := visible.center_cells
	check(not visible.reveal_cell(target), "an already readable, visible head does not move the view")
	check(_near(visible.cell_pixels, scale_before) and _near_v(visible.center_cells, center_before),
		"a satisfied reveal leaves scale and center untouched")

	var far := _make(Vector2i(40, 30), Vector2(1000, 600))
	far.zoom_at(4.0, Vector2(500, 300))
	far.pan_pixels(Vector2(1.0e6, 1.0e6))
	far.reveal_cell(Vector2i(39, 29))
	var far_corner := far.logical_to_local(Vector2(40, 30))
	check(far_corner.x <= 1000 - 8 + 0.01 and far_corner.y <= 600 - 8 + 0.01,
		"a corner head is revealed with padding at the board edge")
	var head_rect_min := far.logical_to_local(Vector2(39, 29))
	check(head_rect_min.x >= 8.0 - 0.01 and head_rect_min.y >= 8.0 - 0.01, "the corner head stays inside the padded viewport")

	var invalid := _make(Vector2i(40, 30), Vector2(1000, 600))
	invalid.resize_view(Vector2(0, 0))
	check(not invalid.reveal_cell(Vector2i(2, 2)), "reveal is refused while the layout is invalid")

func _test_world_projection() -> void:
	var transform := _make(Vector2i(10, 10), Vector2(532, 532))
	check(_near_v(transform.world_scale(), Vector2.ONE * 50.0 / 64.0), "world scale is cell pixels over the canonical extent")
	check(_near_v(transform.world_position(), Vector2(16, 16)), "world position places the board origin at the margin")
	var logical := Vector2(3.5, 4.5)
	var projected := transform.world_position() + logical * PuzzleViewportTransform.CANONICAL_CELL_PIXELS * transform.world_scale()
	check(_near_v(projected, transform.logical_to_local(logical)), "world projection agrees with the logical conversion")

func _initialize() -> void:
	_test_fit_margin_and_containment()
	_test_inverse_round_trips()
	_test_cell_at()
	_test_zoom_anchor_and_limits()
	_test_noop_bound_keeps_fit_mode()
	_test_pan_clamping()
	_test_pan_pixels_sign()
	_test_fit_resets()
	_test_resize_policy()
	_test_invalid_size()
	_test_reveal_cell()
	_test_world_projection()
	print("PUZZLE_VIEWPORT_FAILURES=", failures)
	quit(failures)
