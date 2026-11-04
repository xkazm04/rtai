extends Scenario
## rivet-arsenal: a carried melee weapon in the live arena's real fight. Rivet carries the katana
## (ArenaArsenal.arm, as --loadout=katana does) and ArenaRivetBot plays the claw cops station:
## every press now swings the katana's combo (melee_weapons.json), the hits are dealt as `katana`,
## at least four cops drop, no round is fired, and the run replays identical on a fresh world.
## TST-05: a planted fault (the katana's reach cut to 0.3 m) must whiff and drop fewer cops.

const LIMIT_TICKS: int = 30 * SimClock.TICK_RATE
const LOADOUT: Array[StringName] = [&"katana"]
const STATION: String = "rivet_claw_cops"
const EVIDENCE_FILE: String = "rivet-katana-telemetry.json"


func run(_tree: SceneTree) -> String:
	var s: ArenaSession = _open(Events, Data)
	var bot: ArenaRivetBot = ArenaRivetBot.new(s.stage, s.actions)
	s.world.loop().set_input(bot)
	s.world.loop().start_recording()
	var tel: Dictionary = _play(s, bot)
	var log: ReplayLog = s.world.loop().finish_recording()
	s.world.free()
	@warning_ignore("return_value_discarded")
	write_evidence(EVIDENCE_FILE, tel)
	var reason: String = _judge(tel)
	if reason != "":
		return reason
	var divergence: String = _replay(log)
	return divergence if divergence != "" else _planted()


static func _open(bus: EventBus, data: DataStore) -> ArenaSession:
	var s: ArenaSession = ArenaSession.open(bus, data)
	for h: ArenaHook in s.stage.hooks:
		if h is ArenaArsenal:
			@warning_ignore("return_value_discarded")
			(h as ArenaArsenal).arm(LOADOUT, true)
	return s


static func _play(s: ArenaSession, bot: ArenaRivetBot) -> Dictionary:
	var weapon: StringName = &""
	while s.tick() < LIMIT_TICKS and bot.finished_tick < 0:
		s.step()
		if s.stage.pilot.melee.busy():
			weapon = s.stage.pilot.melee.weapon_id
	var station: Dictionary = s.stage.telemetry_dict().get(STATION, {})
	var tel: Dictionary = station.duplicate()
	tel["swing_weapon"] = String(weapon)
	tel["shots"] = s.stage.arena.shots.size()
	tel["finished_tick"] = bot.finished_tick
	return tel


func _judge(tel: Dictionary) -> String:
	if tel["finished_tick"] < 0:
		return "the rivet bot did not finish with the katana: %s" % tel
	if tel["swing_weapon"] != "katana" or tel["shots"] != 0:
		return "the swings were not the katana's, or a round left: %s" % tel
	if tel.get("claw_kills", 0) < 4 or tel.get("claw_hits", 0) < 8:
		return "the katana dropped too few cops: %s" % tel
	return ""


func _replay(log: ReplayLog) -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var again: ArenaSession = _open(bus, data)
	var divergence: String = again.world.verify_replay(log)
	again.world.free()
	bus.free()
	data.free()
	return "" if divergence == "" else "katana replay diverged: %s" % divergence


func _planted() -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = _open(bus, data)
	var t: MeleeTable = MeleeTable.weapon(&"katana")
	for h: MeleeHit in t.hits:
		h.reach_m = 0.3
		h.lunge_m = 0.0
	s.stage.pilot._melees[&"katana"] = PlayerMelee.new(t)
	var bot: ArenaRivetBot = ArenaRivetBot.new(s.stage, s.actions)
	s.world.loop().set_input(bot)
	var tel: Dictionary = _play(s, bot)
	s.world.free()
	bus.free()
	data.free()
	if tel.get("claw_kills", 0) >= 4:
		return "the planted 0.3 m katana still dropped the cops: %s" % tel
	return ""
