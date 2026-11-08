class_name Block70Drive
extends WorldSystem
## The true-70 block test (d10): plants the camera and Rivet on the nearest pavement south of a
## building's south wall, with a few pedestrians, one of them struck dead at STRIKE_TICK.

const SEARCH_M: int = 120
const STRIKE_TICK: int = 40

var spot: Vector2 = Vector2(-1, -1)
var _city: CitySystem
var _slot: int = -1


func _init(city: CitySystem) -> void:
	_city = city


func setup(_ctx: WorldContext) -> void:
	pass


func step(tick: int, _input: TickInput) -> void:
	if tick == 0:
		_plant()
	elif tick == STRIKE_TICK and _slot >= 0:
		_city.sim.strike(_slot, 6.0, 0.0, true)


func _plant() -> void:
	_city.residency.update(_city.focus)
	spot = _find(_city.focus)
	if spot.x < 0.0:
		printerr("block70: no pavement south of a wall within %d m" % SEARCH_M)
		return
	_city.focus = spot + Vector2(0.0, -2.0)
	_city.target = spot + Vector2(0.0, 2.0)
	_city.body.pos = _city.target
	for off: Vector2 in [Vector2(3, 2), Vector2(-4, 1), Vector2(6, 0)]:
		var at: Vector2 = spot + off
		var spec: Array = [SimConst.K_PED, at.x, at.y, 1.0, 0.0, 2, 0, 0.0, 0, 0]
		var slot: int = _city.sim.spawn(PackedFloat64Array(spec))
		if _slot < 0:
			_slot = slot


## The nearest cell with 3 walk rows here and south of it and a 12-wide building to its north.
func _find(around: Vector2) -> Vector2:
	var best: Vector2 = Vector2(-1, -1)
	var best_d: float = INF
	var cx: int = floori(around.x)
	var cy: int = floori(around.y)
	for y: int in range(cy - SEARCH_M, cy + SEARCH_M):
		for x: int in range(cx - SEARCH_M, cx + SEARCH_M):
			if _fits(x, y):
				var d: float = Vector2(x - cx, y - cy).length_squared()
				if d < best_d:
					best_d = d
					best = Vector2(x + 0.5, y + 0.5)
	return best


func _fits(x: int, y: int) -> bool:
	for dx: int in range(-6, 7):
		if _cell(x + dx, y - 1) != SimConst.C_BUILD or _cell(x + dx, y - 3) != SimConst.C_BUILD:
			return false
		for dy: int in range(0, 3):
			if _cell(x + dx, y + dy) != SimConst.C_WALK:
				return false
	return true


func _cell(x: int, y: int) -> int:
	return _city.sim.cell_at(x + 0.5, y + 0.5)
