class_name DockDresser
extends RefCounted
## The docks' standing dressing (n18 districts item 3, the asset lane's it471/it473 cards and plan
## twins): a prop on the quay apron's land side, and one by the coping of each basin's west quay.
## Data: the zone row's apron_props / apron_prop_share and quay_edge_prop; Dock 9's office roof.

## The open walk the apron keeps by the water, metres from the apron tile's east edge.
const OPEN_M: float = 2.5
const BOAT_GAP_M: float = 1.0
## Dock 9's block: the rule and point of places.json's dock_9 row (test_dock_office pins them
## together; a place row moves the place, never the bake).
const OFFICE_RULE: String = "dock_block_nearest"
const OFFICE_NEAR: Vector2 = Vector2(1.0, 0.5)


## One apron_props prop under apron_prop_share, front to the camera, on the apron tile's land
## (west) side; OPEN_M by the water stays an open walk.
static func apron(
	g: CityGen, b: ChunkBuild, kerb: KerbDresser, zone: CityZone, t: Vector2i
) -> void:
	if zone.apron_props.is_empty() or g.rnd(t.x, t.y, 0, 64) >= zone.apron_prop_share:
		return
	var tex: int = zone.apron_props[int(g.rnd(t.x, t.y, 0, 65) * zone.apron_props.size())]
	var half: Vector2 = g.sizes[tex] * 0.5
	var x: float = minf(0.6 + half.x, 8.0 - OPEN_M - half.x)
	var v: float = lerpf(half.y + 0.5, 7.5 - half.y, g.rnd(t.x, t.y, 0, 66))
	kerb.prop(g, b, tex, TilePainter.origin(t) + Vector2(x, v), 0.0)


## The zone's quay_edge_prop on the land strip by the coping of a straight west quay tile, on the
## basin's middle tile only (one a basin); and on basin_boat_share of the basins a basin_boat
## moored BOAT_GAP_M off the coping, in open water (it never touches a walk cell).
static func quay_edge(
	g: CityGen, b: ChunkBuild, kerb: KerbDresser, zone: CityZone, t: Vector2i
) -> void:
	if posmod(t.y, CityGen.PERIOD) != 5:
		return
	var o: Vector2 = TilePainter.origin(t)
	if zone.quay_edge_prop >= 0:
		var half: Vector2 = g.sizes[zone.quay_edge_prop] * 0.5
		var at: Vector2 = o + Vector2(DockPainter.LAND_M - 0.4 - half.x, 4.0)
		kerb.prop(g, b, zone.quay_edge_prop, at, 0.0)
	if zone.basin_boat >= 0 and g.rnd(t.x, t.y, 0, 67) < zone.basin_boat_share:
		var boat: Vector2 = g.sizes[zone.basin_boat] * 0.5
		var x: float = DockPainter.LAND_M + BOAT_GAP_M + boat.x
		b.add(ChunkBuild.L_PROP, zone.basin_boat, o + Vector2(x, 4.0), 0.0)


## The zone's office_roof on Dock 9's office tile, else the shed it was given.
static func shed_or_office(g: CityGen, zone: CityZone, t: Vector2i, shed: int) -> int:
	if zone.office_roof < 0:
		return shed
	if zone.office_tile == CityZone.UNRESOLVED:
		zone.office_tile = office_tile(g, zone)
	return zone.office_roof if t == zone.office_tile else shed


## The shed tile at the quay end of the south row of the block nearest OFFICE_NEAR (-1, -1: none).
static func office_tile(g: CityGen, zone: CityZone) -> Vector2i:
	return office_tile_on(zone, CityPlaces.nearest_block(g, OFFICE_RULE, zone.id, OFFICE_NEAR))


## The shed tile at the quay end of the block's south row (-1, -1: none); CityPlaces puts a
## `door: "office"` place's door before it.
static func office_tile_on(zone: CityZone, block: Rect2i) -> Vector2i:
	var wx: int = DockPainter.water_x(zone)
	var last_u: int = CityGen.PERIOD * zone.street_keep_x - 4
	var y: int = block.end.y - 1
	for x: int in range(block.end.x - 1, block.position.x - 1, -1):
		var u: int = posmod(x, CityGen.PERIOD * zone.street_keep_x) - 3
		var room: bool = wx < 0 or x + 1 < wx - 1
		if (wx < 0 or x < wx - 1) and (u == last_u or (u % 2 == 0 and not room)):
			return Vector2i(x, y)
	return Vector2i(-1, -1)
