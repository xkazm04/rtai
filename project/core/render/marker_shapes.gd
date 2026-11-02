class_name MarkerShapes
extends RefCounted
## The world-UI marker shapes, drawn on a CanvasItem in local units: a paper sticker rim, an ink
## outline, then the fill (the characters' cream rim, so a marker reads on charcoal and on cream).
## `dims` is (size, rim) in local units.

const PAPER: StringName = &"paper"
const INK: StringName = &"ink"


static func draw(ci: CanvasItem, shape: StringName, at: Vector2, dims: Vector2, col: Color) -> void:
	var pal: PaletteTokens = PaletteTokens.shared()
	var size: float = dims.x
	var rim: float = dims.y
	if shape == &"ring":
		var r: float = size * 0.5
		var w: float = maxf(size * 0.22, rim)
		ci.draw_arc(at, r, 0.0, TAU, 32, pal.color(PAPER), w + rim * 4.0, true)
		ci.draw_arc(at, r, 0.0, TAU, 32, pal.color(INK), w + rim * 2.0, true)
		ci.draw_arc(at, r, 0.0, TAU, 32, col, w, true)
		return
	_rimmed(ci, _diamond(at, size * 0.5), rim, col)


## The shape's bare fill (no rims) at `size`: a marker's core in a second ink.
static func fill(ci: CanvasItem, shape: StringName, at: Vector2, size: float, col: Color) -> void:
	if shape == &"ring":
		ci.draw_circle(at, size * 0.5, col, true, -1.0, true)
		return
	ci.draw_colored_polygon(_diamond(at, size * 0.5), col)


## A chevron at `at` pointing along `dir`.
static func arrow(ci: CanvasItem, at: Vector2, dir: Vector2, dims: Vector2, col: Color) -> void:
	var size: float = dims.x
	var rim: float = dims.y
	_rimmed(ci, _chevron(at, dir, size * 0.5), rim, col)


## A filled polygon with an even ink outline (rim wide) and a paper rim (rim wide) outside it.
static func _rimmed(ci: CanvasItem, poly: PackedVector2Array, rim: float, col: Color) -> void:
	var pal: PaletteTokens = PaletteTokens.shared()
	var closed: PackedVector2Array = poly.duplicate()
	@warning_ignore("return_value_discarded")
	closed.append(poly[0])
	ci.draw_polyline(closed, pal.color(PAPER), rim * 4.0, true)
	ci.draw_polyline(closed, pal.color(INK), rim * 2.0, true)
	ci.draw_colored_polygon(poly, col)


static func _diamond(c: Vector2, r: float) -> PackedVector2Array:
	return PackedVector2Array(
		[c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)]
	)


static func _chevron(c: Vector2, dir: Vector2, r: float) -> PackedVector2Array:
	var n: Vector2 = dir.orthogonal()
	return PackedVector2Array(
		[
			c + dir * r,
			c - dir * r * 0.6 + n * r * 0.8,
			c - dir * r * 0.2,
			c - dir * r * 0.6 - n * r * 0.8
		]
	)
