extends GutTest
## n31 melee 04e: a light round on a body flicks (GunFxWound), capped per victim; the body hit's
## cream hot point (GunFxMarks.over) is per gun.


func after_each() -> void:
	GunFxWound.use(null)


func test_admit_caps_one_flick_per_victim_per_gap() -> void:
	GunFxWound.use(null)
	assert_true(GunFxWound.admit(7, 100, 6))
	assert_false(GunFxWound.admit(7, 105, 6), "inside the gap")
	assert_true(GunFxWound.admit(8, 105, 6), "another victim has its own clock")
	assert_true(GunFxWound.admit(7, 106, 6), "the gap has run")
	assert_true(GunFxWound.admit(7, 50, 6), "a tick that ran backwards admits")


func test_rows_carry_the_flick_and_the_hot_point() -> void:
	var fx: GunFx = GunFx.new()
	var gap: int = fx.p.get("flick_gap_ticks", 0)
	assert_eq(gap, 6)
	for id: StringName in [&"pistol", &"machine_pistol", &"gloria", &"gatling"]:
		var flicks: bool = fx.look(id).get("flick", false)
		assert_true(flicks, "%s flicks" % id)
	var small: float = fx.look(&"pistol").get("body_hot_m", 0.0)
	var big: float = fx.look(&"gatling").get("body_hot_m", 0.0)
	var gloria: float = fx.look(&"gloria").get("body_hot_m", 0.0)
	assert_gt(small, 0.0)
	assert_gt(big, small)
	assert_gt(gloria, small)


func test_no_blood_no_flick() -> void:
	GunFxWound.use(null)
	assert_eq(GunFxWound.on_round(GunFx.new(), null, null, Vector2.ZERO, Vector2.RIGHT), 0)


func test_gun_flick_row_is_a_few_drops() -> void:
	var blood: BloodFx = BloodFx.new()
	var row: Dictionary = blood.p["hits"][GunFxWound.KIND]
	var drops: int = row["drops"]
	var pool: bool = row["pool"]
	assert_between(drops, 2, 4)
	assert_false(pool)
	blood.free()
