extends Scenario
## rivet-arsenal: the arsenal's fight on the city proving block (--arena=city --bot=arsenal). On
## the 12 m city a pit guard holds behind a kerb car or a corner; the bot then walks straight at
## him after stuck_ticks in reach without a shot, so the block's fight keeps moving. With a pistol
## it must reach the third wave and drop five guards in 40 s, and the run replays identical
## (SIM-05). TST-05: a planted fault (neither stuck_ticks nor GunplayBot's flank ever runs
## out) must stall in the first wave.
## The dev arena's pit must still fight from its entry walk (the close-in once hijacked the walk
## in, where a guard is already in reach: 0 shots): two guards down in 20 s there.

const LIMIT_TICKS: int = 40 * SimClock.TICK_RATE
const LOADOUT: Array[StringName] = [&"pistol"]
const EVIDENCE_FILE: String = "rivet-city-fight-telemetry.json"
const MIN_WAVE: int = 3
const MIN_KILLS: int = 5


func run(_tree: SceneTree) -> String:
	var s: ArenaSession = _open(Events, Data)
	s.world.loop().set_input(ArenaArsenalBot.new(s.stage, s.actions))
	s.world.loop().start_recording()
	var tel: Dictionary = _play(s)
	var log: ReplayLog = s.world.loop().finish_recording()
	s.world.free()
	@warning_ignore("return_value_discarded")
	write_evidence(EVIDENCE_FILE, tel)
	if tel["wave"] < MIN_WAVE or tel["kills"] < MIN_KILLS:
		return "the city fight stalled: %s" % tel
	var divergence: String = _replay(log)
	if divergence != "":
		return divergence
	var pit: String = _pit()
	return pit if pit != "" else _planted()


static func _open(bus: EventBus, data: DataStore, on_city: bool = true) -> ArenaSession:
	var s: ArenaSession = ArenaSession.open(bus, data, ArenaSession.MASTER_SEED, null, on_city)
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
	return "" if divergence == "" else "city fight replay diverged: %s" % divergence


func _planted() -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = _open(bus, data)
	var bot: ArenaArsenalBot = ArenaArsenalBot.new(s.stage, s.actions)
	bot.never_close_in(LIMIT_TICKS * 2)
	s.world.loop().set_input(bot)
	var tel: Dictionary = _play(s)
	s.world.free()
	bus.free()
	data.free()
	if tel["wave"] >= MIN_WAVE:
		return (
			"planted fault not caught: a bot that never closes in still reached wave %d"
			% tel["wave"]
		)
	return ""


## The pit in the dev arena (teleported in, as --start=pit): the bot's entry walk then the fight.
func _pit() -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = _open(bus, data, false)
	for a: ArenaPlan.Area in s.plan.areas:
		if a.id == "pit":
			s.stage.arena.rivet.pos = a.rect.get_center()
	s.world.loop().set_input(ArenaArsenalBot.new(s.stage, s.actions))
	while s.tick() < LIMIT_TICKS / 2:
		s.step()
	var kills: int = s.stage.pit.kills
	s.world.free()
	bus.free()
	data.free()
	return "" if kills >= 2 else "the pit fight never started: %d kills in 20 s" % kills
