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
