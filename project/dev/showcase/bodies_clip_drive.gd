class_name BodiesClipDrive
extends WorldSystem
## The bodies clip's script on the fixed tick (registered after the city): plants a standing
## crowd on a long sidewalk band, then moves Rivet (city.target, the camera follows) east: stand
## 1 s, walk 10 s at 1.4 m/s through crowd A, stand 1 s, sprint 5 s at 6 m/s into crowd B, stand.

const WALK_MPS: float = 1.4
const SPRINT_MPS: float = 6.0

var band: Vector2 = Vector2(-1, -1)
var knocks: int = 0
var _city: CitySystem
var _start: Vector2
var _before: bool = false


func _init(city: CitySystem, start: Vector2, before: bool) -> void:
	_city = city
	_start = start
	_before = before
	_city.focus = start
	_city.target = start


func setup(_ctx: WorldContext) -> void:
	pass


func step(tick: int, _input: TickInput) -> void:
	if tick == 0:
		_plant()
		return
	if band.x < 0.0:
		return
	_city.body.on = not _before
	@warning_ignore("integer_division")
	knocks += _city.body.knocks.size() / SimConst.BR_STRIDE
	var t: float = tick * SimClock.TICK_DT
	var v: float = 0.0
	if t >= 1.0 and t < 11.0:
		v = WALK_MPS
	elif t >= 12.0 and t < 17.0:
		v = SPRINT_MPS
	var from: Vector2 = _city.target if _before else _city.body.pos
	_city.target = from + Vector2(v, 0.0) * SimClock.TICK_DT
	_city.focus = _city.target


## Finds a walkable band (sidewalk, kerb-side or lane: nothing solid) 50 m long near the start, puts Rivet on it and plants the crowds.
func _plant() -> void:
	for dy: int in range(-64, 65):
		for dx: int in range(-64, 65, 2):
			var p: Vector2 = Vector2(floorf(_start.x) + dx + 0.5, floorf(_start.y) + dy + 0.5)
			if _band_ok(p, 50.0):
				band = p
				break
		if band.x > 0.0:
			break
	if band.x < 0.0:
		Log.warn("bodies_clip", "no sidewalk band near %s" % _start)
		return
	_city.target = band
	_city.focus = band
	_city.body.pos = band
	for col: int in 5:
		for row: int in range(-1, 2):
			_stand(band + Vector2(4.0 + col * 2.5, row * 0.9), col * 3 + row + 1)
	for k: int in 8:
		_stand(band + Vector2(26.0 + k * 1.6, 0.45 * ((k % 3) - 1)), k)


func _stand(at: Vector2, look: int) -> void:
	var v: int = look % SimConst.CLIP_VARIANTS
	var spec: Array = [SimConst.K_PED, at.x, at.y, 1.0, 0.0, v, SimConst.F_PROMOTED, 0.0]
	@warning_ignore("return_value_discarded")
	_city.sim.spawn(PackedFloat64Array(spec + [0.0, 0]))


func _band_ok(p: Vector2, length: float) -> bool:
	for k: int in int(length) + 1:
		for row: int in range(-1, 2):
			var c: int = _city.sim.cell_at(p.x + k, p.y + row)
			if c < SimConst.C_LANE or c > SimConst.C_WALK:
				return false
	return true
