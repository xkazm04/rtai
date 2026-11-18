class_name HeatClipCount
extends RefCounted
## heat_clip's heat 3 numbers per sample (n18 police item 5).

const NEAR_M: float = 4.0
const QUEUE_M: float = 25.0
const BODY_M: float = 4.0


## Squad cops (riot 6 / SWAT 8 looks) within NEAR_M of a, the roadblock's cars and
## the traffic cars stopped within QUEUE_M of it.
static func heat3(
	sim: CitySimBackend, rb: CityRoadblock, snap: PackedFloat64Array, a: Vector2
) -> Dictionary:
	var v: PackedByteArray = sim.get_variants()
	var squad: int = 0
	var queued: int = 0
	for k: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if snap[k] >= SimConst.SNAP_PROJ_BASE:
			break
		var p: Vector2 = Vector2(snap[k + 4], snap[k + 5])
		var kind: int = int(snap[k + 1])
		if kind == SimConst.K_COP and _squad_look(v[int(snap[k])]) and p.distance_to(a) <= NEAR_M:
			squad += 1
		if kind == SimConst.K_CAR and rb.placed > 0 and p.distance_to(rb.at) <= QUEUE_M:
			queued += 1 if snap[k + 8] < 0.5 else 0
	return (
		{
			"squad_near": squad,
			"block": rb.placed,
			"block_at": [snapped(rb.at.x, 0.01), snapped(rb.at.y, 0.01)],
			"queued": queued,
		}
		. merged(bodies(snap))
	)


## Dead people (bodies) and those within BODY_M of a police car (pcar_bodies): the heat 3 clip's
## open finding, peds dead beside a dispatched car (a car above 4 m/s kills whom its box touches).
static func bodies(snap: PackedFloat64Array) -> Dictionary:
	var cars: Array[Vector2] = []
	var dead: Array[Vector2] = []
	var down: Array = []
	for k: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if snap[k] >= SimConst.SNAP_PROJ_BASE:
			break
		var kind: int = int(snap[k + 1])
		var p: Vector2 = Vector2(snap[k + 4], snap[k + 5])
		if kind == SimConst.K_PCAR:
			cars.append(p)
		elif (
			(kind == SimConst.K_PED or kind == SimConst.K_COP)
			and int(snap[k + 2]) == SimConst.M_DEAD
		):
			dead.append(p)
	var n: int = 0
	for b: Vector2 in dead:
		for c: Vector2 in cars:
			if b.distance_to(c) <= BODY_M:
				n += 1
				break
	return {"bodies": dead.size(), "pcar_bodies": n, "down": down}


static func _squad_look(v: int) -> bool:
	return v == 6 or v == RigVariant.SWAT
