extends Node
## Paired fixed-seed traffic samples on the generated roads in every chunk. The before arm
## omits zones. Both arms use the real density check, with police and bikes excluded.

const KNOWN_FLAGS: PackedStringArray = ["--out", "--before"]
const MASTER_SEED: int = 91
const ATTEMPTS: int = 384
const ART_IDS: Array[String] = [
	"sedan", "sedan_b", "sedan_c", "taxi", "van", "pickup", "ambulance", "sedan_grey"
]


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var path: String = args.text("--out")
	if path.is_empty() or args.values.size() != (2 if args.has("--before") else 1):
		Log.error("zone_car_census", "expected --out=<car_census.json path> [--before]")
		get_tree().quit(2)
		return
	var gen: CityGen = CityGen.from_tables(CitySystem.DISTRICT, CitySystem.TEXTURES)
	var report: Dictionary = {
		"schema": "gtai.zone-car-census/1",
		"master_seed": MASTER_SEED,
		"attempts_per_chunk": ATTEMPTS,
		"art_ids": ART_IDS,
		"before": _census(gen, null),
	}
	if not args.has("--before"):
		report["after"] = _census(gen, gen.zones)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null or not file.store_string(JSON.stringify(report, "  ") + "\n"):
		Log.error("zone_car_census", "failed to write %s" % path)
		get_tree().quit(1)
		return
	file.close()
	get_tree().quit(0)


func _census(gen: CityGen, zones: CityZones) -> Dictionary[StringName, Array]:
	var totals: Dictionary[StringName, Array] = {}
	var sim := CitySimRef.new()
	var res := CityResidency.new(ChunkSource.new(gen), sim, SimConst.CITY_CHUNKS)
	var rng: RandomNumberGenerator = RngRegistry.new(MASTER_SEED).stream(CitySystem.SPAWN_STREAM)
	var sp := CitySpawner.new(sim, res, rng, zones)
	for zone: CityZone in gen.zones.rows:
		totals[zone.id] = [0, 0, 0, 0, 0, 0, 0, 0] as Array[int]
	for cy: int in SimConst.CITY_CHUNKS:
		for cx: int in SimConst.CITY_CHUNKS:
			var key := Vector2i(cx, cy)
			res.adopt(key, gen.gen_chunk(cx, cy))
			_sample(key, sp, sim, totals[gen.zones.id_of_chunk(cx, cy)])
			res.evict(key)
	return totals


func _sample(key: Vector2i, sp: CitySpawner, sim: CitySimRef, counts: Array[int]) -> void:
	# The entire disc lies inside this chunk. Evacuate its cars before sampling the next one.
	var centre: Vector2 = (Vector2(key) + Vector2(0.5, 0.5)) * SimConst.CHUNK_M
	for attempt: int in ATTEMPTS:
		@warning_ignore("return_value_discarded")
		sp.try_car(centre, 0.0, SimConst.CHUNK_M * 0.5 - 0.01, false)
	var cars: PackedFloat64Array = sim.snapshot()
	var arts: PackedByteArray = sim.get_variants()
	for row: int in range(0, cars.size(), SimConst.SNAP_STRIDE):
		var slot: int = int(cars[row])
		counts[arts[slot]] += 1
		sim.kill(slot)
