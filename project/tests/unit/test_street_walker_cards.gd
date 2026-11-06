extends GutTest
## Lane n8 street: the walkers' whole-figure cards (StreetWalkerCards).


func test_every_walker_strip_loads_with_whole_frames() -> void:
	for art: String in StreetWalkerCards.STRIPS:
		var rows: Dictionary = StreetWalkerCards.STRIPS[art]
		assert_eq(rows.size(), 9, "the nine library pedestrian types at %s" % art)
		for key: String in rows:
			var path: String = StreetWalkerCards.DIR + art + "/" + str(rows[key])
			var tex: Texture2D = load(path) as Texture2D
			assert_not_null(tex, path)
			if tex != null:
				assert_eq(tex.get_width() % RigHeadCard.FRAMES, 0, "%s whole frames" % path)


func test_every_crowd_card_row_has_a_walker() -> void:
	var rows: Dictionary = StreetWalkerCards.STRIPS["p70"]
	for tag: String in StreetCrowdCards.POOLS:
		var pool: PackedStringArray = StreetCrowdCards.POOLS.get(tag, PackedStringArray())
		for i: int in pool.size():
			assert_true(rows.has(pool[i]), pool[i])
	for head: String in ["head_hair", "head_bald", "head_hat", "head_hood", "head_cap"]:
		assert_true(rows.has("ped/" + head), head)


func test_straight_down_no_walker_is_drawn() -> void:
	var rig: CutRig = autofree(CutRig.new())
	assert_eq(StreetWalkerCards.strip_of(rig), "", "no head card (top): the parts draw")


func test_release_without_a_walker_is_a_no_op() -> void:
	var rig: CutRig = autofree(CutRig.new())
	StreetWalkerCards.release(rig)
	assert_null(rig.head_card)
