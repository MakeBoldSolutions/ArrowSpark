class_name PuzzleGenerator
extends RefCounted
## Seeded, deterministic level generator for developer tooling (the pack-build
## tool); the shipped game never generates levels. It only proposes boards:
## validity, solvability and every measured metric come from
## PuzzleDefinition, PuzzleSolver and PuzzleAnalyzer, never from rules of its
## own.
##
## Arrows are placed in reverse solve order. A new arrow is accepted only if
## its forward ray is clear of every cell already placed, so the last arrow
## placed can always leave first and the board is solvable by construction.
## Its tail may cross earlier arrows' rays; that is what creates dependencies.
##
## A profile (see generate()) sets board size, target ranges over analyzer
## metrics and placement options. Candidates are scored by how far their
## metrics fall outside the ranges; the first perfect candidate, or the best
## within the attempt budget, is returned.

## Names the generation algorithm. Recorded in generated provenance, so a
## change to how boards are proposed is visible next to each pinned content
## version. Bump it whenever the same profile and seed would give a
## different board.
const GENERATOR_SCHEME := "gen1"
const MAX_HEAD_TRIES := 64
const MAX_ATTEMPTS := 5000
const DEFAULT_ATTEMPTS := 200
const DEFAULT_ARROW_LENGTH := Vector2i(1, 8)
const CENTER_JITTER := 1.5
const LAYERINGS := ["center_out", "uniform"]

## Profile metric key -> [analyzer section, analyzer key, whole numbers only].
const METRICS := {
	"arrows": ["board", "arrow_count", true],
	"density": ["board", "density", false],
	"initial_playable": ["legal_move_structure", "initial_legal_count", true],
	"depth": ["dependency_graph", "depth", true],
	"components": ["dependency_graph", "component_count", true],
	"bends": ["geometry", "total_bends", true],
	"max_length": ["geometry", "max_length", true],
	"average_length": ["geometry", "average_length", false],
}
const PROFILE_KEYS := ["width", "height", "placement", "attempts"]
const PLACEMENT_KEYS := ["layering", "initial_playable_cap", "arrow_length"]

## Generates one board for a profile and seed. Returns:
## ok (bool), profile_errors (Array[String]; non-empty means the profile was
## rejected and nothing was searched), definition (best PuzzleDefinition or
## null), metrics (profiled metric -> measured value), misses (Array of
## {metric, value, min, max}), score (0.0 when ok), attempts_used (int).
static func generate(profile: Dictionary, level_seed: int) -> Dictionary:
	var spec := _resolve_profile(profile)
	if not spec["errors"].is_empty():
		return _result(false, spec["errors"], null, {}, [], INF, 0)

	var rng := RandomNumberGenerator.new()
	rng.seed = level_seed
	var sizes: Array = spec["sizes"]
	var arrows_range: Vector2i = spec["arrows"]
	var best: Dictionary = {}
	var attempts_used := 0
	for attempt in range(spec["attempts"]):
		attempts_used = attempt + 1
		var size: Vector2i = sizes[rng.randi_range(0, sizes.size() - 1)]
		var target := mini(rng.randi_range(arrows_range.x, arrows_range.y), size.x * size.y)
		var definition := _build_candidate(size, target, spec, rng)
		if definition == null:
			continue
		var scored := _score(definition, spec)
		if scored.is_empty():
			continue
		if best.is_empty() or scored["score"] < best["score"]:
			best = scored
			best["definition"] = definition
		if best["misses"].is_empty():
			break
	if best.is_empty():
		return _result(false, [] as Array[String], null, {}, [], INF, attempts_used)
	return _result(best["misses"].is_empty(), [] as Array[String], best["definition"], best["metrics"],
		best["misses"], best["score"], attempts_used)

static func _result(ok: bool, errors: Array[String], definition, metrics: Dictionary, misses: Array,
		score: float, attempts_used: int) -> Dictionary:
	return {
		"ok": ok,
		"profile_errors": errors,
		"definition": definition,
		"metrics": metrics,
		"misses": misses,
		"score": score,
		"attempts_used": attempts_used,
	}

## Validates a profile and resolves it into what the search needs. Rejects
## only detectable contradictions: an inverted range, a value outside its
## allowed range, an unknown key, or no permitted board size large enough for
## the minimum arrow count at the minimum arrow length.
static func _resolve_profile(profile: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	for key in profile.keys():
		if not PROFILE_KEYS.has(key) and not METRICS.has(key):
			errors.append("unknown profile key '%s'" % key)
	var width := _int_range(profile.get("width"), "width", 2, errors, true)
	var height := _int_range(profile.get("height"), "height", 2, errors, true)

	var ranges := {}
	for key in METRICS.keys():
		if not profile.has(key):
			continue
		var whole: bool = METRICS[key][2]
		var bounds := _number_range(profile[key], key, whole, errors)
		if bounds.is_empty():
			continue
		if key == "density" and (bounds[0] <= 0.0 or bounds[1] > 1.0):
			errors.append("'density' must lie within (0, 1]")
		elif bounds[0] < 0:
			errors.append("'%s' cannot be negative" % key)
		ranges[key] = bounds

	var placement = profile.get("placement", {})
	if not (placement is Dictionary):
		errors.append("'placement' must be an object")
		placement = {}
	for key in placement.keys():
		if not PLACEMENT_KEYS.has(key):
			errors.append("unknown placement key '%s'" % key)
	var layering = placement.get("layering", "center_out")
	if not LAYERINGS.has(layering):
		errors.append("'placement.layering' must be one of %s" % [LAYERINGS])
	var arrow_length := DEFAULT_ARROW_LENGTH
	if placement.has("arrow_length"):
		arrow_length = _int_range(placement["arrow_length"], "placement.arrow_length", 1, errors, false)
	var cap := -1
	if placement.has("initial_playable_cap"):
		var value = _whole(placement["initial_playable_cap"])
		if value == null or value < 1:
			errors.append("'placement.initial_playable_cap' must be a whole number of at least 1")
		else:
			cap = value
	var attempts := DEFAULT_ATTEMPTS
	if profile.has("attempts"):
		var value = _whole(profile["attempts"])
		if value == null or value < 1 or value > MAX_ATTEMPTS:
			errors.append("'attempts' must be a whole number from 1 to %d" % MAX_ATTEMPTS)
		else:
			attempts = value

	var arrows_range := Vector2i(1, 1 << 30)
	if ranges.has("arrows"):
		arrows_range = Vector2i(int(ranges["arrows"][0]), int(ranges["arrows"][1]))
		if arrows_range.x < 1:
			errors.append("'arrows' minimum must be at least 1")

	var sizes: Array[Vector2i] = []
	if errors.is_empty():
		var needed := arrows_range.x * arrow_length.x
		for h in range(height.x, height.y + 1):
			for w in range(width.x, width.y + 1):
				if w * h >= needed:
					sizes.append(Vector2i(w, h))
		if sizes.is_empty():
			errors.append("no board size allowed by 'width' and 'height' can hold %d arrows of at least %d cells" % [arrows_range.x, arrow_length.x])

	return {
		"errors": errors,
		"sizes": sizes,
		"ranges": ranges,
		"arrows": arrows_range,
		"layering": layering,
		"arrow_length": arrow_length,
		"cap": cap,
		"attempts": attempts,
	}

## A whole number, or an inclusive [min, max] range of them when `allow_single`.
static func _int_range(value, name: String, minimum: int, errors: Array[String], allow_single: bool) -> Vector2i:
	if value == null:
		errors.append("'%s' is required" % name)
		return Vector2i(minimum, minimum)
	var single = _whole(value) if allow_single else null
	if single != null:
		value = [single, single]
	if not (value is Array) or value.size() != 2 or _whole(value[0]) == null or _whole(value[1]) == null:
		errors.append("'%s' must be %s" % [name, "a whole number or [min, max]" if allow_single else "[min, max] whole numbers"])
		return Vector2i(minimum, minimum)
	var bounds := Vector2i(_whole(value[0]), _whole(value[1]))
	if bounds.x > bounds.y:
		errors.append("'%s' minimum %d is above its maximum %d" % [name, bounds.x, bounds.y])
	elif bounds.x < minimum:
		errors.append("'%s' must be at least %d" % [name, minimum])
	return bounds

static func _number_range(value, name: String, whole: bool, errors: Array[String]) -> Array:
	if not (value is Array) or value.size() != 2 or not _is_number(value[0]) or not _is_number(value[1]):
		errors.append("'%s' must be [min, max]" % name)
		return []
	if whole and (_whole(value[0]) == null or _whole(value[1]) == null):
		errors.append("'%s' must be whole numbers" % name)
		return []
	if value[0] > value[1]:
		errors.append("'%s' minimum %s is above its maximum %s" % [name, value[0], value[1]])
		return []
	return [value[0], value[1]]

static func _is_number(value) -> bool:
	return (value is int or value is float) and is_finite(float(value))

static func _whole(value) -> Variant:
	if value is int:
		return value
	if value is float and is_finite(value) and value == floorf(value):
		return int(value)
	return null

## One candidate board, or null if no arrow could be placed. Construction is
## bounded: candidate head cells are visited in one fixed order, a cell that
## fails is never retried (occupancy only grows, so it cannot start to fit),
## and each arrow gets at most MAX_HEAD_TRIES head cells.
static func _build_candidate(size: Vector2i, target: int, spec: Dictionary, rng: RandomNumberGenerator) -> PuzzleDefinition:
	var order := _head_order(size, spec["layering"], rng)
	var occupied := {}
	var arrows := {}
	var tails := {}
	var cursor := 0
	while arrows.size() < target:
		var placed := false
		var tries := 0
		while not placed and tries < MAX_HEAD_TRIES and cursor < order.size():
			var head: Vector2i = order[cursor]
			cursor += 1
			if occupied.has(head):
				continue
			tries += 1
			placed = _try_place(head, size, occupied, arrows, tails, spec, rng)
		if not placed:
			break
	if arrows.is_empty():
		return null
	return PuzzleDefinition.new(size.x, size.y, arrows, tails)

## Every cell once: nearest the centre first (with seeded jitter) for
## center_out, or a seeded shuffle for uniform.
static func _head_order(size: Vector2i, layering: String, rng: RandomNumberGenerator) -> Array:
	var cells: Array = []
	for y in range(size.y):
		for x in range(size.x):
			cells.append(Vector2i(x, y))
	if layering == "uniform":
		for i in range(cells.size() - 1, 0, -1):
			var j := rng.randi_range(0, i)
			var swap = cells[i]
			cells[i] = cells[j]
			cells[j] = swap
		return cells
	var center := Vector2((size.x - 1) / 2.0, (size.y - 1) / 2.0)
	var keyed: Array = []
	for cell in cells:
		keyed.append([Vector2(cell).distance_to(center) + rng.randf() * CENTER_JITTER, cell])
	keyed.sort_custom(func(a, b): return a[0] < b[0] or (a[0] == b[0] and PuzzleDefinition.head_less_than(a[1], b[1])))
	return keyed.map(func(item): return item[1])

## Tries every direction (in a seeded order) for one head cell: the forward
## ray must be clear of all placed cells, then a tail is walked behind the
## head. Places the arrow and returns true on the first that works.
static func _try_place(head: Vector2i, size: Vector2i, occupied: Dictionary, arrows: Dictionary,
		tails: Dictionary, spec: Dictionary, rng: RandomNumberGenerator) -> bool:
	var directions := [PuzzleDefinition.Direction.UP, PuzzleDefinition.Direction.DOWN,
		PuzzleDefinition.Direction.LEFT, PuzzleDefinition.Direction.RIGHT]
	for i in range(directions.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap = directions[i]
		directions[i] = directions[j]
		directions[j] = swap
	var arrow_length: Vector2i = spec["arrow_length"]
	for direction in directions:
		var ray := _ray(head, direction, size)
		if ray.any(func(cell): return occupied.has(cell)):
			continue
		var length := rng.randi_range(arrow_length.x, arrow_length.y)
		var tail := _walk_tail(head, direction, length, size, occupied, ray, arrows, spec, rng)
		if tail.size() + 1 < arrow_length.x:
			continue
		arrows[head] = direction
		tails[head] = tail
		occupied[head] = true
		for cell in tail:
			occupied[cell] = true
		return true
	return false

## A random walk behind the head through empty cells, never onto the arrow's
## own forward ray or back onto itself, stopping at `length` cells (head
## included) or a dead end. While more arrows are playable than the cap
## allows, steps that land on a currently playable arrow's ray are preferred,
## which blocks it; the cap itself is enforced on the measured result.
static func _walk_tail(head: Vector2i, direction: int, length: int, size: Vector2i, occupied: Dictionary,
		own_ray: Array[Vector2i], arrows: Dictionary, spec: Dictionary, rng: RandomNumberGenerator) -> Array[Vector2i]:
	var tail: Array[Vector2i] = []
	var first := head - PuzzleDefinition.direction_vector(direction)
	if length < 2 or not _free(first, size, occupied) :
		return tail
	var blocked_rays := {}
	for cell in own_ray:
		blocked_rays[cell] = true
	var steer := _playable_rays(arrows, occupied, size, spec["cap"])
	var shape := {head: true}
	var current := first
	tail.append(current)
	shape[current] = true
	while tail.size() + 1 < length:
		var options: Array[Vector2i] = []
		for step in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
			var next: Vector2i = current + step
			if _free(next, size, occupied) and not shape.has(next) and not blocked_rays.has(next):
				options.append(next)
		if options.is_empty():
			break
		var preferred := options.filter(func(cell): return steer.has(cell))
		var pool: Array = preferred if not preferred.is_empty() else options
		current = pool[rng.randi_range(0, pool.size() - 1)]
		tail.append(current)
		shape[current] = true
	return tail

## Cells on the rays of arrows that are currently playable, when more of them
## are playable than the cap allows; empty otherwise (no steering needed).
static func _playable_rays(arrows: Dictionary, occupied: Dictionary, size: Vector2i, cap: int) -> Dictionary:
	if cap < 0:
		return {}
	var rays := {}
	var playable := 0
	for head in arrows.keys():
		var ray := _ray(head, arrows[head], size)
		if ray.any(func(cell): return occupied.has(cell)):
			continue
		playable += 1
		for cell in ray:
			rays[cell] = true
	return rays if playable > cap else {}

static func _ray(head: Vector2i, direction: int, size: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var step := PuzzleDefinition.direction_vector(direction)
	var cell := head + step
	while cell.x >= 0 and cell.x < size.x and cell.y >= 0 and cell.y < size.y:
		cells.append(cell)
		cell += step
	return cells

static func _free(cell: Vector2i, size: Vector2i, occupied: Dictionary) -> bool:
	return cell.x >= 0 and cell.x < size.x and cell.y >= 0 and cell.y < size.y and not occupied.has(cell)

## Measures a candidate with the analyzer. Empty when the board is invalid or
## unsolvable (never expected, since construction guarantees both). Each
## profiled metric outside its range adds its distance, relative to the
## bound, to the score; exceeding the playable cap is scored the same way.
static func _score(definition: PuzzleDefinition, spec: Dictionary) -> Dictionary:
	var analysis := PuzzleAnalyzer.analyze(definition)
	if not analysis["valid"] or not analysis["solvable"]:
		return {}
	var metrics := {}
	var misses: Array = []
	var score := 0.0
	var ranges: Dictionary = spec["ranges"]
	for key in METRICS.keys():
		if not ranges.has(key) and not (key == "initial_playable" and spec["cap"] >= 0):
			continue
		var value = analysis[METRICS[key][0]][METRICS[key][1]]
		metrics[key] = value
		if ranges.has(key):
			var low = ranges[key][0]
			var high = ranges[key][1]
			if value < low or value > high:
				var bound = low if value < low else high
				score += absf(float(value) - float(bound)) / maxf(1.0, absf(float(bound)))
				misses.append({"metric": key, "value": value, "min": low, "max": high})
	var cap: int = spec["cap"]
	if cap >= 0 and metrics["initial_playable"] > cap:
		score += float(metrics["initial_playable"] - cap) / float(cap)
		misses.append({"metric": "initial_playable_cap", "value": metrics["initial_playable"], "min": 1, "max": cap})
	return {"metrics": metrics, "misses": misses, "score": score}
