extends Scenario
## rivet-arsenal: the plasma sword's timed deflect in the live arena's real fight. Rivet carries
## the plasma sword (ArenaArsenal.arm, as --loadout=plasma_sword does) and ArenaArsenalBot plays
## gunplay's pit (walk in, each wave at reach, the held attack swings): the pit guards' rounds that
## meet a slash's active ticks in front of him fly back as his (PlayerDeflect). Judged: at least
## one deflect, the swings dealt as `plasma_sword`, and the run replays identical (SIM-05).
## TST-05: a planted fault (the plasma sword row with deflect_m 0) must never deflect.
## The bot keeps gunplay's stand-off at reach (melee_close_in false): the deflect is judged on
## rounds flying in, not on the walk into claw reach that scenario_rivet_city_melee judges.

const LIMIT_TICKS: int = 40 * SimClock.TICK_RATE
const LOADOUT: Array[StringName] = [&"plasma_sword"]
const EVIDENCE_FILE: String = "rivet-deflect-telemetry.json"


func run(_tree: SceneTree) -> String:
	var s: ArenaSession = _open(Events, Data)
	s.world.loop().set_input(_bot(s))
	s.world.loop().start_recording()
	var tel: Dictionary = _play(s)
	var log: ReplayLog = s.world.loop().finish_recording()
	s.world.free()
	@warning_ignore("return_value_discarded")
	write_evidence(EVIDENCE_FILE, tel)
	if tel["swing_weapon"] != "plasma_sword" or tel["deflects"] < 1:
		return "no plasma sword deflect in the pit: %s" % tel
	var divergence: String = _replay(log)
	return divergence if divergence != "" else _planted()


static func _open(bus: EventBus, data: DataStore) -> ArenaSession:
	var s: ArenaSession = ArenaSession.open(bus, data)
	for h: ArenaHook in s.stage.hooks:
		if h is ArenaArsenal:
			@warning_ignore("return_value_discarded")
			(h as ArenaArsenal).arm(LOADOUT, true)
	return s


static func _play(s: ArenaSession) -> Dictionary:
	var weapon: StringName = &""
	var first: int = -1
	while s.tick() < LIMIT_TICKS:
		s.step()
		var m: PlayerMelee = s.stage.pilot.melee
		if m.busy():
			weapon = m.weapon_id
		if first < 0 and m.deflects > 0:
			first = s.tick()
	var tel: Dictionary = {}
	tel["swing_weapon"] = String(weapon)
	tel["deflects"] = s.stage.pilot.melee.deflects
	tel["first_deflect_tick"] = first
	tel["swings"] = s.stage.pilot.melee_swings
	tel["ticks"] = s.tick()
	return tel


func _replay(log: ReplayLog) -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var again: ArenaSession = _open(bus, data)
	var divergence: String = again.world.verify_replay(log)
	again.world.free()
	bus.free()
	data.free()
	return "" if divergence == "" else "deflect replay diverged: %s" % divergence


func _planted() -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = _open(bus, data)
	var t: MeleeTable = MeleeTable.weapon(&"plasma_sword")
	t.deflect_m = 0.0
	s.stage.pilot._melees[&"plasma_sword"] = PlayerMelee.new(t)
	s.world.loop().set_input(_bot(s))
	var tel: Dictionary = _play(s)
	s.world.free()
	bus.free()
	data.free()
	if tel["deflects"] > 0:
		return "the planted deflect_m 0 sword still deflected: %s" % tel
	return ""


static func _bot(s: ArenaSession) -> ArenaArsenalBot:
	var bot: ArenaArsenalBot = ArenaArsenalBot.new(s.stage, s.actions)
	bot.melee_close_in = false
	return bot
