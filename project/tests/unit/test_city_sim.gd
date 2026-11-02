extends GutTest
## The GDScript reference bubble sim (CitySimRef): slots, tiers, traffic on lanes, people on
## sidewalks, projectiles, determinism. The native backend is held to it by tests/parity.

const ROAD_Y: float = 64.0 * 4 + 12.0
const CAM: Vector2 = Vector2(64.0 * 4 + 40.0, 64.0 * 4 + 12.0)

var _gen: CityGen


func before_all() -> void:
	_gen = CityGen.from_tables(CitySystem.DISTRICT, CitySystem.TEXTURES)


func test_spawn_kill_and_counters() -> void:
	var sim: CitySimRef = _world()
	var slot: int = sim.spawn(_ped(CAM))
	assert_eq(slot, 0)
	assert_eq(sim.spawn(PackedFloat64Array([1, 2, 3])), -1, "a short spec is refused")
	sim.step(SimClock.TICK_DT, CAM.x, CAM.y, CAM.x, CAM.y)
	assert_eq(sim.get_counters()[SimConst.CN_PEDS], 1)
	assert_eq(sim.get_counters()[SimConst.CN_TIER_A], 1)
	sim.kill(slot)
	sim.step(SimClock.TICK_DT, CAM.x, CAM.y, CAM.x, CAM.y)
	assert_eq(sim.get_counters()[SimConst.CN_PEDS], 0)
	assert_eq(sim.get_counters()[SimConst.CN_DESPAWNED], 1)


func test_actors_beyond_the_bubble_despawn() -> void:
	var sim: CitySimRef = _world()
	var far: Vector2 = CAM + Vector2(SimConst.CHUNK_M * 1.5, 0)
	assert_gte(sim.spawn(_ped(far)), 0)
	sim.step(SimClock.TICK_DT, CAM.x, CAM.y, CAM.x, CAM.y)
	assert_eq(sim.get_counters()[SimConst.CN_PEDS], 0, "outside rb: despawned")


func test_a_car_drives_east_in_its_lane() -> void:
	var sim: CitySimRef = _world()
	var lane: float = ROAD_Y + 2.0
	var start: Vector2 = Vector2(CAM.x - 20.0, lane)
	var spec: Array = [SimConst.K_CAR, start.x, start.y, 1.0, 0.0, 0, 0, 12.0, lane, 0]
	assert_gte(sim.spawn(PackedFloat64Array(spec)), 0)
	for i: int in 60:
		sim.step(SimClock.TICK_DT, CAM.x, CAM.y, CAM.x, CAM.y)
	var snap: PackedFloat64Array = sim.snapshot()
	assert_gt(snap[4], start.x + 1.0, "moved east")
	assert_almost_eq(snap[5], lane, 0.5, "stayed in its lane")


func test_same_seed_same_world() -> void:
	var a: CitySimRef = _world()
	var b: CitySimRef = _world()
	for sim: CitySimRef in [a, b]:
		for k: int in 20:
			var spec: PackedFloat64Array = _ped(CAM + Vector2(k * 0.7 - 7.0, 6.0))
			spec[SimConst.SP_FLAGS] = SimConst.F_PROMOTED | SimConst.F_RIOTER
			var slot: int = sim.spawn(spec)
			sim.set_riot_centre(slot, CAM.x, CAM.y + 6.0)
		for i: int in 120:
			sim.step(SimClock.TICK_DT, CAM.x, CAM.y, CAM.x, CAM.y)
	assert_eq(a.snapshot(), b.snapshot())


func test_a_cop_shoots_and_a_hit_kills() -> void:
	var sim: CitySimRef = _world()
	var victim: Vector2 = Vector2(CAM.x, ROAD_Y - 6.5)
	assert_gte(sim.spawn(_ped(victim)), 0)
	var cop: Array = [SimConst.K_COP, victim.x - 9.0, victim.y, 1.0, 0.0, 7, 1, 3.4, 0.0, 0]
	assert_gte(sim.spawn(PackedFloat64Array(cop)), 0)
	var shots: int = 0
	for i: int in 600:
		sim.step(SimClock.TICK_DT, CAM.x, CAM.y, victim.x, victim.y)
		shots = maxi(shots, sim.get_counters()[SimConst.CN_PROJ])
	assert_gt(shots, 0, "the cop fired")


func _world() -> CitySimRef:
	var sim: CitySimRef = CitySimRef.new()
	sim.init(7)
	sim.set_radii(80.0, 160.0, 14.0)
	for cy: int in range(1, 4):
		for cx: int in range(1, 4):
			var c: CityChunk = _gen.gen_chunk(cx, cy)
			sim.stamp_chunk(cx, cy, c.tiles, c.cells)
	return sim


static func _ped(at: Vector2) -> PackedFloat64Array:
	return PackedFloat64Array([SimConst.K_PED, at.x, at.y, 1.0, 0.0, 0, 0, 1.3, 0.0, 0])
