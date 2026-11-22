extends GutTest

var run: GauntletRun
var session: GauntletSession
var waves: GauntletWaves
var arena: CombatArena


func before_each() -> void:
	run = GauntletRun.new()
	run.seed = 7
	var picker: GauntletPilot = GauntletPilot.new()
	picker.configure(&"average", &"greedy", run.seed)
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	session = GauntletSession.open_street(bus, data, run, picker)
	waves = GauntletWaves.attach(session, run, picker, 0)
	arena = session.stage.arena


func after_each() -> void:
	session.close()


func _enter() -> int:
	arena.rivet.pos.x = session.street.current().end_x() + 0.1
	session.step()
	return arena.tick


func _count(row: Dictionary, key: String) -> int:
	return row.get(key, -1)


func _kill(foe: Fighter) -> void:
	arena.damage(foe, foe.max_hp * 10, arena.rivet.id, &"claw")


func test_timeout_keeps_the_squad_fighting_in_the_same_block_and_restarts_the_hud_clock() -> void:
	assert_eq(session.street.timeout_ticks, 90 * SimClock.TICK_RATE)
	var tick: int = _enter() + session.street.timeout_ticks
	var original: Array[Fighter] = arena.hostiles.duplicate()
	var seam: float = session.street.forward_limit
	waves.step(session.stage, tick - 1)
	assert_eq(run.wave, 1)
	waves.step(session.stage, tick)
	assert_eq(run.wave, 2)
	assert_eq(waves.live_wave_count(), 2)
	assert_eq(waves.wave_seconds(tick), 0.0)
	assert_eq(session.street.forward_limit, seam)
	assert_false(waves.done)
	assert_true(waves.pending.is_empty())
	assert_true(run.picks.is_empty())
	var timed_out: bool = run.waves[0].get("timed_out", false)
	assert_true(timed_out)
	assert_false(run.waves[0].has("seconds"))
	assert_false(run.waves[0].has("shots"))
	assert_eq(_count(run.waves[0], "spawn_delayed"), 0)
	assert_eq(_count(run.waves[1], "spawn_delayed"), 0)
	for foe: Fighter in original:
		assert_true(foe.alive() and arena.hostiles.has(foe) and arena.squad_ai.owns(foe))
	var hud: GauntletHud = GauntletHud.new()
	hud.session = session
	hud.run = run
	hud.waves = waves
	add_child(hud)
	hud._process(0.0)
	assert_eq(hud._wave.text, "Wave 2 - 2 alive")
	hud.free()


func test_three_waves_close_their_own_rows_then_award_each_pick() -> void:
	waves.manual_picks = true
	waves._limit = 3
	var first: int = _enter()
	var timeout: int = session.street.timeout_ticks
	var old: Array[Fighter] = arena.hostiles.duplicate()
	waves.step(session.stage, first + timeout)
	waves.step(session.stage, first + timeout * 2)
	assert_eq(waves.live_wave_count(), 3)
	var timed_out: bool = run.waves[1].get("timed_out", false)
	assert_true(timed_out)
	var newest: Array[Fighter] = waves._live[-1].members.duplicate()
	arena.damage(old[0], old[0].hp * 0.25, arena.rivet.id, &"claw")
	for foe: Fighter in old:
		_kill(foe)
	var tick: int = first + timeout * 2 + 1
	waves.step(session.stage, tick)
	assert_eq(waves.live_wave_count(), 2)
	assert_eq(_count(run.waves[0], "hits"), old.size() + 1)
	assert_eq(_count(run.waves[0], "hits_melee"), old.size() + 1)
	var seconds: float = run.waves[0]["seconds"]
	assert_almost_eq(seconds, (tick - first) * SimClock.TICK_DT, 0.00001)
	for foe: Fighter in newest:
		_kill(foe)
	waves.step(session.stage, tick + 1)
	assert_eq(waves.live_wave_count(), 1)
	assert_eq(_count(run.waves[2], "hits"), newest.size())
	assert_true(is_finite(session.street.forward_limit))
	assert_eq(waves.owed_remaining, 0)
	for foe: Fighter in arena.hostiles:
		_kill(foe)
	waves.step(session.stage, tick + 2)
	assert_eq(waves.live_wave_count(), 0)
	assert_eq(session.street.forward_limit, INF)
	_take_three()


func _take_three() -> void:
	assert_eq(waves.owed_total, 3)
	for n: int in range(1, 4):
		assert_eq(waves.owed_index, n)
		assert_eq(waves.owed_remaining, 4 - n)
		assert_false(waves.done)
		assert_false(waves.choose(-1))
		var offered: Array[StringName] = waves.pending.duplicate()
		assert_true(waves.choose(0))
		assert_eq(run.picks[-1], {"wave": n, "offered": offered, "taken": offered[0]})
	assert_true(waves.done)
	assert_eq(waves.owed_remaining, 0)
	assert_true(waves.pending.is_empty())


func test_cap_refills_in_roster_order_and_starts_a_queued_clock_on_first_spawn() -> void:
	assert_eq(session.street.max_alive, 40)
	session.street.max_alive = 2
	var tick: int = _enter()
	var roster: Array[StringName] = waves._composer.compose(1)
	assert_eq(arena.hostiles.size(), 2)
	assert_eq(_count(run.waves[0], "spawn_delayed"), roster.size() - 2)
	tick += session.street.timeout_ticks
	waves.step(session.stage, tick)
	assert_eq(run.wave, 1)
	assert_eq(waves.live_wave_count(), 1)
	for i: int in range(2, roster.size()):
		_kill(arena.hostiles[i - 2])
		tick += 1
		waves.step(session.stage, tick)
		assert_eq(arena.hostiles.size(), i + 1)
		assert_eq(arena.hostiles[i].archetype, roster[i])
		assert_eq(run.wave, 1)
	tick += session.street.timeout_ticks
	waves.step(session.stage, tick)
	assert_eq(run.wave, 1)
	_kill(arena.hostiles[-2])
	waves.step(session.stage, tick + 1)
	assert_eq(run.wave, 2)
	assert_eq(waves.live_wave_count(), 2)
	assert_eq(waves.wave_seconds(tick + 1), 0.0)
	assert_eq(_count(run.waves[1], "spawn_delayed"), waves._composer.compose(2).size())
	assert_eq(arena.hostiles.size(), roster.size() + 1)
	assert_true(arena.hostiles[-2].alive() and arena.hostiles[-1].alive())


func test_headless_pilot_takes_both_picks_only_after_the_limited_stack_is_clear() -> void:
	waves._limit = 2
	var tick: int = _enter() + session.street.timeout_ticks
	waves.step(session.stage, tick)
	waves.step(session.stage, tick + session.street.timeout_ticks)
	assert_eq(run.wave, 2)
	assert_true(run.picks.is_empty())
	assert_false(waves.done)
	for foe: Fighter in arena.hostiles:
		_kill(foe)
	waves.step(session.stage, tick + session.street.timeout_ticks + 1)
	assert_true(waves.done)
	assert_true(run.alive)
	assert_eq(run.picks.size(), 2)
	assert_eq(_count(run.picks[0], "wave"), 1)
	assert_eq(_count(run.picks[1], "wave"), 2)


func test_an_old_member_can_kill_rivet_in_the_newest_live_wave() -> void:
	var tick: int = _enter() + session.street.timeout_ticks
	var killer: Fighter = arena.hostiles[0]
	waves.step(session.stage, tick)
	arena.damage(arena.rivet, arena.rivet.max_hp, killer.id, &"baton", &"melee")
	waves.step(session.stage, tick + 1)
	assert_true(waves.done)
	var death: Dictionary = run.to_result()["death"]
	assert_eq(death, {"wave": 2, "by": String(killer.archetype)})
	for row: Dictionary in run.waves:
		assert_false(row.has("seconds"))
		assert_true(row.has("shots"))
	assert_true(run.picks.is_empty())


func test_death_after_the_latest_clear_names_the_older_wave_still_fighting() -> void:
	var tick: int = _enter() + session.street.timeout_ticks
	waves.step(session.stage, tick)
	for foe: Fighter in waves._live[-1].members:
		_kill(foe)
	waves.step(session.stage, tick + 1)
	arena.damage(arena.rivet, arena.rivet.max_hp, arena.hostiles[0].id, &"baton")
	waves.step(session.stage, tick + 2)
	assert_eq(run.wave, 2)
	assert_eq(run.death_wave, 1)
