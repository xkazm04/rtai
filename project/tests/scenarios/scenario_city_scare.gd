extends Scenario
## Lane human-reactions: the fight's gunfire reaches the city's crowd (--arena=city). The range
## bot fights on the proving block; CityScare turns each muzzle and each landing into the sim's
## scare, so pedestrians round Rivet flee (and cower on their rigs, CrowdReact). Pass: the scares
## reach the sim, at least MIN_FLED people near the fight flee, and the run replays identical on
## a fresh world (SIM-05). TST-05 planted fault: CityScare off, the crowd must stay deaf.

const TICKS: int = 20 * SimClock.TICK_RATE
const NEAR_M: float = 20.0
const MIN_FLED: int = 3


func run(_tree: SceneTree) -> String:
	var s: ArenaSession = ArenaSession.open(Events, Data, ArenaSession.MASTER_SEED, null, true)
	s.world.loop().set_input(ArenaRangeBot.new(s.stage, s.actions))
	s.world.loop().start_recording()
	var fled: int = _play(s)
	var log: ReplayLog = s.world.loop().finish_recording()
	var scares: int = s.scare.scares
	s.world.free()
	var deaf: int = _deaf()
	@warning_ignore("return_value_discarded")
	write_evidence("city-scare.json", {"scares": scares, "fled": fled, "fled_deaf": deaf})
	if scares < 2:
		return "only %d bangs reached the city sim" % scares
	if fled < MIN_FLED:
		return "%d people near the fight fled, want %d or more" % [fled, MIN_FLED]
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var again: ArenaSession = ArenaSession.open(bus, data, ArenaSession.MASTER_SEED, null, true)
	var divergence: String = again.world.verify_replay(log)
	again.world.free()
	bus.free()
	data.free()
	if divergence != "":
		return "city scare replay diverged: %s" % divergence
	if deaf >= fled:
		return (
			"with the scare off %d still fled (on: %d): the check would miss the fault"
			% [deaf, fled]
		)
	return ""


## Steps the session to TICKS; returns how many people within NEAR_M of Rivet were seen fleeing.
func _play(s: ArenaSession) -> int:
	var seen: Dictionary[int, bool] = {}
	while s.tick() < TICKS:
		s.step()
		var snap: PackedFloat64Array = s.city.sim.snapshot()
		var at: Vector2 = s.stage.arena.rivet.pos
		var k: int = 0
		while k + SimConst.SNAP_STRIDE <= snap.size() and snap[k] < SimConst.SNAP_PROJ_BASE:
			var near: bool = Vector2(snap[k + 4], snap[k + 5]).distance_to(at) < NEAR_M
			if int(snap[k + 1]) == SimConst.K_PED and int(snap[k + 2]) == SimConst.M_FLEE and near:
				seen[int(snap[k])] = true
			k += SimConst.SNAP_STRIDE
	return seen.size()


func _deaf() -> int:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var s: ArenaSession = ArenaSession.open(bus, data, ArenaSession.MASTER_SEED, null, true)
	s.scare.on = false
	s.world.loop().set_input(ArenaRangeBot.new(s.stage, s.actions))
	var fled: int = _play(s)
	s.world.free()
	bus.free()
	data.free()
	return fled
