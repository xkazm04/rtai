extends GutTest
## HitLink: a landed table round becomes the kill hit-stop owed to the caller, a victim flash
## that fades, and a knockback slide along the shot that decays to a stop. A bot's tapped semi
## gun re-fires once the trigger is ready.


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(3)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	arena.gun = GunHand.make(WeaponTable.shipped(), &"pistol", reg.stream(&"gunplay"))
	return arena


func test_a_kill_owes_the_hit_stop_flashes_and_slides() -> void:
	var arena: CombatArena = _arena()
	var link: HitLink = HitLink.make(arena, HitFeel.shipped(CameraRig.new()), WeaponTable.shipped())
	var guard: Fighter = arena.spawn_guard(Vector2(10.0, 0.0))
	guard.cooldown = 999
	assert_true(arena.rivet_fire(guard.pos))
	var hit_x: float = INF
	var lit: float = 0.0
	for i: int in 30:
		arena.step(1000 + i)
		if link.hits > 0 and hit_x == INF:
			hit_x = guard.pos.x
			lit = link.flash(guard)
		link.step()
	assert_eq(link.kills, 1)
	assert_eq(link.hold, 6, "the kill hit-stop is owed to the caller")
	assert_gt(lit, 0.0, "the victim flashes on the hit")
	assert_eq(link.flash(guard), 0.0, "and the flash is gone 20+ ticks later")
	assert_gt(guard.pos.x, hit_x + 0.02, "the body slides along the shot")
	assert_lt(guard.pos.x, hit_x + 0.5, "and stops (knockback decays)")


func test_a_tapped_semi_gun_refires_when_ready() -> void:
	var arena: CombatArena = _arena()
	arena.gun.tap = true
	var fired: int = 0
	for i: int in 60:
		fired += 1 if arena.rivet_fire(Vector2(30, 0)) else 0
		arena.step(i + 1)
	assert_gt(fired, 1, "a held, tapped trigger keeps firing")
	assert_lte(fired, 60 / arena.gun.trigger.spec.interval_ticks + 1, "never past the cadence")


func test_a_non_lethal_hit_leans_the_figure_then_eases_back() -> void:
	var arena: CombatArena = _arena()
	var link: HitLink = HitLink.make(arena, HitFeel.shipped(CameraRig.new()), WeaponTable.shipped())
	var guard: Fighter = arena.spawn_guard(Vector2(10.0, 0.0))
	guard.cooldown = 999
	guard.hp = 3.0
	guard.max_hp = 3.0
	assert_true(arena.rivet_fire(guard.pos))
	var leaned: float = 0.0
	for i: int in 40:
		arena.step(1000 + i)
		link.step()
		leaned = maxf(leaned, link.lean(guard).x)
	assert_true(guard.alive())
	assert_gt(leaned, 0.1, "the struck figure leans along the shot")
	assert_eq(link.lean(guard), Vector2.ZERO, "and is upright again")
