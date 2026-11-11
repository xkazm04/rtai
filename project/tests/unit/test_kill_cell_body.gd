extends GutTest
## Lane kills-new (n16): KillCellBody finds where a drawn cell's body lies (its alpha centroid in
## the sprite's local px), so the molotov's flames follow the drawn corpse, not the fall vector.


func _sprite(row: int, col: int) -> Sprite2D:
	var s: Sprite2D = autofree(Sprite2D.new())
	s.texture = load(StreetWalkerCards.DIR + "p70/cop_patrol_gatling_shred.png")
	s.hframes = 5
	s.vframes = 3
	s.centered = true
	s.frame_coords = Vector2i(col, row)
	return s


func test_a_standing_cell_centres_above_its_feet() -> void:
	var c: Vector2 = KillCellBody.centroid(_sprite(0, 0))
	assert_lt(c.y, 0.0, "the standing body is above the feet at the cell centre")
	assert_lt(absf(c.x), 40.0, "and roughly over them")


func test_the_lying_side_cell_lies_off_to_one_side_and_flip_mirrors_it() -> void:
	var s: Sprite2D = _sprite(2, 2)
	var c: Vector2 = KillCellBody.centroid(s)
	assert_gt(absf(c.x), 40.0, "the heap seen side-on lies along the cell")
	s.flip_h = true
	assert_almost_eq(KillCellBody.centroid(s).x, -c.x, 0.001, "flip_h mirrors it")


func test_no_texture_is_zero() -> void:
	var s: Sprite2D = autofree(Sprite2D.new())
	assert_eq(KillCellBody.centroid(s), Vector2.ZERO)
