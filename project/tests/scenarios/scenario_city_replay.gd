extends Scenario
## SIM-05 on the real world: the World with its CitySystem (streaming, spawning, traffic, the
## bubble sim) driven 20 s by a bot that steers the focus across chunk borders, recorded, saved,
## reloaded and replayed bit-identically, on the native backend and on the GDScript reference
## (parity makes a log portable between them).

const SECONDS: int = 20
const MASTER_SEED: int = 61
var _path: String = TestTmp.dir("replay").path_join("city_20s.json")


func run(_tree: SceneTree) -> String:
	var recorded: ReplayLog = _record()
	if recorded.ticks != SECONDS * SimClock.TICK_RATE or recorded.checkpoints.is_empty():
		return "recording incomplete (%d ticks)" % recorded.ticks
	if (
		DirAccess.make_dir_recursive_absolute(_path.get_base_dir()) != OK
		or recorded.save(_path) != OK
	):
		return "cannot save %s" % _path
	var loaded: ReplayLog = ReplayLog.load_file(_path)
	if loaded == null:
		return "saved log does not load"
	for native: bool in [true, false]:
		var reason: String = _replay(loaded, native)
		if reason != "":
			return "replay (%s) diverged: %s" % ["native" if native else "gdscript", reason]
	Log.info(
		"scenario",
		(
			"city replay: %d ticks, %d checkpoints identical"
			% [loaded.ticks, loaded.checkpoints.size()]
		)
	)
	return ""


func _record() -> ReplayLog:
	var w: Array[Object] = _world(MASTER_SEED, true)
	var world: World = w[0]
	var city: CitySystem = w[3]
	world.loop().set_input(DummyBot.new(MASTER_SEED + 1))
	world.loop().start_recording()
	var start: Vector2 = city.focus
	for i: int in SECONDS * SimClock.TICK_RATE:
		world.loop().step()
	var log: ReplayLog = world.loop().finish_recording()
	Log.info(
		"scenario",
		(
			"city focus moved %.0f m, %d chunks stamped"
			% [start.distance_to(city.focus), city.residency.stamped]
		)
	)
	_free(w)
	return log


func _replay(log: ReplayLog, native: bool) -> String:
	var w: Array[Object] = _world(log.master_seed, native)
	var world: World = w[0]
	var reason: String = world.verify_replay(log)
	_free(w)
	return reason


## [World, EventBus, DataStore, CitySystem] on throwaway nodes.
static func _world(master_seed: int, native: bool) -> Array[Object]:
	var world: World = World.new()
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	world.start(bus, data, master_seed)
	var city: CitySystem = CitySystem.new(native)
	world.add_system(city)
	return [world, bus, data, city]


static func _free(w: Array[Object]) -> void:
	for k: int in 3:
		w[k].free()
