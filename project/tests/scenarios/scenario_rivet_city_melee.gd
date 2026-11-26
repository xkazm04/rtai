extends Scenario
## rivet-arsenal: the carried melee weapons in the city block's fight (--arena=city --bot=arsenal
## --loadout=katana,chainsaw,electro_baton). With a melee weapon drawn the bot walks into reach of
## the nearest guard (side-stepping cover it stalls on) and swings only there, so the katana,
## chainsaw and baton meet bodies on the live path. Two guards must drop in 30 s, and the run
## replays identical (SIM-05). TST-05: a planted fault (the old stand-off at gun reach,
## melee_close_in = false, swinging only from past STAND_OFF_M) must fail to land kills with the
## full carried loadout.

const LIMIT_TICKS: int = 30 * SimClock.TICK_RATE
const LOADOUT: Array[StringName] = [&"katana", &"chainsaw", &"electro_baton"]
const EVIDENCE_FILE: String = "rivet-city-melee-telemetry.json"
const MIN_KILLS: int = 2
## The planted fault's stand-off: past the longest drawn sweep reach (2.25 m, n31 melee 02p3b)
## plus a guard's body radius (0.45 m) and a 0.8 m margin. A guard walking into Rivet inside it is
## not swung at, so only a bot that closes in lands the loadout.
const STAND_OFF_M: float = 3.5


## The planted fault's input: the stand-off bot, its fire held while a standing guard is inside
## STAND_OFF_M.
class StandOff:
	extends InputSource
	var bot: ArenaArsenalBot

	func _init(p_bot: ArenaArsenalBot) -> void:
		bot = p_bot

	func sample(tick: int) -> TickInput:
		var t: TickInput = bot.sample(tick)
		var rivet: Vector2 = bot.stage.arena.rivet.pos
		for f: Fighter in bot.stage.pit.standing:
			if f.alive() and rivet.distance_to(f.pos) <= STAND_OFF_M:
				t.buttons &= ~(1 << bot.actions.bit(&"fire"))
				break
		return t


func run(_tree: SceneTree) -> String:
	var s: ArenaSession = _open(Events, Data)
	s.world.loop().set_input(ArenaArsenalBot.new(s.stage, s.actions))
	s.world.loop().start_recording()
	var tel: Dictionary = _play(s)
	var log: ReplayLog = s.world.loop().finish_recording()
	s.world.free()
	@warning_ignore("return_value_discarded")
	write_evidence(EVIDENCE_FILE, tel)
	if not _met_loadout(tel):
		return "the city melee fight did not land the loadout: %s" % tel
	var divergence: String = _replay(log)
	return divergence if divergence != "" else _planted()


static func _open(bus: EventBus, data: DataStore) -> ArenaSession:
	# This tests Rivet's melee approach. Squad fighters can enter reach even when the bot hangs back.
	var options: ArenaArgs = ArenaArgs.parse(["--arena=city", "--enemy-brain=guard"])
	var s: ArenaSession = ArenaSession.open_with_args(
		bus, data, ArenaSession.MASTER_SEED, null, options
	)
	for h: ArenaHook in s.stage.hooks:
		if h is ArenaArsenal:
			@warning_ignore("return_value_discarded")
			(h as ArenaArsenal).arm(LOADOUT, true)
	return s


static func _play(s: ArenaSession) -> Dictionary:
	var weapons: Dictionary[StringName, bool] = {}
	var landed: Callable = func(
		victim: Fighter, weapon: StringName, _dir: Vector2, _at: Vector2, _kind: StringName
	) -> void:
		if victim in s.stage.pit.standing and weapon in LOADOUT:
			weapons[weapon] = true
	@warning_ignore("return_value_discarded")
	s.stage.arena.kill_landed.connect(landed)
	while s.tick() < LIMIT_TICKS:
		s.step()
	s.stage.arena.kill_landed.disconnect(landed)
	return {
		"weapons": weapons.keys(),
		"wave": s.stage.pit.wave,
		"kills": s.stage.pit.kills,
		"ticks": s.tick()
	}


static func _met_loadout(tel: Dictionary) -> bool:
	var weapons: Array = tel.weapons
	return tel.kills >= MIN_KILLS and weapons.size() == LOADOUT.size()


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
	bot.never_close_in(LIMIT_TICKS + 1)
	s.world.loop().set_input(StandOff.new(bot))
	var tel: Dictionary = _play(s)
	s.world.free()
	bus.free()
	data.free()
	if _met_loadout(tel):
		return "planted fault not caught: a bot at gun reach landed the full loadout: %s" % tel
	return ""
