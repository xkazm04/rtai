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


func test_every_gun_names_a_shot_cue_that_exists() -> void:
	var table: WeaponTable = WeaponTable.shipped()
	var cues: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string("res://data/tables/audio_cues.json")
	)
	var ids: Array[String] = []
	for row: Dictionary in cues["cues"]:
		ids.append(str(row["id"]))
	for id: StringName in table.weapons:
		var w: WeaponSpec = table.weapon(id)
		assert_ne(w.shot_cue, &"", "%s has a sound hook" % id)
		assert_has(ids, str(w.shot_cue), "%s: cue %s exists" % [id, w.shot_cue])
	assert_has(ids, "tazer_charge", "the charge-up cue exists")


func test_a_charged_bolt_lands_as_a_blast_a_plain_one_as_shock() -> void:
	var arena: CombatArena = _arena()
	var link: HitLink = HitLink.make(arena, HitFeel.shipped(CameraRig.new()), WeaponTable.shipped())
	var g: Fighter = _guard(arena, Vector2(9.0, 0.0))
	g.hp = g.max_hp * 100.0  # he takes both bolts
	var holds: Array[int] = []
	for t: int in 160:
		@warning_ignore("return_value_discarded")
		arena.rivet_fire(g.pos)
		arena.step(t)
		if link.hold > 0:
			holds.append(link.hold)
			link.hold = 0
	assert_gte(holds.size(), 2, "the plain bolt, then charged ones, landed")
	assert_lt(holds[0], holds[1], "the charged bolt holds the play longer")


func test_the_range_model_holds_the_charge_gun_and_the_charged_bolt_kills() -> void:
	var table: WeaponTable = WeaponTable.shipped()
	var lane: RangeDrill.Lane = RangeDrill.Lane.new()
	lane.weapon = &"electro_gun"
	lane.distance_m = 5.0
	lane.target_hp = table.target_hp[&"human"]
	lane.target_radius_m = 0.3
	var res: RangeDrill.Result = RangeDrill.run(table, lane, RngRegistry.new(3).stream(&"t"))
	assert_true(res.killed, "the TTK table sees the charged kill")
	assert_eq(res.shots, 2, "the tap bolt stuns, the held charged bolt kills")
	# planted: a gun without the charge column keeps the plain bolt's damage (no one-shot)
	var plain: Trigger = Trigger.new(table.weapon(&"pistol"))
	var sim: ProjectileSim = ProjectileSim.new(RngRegistry.new(3).stream(&"t"), table)
	assert_true(plain.pull(true))
	sim.fire(plain, Vector2.ZERO, Vector2(5.0, 0.0), Projectile.TEAM_PLAYER, 0)
	assert_eq(sim.projectiles[0].damage, table.weapon(&"pistol").damage)
