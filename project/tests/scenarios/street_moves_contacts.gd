class_name StreetMovesContacts
extends RefCounted
## Inspect the baked kerb car collision footprints independently of the probe's ownership map.
## The generator stamps 90% of the car's length and the kerb strip width into 1 m cells.

var near_traffic: bool
var over_target: bool
var _key: Vector2i = Vector2i(-1, -1)
var _parked: Array[Rect2i] = []


func centre(s: Quest1Session, p: Vector2) -> String:
	var cell: Vector2i = Vector2i(p.floor())
	var key: Vector2i = cell / SimConst.CHUNK_CELLS
	if key != _key:
		_index(s.city, key)
	var parked: bool = false
	for box: Rect2i in _parked:
		if box.has_point(cell):
			parked = true
			break
	var code: int = s.city.sim.cell_at(p.x, p.y)
	over_target = false
	if (
		not parked
		and not s.stage.cells.solid(cell.x, cell.y)
		and code in [SimConst.C_WALK, SimConst.C_LANE, SimConst.C_PARK]
	):
		return ""
	var v: PlayerVault = s.pilot.motion.vault
	var prop: VaultCity.Prop = v.probe.city.owner(cell)
	if (
		code == SimConst.C_PROP
		and prop != null
		and (not parked or StreetMovesTape.CARS.has(prop.kind))
		and v.airborne()
		and v.hit.city_prop == prop
	):
		over_target = true
		return ""
	return (
		"centre in %s cell %s (%s)"
		% ["parked car" if parked else "solid", cell, prop.kind if prop != null else str(code)]
	)


func _index(city: CitySystem, key: Vector2i) -> void:
	_key = key
	_parked.clear()
	var chunk: CityChunk = city.residency.chunk_at(key)
	if chunk == null:
		return
	for i: int in chunk.command_count():
		var tex: int = chunk.tex[i]
		var o: int = i * CityChunk.XF_STRIDE
		if chunk.xf[o + 3] != 0.0 or not KerbDresser.PARKED.has(tex):
			continue
		var at: Vector2 = Vector2(chunk.xf[o], chunk.xf[o + 1])
		var size_m: Vector2 = Vector2(city.gen.sizes[tex].x * 0.9, KerbDresser.CAR_STRIP_M)
		var half: Vector2 = KerbDresser.quarter_turn(size_m, chunk.xf[o + 2]).abs() * 0.5
		var start: Vector2i = Vector2i((at - half).floor())
		_parked.append(Rect2i(start, Vector2i((at + half).ceil()) - start))


## BR_HIT reports hard knocks. Slow traffic also shoves: compare the incoming city body
## with each live tier-A moving hull at the same tick, in the car's heading frame.
func traffic(s: Quest1Session, incoming: Vector2) -> bool:
	near_traffic = false
	var contact: bool = s.city.sim.body_result()[SimConst.BR_HIT] > 0.0
	var snap: PackedFloat64Array = s.city.sim.snapshot()
	var variants: PackedByteArray = s.city.sim.get_variants()
	var r: float = s.city.body.table.radius(s.city.body.body_class)
	for i: int in range(0, snap.size(), SimConst.SNAP_STRIDE):
		if snap[i] >= SimConst.SNAP_PROJ_BASE:
			break
		if int(snap[i + 1]) not in [SimConst.K_CAR, SimConst.K_PCAR] or snap[i + 3] != 0.0:
			continue
		var dx: float = incoming.x - snap[i + 4]
		var dy: float = incoming.y - snap[i + 5]
		if dx * dx + dy * dy > 12.0 * 12.0 or snap[i + 8] <= 0.0:
			continue
		near_traffic = true
		var along: float = dx * snap[i + 6] + dy * snap[i + 7]
		var across: float = -dx * snap[i + 7] + dy * snap[i + 6]
		var bike: bool = variants[int(snap[i])] == SimConst.ART_BIKE
		var f: float = SimConst.BIKE_HULL_F if bike else CitySimBodyCars.CAR_HULL_F
		var side: float = SimConst.BIKE_HULL_S if bike else CitySimBodyCars.CAR_HULL_S
		if absf(along) < f + r and absf(across) < side + r:
			contact = true
	return contact
