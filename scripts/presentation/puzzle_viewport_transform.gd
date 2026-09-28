class_name PuzzleViewportTransform
extends RefCounted
## Pure presentation math for the puzzle canvas: fit, bounded zoom/pan and the
## board-local <-> logical (cell-unit) mapping. It knows only the board
## dimensions and the visible area, never puzzle rules, and holds no persisted
## state -- the camera is transient and resets with every attempt.
##
## Mapping: a logical point q (cells) appears at board-local pixel
## p = viewport / 2 + (q - center_cells) * cell_pixels.

const CANONICAL_CELL_PIXELS := 64.0
const FIT_MARGIN_PIXELS := 16.0
const MIN_AXIS_PIXELS := 2.0 * FIT_MARGIN_PIXELS
const ZOOM_STEP := 1.2
const MAX_CELL_PIXELS := 192.0
const COMFORTABLE_CELL_PIXELS := 48.0
const REVEAL_PADDING_PIXELS := 8.0
const _EPSILON := 0.0001

var board_size: Vector2i = Vector2i.ZERO
var viewport_size: Vector2 = Vector2.ZERO # last valid area
var cell_pixels: float = 0.0
var center_cells: Vector2 = Vector2.ZERO
var fit_mode: bool = true
var layout_valid: bool = false

var _area_valid: bool = false

## Resets the definition dimensions and the fit/manual state. The last known
## viewport area is kept because it describes the screen, not the puzzle.
func configure(grid_size: Vector2i) -> void:
	board_size = grid_size if grid_size.x > 0 and grid_size.y > 0 else Vector2i.ZERO
	fit_mode = true
	cell_pixels = 0.0
	center_cells = Vector2(board_size) / 2.0
	_refresh_validity()
	if layout_valid:
		fit_puzzle()

## Applies the fit/manual resize policy for a newly measured area. An invalid
## area suspends the layout but retains the last valid projection values.
func resize_view(area: Vector2) -> void:
	_area_valid = _is_usable_area(area)
	if not _area_valid:
		_refresh_validity()
		return
	viewport_size = area
	_refresh_validity()
	if not layout_valid:
		return
	if fit_mode or cell_pixels <= 0.0:
		fit_puzzle()
	else:
		cell_pixels = clampf(cell_pixels, fit_cell_pixels(), max_cell_pixels())
		center_cells = _clamped_center(center_cells, cell_pixels)

func fit_puzzle() -> void:
	if not layout_valid:
		return
	fit_mode = true
	cell_pixels = fit_cell_pixels()
	center_cells = Vector2(board_size) / 2.0

func fit_cell_pixels() -> float:
	if board_size.x <= 0 or board_size.y <= 0 or viewport_size.x <= MIN_AXIS_PIXELS \
			or viewport_size.y <= MIN_AXIS_PIXELS:
		return 0.0
	return minf((viewport_size.x - MIN_AXIS_PIXELS) / float(board_size.x),
		(viewport_size.y - MIN_AXIS_PIXELS) / float(board_size.y))

func max_cell_pixels() -> float:
	return maxf(MAX_CELL_PIXELS, fit_cell_pixels())

func can_zoom_in() -> bool:
	return layout_valid and cell_pixels < max_cell_pixels() - _EPSILON

func can_zoom_out() -> bool:
	return layout_valid and cell_pixels > fit_cell_pixels() + _EPSILON

## Zooms by factor keeping the logical point under anchor_local fixed, except
## for the bounds clamp. Returns true only when the view effectively changed.
func zoom_at(factor: float, anchor_local: Vector2) -> bool:
	if not layout_valid or not is_finite(factor) or factor <= 0.0 \
			or not is_finite(anchor_local.x) or not is_finite(anchor_local.y):
		return false
	var new_scale := clampf(cell_pixels * factor, fit_cell_pixels(), max_cell_pixels())
	var anchored_point := local_to_logical(anchor_local)
	var new_center := _clamped_center(
		anchored_point - (anchor_local - viewport_size / 2.0) / new_scale, new_scale)
	return _commit(new_scale, new_center)

## Moves the content by content_delta screen pixels (a drag), i.e. the camera
## center moves the opposite way.
func pan_pixels(content_delta: Vector2) -> bool:
	if not layout_valid or not is_finite(content_delta.x) or not is_finite(content_delta.y):
		return false
	return _commit(cell_pixels, _clamped_center(center_cells - content_delta / cell_pixels, cell_pixels))

## Moves the camera center by camera_delta screen pixels in the named direction.
func pan_camera_pixels(camera_delta: Vector2) -> bool:
	return pan_pixels(-camera_delta)

func logical_to_local(point: Vector2) -> Vector2:
	if not layout_valid:
		return Vector2(NAN, NAN)
	return viewport_size / 2.0 + (point - center_cells) * cell_pixels

func local_to_logical(point: Vector2) -> Vector2:
	if not layout_valid:
		return Vector2(NAN, NAN)
	return center_cells + (point - viewport_size / 2.0) / cell_pixels

## The cell under a board-local point, or (-1, -1) for an invalid layout, a
## point outside the viewport, or a point outside the board.
func cell_at(local_point: Vector2) -> Vector2i:
	var none := Vector2i(-1, -1)
	if not layout_valid or not is_finite(local_point.x) or not is_finite(local_point.y) \
			or not Rect2(Vector2.ZERO, viewport_size).has_point(local_point):
		return none
	var logical := local_to_logical(local_point)
	var cell := Vector2i(int(floor(logical.x)), int(floor(logical.y)))
	if cell.x < 0 or cell.y < 0 or cell.x >= board_size.x or cell.y >= board_size.y:
		return none
	return cell

## Zooms up to at least minimum_cell_pixels (bounded by the maximum) about the
## current center, then pans minimally so the padded full cell rectangle is
## inside the viewport. A head that is already readable and padded-visible
## leaves the view untouched. Returns true when the view changed.
func reveal_cell(cell: Vector2i, minimum_cell_pixels: float = COMFORTABLE_CELL_PIXELS,
		padding: float = REVEAL_PADDING_PIXELS) -> bool:
	if not layout_valid or cell.x < 0 or cell.y < 0 or cell.x >= board_size.x or cell.y >= board_size.y:
		return false
	var new_scale := cell_pixels
	if new_scale < minimum_cell_pixels:
		new_scale = minf(minimum_cell_pixels, max_cell_pixels())
	var new_center := center_cells
	var half_reach := viewport_size / 2.0 - Vector2(padding, padding)
	for axis in 2:
		var reach: float = half_reach[axis] / new_scale
		var cell_min: float = float(cell[axis])
		var low: float = cell_min + 1.0 - reach # smallest center keeping the far edge padded-visible
		var high: float = cell_min + reach # largest center keeping the near edge padded-visible
		if low > high:
			new_center[axis] = cell_min + 0.5
		else:
			new_center[axis] = clampf(new_center[axis], low, high)
	new_center = _clamped_center(new_center, new_scale)
	return _commit(new_scale, new_center)

## World node projection: position and scale that draw canonical 64-pixel
## geometry at the current view. Pure derivation; nothing is rebuilt.
func world_position() -> Vector2:
	return viewport_size / 2.0 - center_cells * cell_pixels

func world_scale() -> Vector2:
	return Vector2.ONE * (cell_pixels / CANONICAL_CELL_PIXELS)

func _commit(new_scale: float, new_center: Vector2) -> bool:
	if absf(new_scale - cell_pixels) <= _EPSILON and new_center.distance_to(center_cells) <= _EPSILON:
		return false
	cell_pixels = new_scale
	center_cells = new_center
	fit_mode = false
	return true

func _clamped_center(center: Vector2, scale: float) -> Vector2:
	var result := center
	for axis in 2:
		var extent: float = float(board_size[axis])
		var reach: float = (viewport_size[axis] - MIN_AXIS_PIXELS) / (2.0 * scale)
		if extent > 2.0 * reach + _EPSILON:
			result[axis] = clampf(center[axis], reach, extent - reach)
		else:
			result[axis] = extent / 2.0
	return result

func _refresh_validity() -> void:
	layout_valid = _area_valid and board_size.x > 0 and board_size.y > 0 \
		and fit_cell_pixels() > 0.0

static func _is_usable_area(area: Vector2) -> bool:
	return is_finite(area.x) and is_finite(area.y) \
		and area.x > MIN_AXIS_PIXELS and area.y > MIN_AXIS_PIXELS
