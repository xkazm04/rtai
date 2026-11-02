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
	ci.draw_colored_polygon(_diamond(at, size * 0.5 + rim * 2.0), pal.color(PAPER))
	ci.draw_colored_polygon(_diamond(at, size * 0.5 + rim), pal.color(INK))
	ci.draw_colored_polygon(_diamond(at, size * 0.5), col)


## A chevron at `at` pointing along `dir`.
static func arrow(ci: CanvasItem, at: Vector2, dir: Vector2, dims: Vector2, col: Color) -> void:
	var pal: PaletteTokens = PaletteTokens.shared()
	var size: float = dims.x
	var rim: float = dims.y
	ci.draw_colored_polygon(_chevron(at, dir, size * 0.5 + rim * 2.0), pal.color(PAPER))
	ci.draw_colored_polygon(_chevron(at, dir, size * 0.5 + rim), pal.color(INK))
	ci.draw_colored_polygon(_chevron(at, dir, size * 0.5), col)


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
