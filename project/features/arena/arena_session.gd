class_name ArenaSession
extends RefCounted
## The dev arena as the player plays it: the real World + SimLoop, ArenaStage on it, Rivet driven
## by StagePilot from the loop's input (LiveInput live, an InputTape recording it; a scripted
## tape in the scenarios). The caller adds `world` to the tree, or a headless test calls step().

const MASTER_SEED: int = 20261103

var world: World = World.new()
var stage: ArenaStage
var plan: ArenaPlan
var stations: ArenaStations
var pilot: StagePilot
var live: LiveInput
var tape: InputTape
var actions: PlayerActions


## `input` overrides the live devices (a scripted source for the station scenarios).
static func open(
	events: EventBus, data: DataStore, seed: int = MASTER_SEED, input: InputSource = null
) -> ArenaSession:
	var s: ArenaSession = ArenaSession.new()
	s.actions = PlayerActions.shipped()
	s.actions.install()
	s.world.name = "ArenaWorld"
	s.world.start(events, data, seed)
	s.plan = ArenaPlan.shipped()
	s.stations = ArenaStations.shipped()
	s.stage = ArenaStage.new(s.plan, s.stations)
	s.pilot = StagePilot.new(s.actions)
	s.stage.pilot = s.pilot
	s.world.add_system(s.stage)
	s.live = LiveInput.new(s.actions)
	s.tape = InputTape.new(s.live)
	s.world.loop().set_input(input if input != null else s.tape)
	Log.info("arena", "arena open: %d stations" % s.stations.stations.size())
	return s


func step() -> void:
	world.loop().step()


func tick() -> int:
	return world.context().clock.tick()


## The session's telemetry as JSON at `path` (a directory is made if missing).
func write_telemetry(path: String) -> bool:
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return false
	@warning_ignore("return_value_discarded")
	f.store_string(JSON.stringify(stage.telemetry_dict(), "  ", true))
	f.close()
	return true
