extends GutTest
## n7-melee (combat-notes' next step 1): a melee hit that does not kill (a riot cop at 2 hp takes
## the claw's 1) played no wound. CombatArena.wounded now queues the melee wound on the hit tick,
## once per strike (the chainsaw grind lands every tick); --soft-swing is the night's: none.


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(3)
	return CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))


func _riot(arena: CombatArena, at: Vector2) -> Fighter:
	var f: Fighter = Fighter.make(Fighter.Kind.GUARD, 7, at, 2.0)
	arena.hostiles.append(f)
	return f


func after_each() -> void:
	ReactLink.melee_deaths = true
	MeleeWound.past_slab = true


func test_a_claw_jab_on_a_riot_cop_queues_a_wound_on_the_hit_tick() -> void:
	var arena: CombatArena = _arena()
	var link: ReactLink = ReactLink.make(arena)
	var f: Fighter = _riot(arena, Vector2(1.0, 0.0))
	arena.damage(f, 1.0, arena.rivet.id, &"claw")
	assert_true(f.alive(), "2 hp takes the jab and lives")
	assert_eq(link._pending.size(), 1, "the wound is queued on the hit tick")
	var h: Array = link._pending[0]
	var lethal: bool = h[2]
	var hit_class: StringName = h[3]
	var dir: Vector2 = h[1]
	assert_false(lethal)
	assert_eq(hit_class, &"melee")
	assert_almost_eq(dir.x, 1.0, 0.001, "pushed away from Rivet")


func test_the_chainsaw_grind_wounds_once_per_strike_not_every_tick() -> void:
	var arena: CombatArena = _arena()
	var link: ReactLink = ReactLink.make(arena)
	var f: Fighter = _riot(arena, Vector2(1.0, 0.0))
	f.hp = 100.0
	for t: int in 30:
		arena.tick = t
		arena.damage(f, 0.34, arena.rivet.id, &"chainsaw")
	assert_between(link._pending.size(), 1, 3, "30 grind ticks play 1 to 3 wounds")
	assert_eq(link.melee_wound.gated, 30 - link._pending.size())


func test_a_gun_hit_is_left_to_its_struck() -> void:
	var arena: CombatArena = _arena()
	var link: ReactLink = ReactLink.make(arena)
	arena.damage(_riot(arena, Vector2(3.0, 0.0)), 1.0, arena.rivet.id, &"pistol")
	assert_eq(link._pending.size(), 0, "a round's wound comes with its struck")


func test_a_kill_is_not_also_a_wound() -> void:
	var arena: CombatArena = _arena()
	var link: ReactLink = ReactLink.make(arena)
	arena.damage(_riot(arena, Vector2(1.0, 0.0)), 9.0, arena.rivet.id, &"claw")
	assert_eq(link._pending.size(), 1, "one death, no wound beside it")
	assert_eq(link.melee_wound.played, 0)


func test_planted_night_path_plays_no_wound() -> void:
	ReactLink.melee_deaths = false
	var arena: CombatArena = _arena()
	var link: ReactLink = ReactLink.make(arena)
	arena.damage(_riot(arena, Vector2(1.0, 0.0)), 1.0, arena.rivet.id, &"claw")
	assert_eq(link._pending.size(), 0, "the night's: the riot cop shrugs the jab off")


func test_a_claw_on_a_riot_shield_front_wounds_the_body_without_block_sparks() -> void:
	var link: ReactLink = ReactLink.make(_arena())
	var rig: CutRig = CutRig.new()
	rig.variant = RigVariant.crowd(6)
	watch_signals(link)
	link._wound(rig, 9, &"melee", Vector2.LEFT, false)
	assert_signal_not_emitted(link, "blocked", "the claw drew blood: no 'blocked' sparks")
	assert_ne(HumanReact.on(rig).kind, &"shield")
	rig.free()


func test_planted_slab_takes_the_claw() -> void:
	MeleeWound.past_slab = false
	var link: ReactLink = ReactLink.make(_arena())
	var rig: CutRig = CutRig.new()
	rig.variant = RigVariant.crowd(6)
	watch_signals(link)
	link._wound(rig, 9, &"melee", Vector2.LEFT, false)
	assert_signal_emitted(link, "blocked", "the first pass: the shield family and its sparks")
	rig.free()
