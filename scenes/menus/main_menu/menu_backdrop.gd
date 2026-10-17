class_name MenuBackdrop
extends Control
## Quiet menu background: a field of the game's own arrow shapes in a low-contrast
## tint, drifting slowly upward. The pattern is drawn once; only this control's
## position moves each frame, and only while it is visible. Never takes input.

const CELL := 48.0
const DRIFT_PIXELS_PER_SECOND := 6.0
const COLOR := GameVisualStyle.INK_100
## Cell paths (tail to head) in a pattern tile of TILE_CELLS; heads point along the
## final segment, like puzzle arrows.
const TILE_CELLS := Vector2i(16, 15)
const ARROWS := [
	[Vector2i(1, 2), Vector2i(4, 2)],
	[Vector2i(7, 1), Vector2i(7, 4), Vector2i(10, 4)],
	[Vector2i(13, 5), Vector2i(13, 2)],
	[Vector2i(2, 8), Vector2i(2, 5)],
	[Vector2i(5, 6), Vector2i(9, 6), Vector2i(9, 9)],
	[Vector2i(15, 8), Vector2i(12, 8)],
	[Vector2i(4, 12), Vector2i(4, 10), Vector2i(1, 10)],
	[Vector2i(8, 13), Vector2i(12, 13)],
	[Vector2i(14, 14), Vector2i(14, 11)],
]

var _elapsed := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visibility_changed.connect(_update_processing)
	_update_processing()

func _update_processing() -> void:
	set_process(is_visible_in_tree())

func _process(delta: float) -> void:
	_elapsed += delta
	var tile_height := TILE_CELLS.y * CELL
	position.y = -fmod(_elapsed * DRIFT_PIXELS_PER_SECOND, tile_height)

func _draw() -> void:
	var tile := Vector2(TILE_CELLS) * CELL
	var rows := int(ceil(size.y / tile.y)) + 1
	var columns := int(ceil(size.x / tile.x))
	for row in range(rows):
		for column in range(columns):
			_draw_tile(Vector2(column, row) * tile)

func _draw_tile(origin: Vector2) -> void:
	var width := CELL * GameVisualStyle.BODY_WIDTH
	for path in ARROWS:
		var points := PackedVector2Array()
		for cell in path:
			points.append(origin + (Vector2(cell) + Vector2(0.5, 0.5)) * CELL)
		var head: Vector2 = points[points.size() - 1]
		var forward: Vector2 = (head - points[points.size() - 2]).normalized()
		var side := Vector2(-forward.y, forward.x)
		points[points.size() - 1] = head + forward * GameVisualStyle.BODY_END * CELL
		draw_polyline(points, COLOR, width, true)
		var tip := head + forward * GameVisualStyle.HEAD_TIP * CELL
		var base := head + forward * GameVisualStyle.HEAD_BASE * CELL
		var half := side * GameVisualStyle.HEAD_HALF_WIDTH * CELL
		draw_colored_polygon(PackedVector2Array([tip, base + half, base - half]), COLOR)
