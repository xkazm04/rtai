extends GutTest
## FightAreas: the weapon table's area behaviours in the real fight (CombatArena via GunHand):
## the rocket splashes and knocks down, the flamethrower sets humans burning and panicking, the
## electro bolt chains body to body and stuns, the molotov flies over bodies and leaves fire.


func _arena(weapon: StringName) -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(5)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	arena.gun = GunHand.make(WeaponTable.shipped(), weapon, reg.stream(&"gunplay"))
	return arena


func _guard(arena: CombatArena, at: Vector2) -> Fighter:
	var g: Fighter = arena.spawn_guard(at)
	g.pos = at
	g.cooldown = 9999
	return g


func _run(arena: CombatArena, from: int, ticks: int) -> void:
	for i: int in ticks:
		arena.step(from + i)


func test_rocket_splash_kills_near_and_knocks_down_far() -> void:
	var arena: CombatArena = _arena(&"rocket_launcher")
	var direct: Fighter = _guard(arena, Vector2(10.0, 0.0))
	var near: Fighter = _guard(arena, Vector2(10.0, 1.2))
	var far: Fighter = _guard(arena, Vector2(10.0, 3.2))
	var kinds: Array[StringName] = []
	var hook: Callable = func(
		_v: Fighter, _w: StringName, _d: Vector2, _a: Vector2, k: StringName
	) -> void:
		kinds.append(k)
	assert_eq(arena.kill_landed.connect(hook), OK)
	assert_true(arena.rivet_fire(direct.pos))
	_run(arena, 1, 50)
	assert_false(direct.alive(), "direct hit kills")
	assert_false(near.alive(), "1.2 m from the blast dies")
	assert_true(far.alive(), "3.2 m from the blast lives")
	assert_gt(arena.areas.knockdowns, 0, "the blast knocks the living down")
	assert_eq(kinds, [&"blown", &"blown"] as Array[StringName])


func test_flame_sets_a_human_burning_and_panicking_until_he_dies() -> void:
	var arena: CombatArena = _arena(&"flamethrower")
	var g: Fighter = _guard(arena, Vector2(4.0, 0.0))
	for i: int in 3:
		@warning_ignore("return_value_discarded")
		arena.rivet_fire(g.pos)
		arena.step(1 + i)
	_run(arena, 4, 20)
	var e: FighterFx = arena.areas.effect(g)
	assert_not_null(e)
	assert_true(g.alive() and e.burn_ticks > 0, "a brief touch sets him burning, alive")
	var start: Vector2 = g.pos
	_run(arena, 30, 30)
	assert_gt(g.pos.distance_to(start), 1.0, "a burning human runs")
	_run(arena, 60, 240)
	assert_false(g.alive(), "the fire finishes him")


func test_electro_bolt_chains_body_to_body_and_stuns() -> void:
	var arena: CombatArena = _arena(&"electro_gun")
	var a: Fighter = _guard(arena, Vector2(8.0, 0.0))
	var b: Fighter = _guard(arena, Vector2(8.0, 2.5))
	var c: Fighter = _guard(arena, Vector2(8.0, 5.0))
	assert_true(arena.rivet_fire(a.pos))
	_run(arena, 1, 15)
	assert_eq(arena.areas.chain_hits, 2, "two hops")
	for f: Fighter in [a, b, c]:
		assert_gt(arena.areas.effect(f).stun_ticks, 0, "every body in the chain is stunned")
	assert_true(b.hp < b.max_hp and c.hp > b.hp, "the chain falls off per hop")


func test_molotov_flies_over_a_body_and_leaves_fire() -> void:
	var arena: CombatArena = _arena(&"molotov")
	var between: Fighter = _guard(arena, Vector2(4.0, 0.3))  # on the path, off the aim
	var behind: Fighter = _guard(arena, Vector2(9.0, 0.0))
	assert_true(arena.rivet_fire(Vector2(9.0, 0.0)))
	_run(arena, 1, 50)
	assert_true(between.alive() and arena.areas.effect(between) == null, "the bottle flies over")
	assert_eq(arena.areas.patches.size(), 1, "a fire patch where it landed")
	assert_gt(arena.areas.effect(behind).burn_ticks, 0, "the one under it burns")


func test_quest_weapons_never_build_the_area_model() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(5)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	arena.rivet.weapon = &"gloria"
	var g: Fighter = _guard(arena, Vector2(8.0, 0.0))
	assert_true(arena.rivet_fire(g.pos))
	_run(arena, 1, 30)
	assert_false(g.alive())
	assert_null(arena.areas, "quest 1 (no GunHand) keeps its own model and goldens")


func test_a_bottle_aimed_past_a_guard_lands_on_him() -> void:
	var arena: CombatArena = _arena(&"molotov")
	var g: Fighter = _guard(arena, Vector2(9.0, 0.8))
	# the arena's aim point is the aim direction x aim_range_m: far past the guard
	assert_true(arena.rivet_fire(Vector2(25.0, 0.0)))
	_run(arena, 1, 50)
	assert_not_null(arena.areas.effect(g), "the bottle found the guard under the aim line")
	assert_gt(arena.areas.effect(g).burn_ticks, 0)


func test_one_mini_nuke_clears_every_human_in_its_circle_and_leaves_fire() -> void:
	var arena: CombatArena = _arena(&"mini_nuke")
	assert_true(arena.gun.trigger.spec.enabled, "the mini-nuke is in the arsenal")
	var target: Fighter = _guard(arena, Vector2(14.0, 0.0))
	var near: Fighter = _guard(arena, Vector2(14.0, 6.0))
	var far: Fighter = _guard(arena, Vector2(14.0, 30.0))
	assert_true(arena.rivet_fire(target.pos))
	_run(arena, 1, 120)
	assert_false(target.alive(), "the shell drops the human it lands on")
	assert_false(near.alive(), "and every human 6 m out")
	assert_true(far.alive(), "a human 30 m out is outside the blast")
	assert_eq(arena.areas.patches.size(), 1, "a fire patch where it landed")
	assert_eq(FightAreas.kind_of(arena.gun.trigger.spec), &"blown", "a nuke kill is a blast death")
	assert_eq(FightAreas.kind_of(_arena(&"molotov").gun.trigger.spec), &"burned")


func test_a_homing_shard_curves_onto_a_human_off_the_aim_line() -> void:
	var arena: CombatArena = _arena(&"homing_shard")
	assert_true(arena.gun.trigger.spec.enabled, "the homing shard gun is in the arsenal")
	var g: Fighter = _guard(arena, Vector2(9.0, 2.5))  # 15 deg off the aim line
	assert_true(arena.rivet_fire(Vector2(20.0, 0.0)))
	_run(arena, 1, 60)
	assert_false(g.alive(), "the shard turned onto him and one shard drops a human")
	assert_eq(arena.areas.blasts.size(), 1, "it bursts where it stops")


func test_a_homing_shard_ignores_a_human_behind_it() -> void:
	var arena: CombatArena = _arena(&"homing_shard")
	var g: Fighter = _guard(arena, Vector2(-6.0, 0.0))
	assert_true(arena.rivet_fire(Vector2(20.0, 0.0)))
	_run(arena, 1, 60)
	assert_true(g.alive(), "a shard never turns around")
