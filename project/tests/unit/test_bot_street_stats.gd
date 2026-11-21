extends GutTest


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
