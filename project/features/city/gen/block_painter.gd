class_name BlockPainter
extends RefCounted
## Paints one building-block tile (CityGen layout: rows and columns 3-7 of a street period) from
## its zone's rules (CityZone): parapet roof ground, one 8.4 m roof per tile, a 16.4 m long roof
## over two, or a 2 x 2 big roof over the interior. Split from TilePainter (n18 districts).

const PERIOD: int = CityGen.PERIOD
## Square roofs: the zone's landmark_roofs on its landmark_share of the tiles, the rest its
## generic_roofs (CityZone; mixed: the 8 district buildings 14-21 on 30 %, the 7 generic roofs
## 65-71). Lettered roofs (and the warehouse's 7) stay upright.
const LETTERED: Array[int] = [14, 16, 18, 19, 21, 23]
## T1's coarse rooftops: on the zone's big_share of the blocks one 16.4 m building covers the
## 2 x 2 interior tiles (mx, my 4-5) with T1-scale objects; no long building crosses it. The
## zone's big_roofs plates (mixed: 78 tank + fan pairs, 79 machine room + fan row, 80 skylight
## grid + two tanks), cycled A-B-C along a block row from a per-row random offset; upright.
## Long (two-tile) buildings from the zone's long_roofs (mixed: 22 long, 23 warehouse, 81 the
## T1-scale long roof, upright only).
const T_LONG_T1: int = 81


## Roofs: a parapet edge toward the street on the block perimeter, plain roof inside; one 8.4 m
## building per tile, or a 16.4 m one over two tiles (placed from the left tile of the pair).
func paint(g: CityGen, b: ChunkBuild, t: Vector2i) -> int:
	var mx: int = t.x % PERIOD
	var my: int = t.y % PERIOD
	var o: Vector2 = TilePainter.origin(t)
	var c: Vector2 = o + Vector2(4.0, 4.0)
	var edge: float = _edge(mx, my)
	if edge >= 0.0:
		b.add(ChunkBuild.L_GROUND, 11, c, deg_to_rad(edge))
	else:
		b.add(ChunkBuild.L_GROUND, 12, c, 0.0)
	b.stamp(Rect2(o, Vector2(8, 8)), SimConst.C_BUILD)
	var big: bool = _big_rows(g, t)
	if big and (mx == 4 or mx == 5):
		if mx == 4 and my == 4:  # upright: its big hatched shadows fall lower-right, as T1's
			var bk: Vector2i = Vector2i(floori(float(t.x) / PERIOD), floori(float(t.y) / PERIOD))
			var plates: Array[int] = g.zones.of_tile(t).big_roofs
			var pick: int = posmod(bk.x + int(g.rnd(0, bk.y, 0, 62) * plates.size()), plates.size())
			b.add(ChunkBuild.L_ROOF, plates[pick], o + Vector2(8.0, 8.0), 0.0, true)
		return SimConst.T_BLOCK
	if _empty_interior(g, t) or ((mx == 4 or mx == 6) and _long_at(g, Vector2i(t.x - 1, t.y))):
		return SimConst.T_BLOCK
	var zone: CityZone = g.zones.of_tile(t)
	if (mx == 3 or mx == 5) and not big and g.rnd(t.x, t.y, 0, 32) < zone.long_share:
		var longs: Array[int] = zone.long_roofs
		var tex: int = longs[int(g.rnd(t.x, t.y, 0, 33) * longs.size())]
		var turn: bool = g.rnd(t.x, t.y, 0, 34) < 0.5 and not LETTERED.has(tex) and tex != T_LONG_T1
		var rot: float = PI if turn else 0.0
		b.add(ChunkBuild.L_ROOF, tex, Vector2(c.x + 4.0, c.y), rot, true)
	else:
		var tex: int = _square_roof(g, t)
		var rot: float = deg_to_rad(90.0 * int(g.rnd(t.x, t.y, 0, 34) * 4.0))
		if LETTERED.has(tex):
			rot = 0.0
		b.add(ChunkBuild.L_ROOF, tex, c, rot, true)
	return SimConst.T_BLOCK


## A tile's roof; one that repeats its left or upper neighbour's pick steps to the next generic.
static func _square_roof(g: CityGen, t: Vector2i) -> int:
	var tex: int = _roof_pick(g, t)
	var left: int = _roof_pick(g, t + Vector2i.LEFT)
	var up: int = _roof_pick(g, t + Vector2i.UP)
	var generic: Array[int] = g.zones.of_tile(t).generic_roofs
	var step: int = generic.find(tex) + 1
	for i: int in 3:
		if tex != left and tex != up:
			break
		tex = generic[(step + i) % generic.size()]
	return tex


static func _roof_pick(g: CityGen, t: Vector2i) -> int:
	var zone: CityZone = g.zones.of_tile(t)
	var r: float = g.rnd(t.x, t.y, 0, 33)
	var share: float = zone.landmark_share
	var marks: Array[int] = zone.landmark_roofs
	if r < share:
		return marks[mini(int(r / share * marks.size()), marks.size() - 1)]
	var generic: Array[int] = zone.generic_roofs
	var k: int = int((r - share) / (1.0 - share) * generic.size())
	return generic[mini(k, generic.size() - 1)]


static func _edge(mx: int, my: int) -> float:
	if my == 3:
		return 0.0
	if my == 7:
		return 180.0
	if mx == 3:
		return 270.0
	return 90.0 if mx == 7 else -1.0


static func _empty_interior(g: CityGen, t: Vector2i) -> bool:
	var mx: int = t.x % PERIOD
	var my: int = t.y % PERIOD
	var interior: bool = mx >= 4 and mx <= 6 and my >= 4 and my <= 6
	return interior and g.rnd(t.x, t.y, 0, 31) < g.zones.of_tile(t).empty_share


## Whether tile t starts a long (two-tile) building, so its right neighbour stays empty.
static func _long_at(g: CityGen, t: Vector2i) -> bool:
	var mx: int = t.x % PERIOD
	if _big_rows(g, t):
		return false
	var zone: CityZone = g.zones.of_tile(t)
	if g.rnd(floori(float(t.x) / PERIOD), floori(float(t.y) / PERIOD), 0, 5) < zone.plaza_share:
		return false
	if _empty_interior(g, t):
		return false
	return (mx == 3 or mx == 5) and g.rnd(t.x, t.y, 0, 32) < zone.long_share


## Whether tile t sits in rows 4-5 of a block that holds the 2 x 2 building.
static func _big_rows(g: CityGen, t: Vector2i) -> bool:
	var my: int = t.y % PERIOD
	var bx: int = floori(float(t.x) / PERIOD)
	var share: float = g.zones.of_tile(t).big_share
	return (my == 4 or my == 5) and g.rnd(bx, floori(float(t.y) / PERIOD), 0, 6) < share
