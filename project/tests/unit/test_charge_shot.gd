extends GutTest
## Lane gunplay: the electro gun's charged shot (brutality REQUEST 12). A press fires the plain
## stun bolt at once; held on, the gun charges once ready and lets a charged bolt go that drops a
## fresh human in one hit (kill_landed with weapon electro_gun); a release drops the charge.


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(5)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	arena.gun = GunHand.make(WeaponTable.shipped(), &"electro_gun", reg.stream(&"gunplay"))
	return arena


func _guard(arena: CombatArena, at: Vector2) -> Fighter:
	var g: Fighter = arena.spawn_guard(at)
	g.pos = at
	g.cooldown = 9999
	return g


func test_a_held_trigger_charges_and_fires_once_full() -> void:
	var trig: Trigger = Trigger.new(WeaponTable.shipped().weapon(&"electro_gun"))
	assert_gt(trig.spec.charge_ticks, 0)
	assert_true(trig.pull(true), "the press fires at once")
	assert_false(trig.charged, "the tap is the plain bolt")
	var fired_at: int = -1
	for i: int in 200:
		trig.step()
		if trig.pull(true):
			fired_at = i
			break
	assert_true(trig.charged, "the held shot is the charged one")
	# ready on step interval - 1 (charge 1 there), full charge_ticks - 1 steps later
	assert_eq(fired_at, trig.spec.interval_ticks + trig.spec.charge_ticks - 2)


func test_a_release_drops_the_charge() -> void:
	var trig: Trigger = Trigger.new(WeaponTable.shipped().weapon(&"electro_gun"))
	assert_true(trig.pull(true))
	for i: int in trig.spec.interval_ticks + trig.spec.charge_ticks / 2:
		trig.step()
		assert_false(trig.pull(true))
	assert_gt(trig.charge_frac(), 0.0)
	assert_false(trig.pull(false))
	assert_eq(trig.charge, 0, "a release drops the charge")


func test_a_gun_without_charge_never_charges() -> void:
	var trig: Trigger = Trigger.new(WeaponTable.shipped().weapon(&"pistol"))
	assert_true(trig.pull(true))
	for i: int in 200:
		trig.step()
		assert_false(trig.pull(true), "a held pistol never fires again (planted: no charge)")
	assert_eq(trig.charge, 0)


func test_one_charged_bolt_drops_a_fresh_human_and_a_plain_one_does_not() -> void:
	var arena: CombatArena = _arena()
	var g: Fighter = _guard(arena, Vector2(9.0, 0.0))
	var kills: Array[StringName] = []
	var hook: Callable = func(
		_v: Fighter, w: StringName, _d: Vector2, _a: Vector2, _k: StringName
	) -> void:
		kills.append(w)
	assert_eq(arena.kill_landed.connect(hook), OK)
	var charged: int = 0
	for t: int in 160:
		var fired: bool = arena.rivet_fire(g.pos) if g.alive() else false
		if fired and arena.shots.back().charged:
			charged += 1
			assert_true(g.alive(), "alive after the plain bolt and its stun")
		arena.step(t)
	assert_eq(charged, 1, "one charged bolt left")
	assert_false(g.alive(), "the charged bolt drops him")
	assert_eq(kills, [&"electro_gun"] as Array[StringName])
