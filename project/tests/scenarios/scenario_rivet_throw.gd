extends Scenario
## rivet-arsenal: the molotov's wind-up in the live arena's real fight. Rivet carries molotovs
## (ArenaArsenal.arm, as --loadout=molotov does) and ArenaArsenalBot plays gunplay's pit with the
## trigger held. Every bottle must leave exactly windup_ticks after its wind-up started
## (PlayerThrow over rivet_arsenal.json thrown), at least three must leave, and the run replays
## identical (SIM-05). TST-05: a planted fault (windup_ticks 0) must throw with no wind-up.

const LIMIT_TICKS: int = 30 * SimClock.TICK_RATE
const LOADOUT: Array[StringName] = [&"molotov"]
const EVIDENCE_FILE: String = "rivet-throw-telemetry.json"


func run(_tree: SceneTree) -> String:
	var s: ArenaSession = _open(Events, Data)
	s.world.loop().set_input(ArenaArsenalBot.new(s.stage, s.actions))
	s.world.loop().start_recording()
	var tel: Dictionary = _play(s)
	var log: ReplayLog = s.world.loop().finish_recording()
	s.world.free()
	@warning_ignore("return_value_discarded")
	write_evidence(EVIDENCE_FILE, tel)
	var w: int = ArsenalTable.shipped().grips[&"thrown"].windup_ticks
	if tel["throws"] < 3 or tel["lead_min"] != w or tel["lead_max"] != w:
		return "the bottles did not leave %d ticks into their wind-ups: %s" % [w, tel]
	var divergence: String = _replay(log)
	return divergence if divergence != "" else _planted()


static func _open(bus: EventBus, data: DataStore) -> ArenaSession:
	var s: ArenaSession = ArenaSession.open(bus, data)
	for h: ArenaHook in s.stage.hooks:
		if h is ArenaArsenal:
			@warning_ignore("return_value_discarded")
			(h as ArenaArsenal).arm(LOADOUT, true)
	return s


## Steps the run; for each bottle that left, the ticks since its wind-up started.
static func _play(s: ArenaSession) -> Dictionary:
	var winds: int = 0
	var wind_tick: int = -1
	var shots: int = 0
	var leads: Array[int] = []
	while s.tick() < LIMIT_TICKS:
		s.step()
		var t: PlayerThrow = s.stage.pilot.throw
		if t.winds != winds:
			winds = t.winds
			wind_tick = s.tick()
		var gun: GunHand = s.stage.arena.gun
		if gun != null and gun.shots_fired != shots:
			shots = gun.shots_fired
			leads.append(s.tick() - wind_tick + 1 if wind_tick >= 0 else 0)
	var tel: Dictionary = {"throws": leads.size(), "winds": winds, "ticks": s.tick()}
	tel["lead_min"] = leads.min() if not leads.is_empty() else -1
	tel["lead_max"] = leads.max() if not leads.is_empty() else -1
	return tel


func _replay(log: ReplayLog) -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var again: ArenaSession = _open(bus, data)
	var divergence: String = again.world.verify_replay(log)
	again.world.free()
	bus.free()
	data.free()
	return "" if divergence == "" else "throw replay diverged: %s" % divergence


func _planted() -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = _open(bus, data)
	var table: ArsenalTable = ArsenalTable.shipped()
	table.grips[&"thrown"].windup_ticks = 0
	s.stage.pilot.hold.table = table
	s.world.loop().set_input(ArenaArsenalBot.new(s.stage, s.actions))
	var tel: Dictionary = _play(s)
	s.world.free()
	bus.free()
	data.free()
	if tel["winds"] > 0 or tel["throws"] < 1:
		return "the planted windup 0 still wound up (or never threw): %s" % tel
	return ""
