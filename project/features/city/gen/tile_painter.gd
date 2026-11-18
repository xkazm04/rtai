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
const ZEBRA_IN_M: float = -2.35 + (CityGen.WALK_M - 3.0)
## Clean asphalt over both halves of an approach arm: no dashes in the crossing or the zebra.
const T_DASH_ERASER: int = 74
## plaza dressing: one prop per slot (3 slots a tile, apart so their footprints never meet), from
## the zone's plaza_props under its plaza_prop_share (CityZone; the mixed row: benches and planters
## twice, no barrel_cluster (prints vermilion), no lamp (reads as a spoon))
const PLAZA_SLOTS: Array[Vector2] = [Vector2(2.0, 2.0), Vector2(6.0, 3.5), Vector2(2.8, 6.2)]
const PLAZA_JITTER_M: float = 0.8
const CORNER_ROT: Array[float] = [0.0, 90.0, 270.0, 180.0]
## T1 lights its corners with street lamps: two diagonal corners take the inked lamp, the other
## two keep a traffic light, each over the crossing (45 degrees).

var _kerb: KerbDresser = KerbDresser.new()
var _blocks: BlockPainter = BlockPainter.new()
var _docks: DockPainter = DockPainter.new()


func paint(g: CityGen, b: ChunkBuild, ti: int, tj: int) -> int:
	var t: Vector2i = Vector2i(ti, tj)
	var mx: int = ti % PERIOD
	var my: int = tj % PERIOD
	var zone: CityZone = g.zones.of_tile(t)
	if zone.street_keep_x > 1:
		return _docks_tile(g, b, zone, t)
	if mx <= 2 and my <= 2:
		return _junction(g, b, t)
	if mx <= 2 or my <= 2:
		return _street(g, b, t, my <= 2)
	if g.rnd(floori(float(ti) / PERIOD), floori(float(tj) / PERIOD), 0, 5) < zone.plaza_share:
		return _plaza(g, b, t)
	return _blocks.paint(g, b, t)


## A docks tile (DockPainter): water and quay first (between the piers: every road still ends only
## at the city edge, test_city_lane_grid), then the kept streets, a dropped street line as block
## (its east-west crossings as plain street), the long blocks' yards and warehouses.
func _docks_tile(g: CityGen, b: ChunkBuild, zone: CityZone, t: Vector2i) -> int:
	var wx: int = DockPainter.water_x(zone)
	var my: int = posmod(t.y, PERIOD)
	if wx >= 0 and t.x >= wx - 1 and my > 2:  # the east-west streets run on as piers to the edge
		return _docks.quay(g, b, _kerb, t, t.x < wx)
	if DockPainter.dropped(zone, t):
		if my <= 2:
			return _street(g, b, t, true)
	elif posmod(t.x, PERIOD) <= 2 and my <= 2:
		return _junction(g, b, t)
	elif posmod(t.x, PERIOD) <= 2 or my <= 2:
		return _street(g, b, t, my <= 2)
	if DockPainter.is_yard(g, zone, t):  # no yard_props: a plaza (the v18 look)
		return _plaza(g, b, t) if zone.yard_props.is_empty() else _docks.yard(g, b, _kerb, zone, t)
	return _docks.block(g, b, zone, t)


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
	b.add(ChunkBuild.L_GROUND, CityGen.CORNER_TEX, c, deg_to_rad(rot))
	b.stamp(Rect2(o, Vector2(8, 8)), SimConst.C_PARK)
	var w: float = CityGen.WALK_M
	var s: Vector2 = Vector2(o.x if mx == 0 else o.x + 8.0 - w, o.y if my == 0 else o.y + 8.0 - w)
	b.stamp(Rect2(s, Vector2(w, w)), SimConst.C_WALK)
	var post: int = KerbDresser.T_LAMP if k == 0 or k == 3 else T_TRAFFIC_LIGHT
	var at: Vector2 = Vector2(w - 1.5 if mx == 0 else 1.5, w - 1.5 if my == 0 else 1.5)
	b.add(ChunkBuild.L_PROP, post, s + at, deg_to_rad(rot + 45.0), true)
	b.chunk.dens_ped[local_index(t)] = int(g.zones.of_tile(t).ped_corner * b.district)
	return SimConst.T_CORNER


func _street(g: CityGen, b: ChunkBuild, t: Vector2i, horiz: bool) -> int:
	var m: int = (t.y if horiz else t.x) % PERIOD
	var o: Vector2 = origin(t)
	var c: Vector2 = o + Vector2(4.0, 4.0)
	var v3: int = _variant(g, t, horiz)
	if m == 1:
		b.add(ChunkBuild.L_GROUND, v3 if horiz else 3 + v3, c, 0.0)
		b.stamp(Rect2(o, Vector2(8, 8)), SimConst.C_LANE)
		b.chunk.dens_car[local_index(t)] = g.zones.of_tile(t).car_lane
		_kerb.road_decals(g, b, t, horiz)
		return SimConst.T_ROAD_H if horiz else SimConst.T_ROAD_V
	var rotd: float = (0.0 if m == 0 else 180.0) if horiz else (270.0 if m == 0 else 90.0)
	var rot: float = deg_to_rad(rotd)
	b.add(ChunkBuild.L_GROUND, CityGen.KERB_TEX[v3], c, rot)
	# rotate each cell centre back into the rot-0 frame: sidewalk where v < 3
	for yy: int in 8:
		for xx: int in 8:
			var p: Vector2 = KerbDresser.quarter_turn(Vector2(xx + 0.5 - 4.0, yy + 0.5 - 4.0), -rot)
			var code: int = SimConst.C_WALK if p.y + 4.0 < CityGen.WALK_M else SimConst.C_PARK
			b.set_cell(int(o.x) + xx, int(o.y) + yy, code)
	_kerb.dress(g, b, t, rot, horiz)
	var ped: float = g.zones.of_tile(t).ped_kerb * b.district
	b.chunk.dens_ped[local_index(t)] = int(clampf(ped, 0, 255))
	return SimConst.T_CURB


func _plaza(g: CityGen, b: ChunkBuild, t: Vector2i) -> int:
	var o: Vector2 = origin(t)
	var zone: CityZone = g.zones.of_tile(t)
	# a quarter turn per tile breaks the 8 m repeat of the paving's cracks and stains (joints stay);
	# a zone's own ground (a bond) turns only by half turns
	var turns: int = 4 if zone.plaza_ground < 0 else 2
	var turn: float = deg_to_rad(360.0 / turns * int(g.rnd(t.x, t.y, 0, 26) * turns))
	b.add(
		ChunkBuild.L_GROUND,
		zone.plaza_ground if zone.plaza_ground >= 0 else 13,
		o + Vector2(4.0, 4.0),
		turn
	)
	b.stamp(Rect2(o, Vector2(8, 8)), SimConst.C_WALK)
	b.chunk.dens_ped[local_index(t)] = int(zone.ped_plaza * b.district)
	if zone.plaza_centre >= 0 and posmod(t.x, PERIOD) == 5 and posmod(t.y, PERIOD) == 5:
		_kerb.prop(g, b, zone.plaza_centre, o + Vector2(4.0, 4.0), 0.0)  # the block's middle tile
		return SimConst.T_PLAZA
	var single: int = plaza_single(g, zone, t)
	if single >= 0:
		_kerb.prop(g, b, single, o + Vector2(4.0, 4.0), 0.0)  # front to the camera
		return SimConst.T_PLAZA
	for k: int in PLAZA_SLOTS.size():
		if g.rnd(t.x, t.y, k, 21) < zone.plaza_prop_share:
			var props: Array[int] = zone.plaza_props
			var tex: int = props[int(g.rnd(t.x, t.y, k, 22) * props.size())]
			var jitter: Vector2 = (
				Vector2(g.rnd(t.x, t.y, k, 23), g.rnd(t.x, t.y, k, 24)) - Vector2.ONE * 0.5
			)
			var p: Vector2 = o + PLAZA_SLOTS[k] + jitter * PLAZA_JITTER_M
			var rot: float = deg_to_rad(90.0 * int(g.rnd(t.x, t.y, k, 25) * 4.0))
			_kerb.prop(g, b, tex, p, rot)
	return SimConst.T_PLAZA


## Road / kerb art variant (0-2): an a-b-c cycle along the street from a random offset
## per street line, so two neighbouring tiles never share a variant (a random pick
## repeated a distinctive crack on every third pair of tiles).
static func _variant(g: CityGen, t: Vector2i, horiz: bool) -> int:
	var k: int = t.x if horiz else t.y
	var line: int = t.y if horiz else t.x
	return posmod(k + int(g.rnd(line, 1 if horiz else 0, 0, 7) * 3.0), 3)


## The zone's plaza_singles prop that stands on plaza tile t (each at most once a block, on a
## seeded interior tile off the middle), or -1.
static func plaza_single(g: CityGen, zone: CityZone, t: Vector2i) -> int:
	var bk: Vector2i = Vector2i(floori(t.x / float(PERIOD)), floori(t.y / float(PERIOD)))
	for k: int in zone.plaza_singles.size():
		var n: int = int(g.rnd(bk.x, bk.y, k, 83) * 24.0)
		n += 1 if n >= 12 else 0  # skip the middle tile (5, 5)
		if posmod(t.x, PERIOD) == 3 + n % 5 and posmod(t.y, PERIOD) == 3 + floori(n / 5.0):
			return zone.plaza_singles[k]
	return -1
