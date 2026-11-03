class_name CityVehicleWorld
extends VehicleWorld
## Composition-root glue (LAY-05: vehicles never names the city): VehicleService's world over the
## streamed city's bubble sim. One snapshot per tick (refresh), solids from the 1 m cell map,
## hijack = the sim car leaves (kill) and its driver is spawned beside it and knocked down
## (strike, so they stagger off fleeing), run-overs through strike(), car states to custom.y.
## While Rivet drives, the city's bubble and pursuit target follow the car and Rivet's rig hides.

const DRIVER_VMAX: float = 1.4

var characters: CityCharacters = null
var _city: CitySystem
var _snap: PackedFloat64Array = PackedFloat64Array()
var _stale: bool = true
var _recs: Array[int] = []


func _init(city: CitySystem) -> void:
	_city = city


## Marks the cached snapshot stale; the next query takes one (a tick with no query takes none).
func refresh() -> void:
	_stale = true


func cars_near(at: Vector2, radius: float) -> PackedFloat64Array:
	var out: PackedFloat64Array = PackedFloat64Array()
	var variants: PackedByteArray = _city.sim.get_variants()
	for r: int in _records():
		var kind: int = int(_snap[r + 1])
		if kind != SimConst.K_CAR and kind != SimConst.K_PCAR:
			continue
		if Vector2(_snap[r + 4], _snap[r + 5]).distance_squared_to(at) > radius * radius:
			continue
		var slot: int = int(_snap[r])
		var police: float = 1.0 if kind == SimConst.K_PCAR else 0.0
		var art: int = variants[slot] if slot < variants.size() else 0
		out.append_array(
			[
				slot,
				police,
				_snap[r + 4],
				_snap[r + 5],
				_snap[r + 6],
				_snap[r + 7],
				_snap[r + 8],
				art
			]
		)
	return out


func people_near(at: Vector2, radius: float) -> PackedFloat64Array:
	var out: PackedFloat64Array = PackedFloat64Array()
	for r: int in _records():
		var kind: int = int(_snap[r + 1])
		if kind != SimConst.K_PED and kind != SimConst.K_COP:
			continue
		if Vector2(_snap[r + 4], _snap[r + 5]).distance_squared_to(at) > radius * radius:
			continue
		var dead: float = 1.0 if int(_snap[r + 2]) == SimConst.M_DEAD else 0.0
		out.append_array([_snap[r], _snap[r + 4], _snap[r + 5], dead])
	return out


func solid(x: float, y: float) -> bool:
	var c: int = _city.sim.cell_at(x, y)
	return c == SimConst.C_VOID or c >= SimConst.C_BUILD


func take_car(slot: int) -> void:
	_city.sim.kill(slot)
	_stale = true


func eject_driver(at: Vector2, away: Vector2, art: int) -> void:
	var spec: PackedFloat64Array = PackedFloat64Array(
		[SimConst.K_PED, at.x, at.y, away.x, away.y, art, 0, DRIVER_VMAX, 0.0, 0]
	)
	var slot: int = _city.sim.spawn(spec)
	if slot >= 0:
		_city.sim.strike(slot, away.x * 3.0, away.y * 3.0, false)


func strike_person(slot: int, vel: Vector2, kill: bool) -> bool:
	_city.sim.strike(slot, vel.x, vel.y, kill)
	return kill


func set_car_state(slot: int, state: int) -> void:
	_city.sim.set_car_state(slot, state)


func set_focus(at: Vector2, in_car: bool) -> void:
	_city.steer_by_input = not in_car
	_city.focus = at
	_city.target = at
	if characters != null:
		characters.rivet_on_foot = not in_car


## The service's view, printed like the city's traffic (the crowd car layers' mesh + material).
static func make_view(svc: VehicleService, view: CityView) -> VehicleView:
	var tex: Array[Texture2D] = []
	for f: String in [
		"traffic_atlas", "traffic_atlas_d1", "traffic_atlas_d2", "traffic_atlas_hijack"
	]:
		var path: String = "res://features/city/art/vehicles/%s.png" % f
		tex.append(load(path) as Texture2D if ResourceLoader.exists(path) else null)
	var v: VehicleView = VehicleView.new()
	var nodes: Array[MultiMeshInstance2D] = view.crowd.nodes
	v.setup(svc, tex, nodes[SimConst.RL_CARS], nodes[SimConst.RL_CAR_SHADOWS])
	return v


func player_pos() -> Vector2:
	return _city.target


## Record offsets of every live actor in the cached snapshot (projectiles excluded).
func _records() -> Array[int]:
	if not _stale:
		return _recs
	_snap = _city.sim.snapshot()
	_stale = false
	_recs.clear()
	for r: int in range(0, _snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if _snap[r] >= SimConst.SNAP_PROJ_BASE:
			break
		_recs.append(r)
	return _recs
