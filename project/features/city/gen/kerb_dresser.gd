class_name KerbDresser
extends RefCounted
## Street dressing for the generator: furniture on the sidewalk, parked cars on the kerb-side
## asphalt, drain grates, road decals and lane arrows. Solid props stamp C_PROP cells.

const T_LAMP: int = 24
const T_DRAIN: int = 57
const T_ARROW: int = 61
const KERB_PROPS: Array[int] = [25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 36, 37]
const NEAR_KERB: Array[int] = [34, 32, 29]
const PARKED: Array[int] = [44, 45, 46, 47, 48, 49, 44, 45, 46, 50, 52, 53]


## A prop (with its shadow); a solid one blocks its footprint (85% of the art, rotated).
func prop(g: CityGen, b: ChunkBuild, tex: int, p: Vector2, rot: float) -> void:
	b.add(ChunkBuild.L_PROP, tex, p, rot, true)
	if not g.solid[tex]:
		return
	_block_footprint(b, p, g.sizes[tex] * 0.85, rot)


func dress(g: CityGen, b: ChunkBuild, t: Vector2i, rot: float, horiz: bool) -> void:
	var along: int = t.x if horiz else t.y
	var c: Vector2 = TilePainter.origin(t) + Vector2(4.0, 4.0)
	if along % 2 == 0:
		b.add(ChunkBuild.L_PROP, T_LAMP, _local(c, rot, 4.0, 2.4), rot + PI * 0.5, true)
	if g.rnd(t.x, t.y, 0, 41) < 0.4:
		var tex: int = KERB_PROPS[int(g.rnd(t.x, t.y, 0, 42) * KERB_PROPS.size())]
		var u: float = 1.2 + 5.6 * g.rnd(t.x, t.y, 0, 43)
		var v: float = 0.9 if NEAR_KERB.has(tex) else 2.3
		prop(g, b, tex, _local(c, rot, u, v), rot)
	if g.rnd(t.x, t.y, 0, 44) < 0.4:
		var car: int = PARKED[int(g.rnd(t.x, t.y, 0, 45) * PARKED.size())]
		var p: Vector2 = _local(c, rot, 4.0 + (g.rnd(t.x, t.y, 0, 46) - 0.5), 4.45)
		var r: float = rot + (PI if g.rnd(t.x, t.y, 0, 47) < 0.5 else 0.0)
		b.add(ChunkBuild.L_PROP, car, p, r, true)
		_block_footprint(b, p, g.sizes[car] * 0.9, r)
	elif g.rnd(t.x, t.y, 0, 48) < 0.5:
		var p: Vector2 = _local(c, rot, 1.0 + 6.0 * g.rnd(t.x, t.y, 0, 49), 3.35)
		b.add(ChunkBuild.L_DECAL, T_DRAIN, p, rot)


func road_decals(g: CityGen, b: ChunkBuild, t: Vector2i, horiz: bool) -> void:
	var c: Vector2 = TilePainter.origin(t) + Vector2(4.0, 4.0)
	var r: float = g.rnd(t.x, t.y, 0, 51)
	var rot: float = 0.0 if horiz else PI * 0.5
	var jx: float = g.rnd(t.x, t.y, 0, 52) - 0.5
	var jy: float = g.rnd(t.x, t.y, 0, 53) - 0.5
	if r < 0.25:
		b.add(ChunkBuild.L_DECAL, 54, c + Vector2(jx * 4.0, jy * 4.0), rot)
	elif r < 0.4:
		b.add(ChunkBuild.L_DECAL, 55, c + Vector2(jx * 4.0, jy * 2.0), 0.0)
	elif r < 0.55:
		b.add(ChunkBuild.L_DECAL, 56 if r < 0.5 else 59, c + Vector2(jx * 5.0, jy * 4.0), rot)
	elif r < 0.6:
		b.add(ChunkBuild.L_DECAL, 62, Vector2(c.x, c.y + jy * 3.0), rot)
	# lane arrows on the approach to each junction (right-hand traffic)
	var m: int = (t.x if horiz else t.y) % CityGen.PERIOD
	if m == 7:
		var off: Vector2 = Vector2(0.0, 2.0) if horiz else Vector2(-2.0, 0.0)
		b.add(ChunkBuild.L_DECAL, T_ARROW, c + off, rot)
	elif m == 3:
		var off: Vector2 = Vector2(0.0, -2.0) if horiz else Vector2(2.0, 0.0)
		b.add(ChunkBuild.L_DECAL, T_ARROW, c + off, rot + PI)


## The tile-local point (u, v) in metres of a kerb tile rotated by rot, in world metres.
static func _local(c: Vector2, rot: float, u: float, v: float) -> Vector2:
	return c + quarter_turn(Vector2(u - 4.0, v - 4.0), rot)


## Rotates by a multiple of 90 degrees exactly (no sin/cos: libm results differ between
## platforms in the last bit, and the golden hash list must hold on every CI runner).
static func quarter_turn(p: Vector2, rot: float) -> Vector2:
	var k: int = posmod(roundi(rot / (PI * 0.5)), 4)
	match k:
		1:
			return Vector2(-p.y, p.x)
		2:
			return Vector2(-p.x, -p.y)
		3:
			return Vector2(p.y, -p.x)
	return p


static func _block_footprint(b: ChunkBuild, p: Vector2, size: Vector2, rot: float) -> void:
	var sz: Vector2 = size
	if posmod(roundi(rot / (PI * 0.5)), 2) == 1:
		sz = Vector2(sz.y, sz.x)
	b.stamp(Rect2(p - sz * 0.5, sz), SimConst.C_PROP)
