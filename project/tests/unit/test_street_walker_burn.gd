extends GutTest
## n11 combat it33: a burning man flails as the drawn burning figure, not a calm walker under loops.


func _cop(kind: StringName, t: float) -> CutRig:
	var rig: CutRig = autofree(CutRig.new())
	rig.plan = HumanPlan.cop()
	var r: HumanReact = HumanReact.on(rig)
	r.kind = kind
	r.t = t
	return rig


func _card(rig: CutRig, path: String) -> Sprite2D:
	var card: Sprite2D = autofree(Sprite2D.new())
	card.texture = load(path) as Texture2D
	card.hframes = RigHeadCard.FRAMES
	card.set_meta(StreetWalkerCards.ON, path)
	rig.head_card = card
	return card


func test_every_burn_grid_loads_as_five_facings() -> void:
	for key: String in StreetWalkerHit.BURN_GRIDS:
		var path: String = StreetWalkerCards.DIR + StreetWalkerHit.BURN_GRIDS[key]
		assert_true(StreetWalkerHit.is_burn(path), path)
		var tex: Texture2D = load(path) as Texture2D
		assert_not_null(tex, path)
		if tex != null:
			assert_eq(tex.get_width() % RigHeadCard.FRAMES, 0, "%s whole facings" % path)
		assert_true(StreetWalkerHit.FILL.has(path.get_file()), "%s drawn at the walk's size" % path)


func test_the_armed_kinds_and_four_peds_burn_as_drawn_figures() -> void:
	var rows: Array[String] = ["cop/head_helmet", "cop/head_swat", "thug", "ped/head_hood"]
	for row: String in rows:
		var want: String = str(StreetWalkerHit.BURN_GRIDS.get(row, "none"))
		assert_eq(StreetWalkerHit.grid_of(_cop(&"burn", 0.05), row), want, row)
		assert_true(StreetWalkerHit.BURN_GRIDS.has(row), row)


func test_a_burning_patrol_cop_draws_the_burning_figure_for_the_whole_family() -> void:
	var want: String = StreetWalkerHit.BURN_GRIDS["cop/head_cap"]
	assert_eq(StreetWalkerHit.grid_of(_cop(&"burn", 0.05), "cop/head_cap"), want, "on fire")
	assert_eq(StreetWalkerHit.grid_of(_cop(&"burn", 6.0), "cop/head_cap"), want, "still burning")
	assert_eq(StreetWalkerHit.grid_of(_cop(&"burn", 0.05), "ped/head_none"), "", "no drawn burn")


func test_the_burning_figure_keeps_its_head_facing_and_shakes() -> void:
	var rig: CutRig = _cop(&"burn", 0.25 / StreetWalkerHit.FLAIL_HZ)
	var path: String = StreetWalkerCards.DIR + StreetWalkerHit.BURN_GRIDS["cop/head_cap"]
	var card: Sprite2D = _card(rig, path)
	rig.react.dir = Vector2.RIGHT
	card.frame = 3
	card.flip_h = true
	assert_true(StreetWalkerHit.draws_burn(rig))
	StreetWalkerCards.place(rig, card)
	assert_eq(card.frame, 3, "faced by the head, not the blow")
	assert_true(card.flip_h)
	var a: float = card.global_rotation
	rig.react.t = 0.75 / StreetWalkerHit.FLAIL_HZ  # half a shake later
	StreetWalkerCards.place(rig, card)
	assert_gt(absf(card.global_rotation - a), StreetWalkerHit.FLAIL_RAD, "the figure flails")


func test_a_walker_does_not_flail() -> void:
	var rig: CutRig = _cop(&"burn", 0.1)
	var card: Sprite2D = _card(rig, StreetWalkerCards.DIR + "p70/cop_patrol_armed_walk.png")
	assert_not_null(card)
	assert_false(StreetWalkerHit.draws_burn(rig))
	assert_eq(StreetWalkerHit.flail(rig), 0.0)


func test_the_burning_figure_stands_on_its_shadow_while_the_parts_flail() -> void:
	var rig: CutRig = _cop(&"burn", 0.2)
	var card: Sprite2D = _card(
		rig, StreetWalkerCards.DIR + StreetWalkerHit.BURN_GRIDS["cop/head_cap"]
	)
	rig.react.off = Vector2(9.0, -6.0)  # the burn family's body travel (hidden parts)
	rig.react.travel = 12.0
	StreetWalkerCards.place(rig, card)
	assert_eq(card.global_position, rig.global_position, "boots on the contact shadow's point")


func test_the_second_flail_frame_swaps_on_odd_half_shakes_and_draws_at_frame_one_size() -> void:
	var path: String = StreetWalkerHit.BURN_GRIDS["cop/head_cap"]
	var half: float = 0.5 / StreetWalkerHit.FLAIL_HZ
	assert_eq(StreetWalkerHit.flail_frame(path, half * 0.5), path, "first half shake: frame one")
	var second: String = StreetWalkerHit.flail_frame(path, half * 1.5)
	if StreetWalkerHit.FLAIL_FRAMES:
		assert_eq(second, path.replace("_burn_hit.png", "_flail_burn_hit.png"), "second half shake")
	else:
		assert_eq(second, path, "flag off: one frame")
	for key: String in StreetWalkerHit.BURN_GRIDS:
		var flail: String = str(StreetWalkerHit.BURN_GRIDS[key]).replace(
			"_burn_hit", "_flail_burn_hit"
		)
		assert_true(ResourceLoader.exists(StreetWalkerCards.DIR + flail), flail)
		assert_eq(
			StreetWalkerHit.fill_of(flail),
			StreetWalkerHit.fill_of(str(StreetWalkerHit.BURN_GRIDS[key])),
			flail
		)
