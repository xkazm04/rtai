class_name CitySystem
extends WorldSystem
## The streamed city as one sim system (ARC-04): the bubble sim backend (native when the library
## loaded, else the GDScript reference: parity makes them interchangeable), deterministic chunk
## residency and the spawner, all stepped on the fixed tick with RNG streams from the world's
## registry, so `--replay` re-runs a city bit-identically (SIM-05). Until the player lands, the
## focus is a free camera steered by the tick's move axes.

const SIM_STREAM: StringName = &"city_sim"
const SPAWN_STREAM: StringName = &"city_spawn"
const DISTRICT: String = "res://data/tables/city_district.json"
const TEXTURES: String = "res://data/tables/city_textures.json"
const START: Vector2 = Vector2(64.0 * 4 + 12.0, 64.0 * 4 + 14.0)
const FOCUS_SPEED: float = 25.0
const RA: float = 80.0
const RB: float = 160.0
const RIOT_R: float = 14.0

var sim: CitySimBackend = null
var residency: CityResidency = null
var spawner: CitySpawner = null
var source: ChunkSource = null
var gen: CityGen = null
## Where the bubble is centred, and what police pursue (the player, once it exists).
var focus: Vector2 = START
var target: Vector2 = START
## Set focus from outside (a bench or a cutscene) instead of the input axes.
var steer_by_input: bool = true
var _filled: bool = false
var _prefer_native: bool = true


func _init(prefer_native: bool = true) -> void:
	_prefer_native = prefer_native


func setup(ctx: WorldContext) -> void:
	gen = CityGen.from_tables(DISTRICT, TEXTURES)
	source = ChunkSource.new(gen)
	sim = CitySimNative.best() if _prefer_native else CitySimRef.new()
	sim.init(ctx.rng.stream(SIM_STREAM).randi())
	sim.set_radii(RA, RB, RIOT_R)
	residency = CityResidency.new(source, sim, SimConst.CITY_CHUNKS)
	spawner = CitySpawner.new(sim, residency, ctx.rng.stream(SPAWN_STREAM))
	spawner.rb = RB
	spawner.targets = CityTargets.street(270, 120, 10)


func step(_tick: int, input: TickInput) -> void:
	if steer_by_input:
		var axis: Vector2 = Vector2(input.move_x, input.move_y) / TickInput.AXIS_MAX
		focus += axis * FOCUS_SPEED * SimClock.TICK_DT
		target = focus
	residency.update(focus)
	@warning_ignore("return_value_discarded")
	spawner.tick(focus, not _filled)
	_filled = true
	sim.step(SimClock.TICK_DT, focus.x, focus.y, target.x, target.y)


func write_state(out: StreamPeerBuffer) -> void:
	out.put_float(focus.x)
	out.put_float(focus.y)
	var err: int = out.put_data(sim.snapshot().to_byte_array())
	err |= out.put_data(sim.get_counters().to_byte_array())
	assert(err == OK)
	for key: Vector2i in residency.resident_keys():
		out.put_32(key.x * 1000 + key.y)
