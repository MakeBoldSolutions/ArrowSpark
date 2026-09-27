class_name ArrowDepartureGeometry
extends RefCounted
## Pure cell-unit route math for a departing arrow: a stationary ordered
## tail-to-head polyline sampled by distance, plus its analytic forward-ray
## extension beyond the head. Holds no Node, PuzzleState, solver, input,
## score, or persistence reference; presentation views own rendering and
## lifecycle. Route points and lengths are copied once at construction and
## never mutated afterward.

const GEOMETRY_TOLERANCE := 0.00001

var _points: PackedVector2Array = PackedVector2Array()
var _prefix: PackedFloat64Array = PackedFloat64Array()
var _forward: Vector2 = Vector2.ZERO
var _length: float = 0.0
var _valid: bool = false

## route_points: tail-to-head cell-unit positions (already deduplicated by
## caller is not required; consecutive coincident points are removed here).
## forward: the cardinal unit direction of travel, continued analytically
## past the original head for any sample distance beyond the route length.
## head_base and tail_cap_radius are the caller's style-ratio offsets (head
## polygon base distance behind head-center, and half the body width); when
## both are finite, construction asserts the tail cap remains the rearmost
## support point (see forward_clearance) so a future style-ratio edit that
## breaks this assumption fails loudly instead of silently permitting early
## completion. Passed in rather than referenced directly so this helper
## carries no dependency on any specific presentation style resource.
func _init(route_points: Array, forward: Vector2, head_base: float = NAN, tail_cap_radius: float = NAN) -> void:
	_forward = forward
	var deduped: Array[Vector2] = []
	for point in route_points:
		var candidate: Vector2 = point
		if deduped.is_empty() or deduped[-1].distance_to(candidate) > GEOMETRY_TOLERANCE:
			deduped.append(candidate)
	if deduped.size() < 2 or _forward.length() <= GEOMETRY_TOLERANCE:
		return
	_points = PackedVector2Array(deduped)
	_prefix = PackedFloat64Array()
	_prefix.append(0.0)
	for i in range(1, _points.size()):
		_prefix.append(_prefix[i - 1] + _points[i - 1].distance_to(_points[i]))
	_length = _prefix[_prefix.size() - 1]
	_valid = _length > GEOMETRY_TOLERANCE
	if _valid and not is_nan(head_base) and not is_nan(tail_cap_radius):
		assert(_length + head_base >= -tail_cap_radius,
			"tail cap must remain the rearmost support point for the configured style ratios; " +
			"recompute clearance from actual body/head support bounds if this style ratio changes")

func is_valid() -> bool:
	return _valid

func length() -> float:
	return _length

func head_center() -> Vector2:
	return _points[_points.size() - 1] if _valid else Vector2.ZERO

func forward() -> Vector2:
	return _forward

## Distance is clamped to zero; beyond the route length, position continues
## analytically along forward from the head.
func sample_distance(s: float) -> Vector2:
	if not _valid:
		return Vector2.ZERO
	var clamped: float = maxf(s, 0.0)
	if clamped >= _length - GEOMETRY_TOLERANCE:
		return head_center() + _forward * (clamped - _length)
	for i in range(1, _prefix.size()):
		if clamped <= _prefix[i] + GEOMETRY_TOLERANCE:
			var segment_length: float = _prefix[i] - _prefix[i - 1]
			if segment_length <= GEOMETRY_TOLERANCE:
				return _points[i]
			var t: float = (clamped - _prefix[i - 1]) / segment_length
			return _points[i - 1].lerp(_points[i], t)
	return head_center()

## Returns the sampled start endpoint, every original vertex strictly inside
## (a, b), and the sampled end endpoint, with consecutive coincident output
## points removed. Requires a <= b after clamping; equal endpoints produce
## exactly one point.
func extract_interval(a: float, b: float) -> PackedVector2Array:
	if not _valid:
		return PackedVector2Array()
	var start: float = maxf(a, 0.0)
	var end: float = maxf(b, start)
	var raw: Array[Vector2] = [sample_distance(start)]
	for i in range(_prefix.size()):
		var d: float = _prefix[i]
		if d > start + GEOMETRY_TOLERANCE and d < end - GEOMETRY_TOLERANCE:
			raw.append(_points[i])
	raw.append(sample_distance(end))
	var out: Array[Vector2] = []
	for point in raw:
		if out.is_empty() or out[-1].distance_to(point) > GEOMETRY_TOLERANCE:
			out.append(point)
	return PackedVector2Array(out)

## Cell-unit distance beyond the route length (L) still needed for
## head_cell's whole visual footprint (body/head plus rear_support and
## margin) to clear the grid edge in the direction of travel. grid_size and
## head_cell are in cell units; head_cell is the arrow's original,
## grid-absolute head position. Pure function of direction/position/grid
## size only — independent of pixel extent, so resize never changes it.
static func forward_clearance(forward: Vector2, head_cell: Vector2, grid_size: Vector2, rear_support: float, margin: float) -> float:
	var edge: float
	if forward.x > 0.5:
		edge = grid_size.x - (head_cell.x + 0.5)
	elif forward.x < -0.5:
		edge = head_cell.x + 0.5
	elif forward.y > 0.5:
		edge = grid_size.y - (head_cell.y + 0.5)
	else:
		edge = head_cell.y + 0.5
	return edge + rear_support + margin
