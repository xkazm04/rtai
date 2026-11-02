extends Scenario
## F-07 / WLD-09: a chase through the streamed city. The target runs east down a street across
## chunk borders, then stops; promoted cops start behind it around the block and police cars
## patrol. Asserts the cops close in along the flow field, a police car gets near, and the field
## stays inside the section 20 nav budget (2 ms) on the native backend (the GDScript reference
## only reports its time: it is the fallback, not the shipped path).

const SECONDS: int = 35
const RUN_TICKS: int = 12 * SimClock.TICK_RATE
const START: Vector2 = Vector2(64.0 * 5 + 30.0, 64.0 * 5 + 12.0)
const SPEED: float = 4.0
const COPS: int = 8
const NAV_BUDGET_US: int = 2000


func run(_tree: SceneTree) -> String:
	var gen: CityGen = CityGen.from_tables(CitySystem.DISTRICT, CitySystem.TEXTURES)
	var sim: CitySimBackend = CitySimNative.best()
	sim.init(5)
	sim.set_radii(80.0, 160.0, 14.0)
	var res: CityResidency = CityResidency.new(ChunkSource.new(gen), sim, SimConst.CITY_CHUNKS)
	res.update(START)
	var sp: CitySpawner = CitySpawner.new(sim, res, RngRegistry.new(5).stream(&"city_spawn"))
	sp.targets = CityTargets.street(60, 30, 4)
	@warning_ignore("return_value_discarded")
	sp.tick(START, true)
	var cops: Array[int] = _spawn_cops(sim)
	if cops.size() < COPS:
		return "only %d cops spawned" % cops.size()
	var target: Vector2 = _sidewalk_east_of(sim, START + Vector2(0, 8))
	var d0: float = _mean_dist(sim, cops, target)
	var near_car: float = INF
	for t: int in SECONDS * SimClock.TICK_RATE:
		if t < RUN_TICKS:
			target.x += SPEED * SimClock.TICK_DT
		res.update(target)
		@warning_ignore("return_value_discarded")
		sp.tick(target, false)
		sim.step(SimClock.TICK_DT, target.x, target.y, target.x, target.y)
		near_car = minf(near_car, _nearest_kind(sim, SimConst.K_PCAR, target))
	return _judge(sim, d0, _mean_dist(sim, cops, target), near_car)


func _judge(sim: CitySimBackend, d0: float, d1: float, near_car: float) -> String:
	var st: PackedInt32Array = sim.flow_stats()
	var summary: String = (
		"chase (%s): cops %.1f -> %.1f m, nearest police car %.1f m, %d fields, max %d us, last %d us"
		% [
			sim.backend_name(),
			d0,
			d1,
			near_car,
			st[SimConst.FS_COMPUTES],
			st[SimConst.FS_MAX_US],
			st[SimConst.FS_LAST_US],
		]
	)
	Log.info("scenario", summary)
	if st[SimConst.FS_COMPUTES] < 10:
		return "the field was computed only %d times" % st[SimConst.FS_COMPUTES]
	if d1 > d0 * 0.5 or d1 > 25.0:
		return "the cops did not close in: %s" % summary
	if near_car > 40.0:
		return "no police car got within 40 m: %s" % summary
	if sim.backend_name() == &"native" and st[SimConst.FS_MAX_US] > NAV_BUDGET_US:
		return "flow field over the 2 ms nav budget: %s" % summary
	return ""


## Promoted cops on walkable cells 40-60 m behind the target, around the block.
func _spawn_cops(sim: CitySimBackend) -> Array[int]:
	var out: Array[int] = []
	for k: int in COPS:
		var want: Vector2 = START + Vector2(-40.0 - 3.0 * k, 20.0 + 2.0 * (k % 3))
		var at: Vector2 = _walkable_near(sim, want)
		if at.x < 0.0:
			continue
		var spec: Array = [SimConst.K_COP, at.x, at.y, 1.0, 0.0, 7, SimConst.F_PROMOTED, 3.4]
		var slot: int = sim.spawn(PackedFloat64Array(spec + [0.0, 0]))
		if slot >= 0:
			out.append(slot)
	return out


## A sidewalk row near p that stays walkable for the whole run east (the target's path).
static func _sidewalk_east_of(sim: CitySimBackend, p: Vector2) -> Vector2:
	for dy: int in range(-6, 7):
		var y: float = floorf(p.y) + dy + 0.5
		var ok: bool = true
		for k: int in int(SPEED * RUN_TICKS / SimClock.TICK_RATE) + 2:
			ok = ok and sim.cell_at(p.x + k, y) >= SimConst.C_LANE
		if ok and sim.cell_at(p.x, y) == SimConst.C_WALK:
			return Vector2(p.x, y)
	return p


static func _walkable_near(sim: CitySimBackend, p: Vector2) -> Vector2:
	for r: int in 24:
		for dy: int in range(-r, r + 1):
			for dx: int in range(-r, r + 1):
				var q: Vector2 = Vector2(floorf(p.x) + dx + 0.5, floorf(p.y) + dy + 0.5)
				if sim.cell_at(q.x, q.y) == SimConst.C_WALK:
					return q
	return Vector2(-1, -1)


static func _mean_dist(sim: CitySimBackend, slots: Array[int], target: Vector2) -> float:
	var snap: PackedFloat64Array = sim.snapshot()
	var sum: float = 0.0
	var n: int = 0
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		var alive_cop: bool = (
			int(snap[r + 1]) == SimConst.K_COP and int(snap[r + 2]) != SimConst.M_DEAD
		)
		if slots.has(int(snap[r])) and alive_cop:
			sum += Vector2(snap[r + 4], snap[r + 5]).distance_to(target)
			n += 1
	return sum / n if n > 0 else INF


static func _nearest_kind(sim: CitySimBackend, kind: int, target: Vector2) -> float:
	var snap: PackedFloat64Array = sim.snapshot()
	var best: float = INF
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if int(snap[r + 1]) == kind:
			best = minf(best, Vector2(snap[r + 4], snap[r + 5]).distance_to(target))
	return best
