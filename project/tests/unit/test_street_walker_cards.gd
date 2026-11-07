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


func test_every_walk_grid_loads_as_five_facings_by_four_frames() -> void:
	for art: String in StreetWalkerCards.WALKS:
		var rows: Dictionary = StreetWalkerCards.WALKS[art]
		assert_true(
			StreetWalkerCards.STRIPS[art].has_all(rows.keys()), "%s walks have stills" % art
		)
		for key: String in rows:
			var path: String = StreetWalkerCards.DIR + art + "/" + str(rows[key])
			assert_true(path.ends_with("_walk.png"), path)
			assert_true(StreetWalkerCards.WALK_FILL.has(str(rows[key])), "%s has a fill" % path)
			var tex: Texture2D = load(path) as Texture2D
			assert_not_null(tex, path)
			if tex != null:
				assert_eq(tex.get_width() % RigHeadCard.FRAMES, 0, "%s whole facings" % path)
				assert_eq(tex.get_height() % StreetWalkerCards.STRIDE_FRAMES, 0, "%s frames" % path)


func test_stride_frame_steps_four_frames_per_cycle_and_stands_on_pass() -> void:
	assert_eq(StreetWalkerCards.stride_frame(0.0, true), 0)
	assert_eq(StreetWalkerCards.stride_frame(0.26, true), 1)
	assert_eq(StreetWalkerCards.stride_frame(0.51, true), 2)
	assert_eq(StreetWalkerCards.stride_frame(0.99, true), 3)
	assert_eq(StreetWalkerCards.stride_frame(1.3, true), 1, "the cycle wraps")
	assert_eq(StreetWalkerCards.stride_frame(0.6, false), StreetWalkerCards.STAND_FRAME)


func test_a_flinch_keeps_the_figure_and_a_death_falls_after_the_hold() -> void:
	var rig: CutRig = autofree(CutRig.new())
	var r: HumanReact = HumanReact.on(rig)
	assert_false(StreetWalkerCards.falls(rig), "a reaction slot alone keeps the figure")
	r.kind = &"flinch"
	assert_false(StreetWalkerCards.falls(rig), "a flinch keeps the figure")
	r.kind = &"death_light"
	r.dying = true
	r.length = 1.0
	r.t = StreetWalkerCards.DEATH_HOLD * 0.5
	rig.dead = true
	assert_false(StreetWalkerCards.falls(rig), "the figure holds into the death")
	r.t = StreetWalkerCards.DEATH_HOLD
	assert_true(StreetWalkerCards.falls(rig), "the parts take the fall")
	r.clear()
	assert_true(StreetWalkerCards.falls(rig), "dead with no family: the parts")


func test_hide_skips_an_item_freed_since_it_was_hidden() -> void:
	var kept: Node2D = autofree(Node2D.new())
	var gone: Node2D = Node2D.new()
	var items: Array[CanvasItem] = [gone, kept]
	gone.free()
	StreetView.hide_all(items)
	assert_false(kept.visible, "the live item is hidden")
	assert_false(is_instance_valid(items[0]), "the freed one was skipped")
