extends GutTest

const MOUTH_OPENING_X: Vector2 = Vector2(9.6, 14.7)


func _row() -> Dictionary:
	var table: DataTable = DataTable.open(PrologueYardDressing.TABLE, PrologueYardDressing.SCHEMA)
	return table.raw["dressings"]["arched_line"]


func _piece() -> Dictionary:
	for piece: Dictionary in _row()["layout"]["debris"]:
		if piece["id"] == "span_mouth_door":
			return piece
	return {}


func test_mouth_span_is_the_last_over_print_id_and_blocks_nothing() -> void:
	var over: Array = _row()["over_print"]
	var last: String = over[over.size() - 1]
	assert_eq(last, "span_mouth_door", "spans stay last")
	for cover: Dictionary in _row()["layout"]["cover"]:
		assert_ne(str(cover["id"]), "span_mouth_door")
	var piece: Dictionary = _piece()
	assert_false(piece.is_empty())
	assert_true(ResourceLoader.exists(str(piece["art"])))
	assert_false(piece.has("cover"))
	assert_false(piece.has("collision"))
	assert_false(piece.has("legs"))


func test_mouth_span_starts_inside_the_burst_bay_opening() -> void:
	var piece: Dictionary = _piece()
	var at: Array = piece["at"]
	var size: Array = piece["size_m"]
	var at_x: float = at[0]
	var size_x: float = size[0]
	var west: float = at_x - size_x / 2.0
	assert_between(west, MOUTH_OPENING_X.x, MOUTH_OPENING_X.y, "the art's west end x")
