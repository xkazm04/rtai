extends GutTest
## n15 combat item 3: past the wind-up a one-handed weapon's left strip swaps to its drawn
## left strike (rivet_eq_<weapon>_left_strike.png, one unmirrored cell); the baton's ships at
## p70 and p55.

const DIR: String = "res://features/characters/art/view/p70/rivet_eq_electro_baton"
const LEFT: String = DIR + "_left.png"
const LS: String = DIR + RivetWindup.LEFT_STRIKE_FILE
const LW: String = DIR + RivetWindup.LEFT_FILE


func before_each() -> void:
	RivetStrips._exists[LS] = true
	RivetStrips._exists[LW] = true


func after_each() -> void:
	RivetWindup.enabled = true
	RivetWindup.left_strike = true
	for p: String in [LS, LW]:
		@warning_ignore("return_value_discarded")
		RivetStrips._exists.erase(p)


func _rig(strike_t: float) -> CutRig:
	var rig: CutRig = CutRig.new()
	autofree(rig)
	rig.clips.strike_t = strike_t
	rig.clips.strike_ph = Vector3(4.0 / 60.0, 3.0 / 60.0, 8.0 / 60.0)
	return rig


func test_the_strike_and_recovery_draw_the_left_strike() -> void:
	var first: CutRig = _rig(4.5 / 60.0)
	assert_eq(RivetWindup.path_or(first, "p70", &"electro_baton", LEFT), LS, "strike")
	assert_eq(RivetWindup.path_or(_rig(10.0 / 60.0), "p70", &"electro_baton", LEFT), LS, "recovery")


func test_the_wind_up_and_no_strike_keep_their_cells() -> void:
	assert_eq(RivetWindup.path_or(_rig(3.0 / 60.0), "p70", &"electro_baton", LEFT), LW, "wind-up")
	assert_eq(RivetWindup.path_or(_rig(-1.0), "p70", &"electro_baton", LEFT), LEFT, "no strike")


func test_only_the_left_strip_swaps() -> void:
	var eq: String = DIR + ".png"
	assert_eq(RivetWindup.path_or(_rig(5.0 / 60.0), "p70", &"electro_baton", eq), eq, "right")
	var other: String = RivetStrips.DIR + "p70/rivet_eq_pistol_left.png"
	assert_eq(RivetWindup.path_or(_rig(5.0 / 60.0), "p70", &"electro_baton", other), other)


func test_the_flags_and_a_missing_cut_keep_the_left_facing() -> void:
	RivetWindup.left_strike = false
	assert_eq(RivetWindup.path_or(_rig(5.0 / 60.0), "p70", &"electro_baton", LEFT), LEFT, "flag")
	RivetWindup.left_strike = true
	RivetWindup.enabled = false
	assert_eq(RivetWindup.path_or(_rig(5.0 / 60.0), "p70", &"electro_baton", LEFT), LEFT, "off")
	RivetWindup.enabled = true
	RivetStrips._exists[LS] = false
	assert_eq(RivetWindup.path_or(_rig(5.0 / 60.0), "p70", &"electro_baton", LEFT), LEFT, "no cut")


func test_it_is_one_unmirrored_cell_on_the_plain_pad() -> void:
	assert_eq(RivetStrips.cells_of(LS, false), RivetWindup.LEFT_CELLS)
	assert_eq(
		RivetWindup.small_of(4, RivetStrips.cells_of(LS, false)), Vector2i(RivetWindup.SIDE, 0)
	)
	assert_eq(RivetStrips.foot_px(LS), RivetFrames.PAD_PX)


func test_the_baton_ships_it_at_both_art_keys_and_warms_it() -> void:
	for art: String in ["p70", "p55"]:
		var ls: String = (
			RivetStrips.DIR + art + "/rivet_eq_electro_baton" + RivetWindup.LEFT_STRIKE_FILE
		)
		var tex: Texture2D = load(ls) as Texture2D
		assert_not_null(tex, art)
		var left: Texture2D = load(RivetStrips.DIR + art + "/rivet_eq_electro_baton_left.png")
		assert_gte(tex.get_width(), left.get_width() / 3, art + ": at least the left cell's width")
		assert_true(RivetStripWarm.paths(art, [&"electro_baton"]).has(ls), art + " warmed")
