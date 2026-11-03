class_name CityParity
extends RefCounted
## NAT-06 parity: the GDScript reference vs the native CitySim on the same chunks, the same
## spawn RNG stream, fixed dt, with the camera sweeping 300 m so actors cross tiers, despawn and
## respawn; traffic, pursuit police, a riot with cops shooting. Every CHECK_EVERY steps the full
## snapshots must be EXACTLY equal. plant_at >= 0 plants a mutation (an ulp-sized nudge to one
## rioter of side b) to prove the gate can fail (TST-05).

const CHECK_EVERY: int = 30
const SIM_SEED: int = 4242
const SPAWN_SEED: int = 99
const RIOT: Vector2 = Vector2(64.0 * 8 + 12.0, 64.0 * 8 + 12.0)

var result: Dictionary = {}


func run(a: CitySimBackend, b: CitySimBackend, steps: int, plant_at: int) -> bool:
	var gen: CityGen = CityGen.from_tables(
		"res://data/tables/city_district.json", "res://data/tables/city_textures.json"
	)
	var sa: CitySpawner = _side(a, gen)
	var sb: CitySpawner = _side(b, gen)
	var dt: float = SimClock.TICK_DT
	var mismatch: int = -1
	var checks: int = 0
	var us: PackedInt64Array = PackedInt64Array([0, 0])
	var diff: float = 0.0
	var knocks: int = 0
	for st: int in steps:
		var cam: Vector2 = RIOT - Vector2(150, 0) + Vector2(300.0 * st / steps, 0)
		var tg: Vector2 = RIOT + Vector2(cos(st * 0.01), sin(st * 0.01)) * 5.0
		a.set_body(body_spec(st))
		b.set_body(body_spec(st))
		var t0: int = Time.get_ticks_usec()
		a.step(dt, cam.x, cam.y, tg.x, tg.y)
		var t1: int = Time.get_ticks_usec()
		b.step(dt, cam.x, cam.y, tg.x, tg.y)
		us[0] += t1 - t0
		us[1] += Time.get_ticks_usec() - t1
		knocks += int(a.body_result()[SimConst.BR_N])
		if st == plant_at:
			_plant(b)
		var made_a: int = sa.tick(cam, false)
		var made_b: int = sb.tick(cam, false)
		if made_a != made_b:
			mismatch = st
			break
		if st % CHECK_EVERY == CHECK_EVERY - 1 or st == steps - 1:
			checks += 1
			diff = _compare(a.snapshot(), b.snapshot())
			diff = maxf(diff, _compare(a.body_result(), b.body_result()))
			if diff != 0.0:
				mismatch = st
				break
	_report(a, b, [steps, checks, mismatch, knocks], us, diff)
	return mismatch < 0


func _side(sim: CitySimBackend, gen: CityGen) -> CitySpawner:
	sim.init(SIM_SEED)
	sim.set_radii(80.0, 160.0, 14.0)
	var res: CityResidency = CityResidency.new(ChunkSource.new(gen), sim, SimConst.CITY_CHUNKS)
	for cy: int in range(2, 9):
		for cx: int in range(2, 9):
			res.adopt(Vector2i(cx, cy), gen.gen_chunk(cx, cy))
	var rng: RandomNumberGenerator = RngRegistry.new(SPAWN_SEED).stream(&"city_spawn")
	var sp: CitySpawner = CitySpawner.new(sim, res, rng)
	sp.targets = CityTargets.street(150, 70, 6)
	var cam: Vector2 = RIOT - Vector2(150, 0)
	@warning_ignore("return_value_discarded")
	sp.tick(cam, true)
	sp.riot_c = RIOT
	for k: int in 80:
		@warning_ignore("return_value_discarded")
		sp.try_riot(RIOT, 0.0, 12.0, false)
	for k: int in 30:
		@warning_ignore("return_value_discarded")
		sp.try_riot(RIOT, 22.0, 34.0, true)
	return sp


## The player body (features/bodies) crossing the riot east-west, 12 m each way: a walk (1.5 m/s,
## shoves) on even legs, a sprint (6 m/s, tackles) on odd legs, with the shipped body table.
static func body_spec(st: int) -> PackedFloat64Array:
	@warning_ignore("integer_division")
	var leg: int = st / 240
	var u: float = float(st % 240) / 240.0
	var spd: float = 6.0 if leg % 2 == 1 else 1.5
	var dir: float = 1.0 if (leg % 4) < 2 else -1.0
	var x0: float = RIOT.x - dir * spd * 2.0
	var vx: float = dir * spd
	var s: PackedFloat64Array = SimArrays.f64(SimConst.BD_LEN)
	s[SimConst.BD_X] = x0 + vx * 4.0 * u
	s[SimConst.BD_Y] = RIOT.y + 0.5
	s[SimConst.BD_VX] = vx
	s[SimConst.BD_ON] = 1.0
	s[SimConst.BD_R] = 0.42
	s[SimConst.BD_RP] = 0.35
	s[SimConst.BD_SHARE] = 160.0 / 235.0
	s[SimConst.BD_TACKLE] = 3.2
	s[SimConst.BD_KNOCK] = 5.0
	s[SimConst.BD_DOWN] = 1.4
	s[SimConst.BD_FLEE] = 3.0
	s[SimConst.BD_RUN_IN] = 1.0
	return s


## 0.0 when identical; otherwise the largest absolute difference (INF when sizes differ).
static func _compare(x: PackedFloat64Array, y: PackedFloat64Array) -> float:
	if x.size() != y.size():
		return INF
	var worst: float = 0.0
	for k: int in x.size():
		if x[k] != y[k]:
			worst = maxf(worst, maxf(absf(x[k] - y[k]), 1e-300))
	return worst


## Nudges every live rioter's riot centre by about an ulp: any rioter outside its circle then
## steers a hair differently, which must show up in the next snapshot check.
static func _plant(sim: CitySimBackend) -> void:
	var snap: PackedFloat64Array = sim.snapshot()
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if int(snap[r]) >= SimConst.SNAP_PROJ_BASE:
			return
		if int(snap[r + 2]) == SimConst.M_RIOT:
			sim.set_riot_centre(int(snap[r]), RIOT.x + 1e-9, RIOT.y)


func _report(
	a: CitySimBackend, b: CitySimBackend, n: Array[int], us: PackedInt64Array, diff: float
) -> void:
	var steps: int = n[0]
	result = {
		"backends": [String(a.backend_name()), String(b.backend_name())],
		"steps": steps,
		"checks": n[1],
		"exact": n[2] < 0,
		"first_mismatch_step": n[2],
		"body_knockdowns": n[3],
		"max_abs_diff": diff if is_finite(diff) else -1.0,
		"snapshot_floats": a.snapshot().size(),
		"counters_a": Array(a.get_counters()),
		"counters_b": Array(b.get_counters()),
		"step_ms_a": us[0] / 1000.0 / steps,
		"step_ms_b": us[1] / 1000.0 / steps,
		"debug_build": OS.is_debug_build(),
	}
