extends GutTest
## n11 combat (owner: reactions on being shot are poor): a whole-figure card shows a wound.


func _cop(kind: StringName, t: float) -> CutRig:
	var rig: CutRig = autofree(CutRig.new())
	rig.plan = HumanPlan.cop()
	var r: HumanReact = HumanReact.on(rig)
	r.kind = kind
	r.t = t
	return rig


func test_every_hit_grid_loads_as_five_facings() -> void:
	for key: String in StreetWalkerHit.GRIDS:
		var path: String = StreetWalkerCards.DIR + StreetWalkerHit.GRIDS[key]
		assert_true(StreetWalkerHit.is_grid(path), path)
		var tex: Texture2D = load(path) as Texture2D
		assert_not_null(tex, path)
		if tex != null:
			assert_eq(tex.get_width() % RigHeadCard.FRAMES, 0, "%s whole facings" % path)


func test_a_flinch_draws_the_cell_only_inside_its_hold() -> void:
	var row: String = "cop/head_cap"
	assert_ne(StreetWalkerHit.grid_of(_cop(&"flinch", 0.05), row), "", "hit: thrown back")
	var end: float = StreetWalkerHit.HOLD_S[&"flinch"]
	assert_eq(StreetWalkerHit.grid_of(_cop(&"flinch", end), row), "", "the hold is over")


func test_a_kind_with_no_drawn_cell_keeps_its_figure() -> void:
	# it20: every street kind that dies has a grid now (the punk was this example): a row without one
	assert_false(StreetWalkerHit.GRIDS.has("ped/head_none"))
	assert_eq(StreetWalkerHit.grid_of(_cop(&"flinch", 0.05), "ped/head_none"), "")


func test_a_shot_death_opens_on_the_thrown_cell_then_falls() -> void:
	var dying: CutRig = _cop(&"death_bullet", 0.0)
	var r: HumanReact = dying.react
	r.dying = true
	r.length = 1.0
	r.t = 0.05
	assert_ne(StreetWalkerHit.grid_of(dying, "cop/head_cap"), "", "the blow's frame")
	r.t = StreetWalkerFall.FALL_AT[1]
	assert_eq(StreetWalkerHit.grid_of(dying, "cop/head_cap"), "", "the fall grid has it from here")
	assert_eq(StreetWalkerHit.grid_of(_cop(&"", 0.05), "cop/head_cap"), "", "no family, no cell")


func test_fire_and_shock_deaths_keep_their_own_look() -> void:
	var burn: CutRig = _cop(&"death_burn", 0.0)
	burn.react.dying = true
	assert_eq(StreetWalkerHit.grid_of(burn, "cop/head_cap"), "", "death_burn is the fire's")


func test_a_family_without_a_cell_does_not_draw_one() -> void:
	assert_eq(StreetWalkerHit.grid_of(_cop(&"fold", 0.05), "cop/head_cap"), "")


func test_the_cell_faces_the_shooter_so_the_figure_arches_with_the_blow() -> void:
	var card: Sprite2D = autofree(Sprite2D.new())
	card.hframes = RigHeadCard.FRAMES
	# a round flying west: the shooter is east, the drawn figure faces east, unmirrored
	StreetWalkerHit.face(card, Vector2.LEFT)
	assert_eq(card.frame_coords.x, 2, "the side-on cell")
	assert_false(card.flip_h, "the cell faces screen right")
	# flying east: the shooter is west: the same cell mirrored
	StreetWalkerHit.face(card, Vector2.RIGHT)
	assert_true(card.flip_h, "mirrored for a shooter on the left")
	# flying north: the shooter is south, toward the camera: the face
	StreetWalkerHit.face(card, Vector2.UP)
	assert_eq(card.frame_coords.x, 0, "the front cell")


func test_a_wound_shoves_and_tips_the_card_along_the_blow() -> void:
	var rig: CutRig = _cop(&"flinch", 0.05)
	add_child_autofree(rig)
	var r: HumanReact = rig.react
	r.travel = 80.0
	r.off = Vector2(80.0, 0.0)
	rig.scale = Vector2(0.1, 0.1)
	var s: Vector3 = StreetWalkerHit.shove(rig)
	assert_almost_eq(s.x, 8.0, 0.001, "the wound's travel in world px")
	assert_gt(s.z, 0.0, "tips the way the blow travels on screen")
	assert_almost_eq(s.z, StreetWalkerHit.LEAN, 0.001, "at the peak of the family")


func test_no_wound_moves_nothing() -> void:
	var rig: CutRig = _cop(&"", 0.0)
	assert_eq(StreetWalkerHit.shove(rig), Vector3.ZERO, "nothing playing")
	rig.react.kind = &"flinch"
	rig.react.dying = true
	rig.react.off = Vector2(80.0, 0.0)
	assert_eq(StreetWalkerHit.shove(rig), Vector3.ZERO, "a death is the fall grid's")


func test_a_hit_grid_is_dropped_when_its_hold_ends() -> void:
	assert_true(StreetWalkerHit.is_grid(StreetWalkerCards.DIR + "p70/cop_patrol_hit.png"))
	assert_false(StreetWalkerHit.is_grid(StreetWalkerCards.DIR + "p70/cop_patrol_armed_walk.png"))


func test_a_living_wound_draws_its_site_and_a_death_the_thrown_cell() -> void:
	var row: String = "cop/head_cap"
	assert_eq(
		StreetWalkerHit.grid_of(_cop(&"flinch", 0.05), row), "p70/cop_patrol_shoulder_hit.png"
	)
	assert_eq(StreetWalkerHit.grid_of(_cop(&"stagger", 0.05), row), "p70/cop_patrol_gut_hit.png")
	var dying: CutRig = _cop(&"death_bullet", 0.0)
	dying.react.dying = true
	dying.react.length = 1.0
	assert_eq(StreetWalkerHit.grid_of(dying, row), StreetWalkerHit.GRIDS[row], "death: thrown back")
	assert_eq(
		StreetWalkerHit.grid_of(_cop(&"flinch", 0.05), "cop/head_helmet"),
		StreetWalkerHit.GRIDS["cop/head_helmet"],
		"a kind with no sites keeps the thrown cell"
	)


func test_every_site_grid_loads_as_five_facings() -> void:
	for row: String in StreetWalkerHit.SITE_GRIDS:
		var sites: Dictionary = StreetWalkerHit.SITE_GRIDS[row]
		for kind: StringName in sites:
			var path: String = StreetWalkerCards.DIR + str(sites[kind])
			assert_true(StreetWalkerHit.is_grid(path), path)
			var tex: Texture2D = load(path) as Texture2D
			assert_not_null(tex, path)
			if tex != null:
				assert_eq(tex.get_width() % RigHeadCard.FRAMES, 0, "%s whole facings" % path)


func test_every_street_kind_that_dies_is_drawn_thrown_back_by_the_round() -> void:
	# n11 it20: only the cops, the suit and the worker had a drawn hit grid; the thug and seven
	# pedestrians wilted on their feet (the asset lane's cells, ASSETS-REPLIES 01:01-01:06)
	for row: String in StreetDeadPlan.CLASS_OF:
		assert_true(StreetWalkerHit.GRIDS.has(row), "%s has a drawn hit grid" % row)


func test_every_thrown_cell_draws_at_the_walking_figures_scale() -> void:
	# n11 it21: the cell fitted to its height drew the head and torso at ~0.65 x the walker's
	for row: String in StreetWalkerHit.GRIDS:
		var path: String = StreetWalkerCards.DIR + StreetWalkerHit.GRIDS[row]
		var fill: float = StreetWalkerHit.fill_of(path)
		assert_between(fill, 1.1, 1.5, "%s drawn up to the walker's scale" % path)
	for row: String in StreetWalkerHit.SITE_GRIDS:
		for site: String in StreetWalkerHit.SITE_GRIDS[row].values():
			var drawn: float = StreetWalkerHit.fill_of(StreetWalkerCards.DIR + site)
			assert_eq(drawn, 1.0, "%s: drawn at the walk's scale" % site)
	assert_eq(StreetWalkerHit.fill_of(StreetWalkerCards.DIR + "p70/cop_patrol_armed_walk.png"), 1.0)


func test_a_thrown_card_is_placed_at_its_fill_about_the_planted_boot() -> void:
	var rig: CutRig = _cop(&"flinch", 0.05)
	var card: Sprite2D = autofree(Sprite2D.new())
	var path: String = StreetWalkerCards.DIR + StreetWalkerHit.GRIDS["cop/head_helmet"]
	card.texture = load(path) as Texture2D
	card.hframes = RigHeadCard.FRAMES
	card.set_meta(StreetWalkerCards.ON, path)
	StreetWalkerCards.place(rig, card)
	var drawn: float = card.global_scale.x
	assert_eq(card.global_position, rig.global_position, "the boot stays where the rig stands")
	card.set_meta(StreetWalkerCards.ON, StreetWalkerCards.DIR + "p70/cop_riot_card.png")
	StreetWalkerCards.place(rig, card)
	assert_almost_eq(drawn / card.global_scale.x, StreetWalkerHit.FILL["cop_riot_hit.png"], 0.001)
