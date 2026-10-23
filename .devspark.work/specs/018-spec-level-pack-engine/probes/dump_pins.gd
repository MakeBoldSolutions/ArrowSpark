extends SceneTree
## Throwaway probe: one line per catalog entry with every identity the
## migration must preserve.

func _initialize() -> void:
	for i in range(PuzzleCatalog.count()):
		var id := PuzzleCatalog.id_at(i)
		var definition := PuzzleCatalog.get_definition(id)
		print("%d|%s|%s|%s|%d|%s|%s" % [i, id, PuzzleCatalog.title_at(i), PuzzleCatalog.group_of(id),
			PuzzleCatalog.group_position(id), PuzzleCatalog.next_in_group(id), PuzzleContentVersion.of(definition)])
	quit()
