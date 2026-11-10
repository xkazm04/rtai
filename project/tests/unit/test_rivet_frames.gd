extends GutTest
## d9 rivet: the strip pick (base, equipped, drawn left) and the hand rule's fallback.

const P70: String = "res://features/characters/art/view/p70/"
const P55: String = "res://features/characters/art/view/p55/"


func after_each() -> void:
	RivetStrips.cone = []
	RivetStrips.flame_all = false


## A drawn p70 Rivet standing with the pistol at octant `o` (aim along it), posed once.
func _drawn_rig(o: int) -> CutRig:
	var rig: CutRig = add_child_autofree(CutRig.new())
	rig.plan = RivetPlan.build()
	for n: StringName in [&"head", &"body"]:
		var node: Node2D = Node2D.new()
		rig.add_child(node)
		rig.set(n, node)
	var card: Sprite2D = Sprite2D.new()
	rig.head.add_child(card)
	rig.head_card = card
	rig.head.rotation = o * PI * 0.25
	rig.face_to = o * PI * 0.25
	rig.gun_out = true
	rig.aiming = true
	rig.aim_at = rig.global_position + Vector2.from_angle(o * PI * 0.25) * 128.0
	rig.set_meta(RivetFrames.WEAPON, &"pistol")
	RivetFrames.step(rig)
	return rig


func test_the_shots_own_frame_takes_the_fire_cell() -> void:
	# n10: the pose ran before publish raised the fire latch, so the first frame of every shot kept
	# the facing cell, no muzzle point, and the flash drew at the fallback spot beside him
	var was: ViewMode = ViewMode._shared
	ViewMode._shared = ViewMode.of("tilt70")
	var rig: CutRig = _drawn_rig(0)
	assert_ne(rig.head_card.frame, RivetFrames.Eq.FIRE_SIDE, "no shot yet: the facing cell")
	var reg: RngRegistry = RngRegistry.new(1)
	var gun: GunHand = GunHand.make(WeaponTable.shipped(), &"pistol", reg.stream(&"gunplay"))
	gun.trigger.cooldown = gun.trigger.spec.interval_ticks  # the tick the shot left
	RivetFrames.publish(rig, &"pistol", gun)
	assert_eq(rig.head_card.frame, RivetFrames.Eq.FIRE_SIDE, "the shot's own frame")
	assert_true(HeldMuzzle.fresh(), "the drawn muzzle is published on that frame")
	HeldMuzzle.reset()
	ViewMode._shared = was


func test_a_burst_on_the_tolerance_edge_keeps_its_fire_cell() -> void:
	# n10: a 45 deg shot sat on GUN_TOL; float noise dropped the cell one tick into the latch
	var rig: CutRig = add_child_autofree(CutRig.new())
	var aim: Callable = func(deg: float) -> void:
		rig.aim_at = rig.global_position + Vector2.from_angle(deg_to_rad(deg)) * 128.0
	rig.aiming = true
	aim.call(44.9)
	assert_true(RivetStrips.draws_fire(rig, &"pistol", 1, true), "on the cell")
	aim.call(45.3)
	assert_true(RivetStrips.draws_fire(rig, &"pistol", 1, true), "noise past the edge holds it")
	aim.call(60.0)
	assert_false(RivetStrips.draws_fire(rig, &"pistol", 1, true), "the aim really left")
	aim.call(44.0)
	assert_false(RivetStrips.draws_fire(rig, &"pistol", 1, true), "off stays off to the burst end")
	assert_false(RivetStrips.draws_fire(rig, &"pistol", 1, false), "the latch clears")
	assert_true(RivetStrips.draws_fire(rig, &"pistol", 1, true), "the next burst decides afresh")


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
	assert_eq(RivetStrips.left_of("p55", &"gatling"), P55 + RivetStrips.BASE)


func test_the_flamer_fires_its_drawn_flame_in_every_direction() -> void:
	# n9: the owner's r-7 B (cone empty): the drawn flame cell wherever one is drawn along the aim
	assert_true(RivetStrips.cone.is_empty())
	for art: String in ["p70", "p55"]:
		var key: String = art + "/flamethrower"
		var deg: PackedFloat32Array = RivetStrips.FLAME_DEG.get(key, PackedFloat32Array())
		assert_eq(deg.size(), 8, key)
		for o: int in deg.size():
			var along: float = deg_to_rad(deg[o] + 20.0)
			assert_true(RivetStrips.fires_drawn(&"flamethrower", o, along, art), "%s %d" % [art, o])
		assert_true(RivetStrips.fires_drawn(&"flamethrower", 7, deg_to_rad(-40.0), art))


func test_a_flame_burst_off_its_drawn_flame_keeps_the_facing_cell() -> void:
	# n9 it10: aimed straight up (octant 6) the side cell drew its flame sideways under an up jet
	for art: String in ["p70", "p55"]:
		assert_false(RivetStrips.fires_drawn(&"flamethrower", 6, deg_to_rad(-85.0), art), art)
		assert_false(RivetStrips.fires_drawn(&"flamethrower", 7, deg_to_rad(-64.0), art), art)
		assert_false(
			RivetStrips.fires_drawn(&"pistol", 6, deg_to_rad(-85.0), art), "a gun aimed up"
		)
		assert_true(RivetStrips.fires_drawn(&"pistol", 0, deg_to_rad(-30.0), art), "a gun along")
		assert_true(
			RivetStrips.fires_drawn(&"pistol", 2, deg_to_rad(100.0), art), "a gun at the camera"
		)
		assert_true(RivetStrips.fires_drawn(&"pistol", 4, deg_to_rad(-150.0), art), "a gun left")
		assert_false(
			RivetStrips.fires_drawn(&"pistol", 5, deg_to_rad(-130.0), art), "away diagonal"
		)
	RivetStrips.flame_all = true
	assert_true(RivetStrips.fires_drawn(&"flamethrower", 6, deg_to_rad(-85.0), "p55"), "=all")
	assert_true(RivetStrips.fires_drawn(&"pistol", 6, deg_to_rad(-85.0), "p55"), "=all: a gun")
	RivetStrips.flame_all = false


func test_the_d9_cone_fires_its_drawn_flame_only_along_side_and_camera() -> void:
	RivetStrips.cone = RivetStrips.CONE_D9.duplicate()
	for o: int in 8:
		assert_eq(RivetStrips.fires_drawn(&"flamethrower", o), o in [0, 2, 4], "octant %d" % o)
		assert_true(RivetStrips.fires_drawn(&"pistol", o), "pistol octant %d" % o)


func test_the_flamer_drawn_flame_needs_the_aim_along_it() -> void:
	# d9 it16: the head read octant 4 (screen left) while the jet left at ~124 deg (down-left).
	RivetStrips.cone = RivetStrips.CONE_D9.duplicate()
	assert_false(RivetStrips.fires_drawn(&"flamethrower", 4, deg_to_rad(124.0)))
	assert_true(RivetStrips.fires_drawn(&"flamethrower", 4, deg_to_rad(170.0)))
	assert_true(RivetStrips.fires_drawn(&"flamethrower", 0, deg_to_rad(-15.0)))
	assert_false(RivetStrips.fires_drawn(&"flamethrower", 2, deg_to_rad(50.0)))
	assert_false(RivetStrips.fires_drawn(&"pistol", 4, deg_to_rad(124.0)), "n9 it12: GUN_TOL")
	assert_true(RivetStrips.fires_drawn(&"pistol", 4, deg_to_rad(150.0)))


func test_the_flamer_facings_carry_the_nozzle_at_both_pitches() -> void:
	for art: String in ["p70", "p55"]:
		var path: String = RivetStrips.DIR + art + "/rivet_eq_flamethrower.png"
		for cell: int in 5:
			assert_gt(RivetMuzzle.point(path, cell).x, 0.0, "%s cell %d" % [art, cell])


func test_a_cone_burst_that_went_off_its_drawn_flame_keeps_the_facing_cell() -> void:
	# d9 it16: the stream stopped (t367), the fire latch held 3 more frames while the aim swung
	# into screen left: a drawn flame with no jet. The burst keeps its facing cell to the end.
	RivetStrips.cone = RivetStrips.CONE_D9.duplicate()
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
