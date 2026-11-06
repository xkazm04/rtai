extends GutTest
## GunFx follows the aim of Rivet's last shot (GunHand.last_aim): the flash, the smoke and the
## shells leave along the shot even when the walk turned his facing between shots (n7-ranged).


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(5)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	arena.gun = GunHand.make(WeaponTable.shipped(), &"pistol", reg.stream(&"gunplay"))
	return arena


func test_the_muzzle_stays_on_the_shot_when_the_walk_turns_rivet() -> void:
	var arena: CombatArena = _arena()
	var fx: GunFx = GunFx.new()
	@warning_ignore("return_value_discarded")
	arena.rivet_fire(arena.rivet.pos + Vector2(20.0, 0.0))
	arena.step(1)
	fx.step(arena, 1)
	assert_gt(arena.gun.shots_fired, 0, "the pistol fired")
	arena.rivet.facing = Vector2.LEFT
	var at: Vector2 = fx.muzzle(arena.rivet, 0.45)
	assert_gt(
		at.x, arena.rivet.pos.x, "the flash sits ahead along the shot (+x), not the walk (-x)"
	)
	assert_almost_eq(fx.aim_of(arena.rivet).x, 1.0, 0.01)


func test_before_any_shot_the_muzzle_uses_the_facing() -> void:
	var arena: CombatArena = _arena()
	var fx: GunFx = GunFx.new()
	arena.rivet.facing = Vector2.LEFT
	assert_lt(fx.muzzle(arena.rivet, 0.45).x, arena.rivet.pos.x)
