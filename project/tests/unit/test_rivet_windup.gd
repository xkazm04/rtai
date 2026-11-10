extends GutTest
## n13 item 4: a blade with a wind-up strip draws it through the strike's wind-up ticks (view only).
## The p70 strips ship for the plasma sword, katana and baton (the asset lane's drawn cells,
## tools/art/rivet_windup_cells.py); the path tests stub the file cache, not depending on them.

const EQ: String = "res://features/characters/art/view/p70/rivet_eq_plasma_sword.png"
const WU: String = "res://features/characters/art/view/p70/rivet_eq_plasma_sword_windup.png"


func before_each() -> void:
	RivetStrips._exists[WU] = true


func after_each() -> void:
	RivetWindup.enabled = true
	@warning_ignore("return_value_discarded")
	RivetStrips._exists.erase(WU)


func _rig(strike_t: float, windup_s: float = 4.0 / 60.0) -> CutRig:
	var rig: CutRig = CutRig.new()
	autofree(rig)
	rig.clips.strike_t = strike_t
	rig.clips.strike_ph = Vector3(windup_s, 3.0 / 60.0, 8.0 / 60.0)
	return rig


func test_the_wind_up_ticks_draw_the_wind_up_strip() -> void:
	assert_eq(RivetWindup.path_or(_rig(0.0), "p70", &"plasma_sword", EQ), WU, "first tick")
	assert_eq(RivetWindup.path_or(_rig(3.0 / 60.0), "p70", &"plasma_sword", EQ), WU)


func test_no_strike_and_the_active_ticks_keep_the_strip() -> void:
	assert_eq(RivetWindup.path_or(_rig(-1.0), "p70", &"plasma_sword", EQ), EQ, "no strike")
	assert_eq(RivetWindup.path_or(_rig(4.5 / 60.0), "p70", &"plasma_sword", EQ), EQ, "active")
	assert_eq(RivetWindup.path_or(_rig(0.0, 0.0), "p70", &"plasma_sword", EQ), EQ, "no wind-up")


func test_only_the_equipped_strip_and_a_weapon_with_a_cut_swap() -> void:
	var walk: String = "res://features/characters/art/view/p70/rivet_walk_armed_plasma_sword.png"
	assert_eq(RivetWindup.path_or(_rig(0.0), "p70", &"plasma_sword", walk), walk, "a walk grid")
	var pistol: String = "res://features/characters/art/view/p70/rivet_eq_pistol.png"
	assert_eq(RivetWindup.path_or(_rig(0.0), "p70", &"pistol", pistol), pistol, "no cut")
	assert_eq(RivetWindup.path_or(_rig(0.0), "p70", &"", EQ), EQ, "no weapon")


func test_the_flag_turns_it_off() -> void:
	RivetWindup.enabled = false
	assert_eq(RivetWindup.path_or(_rig(0.0), "p70", &"plasma_sword", EQ), EQ)


func test_the_strip_is_two_cells_on_the_equipped_pad() -> void:
	assert_eq(RivetStrips.cells_of(WU, false), RivetWindup.CELLS)
	assert_eq(RivetStrips.foot_px(WU), RivetStrips.foot_px(EQ))


func test_without_a_cut_nothing_changes() -> void:
	@warning_ignore("return_value_discarded")
	RivetStrips._exists.erase(WU)
	RivetStrips._exists[WU] = false
	assert_eq(RivetWindup.path_or(_rig(0.0), "p70", &"plasma_sword", EQ), EQ)
	assert_false(RivetStripWarm.paths("p70", [&"plasma_sword"]).has(WU), "nothing to warm")


func test_the_three_blades_ship_a_p70_strip_wide_and_tall_enough() -> void:
	for w: String in ["plasma_sword", "katana", "electro_baton"]:
		var dir: String = RivetStrips.DIR + "p70/rivet_eq_" + w
		var eq: Texture2D = load(dir + ".png") as Texture2D
		var wu: Texture2D = load(dir + RivetWindup.FILE) as Texture2D
		assert_not_null(wu, w)
		# compared in 110 space: n11 re-cut some equipped strips at x1.5 (RivetRes.X15)
		var k: float = RivetRes.of(dir + ".png") / RivetRes.of(dir + RivetWindup.FILE)
		var eq_w: float = eq.get_width() / 8.0 / k
		assert_gte(wu.get_width() / float(RivetWindup.CELLS), eq_w, w + ": the cell width")
		assert_gte(float(wu.get_height()), eq.get_height() / k, w + ": room for the raised weapon")
		assert_true(RivetStripWarm.paths("p70", [StringName(w)]).has(dir + RivetWindup.FILE))


func test_the_cells_by_octant() -> void:
	assert_eq(RivetWindup.small_of(2, RivetWindup.CELLS), Vector2i(RivetWindup.CAM, 0))
	for o: int in [0, 1, 7, 6]:
		assert_eq(RivetWindup.small_of(o, RivetWindup.CELLS), Vector2i(RivetWindup.SIDE, 0))
	for o: int in [3, 4, 5]:
		assert_eq(RivetWindup.small_of(o, RivetWindup.CELLS), Vector2i(RivetWindup.SIDE, 1))
	assert_eq(RivetWindup.small_of(1, RivetStrips.DIAG_CELLS), Vector2i(0, 0), "the diag strip")


func test_the_warm_lists_it() -> void:
	var paths: PackedStringArray = RivetStripWarm.paths("p70", [&"plasma_sword"])
	assert_true(paths.has(WU))


func test_a_left_strip_takes_the_left_wind_up() -> void:
	var dir: String = RivetStrips.DIR + "p70/rivet_eq_electro_baton"
	var left: String = dir + "_left.png"
	var lw: String = dir + RivetWindup.LEFT_FILE
	RivetStrips._exists[lw] = true
	assert_eq(RivetWindup.path_or(_rig(0.0), "p70", &"electro_baton", left), lw, "winding")
	assert_eq(RivetWindup.path_or(_rig(-1.0), "p70", &"electro_baton", left), left, "no strike")
	assert_eq(RivetWindup.path_or(_rig(4.5 / 60.0), "p70", &"electro_baton", left), left, "active")
	var other: String = RivetStrips.DIR + "p70/rivet_eq_pistol_left.png"
	assert_eq(RivetWindup.path_or(_rig(0.0), "p70", &"electro_baton", other), other, "not his")
	RivetWindup.enabled = false
	assert_eq(RivetWindup.path_or(_rig(0.0), "p70", &"electro_baton", left), left, "the flag")
	RivetStrips._exists[lw] = false
	RivetWindup.enabled = true
	assert_eq(RivetWindup.path_or(_rig(0.0), "p70", &"electro_baton", left), left, "no cut")
	@warning_ignore("return_value_discarded")
	RivetStrips._exists.erase(lw)


func test_the_left_wind_up_is_one_unmirrored_cell() -> void:
	var lw: String = RivetStrips.DIR + "p70/rivet_eq_electro_baton" + RivetWindup.LEFT_FILE
	assert_eq(RivetStrips.cells_of(lw, false), RivetWindup.LEFT_CELLS)
	assert_eq(RivetStrips.cells_of(WU, false), RivetWindup.CELLS, "the two-cell strip")
	for o: int in [3, 4, 5]:
		assert_eq(RivetWindup.small_of(o, RivetWindup.LEFT_CELLS), Vector2i(RivetWindup.SIDE, 0))
	assert_eq(RivetStrips.foot_px(lw), RivetFrames.PAD_PX, "the baton is raised: the plain pad")


func test_the_n14_strips_ship_and_are_warmed() -> void:
	var ship: Dictionary[String, Array] = {
		"p55": ["plasma_sword", "katana", "electro_baton", "chainsaw"], "p70": ["chainsaw"]
	}
	for art: String in ship:
		for w: String in ship[art]:
			var dir: String = RivetStrips.DIR + art + "/rivet_eq_" + w
			var eq: Texture2D = load(dir + ".png") as Texture2D
			var wu: Texture2D = load(dir + RivetWindup.FILE) as Texture2D
			assert_not_null(wu, art + " " + w)
			var k: float = RivetRes.of(dir + ".png") / RivetRes.of(dir + RivetWindup.FILE)
			assert_gte(wu.get_width() / float(RivetWindup.CELLS), eq.get_width() / 8.0 / k, w)
			assert_true(RivetStripWarm.paths(art, [StringName(w)]).has(dir + RivetWindup.FILE))
	for art: String in ["p70", "p55"]:
		var lw: String = RivetStrips.DIR + art + "/rivet_eq_electro_baton" + RivetWindup.LEFT_FILE
		assert_not_null(load(lw), art + " left")
		assert_true(RivetStripWarm.paths(art, [&"electro_baton"]).has(lw), art + " left warmed")


func test_the_p70_chainsaw_wind_up_is_cut_at_its_strip_res() -> void:
	var dir: String = RivetStrips.DIR + "p70/rivet_eq_chainsaw"
	assert_eq(RivetRes.of(dir + RivetWindup.FILE), RivetRes.of(dir + ".png"))
	assert_eq(RivetRes.of(dir + RivetWindup.FILE), RivetWalk.RES)
