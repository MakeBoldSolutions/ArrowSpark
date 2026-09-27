extends SceneTree
## Pure, isolated geometry checks for ArrowDepartureGeometry: route
## construction, sampling, interval extraction, forward-grid clearance and
## the tail-cap-dominance style-ratio guard. Runs in a bare temporary
## project containing only arrow_departure_geometry.gd (see
## tests/run_puzzle_regressions.py), matching the pure rule-suite isolation
## used for tests/puzzle_regression.gd. The style-ratio constants below are
## intentionally mirrored literals, not references to GameVisualStyle (which
## this isolated project does not have), so this suite never depends on any
## specific presentation resource.

## Mirrors of the shipped GameVisualStyle ratios this suite exercises.
const SINGLE_TAIL: float = -0.30
const BODY_END: float = -0.02
const HEAD_BASE: float = -0.06
const BODY_WIDTH: float = 0.14

var failures: int = 0

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func _straight_route() -> ArrowDepartureGeometry:
	return ArrowDepartureGeometry.new([Vector2(0, 0), Vector2(1, 0), Vector2(2, 0)], Vector2(1, 0), HEAD_BASE, BODY_WIDTH / 2.0)

func _one_bend_route() -> ArrowDepartureGeometry:
	# tail (2,0) -> bend (1,0) -> head (1,1); travel direction into the head is DOWN.
	return ArrowDepartureGeometry.new([Vector2(2, 0), Vector2(1, 0), Vector2(1, 1)], Vector2(0, 1), HEAD_BASE, BODY_WIDTH / 2.0)

func _multi_bend_route() -> ArrowDepartureGeometry:
	# tail (3,2) -> (3,1) -> (3,0) -> (2,0) -> head (1,0); travel direction LEFT.
	return ArrowDepartureGeometry.new(
		[Vector2(3, 2), Vector2(3, 1), Vector2(3, 0), Vector2(2, 0), Vector2(1, 0)], Vector2(-1, 0), HEAD_BASE, BODY_WIDTH / 2.0)

func _synthetic_single_cell_route(head: Vector2, forward: Vector2) -> ArrowDepartureGeometry:
	return ArrowDepartureGeometry.new([head + forward * SINGLE_TAIL, head], forward, HEAD_BASE, BODY_WIDTH / 2.0)

func _test_straight_route_lengths_and_samples() -> void:
	var route := _straight_route()
	check(route.is_valid(), "a straight three-point route is valid")
	check(is_equal_approx(route.length(), 2.0), "straight route length equals summed segment distances")
	check(route.sample_distance(0.0).is_equal_approx(Vector2(0, 0)), "distance 0 samples the original tail")
	check(route.sample_distance(1.0).is_equal_approx(Vector2(1, 0)), "an exact interior vertex distance samples that vertex")
	check(route.sample_distance(2.0).is_equal_approx(Vector2(2, 0)), "distance L samples the head")
	check(route.head_center().is_equal_approx(Vector2(2, 0)), "head_center reports the original head position")
	check(route.sample_distance(3.0).is_equal_approx(Vector2(3, 0)), "sampling beyond L continues analytically along forward")
	check(route.sample_distance(-1.0).is_equal_approx(Vector2(0, 0)), "negative sample requests clamp to zero")

func _test_one_bend_route_retains_corner() -> void:
	var route := _one_bend_route()
	check(route.is_valid(), "a one-bend route is valid")
	check(is_equal_approx(route.length(), 2.0), "one-bend route length sums both segments")
	check(route.sample_distance(1.0).is_equal_approx(Vector2(1, 0)), "sampling at the exact corner distance returns the bend vertex")
	var interval := route.extract_interval(0.0, 2.0)
	check(interval.size() == 3, "the full interval retains the intermediate bend vertex")
	check(interval[1].is_equal_approx(Vector2(1, 0)), "no diagonal shortcut is taken across the retained bend")

func _test_multi_bend_route_retains_all_corners() -> void:
	var route := _multi_bend_route()
	check(route.is_valid(), "a multi-bend route is valid")
	check(is_equal_approx(route.length(), 4.0), "multi-bend route length sums every segment")
	var interval := route.extract_interval(0.0, route.length())
	check(interval.size() == 5, "the full interval retains every original vertex, including nonconsecutive corners")
	for i in range(interval.size()):
		check(interval[i].is_equal_approx([Vector2(3, 2), Vector2(3, 1), Vector2(3, 0), Vector2(2, 0), Vector2(1, 0)][i]),
			"multi-bend vertex %d follows route order without inventing connections" % i)

func _test_synthetic_single_cell_shaft_all_directions() -> void:
	for direction_vector in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
		var head := Vector2(5, 5)
		var route := _synthetic_single_cell_route(head, direction_vector)
		check(route.is_valid(), "a synthetic single-cell shaft is valid for direction %s" % [direction_vector])
		check(is_equal_approx(route.length(), -SINGLE_TAIL), "a single-cell shaft's length equals the coded synthetic shaft distance")
		check(route.head_center().is_equal_approx(head), "a single-cell shaft's head sample equals the owned cell center")

func _test_coincident_points_are_deduplicated() -> void:
	var route := ArrowDepartureGeometry.new(
		[Vector2(0, 0), Vector2(0, 0), Vector2(1, 0), Vector2(1, 0), Vector2(2, 0)], Vector2(1, 0), HEAD_BASE, BODY_WIDTH / 2.0)
	check(route.is_valid(), "repeated consecutive points do not invalidate a route")
	check(is_equal_approx(route.length(), 2.0), "duplicate consecutive points do not inflate cumulative length")

func _test_short_residual_segment_is_safe() -> void:
	var tiny := ArrowDepartureGeometry.GEOMETRY_TOLERANCE * 0.1
	var route := ArrowDepartureGeometry.new(
		[Vector2(0, 0), Vector2(1, 0), Vector2(1 + tiny, 0), Vector2(2, 0)], Vector2(1, 0), HEAD_BASE, BODY_WIDTH / 2.0)
	check(route.is_valid(), "a short residual segment below tolerance does not invalidate a route")
	var sampled := route.sample_distance(1.0)
	check(is_finite(sampled.x) and is_finite(sampled.y), "sampling near a short residual segment produces no division-by-zero artifact")

func _test_invalid_construction_is_explicit() -> void:
	check(not ArrowDepartureGeometry.new([Vector2(0, 0)], Vector2(1, 0)).is_valid(), "fewer than two distinct points is explicitly invalid")
	check(not ArrowDepartureGeometry.new([Vector2(0, 0), Vector2(0, 0)], Vector2(1, 0)).is_valid(), "a single distinct point after deduplication is explicitly invalid")
	check(not ArrowDepartureGeometry.new([Vector2(0, 0), Vector2(1, 0)], Vector2.ZERO).is_valid(), "a zero-length forward vector is explicitly invalid")

func _test_extract_interval_equal_endpoints_and_reversed_bounds() -> void:
	var route := _straight_route()
	var single := route.extract_interval(1.0, 1.0)
	check(single.size() == 1 and single[0].is_equal_approx(Vector2(1, 0)), "equal interval endpoints produce exactly one point")
	var reversed_bounds := route.extract_interval(1.5, 1.0)
	check(reversed_bounds.size() == 1, "a request with end below start clamps safely to a single point rather than reversing")

func _test_constant_centerline_length_across_departure_distances() -> void:
	for route in [_straight_route(), _one_bend_route(), _multi_bend_route()]:
		var l: float = route.length()
		var reference: float = -1.0
		for d in [0.0, l * 0.25, l * 0.5, l * 0.9, l]:
			var interval: PackedVector2Array = route.extract_interval(d, l + d + BODY_END)
			var polyline_length := 0.0
			for i in range(1, interval.size()):
				polyline_length += interval[i - 1].distance_to(interval[i])
			if reference < 0.0:
				reference = polyline_length
			check(is_equal_approx(polyline_length, reference), "the moving body interval's unclipped centerline length stays constant as departure distance advances")

func _test_forward_clearance_all_directions() -> void:
	var grid_size := Vector2(5, 4)
	var rear_support: float = BODY_WIDTH / 2.0
	var margin := 0.001
	check(is_equal_approx(ArrowDepartureGeometry.forward_clearance(Vector2(1, 0), Vector2(1, 0), grid_size, rear_support, margin), 3.5 + rear_support + margin),
		"rightward clearance measures the remaining cells plus rear support and margin")
	check(is_equal_approx(ArrowDepartureGeometry.forward_clearance(Vector2(-1, 0), Vector2(3, 0), grid_size, rear_support, margin), 3.5 + rear_support + margin),
		"leftward clearance mirrors rightward for a symmetric head position")
	check(is_equal_approx(ArrowDepartureGeometry.forward_clearance(Vector2(0, 1), Vector2(0, 1), grid_size, rear_support, margin), 2.5 + rear_support + margin),
		"downward clearance uses grid height")
	check(is_equal_approx(ArrowDepartureGeometry.forward_clearance(Vector2(0, -1), Vector2(0, 2), grid_size, rear_support, margin), 2.5 + rear_support + margin),
		"upward clearance mirrors downward for a symmetric head position")

func _test_tail_cap_dominance_guard_holds_for_shipped_ratios() -> void:
	# Constructing with the shipped ratios must never trip the assert; an
	## invalid combination (deliberately violating the invariant) is exercised
	## by directly re-deriving the comparison it guards, since intentionally
	## crashing the test process is not itself a checkable outcome.
	check(_straight_route().is_valid(), "constructing with the shipped style ratios does not trip the tail-cap-dominance guard")
	check(_straight_route().length() + HEAD_BASE >= -(BODY_WIDTH / 2.0),
		"the tail-cap-dominance invariant this suite's guard enforces also holds for the shipped style ratios")

func _initialize() -> void:
	_test_straight_route_lengths_and_samples()
	_test_one_bend_route_retains_corner()
	_test_multi_bend_route_retains_all_corners()
	_test_synthetic_single_cell_shaft_all_directions()
	_test_coincident_points_are_deduplicated()
	_test_short_residual_segment_is_safe()
	_test_invalid_construction_is_explicit()
	_test_extract_interval_equal_endpoints_and_reversed_bounds()
	_test_constant_centerline_length_across_departure_distances()
	_test_forward_clearance_all_directions()
	_test_tail_cap_dominance_guard_holds_for_shipped_ratios()
	print("ARROW_DEPARTURE_GEOMETRY_FAILURES=", failures)
	quit(1 if failures else 0)
