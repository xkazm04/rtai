extends GutTest
## The real fork release runs before arena.step, as it does in CollectCallStage.

var arena: CombatArena
var stage: CollectCallStage
var squad: ArenaSquad
var ohm: OhmStage


func before_each() -> void:
	stage = CollectCallStage.new(StageLayout.shipped())
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage.setup(World.build_context(bus, data, 23))
	arena = stage.arena
	arena.rivet.pos = Vector2.ZERO
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	squad = ArenaSquad.new(arena.guard_map)
	arena.squad_ai = squad
	ohm = OhmStage.shipped()


func _spawn(id: StringName, at: Vector2, machine: bool = true) -> Fighter:
	if machine:
		squad.pit.roster.archetype(id).machine = true
	var h: Fighter = squad.spawn_member(arena, at, id)
	h.pos = at
	h.facing = Vector2.LEFT
	h.cooldown = 0
	return h


func _tick(bolt: bool = false) -> void:
	stage.tick += 1
	ohm.drive(stage, bolt and not ohm.on(), bolt, Vector2.RIGHT)
	arena.step(stage.tick)


func _before(tick: int) -> void:
	while stage.tick < tick - 1:
		_tick()


func _uses() -> int:
	var row: Dictionary = {}
	arena.move_tally.append_wave(row)
	var moves: Dictionary = row.get("moves", {})
	var count: int = moves.get("ohm_short_circuit", 0)
	return count


func test_live_turret_freezes_for_120_ticks_but_its_round_keeps_flying() -> void:
	var gun: Fighter = _spawn(&"sentry_turret", Vector2(9, 0))
	for i: int in 200:
		_tick()
		if not arena.shots.is_empty():
			break
	assert_false(arena.shots.is_empty())
	if arena.shots.is_empty():
		return
	var round_in_flight: Shot = arena.shots[0]
	var at: Vector2 = round_in_flight.pos
	var facing: Vector2 = gun.facing
	var mind: SquadMind = squad.minds[gun.id]
	var last_round: int = mind.agent.shot_tick
	_tick(true)
	var start: int = stage.tick
	assert_true(arena.shots.has(round_in_flight))
	assert_ne(round_in_flight.pos, at)
	for age: int in 120:
		if age > 0:
			_tick()
		assert_true(OhmShortCircuit.held(squad, gun))
		assert_eq(gun.facing, facing)
		assert_eq(mind.agent.shot_tick, last_round)
		assert_eq(gun.tell_left, 0)
	_tick()
	assert_false(OhmShortCircuit.held(squad, gun))
	assert_eq(gun.tell_left, mind.agent.arch.telegraph_ticks)
	_before(start + 235)
	assert_gt(mind.agent.shot_tick, start + 120)
	assert_ne(gun.facing, facing)


func _frontal_hit(h: Fighter) -> float:
	var before: float = h.hp
	arena.hit_dir = Vector2.RIGHT
	arena.damage(h, 1.0, arena.rivet.id, &"gloria")
	return before - h.hp


func test_shield_drops_for_carrier_and_rifleman_then_covers_both_again() -> void:
	var shield: Fighter = _spawn(&"shield_robot", Vector2(5, 0))
	var plate: float = squad.pit.roster.archetype(shield.archetype).shield_front_mult
	assert_almost_eq(_frontal_hit(shield), plate, 0.00001)
	_tick(true)
	var mate: Fighter = _spawn(&"swat", shield.pos + Vector2.RIGHT, false)
	mate.hp = 5.0
	assert_eq(_frontal_hit(shield), 1.0)
	assert_eq(_frontal_hit(mate), 1.0)
	_before(stage.tick + 120)
	assert_eq(_frontal_hit(shield), 1.0)
	_tick()
	mate.pos = shield.pos + Vector2.RIGHT
	assert_almost_eq(_frontal_hit(shield), plate, 0.00001)
	assert_almost_eq(_frontal_hit(mate), plate, 0.00001)


func _interrupt_walker(distance: float) -> void:
	var h: Fighter = _spawn(&"war_machine", Vector2(distance, 0))
	for i: int in 70:
		_tick()
		if h.tell_left + h.swing_left > 0:
			break
	var mind: SquadMind = squad.minds[h.id]
	var full_tell: int = h.tell_left + h.swing_left
	assert_gt(full_tell, 0)
	_tick()
	_tick(true)
	assert_eq(_uses(), 1)
	assert_eq(FoeArmor.k(h, -h.facing, &"shot", squad), mind.agent.arch.shield_front_mult)
	assert_eq(FoeArmor.k(h, h.facing, &"shot", squad), mind.agent.arch.rear_mult)
	for age: int in 36:
		if age > 0:
			_tick()
		assert_true(OhmShortCircuit.held(squad, h))
		assert_eq(h.tell_left + h.swing_left, 0)
		assert_eq(mind.walker.ring_radius(mind.agent), 0.0)
		assert_true(arena.shots.is_empty())
	_tick()
	assert_false(OhmShortCircuit.held(squad, h))
	assert_eq(h.tell_left + h.swing_left, full_tell, "the next attack starts a fresh tell")


func test_short_circuit_cancels_the_cannon_tell_for_36_ticks() -> void:
	_interrupt_walker(9.0)


func test_short_circuit_cancels_the_stomp_tell_for_36_ticks() -> void:
	_interrupt_walker(1.5)


func test_immune_bolts_do_damage_without_extending_the_stun_or_counting() -> void:
	var h: Fighter = _spawn(&"sentry_turret", Vector2(8, 0))
	# Allow the two presses at 3.9 s and 4.1 s: this test isolates the machine's immunity.
	ohm.attacks.block(OhmStage.GHOST)["bolt_gap_s"] = 0.1
	_tick(true)
	var start: int = stage.tick
	var mind: SquadMind = squad.minds[h.id]
	for offset: int in [60, 234]:
		_before(start + offset)
		var hp: float = h.hp
		_tick(true)
		assert_lt(h.hp, hp)
		assert_eq(_uses(), 1)
		assert_eq(mind.stun_until, start + 120)
		assert_eq(mind.immune_until, start + 240)
		assert_eq(OhmShortCircuit.held(squad, h), offset < 120)
		assert_true(arena.areas == null or arena.areas.effect(h) == null)
	_before(start + 246)
	_tick(true)
	assert_eq(_uses(), 2)
	assert_true(OhmShortCircuit.held(squad, h))
	assert_eq(mind.stun_until, start + 246 + 120)


func test_fork_counts_one_use_and_keeps_immunity_per_fighter() -> void:
	var a: Fighter = _spawn(&"sentry_turret", Vector2(6, 0))
	var b: Fighter = _spawn(&"shield_robot", Vector2(7, 1))
	_tick(true)
	assert_true(OhmShortCircuit.held(squad, a))
	assert_true(OhmShortCircuit.held(squad, b))
	assert_eq(_uses(), 1)
	var c: Fighter = _spawn(&"sentry_turret", Vector2(6, 1))
	_before(61)
	_tick(true)
	assert_true(OhmShortCircuit.held(squad, c))
	assert_eq(_uses(), 2)
	_before(241)
	_tick(true)
	assert_eq(squad.minds[a.id].immune_until, 481, "eligible at exactly 4 s")
	assert_eq(_uses(), 3)


func test_short_circuit_interrupts_the_shields_locked_lunge() -> void:
	var h: Fighter = _spawn(&"shield_robot", Vector2(1.6, 0))
	var mind: SquadMind = squad.mind_for(h)
	for i: int in 180:
		_tick()
		if mind.shield.lunge_left > 0:
			break
	assert_gt(mind.shield.lunge_left, 0)
	_tick(true)
	assert_eq(mind.shield.lunge_left, 0)
	assert_false(mind.agent.token)
	var at: Vector2 = h.pos
	_before(stage.tick + 120)
	assert_eq(h.pos, at)
	assert_eq(arena.rivet.hp, arena.rivet.max_hp)
