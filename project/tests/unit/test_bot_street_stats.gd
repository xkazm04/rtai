extends GutTest


func test_hp_cover_and_rolls_reach_the_closed_result_row() -> void:
	var run: GauntletRun = GauntletRun.new()
	var pilot: GauntletTestPlayer = GauntletTestPlayer.new()
	pilot.configure(&"average", &"greedy", 3)
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	var session: GauntletSession = GauntletSession.open_street(bus, data, run, pilot)
	pilot.bind(run, session)
	var waves: GauntletWaves = GauntletWaves.attach(session, run, pilot, 1)
	var arena: CombatArena = session.stage.arena
	arena.rivet.pos.x = session.street.current().end_x() + 0.1
	session.step()
	pilot._brain._view.refresh()
	var start: float = arena.rivet.hp
	var capacity: float = arena.rivet.max_hp
	arena.rivet.hp -= 15.0
	arena.rivet.hurt_tick = arena.tick
	pilot._brain.counters.cover_ticks += 3
	var stats: BotStreetStats = session.stage.hooks[-2] as BotStreetStats
	stats.step(session.stage, 2)
	arena.rivet.hp += 4.0
	stats.step(session.stage, 3)
	arena.rivet.hp += 2.0
	stats.step(session.stage, 4)
	for foe: Fighter in arena.hostiles:
		arena.damage(foe, foe.max_hp, arena.rivet.id, &"claw")
	session.pilot.motion._start_roll(Vector2.RIGHT)
	session.step()
	var rows: Array = run.to_result().waves
	var row: Dictionary = rows[0]
	var cover: int = row.cover_ticks
	var rolls: int = row.rolls
	var hp: Dictionary = row.hp
	assert_eq(cover, 3)
	assert_true(waves.done)
	assert_eq(rolls, 1)
	var expected: Dictionary = {"start": start, "min": start - 15, "end": start - 9}
	expected.merge({"max": capacity, "repaired": 6.0})
	assert_eq(hp, expected)
	session.close()


func test_last_machine_hit_and_settled_form_are_measured_on_the_kill_tick() -> void:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var run: GauntletRun = GauntletRun.new()
	var session: GauntletSession = GauntletSession.open_street(bus, data, run)
	var arena: CombatArena = session.stage.arena
	var foe: Fighter = arena.squad_ai.spawn_member(arena, Vector2(3, 0), &"war_machine")
	foe.pos = arena.rivet.pos + Vector2.RIGHT
	var view: BotViewArena = BotViewArena.new(session.stage, session.actions, true)
	var counts: BotCounters = BotCounters.new()
	var stats: BotStreetStats = BotStreetStats.new(run, view, counts)
	run.begin_wave({"war_machine": 1})
	view.refresh()
	view.player().form = &"tonnage"
	var hp: float = foe.hp
	foe.hp = 0.0
	counts.cover_ticks = 1
	stats.step(session.stage, 1)
	var row: Dictionary = run.waves[0]
	var measured: Dictionary = row.machine
	var forms: Dictionary = row.form_seconds
	var loss: float = measured.hp_lost
	var ticks: int = measured.ticks
	var reach: int = measured.claw_reach_ticks
	var cover: int = measured.cover_ticks
	var tonnage: float = forms.tonnage
	assert_eq(loss, hp)
	assert_eq(ticks, 1)
	assert_eq(reach, 1)
	assert_eq(cover, 1)
	assert_eq(tonnage, SimClock.TICK_DT)
	row.shots = 0  # GauntletWaves has closed this row.
	stats.step(session.stage, 2)
	ticks = measured.ticks
	assert_eq(ticks, 1)
	session.close()
	bus.free()
	data.free()


func test_wave_counters_subtract_the_snapshot_and_omit_unchanged_forms() -> void:
	var counts: BotCounters = BotCounters.new()
	counts.guard_ticks = 2
	counts.form_ticks[&"tonnage"] = 2
	counts.form_ticks[&"kerf"] = 4
	var before: Dictionary = counts.report()
	counts.guard_ticks += 3
	counts.form_ticks[&"tonnage"] += 3
	counts.form_ticks[&"ohm"] = 1
	var delta: Dictionary = counts.since(before)
	var guard_ticks: int = delta.guard_ticks
	var form_ticks: Dictionary = delta.form_ticks
	assert_eq(guard_ticks, 3)
	assert_eq(form_ticks, {&"tonnage": 3, &"ohm": 1})


func test_wave_row_reports_elapsed_seconds_and_every_form_in_order() -> void:
	var counts: BotCounters = BotCounters.new()
	counts.form_ticks[&"tonnage"] = 3
	var attempt: Dictionary = {
		"n": 2,
		"status": "cleared",
		"enemies": {},
		"damage_taken": 1.0,
		"counters": counts.report(),
		"start_tick": 120,
		"end_tick": 180
	}
	var order: Array[StringName] = [&"tonnage", &"kerf"]
	var row: Dictionary = BotCounters.wave_row(attempt, order)
	var seconds: float = row.seconds
	var form_seconds: Dictionary = row.form_seconds
	assert_eq(seconds, 1.0)
	assert_eq(form_seconds, {&"tonnage": 3 * SimClock.TICK_DT, &"kerf": 0.0})
	attempt.status = "tick_limit"
	assert_false(BotCounters.wave_row(attempt, order).has("seconds"))
