class_name DockPainter
extends RefCounted
## The docks zone's own block layout (n18 districts item 2; CityZone.street_keep_x 2 and
## water_tiles): every other north-south street line is dropped, so two blocks and the street
## between them make one 13-tile long block (u 0-12 across, v 0-4 down) of 16.4 m warehouse
## roofs in rows, one container-yard row per block (or a whole yard block under the zone's
## plaza_share), a shed at the long block's east end; along the city's east edge a quay apron
## and water_tiles of water. Today's art recombined until the asset lane's docks set lands
## (JOURNAL REQUEST assets 1-5); the water draws the zone's water_ground, checkered, turned.

const PERIOD: int = CityGen.PERIOD
const T_PAVING: int = 13
const T_BOLLARD: int = 37
const SHED_U: int = 12
const BOLLARD_V_M: Array[float] = [1.5, 4.0, 6.5]
## The quay set (asset lane it469/it470): the straight is drawn land north (5 m of apron to its
## coping), the inner corner land north and west; a turn carries them to the tile's land sides.
const LAND_M: float = 5.0
## Two container rows a yard tile, long axis east-west: their 85 % footprints (cells 1-6 x 0-2
## and 1-6 x 4-6) leave cell rows 3 and 7 and columns 0 and 7 walkable: one walk network.
const YARD_SLOTS: Array[Vector2] = [Vector2(4.0, 1.5), Vector2(4.0, 5.5)]
const EDGE_N: int = 1
const EDGE_S: int = 2
const EDGE_W: int = 4
const QUAY_CASES: Dictionary = {
	EDGE_N: [0, 0],
	EDGE_S: [0, 180],
	EDGE_W: [0, 270],
	EDGE_N | EDGE_W: [1, 0],
	EDGE_S | EDGE_W: [1, 270],
}


## Whether the street line through tile t is dropped in its zone (a long block runs over it).
static func dropped(zone: CityZone, t: Vector2i) -> bool:
	if zone.street_keep_x <= 1 or posmod(t.x, PERIOD) > 2:
		return false
	return posmod(floori(float(t.x) / PERIOD), zone.street_keep_x) != 0


## The first water column of the city (the quay apron is the column before it), or -1.
static func water_x(zone: CityZone) -> int:
	if zone.water_tiles <= 0:
		return -1
	return SimConst.CITY_CHUNKS * SimConst.CHUNK_TILES - zone.water_tiles


## Whether a docks block tile is container yard: a whole yard block, or the block's yard row.
static func is_yard(g: CityGen, zone: CityZone, t: Vector2i) -> bool:
	var mb: Vector2i = _long_block(zone, t)
	if g.rnd(mb.x, mb.y, 0, 5) < zone.plaza_share:
		return true
	return posmod(t.y, PERIOD) - 3 == int(g.rnd(mb.x, mb.y, 0, 71) * 5.0)


## A warehouse-row tile of a long block: roof ground, a long roof from every even u, a shed at u 12.
func block(g: CityGen, b: ChunkBuild, zone: CityZone, t: Vector2i) -> int:
	var u: int = _u(zone, t)
	var v: int = posmod(t.y, PERIOD) - 3
	var o: Vector2 = TilePainter.origin(t)
	var c: Vector2 = o + Vector2(4.0, 4.0)
	var last_u: int = PERIOD * zone.street_keep_x - 4
	var edge: float = _edge(u, v, last_u)
	b.add(ChunkBuild.L_GROUND, 11 if edge >= 0.0 else 12, c, deg_to_rad(maxf(edge, 0.0)))
	b.stamp(Rect2(o, Vector2(8, 8)), SimConst.C_BUILD)
	var wx: int = water_x(zone)
	var room: bool = wx < 0 or t.x + 1 < wx - 1  # a long roof never crosses onto the quay
	if u == last_u or (u % 2 == 0 and not room):
		var tex: int = _shed(g, zone, t)
		var lettered: bool = BlockPainter.LETTERED.has(tex)
		var rot: float = 0.0 if lettered else deg_to_rad(90.0 * int(g.rnd(t.x, t.y, 0, 34) * 4.0))
		b.add(ChunkBuild.L_ROOF, tex, c, rot, true)
	elif u % 2 == 0:
		var longs: Array[int] = zone.long_roofs
		var tex: int = longs[int(g.rnd(t.x, t.y, 0, 33) * longs.size())]
		var upright: bool = (
			BlockPainter.LETTERED.has(tex)
			or tex == BlockPainter.T_LONG_T1
			or zone.upright_roofs.has(tex)
		)
		var turn: bool = not upright and g.rnd(t.x, t.y, 0, 34) < 0.5
		b.add(ChunkBuild.L_ROOF, tex, Vector2(c.x + 4.0, c.y), PI if turn else 0.0, true)
	return SimConst.T_BLOCK


## The quay apron (paving, a bollard line at the water's edge) or a water tile.
func quay(g: CityGen, b: ChunkBuild, kerb: KerbDresser, t: Vector2i, apron: bool) -> int:
	var o: Vector2 = TilePainter.origin(t)
	var zone: CityZone = g.zones.of_tile(t)
	if not apron:
		return _water(g, b, kerb, zone, t)
	var turn: float = deg_to_rad(90.0 * int(g.rnd(t.x, t.y, 0, 26) * 4.0))
	var ground: int = zone.apron_ground if zone.apron_ground >= 0 else T_PAVING
	b.add(ChunkBuild.L_GROUND, ground, o + Vector2(4.0, 4.0), turn)
	b.stamp(Rect2(o, Vector2(8, 8)), SimConst.C_WALK)
	if zone.quay_ground.size() < 2:  # no coping art: the bollard line marks the edge
		for vm: float in BOLLARD_V_M:
			kerb.prop(g, b, T_BOLLARD, o + Vector2(7.4, vm), 0.0)
	DockDresser.apron(g, b, kerb, zone, t)
	b.chunk.dens_ped[TilePainter.local_index(t)] = int(zone.ped_plaza * 0.25 * b.district)
	return SimConst.T_PLAZA


## A container-yard tile: paving (the zone's yard_ground, unturned), then a stack in each
## YARD_SLOTS row under yard_prop_share (a 0 / 180 turn; the broadside faces the camera).
func yard(g: CityGen, b: ChunkBuild, kerb: KerbDresser, zone: CityZone, t: Vector2i) -> int:
	var o: Vector2 = TilePainter.origin(t)
	var turn: float = deg_to_rad(90.0 * int(g.rnd(t.x, t.y, 0, 26) * 4.0))
	if zone.yard_ground >= 0:  # painted bays line up with YARD_SLOTS: never turned
		b.add(ChunkBuild.L_GROUND, zone.yard_ground, o + Vector2(4.0, 4.0), 0.0)
	else:
		b.add(ChunkBuild.L_GROUND, T_PAVING, o + Vector2(4.0, 4.0), turn)
	b.stamp(Rect2(o, Vector2(8, 8)), SimConst.C_WALK)
	b.chunk.dens_ped[TilePainter.local_index(t)] = int(zone.ped_plaza * b.district)
	for k: int in YARD_SLOTS.size():
		if g.rnd(t.x, t.y, k, 61) < zone.yard_prop_share:
			var stacks: Array[int] = zone.yard_props
			var tex: int = stacks[int(g.rnd(t.x, t.y, k, 62) * stacks.size())]
			kerb.prop(g, b, tex, o + YARD_SLOTS[k], PI * int(g.rnd(t.x, t.y, k, 63) * 2.0))
	return SimConst.T_PLAZA


## The quay edge's autotile case of a water tile: [land sides (bits EDGE_N/S/W), the art index
## into quay_ground (0 straight, 1 inner corner, -1 open water), its turn in degrees]. The basin
## between two piers is closed west by the apron, north and south by the pier streets.
static func quay_case(zone: CityZone, t: Vector2i) -> Array[int]:
	var my: int = posmod(t.y, PERIOD)
	var sides: int = 0
	if t.x == water_x(zone):
		sides |= EDGE_W
	if my == 3:
		sides |= EDGE_N
	elif my == PERIOD - 1:
		sides |= EDGE_S
	var case: Array = QUAY_CASES.get(sides, [-1, 0])
	var art: int = case[0]
	var turn: int = case[1]
	return [sides, art, turn]


## A water tile: open water, or a quay edge (coping + LAND_M of apron on its land sides, walkable).
func _water(g: CityGen, b: ChunkBuild, kerb: KerbDresser, zone: CityZone, t: Vector2i) -> int:
	var o: Vector2 = TilePainter.origin(t)
	b.stamp(Rect2(o, Vector2(8, 8)), SimConst.C_BUILD)
	var case: Array[int] = quay_case(zone, t)
	if case[1] < 0 or zone.quay_ground.size() < 2:
		var water: Array[int] = zone.water_ground
		var turn_w: float = PI * int(g.rnd(t.x, t.y, 0, 27) * 2.0)  # 0 / 180: ripples keep one heading
		var tex: int = water[posmod(t.x + t.y, water.size())]
		b.add(ChunkBuild.L_GROUND, tex, o + Vector2(4.0, 4.0), turn_w)
		return SimConst.T_BLOCK
	b.add(
		ChunkBuild.L_GROUND, zone.quay_ground[case[1]], o + Vector2(4.0, 4.0), deg_to_rad(case[2])
	)
	var land: float = LAND_M
	if case[0] & EDGE_N:
		b.stamp(Rect2(o, Vector2(8, land)), SimConst.C_WALK)
	if case[0] & EDGE_S:
		b.stamp(Rect2(o + Vector2(0, 8 - land), Vector2(8, land)), SimConst.C_WALK)
	if case[0] & EDGE_W:
		b.stamp(Rect2(o, Vector2(land, 8)), SimConst.C_WALK)
	if case[0] == EDGE_W:
		DockDresser.quay_edge(g, b, kerb, zone, t)
	b.chunk.dens_ped[TilePainter.local_index(t)] = int(zone.ped_plaza * 0.1 * b.district)
	return SimConst.T_PLAZA


static func _shed(g: CityGen, zone: CityZone, t: Vector2i) -> int:
	var r: float = g.rnd(t.x, t.y, 0, 33)
	if r < zone.landmark_share:
		return zone.landmark_roofs[int(r / zone.landmark_share * zone.landmark_roofs.size())]
	var generic: Array[int] = zone.generic_roofs
	return generic[mini(int(r * generic.size()), generic.size() - 1)]


static func _u(zone: CityZone, t: Vector2i) -> int:
	return posmod(t.x, PERIOD * zone.street_keep_x) - 3


static func _long_block(zone: CityZone, t: Vector2i) -> Vector2i:
	var w: int = PERIOD * zone.street_keep_x
	return Vector2i(floori(float(t.x) / w), floori(float(t.y) / PERIOD))


static func _edge(u: int, v: int, last_u: int) -> float:
	if v == 0:
		return 0.0
	if v == 4:
		return 180.0
	if u == 0:
		return 270.0
	return 90.0 if u == last_u else -1.0
