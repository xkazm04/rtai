class_name KerbDresser
extends RefCounted
## Street dressing for the generator: furniture on the sidewalk, parked cars on the kerb-side
## asphalt, drain grates and road decals (no lane arrows: T1 has none). Solid props stamp
## C_PROP cells.

const T_LAMP: int = 24
const T_DRAIN: int = 57
const KERB_PROPS: Array[int] = [25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 36, 37]
const NEAR_KERB: Array[int] = [34, 32, 29]
## T1's wall-side clutter (crates, dumpsters, vending, bins) flush against the building, on the
## half of the tile the kerb prop left free; neutral inks only (barrel_cluster prints vermilion).
const WALL_PROPS: Array[int] = [39, 34, 32, 26, 34, 26]
const WALL_SHARE: float = 0.75
const WALL_GAP_M: float = 0.3
## clearance (m) between a wall prop and the lamp post's arm / the kerb prop, along the tile
const CLEAR_M: float = 0.45
## the hero scene's story paint on 8% of lane tiles (art/d5/decals): STRIKE and the union fist
## stencil (the chalk robot, row 77, printed as a grey smudge at 32-48 px/m: not placed)
const LANE_PAINT: Array[int] = [75, 76]
const LANE_M: float = 2.1
const CAR_STRIP_M: float = 1.8
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
	var busy: Array[Vector2] = []  # tile-local u spans the wall prop must keep clear of
	if along % 2 == 0:
		b.add(
			ChunkBuild.L_PROP,
			T_LAMP,
			_local(c, rot, 4.0, CityGen.WALK_M - 0.6),
			rot + PI * 0.5,
			true
		)
		busy.append(Vector2(4.0 - 0.25, 4.0 + 0.25))
	if g.rnd(t.x, t.y, 0, 41) < 0.4:
		var tex: int = KERB_PROPS[int(g.rnd(t.x, t.y, 0, 42) * KERB_PROPS.size())]
		var u: float = 1.2 + 5.6 * g.rnd(t.x, t.y, 0, 43)
		var v: float = 0.9 if NEAR_KERB.has(tex) else CityGen.WALK_M - 0.7
		prop(g, b, tex, _local(c, rot, u, v), rot)
		busy.append(Vector2(u - g.sizes[tex].x * 0.5, u + g.sizes[tex].x * 0.5))
	if not _faces_plaza(g, t, horiz):
		_wall_prop(g, b, t, rot, busy)
	if g.rnd(t.x, t.y, 0, 44) < 0.4:
		var car: int = PARKED[int(g.rnd(t.x, t.y, 0, 45) * PARKED.size())]
		var p: Vector2 = _local(c, rot, 4.0 + (g.rnd(t.x, t.y, 0, 46) - 0.5), CityGen.WALK_M + 1.05)
		var r: float = rot + (PI if g.rnd(t.x, t.y, 0, 47) < 0.5 else 0.0)
		b.add(ChunkBuild.L_PROP, car, p, r, true)
		# solid for the 2 m kerb strip only (a van's 2.7 m overhangs the lane by looks, not cells)
		_block_footprint(b, p, Vector2(g.sizes[car].x * 0.9, CAR_STRIP_M), r)
	elif g.rnd(t.x, t.y, 0, 48) < 0.5:
		var p: Vector2 = _local(c, rot, 1.0 + 6.0 * g.rnd(t.x, t.y, 0, 49), CityGen.WALK_M + 0.35)
		b.add(ChunkBuild.L_DECAL, T_DRAIN, p, rot)


## One wall-side prop, flush to the building, on a free stretch of the tile (busy = taken u spans).
func _wall_prop(g: CityGen, b: ChunkBuild, t: Vector2i, rot: float, busy: Array[Vector2]) -> void:
	if g.rnd(t.x, t.y, 0, 56) >= WALL_SHARE:
		return
	var tex: int = WALL_PROPS[int(g.rnd(t.x, t.y, 0, 57) * WALL_PROPS.size())]
	var half: Vector2 = g.sizes[tex] * 0.5
	var free: Array[Vector2] = [Vector2(half.x + 0.3, 7.7 - half.x)]
	for span: Vector2 in busy:
		var cut: Vector2 = Vector2(span.x - half.x - CLEAR_M, span.y + half.x + CLEAR_M)
		var next: Array[Vector2] = []
		for f: Vector2 in free:
			if f.x < cut.x:
				next.append(Vector2(f.x, minf(f.y, cut.x)))
			if f.y > cut.y:
				next.append(Vector2(maxf(f.x, cut.y), f.y))
		free = next
	if free.is_empty():
		return
	var f: Vector2 = free[int(g.rnd(t.x, t.y, 0, 58) * free.size())]
	var u: float = lerpf(f.x, f.y, g.rnd(t.x, t.y, 0, 59))
	var c: Vector2 = TilePainter.origin(t) + Vector2(4.0, 4.0)
	prop(g, b, tex, _local(c, rot, u, half.y + WALL_GAP_M), rot)


## Whether the kerb tile's back edge faces a plaza block (open paving, no wall to lean on).
static func _faces_plaza(g: CityGen, t: Vector2i, horiz: bool) -> bool:
	var m: int = (t.y if horiz else t.x) % CityGen.PERIOD
	var out: int = -1 if m == 0 else 1
	var n: Vector2i = t + (Vector2i(0, out) if horiz else Vector2i(out, 0))
	var period: float = float(CityGen.PERIOD)
	return g.rnd(floori(n.x / period), floori(n.y / period), 0, 5) < 0.12


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
	elif r < 0.68:
		_lane_paint(g, b, t, horiz, LANE_PAINT[int((r - 0.6) / 0.08 * LANE_PAINT.size())])


## H2's road paint (STRIKE, the union fist) inside one lane, clear of the centre dashes, across
## the lane and upright for the traffic in it.
func _lane_paint(g: CityGen, b: ChunkBuild, t: Vector2i, horiz: bool, tex: int) -> void:
	var c: Vector2 = TilePainter.origin(t) + Vector2(4.0, 4.0)
	var side: float = 1.0 if g.rnd(t.x, t.y, 0, 54) < 0.5 else -1.0
	var along: float = (g.rnd(t.x, t.y, 0, 55) - 0.5) * 3.0
	var off: Vector2 = Vector2(along, LANE_M * side) if horiz else Vector2(LANE_M * side, along)
	var rot: float = PI * 0.5 if horiz else 0.0
	b.add(ChunkBuild.L_DECAL, tex, c + off, rot + (PI if side < 0.0 else 0.0))


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
