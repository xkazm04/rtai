extends GutTest
## d9 rivet: the strip pick (base, equipped, drawn left) and the hand rule's fallback.

const P70: String = "res://features/characters/art/view/p70/"
const P55: String = "res://features/characters/art/view/p55/"


func test_top_has_no_strip() -> void:
	assert_eq(RivetStrips.strip_of("", &"pistol"), "")


func test_a_weapon_out_takes_its_equipped_strip() -> void:
	assert_eq(RivetStrips.strip_of("p70", &"pistol"), P70 + "rivet_eq_pistol.png")
	assert_eq(RivetStrips.strip_of("p55", &"katana"), P55 + "rivet_eq_katana.png")
	assert_eq(RivetStrips.strip_of("p70", &""), P70 + RivetStrips.BASE)


func test_every_one_handed_hold_has_a_drawn_left_strip_at_both_pitches() -> void:
	for art: String in ["p70", "p55"]:
		for w: StringName in RivetStrips.ONE_HAND:
			var path: String = RivetStrips.left_of(art, w)
			assert_eq(path, RivetStrips.DIR + art + "/rivet_eq_%s_left.png" % w)
			var tex: Texture2D = load(path) as Texture2D
			assert_eq(tex.get_width() % RivetFrames.LEFT_CELLS, 0, String(w))


func test_without_a_left_strip_the_base_figure_draws() -> void:
	assert_eq(RivetStrips.left_of("p55", &"katana"), P55 + RivetStrips.BASE)


func test_the_flamer_fires_its_drawn_flame_only_along_side_and_camera() -> void:
	for o: int in 8:
		assert_eq(RivetStrips.fires_drawn(&"flamethrower", o), o in [0, 2, 4], "octant %d" % o)
		assert_true(RivetStrips.fires_drawn(&"pistol", o), "pistol octant %d" % o)


func test_the_flamer_drawn_flame_needs_the_aim_along_it() -> void:
	# d9 it16: the head read octant 4 (screen left) while the jet left at ~124 deg (down-left).
	assert_false(RivetStrips.fires_drawn(&"flamethrower", 4, deg_to_rad(124.0)))
	assert_true(RivetStrips.fires_drawn(&"flamethrower", 4, deg_to_rad(170.0)))
	assert_true(RivetStrips.fires_drawn(&"flamethrower", 0, deg_to_rad(-15.0)))
	assert_false(RivetStrips.fires_drawn(&"flamethrower", 2, deg_to_rad(50.0)))
	assert_true(RivetStrips.fires_drawn(&"pistol", 4, deg_to_rad(124.0)))


func test_the_flamer_facings_carry_the_nozzle_at_both_pitches() -> void:
	for art: String in ["p70", "p55"]:
		var path: String = RivetStrips.DIR + art + "/rivet_eq_flamethrower.png"
		for cell: int in 5:
			assert_gt(RivetMuzzle.point(path, cell).x, 0.0, "%s cell %d" % [art, cell])


func test_a_cone_burst_that_went_off_its_drawn_flame_keeps_the_facing_cell() -> void:
	# d9 it16: the stream stopped (t367), the fire latch held 3 more frames while the aim swung
	# into screen left: a drawn flame with no jet. The burst keeps its facing cell to the end.
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.aiming = true
	rig.aim_at = Vector2(-100.0, 150.0)  # ~124 deg: off the left octant's drawn flame
	assert_false(RivetStrips.draws_fire(rig, &"flamethrower", 4, true))
	rig.aim_at = Vector2(-100.0, 0.0)  # swung onto screen left, latch still up
	assert_false(RivetStrips.draws_fire(rig, &"flamethrower", 4, true))
	assert_false(RivetStrips.draws_fire(rig, &"flamethrower", 4, false))  # the latch clears
	assert_true(RivetStrips.draws_fire(rig, &"flamethrower", 4, true))  # a new burst on the flame
	assert_true(RivetStrips.draws_fire(rig, &"pistol", 3, true))


func test_a_strip_with_no_drawn_arc_keeps_the_held_part_posing_for_the_smear() -> void:
	# d9 it20: the baton's strike cells at p55 (v3) draw no swing arc, so the game's smear sweeps
	# the cut from the hidden held part; the katana's sheet draws its own arc, and so does the
	# p70 baton since it21 (v5).
	var saved: ViewMode = ViewMode._shared
	ViewMode._shared = ViewMode.of("tilt")
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.head_card = autofree(Sprite2D.new())
	rig.head_card.hframes = RivetFrames.EQ_CELLS
	rig.head_card.set_meta(RivetFrames.ON, P55 + "rivet_eq_electro_baton.png")
	rig.gun_out = true
	rig.set_meta(RivetFrames.WEAPON, &"electro_baton")
	var art: String = ViewMode._shared.art
	assert_false(RivetStrips.hides_held(rig), "baton at " + art)
	rig.set_meta(RivetFrames.WEAPON, &"katana")
	assert_true(RivetStrips.hides_held(rig), "katana at " + art)
	rig.head_card.hframes = RivetFrames.BASE_CELLS  # the bare-claw strip carries no weapon
	assert_false(RivetStrips.hides_held(rig))
	ViewMode._shared = ViewMode.of("tilt70")  # the p70 baton v5 draws its own arc
	rig.head_card.hframes = RivetFrames.EQ_CELLS
	rig.head_card.set_meta(RivetFrames.ON, P70 + "rivet_eq_electro_baton.png")
	rig.set_meta(RivetFrames.WEAPON, &"electro_baton")
	assert_true(RivetStrips.hides_held(rig), "baton at p70 (v5 draws its arc)")
	ViewMode._shared = saved


func test_every_no_arc_strip_has_its_strike_tip_measured() -> void:
	# The smear's reach under the drawn figure (RivetMuzzle.smear_root): the side strike cell's tip.
	for art: String in RivetStrips.NO_ARC:
		for w: StringName in RivetStrips.NO_ARC[art]:
			var eq: String = RivetStrips.strip_of(art, w)
			var tip: Vector2 = RivetMuzzle.point(eq, RivetFrames.Eq.FIRE_SIDE)
			assert_gt(tip.x, 0.0, "%s %s" % [art, w])
