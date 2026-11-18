extends Scenario
## City production fight, measured at the same pre-ballistics point as the five-seed probe.
## Stop on the last kill of wave five: no partial wave can hide a stranded guard.

const WAVES: int = 5
const LIMIT: int = 90 * SimClock.TICK_RATE
const CITY_COVER: float = 0.4419
const CROWD_LIMIT: float = 0.02


func run(_tree: SceneTree) -> String:
	var live: Dictionary = _fight(false)
	var bad: Dictionary = _fight(true)
	@warning_ignore("return_value_discarded")
	write_evidence("arena-squad.json", {"live": live, "no_separation": bad})
	if not live.replayed:
		return "city squad replay diverged"
	if live.cleared != WAVES or live.spawned != WAVES:
		return "city squad unfinished: %s" % live
	if live.crowded >= CROWD_LIMIT or live.cover <= CITY_COVER or live.flankers < 1:
		return "city squad positioning: %s" % live
	if bad.crowded < CROWD_LIMIT:
		return "crowding judge missed separation disabled: %s" % bad
	return ""


func _open() -> ArenaSession:
	var options: ArenaArgs = ArenaArgs.parse(["--arena=city", "--enemy-brain=squad"])
	return ArenaSession.open_with_args(Events, Data, ArenaSession.MASTER_SEED, null, options)


func _fight(plant: bool) -> Dictionary:
	var s: ArenaSession = _open()
	var arena: FightProbeArena = FightProbeArena.attach(s.stage.arena)
	arena.squad_ai.plant_no_separation = plant
	arena.squad = s.stage.pit.standing
	var meter: FightProbeSample = FightProbeSample.new(arena)
	meter.walls = s.stage.walls
	meter.cells = s.stage.cells
	meter.observing = true
	arena.sampled = meter.sample
	s.world.loop().set_input(ArenaPitBot.new(s.stage, s.actions))
	s.world.loop().start_recording()
	while s.tick() < LIMIT and s.stage.pit.waves_cleared < WAVES:
		s.step()
	var log: ReplayLog = s.world.loop().finish_recording()
	var result: Dictionary = {
		"cleared": s.stage.pit.waves_cleared,
		"spawned": s.stage.pit.wave,
		"ticks": s.tick(),
		"crowded": float(meter.crowded) / maxi(meter.hostile_ticks, 1),
		"cover": float(meter.covered) / maxi(meter.hostile_ticks, 1),
		"flankers": meter.flankers.size(),
	}
	arena.sampled = Callable()
	_close(s)
	if not plant:
		var again: ArenaSession = _open()
		result.replayed = again.world.verify_replay(log) == ""
		_close(again)
	return result


func _close(s: ArenaSession) -> void:
	s.stage.hooks.clear()
	s.live.cursor_px = Callable()
	if s.stage.vehicles != null:
		s.stage.vehicles.world = null
	s.world.free()
