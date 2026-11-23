extends GutTest

var arena: CombatArena
var squad: ArenaSquad
var table: MeleeTable
var swing: PlayerMelee


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	arena = CombatArena.new(CombatTuning.shipped(), bus, RngRegistry.new(53).stream(&"combat"))
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	squad = ArenaSquad.new(arena.guard_map)
	arena.squad_ai = squad
	table = MeleeTable.weapon(&"electro_baton")
	swing = PlayerMelee.new(table)


func _spawn(id: StringName) -> Fighter:
	var f: Fighter = squad.spawn_member(arena, Vector2.RIGHT, id)
	f.pos = Vector2.RIGHT
	f.facing = Vector2.LEFT
	f.hp = 77.0
	f.max_hp = f.hp
	return f


func _click() -> void:
	for i: int in table.hits[0].length() + 1:
		arena.tick += 1
		@warning_ignore("return_value_discarded")
		swing.step(arena, i == 0, Vector2.RIGHT)


func test_one_direct_electric_contact_finishes_both_light_robots() -> void:
	var thug: Fighter = _spawn(&"robot_thug")
	var gunner: Fighter = _spawn(&"robot_gunner")
	_click()
	assert_false(thug.alive())
	assert_false(gunner.alive())
	assert_eq(arena.kills, 2)
	assert_eq(swing.starts, 1)


func test_overload_front_shield_and_turret_hold_still_then_die_to_second_swing() -> void:
	var bodies: Array[Fighter] = [_spawn(&"shield_robot"), _spawn(&"sentry_turret")]
	_click()
	for f: Fighter in bodies:
		assert_eq(f.hp, f.max_hp)
		assert_true(MeleeShutdown.primed(f, arena.tick))
		assert_eq(arena.areas.effect(f).stun_ticks, table.machine_stun_ticks)
		var mind: SquadMind = squad.mind_for(f)
		assert_gt(mind.stun_until, arena.tick)
	var shots: int = arena.shots.size()
	arena.step(arena.tick + 1)
	for f: Fighter in bodies:
		assert_eq(f.pos, Vector2.RIGHT)
	assert_eq(arena.shots.size(), shots)
	_click()
	assert_eq(arena.kills, 2)


func test_stun_from_another_source_does_not_arm_a_finish_and_deadline_is_exclusive() -> void:
	var f: Fighter = _spawn(&"shield_robot")
	PlayerShock.stun_on(PlayerShock.areas_of(arena), f, table.machine_stun_ticks)
	assert_false(MeleeShutdown.primed(f, arena.tick))
	_click()
	assert_true(f.alive())
	var until: int = f.get_meta(MeleeShutdown.PRIMED)
	assert_true(MeleeShutdown.primed(f, until - 1))
	assert_false(MeleeShutdown.primed(f, until))
	arena.tick = until
	_click()
	assert_true(f.alive())
	assert_true(MeleeShutdown.primed(f, arena.tick))


func test_heavy_takes_normal_damage_and_only_the_short_stun_on_repeated_hits() -> void:
	var f: Fighter = _spawn(&"war_machine")
	for i: int in 4:
		var hp: float = f.hp
		var mult: float = FoeArmor.k(f, Vector2.RIGHT, &"shot", squad, arena.tick)
		_click()
		assert_almost_eq(f.hp, hp - table.hits[0].damage * mult, 0.00001)
		assert_false(MeleeShutdown.primed(f, arena.tick))
		assert_eq(arena.areas.effect(f).stun_ticks, table.heavy_stun_ticks)
		assert_gt(squad.mind_for(f).stun_until, arena.tick)


func test_boss_owned_and_boss_fighters_do_not_get_a_finish() -> void:
	var owned: Fighter = _spawn(&"robot_thug")
	owned.brain_owned = true
	var boss: Fighter = _spawn(&"robot_gunner")
	arena.boss = boss
	var tagged: Fighter = _spawn(&"robot_thug")
	tagged.kind = Fighter.Kind.BOSS
	_click()
	for f: Fighter in [owned, boss, tagged]:
		assert_eq(f.hp, f.max_hp - table.hits[0].damage)


func test_blades_and_disabled_electric_use_their_ordinary_hit() -> void:
	for weapon: StringName in [&"katana", &"plasma_sword", &"chainsaw", &"electro_baton"]:
		table = MeleeTable.weapon(weapon)
		if weapon == &"electro_baton":
			table.electric = false
		swing = PlayerMelee.new(table)
		var f: Fighter = _spawn(&"robot_thug")
		_click()
		assert_true(f.alive(), String(weapon))
		assert_lt(f.hp, f.max_hp)
		assert_false(MeleeShutdown.primed(f, arena.tick))
		arena.hostiles.clear()


func test_tuning_one_row_can_protect_a_light_robot_or_change_the_window() -> void:
	table.never_finish = [&"robot_gunner"]
	table.heavy_stun_ticks = 7
	table.machine_stun_ticks = 41
	var light: Fighter = _spawn(&"robot_gunner")
	var carrier: Fighter = _spawn(&"shield_robot")
	_click()
	assert_true(light.alive())
	assert_eq(arena.areas.effect(light).stun_ticks, 7)
	assert_eq(arena.areas.effect(carrier).stun_ticks, 41)


func test_enemy_pit_uses_the_same_contacts_and_preserves_turret_stun() -> void:
	var pit: EnemyPit = squad.pit
	swing.combo.press()
	for id: StringName in [
		&"robot_thug", &"robot_gunner", &"sentry_turret", &"shield_robot", &"war_machine"
	]:
		var agent: EnemyAgent = pit.spawn(id, Vector2.RIGHT)
		agent.hp = 77.0
		agent.facing = Vector2.LEFT
		pit.hurt(agent, 1.0, Vector2.RIGHT, swing.combo)
		if id == &"war_machine":
			assert_true(agent.alive())
			assert_eq(agent.timer, table.heavy_stun_ticks)
		elif agent.arch.machine:
			assert_true(agent.alive())
			assert_eq(agent.timer, table.machine_stun_ticks)
			pit.hurt(agent, 1.0, Vector2.RIGHT, swing.combo)
			assert_true(agent.alive(), "holding the same swing cannot execute")
			pit.hurt(agent, 0.1, Vector2.RIGHT)
			assert_eq(agent.timer, table.machine_stun_ticks)
			var second: MeleeCombo = MeleeCombo.new(table)
			second.press()
			pit.hurt(agent, 1.0, Vector2.RIGHT, second)
			assert_false(agent.alive())
		else:
			assert_false(agent.alive())


func test_shutdown_selects_a_whole_bloodless_frame_at_either_gore_setting() -> void:
	var rows: SignatureKillTable = SignatureKillTable.load_table()
	for full: bool in [true, false]:
		rows.gore_full = full
		var f: Fighter = _spawn(&"robot_gunner")
		f.set_meta(KillEvent.SHUTDOWN, true)
		var event: KillEvent = KillEvent.of_fighter(f, Vector2.LEFT, table.id)
		var k: SignatureKills = SignatureKills.new(rows, RngRegistry.new(16).stream(&"brutality"))
		assert_true(k.on_kill(event))
		var row: SignatureKill = rows.shutdown(f.archetype)
		assert_eq(row.style, &"shutdown")
		assert_eq(row.pieces, PackedInt32Array([SignatureKill.BODY]))
		var mark: KillMarks.Mark = k.marks.marks.back()
		assert_true(mark.drops.is_empty())
		assert_gt(mark.scorch_m, 0.0)
