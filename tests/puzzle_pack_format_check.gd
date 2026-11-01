extends SceneTree
## Headless isolated-project check for PuzzlePackFormat's handling of bad
## input: every malformed or inconsistent pack is reported with a message
## naming the pack and level, never silently dropped or accepted. Inline pack
## text covers parsing; manifests written under user:// (the launcher isolates
## user data) cover missing packs. Run via tests/run_puzzle_regressions.py.

const FIXTURES := "user://pack_fixtures"

var failures: int = 0

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

## One valid level as plain JSON data (a 3x2 board with a single arrow), so
## each case can break exactly one thing.
func _level(id: String, head_x: int = 0, group: String = "foundations") -> Dictionary:
	var definition := PuzzleDefinition.new(3, 2, {Vector2i(head_x, 0): PuzzleDefinition.Direction.UP})
	var record := PuzzlePackFormat.make_record(id, id.to_upper(), group, definition, {"kind": "hand-authored"})
	var text := PuzzlePackFormat.serialize_pack("p", [record])
	return JSON.parse_string(text)["levels"][0]

func _pack_text(levels: Array, pack_name: String = "p") -> String:
	return JSON.stringify({"format": PuzzlePackFormat.PACK_FORMAT, "pack": pack_name, "levels": levels})

## Parses one broken level and checks the error names the pack, the level
## and the problem.
func _expect_parse_error(level: Dictionary, needle: String, description: String) -> void:
	var parsed := PuzzlePackFormat.parse_pack(_pack_text([level]), "p")
	var errors: Array = parsed["errors"]
	var message: String = "" if errors.is_empty() else errors[0]
	check(parsed["levels"].is_empty() and errors.size() == 1, "%s is rejected" % description)
	check(message.contains("pack 'p'") and message.contains("level '%s'" % level["id"]) and message.contains(needle),
		"%s names pack, level and problem (%s)" % [description, message])

func _expect_audit_error(levels: Array, needle: String, description: String) -> void:
	var parsed := PuzzlePackFormat.parse_pack(_pack_text(levels), "p")
	check(parsed["errors"].is_empty(), "%s parses cleanly before auditing" % description)
	var errors := PuzzlePackFormat.audit_levels(parsed["levels"], ["foundations"])
	var message: String = "" if errors.is_empty() else errors[0]
	check(errors.size() == 1 and message.contains("pack 'p'") and message.contains(needle),
		"%s fails the audit naming pack and problem (%s)" % [description, message])

func _check_well_formed() -> void:
	var parsed := PuzzlePackFormat.parse_pack(_pack_text([_level("a"), _level("b", 2)]), "p")
	check(parsed["errors"].is_empty() and parsed["levels"].size() == 2, "a well-formed pack parses with no errors")
	check(PuzzlePackFormat.audit_levels(parsed["levels"], ["foundations"]).is_empty(), "a well-formed pack passes the audit")
	var text := PuzzlePackFormat.serialize_pack("p", parsed["levels"])
	check(PuzzlePackFormat.serialize_pack("p", PuzzlePackFormat.parse_pack(text, "p")["levels"]) == text,
		"serialize -> parse -> serialize is byte-identical")

func _check_malformed_json() -> void:
	var parsed := PuzzlePackFormat.parse_pack("{\"format\": \"arrowspark-pack/1\", \"levels\": [", "p")
	var errors: Array = parsed["errors"]
	check(parsed["levels"].is_empty() and errors.size() == 1 and errors[0].contains("pack 'p'") and errors[0].contains("not valid JSON"),
		"malformed JSON is reported naming the pack (%s)" % ", ".join(errors))

func _check_coordinates() -> void:
	var fractional := _level("frac")
	fractional["arrows"][0][1][0] = [0.5, 0]
	_expect_parse_error(fractional, "whole numbers", "a fractional coordinate")

	var text_coordinate := _level("text")
	text_coordinate["arrows"][0][1][0] = ["zero", 0]
	_expect_parse_error(text_coordinate, "whole numbers", "a non-numeric coordinate")

	var fractional_size := _level("size")
	fractional_size["width"] = 3.5
	_expect_parse_error(fractional_size, "positive whole numbers", "a fractional board width")

func _check_vertices() -> void:
	var diagonal := _level("diag")
	diagonal["arrows"][0] = ["up", [[0, 0], [1, 1]]]
	_expect_parse_error(diagonal, "diagonal", "a diagonal vertex step")

	var zero_length := _level("zero")
	zero_length["arrows"][0] = ["up", [[0, 0], [0, 0]]]
	_expect_parse_error(zero_length, "zero-length", "a zero-length vertex step")

	var out_of_bounds := _level("oob")
	out_of_bounds["arrows"][0] = ["up", [[5, 0]]]
	_expect_parse_error(out_of_bounds, "invalid board", "an arrow that fails board validation")

	var bad_direction := _level("dir")
	bad_direction["arrows"][0][0] = "sideways"
	_expect_parse_error(bad_direction, "direction", "an unknown direction")

func _check_audit() -> void:
	var first := _level("same")
	var second := _level("same", 2)
	_expect_audit_error([first, second], "duplicate id", "a duplicate id")

	_expect_audit_error([_level("one"), _level("two")], "same board", "a duplicate board")

	_expect_audit_error([_level("lost", 0, "nowhere")], "unknown group", "an unknown group")

	var stale := _level("stale")
	stale["content_version"] = "g1-000000000000"
	_expect_audit_error([stale], "does not match", "a stored content version that does not match its geometry")

func _write(path: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()

func _check_missing_pack() -> void:
	var root := FIXTURES.path_join("missing")
	_write(root.path_join("catalog.json"), JSON.stringify({"format": PuzzlePackFormat.CATALOG_FORMAT, "packs": ["present", "absent"]}))
	_write(root.path_join("packs/present.json"), _pack_text([_level("here")], "present"))

	var loaded := PuzzlePackFormat.load_catalog(root)
	var errors: Array = loaded["errors"]
	check(loaded["levels"].size() == 1, "the present pack still loads when another listed pack is missing")
	check(errors.size() == 1 and errors[0].contains("pack 'absent'") and errors[0].contains("missing"),
		"a listed pack whose file is missing is reported by name (%s)" % ", ".join(errors))

	var skipped := PuzzlePackFormat.load_catalog(root, "absent")
	check(skipped["errors"].is_empty() and skipped["levels"].size() == 1,
		"a missing pack named as skip_pack is not an error")

	var no_manifest := PuzzlePackFormat.load_catalog(FIXTURES.path_join("nothing_here"))
	check(no_manifest["errors"].size() == 1 and no_manifest["errors"][0].contains("catalog.json"),
		"a missing catalog manifest is reported")

func _initialize() -> void:
	_check_well_formed()
	_check_malformed_json()
	_check_coordinates()
	_check_vertices()
	_check_audit()
	_check_missing_pack()
	print("PUZZLE_PACK_FORMAT_FAILURES=", failures)
	quit(1 if failures else 0)
