extends Scenario
## rivet-arsenal: the carried melee weapons in the city block's fight (--arena=city --bot=arsenal
## --loadout=katana,chainsaw,electro_baton). With a melee weapon drawn the bot walks into reach of
## the nearest guard (side-stepping cover it stalls on) and swings only there, so the katana,
## chainsaw and baton meet bodies on the live path. Two guards must drop in 30 s, and the run
## replays identical (SIM-05). TST-05: a planted fault (the old stand-off at gun reach,
## melee_close_in = false) must drop none.

const LIMIT_TICKS: int = 30 * SimClock.TICK_RATE
const LOADOUT: Array[StringName] = [&"katana", &"chainsaw", &"electro_baton"]
const EVIDENCE_FILE: String = "rivet-city-melee-telemetry.json"
const MIN_KILLS: int = 2


func run(_tree: SceneTree) -> String:
	var s: ArenaSession = _open(Events, Data)
	s.world.loop().set_input(ArenaArsenalBot.new(s.stage, s.actions))
	s.world.loop().start_recording()
	var tel: Dictionary = _play(s)
	var log: ReplayLog = s.world.loop().finish_recording()
	s.world.free()
	@warning_ignore("return_value_discarded")
	write_evidence(EVIDENCE_FILE, tel)
	if tel["kills"] < MIN_KILLS:
		return "the city melee fight dropped too few guards: %s" % tel
	var divergence: String = _replay(log)
	return divergence if divergence != "" else _planted()


static func _open(bus: EventBus, data: DataStore) -> ArenaSession:
	var s: ArenaSession = ArenaSession.open(bus, data, ArenaSession.MASTER_SEED, null, true)
	for h: ArenaHook in s.stage.hooks:
		if h is ArenaArsenal:
			@warning_ignore("return_value_discarded")
			(h as ArenaArsenal).arm(LOADOUT, true)
	return s


static func _play(s: ArenaSession) -> Dictionary:
	while s.tick() < LIMIT_TICKS:
		s.step()
	return {"wave": s.stage.pit.wave, "kills": s.stage.pit.kills, "ticks": s.tick()}


func _replay(log: ReplayLog) -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var again: ArenaSession = _open(bus, data)
	var divergence: String = again.world.verify_replay(log)
	again.world.free()
	bus.free()
	data.free()
	return "" if divergence == "" else "city melee replay diverged: %s" % divergence


func _planted() -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = _open(bus, data)
	var bot: ArenaArsenalBot = ArenaArsenalBot.new(s.stage, s.actions)
	bot.melee_close_in = false
	s.world.loop().set_input(bot)
	var tel: Dictionary = _play(s)
	s.world.free()
	bus.free()
	data.free()
	if tel["kills"] >= MIN_KILLS:
		return "planted fault not caught: a bot at gun reach still dropped %d" % tel["kills"]
	return ""
