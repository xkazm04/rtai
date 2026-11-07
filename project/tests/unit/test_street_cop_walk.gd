extends GutTest
## Lane d9 seams: armed city cops walk as drawn grids (StreetCopWalk).


func _cop() -> CutRig:
	var rig: CutRig = autofree(CutRig.new())
	rig.plan = HumanPlan.cop()
	return rig


func test_every_armed_grid_loads_as_five_facings_by_four_frames() -> void:
	for art: String in StreetCopWalk.WALKS:
		var rows: Dictionary = StreetCopWalk.WALKS[art]
		for key: String in rows:
			var file: String = str(rows[key])
			var path: String = StreetWalkerCards.DIR + art + "/" + file
			assert_true(path.ends_with("_walk.png"), "%s steps as a walk grid" % path)
			assert_true(StreetCopWalk.FILL.has(art + "/" + file), "%s has a fill" % path)
			var tex: Texture2D = load(path) as Texture2D
			assert_not_null(tex, path)
			if tex != null:
				assert_eq(tex.get_width() % RigHeadCard.FRAMES, 0, "%s whole facings" % path)
				assert_eq(tex.get_height() % StreetWalkerCards.STRIDE_FRAMES, 0, "%s frames" % path)


func test_a_living_cop_walks_its_rows_grid_at_70_and_55() -> void:
	var rig: CutRig = _cop()
	var cap: String = StreetCopWalk.strip_of(rig, "p70", "cop/head_cap")
	assert_eq(cap, StreetWalkerCards.DIR + "p70/cop_patrol_armed_walk.png")
	var riot: String = StreetCopWalk.strip_of(rig, "p70", "cop/head_helmet")
	assert_eq(riot, StreetWalkerCards.DIR + "p70/cop_riot_armed_walk.png")
	var swat: String = StreetCopWalk.strip_of(rig, "p70", "cop/head_swat")
	assert_eq(swat, StreetWalkerCards.DIR + "p70/swat_armed_walk.png")
	var cap55: String = StreetCopWalk.strip_of(rig, "p55", "cop/head_cap")
	assert_eq(cap55, StreetWalkerCards.DIR + "p55/cop_patrol_armed_walk.png")
	assert_eq(StreetCopWalk.strip_of(rig, "p55", "cop/head_swat"), "", "no 55 SWAT grid yet")


func test_aiming_and_firing_keep_the_grid() -> void:
	var rig: CutRig = _cop()
	rig.aiming = true
	rig.c_recoil = 0.8
	assert_ne(StreetCopWalk.strip_of(rig, "p70", "cop/head_cap"), "", "no flicker per shot")


func test_a_strike_a_throw_a_reload_or_a_death_goes_to_the_parts() -> void:
	var rig: CutRig = _cop()
	rig.strike_arm = 0
	assert_eq(StreetCopWalk.strip_of(rig, "p70", "cop/head_helmet"), "", "the baton swing")
	rig.strike_arm = -1
	rig.throw_t = 0.2
	assert_eq(StreetCopWalk.strip_of(rig, "p70", "cop/head_cap"), "", "a throw")
	rig.throw_t = -1.0
	rig.reload_k = 0.5
	assert_eq(StreetCopWalk.strip_of(rig, "p70", "cop/head_cap"), "", "a reload")
	rig.reload_k = -1.0
	rig.dead = true
	assert_eq(StreetCopWalk.strip_of(rig, "p70", "cop/head_cap"), "", "the fall grids own death")


func test_a_pedestrian_is_not_a_cop() -> void:
	var rig: CutRig = autofree(CutRig.new())
	rig.plan = HumanPlan.ped()
	assert_eq(StreetCopWalk.strip_of(rig, "p70", "cop/head_cap"), "")


func test_fill_of_an_unknown_file_is_one() -> void:
	assert_eq(StreetCopWalk.fill_of(StreetWalkerCards.DIR + "p70/ped_suit_walk.png"), 1.0)
	var riot70: String = StreetWalkerCards.DIR + "p70/cop_riot_armed_walk.png"
	assert_almost_eq(StreetCopWalk.fill_of(riot70), 1.11, 0.001)
	var riot55: String = StreetWalkerCards.DIR + "p55/cop_riot_armed_walk.png"
	assert_almost_eq(StreetCopWalk.fill_of(riot55), 1.09, 0.001, "per pitch")
