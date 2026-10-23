extends SceneTree
## Headless isolated-project check for PuzzleGenerator: deterministic for a
## profile and seed, solvable and in range when it reports success, the
## initial-playable cap enforced on the result, bounded work, and profiles
## with detectable contradictions rejected before any search. Profiles stay
## small so the gate stays fast. Run via tests/run_puzzle_regressions.py.

var failures: int = 0

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

const SMALL := {
	"width": 7, "height": 6,
	"arrows": [5, 7],
	"density": [0.2, 0.9],
	"placement": {"layering": "center_out", "arrow_length": [2, 5]},
	"attempts": 40,
}

func _version(result: Dictionary) -> String:
	return "" if result["definition"] == null else PuzzleContentVersion.of(result["definition"])

func _check_determinism() -> void:
	var versions: Array[String] = []
	for i in range(3):
		versions.append(_version(PuzzleGenerator.generate(SMALL, 11)))
	check(not versions[0].is_empty() and versions[0] == versions[1] and versions[1] == versions[2],
		"the same profile and seed give the same board three times (%s)" % versions[0])
	check(_version(PuzzleGenerator.generate(SMALL, 12)) != versions[0], "a different seed gives a different board")
	var uniform := SMALL.duplicate(true)
	uniform["placement"]["layering"] = "uniform"
	check(_version(PuzzleGenerator.generate(uniform, 11)) == _version(PuzzleGenerator.generate(uniform, 11)),
		"uniform layering is deterministic too")

func _check_reachable_profile() -> void:
	var result := PuzzleGenerator.generate(SMALL, 11)
	var definition: PuzzleDefinition = result["definition"]
	check(result["ok"] and result["misses"].is_empty(), "a reachable profile reports success")
	check(definition != null and definition.is_valid(), "the generated board is valid")
	check(definition != null and PuzzleSolver.analyze(definition)["solvable"], "the generated board is solvable")
	var analysis := PuzzleAnalyzer.analyze(definition)
	var arrows: int = analysis["board"]["arrow_count"]
	var density: float = analysis["board"]["density"]
	check(arrows >= 5 and arrows <= 7 and density >= 0.2 and density <= 0.9,
		"the generated board is within its profiled ranges (%d arrows, density %.2f)" % [arrows, density])
	check(result["metrics"]["arrows"] == arrows, "reported metrics come from the analyzer")
	check(result["attempts_used"] >= 1 and result["attempts_used"] <= 40, "attempts stay within the budget")

## The cap is an acceptance rule, not a preference: across several seeds no
## result is reported ok with more playable arrows than the cap, and a result
## that exceeds it carries an initial_playable_cap miss.
func _check_playable_cap() -> void:
	var capped := {
		"width": 6, "height": 6,
		"arrows": [8, 10],
		"placement": {"initial_playable_cap": 2, "arrow_length": [2, 6]},
		"attempts": 30,
	}
	var ok_seen := false
	for level_seed in [1, 2, 3, 4, 5]:
		var result := PuzzleGenerator.generate(capped, level_seed)
		if result["definition"] == null:
			check(false, "seed %d: the capped profile builds a board" % level_seed)
			continue
		var playable: int = PuzzleAnalyzer.analyze(result["definition"])["legal_move_structure"]["initial_legal_count"]
		var cap_missed: bool = result["misses"].any(func(m): return m["metric"] == "initial_playable_cap")
		check(not (result["ok"] and playable > 2), "seed %d: never ok with %d playable arrows over a cap of 2" % [level_seed, playable])
		check(playable <= 2 or (not result["ok"] and cap_missed), "seed %d: exceeding the cap is reported as a miss" % level_seed)
		ok_seen = ok_seen or result["ok"]
	check(ok_seen, "the capped profile is reachable for at least one seed")

	var impossible := {
		"width": 4, "height": 4,
		"arrows": [12, 12],
		"placement": {"initial_playable_cap": 1, "arrow_length": [1, 1]},
		"attempts": 10,
	}
	var result := PuzzleGenerator.generate(impossible, 7)
	var cap_missed: bool = result["misses"].any(func(m): return m["metric"] == "initial_playable_cap")
	check(not result["ok"] and cap_missed, "an unreachable cap ends as a reported miss, even with no initial_playable range")

func _check_unreachable_profile() -> void:
	var result := PuzzleGenerator.generate({"width": 5, "height": 5, "arrows": [4, 6], "depth": [40, 50], "attempts": 10}, 3)
	check(not result["ok"], "an unreachable structural profile is not reported ok")
	check(result["profile_errors"].is_empty(), "an unreachable profile is not rejected up front")
	check(result["misses"].any(func(m): return m["metric"] == "depth" and m["min"] == 40 and m["max"] == 50),
		"the miss names the metric, its value and its range")

func _check_bounded_work() -> void:
	var started := Time.get_ticks_msec()
	var result := PuzzleGenerator.generate({"width": 6, "height": 6, "arrows": [9, 9], "placement": {"arrow_length": [4, 4]}, "attempts": 20}, 5)
	check(result["attempts_used"] <= 20, "a profile whose arrows rarely fit still stops within its budget")
	check(Time.get_ticks_msec() - started < 20000, "and returns promptly")

func _expect_rejected(profile: Dictionary, needle: String, description: String) -> void:
	var result := PuzzleGenerator.generate(profile, 1)
	var errors: Array = result["profile_errors"]
	check(not result["ok"] and result["attempts_used"] == 0 and result["definition"] == null, "%s: rejected before any search" % description)
	check(errors.any(func(e): return e.contains(needle)), "%s: the message names the problem (%s)" % [description, "; ".join(errors)])

func _check_rejections() -> void:
	_expect_rejected({"width": 6, "height": 6, "arrows": [5, 2]}, "arrows", "a minimum above its maximum")
	_expect_rejected({"width": 1, "height": 6}, "width", "a board dimension under 2")
	_expect_rejected({"width": 6, "height": 6, "density": [0.0, 0.5]}, "density", "a density outside (0, 1]")
	_expect_rejected({"width": 6, "height": 6, "placement": {"arrow_length": [0, 3]}}, "arrow_length", "an arrow length under 1")
	_expect_rejected({"width": 6, "height": 6, "placement": {"initial_playable_cap": 0}}, "initial_playable_cap", "a cap under 1")
	_expect_rejected({"width": 6, "height": 6, "attempts": 0}, "attempts", "an attempt budget of 0")
	_expect_rejected({"width": 6, "height": 6, "placement": {"layering": "spiral"}}, "layering", "an unknown layering")
	_expect_rejected({"width": 6, "height": 6, "depht": [1, 2]}, "depht", "an unknown profile key")
	_expect_rejected({"width": 3, "height": 3, "arrows": [10, 10], "placement": {"arrow_length": [1, 1]}}, "no board size",
		"no permitted board size can hold the minimum arrows")

func _check_feasible_sizes() -> void:
	var ranged := {"width": [2, 6], "height": [2, 6], "arrows": [10, 10], "placement": {"arrow_length": [2, 2]}, "attempts": 3}
	var all_feasible := true
	for level_seed in [1, 2, 3, 4, 5, 6]:
		var definition: PuzzleDefinition = PuzzleGenerator.generate(ranged, level_seed)["definition"]
		if definition == null or definition.width * definition.height < 20:
			all_feasible = false
	check(all_feasible, "a ranged board size only draws sizes able to hold 10 arrows of length 2")

func _initialize() -> void:
	_check_determinism()
	_check_reachable_profile()
	_check_playable_cap()
	_check_unreachable_profile()
	_check_bounded_work()
	_check_rejections()
	_check_feasible_sizes()
	print("PUZZLE_GENERATOR_FAILURES=", failures)
	quit(1 if failures else 0)
