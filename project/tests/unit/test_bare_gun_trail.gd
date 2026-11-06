extends GutTest
## n7-ranged it24: quest 1's picked-up rifle (no GunFx on its path) leaves the shot trail when its
## round stops in a hostile, from where it left the gun; a round that stops in nobody leaves none,
## and --feel=off leaves none.


func after_each() -> void:
	WeaponFxTrail.reset()


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(5)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	arena.hostiles.clear()
	arena.rivet.weapon = &"assault-rifle"
	arena.rifle_ammo = 30
	assert_true(arena.rivet_fire(Vector2(5.0, 0.0)), "Rivet fires the rifle on combat.json's path")
	return arena


## The round seen in flight on tick 1, then gone on tick 2 with `victim` (or nobody) on its step.
func _trails_after_stop(arena: CombatArena, victim: bool) -> int:
	var view: BareGunTrail = BareGunTrail.new()
	var s: Shot = arena.shots[-1]
	s.pos += s.vel.normalized() * 6.0
	s.left_m -= 6.0
	view.step(arena, 1)
	arena.shots.clear()
	if victim:
		var at: Vector2 = s.pos + s.vel * SimClock.TICK_DT * 0.5
		arena.hostiles.append(Fighter.make(Fighter.Kind.GUARD, 77, at, 100.0))
	view.step(arena, 2)
	if view.trails.is_empty():
		return 0
	assert_lt(view.trails[0].from.distance_to(arena.rivet.pos), 2.0, "starts at Rivet's gun")
	return view.trails.size()


func test_a_rifle_hit_leaves_a_trail() -> void:
	WeaponFxTrail.reset(HitFeel.shipped())
	assert_eq(_trails_after_stop(_arena(), true), 1)


func test_a_round_that_stops_in_nobody_leaves_none() -> void:
	WeaponFxTrail.reset(HitFeel.shipped())
	assert_eq(_trails_after_stop(_arena(), false), 0)


func test_feel_off_leaves_none() -> void:
	var off: HitFeel = HitFeel.shipped()
	off.enabled = false
	WeaponFxTrail.reset(off)
	assert_eq(_trails_after_stop(_arena(), true), 0)
