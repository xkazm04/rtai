class_name BodiesStage
extends RefCounted
## Test stage for the body scenarios (features/bodies): the real generated city stamped around a
## sidewalk band, standing peds placed by the test (no spawner), and Rivet's body driven through
## them on the fixed tick exactly as CitySystem does (RivetBody.spec -> step -> take). Measures,
## every tick, the worst overlap between Rivet and any live person (sum of the table radii minus
## the distance) and the worst person-person overlap.

const ORIGIN: Vector2 = Vector2(64.0 * 5 + 30.0, 64.0 * 5 + 12.0)
## How far (m) from ORIGIN the band may sit, nearest rows first: d5-city's wall-side clutter
## (2026-11-03) leaves no clean 3-row band within the old 24 m.
const BAND_SEARCH_M: int = 160

var sim: CitySimBackend = null
var table: BodyTable = BodyTable.load_default()
var body: RivetBody = null
var band: Vector2 = Vector2(-1, -1)
var worst_rivet: float = -INF
var worst_people: float = -INF
var knocks: Array[int] = []
## Planted faults (TST-05): overrides written into the spec after RivetBody builds it.
var plant_radius_zero: bool = false
var plant_body_off: bool = false
var plant_no_tackle: bool = false
var plant_down_zero: bool = false
var plant_no_run_in: bool = false


## Stamps the city and finds a sidewalk band (rows y-1..y+1 walkable for `length` m east).
func setup(length: float) -> String:
	sim = CitySimNative.best()
	sim.init(7)
	sim.set_radii(80.0, 160.0, 14.0)
	var res: CityResidency = CityResidency.new(
		ChunkSource.new(CityGen.from_tables(CitySystem.DISTRICT, CitySystem.TEXTURES)),
		sim,
		SimConst.CITY_CHUNKS
	)
	res.update(ORIGIN)
	band = _find_band(length)
	if band.x < 0.0:
		return "no 3-row sidewalk band of %.0f m near %s" % [length, ORIGIN]
	body = RivetBody.new(table, band)
	return "" if table.ok() else "body table: %s" % "; ".join(table.errors())


## A standing ped (vmax 0) or cop, promoted so it stays tier A; returns the slot.
func stand(at: Vector2, kind: int = SimConst.K_PED) -> int:
	var spec: Array = [kind, at.x, at.y, 1.0, 0.0, 1, SimConst.F_PROMOTED, 0.0]
	return sim.spawn(PackedFloat64Array(spec + [0.0, 0]))


## A ped walking along `dir` at `mps` (promoted); returns the slot.
func walker(at: Vector2, dir: Vector2, mps: float) -> int:
	var spec: Array = [SimConst.K_PED, at.x, at.y, dir.x, dir.y, 2, SimConst.F_PROMOTED, mps]
	return sim.spawn(PackedFloat64Array(spec + [0.0, 0]))


## One tick: Rivet wants to move by vel * dt from where he ended the last tick.
func tick(vel: Vector2) -> void:
	var spec: PackedFloat64Array = body.spec(body.pos + vel * SimClock.TICK_DT)
	if plant_radius_zero:
		spec[SimConst.BD_R] = 0.0
	if plant_body_off:
		spec[SimConst.BD_ON] = 0.0
	if plant_no_tackle:
		spec[SimConst.BD_TACKLE] = RivetBody.NEVER_MPS
	if plant_down_zero:
		spec[SimConst.BD_DOWN] = 0.0
	if plant_no_run_in:
		spec[SimConst.BD_RUN_IN] = 0.0
	sim.set_body(spec)
	sim.step(SimClock.TICK_DT, body.pos.x, body.pos.y, body.pos.x, body.pos.y)
	body.take(sim.body_result())
	for k: int in range(0, body.knocks.size(), SimConst.BR_STRIDE):
		knocks.append(int(body.knocks[k]))
	_measure()


## [kind, mode, x, y, v] of a slot from the snapshot, or empty when it is gone.
func person(slot: int) -> PackedFloat64Array:
	var snap: PackedFloat64Array = sim.snapshot()
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if int(snap[r]) == slot:
			return PackedFloat64Array(
				[snap[r + 1], snap[r + 2], snap[r + 4], snap[r + 5], snap[r + 8]]
			)
	return PackedFloat64Array()


func _measure() -> void:
	var rr: float = table.radius(RivetBody.CLASS) + table.radius(RivetBody.PERSON)
	var rp: float = table.radius(RivetBody.PERSON) * 2.0
	var pts: PackedVector2Array = PackedVector2Array()
	var snap: PackedFloat64Array = sim.snapshot()
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if int(snap[r]) >= SimConst.SNAP_PROJ_BASE:
			break
		var k: int = int(snap[r + 1])
		var person_kind: bool = k == SimConst.K_PED or k == SimConst.K_COP
		if person_kind and int(snap[r + 2]) != SimConst.M_DEAD:
			@warning_ignore("return_value_discarded")
			pts.append(Vector2(snap[r + 4], snap[r + 5]))
	for i: int in pts.size():
		worst_rivet = maxf(worst_rivet, rr - body.pos.distance_to(pts[i]))
		for j: int in range(i + 1, pts.size()):
			worst_people = maxf(worst_people, rp - pts[i].distance_to(pts[j]))


func _find_band(length: float) -> Vector2:
	for k: int in range(0, 2 * BAND_SEARCH_M + 1):
		@warning_ignore("integer_division")
		var dy: int = (k + 1) / 2 * (1 if k % 2 == 1 else -1)
		for dx: int in range(-BAND_SEARCH_M, BAND_SEARCH_M + 1, 4):
			var p: Vector2 = Vector2(floorf(ORIGIN.x) + dx + 0.5, floorf(ORIGIN.y) + dy + 0.5)
			if _band_ok(p, length):
				return p
	return Vector2(-1, -1)


func _band_ok(p: Vector2, length: float) -> bool:
	for k: int in int(length) + 1:
		for row: int in range(-1, 2):
			if sim.cell_at(p.x + k, p.y + row) != SimConst.C_WALK:
				return false
	return true
