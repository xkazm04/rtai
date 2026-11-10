extends GutTest
## n13 item 3: the plasma rifle's burst is sized by its gun_fx.json row (a small core and a thin
## ring, so the struck body reads through the held frames); a row without the keys keeps the
## approved n7 burst (the ray gun, the homing shard, and the plasma rifle's before).


func _old(age: int) -> Vector4:  # the n7 burst, as GunFxMarks.pop drew it before n13
	var k: float = float(age + 1) / float(GunFx.IMPACT_TICKS)
	var core: float = 0.22 * Ink.PX_PER_M if age < 4 else 0.0
	return Vector4(
		(0.2 + 0.6 * k) * Ink.PX_PER_M, 10.0 * (1.0 - k) + 2.0, 5.0 * (1.0 - k) + 1.0, core
	)


func test_a_row_without_keys_draws_the_approved_burst() -> void:
	for age: int in GunFx.IMPACT_TICKS:
		assert_eq(GunFxMarks.pop_shape(age, {}), _old(age), "age %d" % age)


func test_the_other_scorch_guns_keep_the_approved_burst() -> void:
	var fx: GunFx = GunFx.new()
	for id: StringName in [&"ray_gun", &"homing_shard"]:
		var row: Dictionary = fx.look(id)
		var bursts: bool = row.get("scorch", false)
		assert_true(bursts, "%s bursts" % id)
		for age: int in GunFx.IMPACT_TICKS:
			assert_eq(GunFxMarks.pop_shape(age, row), _old(age))


func test_the_plasma_rifle_burst_is_small() -> void:
	var row: Dictionary = GunFx.new().look(&"plasma_rifle")
	var shipped: Vector4 = GunFxMarks.pop_shape(0, row)
	assert_almost_eq(shipped.w, 0.08 * Ink.PX_PER_M, 1e-3, "a small hot core")
	assert_lt(shipped.w, _old(0).w * 0.5)
	assert_lt(shipped.x, _old(0).x, "the ring opens tighter")
	assert_lt(shipped.y, _old(0).y, "a thinner ink ring")
	assert_lt(shipped.z, _old(0).z, "a thinner cream ring")
	assert_almost_eq(GunFxMarks.pop_shape(GunFx.IMPACT_TICKS - 1, row).x, 0.8 * Ink.PX_PER_M, 1e-3)


func test_the_core_goes_after_four_ticks_and_a_zero_core_draws_none() -> void:
	var row: Dictionary = GunFx.new().look(&"plasma_rifle")
	assert_gt(GunFxMarks.pop_shape(3, row).w, 0.0)
	assert_eq(GunFxMarks.pop_shape(4, row).w, 0.0)
	assert_eq(GunFxMarks.pop_shape(0, {"pop_core_m": 0.0}).w, 0.0)
	assert_eq(GunFxMarks.pop_shape(0, {"pop_core_m": -1.0}).w, 0.0)


func test_the_ring_starts_at_from_m() -> void:
	var sh: Vector4 = GunFxMarks.pop_shape(-1, {"pop_from_m": 0.35})
	assert_almost_eq(sh.x, 0.35 * Ink.PX_PER_M, 1e-3)
	assert_almost_eq(sh.y, 12.0, 1e-4)
	assert_almost_eq(sh.z, 6.0, 1e-4)
