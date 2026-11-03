extends GutTest
## FX cues as data (core/render/fx_triggers.gd) and the sim-snapshot reader that fires them
## (features/city/view/city_fx_feed.gd): shots, projectile ends and deaths are diffed out of
## synthetic snapshots; the shake only kicks near the focus.


func _person(slot: int, mode: int, at: Vector2) -> PackedFloat64Array:
	var r: PackedFloat64Array = PackedFloat64Array()
	@warning_ignore("return_value_discarded")
	r.resize(SimConst.SNAP_STRIDE)
	r[0] = slot
	r[1] = SimConst.K_PED
	r[2] = mode
	r[4] = at.x
	r[5] = at.y
	r[6] = 1.0
	return r


func _proj(k: int, at: Vector2) -> PackedFloat64Array:
	return PackedFloat64Array([SimConst.SNAP_PROJ_BASE + k, at.x, at.y])


func _feed() -> CityFxFeed:
	var t: FxTriggers = FxTriggers.new()
	return CityFxFeed.new(t)


func test_every_cue_names_known_fx_kinds_and_shakes() -> void:
	var t: FxTriggers = FxTriggers.new()
	var fx: FxSystem = autofree(FxSystem.new())
	var rig: CameraRig = CameraRig.new()
	assert_gt(t.rows.size(), 0)
	for id: StringName in t.rows:
		for kind: String in t.rows[id]["fx"]:
			assert_true(fx.kinds.has(StringName(kind)), "%s -> %s" % [id, kind])
		var shake: String = t.rows[id]["shake"]
		assert_true(shake == "" or rig.shakes.has(StringName(shake)), "%s shake" % id)
	for id: StringName in [&"shot", &"projectile_end", &"death", &"player_hit"]:
		assert_true(t.rows.has(id), String(id))


func test_a_new_projectile_is_one_shot_and_its_end_one_impact() -> void:
	var f: CityFxFeed = _feed()
	f.observe(PackedFloat64Array(), 1)
	f.observe(_proj(3, Vector2(10, 10)), 2)
	assert_eq(f.triggers.fired[&"shot"], 0, "the heading is not known yet")
	f.observe(_proj(3, Vector2(10.6, 10)), 3)
	f.observe(_proj(3, Vector2(11.2, 10)), 4)
	assert_eq(f.triggers.fired[&"shot"], 1)
	f.observe(PackedFloat64Array(), 5)
	assert_eq(f.triggers.fired[&"projectile_end"], 1)
	f.observe(PackedFloat64Array(), 6)
	assert_eq(f.triggers.fired[&"projectile_end"], 1)


func test_the_first_observe_only_primes() -> void:
	var f: CityFxFeed = _feed()
	var snap: PackedFloat64Array = _person(5, SimConst.M_DEAD, Vector2(4, 4))
	snap.append_array(_proj(0, Vector2(1, 1)))
	f.observe(snap, 1)
	snap[SimConst.SNAP_STRIDE + 1] = 1.5
	f.observe(snap, 2)
	assert_eq(f.triggers.fired[&"shot"], 0, "already flying at boot")
	assert_eq(f.triggers.fired[&"death"], 0, "already dead at boot")


func test_a_death_fires_once_and_a_refire_is_a_new_shot() -> void:
	var f: CityFxFeed = _feed()
	f.observe(_person(7, 0, Vector2(2, 2)), 1)
	f.observe(_person(7, SimConst.M_DEAD, Vector2(2, 2)), 2)
	f.observe(_person(7, SimConst.M_DEAD, Vector2(2.1, 2)), 3)
	assert_eq(f.triggers.fired[&"death"], 1)
	f.observe(_proj(9, Vector2(0, 0)), 4)
	f.observe(_proj(9, Vector2(0.6, 0)), 5)
	f.observe(_proj(9, Vector2(30, 30)), 6)
	f.observe(_proj(9, Vector2(30, 30.6)), 7)
	assert_eq(f.triggers.fired[&"shot"], 2)
	assert_eq(f.triggers.fired[&"projectile_end"], 1)


func test_the_shake_kicks_only_near_the_focus() -> void:
	var t: FxTriggers = FxTriggers.new()
	t.rig = CameraRig.new()
	t.fire(&"shot", Vector2(100 * SimConst.PX_PER_M, 0), 0.0, 10)
	t.rig.step(11, Vector2.ZERO)
	assert_eq(t.rig.offset_px(SimConst.PX_PER_M), Vector2.ZERO, "far gunfire")
	t.fire(&"shot", Vector2.ONE, 0.0, 11)
	t.rig.step(12, Vector2.ZERO)
	assert_ne(t.rig.offset_px(SimConst.PX_PER_M), Vector2.ZERO, "near gunfire")
