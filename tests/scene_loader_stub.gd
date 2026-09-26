extends Node
## Isolated test-only stand-in for the addon's SceneLoader autoload
## (tests/run_regressions.py registers this as the "SceneLoader" singleton).
## Records calls without touching the filesystem or scene tree, so the
## no-reset regression test can exercise real menu entry-point methods
## without needing the full scene/resource loading pipeline.

var load_scene_calls: int = 0

func load_scene(_scene_path: String, _in_background: bool = false) -> void:
	load_scene_calls += 1

func reload_current_scene() -> void:
	pass
