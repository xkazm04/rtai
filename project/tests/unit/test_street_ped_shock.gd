extends GutTest
## The landed weapon, the sustained area state and the return to walking use the live card lookup.

const ROWS: Dictionary[String, String] = {
	"ped/head_hat": "ped_hat",
	"ped/head_bald": "ped_elder",
	"ped/head_shopper": "ped_shopper",
}


func _ped(row: String) -> CutRig:
	var rig: CutRig = autofree(CutRig.new())
	rig.plan = HumanPlan.ped()
	rig.head_card = Sprite2D.new()
	rig.add_child(rig.head_card)
	rig.head_card.set_meta(&"street_row", row)
	return rig


func _wound(rig: CutRig, hit: StringName, weapon: StringName) -> void:
	var pipe: DeathPipe = DeathPipe.make(ReactTable.shipped())
	var family: StringName = pipe.wound(rig, hit, Vector2.RIGHT, false, false)
	rig.react.blow = StreetHitClass.blow_of(hit, weapon, family)


func test_the_three_looks_keep_their_own_shock_after_the_jab_and_heavy_would_end() -> void:
	for row: String in ROWS:
		var rig: CutRig = _ped(row)
		_wound(rig, &"melee", &"claw")
		assert_eq(StreetWalkerCards.strip_of(rig).get_file(), ROWS[row] + "_jab_hit.png")
		_wound(rig, &"melee", &"katana")
		assert_eq(StreetWalkerCards.strip_of(rig).get_file(), ROWS[row] + "_heavy_hit.png")
		_wound(rig, &"shock", &"electro_gun")
		var shock: String = ROWS[row] + "_shock_hit.png"
		assert_eq(StreetWalkerCards.strip_of(rig).get_file(), shock)
		rig.react.t = 0.65
		assert_eq(StreetWalkerCards.strip_of(rig).get_file(), shock, row + " during stun")
		rig.react.t = 0.86 * rig.react.length
		assert_eq(StreetWalkerCards.strip_of(rig).get_file(), ROWS[row] + "_between_fall.png")
		rig.react.clear()
		assert_eq(StreetWalkerHit.grid_of(rig, row), "", row + " after release")


func test_a_rig_reentering_a_held_stun_resolves_its_wardrobe_without_the_first_hit() -> void:
	for row: String in ROWS:
		var rig: CutRig = _ped(row)
		HumanReact.on(rig).play(rig, &"stun", Vector2.UP, ReactTable.shipped())
		assert_eq(StreetWalkerCards.strip_of(rig).get_file(), ROWS[row] + "_shock_hit.png")


func test_the_worker_and_a_lethal_shock_keep_their_existing_families() -> void:
	var rig: CutRig = _ped("ped/head_worker")
	_wound(rig, &"shock", &"electro_gun")
	rig.react.t = 0.65
	assert_eq(StreetWalkerHit.grid_of(rig, "ped/head_worker"), "")
	rig.react.play(rig, &"death_shock", Vector2.RIGHT, ReactTable.shipped())
	for row: String in ROWS:
		assert_false(StreetPedShock.active(rig.react, row))
		assert_false(StreetPedShock.active(null, row))


func test_the_baton_can_release_on_its_melee_clock() -> void:
	var rig: CutRig = _ped("ped/head_hat")
	_wound(rig, &"melee", &"electro_baton")
	assert_eq(rig.react.kind, &"fold")
	assert_eq(StreetWalkerCards.strip_of(rig).get_file(), "ped_hat_shock_hit.png")
	rig.react.t = 0.85 * rig.react.length
	assert_eq(StreetWalkerCards.strip_of(rig).get_file(), "ped_hat_between_fall.png")


func test_the_release_catches_kneels_then_stands_on_the_same_point_and_heading() -> void:
	var rig: CutRig = _ped("ped/head_shopper")
	_wound(rig, &"shock", &"electro_gun")
	rig.position = Vector2(16, 31)
	rig.facing = PI * 0.25
	var c: Sprite2D = rig.head_card
	var path: String = StreetWalkerCards.DIR + "p70/ped_shopper_between_fall.png"
	c.texture = load(path)
	c.hframes = RigHeadCard.FRAMES
	c.vframes = StreetFallBetween.FRAMES
	c.set_meta(StreetWalkerCards.ON, path)
	rig.react.length = 1.0
	var beats: Array[float] = [0.76, 0.83, 0.90, 0.97]
	var frames: Array[int] = [1, 2, 1, 0]
	for i: int in beats.size():
		rig.react.t = beats[i]
		c.transform = Transform2D(1.1, Vector2(3, 2), 0.0, Vector2(10, 20))
		StreetView.post(rig)
		assert_eq(c.frame_coords, Vector2i(3, frames[i]))
		assert_true(c.flip_h, "the figure still faces the attacker to its northwest")
		assert_almost_eq(c.global_position, rig.global_position, Vector2.ONE * 0.0001)
		assert_almost_eq(c.global_rotation, 0.0, 0.0001)
		var size: float = 1.0 + StreetCrowdCards.SCALE_VAR * StreetCrowdCards.vary(rig.actor_id, 3)
		var scale_at_walk: float = StreetWalkerCards.HEIGHT_M * CharacterRigs.PX_PER_M * size
		var expected: float = scale_at_walk * StreetFallFit.k(c) / StreetWalkerFall.STILL_PX
		assert_almost_eq(c.global_scale, Vector2.ONE * expected, Vector2.ONE * 0.0001)


func test_the_parts_arch_and_jolt_then_bend_the_knees_for_the_same_three_wardrobes() -> void:
	var saved: ViewMode = ViewMode._shared
	ViewMode.select("top")
	# The real wardrobe pools pick elder and shopper for these actor ids.
	for cast: Vector2i in [Vector2i(1, 0), Vector2i(2, 7), Vector2i(4, 4)]:
		var rig: CutRig = autofree(CutRig.new())
		rig.actor_id = cast.x
		rig.variant = RigVariant.crowd(cast.y)
		_wound(rig, &"shock", &"electro_gun")
		rig.react.t = 0.35
		ReactPose.pre(rig.react, rig)
		assert_lt(rig.c_lean, 0.0, "back arched")
		assert_ne(rig.react.off, Vector2.ZERO, "current through the body")
		rig.react.t = 0.86 * rig.react.length
		ReactPose.pre(rig.react, rig)
		assert_almost_eq(rig.c_tuck, StreetPedShock.KNEE_TUCK, 0.0001)
		assert_almost_eq(rig.c_reach, StreetPedShock.BRACE_REACH, 0.0001)
		rig.react.t = 0.995 * rig.react.length
		ReactPose.pre(rig.react, rig)
		assert_eq(rig.c_tuck, 0.0)
	ViewMode._shared = saved


func test_the_short_fall_sheet_stays_off_its_prone_frame() -> void:
	var rig: CutRig = _ped("ped/head_hat")
	_wound(rig, &"shock", &"electro_gun")
	rig.react.t = 0.86 * rig.react.length
	var c: Sprite2D = rig.head_card
	c.texture = load(StreetWalkerCards.DIR + "p70/ped_hat_long_fall.png")
	c.hframes = RigHeadCard.FRAMES
	c.vframes = StreetWalkerFall.FALL_FRAMES
	StreetPedShock.place(rig, c)
	assert_eq(c.frame_coords.y, 1, "buckle while living")
