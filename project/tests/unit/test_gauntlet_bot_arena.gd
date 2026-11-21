extends GutTest


func test_street_pilot_drives_bound_session_and_returns_greedy_offer_index() -> void:
	var pilot: GauntletTestPlayer = GauntletTestPlayer.new()
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var run: GauntletRun = GauntletRun.new()
	pilot.configure(&"average", &"greedy", 3)
	var session: ArenaSession = ArenaSession.open_with_args(bus, data, 3, pilot, ArenaArgs.new())
	pilot.bind(run, session)
	var before: Vector2 = session.stage.arena.rivet.pos
	for tick: int in 60:
		session.step()
	var after: Vector2 = session.stage.arena.rivet.pos
	assert_ne(after, before)
	assert_eq(pilot.profile(), &"average")
	assert_eq(pilot.pick([&"weapon_pistol", &"stat_damage_10", &"ghost_tonnage"]), 2)
	assert_eq(pilot.pick([]), -1)
	Log.info("gauntlet", "seed 3 average: Rivet moved %s to %s in 60 ticks" % [before, after])
	session.close()
	bus.free()
	data.free()


func test_recorded_pit_inputs_replay_without_sampling_the_brain() -> void:
	var events: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var options: ArenaArgs = ArenaArgs.new()
	var first: ArenaSession = ArenaSession.open_with_args(events, data, 83, null, options)
	var view: BotViewArena = BotViewArena.new(first.stage, first.actions)
	var bot: GauntletBot = GauntletBot.new(view, first.actions, BotProfile.shipped(&"expert"), 83)
	first.world.loop().set_input(bot)
	first.world.loop().start_recording()
	for tick: int in 420:
		first.step()
	var recorded: ReplayLog = first.world.loop().finish_recording()
	assert_gt(first.stage.pit.wave, 0)
	assert_gt(bot.counters.shots, 0)
	first.close()
	events.free()
	data.free()

	events = EventBus.new()
	data = DataStore.new()
	var second: ArenaSession = ArenaSession.open_with_args(events, data, 83, null, options)
	var replayed: ReplayLog = second.world.loop().replay(recorded)
	assert_eq(recorded.first_divergence(replayed), "")
	second.close()
	events.free()
	data.free()


func test_adapter_reads_squad_windup_and_preserves_projectile_identity() -> void:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var session: ArenaSession = ArenaSession.open_with_args(bus, data, 14, null, ArenaArgs.new())
	var arena: CombatArena = session.stage.arena
	var squad: ArenaSquad = arena.squad_ai
	var foe: Fighter = squad.spawn_member(arena, Vector2(5, 8), &"robot_gunner")
	session.stage.pit.standing.append(foe)
	@warning_ignore("return_value_discarded")
	squad.assign(arena)
	squad.minds[foe.id].agent.state = EnemyAgent.State.WINDUP
	var shot: Shot = Shot.new()
	shot.from_rivet = false
	arena.shots.append(shot)
	arena.shots.append(Shot.new())
	var view: BotViewArena = BotViewArena.new(session.stage, session.actions)
	view.refresh()
	assert_eq(view.hostiles()[0].tell, &"large")
	assert_eq(view.hostiles()[0].archetype, &"robot_gunner")
	assert_eq(view.incoming().size(), 1)
	assert_eq(view.incoming()[0].size, &"small")
	var id: int = view.incoming()[0].id
	squad.minds[foe.id].agent.state = EnemyAgent.State.RECOVER
	view.refresh()
	assert_eq(view.hostiles()[0].tell, &"")
	assert_eq(view.incoming()[0].id, id)
	session.close()
	bus.free()
	data.free()
