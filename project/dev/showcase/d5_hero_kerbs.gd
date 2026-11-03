class_name D5HeroKerbs
extends RefCounted
## d5-close hero scene (gap 4): the mock's ROUNDED kerb corners, drawn procedurally over the
## square pavement corners of the junction: an asphalt-tone fill cuts the corner to a quarter
## circle and an ink kerb line follows the arc. The world print (look_d4 + look_d5) then prints it
## like the tiles. A proposal for the city lane (tile art should own this); dev evidence only.

const RADIUS_M: float = 1.6
const LINE_M: float = 0.07
const HALF_ROAD_M: float = 4.0
const ASPHALT: Color = Color(0.345, 0.322, 0.322)
const INK: Color = Color(0.090, 0.075, 0.106)
const ARC_STEPS: int = 12
## the mock's kerb stone: a thin ink line STONE_M inside the street edge, continuous along
## the straight kerbs and round the corner (a corner-only arc floated: reverted in iteration 2)
const STONE_M: float = 0.3
const STONE_LINE_M: float = 0.04
const REACH_M: float = 20.0


## One rounded corner per junction quadrant; returns the nodes (hidden: the "d5" tier shows them).
static func corners(parent: Node, px: float) -> Array[Node2D]:
	var out: Array[Node2D] = []
	for sx: float in [-1.0, 1.0]:
		for sy: float in [-1.0, 1.0]:
			out.append_array(_corner(parent, Vector2(sx, sy), px))
	return out


static func _corner(parent: Node, s: Vector2, px: float) -> Array[Node2D]:
	var corner: Vector2 = s * HALF_ROAD_M * px
	var r: float = RADIUS_M * px
	var centre: Vector2 = corner + s * r
	var arc: PackedVector2Array = PackedVector2Array()
	for k: int in ARC_STEPS + 1:
		var t: float = float(k) / ARC_STEPS * PI * 0.5
		# from the point on the x-kerb to the point on the y-kerb, bulging toward the junction
		@warning_ignore("return_value_discarded")
		arc.append(centre - Vector2(s.x * sin(t), s.y * cos(t)) * r)
	var fill: Polygon2D = Polygon2D.new()
	var pts: PackedVector2Array = PackedVector2Array([corner])
	pts.append_array(arc)
	fill.polygon = pts
	fill.color = ASPHALT
	var line: Line2D = Line2D.new()
	line.points = arc
	line.width = LINE_M * px
	line.default_color = INK
	line.antialiased = true
	var nodes: Array[Node2D] = [fill, line, _stone(s, px)]
	for n: Node2D in nodes:
		n.visible = false
		parent.add_child(n)
	return nodes


static func _stone(s: Vector2, px: float) -> Line2D:
	var a: float = HALF_ROAD_M + STONE_M
	var c: float = HALF_ROAD_M + RADIUS_M
	var r: float = RADIUS_M - STONE_M
	var pts: PackedVector2Array = PackedVector2Array([Vector2(s.x * REACH_M, s.y * a) * px])
	for k: int in ARC_STEPS + 1:
		var t: float = float(k) / ARC_STEPS * PI * 0.5
		@warning_ignore("return_value_discarded")
		pts.append((Vector2(s.x * c, s.y * c) - Vector2(s.x * sin(t), s.y * cos(t)) * r) * px)
	@warning_ignore("return_value_discarded")
	pts.append(Vector2(s.x * a, s.y * REACH_M) * px)
	var stone: Line2D = Line2D.new()
	stone.points = pts
	stone.width = STONE_LINE_M * px
	stone.default_color = INK
	stone.antialiased = true
	return stone
