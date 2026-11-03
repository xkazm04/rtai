class_name TilePainter
extends RefCounted
## Paints one 8 m tile into a ChunkBuild: draw commands, cell codes and spawn densities. Returns
## the tile code. Junction (3 x 3 per period), street segments, plaza blocks and building blocks.

const PERIOD: int = CityGen.PERIOD
const T_TRAFFIC_LIGHT: int = 35
## The junction box is plain asphalt; zebras cross each approach kerb to kerb just outside the
## crossing street's kerb line (5.15-7.55 m from the box, clear of the rounded corners; T1).
const T_BOX: int = 72
const T_ZEBRA: int = 73
const ZEBRA_IN_M: float = -2.35
## Clean asphalt over both halves of an approach arm: no dashes in the crossing or the zebra.
const T_DASH_ERASER: int = 74
## plaza dressing: one prop per slot (3 slots a tile, apart so their footprints never meet);
## benches and planters twice; no barrel_cluster (prints vermilion), no lamp (reads as a spoon)
const PLAZA_PROPS: Array[int] = [28, 33, 26, 28, 32, 29, 33]
const PLAZA_SLOTS: Array[Vector2] = [Vector2(2.0, 2.0), Vector2(6.0, 3.5), Vector2(2.8, 6.2)]
const PLAZA_SHARE: float = 0.6
const PLAZA_JITTER_M: float = 0.8
const CORNER_ROT: Array[float] = [0.0, 90.0, 270.0, 180.0]
## T1 lights its corners with street lamps: two diagonal corners take the inked lamp, the other
## two keep a traffic light, each over the crossing (45 degrees).
## Square roofs: the 8 district buildings (14-21) are landmarks, LANDMARK_SHARE of the blocks;
## the rest take the 7 generic roofs (65-71). Lettered roofs (and the warehouse's 7) stay upright.
const LANDMARK_SHARE: float = 0.3
const GENERIC_ROOF: int = 65
const GENERIC_ROOFS: int = 7
const LETTERED: Array[int] = [14, 16, 18, 19, 21, 23]
## T1's coarse rooftops: on BIG_SHARE of the blocks one 16.4 m building covers the 2 x 2 interior
## tiles (mx, my 4-5) with T1-scale objects (a 4.5 m tank, 2.2 m fans); no long building crosses it.
const T_BIG_ROOF: int = 78
const BIG_SHARE: float = 0.35

var _kerb: KerbDresser = KerbDresser.new()


func paint(g: CityGen, b: ChunkBuild, ti: int, tj: int) -> int:
	var mx: int = ti % PERIOD
	var my: int = tj % PERIOD
	if mx <= 2 and my <= 2:
		return _junction(g, b, Vector2i(ti, tj))
	if mx <= 2 or my <= 2:
		return _street(g, b, Vector2i(ti, tj), my <= 2)
	if g.rnd(floori(float(ti) / PERIOD), floori(float(tj) / PERIOD), 0, 5) < 0.12:
		return _plaza(g, b, Vector2i(ti, tj))
	return _block(g, b, Vector2i(ti, tj))


static func origin(t: Vector2i) -> Vector2:
	return Vector2(t.x * SimConst.TILE_M, t.y * SimConst.TILE_M)


static func local_index(t: Vector2i) -> int:
	var n: int = SimConst.CHUNK_TILES
	return (t.y % n) * n + (t.x % n)


func _junction(g: CityGen, b: ChunkBuild, t: Vector2i) -> int:
	var mx: int = t.x % PERIOD
	var my: int = t.y % PERIOD
	var o: Vector2 = origin(t)
	var c: Vector2 = o + Vector2(4.0, 4.0)
	var v3: int = _variant(g, t, mx != 1)
	if mx == 1 or my == 1:
		var tex: int = T_BOX if mx == my else (3 + v3 if mx == 1 else v3)
		b.add(ChunkBuild.L_GROUND, tex, c, 0.0)
		if mx != my:
			var to_box: Vector2 = Vector2(1 - mx, 1 - my)
			var across: float = 0.0 if mx == 1 else PI * 0.5
			for half: float in [2.0, -2.0]:
				b.add(ChunkBuild.L_DECAL, T_DASH_ERASER, c + to_box * half, PI * 0.5 - across)
			b.add(ChunkBuild.L_DECAL, T_ZEBRA, c + to_box * ZEBRA_IN_M, across)
		b.stamp(Rect2(o, Vector2(8, 8)), SimConst.C_LANE)
		if mx == my:
			b.chunk.dens_car[local_index(t)] = 0
			return SimConst.T_INTER
		return SimConst.T_ROAD_V if mx == 1 else SimConst.T_ROAD_H
	# rounded kerb corner: sidewalk in the corner that touches the block diagonal
	var k: int = (mx >> 1) + 2 * (my >> 1)
	var rot: float = CORNER_ROT[k]
	b.add(ChunkBuild.L_GROUND, 10, c, deg_to_rad(rot))
	b.stamp(Rect2(o, Vector2(8, 8)), SimConst.C_PARK)
	var s: Vector2 = Vector2(o.x if mx == 0 else o.x + 5.0, o.y if my == 0 else o.y + 5.0)
	b.stamp(Rect2(s, Vector2(3, 3)), SimConst.C_WALK)
	var post: int = KerbDresser.T_LAMP if k == 0 or k == 3 else T_TRAFFIC_LIGHT
	b.add(ChunkBuild.L_PROP, post, s + Vector2(1.5, 1.5), deg_to_rad(rot + 45.0), true)
	b.chunk.dens_ped[local_index(t)] = int(90 * b.district)
	return SimConst.T_CORNER


func _street(g: CityGen, b: ChunkBuild, t: Vector2i, horiz: bool) -> int:
	var m: int = (t.y if horiz else t.x) % PERIOD
	var o: Vector2 = origin(t)
	var c: Vector2 = o + Vector2(4.0, 4.0)
	var v3: int = _variant(g, t, horiz)
	if m == 1:
		b.add(ChunkBuild.L_GROUND, v3 if horiz else 3 + v3, c, 0.0)
		b.stamp(Rect2(o, Vector2(8, 8)), SimConst.C_LANE)
		b.chunk.dens_car[local_index(t)] = 200
		_kerb.road_decals(g, b, t, horiz)
		return SimConst.T_ROAD_H if horiz else SimConst.T_ROAD_V
	var rotd: float = (0.0 if m == 0 else 180.0) if horiz else (270.0 if m == 0 else 90.0)
	var rot: float = deg_to_rad(rotd)
	b.add(ChunkBuild.L_GROUND, 7 + v3, c, rot)
	# rotate each cell centre back into the rot-0 frame: sidewalk where v < 3
	for yy: int in 8:
		for xx: int in 8:
			var p: Vector2 = KerbDresser.quarter_turn(Vector2(xx + 0.5 - 4.0, yy + 0.5 - 4.0), -rot)
			var code: int = SimConst.C_WALK if p.y + 4.0 < 3.0 else SimConst.C_PARK
			b.set_cell(int(o.x) + xx, int(o.y) + yy, code)
	_kerb.dress(g, b, t, rot, horiz)
	b.chunk.dens_ped[local_index(t)] = int(clampf(140.0 * b.district, 0, 255))
	return SimConst.T_CURB


func _plaza(g: CityGen, b: ChunkBuild, t: Vector2i) -> int:
	var o: Vector2 = origin(t)
	# a quarter turn per tile breaks the 8 m repeat of the paving's cracks and stains (joints stay)
	var turn: float = deg_to_rad(90.0 * int(g.rnd(t.x, t.y, 0, 26) * 4.0))
	b.add(ChunkBuild.L_GROUND, 13, o + Vector2(4.0, 4.0), turn)
	b.stamp(Rect2(o, Vector2(8, 8)), SimConst.C_WALK)
	b.chunk.dens_ped[local_index(t)] = int(255 * b.district)
	for k: int in PLAZA_SLOTS.size():
		if g.rnd(t.x, t.y, k, 21) < PLAZA_SHARE:
			var tex: int = PLAZA_PROPS[int(g.rnd(t.x, t.y, k, 22) * PLAZA_PROPS.size())]
			var jitter: Vector2 = (
				Vector2(g.rnd(t.x, t.y, k, 23), g.rnd(t.x, t.y, k, 24)) - Vector2.ONE * 0.5
			)
			var p: Vector2 = o + PLAZA_SLOTS[k] + jitter * PLAZA_JITTER_M
			var rot: float = deg_to_rad(90.0 * int(g.rnd(t.x, t.y, k, 25) * 4.0))
			_kerb.prop(g, b, tex, p, rot)
	return SimConst.T_PLAZA


## Roofs: a parapet edge toward the street on the block perimeter, plain roof inside; one 8.4 m
## building per tile, or a 16.4 m one over two tiles (placed from the left tile of the pair).
func _block(g: CityGen, b: ChunkBuild, t: Vector2i) -> int:
	var mx: int = t.x % PERIOD
	var my: int = t.y % PERIOD
	var o: Vector2 = origin(t)
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
			b.add(ChunkBuild.L_ROOF, T_BIG_ROOF, o + Vector2(8.0, 8.0), 0.0, true)
		return SimConst.T_BLOCK
	if _empty_interior(g, t) or ((mx == 4 or mx == 6) and _long_at(g, Vector2i(t.x - 1, t.y))):
		return SimConst.T_BLOCK
	if (mx == 3 or mx == 5) and not big and g.rnd(t.x, t.y, 0, 32) < 0.3:
		var tex: int = 22 + int(g.rnd(t.x, t.y, 0, 33) * 2.0)
		var rot: float = PI if g.rnd(t.x, t.y, 0, 34) < 0.5 and not LETTERED.has(tex) else 0.0
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
	var step: int = (tex - GENERIC_ROOF + 1) if tex >= GENERIC_ROOF else 0
	for i: int in 3:
		if tex != left and tex != up:
			break
		tex = GENERIC_ROOF + (step + i) % GENERIC_ROOFS
	return tex


static func _roof_pick(g: CityGen, t: Vector2i) -> int:
	var r: float = g.rnd(t.x, t.y, 0, 33)
	if r < LANDMARK_SHARE:
		return 14 + mini(int(r / LANDMARK_SHARE * 8.0), 7)
	var k: int = int((r - LANDMARK_SHARE) / (1.0 - LANDMARK_SHARE) * GENERIC_ROOFS)
	return GENERIC_ROOF + mini(k, GENERIC_ROOFS - 1)


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
	return interior and g.rnd(t.x, t.y, 0, 31) < 0.45


## Whether tile t starts a long (two-tile) building, so its right neighbour stays empty.
static func _long_at(g: CityGen, t: Vector2i) -> bool:
	var mx: int = t.x % PERIOD
	if _big_rows(g, t):
		return false
	if g.rnd(floori(float(t.x) / PERIOD), floori(float(t.y) / PERIOD), 0, 5) < 0.12:
		return false
	if _empty_interior(g, t):
		return false
	return (mx == 3 or mx == 5) and g.rnd(t.x, t.y, 0, 32) < 0.3


## Whether tile t sits in rows 4-5 of a block that holds the 2 x 2 building.
static func _big_rows(g: CityGen, t: Vector2i) -> bool:
	var my: int = t.y % PERIOD
	var bx: int = floori(float(t.x) / PERIOD)
	return (my == 4 or my == 5) and g.rnd(bx, floori(float(t.y) / PERIOD), 0, 6) < BIG_SHARE


## Road / kerb art variant (0-2): an a-b-c cycle along the street from a random offset
## per street line, so two neighbouring tiles never share a variant (a random pick
## repeated a distinctive crack on every third pair of tiles).
static func _variant(g: CityGen, t: Vector2i, horiz: bool) -> int:
	var k: int = t.x if horiz else t.y
	var line: int = t.y if horiz else t.x
	return posmod(k + int(g.rnd(line, 1 if horiz else 0, 0, 7) * 3.0), 3)
