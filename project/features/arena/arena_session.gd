class_name ArenaSession
extends RefCounted
## The dev arena as the player plays it: the real World + SimLoop, ArenaStage on it, Rivet driven
## by StagePilot from the loop's input (LiveInput live, an InputTape recording it; a scripted
## tape in the scenarios). The caller adds `world` to the tree, or a headless test calls step().

const MASTER_SEED: int = 20261103
## People on the proving block's streets (the course's crowd patch is the city's own crowd).
const CITY_PEDS: int = 120

var world: World = World.new()
var stage: ArenaStage
var plan: ArenaPlan
var stations: ArenaStations
var pilot: StagePilot
var live: LiveInput
var tape: InputTape
var actions: PlayerActions
## The generated city under the proving block (--arena=city); null in the dev arena.
var city: CitySystem = null


## `input` overrides the live devices (a scripted source for the station scenarios); `on_city`
## lays the stations on the city proving block (arena.json city.base) instead of the dev arena.
static func open(
	events: EventBus,
	data: DataStore,
	seed: int = MASTER_SEED,
	input: InputSource = null,
	on_city: bool = false
) -> ArenaSession:
	var s: ArenaSession = ArenaSession.new()
	s.actions = PlayerActions.shipped()
	s.actions.install()
	s.world.name = "ArenaWorld"
	s.world.start(events, data, seed)
	s.plan = ArenaPlan.shipped()
	if on_city:
		s.plan = ArenaPlan.shipped(s.plan.city_base)
	s.stations = ArenaStations.shipped()
	s.stage = ArenaStage.new(s.plan, s.stations)
	s.pilot = StagePilot.new(s.actions)
	s.stage.pilot = s.pilot
	if on_city:
		s.stage.cells = StageCells.shipped()
	s.world.add_system(s.stage)
	if on_city:
		s._add_city()
	if ArenaCars.wanted(s.stations):
		@warning_ignore("return_value_discarded")
		ArenaCars.attach(s.world, s.stage)
	s.live = LiveInput.new(s.actions)
	s.tape = InputTape.new(s.live)
	s.world.loop().set_input(input if input != null else s.tape)
	Log.info("arena", "arena open: %d stations" % s.stations.stations.size())
	return s


## As quest 1 on the city: the bubble follows Rivet, the chunks round him resident at tick 0.
func _add_city() -> void:
	var extent: Array[Vector2] = [plan.base]
	for a: ArenaPlan.Area in plan.areas:
		extent.append_array([a.rect.position, a.rect.end])
	@warning_ignore("return_value_discarded")
	stage.cells.prewarm(extent)
	city = CitySystem.new(true)
	city.steer_by_input = false
	stage.follow = city
	city.focus = stage.layout.rivet_start
	city.target = city.focus
	world.add_system(city)
	city.residency.update(city.focus)
	city.spawner.targets = CityTargets.street(CITY_PEDS, 0, 0)


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
