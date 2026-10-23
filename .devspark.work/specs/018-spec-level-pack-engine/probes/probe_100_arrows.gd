extends SceneTree
## Throwaway probe: can PuzzleGenerator build a 100-arrow board, and at what
## size, density and cost?

const CASES := [
	{"name": "roomy 36x24, len 3-10", "profile": {"width": 36, "height": 24, "arrows": [100, 100], "placement": {"arrow_length": [3, 10]}, "attempts": 5}},
	{"name": "like almost_a_knot 36x24, len 3-12, cap 16", "profile": {"width": 36, "height": 24, "arrows": [100, 100], "placement": {"arrow_length": [3, 12], "initial_playable_cap": 16}, "attempts": 5}},
	{"name": "tighter 30x20, len 3-8", "profile": {"width": 30, "height": 20, "arrows": [100, 100], "placement": {"arrow_length": [3, 8]}, "attempts": 5}},
	{"name": "dense 26x18, len 3-8, density>=0.75", "profile": {"width": 26, "height": 18, "arrows": [100, 100], "density": [0.75, 1.0], "placement": {"arrow_length": [3, 8]}, "attempts": 5}},
]

func _initialize() -> void:
	for case in CASES:
		var started := Time.get_ticks_msec()
		var result := PuzzleGenerator.generate(case["profile"], 2026)
		var elapsed := Time.get_ticks_msec() - started
		var definition: PuzzleDefinition = result["definition"]
		if definition == null:
			print("%s: no board (%s)" % [case["name"], "; ".join(result["profile_errors"])])
			continue
		var a := PuzzleAnalyzer.analyze(definition)
		print("%s: ok=%s arrows=%d density=%.2f playable=%d depth=%d components=%d max_len=%d avg_len=%.1f attempts=%d time=%.1fs misses=%s" % [
			case["name"], result["ok"], a["board"]["arrow_count"], a["board"]["density"],
			a["legal_move_structure"]["initial_legal_count"], a["dependency_graph"]["depth"],
			a["dependency_graph"]["component_count"], a["geometry"]["max_length"], a["geometry"]["average_length"],
			result["attempts_used"], elapsed / 1000.0, result["misses"]])
	quit()
