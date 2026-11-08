class_name DeadWallClipDrive
extends WorldSystem
## The dead-at-the-wall clip's script on the fixed tick (registered after the city): a pedestrian
## stands GAP_M west of a building's west face (the nearest such pavement spot to the city's
## start), and at STRIKE_TICK a lethal blow at BLOW_MPS throws him east into the face (the slide:
## 0.5 x the blow at 8 m/s^2, 4 m at 16 m/s). The camera (city.focus) holds on the spot.

const GAP_M: float = 1.5
const BLOW_MPS: float = 16.0
const STRIKE_TICK: int = 60
const SEARCH_M: int = 80

var spot: Vector2 = Vector2(-1, -1)
var face_x: float = -1.0
var rest: Vector2 = Vector2(-1, -1)
var _city: CitySystem
var _slot: int = -1


func _init(city: CitySystem) -> void:
	_city = city


func setup(_ctx: WorldContext) -> void:
	pass


func step(tick: int, _input: TickInput) -> void:
	if tick == 0:
		_plant()
		return
	if _slot < 0:
		return
	if tick == STRIKE_TICK:
		_city.sim.strike(_slot, BLOW_MPS, 0.0, true)
	elif tick > STRIKE_TICK:
		rest = _pos()


func _plant() -> void:
	_city.residency.update(_city.focus)
	spot = _find(_city.focus)
	if spot.x < 0.0:
		printerr("dead_wall_clip: no pavement spot by a building face within %d m" % SEARCH_M)
		return
	face_x = floorf(spot.x) + 2.0
	_city.focus = spot + Vector2(1.0, 0.0)
	_city.target = spot + Vector2(-6.0, 3.0)
	_city.body.pos = _city.target
	var spec: Array = [SimConst.K_PED, spot.x, spot.y, 1.0, 0.0, 2, 0, 0.0, 0, 0]
	_slot = _city.sim.spawn(PackedFloat64Array(spec))


## The nearest cell centre (x+0.5, y+0.5) with pavement 2 m west and 1 m east of it and a building
## cell 2 m east: the body stands GAP_M from the face.
func _find(around: Vector2) -> Vector2:
	var best: Vector2 = Vector2(-1, -1)
	var best_d: float = INF
	var cx: int = floori(around.x)
	var cy: int = floori(around.y)
	for y: int in range(cy - SEARCH_M, cy + SEARCH_M):
		for x: int in range(cx - SEARCH_M, cx + SEARCH_M):
			if not _row_fits(x, y):
				continue
			var d: float = Vector2(x - cx, y - cy).length_squared()
			if d < best_d:
				best_d = d
				best = Vector2(x + 0.5, y + 0.5)
	return best


func _row_fits(x: int, y: int) -> bool:
	for dx: int in range(-2, 2):
		if _cell(x + dx, y) != SimConst.C_WALK or _cell(x + dx, y - 1) != SimConst.C_WALK:
			return false
	return _cell(x + 2, y) == SimConst.C_BUILD and _cell(x + 2, y - 1) == SimConst.C_BUILD


func _cell(x: int, y: int) -> int:
	return _city.sim.cell_at(x + 0.5, y + 0.5)


func _pos() -> Vector2:
	var snap: PackedFloat64Array = _city.sim.snapshot()
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if snap[r] >= SimConst.SNAP_PROJ_BASE:
			break
		if int(snap[r]) == _slot:
			return Vector2(snap[r + 4], snap[r + 5])
	return rest
