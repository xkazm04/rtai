extends GutTest
## n17 npc-react: KillDeathCells.fit, the cops' pistol snap frame stood at the walk's size.


func test_the_cops_snap_frame_stands_at_the_walk_size_on_his_boot() -> void:
	# n17 (owner: "policemen are changing sizes on hit"): film b_patrol64 t62 -> t63.
	for file: String in KillDeathCells.FIT_K:
		var cells: Sprite2D = autofree(Sprite2D.new())
		cells.texture = load(StreetWalkerCards.DIR + "p70/" + file) as Texture2D
		cells.hframes = RigHeadCard.FRAMES
		cells.vframes = 4
		cells.scale = Vector2(2.0, 2.0)
		cells.frame_coords = Vector2i(0, 0)
		KillDeathCells.fit(cells, 0)
		assert_almost_eq(cells.scale.x, 2.0 * KillDeathCells.FIT_K[file], 0.001, file)
		assert_lt(KillDeathCells.FIT_K[file], 1.0, file + ": drawn smaller than as delivered")
		assert_eq(cells.offset.y, -float(KillDeathCells.FIT_LIFT[file][0]), file + ": boot lifted")
		cells.frame_coords = Vector2i(0, 1)
		KillDeathCells.fit(cells, 1)
		assert_eq(cells.scale, Vector2(2.0, 2.0), file + ": the buckle as drawn")
		assert_eq(cells.offset, Vector2.ZERO, file)


func test_a_grid_without_a_fit_is_left_as_drawn() -> void:
	var cells: Sprite2D = autofree(Sprite2D.new())
	cells.texture = load(StreetWalkerCards.DIR + "p70/ped_suit_pistol_snap.png") as Texture2D
	cells.scale = Vector2(2.0, 2.0)
	KillDeathCells.fit(cells, 0)
	assert_eq(cells.scale, Vector2(2.0, 2.0))
	assert_eq(cells.offset, Vector2.ZERO)
