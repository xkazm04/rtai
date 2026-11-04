extends Scenario
## The showcase lane's scripted fight (CombatReel, `--bot=reel`) on the dev arena: every beat runs,
## the melee beat and the gun beat each drop pit guards, Rivet stays up, and the run replays
## identical on a fresh world (SIM-05). TST-05: a planted fault (every button off) kills nobody.

const EVIDENCE_FILE: String = "showcase-reel-telemetry.json"


func run(_tree: SceneTree) -> String:
	var s: ArenaSession = ArenaSession.open(Events, Data)
	var reel: CombatReel = CombatReel.new(s.stage, s.actions)
	s.world.loop().set_input(reel)
	s.world.loop().start_recording()
	while s.tick() < reel.length():
		s.step()
	var log: ReplayLog = s.world.loop().finish_recording()
	var tel: Dictionary = s.stage.telemetry_dict()
	for id: StringName in reel.kills_by_beat:
		tel["kills_" + String(id)] = reel.kills_by_beat[id]
	@warning_ignore("return_value_discarded")
	write_evidence(EVIDENCE_FILE, tel)
	var problem: String = _judge(s, reel)
	s.world.free()
	if problem != "":
		return problem
	var divergence: String = _replay(log)
	return divergence if divergence != "" else _planted()


func _judge(s: ArenaSession, reel: CombatReel) -> String:
	if reel.beat_i < reel.beats.size() - 1:
		return "the reel stopped at beat %d of %d" % [reel.beat_i, reel.beats.size()]
	if reel.kills_by_beat.get(&"pit_melee", 0) < 1:
		return "the melee beat dropped no pit guard (%s)" % reel.kills_by_beat
	if reel.kills_by_beat.get(&"pit_gun", 0) < 1:
		return "the gun beat dropped no pit guard (%s)" % reel.kills_by_beat
	if s.stage.deaths > 0:
		return "Rivet went down %d times in the reel" % s.stage.deaths
	return ""


func _replay(log: ReplayLog) -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var again: ArenaSession = ArenaSession.open(bus, data)
	var divergence: String = again.world.verify_replay(log)
	again.world.free()
	bus.free()
	data.free()
	return "" if divergence == "" else "showcase reel replay diverged: %s" % divergence


func _planted() -> String:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = ArenaSession.open(bus, data)
	var reel: CombatReel = CombatReel.new(s.stage, s.actions)
	reel.trigger = false
	s.world.loop().set_input(reel)
	while s.tick() < reel.length():
		s.step()
	var kills: int = s.stage.pit.kills
	s.world.free()
	bus.free()
	data.free()
	return "a reel with every button off still killed %d pit guards" % kills if kills > 0 else ""
