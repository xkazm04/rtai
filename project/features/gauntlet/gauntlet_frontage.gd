class_name GauntletFrontage
extends RefCounted
## Ground and building prints in world metres. The street's colliders and route map stay in
## GauntletStreet. These held draw calls consume only template paint and the shipped city atlas.

const ASPHALT: Texture2D = preload("res://features/city/art/ground/road_box_plain.png")
const SLABS: Texture2D = preload("res://features/city/art/ground/sidewalk_tone.png")
const KERB: Texture2D = preload("res://features/city/art/ground/curb12_straight_tone.png")
const FRONTS: Dictionary[String, Texture2D] = {
	"retail": preload("res://features/city/art/view/p70/facade_shop_half.png"),
	"glass": preload("res://features/city/art/view/p70/facade_glass_storeys.png"),
	"office": preload("res://features/city/art/view/p70/facade_office_storeys.png"),
	"depot": preload("res://features/city/art/view/p70/facade_dock_b_storeys.png"),
	"masonry": preload("res://features/city/art/view/p70/facade_tall.png"),
	"arcade": preload("res://features/city/art/view/p70/facade_shop_storeys.png"),
}
const ROOFS: Dictionary[String, Texture2D] = {
	"retail": preload("res://features/city/art/d5/roofs/building_block_2x2.png"),
	"glass": preload("res://features/city/art/d5/roofs/building_block_2x2_b.png"),
	"office": preload("res://features/city/art/d5/roofs/building_block_2x2_c.png"),
	"depot": preload("res://features/city/art/d5/roofs/roof_dock_sawtooth.png"),
	"masonry": preload("res://features/city/art/d5/roofs/roof_dock_shed.png"),
	"arcade": preload("res://features/city/art/d5/roofs/roof_dock_office.png"),
}


static func draw(ci: CanvasItem, block: GauntletSegment) -> void:
	var road: Rect2 = block.road_bounds(0.0)
	var width: float = block.dressing["sidewalk_m"]
	var front: String = block.dressing["front"]
	var upper: float = road.position.y - width
	var lower: float = road.end.y + width
	ci.draw_rect(
		px(Rect2(block.start_x, upper - 32.0, block.length_m, lower - upper + 64.0)), Ink.INK
	)
	# The street continues off both sides of the camera. Narrow service gaps separate buildings.
	var lots: int = block.dressing["lots"]
	var span: float = block.length_m / lots
	for i: int in lots:
		var x: float = block.start_x + i * span
		var height: float = span * FRONTS[front].get_height() / FRONTS[front].get_width()
		_building(ci, Rect2(x, upper - height, span, height), front, lower)
	tile(ci, road, ASPHALT, 8.0)
	_pavement(ci, Rect2(block.start_x, upper, block.length_m, width), false)
	_pavement(ci, Rect2(block.start_x, road.end.y, block.length_m, width), true)


static func _building(ci: CanvasItem, face: Rect2, front: String, lower: float) -> void:
	face.position.x += 0.12
	face.size.x -= 0.24
	var roof: Texture2D = ROOFS[front]
	var depth: float = face.size.x * roof.get_height() / roof.get_width()
	var top: Rect2 = Rect2(face.position - Vector2(0.0, depth), Vector2(face.size.x, depth))
	var bottom: Rect2 = Rect2(face.position.x, lower, face.size.x, depth)
	while top.end.y > -34.0:
		ci.draw_texture_rect(roof, px(top), false, Color(0.83, 0.83, 0.83))
		top.position.y -= depth
	while bottom.position.y < 34.0:
		ci.draw_texture_rect(roof, px(bottom), false, Color(0.76, 0.76, 0.76))
		bottom.position.y += depth
	ci.draw_texture_rect(FRONTS[front], px(face), false)
	ci.draw_line(
		Ink.px(face.position), Ink.px(Vector2(face.end.x, face.position.y)), Ink.CREAM, 3.0
	)


static func _pavement(ci: CanvasItem, strip: Rect2, south: bool) -> void:
	tile(ci, strip, SLABS, 4.0)
	var y: float = strip.position.y if south else strip.end.y - 0.28
	var x: float = strip.position.x
	while x < strip.end.x:
		var width: float = minf(4.0, strip.end.x - x)
		var source: Vector2 = KERB.get_size()
		var rim: Rect2 = Rect2(0.0, 0.69 * source.y, source.x * width / 4.0, 0.09 * source.y)
		ci.draw_texture_rect_region(KERB, px(Rect2(x, y, width, 0.28)), rim)
		x += 4.0


static func px(rect: Rect2) -> Rect2:
	return Rect2(Ink.px(rect.position), Ink.px(rect.size))


static func tile(ci: CanvasItem, rect: Rect2, texture: Texture2D, size_m: float) -> void:
	var y: float = rect.position.y
	while y < rect.end.y:
		var x: float = rect.position.x
		while x < rect.end.x:
			var size: Vector2 = Vector2(minf(size_m, rect.end.x - x), minf(size_m, rect.end.y - y))
			var source: Rect2 = Rect2(Vector2.ZERO, texture.get_size() * size / size_m)
			ci.draw_texture_rect_region(texture, px(Rect2(Vector2(x, y), size)), source)
			x += size_m
		y += size_m
