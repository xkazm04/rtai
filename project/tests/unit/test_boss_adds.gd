extends GutTest
## BossAdds (features/bosses): adds are bosses.json rows on their own BossFight, capped, and the hp
## the arena's chokepoint takes is routed back through BossFight.hurt().


func _arena() -> CombatArena:
	var reg: RngRegistry = RngRegistry.new(3)
	var bus: EventBus = autofree(EventBus.new())
	return CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))


func test_king_gang_row_spawns_capped_brain_owned() -> void:
	var arena: CombatArena = _arena()
	var gang: BossSpec = BossSpec.shipped(&"king_gang")
	assert_not_null(gang)
	var adds: BossAdds = BossAdds.new()
	adds.cap = 3
	var pts: Array[Vector2] = [Vector2(5, 0), Vector2(-5, 0)]
	var rng: RandomNumberGenerator = RngRegistry.new(3).stream(gang.rng)
	assert_eq(adds.spawn(arena, gang, rng, pts, 4), 3, "capped")
	assert_eq(adds.spawn(arena, gang, rng, pts, 4), 0, "still capped")
	assert_eq(arena.hostiles.size(), 3)
	for f: Fighter in arena.hostiles:
		assert_true(f.brain_owned)


func test_route_sends_arena_damage_through_hurt() -> void:
	var gang: BossSpec = BossSpec.shipped(&"king_gang")
	var f: BossFight = BossFight.new(gang, RngRegistry.new(3).stream(gang.rng), Vector2.ZERO)
	f.start()
	var before: float = f.body.hp
	f.body.hp -= 2.0  # what CombatArena.damage() took this tick
	BossAdds.route(f, before)
	assert_almost_eq(f.body.hp, before - 2.0, 0.0001)
	f.state = BossFight.State.TRANSITION  # invulnerable: the arena's hit is handed back
	f.body.hp -= 2.0
	BossAdds.route(f, before - 2.0)
	assert_almost_eq(f.body.hp, before - 2.0, 0.0001)


## Owner call A: a ghost_k boss takes that share of a ghost form's damage (planted: k ignored).
func test_route_scales_by_ghost_k() -> void:
	var gang: BossSpec = BossSpec.shipped(&"king_gang")
	var f: BossFight = BossFight.new(gang, RngRegistry.new(3).stream(gang.rng), Vector2.ZERO)
	f.start()
	var before: float = f.body.hp
	f.body.hp -= 2.0
	BossAdds.route(f, before, 0.5)
	assert_almost_eq(f.body.hp, before - 1.0, 0.0001)
	assert_eq(
		BossSpec.shipped(&"king").ghost_k, 1.0, "King takes the ghosts' full damage (default)"
	)


func test_adds_swipe_hits_a_standing_rivet_and_misses_after_a_sidestep() -> void:
	for sidestep: bool in [false, true]:
		var arena: CombatArena = _arena()
		var gang: BossSpec = BossSpec.shipped(&"king_gang")
		var adds: BossAdds = BossAdds.new()
		arena.rivet.pos = Vector2(2.0, 0.0)
		var rng: RandomNumberGenerator = RngRegistry.new(3).stream(gang.rng)
		@warning_ignore("return_value_discarded")
		adds.spawn(arena, gang, rng, [Vector2.ZERO] as Array[Vector2], 1)
		var hp0: float = arena.rivet.hp
		for tick: int in 120:
			var f: BossFight = adds.fights[0]
			if sidestep and f.locked and f.state == BossFight.State.WINDUP:
				arena.rivet.pos = Vector2(2.0, 2.5)
			adds.step(arena, tick)
		assert_eq(arena.rivet.hp < hp0, not sidestep, "sidestep %s" % sidestep)


func test_the_decree_buffs_the_standing_adds_for_its_seconds() -> void:
	var decree: BossAttack = BossSpec.shipped(&"king").attacks[&"decree"]
	assert_eq(decree.buff_ticks, 360, "6 s")
	var adds: BossAdds = BossAdds.new()
	adds.buff(decree, 100)
	assert_true(adds.buffed(459))
	assert_almost_eq(adds.damage_k, 1.3, 0.001)
	assert_almost_eq(adds.speed_k, 1.2, 0.001)
	assert_false(adds.buffed(460), "the buff ends on time")
