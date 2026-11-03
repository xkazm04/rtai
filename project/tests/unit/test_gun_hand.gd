extends GutTest
## GunHand in the arena's combat: the table pistol fires on the press edge only, drops a guard
## with one round, and a null gun leaves quest 1's own weapons in charge.


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(3)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	arena.gun = GunHand.make(WeaponTable.shipped(), &"pistol", reg.stream(&"gunplay"))
	return arena


func test_semi_pistol_fires_once_per_press() -> void:
	var arena: CombatArena = _arena()
	var held_shots: int = 0
	for i: int in 60:
		held_shots += 1 if arena.rivet_fire(Vector2(10, 0)) else 0
		arena.step(i + 1)
	assert_eq(held_shots, 1, "holding a semi trigger fires once")
	var tapped: int = 0
	for i: int in 60:
		if i % 20 == 10:
			tapped += 1 if arena.rivet_fire(Vector2(10, 0)) else 0
		arena.step(61 + i)
	assert_eq(tapped, 3, "each fresh press past the cooldown fires")


func test_one_pistol_round_drops_a_guard() -> void:
	var arena: CombatArena = _arena()
	var guard: Fighter = arena.spawn_guard(Vector2(10.0, 0.0))
	guard.cooldown = 999
	assert_true(arena.rivet_fire(guard.pos))
	for i: int in 30:
		arena.step(i + 1)
	assert_false(guard.alive())


func test_a_landed_round_reaches_the_hit_feel() -> void:
	var arena: CombatArena = _arena()
	var guard: Fighter = arena.spawn_guard(Vector2(10.0, 0.0))
	guard.cooldown = 999
	var feel: HitFeel = HitFeel.shipped(CameraRig.new())
	var stops: Array[int] = []
	var hook: Callable = func(v: Fighter, dir: Vector2, lethal: bool, _w: StringName) -> void:
		stops.append(feel.land(v.id, &"light", dir, lethal, arena.tick))
	assert_eq(arena.struck.connect(hook), OK)
	assert_true(arena.rivet_fire(guard.pos))
	for i: int in 30:
		arena.step(1000 + i)
	assert_eq(stops, [6], "one lethal pistol round: the kill hit-stop, once")
