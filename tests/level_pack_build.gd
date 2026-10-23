extends SceneTree
## Headless pack build: generates every level a recipe names, checks each one
## and the whole catalog it would join, prints a structural report per level,
## and, only when nothing failed, prints the serialized pack between PACK_BEGIN
## and PACK_END for tests/run_level_pack_build.py to write. Writes no files
## itself. Run via tests/run_level_pack_build.py, which passes
## `-- --recipe <res:// path>`.
##
## Recipe: {"format": "arrowspark-recipe/1", "pack": <name>, "group": <group id>,
## "profiles": {<name>: <PuzzleGenerator profile>}, "levels": [{"id", "title",
## "profile", "seed"}, ...]}. The pack must already be listed in
## res://levels/catalog.json; its current file, if any, is skipped, so a first
## build and a rebuild work the same way.

const RECIPE_FORMAT := "arrowspark-recipe/1"

var failures: int = 0

func fail(message: String) -> void:
	failures += 1
	print("BUILD FAILURE: ", message)

func _initialize() -> void:
	var recipe = _load_recipe(_arg("--recipe"))
	if recipe != null:
		_build(recipe)
	print("PACK_BUILD_FAILURES=", failures)
	quit(1 if failures else 0)

func _build(recipe: Dictionary) -> void:
	var pack_name: String = recipe["pack"]
	var group: String = recipe["group"]
	var manifest_errors: Array[String] = []
	var listed := PuzzlePackFormat.parse_manifest(
		FileAccess.get_file_as_string(PuzzleCatalog.LEVELS_ROOT.path_join("catalog.json")), manifest_errors)
	for message in manifest_errors:
		fail(message)
	if not listed.has(pack_name):
		fail("pack '%s' is not listed in levels/catalog.json; add it there first" % pack_name)
		return
	var others := PuzzlePackFormat.load_catalog(PuzzleCatalog.LEVELS_ROOT, pack_name)
	for message in others["errors"]:
		fail(message)

	var built: Array = []
	for level in recipe["levels"]:
		var record = _build_level(level, recipe, pack_name, group)
		if record != null:
			built.append(record)
	var everything: Array = others["levels"].duplicate()
	everything.append_array(built)
	for message in PuzzlePackFormat.audit_levels(everything, PuzzleCatalog.GROUP_TITLES.keys()):
		fail(message)
	if failures == 0:
		print("PACK_BEGIN")
		print(PuzzlePackFormat.serialize_pack(pack_name, built).trim_suffix("\n"))
		print("PACK_END")

## Generates one recipe level and reports it. Returns its record when the
## generator met the profile, or null (counted as a failure) when it did not.
func _build_level(level: Dictionary, recipe: Dictionary, pack_name: String, group: String) -> Variant:
	var id: String = level["id"]
	var profile_name: String = level["profile"]
	var level_seed: int = level["seed"]
	var profile: Dictionary = recipe["profiles"][profile_name]
	var result := PuzzleGenerator.generate(profile, level_seed)
	if not result["profile_errors"].is_empty():
		fail("level '%s': profile '%s' rejected: %s" % [id, profile_name, "; ".join(result["profile_errors"])])
		return null
	var definition: PuzzleDefinition = result["definition"]
	if definition == null:
		fail("level '%s': no board could be built for profile '%s' with seed %d" % [id, profile_name, level_seed])
		return null
	var provenance := {
		"kind": "generated",
		"generator": PuzzleGenerator.GENERATOR_SCHEME,
		"profile_name": profile_name,
		"profile": profile,
		"seed": level_seed,
	}
	var record := PuzzlePackFormat.make_record(id, level["title"], group, definition, provenance)
	record["pack"] = pack_name
	PuzzleReportFormat.print_entry(id, level["title"], PuzzleAnalyzer.analyze(definition))
	var misses: PackedStringArray = []
	for miss in result["misses"]:
		misses.append("%s %s [%s,%s]" % [miss["metric"], miss["value"], miss["min"], miss["max"]])
	print("  profile: %s seed=%d score=%.3f attempts=%d misses=%s" % [profile_name, level_seed, result["score"],
		result["attempts_used"], ", ".join(misses) if not misses.is_empty() else "none"])
	print("level: %s %s" % [id, record["content_version"]])
	if not result["ok"]:
		fail("level '%s': best board misses its profile: %s" % [id, ", ".join(misses)])
		return null
	return record

## Parses and checks the recipe's shape; null (after reporting) when unusable.
func _load_recipe(path: String) -> Variant:
	if path.is_empty() or not FileAccess.file_exists(path):
		fail("recipe '%s' was not found (pass -- --recipe <path>)" % path)
		return null
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		fail("recipe is not valid JSON: line %d: %s" % [json.get_error_line(), json.get_error_message()])
		return null
	var recipe = json.data
	if not (recipe is Dictionary) or recipe.get("format") != RECIPE_FORMAT:
		fail("recipe format must be '%s'" % RECIPE_FORMAT)
		return null
	if not (recipe.get("pack") is String) or (recipe["pack"] as String).is_empty():
		fail("recipe 'pack' must be a non-empty string")
		return null
	if not PuzzleCatalog.GROUP_TITLES.has(recipe.get("group")):
		fail("recipe 'group' must be one of %s" % [PuzzleCatalog.GROUP_TITLES.keys()])
		return null
	var profiles = recipe.get("profiles")
	var levels = recipe.get("levels")
	if not (profiles is Dictionary) or not (levels is Array) or levels.is_empty():
		fail("recipe needs a 'profiles' object and a non-empty 'levels' array")
		return null
	var clean: Array = []
	for i in range(levels.size()):
		var level = levels[i]
		var problem := ""
		if not (level is Dictionary):
			problem = "is not an object"
		elif not (level.get("id") is String) or (level["id"] as String).is_empty() or not (level.get("title") is String):
			problem = "needs a non-empty 'id' and a 'title'"
		elif not profiles.has(level.get("profile")) or not (profiles[level["profile"]] is Dictionary):
			problem = "names profile '%s', which the recipe does not define" % [level.get("profile")]
		elif not (level.get("seed") is float or level.get("seed") is int) or level["seed"] != floorf(level["seed"]):
			problem = "needs a whole-number 'seed'"
		if not problem.is_empty():
			fail("recipe level #%d %s" % [i, problem])
			continue
		clean.append({"id": level["id"], "title": level["title"], "profile": level["profile"], "seed": int(level["seed"])})
	if clean.size() != levels.size():
		return null
	recipe["levels"] = clean
	return recipe

func _arg(name: String) -> String:
	var args := OS.get_cmdline_user_args()
	var index := args.find(name)
	return args[index + 1] if index != -1 and index + 1 < args.size() else ""
