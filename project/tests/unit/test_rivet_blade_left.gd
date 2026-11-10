extends GutTest
## n15 combat item 3 (the n14 owner's open call): the katana, plasma sword and chainsaw turned left
## take their drawn left set (strip, wind-up, strike) as a one-handed hold does; the drawn left
## strike only where the blade's strike is drawn (straight left), the left facing under the game's
## arc on the left diagonals; --rivet-blade-left=off = the mirrored right strip (the before).

const BLADES: Array[StringName] = [&"katana", &"plasma_sword", &"chainsaw"]


func after_each() -> void:
	RivetWindup.blade_left = true


func _rig(strike_t: float, o: int) -> CutRig:
	var rig: CutRig = CutRig.new()
	autofree(rig)
	rig.face_to = o * PI / 4.0
	rig.clips.strike_t = strike_t
	rig.clips.strike_ph = Vector3(4.0 / 60.0, 3.0 / 60.0, 8.0 / 60.0)
	return rig


func test_the_blades_turned_left_draw_their_left_strip_unless_the_flag_is_off() -> void:
	for w: StringName in BLADES:
		assert_true(RivetWindup.left_drawn(w), String(w))
	assert_true(RivetWindup.left_drawn(&"pistol"), "a one-hand hold keeps its left strip")
	assert_false(RivetWindup.left_drawn(&"gatling"))
	RivetWindup.blade_left = false
	assert_false(RivetWindup.left_drawn(&"katana"), "the before: mirrored")
	assert_true(RivetWindup.left_drawn(&"electro_baton"), "the flag leaves one-hand holds")


func test_every_blade_ships_its_left_set_at_both_pitches_and_warms_it() -> void:
	for art: String in ["p70", "p55"]:
		for w: StringName in BLADES:
			var eq: String = RivetStrips.DIR + art + "/rivet_eq_" + String(w)
			assert_eq(RivetStrips.left_of(art, w), eq + "_left.png", art + " " + String(w))
			for file: String in ["_left.png", RivetWindup.LEFT_FILE, RivetWindup.LEFT_STRIKE_FILE]:
				var tex: Texture2D = load(eq + file) as Texture2D
				assert_not_null(tex, eq + file)
				assert_true(RivetStripWarm.paths(art, [w]).has(eq + file), eq + file + " warmed")


func test_the_x15_blades_cut_their_left_set_at_the_strips_res() -> void:
	for w: String in ["katana", "chainsaw"]:
		var eq: String = RivetStrips.DIR + "p70/rivet_eq_" + w
		for file: String in ["_left.png", RivetWindup.LEFT_FILE, RivetWindup.LEFT_STRIKE_FILE]:
			assert_eq(RivetRes.of(eq + file), RivetRes.of(eq + ".png"), w + file)


func test_the_left_strike_shows_straight_left_only() -> void:
	var eq: String = RivetStrips.DIR + "p70/rivet_eq_katana"
	var left: String = eq + "_left.png"
	var ls: String = eq + RivetWindup.LEFT_STRIKE_FILE
	assert_eq(RivetWindup.path_or(_rig(5.0 / 60.0, 4), "p70", &"katana", left), ls, "left")
	for o: int in [3, 5]:
		assert_eq(RivetWindup.path_or(_rig(5.0 / 60.0, o), "p70", &"katana", left), left, str(o))
	var lw: String = eq + RivetWindup.LEFT_FILE
	assert_eq(RivetWindup.path_or(_rig(2.0 / 60.0, 3), "p70", &"katana", left), lw, "wind-up")
