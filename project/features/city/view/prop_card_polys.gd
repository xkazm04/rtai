class_name PropCardPolys
extends RefCounted
## A PropCards card's opaque outline(s) on screen (night n8, view's it13 REQUEST to city):
## PropOcclusion cuts a hidden body's ink by the card's real silhouette instead of its rect (the
## crate stack's pyramid inked a black kite beside the top crate). The strip cell's alpha traced
## once per (strip, facing) in the cell's unit space, then mapped into the card's screen rect,
## mirrored with the facing. Render only.

## The alpha a pixel needs to count as the card.
const ALPHA: float = 0.5
## The trace's simplification (cell px).
const EPSILON: float = 2.0

## "<strip instance id>:<cell>" -> Array[PackedVector2Array] in the cell's unit square.
static var _unit_cache: Dictionary[String, Array] = {}


## The outline(s) of `cards`' prop `name` facing the way PropCards.draw_on turns it for ground rect
## `r`, mapped into screen rect `rect` (PropCards.stand_rect); empty with no card or no rect.
static func of(cards: PropCards, name: String, r: Rect2, rect: Rect2) -> Array[PackedVector2Array]:
	var out: Array[PackedVector2Array] = []
	var t: int = -1 if cards == null else cards._names.find(name)
	if t < 0 or not cards.has(t) or not rect.has_area():
		return out
	var f: Vector2i = cards.facing(t, 0.0 if r.size.x >= r.size.y else PI * 0.5)
	return outlines(cards._strip[t], f, rect)


## The screen rect PropCards.draw_on's card for `cards`' prop `name` on ground rect `r` covers: the
## cell's full height over the footprint's south edge, as wide as r's long side; empty with no card.
static func rect(cards: PropCards, name: String, r: Rect2) -> Rect2:
	var t: int = -1 if cards == null else cards._names.find(name)
	if t < 0 or not cards.has(t):
		return Rect2()
	var strip: Texture2D = cards._strip[t]
	var w: float = maxf(r.size.x, r.size.y)
	var aspect: float = strip.get_height() * float(PropCards.FACINGS) / strip.get_width()
	var h: float = w * aspect / ViewMode.shared().ground_k()
	return Rect2(r.get_center().x - w * 0.5, r.end.y - h, w, h)


## Cell `f.x` of `strip` (PropCards.FACINGS cells) traced and mapped into `rect`, mirrored when
## f.y == 1 (the winding kept by reversing the points).
static func outlines(strip: Texture2D, f: Vector2i, rect: Rect2) -> Array[PackedVector2Array]:
	var out: Array[PackedVector2Array] = []
	for unit: PackedVector2Array in _unit(strip, f.x):
		var pts: PackedVector2Array = PackedVector2Array()
		for p: Vector2 in unit:
			var u: float = 1.0 - p.x if f.y == 1 else p.x
			@warning_ignore("return_value_discarded")
			pts.append(rect.position + Vector2(u * rect.size.x, p.y * rect.size.y))
		if f.y == 1:
			pts.reverse()
		out.append(pts)
	return out


static func _unit(strip: Texture2D, idx: int) -> Array:
	var key: String = "%d:%d" % [strip.get_instance_id(), idx]
	if _unit_cache.has(key):
		return _unit_cache[key]
	var got: Array[PackedVector2Array] = []
	var img: Image = strip.get_image()
	if img != null and not img.is_empty():
		if img.is_compressed():
			@warning_ignore("return_value_discarded")
			img.decompress()
		var cw: int = floori(img.get_width() / float(PropCards.FACINGS))
		var cell: Image = img.get_region(Rect2i(cw * idx, 0, cw, img.get_height()))
		var bits: BitMap = BitMap.new()
		bits.create_from_image_alpha(cell, ALPHA)
		var size: Vector2 = Vector2(cell.get_size())
		var area: Rect2i = Rect2i(Vector2i.ZERO, cell.get_size())
		for poly: PackedVector2Array in bits.opaque_to_polygons(area, EPSILON):
			var pts: PackedVector2Array = PackedVector2Array()
			for p: Vector2 in poly:
				@warning_ignore("return_value_discarded")
				pts.append(p / size)
			if pts.size() >= 3:
				got.append(pts)
	_unit_cache[key] = got
	return got
