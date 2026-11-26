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


func _arena(weapon: StringName) -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(3)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	arena.gun = GunHand.make(WeaponTable.shipped(), weapon, reg.stream(&"gunplay"))
	return arena


func _blood() -> CombatBlood:
	var blood: CombatBlood = autofree(CombatBlood.new())
	GunFxWound.use(blood)
	return blood


func _victim(id: int, machine: bool) -> Fighter:
	var f: Fighter = Fighter.make(Fighter.Kind.GUARD, id, Vector2(3.0, 0.0), 9.0)
	f.machine = machine
	return f


func _round(arena: CombatArena, on: Fighter) -> int:
	return GunFxWound.on_round(GunFx.new(), arena, on, Vector2(2.0, 0.0), Vector2.RIGHT)


func test_a_human_gets_a_red_flick_one_and_the_blood_drops_land_in_blood() -> void:
	var blood: CombatBlood = _blood()
	var arena: CombatArena = _arena(&"pistol")
	assert_eq(_round(arena, _victim(5, false)), 1)
	assert_gt(blood.blood.drops, 0, "red drops in the blood fx")
	assert_eq(blood.oil.drops, 0, "none in the oil")


func test_a_robot_gets_white_sparks_two_and_the_drops_land_in_oil() -> void:
	var blood: CombatBlood = _blood()
	var arena: CombatArena = _arena(&"pistol")
	assert_eq(_round(arena, _victim(5, true)), 2)
	assert_gt(blood.oil.drops, 0)
	assert_eq(blood.blood.drops, 0)
	var listed: Fighter = _victim(6, false)
	blood.victims.robot_ids[6] = true
	assert_eq(_round(arena, listed), 2, "a listed robot id counts as a robot")


func test_a_robot_without_oil_still_counts_two_and_splashes_the_blood_fx() -> void:
	var blood: CombatBlood = _blood()
	blood.oil.free()
	blood.oil = null
	var arena: CombatArena = _arena(&"pistol")
	assert_eq(_round(arena, _victim(5, true)), 2)
	assert_gt(blood.blood.drops, 0)


func test_each_early_out_returns_zero_and_throws_nothing() -> void:
	var blood: CombatBlood = _blood()
	var arena: CombatArena = _arena(&"pistol")
	var man: Fighter = _victim(5, false)
	assert_eq(GunFxWound.on_round(GunFx.new(), arena, null, Vector2.ZERO, Vector2.RIGHT), 0)
	blood.mode = "ink"
	assert_eq(_round(arena, man), 0, "no blood in ink mode")
	blood.mode = "noir"
	var cannon: CombatArena = _arena(&"hand_cannon")
	var flicks: bool = GunFx.new().look(&"hand_cannon").get("flick", false)
	assert_false(flicks, "the row has no flick")
	assert_eq(_round(cannon, man), 0, "the gun's row has no flick")
	assert_eq(_round(arena, man), 1, "the first flick is admitted")
	assert_eq(_round(arena, man), 0, "inside the cap")
	assert_eq(blood.blood.drops, 3, "only the admitted flick threw drops")


func test_a_reused_instance_admits_again_after_use() -> void:
	var blood: CombatBlood = _blood()
	var arena: CombatArena = _arena(&"pistol")
	var man: Fighter = _victim(5, false)
	assert_eq(_round(arena, man), 1)
	assert_eq(_round(arena, man), 0)
	GunFxWound.use(blood)
	assert_eq(_round(arena, man), 1, "use() cleared the per-victim clock")


func test_a_dead_blood_ref_throws_nothing() -> void:
	var blood: CombatBlood = CombatBlood.new()
	GunFxWound.use(blood)
	blood.free()
	var arena: CombatArena = _arena(&"pistol")
	assert_eq(_round(arena, _victim(5, false)), 0)
