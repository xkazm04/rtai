class_name StageCells
extends RefCounted
## The generated city's 1 m walk cells for quest 1 on the city (CityGen chunks, generated on
## demand and cached: a pure function of the district table, so the same on every run and in
## --replay). Solid = building, prop or parked car, or off the map (CitySimSolid's rule). Rivet
## is pushed out of solid cells the way the city sim pushes its people out.

var _gen: CityGen
var _chunks: Dictionary[Vector2i, PackedByteArray] = {}


func _init(gen: CityGen) -> void:
	_gen = gen


static func shipped() -> StageCells:
	return StageCells.new(CityGen.from_tables(CitySystem.DISTRICT, CitySystem.TEXTURES))


func code_at(cx: int, cy: int) -> int:
	if cx < 0 or cy < 0 or cx >= SimConst.W or cy >= SimConst.W:
		return SimConst.C_VOID
	var n: int = SimConst.CHUNK_CELLS
	var key: Vector2i = Vector2i(cx / n, cy / n)
	if not _chunks.has(key):
		_chunks[key] = _gen.gen_chunk(key.x, key.y).cells
	return _chunks[key][(cy % n) * n + (cx % n)]


func solid(cx: int, cy: int) -> bool:
	var c: int = code_at(cx, cy)
	return c == SimConst.C_VOID or c >= SimConst.C_BUILD


## True when a circle of radius r at p overlaps no solid cell.
func clear(p: Vector2, r: float) -> bool:
	for cy: int in range(floori(p.y - r), floori(p.y + r) + 1):
		for cx: int in range(floori(p.x - r), floori(p.x + r) + 1):
			if not solid(cx, cy):
				continue
			var q: Vector2 = Vector2(clampf(p.x, cx, cx + 1.0), clampf(p.y, cy, cy + 1.0))
			if p.distance_squared_to(q) < r * r:
				return false
	return true


## p pushed out of every solid cell the circle overlaps (a centre inside a cell leaves by the
## nearest side).
func push_out(p: Vector2, r: float) -> Vector2:
	var out: Vector2 = p
	for cy: int in range(floori(p.y - r), floori(p.y + r) + 1):
		for cx: int in range(floori(p.x - r), floori(p.x + r) + 1):
			if not solid(cx, cy):
				continue
			var q: Vector2 = Vector2(clampf(out.x, cx, cx + 1.0), clampf(out.y, cy, cy + 1.0))
			var d: Vector2 = out - q
			var len: float = d.length()
			if len >= r:
				continue
			if len > 1e-6:
				out += d / len * (r - len)
			else:
				out = _eject(out, cx, cy, r)
	return out


static func _eject(p: Vector2, cx: int, cy: int, r: float) -> Vector2:
	var sides: Array[float] = [p.x - cx, cx + 1.0 - p.x, p.y - cy, cy + 1.0 - p.y]
	var m: float = sides.min()
	if m == sides[0]:
		return Vector2(cx - r, p.y)
	if m == sides[1]:
		return Vector2(cx + 1.0 + r, p.y)
	if m == sides[2]:
		return Vector2(p.x, cy - r)
	return Vector2(p.x, cy + 1.0 + r)


## True when a circle of radius r swept from a to b stays clear (sampled every 0.25 m).
func swept_clear(a: Vector2, b: Vector2, r: float) -> bool:
	var steps: int = maxi(ceili(a.distance_to(b) / 0.25), 1)
	for i: int in steps + 1:
		if not clear(a.lerp(b, float(i) / steps), r):
			return false
	return true
