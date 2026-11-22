extends GutTest
## Close the full initial centre-to-centre gap on an unobstructed straight, without using
## body radius as a head start. The pursued speed is measured on a panicking gauntlet cop.


func _flee_speed() -> float:
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), Events, RngRegistry.new(24).stream(&"combat")
	)
	arena.guard_map = GuardRouteMap.new(Rect2(-80, -80, 160, 160), [], null, 0.45)
	var squad: ArenaSquad = ArenaSquad.new(arena.guard_map)
	arena.squad_ai = squad
	var cop: Fighter = squad.spawn_member(arena, Vector2.RIGHT * 10.0, &"patrol_cop")
	cop.pos = Vector2.RIGHT * 10.0
	for i: int in 4:
		var fallen: Fighter = squad.spawn_member(arena, Vector2.LEFT * 10.0, &"patrol_cop")
		fallen.hp = 0.0
	var start: Vector2
	for tick: int in 91:
		arena.step(tick)
		if tick == 30:
			start = cop.pos
	assert_eq(squad.mind_for(cop).motion, EnemyAgent.State.PANIC)
	return cop.pos.distance_to(start)  # 60 fixed ticks


func test_pursuit_speed_and_time_to_close_ten_metres() -> void:
	var flee: float = _flee_speed()
	assert_almost_eq(flee, 3.2, 0.002, "open-ground patrol cop panic speed")
	var plain: Vector2 = _pursuit(flee, false, false)
	var burst: Vector2 = _pursuit(flee, true, false)
	var held: Vector2 = _pursuit(flee, true, true)
	assert_gt(burst.x, plain.x)
	assert_gt(held.x, burst.x)
	assert_lt(burst.y, plain.y)
	assert_lt(held.y, burst.y)


func _pursuit(flee: float, use_dash: bool, hold: bool) -> Vector2:
	var m: PlayerMotion = PlayerMotion.shipped()
	var a: PlayerActions = PlayerActions.shipped()
	m.dash.hold_sprints = hold
	var walk: float = CombatTuning.shipped().rivet["walk_mps"]
	var period: int = m.dash.ticks + m.dash.cooldown_ticks
	var pos: float = 0.0
	var warm: float = 0.0
	var caught: int = 0
	var previous: int = 0
	for tick: int in period * 11:
		var cycle: int = tick % period
		var down: bool = use_dash and (cycle == 0 or (hold and cycle < period - 1))
		var raw: TickInput = TickInput.new(1 << a.bit(&"dash") if down else 0, 127, 0)
		pos += m.step(PlayerCommand.decode(raw, previous, a), walk, a).x
		previous = raw.buttons
		if tick + 1 == period:
			warm = pos
		if caught == 0 and pos >= 10.0 + flee * (tick + 1) * SimClock.TICK_DT:
			caught = tick + 1
	assert_gt(caught, 0)
	assert_eq(m.dashes, 11 if use_dash else 0)
	var speed: float = (pos - warm) / (period * 10 * SimClock.TICK_DT)
	Log.info(
		"dash_probe",
		"cop=%.3fm/s dash=%s hold=%s net=%.3fm/s close=%dt" % [flee, use_dash, hold, speed, caught]
	)
	return Vector2(speed, caught * SimClock.TICK_DT)
