extends GutTest

const ROOF_DIR: String = "res://features/city/art/roofs/"
const SLACK_M: float = 0.05


func _bounds(piece: PrologueYardDressing.Piece) -> Rect2:
	var box: Rect2 = Rect2(-piece.size_m * 0.5, piece.size_m)
	return Transform2D(piece.rotation, piece.at) * box


func test_stamps_clear_every_city_roof_in_the_resolved_torn_line_dressing() -> void:
	var look: PrologueYardDressing = PrologueYardDressing.resolve("torn_line")
	var pieces: Array[PrologueYardDressing.Piece] = look.outside + look.decals + look.factory_front
	var roofs: Array[PrologueYardDressing.Piece] = []
	for piece: PrologueYardDressing.Piece in pieces:
		if piece.art.begins_with(ROOF_DIR):
			roofs.append(piece)
	assert_false(roofs.is_empty(), "torn_line inherits the city's roof blocks")
	for piece: PrologueYardDressing.Piece in pieces:
		if piece in roofs:
			continue
		var box: Rect2 = _bounds(piece)
		for roof: PrologueYardDressing.Piece in roofs:
			assert_false(
				box.intersects(_bounds(roof).grow(-SLACK_M)),
				"%s at %s intersects %s at %s" % [piece.art, piece.at, roof.art, roof.at]
			)
