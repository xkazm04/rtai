class_name FilmCard
extends RefCounted
## n11 tools, dev only: what a drawn card measures for FilmProbe: its opaque rect in the sheet and
## the screen row of its lowest opaque pixel (the feet, whatever the card's anchor or scale).


## The cell's opaque rect; `cache` keeps one entry per texture and cell.
static func used_rect(s: Sprite2D, cache: Dictionary[String, Rect2i]) -> Rect2i:
	if s == null or s.texture == null:
		return Rect2i()
	var id: int = s.texture.get_rid().get_id()
	var key: String = "%d:%d:%d" % [id, s.frame_coords.x, s.frame_coords.y]
	if not cache.has(key):
		cache[key] = _measure(s)
	return cache[key]


static func _measure(s: Sprite2D) -> Rect2i:
	var img: Image = s.texture.get_image()
	if img == null or (img.is_compressed() and img.decompress() != OK):
		return Rect2i()
	var cw: int = img.get_width() / maxi(s.hframes, 1)
	var ch: int = img.get_height() / maxi(s.vframes, 1)
	var cell: Rect2i = Rect2i(s.frame_coords.x * cw, s.frame_coords.y * ch, cw, ch)
	return img.get_region(cell).get_used_rect()


## The screen y of the cell's lowest opaque row (a card may or may not be centred).
static func feet_y(s: Sprite2D, used: Rect2i) -> float:
	var cell: Vector2 = s.texture.get_size() / Vector2(maxi(s.hframes, 1), maxi(s.vframes, 1))
	var local: Vector2 = s.offset + Vector2(used.get_center().x, used.end.y)
	if s.centered:
		local -= cell / 2.0
	return (s.get_global_transform_with_canvas() * local).y
