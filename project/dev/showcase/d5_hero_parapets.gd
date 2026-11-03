class_name D5HeroParapets
extends RefCounted
## d5-close hero scene (gap 5): the mock's RAISED roof read. d4h2_mock.jpg draws every roof as a
## slab: cream lip, then a near-solid ink band along the roof's down-right edges (the wall foot /
## eave shadow core), then the lighter hatched cast shadow. Drawn procedurally per roof; the world
## print (look_d4 + look_d5) inks it like the tiles. Proposal for the city lane; dev evidence only
## ("d5" tier). An inner parapet shadow on the roof (h62) was dropped: invisible over the roof
## art's own border hatch, +0.5 pp ink at 32 px/m.

## the ink core outside the down-right edges (m)
const CORE_M: float = 0.22
const INK: Color = Color(0.090, 0.075, 0.106)


## One parapet set per roof centre (metres); returns the nodes (hidden: the "d5" tier shows them).
## The ink core only runs along down-right edges that face open ground: an alley to a neighbour
## roof (gap < 1 m) stays as drawn, or the block would print as a black grid.
static func place(parent: Node, px: float, centres: Array[Vector2], roof_m: float) -> Array[Node2D]:
	var out: Array[Node2D] = []
	var h: float = roof_m * 0.5
	for c: Vector2 in centres:
		for d: Vector2 in [Vector2(1, 0), Vector2(0, 1)]:
			if not _has_roof(centres, c + d * roof_m, 1.0):
				out.append(_core(c, d, h, px))
	for n: Node2D in out:
		n.visible = false
		parent.add_child(n)
	return out


static func _has_roof(centres: Array[Vector2], at: Vector2, tol: float) -> bool:
	for c: Vector2 in centres:
		if c.distance_to(at) < tol:
			return true
	return false


## The ink strip outside the roof's east (d = +x) or south (d = +y) edge, through the corner.
static func _core(c: Vector2, d: Vector2, h: float, px: float) -> Polygon2D:
	var t: Vector2 = Vector2(d.y, d.x)  # along the edge
	var a: Vector2 = c + d * h - t * h
	var b: Vector2 = c + d * (h + CORE_M) + t * (h + CORE_M)
	var lo: Vector2 = a.min(b) * px
	var hi: Vector2 = a.max(b) * px
	var poly: Polygon2D = Polygon2D.new()
	poly.polygon = PackedVector2Array([lo, Vector2(hi.x, lo.y), hi, Vector2(lo.x, hi.y)])
	poly.color = INK
	return poly
