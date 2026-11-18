class_name CityRoadblock
extends RefCounted
## n18 heat 3: a roadblock of parked cruisers ahead of Rivet. Rivet's heading is his latest 3 m of
## motion (snapped to the street axes). When the level reaches one whose roadblock_cars count is
## above 0 (once an episode; heat 0 ends it), after `delay_ticks` the block is placed: the first
## junction between ahead_m.x and ahead_m.y ahead of him along that heading, `past_m` past its far
## edge on the road beyond, `cars` police cars parked across the road (F_PARKED: the sim keeps them
## at 0 m/s and traffic brakes for them as for any car ahead), spread evenly over its 8 m width.
## No junction ahead: it tries again each tick. Deterministic (no RNG): replay-safe.

const ART_POLICE_CAR: int = 8
const DX: Array[float] = [1.0, 0.0, -1.0, 0.0]
const DY: Array[float] = [0.0, 1.0, 0.0, -1.0]
const TILE_M: float = 8.0
const MOVE_M: float = 3.0

## Cars per level (index 0..3), the delay, the junction search window and the gap past it (m).
var cars: PackedInt32Array = PackedInt32Array([0, 0, 0, 2])
var delay_ticks: int = 120
var ahead_m: Vector2 = Vector2(25.0, 90.0)
var past_m: float = 6.0
## Cars placed this episode (0 until the block stands).
var placed: int = 0
## Where the block stands (the road centre between its cars); valid once placed > 0.
var at: Vector2 = Vector2.ZERO
var _due: int = -1
var _anchor: Vector2 = Vector2.INF
var _dir: int = -1


## One tick. Returns the cars placed this tick.
func step(sim: CitySimBackend, tick: int, level: int, rivet: Vector2) -> int:
	_track(rivet)
	if level <= 0:
		placed = 0
		_due = -1
		return 0
	var n: int = cars[mini(level, cars.size() - 1)]
	if placed > 0 or n <= 0:
		return 0
	if _due < 0:
		_due = tick + delay_ticks
	if tick < _due or _dir < 0:
		return 0
	var spot: Vector3 = find(sim, rivet, _dir, ahead_m, past_m)
	if spot.z < 0.0:
		return 0
	at = Vector2(spot.x, spot.y)
	placed = _park(sim, at, int(spot.z), n)
	return placed


## The block's centre (x, y) and the axis of its road (z: the street direction 0..3), or z -1:
## the first junction tile from `from` along `d` within `window`, then `past` beyond its far edge.
static func find(
	sim: CitySimBackend, from: Vector2, d: int, window: Vector2, past: float
) -> Vector3:
	var s: float = window.x
	while s <= window.y and sim.tile_at(from.x + DX[d] * s, from.y + DY[d] * s) != SimConst.T_INTER:
		s += 1.0
	if s > window.y:
		return Vector3(0.0, 0.0, -1.0)
	var unit: Vector2i = Vector2i(int(DX[d]), int(DY[d]))
	var t: Vector2i = Vector2i(((from + Vector2(unit) * s) / TILE_M).floor())
	while _tile(sim, t + unit) == SimConst.T_INTER:
		t += unit
	var c: Vector2 = (Vector2(t) + Vector2(0.5, 0.5)) * TILE_M  # the far junction tile's centre
	var p: Vector2 = c + Vector2(DX[d], DY[d]) * (TILE_M * 0.5 + past)
	var want: int = SimConst.T_ROAD_H if d % 2 == 0 else SimConst.T_ROAD_V
	if sim.tile_at(p.x, p.y) != want:
		return Vector3(0.0, 0.0, -1.0)
	return Vector3(p.x, p.y, float(d))


static func _tile(sim: CitySimBackend, t: Vector2i) -> int:
	return sim.tile_at((float(t.x) + 0.5) * TILE_M, (float(t.y) + 0.5) * TILE_M)


## n cars across the road at `c`, nose across the street (perpendicular to d), F_PARKED.
static func _park(sim: CitySimBackend, c: Vector2, d: int, n: int) -> int:
	var side: int = (d + 1) % 4
	var gap: float = TILE_M / float(n)
	var fl: int = SimConst.F_PROMOTED | SimConst.F_PARKED
	var out: int = 0
	for k: int in n:
		var off: float = (float(k) - 0.5 * float(n - 1)) * gap
		var x: float = c.x + DX[side] * off
		var y: float = c.y + DY[side] * off
		var lane: float = x if side % 2 == 1 else y
		var spec: Array = [SimConst.K_PCAR, x, y, DX[side], DY[side], ART_POLICE_CAR, fl, 17.0]
		if sim.spawn(PackedFloat64Array(spec + [lane, side])) >= 0:
			out += 1
	return out


## Rivet's heading: his latest MOVE_M of motion, snapped to the dominant axis.
func _track(rivet: Vector2) -> void:
	if _anchor == Vector2.INF:
		_anchor = rivet
		return
	var m: Vector2 = rivet - _anchor
	if m.length_squared() < MOVE_M * MOVE_M:
		return
	_anchor = rivet
	if absf(m.x) >= absf(m.y):
		_dir = 0 if m.x > 0.0 else 2
	else:
		_dir = 1 if m.y > 0.0 else 3


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(placed)
	out.put_32(_due)
	out.put_8(_dir)
	out.put_double(at.x)
	out.put_double(at.y)
