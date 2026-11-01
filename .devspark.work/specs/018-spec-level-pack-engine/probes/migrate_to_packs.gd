extends SceneTree
## Throwaway migration probe: writes every current catalog entry, built by its
## existing builder, into one pack per group through PuzzlePackFormat, keeping
## each builder's doc comment as the level's notes.

func _initialize() -> void:
	var notes := _builder_notes(FileAccess.get_file_as_string("res://scripts/puzzle/puzzle_catalog.gd"))
	var packs := {}
	var order: Array[String] = []
	for i in range(PuzzleCatalog.count()):
		var id := PuzzleCatalog.id_at(i)
		var group := PuzzleCatalog.group_of(id)
		var method: String = (PuzzleCatalog._entries[i]["build"] as Callable).get_method()
		if not notes.has(method):
			push_error("no doc comment found for %s" % method)
		if order.is_empty() or order[order.size() - 1] != group:
			assert(not packs.has(group), "group %s is not contiguous in the catalog" % group)
			order.append(group)
			packs[group] = []
		packs[group].append(PuzzlePackFormat.make_record(id, PuzzleCatalog.title_at(i), group,
			PuzzleCatalog.get_definition(id), {"kind": "hand-authored"}, notes.get(method, "")))
	DirAccess.make_dir_recursive_absolute("res://levels/packs")
	for group in order:
		var file := FileAccess.open("res://levels/packs/%s.json" % group, FileAccess.WRITE)
		file.store_string(PuzzlePackFormat.serialize_pack(group, packs[group]))
		file.close()
		print("wrote ", group, " (", packs[group].size(), " levels)")
	quit()

## Builder method name -> its preceding "##" doc comment, with "##" blank
## lines kept as paragraph breaks.
func _builder_notes(source: String) -> Dictionary:
	var notes := {}
	var block: Array[String] = []
	for line in source.split("\n"):
		var stripped := line.strip_edges()
		if stripped.begins_with("##"):
			block.append(stripped.substr(2).strip_edges())
			continue
		if stripped.begins_with("static func _build_"):
			var name := stripped.substr("static func ".length()).get_slice("(", 0)
			var paragraphs: PackedStringArray = []
			var current: PackedStringArray = []
			for text in block:
				if text.is_empty():
					if not current.is_empty():
						paragraphs.append(" ".join(current))
						current = []
				else:
					current.append(text)
			if not current.is_empty():
				paragraphs.append(" ".join(current))
			notes[name] = "\n\n".join(paragraphs)
		block = []
	return notes
