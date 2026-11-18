class_name CityDispatch
extends RefCounted
## n18 heat 2: police cars sent to the last-seen point. When the level rises to L (2 or more) the
## dispatcher owes the heat table's city.cars[L] cars this episode, less those already sent; after
## city.car_delay_s it spawns them, one a tick, on a road tile city.car_ring_m from the point and
## inside the bubble, in the lane heading toward the point, F_ENGAGED | F_PROMOTED. The sim routes
## them (the police turn rule), stops them within car_stop_m and lets the crew out. Heat 0 ends
## the episode. Its own RNG stream (replay-safe).

const STREAM: StringName = &"city_dispatch"
const ART_POLICE_CAR: int = 8
const DX: Array[float] = [1.0, 0.0, -1.0, 0.0]
const DY: Array[float] = [0.0, 1.0, 0.0, -1.0]
const LANE_OFF: Array[float] = [2.0, -2.0, -2.0, 2.0]
const TRIES: int = 40
## The bubble margin a dispatched car keeps (m inside rb), so the tier pass does not drop it.
const EDGE_M: float = 15.0

## Cars owed per level (index 0..3), the delay and the spawn ring round the point (m).
var cars: PackedInt32Array = PackedInt32Array([0, 0, 2, 3])
var delay_ticks: int = 180
var ring_m: Vector2 = Vector2(60.0, 110.0)
## Cars sent this episode.
var sent: int = 0
var _owed: int = 0
var _due: int = 0
var _level: int = 0
var _rng: RandomNumberGenerator


func _init(rng: RandomNumberGenerator) -> void:
	_rng = rng


## One tick. Returns the cars spawned (0 or 1).
func step(sim: CitySimBackend, tick: int, level: int, point: Vector2, cam: Vector2) -> int:
	if level <= 0:
		sent = 0
		_owed = 0
		_level = 0
		return 0
	if level > _level:
		_owed = maxi(0, cars[mini(level, cars.size() - 1)] - sent)
		_due = tick + delay_ticks
	_level = level
	if _owed <= 0 or tick < _due:
		return 0
	for k: int in TRIES:
		if _try(sim, point, cam):
			_owed -= 1
			sent += 1
			return 1
	return 0


func _try(sim: CitySimBackend, point: Vector2, cam: Vector2) -> bool:
	var a: float = _rng.randf() * TAU
	var r: float = lerpf(ring_m.x, ring_m.y, _rng.randf())
	var x: float = point.x + cos(a) * r
	var y: float = point.y + sin(a) * r
	var cdx: float = x - cam.x
	var cdy: float = y - cam.y
	var reach: float = CitySystem.RB - EDGE_M
	if cdx * cdx + cdy * cdy > reach * reach:
		return false
	var t: int = sim.tile_at(x, y)
	var d: int = 0
	if t == SimConst.T_ROAD_H:
		d = 0 if point.x > x else 2
		y = floorf(y / 8.0) * 8.0 + 4.0 + LANE_OFF[d]
	elif t == SimConst.T_ROAD_V:
		d = 1 if point.y > y else 3
		x = floorf(x / 8.0) * 8.0 + 4.0 + LANE_OFF[d]
	else:
		return false
	var lane: float = y if (d == 0 or d == 2) else x
	var fl: int = SimConst.F_PROMOTED | SimConst.F_ENGAGED
	var spec: Array = [SimConst.K_PCAR, x, y, DX[d], DY[d], ART_POLICE_CAR, fl, 17.0, lane, d]
	return sim.spawn(PackedFloat64Array(spec)) >= 0


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(sent)
	out.put_32(_owed)
	out.put_32(_due)
	out.put_8(_level)
