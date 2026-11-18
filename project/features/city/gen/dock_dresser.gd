class_name DockDresser
extends RefCounted
## The docks' standing dressing (n18 districts item 3, the asset lane's it471/it473 cards and plan
## twins): a prop on the quay apron's land side, and one by the coping of each basin's west quay.
## Data: the zone row's apron_props / apron_prop_share and quay_edge_prop.

## The open walk the apron keeps by the water, metres from the apron tile's east edge.
const OPEN_M: float = 2.5


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
## basin's middle tile only (one a basin).
static func quay_edge(
	g: CityGen, b: ChunkBuild, kerb: KerbDresser, zone: CityZone, t: Vector2i
) -> void:
	if zone.quay_edge_prop < 0 or posmod(t.y, CityGen.PERIOD) != 5:
		return
	var half: Vector2 = g.sizes[zone.quay_edge_prop] * 0.5
	var o: Vector2 = TilePainter.origin(t)
	kerb.prop(g, b, zone.quay_edge_prop, o + Vector2(DockPainter.LAND_M - 0.4 - half.x, 4.0), 0.0)
