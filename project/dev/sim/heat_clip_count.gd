class_name HeatClipCount
extends RefCounted
## heat_clip's heat 3 numbers per sample (n18 police item 5).

const NEAR_M: float = 4.0
const QUEUE_M: float = 25.0


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
	return {
		"squad_near": squad,
		"block": rb.placed,
		"block_at": [snapped(rb.at.x, 0.01), snapped(rb.at.y, 0.01)],
		"queued": queued,
	}


static func _squad_look(v: int) -> bool:
	return v == 6 or v == RigVariant.SWAT
