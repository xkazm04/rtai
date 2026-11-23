extends GutTest

const BOLT: StringName = &"electro_gun"
const CLAW: StringName = &"claw_shock"

var arena: CombatArena
var gun: WeaponSpec
var claw: PlayerShock
var rows: SignatureKillTable
var deaths: Array[StringName] = []


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var streams: RngRegistry = RngRegistry.new(81)
	arena = CombatArena.new(CombatTuning.shipped(), bus, streams.stream(&"combat"))
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	arena.areas = FightAreas.new()
	gun = WeaponTable.shipped().weapon(BOLT)
	claw = PlayerShock.shipped()
	rows = SignatureKillTable.load_table()
	assert_eq(arena.kill_landed.connect(_death), OK)


func _death(f: Fighter, weapon: StringName, dir: Vector2, _at: Vector2, _kind: StringName) -> void:
	var event: KillEvent = KillEvent.of_fighter(f, dir, weapon)
	var row: SignatureKill
	if event.shutdown:
		row = rows.shutdown(f.archetype, weapon)
	elif event.human:
		row = rows.for_weapon(weapon, f.archetype)
	deaths.append(row.weapon if row != null else &"")


func _robot(id: StringName, offset: Vector2 = Vector2.RIGHT) -> Fighter:
	var pos: Vector2 = arena.rivet.pos + offset
	var f: Fighter = arena.squad_ai.spawn_member(arena, pos, id)
	f.pos = pos
	f.facing = Vector2.LEFT
	f.max_hp = 77.0
	f.hp = f.max_hp
	return f


func _hit(source: StringName, f: Fighter, full: bool = true) -> void:
	if source == BOLT:
		var s: Shot = Shot.new()
		s.spec = gun
		s.charged = full
		s.damage = (gun.charge_damage if full else gun.damage) * arena.areas.hp_scale
		s.vel = Vector2.RIGHT * gun.speed_mps
		s.shooter_id = arena.rivet.id
		arena.areas.land(arena, s, f, f.pos)
		return
	for i: int in claw.shock.charge_full if full else claw.shock.charge_full - 1:
		arena.tick += 1
		@warning_ignore("return_value_discarded")
		claw.step(arena, true, true, Vector2.RIGHT)
	assert_true(claw.step(arena, false, true, Vector2.RIGHT))
	# A later release starts after the previous discharge has recovered.
	for i: int in claw.recovery_ticks:
		arena.tick += 1
		@warning_ignore("return_value_discarded")
		claw.step(arena, false, true, Vector2.RIGHT)


func test_direct_sources_finish_light_robots_and_choose_their_own_wreck() -> void:
	rows.gore_full = false
	for source: StringName in [BOLT, CLAW]:
		for id: StringName in [&"robot_thug", &"robot_gunner"]:
			var f: Fighter = _robot(id)
			_hit(source, f, source == CLAW)
			assert_false(f.alive())
			var wreck: StringName = (
				&"electro_bolt_shutdown" if source == BOLT else &"claw_discharge_shutdown"
			)
			assert_eq(deaths[-1], wreck)
			assert_false(f.has_meta(KillEvent.SHUTDOWN))


func test_shield_and_turret_prime_for_150_then_execute_at_either_source() -> void:
	for source: StringName in [BOLT, CLAW]:
		for id: StringName in [&"shield_robot", &"sentry_turret"]:
			var f: Fighter = _robot(id)
			arena.squad_ai.mind_for(f).agent.token = true
			_hit(source, f)
			assert_false(arena.squad_ai.mind_for(f).agent.token)
			assert_eq(f.hp, f.max_hp)
			assert_eq(arena.areas.effect(f).stun_ticks, 150)
			var until: int = f.get_meta(MeleeShutdown.PRIMED)
			assert_true(MeleeShutdown.primed(f, until - 1))
			assert_false(MeleeShutdown.primed(f, until))
			assert_eq(arena.squad_ai.mind_for(f).stun_until, until)
			_hit(source, f)
			assert_false(f.alive())


func test_war_machine_takes_ordinary_damage_and_only_thirty_ticks() -> void:
	for source: StringName in [BOLT, CLAW]:
		var f: Fighter = _robot(&"war_machine")
		var mult: float = FoeArmor.k(f, Vector2.RIGHT, &"shot", arena.squad_ai, arena.tick)
		_hit(source, f)
		var damage: float = (
			gun.charge_damage * arena.areas.hp_scale if source == BOLT else claw.full_damage
		)
		assert_almost_eq(f.hp, f.max_hp - damage * mult, 0.00001)
		assert_eq(arena.areas.effect(f).stun_ticks, 30)
		assert_false(MeleeShutdown.primed(f, arena.tick))
		arena.hostiles.clear()


func test_boss_kind_boss_slot_and_brain_owned_are_exempt() -> void:
	for source: StringName in [BOLT, CLAW]:
		for exemption: int in 3:
			var f: Fighter = _robot(&"robot_thug")
			match exemption:
				0:
					f.kind = Fighter.Kind.BOSS
				1:
					arena.boss = f
				2:
					f.brain_owned = true
			_hit(source, f)
			assert_true(f.alive())
			assert_lt(f.hp, f.max_hp)
			assert_false(MeleeShutdown.primed(f, arena.tick))
			arena.hostiles.clear()


func test_only_the_first_body_gets_the_tier() -> void:
	for source: StringName in [BOLT, CLAW]:
		var direct: Fighter = _robot(&"robot_thug")
		var hop: Fighter = _robot(&"robot_gunner", Vector2(1, 1))
		var shield: Fighter = _robot(&"shield_robot", Vector2(1, 2))
		_hit(source, direct)
		assert_false(direct.alive())
		assert_true(hop.alive())
		assert_gt(arena.areas.effect(hop).stun_ticks, 0)
		if source == BOLT:
			assert_almost_eq(
				hop.max_hp - hop.hp, gun.charge_damage * 0.01 * FightAreas.CHAIN_FALLOFF, 0.00001
			)
		else:
			assert_eq(hop.max_hp, hop.hp)
		assert_false(MeleeShutdown.primed(shield, arena.tick))
		arena.hostiles.clear()


func test_one_tick_short_of_full_stuns_without_damage_or_prime() -> void:
	for id: StringName in [&"robot_thug", &"shield_robot"]:
		var f: Fighter = _robot(id)
		_hit(CLAW, f, false)
		assert_eq(f.hp, f.max_hp)
		assert_between(
			arena.areas.effect(f).stun_ticks, claw.shock.stun_min, claw.shock.stun_full - 1
		)
		assert_false(MeleeShutdown.primed(f, arena.tick))
		arena.hostiles.clear()


func test_human_bolt_damage_and_full_claw_keep_their_human_kills() -> void:
	for source: StringName in [BOLT, CLAW]:
		var human: Fighter = _robot(&"contractor")
		human.hp = 1.0
		if source == BOLT:
			_hit(source, human, false)
			assert_almost_eq(human.hp, 1.0 - gun.damage * 0.01, 0.00001)
		_hit(source, human)
		assert_false(human.alive())
		assert_eq(deaths[-1], rows.for_weapon(source, human.archetype).weapon)
		assert_eq(rows.for_weapon(CLAW).id, &"claw_throw")


func test_bolt_charge_switch_restores_standard_tap_damage() -> void:
	var f: Fighter = _robot(&"robot_gunner")
	_hit(BOLT, f, false)
	assert_false(f.alive())
	RobotFinish._bolt.charged_only = true
	var other: Fighter = _robot(&"robot_gunner")
	_hit(BOLT, other, false)
	assert_almost_eq(other.hp, other.max_hp - gun.damage * 0.01, 0.00001)
	_hit(BOLT, other, true)
	RobotFinish._bolt.charged_only = false
	assert_false(other.alive())


func test_expired_overload_primes_again_and_a_partial_claw_cannot_execute_it() -> void:
	var f: Fighter = _robot(&"shield_robot")
	_hit(BOLT, f, false)
	arena.tick = f.get_meta(MeleeShutdown.PRIMED)
	_hit(BOLT, f, false)
	assert_eq(f.hp, f.max_hp)
	var until: int = f.get_meta(MeleeShutdown.PRIMED)
	assert_eq(until, arena.tick + 150)
	_hit(CLAW, f, false)
	assert_eq(f.hp, f.max_hp)
	_hit(CLAW, f)
	assert_false(f.alive())
	assert_eq(deaths[-1], &"claw_discharge_shutdown")
