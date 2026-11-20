extends GutTest


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
