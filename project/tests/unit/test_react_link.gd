extends GutTest
## ReactLink: the arena's landed rounds reach the human reaction layer (a kill queues the
## standard death with the weapon's damage class), Rivet never reacts, a victim without a full
## rig is skipped, and the queue drains each frame.


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(3)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	arena.gun = GunHand.make(WeaponTable.shipped(), &"pistol", reg.stream(&"gunplay"))
	return arena


func test_a_pistol_kill_queues_a_light_death_along_the_shot() -> void:
	var arena: CombatArena = _arena()
	var link: ReactLink = ReactLink.make(arena)
	var guard: Fighter = arena.spawn_guard(Vector2(10.0, 0.0))
	guard.cooldown = 999
	assert_true(arena.rivet_fire(guard.pos))
	for i: int in 30:
		arena.step(1000 + i)
	assert_eq(link._pending.size(), 1)
	var h: Array = link._pending[0]
	var id: int = h[0]
	var lethal: bool = h[2]
	var hit_class: StringName = h[3]
	assert_eq(id, guard.id)
	assert_true(lethal, "lethal")
	assert_eq(hit_class, &"light")
	var dir: Vector2 = h[1]
	assert_gt(dir.x, 0.9, "the round travels from Rivet toward the guard")


func test_rivet_never_reacts_and_burn_is_burn() -> void:
	var arena: CombatArena = _arena()
	var link: ReactLink = ReactLink.make(arena)
	arena.struck.emit(arena.rivet, Vector2.LEFT, false, &"pistol")
	assert_eq(link._pending.size(), 0)
	assert_eq(link.hit_class_of(&"burn"), &"burn")
	assert_eq(link.hit_class_of(&"no-such-gun"), &"light")


func test_a_victim_without_a_full_rig_is_skipped_and_the_queue_drains() -> void:
	var arena: CombatArena = _arena()
	var link: ReactLink = ReactLink.make(arena)
	var guard: Fighter = arena.spawn_guard(Vector2(4.0, 0.0))
	arena.struck.emit(guard, Vector2.RIGHT, false, &"pistol")
	var rigs: CharacterRigs = CharacterRigs.new()
	autofree(rigs)
	link.apply(rigs)
	assert_eq(link._pending.size(), 0)
	assert_eq(link.wounds, 0, "no rig, nothing played")
