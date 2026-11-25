extends GutTest
## n31 foes: FIGHT (slow, may shoot) and TRAVEL (fast, may not) for ranged wave members.

const F := FoeGait.Mode.FIGHT
const T := FoeGait.Mode.TRAVEL
const MIN: int = 36
const SETTLE: int = 15
const KINDS: Array[StringName] = [&"patrol_cop", &"swat", &"contractor", &"robot_gunner"]
## Digest of the legacy trace below, pinned on the pre-n31 code path (`--foe-moves=legacy`).
const LEGACY_TRACE: int = 0


func _roster() -> EnemyRoster:
	return EnemyRoster.shipped(EnemyRoster.TABLE, true)


func test_a_mode_is_held_36_ticks_except_panic_and_danger() -> void:
	var g: FoeGait = FoeGait.new()
	g.update(100, T, false, MIN, SETTLE)
	assert_eq(g.mode, T, "the first switch is free")
	for tick: int in range(101, 100 + MIN):
		g.update(tick, F, false, MIN, SETTLE)
		assert_eq(g.mode, T, "held at tick %d" % tick)
	g.update(100 + MIN, F, false, MIN, SETTLE)
	assert_eq(g.mode, F)
	g.update(101 + MIN, T, false, MIN, SETTLE)
	assert_eq(g.mode, F, "an ordinary run waits out the hold")
	g.update(102 + MIN, T, true, MIN, SETTLE)
	assert_eq(g.mode, T, "panic or danger runs at once")
	assert_eq(g.mode_since_tick, 102 + MIN)
	g.update(103 + MIN, F, true, MIN, SETTLE)
	assert_eq(g.mode, T, "urgency never skips the hold into FIGHT")


func test_no_round_for_15_ticks_after_travel_to_fight() -> void:
	var g: FoeGait = FoeGait.new()
	assert_true(g.may_fire(0), "a fresh foe starts settled in FIGHT")
	g.update(0, T, false, MIN, SETTLE)
	assert_false(g.may_fire(10), "no round while travelling")
	g.update(MIN, F, false, MIN, SETTLE)
	assert_eq(g.settle_until_tick, MIN + SETTLE)
	for tick: int in range(MIN, MIN + SETTLE):
		assert_false(g.may_fire(tick), "settling at %d" % tick)
	assert_true(g.may_fire(MIN + SETTLE))


func test_speed_cap_is_045_of_speed_in_fight_and_full_or_panic_in_travel() -> void:
	var cop: EnemyRoster.Archetype = _roster().archetype(&"patrol_cop")
	var g: FoeGait = FoeGait.new()
	assert_almost_eq(g.speed_cap(cop), 0.45 * cop.speed_mps, 0.0001)
	g.update(0, T, false, MIN, SETTLE)
	assert_almost_eq(g.speed_cap(cop), cop.speed_mps, 0.0001)
	g.panic = true
	assert_almost_eq(g.speed_cap(cop), 1.6 * cop.speed_mps, 0.0001)


func test_wanted_and_urgent() -> void:
	var cop: EnemyRoster.Archetype = _roster().archetype(&"patrol_cop")
	assert_eq(FoeGait.wanted(false, false, false), F)
	assert_eq(FoeGait.wanted(true, false, false), T)
	assert_eq(FoeGait.wanted(false, true, false), T)
	assert_eq(FoeGait.wanted(false, false, true), T)
	assert_true(FoeGait.urgent(true, 50.0, cop))
	assert_true(FoeGait.urgent(false, 3.9, cop))
	assert_false(FoeGait.urgent(false, 4.0, cop))


func test_table_gives_the_five_ranged_kinds_their_gait() -> void:
	var r: EnemyRoster = _roster()
	for id: StringName in KINDS + [&"sergeant_mulroney"]:
		assert_almost_eq(r.archetype(id).fight_speed_k, 0.45, 0.0001, id)
	assert_eq(r.archetype(&"robot_gunner").danger_m, 3.0)
	assert_eq(r.archetype(&"sergeant_mulroney").danger_m, 4.0)
	assert_eq(r.archetype(&"riot_cop").fight_speed_k, 1.0, "melee keeps its speed")
	assert_eq(r.archetype(&"riot_cop").danger_m, 0.0)
	assert_eq([r.gait_split, r.gait_min_ticks, r.gait_settle_ticks], [true, MIN, SETTLE])


func test_every_round_is_fired_slow_from_fight() -> void:
	var trace: Trace = _run(true)
	assert_gt(trace.shots, 5, "the wave still shoots")
	assert_gt(trace.travel, 100, "and runs between fights")
	assert_eq(trace.bad, [] as Array[String], "a round fired from TRAVEL or above the fight cap")


func test_legacy_never_consults_the_gait() -> void:
	var legacy: Trace = _run(false)
	assert_eq(legacy.travel, 0)
	assert_ne(legacy.digest, _run(true).digest, "the switch changes the fight")
	if LEGACY_TRACE != 0:
		assert_eq(legacy.digest, LEGACY_TRACE, "legacy = the pre-n31 trace")


func test_a_travelling_foe_carries_its_gun_low() -> void:
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), Events, RngRegistry.new(22).stream(&"combat")
	)
	arena.guard_map = GuardRouteMap.new(Rect2(-20, -20, 40, 40), [], null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	var h: Fighter = arena.squad_ai.spawn_member(arena, Vector2.ONE, &"sergeant_mulroney")
	var e: EnemyAgent = arena.squad_ai.mind_for(h).agent
	arena.tick = 23
	e.shot_tick = arena.tick
	assert_false(FoeGaitDrive.gun_down(arena, h))
	assert_eq(FoeCastView.attack_row(h, arena), 1, "FIGHT shows the shot row")
	e.gait.update(arena.tick, T, true, MIN, SETTLE)
	assert_true(FoeGaitDrive.gun_down(arena, h))
	assert_eq(FoeCastView.attack_row(h, arena), -1, "TRAVEL shows the walk cells")
	arena.squad_ai.gaits.split = false
	assert_false(FoeGaitDrive.gun_down(arena, h), "legacy keeps the gun up")


class Trace:
	extends RefCounted
	var shots: int = 0
	var travel: int = 0
	var bad: Array[String] = []
	var digest: int = 17


## A wave of the five ranged kinds against a Rivet who dashes in and out of their range.
func _run(split: bool) -> Trace:
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), Events, RngRegistry.new(31).stream(&"combat")
	)
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	arena.squad_ai.gaits.split = split
	arena.rivet.hp = 100000
	arena.rivet.max_hp = 100000
	var row: int = 0
	for id: StringName in KINDS + [&"sergeant_mulroney"]:
		var h: Fighter = arena.squad_ai.spawn_member(arena, Vector2(-12, row * 3 - 6), id)
		h.cooldown = 0
		row += 1
	var out: Trace = Trace.new()
	for tick: int in 600:
		arena.rivet.pos = Vector2(8.0 * sin(tick * 0.02), 10.0 * cos(tick * 0.013))
		arena.step(tick)
		_check(arena, tick, out)
	return out


func _check(arena: CombatArena, tick: int, out: Trace) -> void:
	for h: Fighter in arena.hostiles:
		if not arena.squad_ai.minds.has(h.id):
			continue
		var e: EnemyAgent = arena.squad_ai.minds[h.id].agent
		out.travel += int(e.gait.mode == T)
		out.digest = hash([out.digest, h.pos, h.facing, e.shot_tick])
		if e.shot_tick != tick:
			continue
		out.shots += 1
		var cap: float = e.arch.fight_speed_k * e.arch.speed_mps + 0.01
		if arena.squad_ai.gaits.split and (e.gait.mode != F or e.vel.length() > cap):
			out.bad.append("%d %s %d %.3f" % [tick, e.arch.id, e.gait.mode, e.vel.length()])
