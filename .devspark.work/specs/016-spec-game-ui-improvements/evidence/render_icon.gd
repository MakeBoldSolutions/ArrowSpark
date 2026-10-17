extends SceneTree
## Throwaway: rasterise the brand mark tile into the 256 px application icon.
func _initialize() -> void:
	var svg := FileAccess.get_file_as_bytes("res://assets/brand/mark_tile.svg")
	var image := Image.new()
	var err := image.load_svg_from_buffer(svg, 256.0 / 828.0)
	print("RENDER err=", err, " size=", image.get_size())
	image.save_png("res://icon.png")
	quit()
