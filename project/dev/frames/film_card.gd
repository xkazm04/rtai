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


static func rig(game: ArenaGame, f: Fighter) -> CutRig:
	return null if game.cast == null else game.cast.rigs.rig_for(f.id)


## The card drawing `f` now: the lying sprite kept for the dead, else the upright head card.
static func drawn(game: ArenaGame, f: Fighter) -> Sprite2D:
	var r: CutRig = rig(game, f)
	if r != null and r.head_card != null:
		var lying: Sprite2D = r.head_card.get_node_or_null(StreetDeadPlan.NODE) as Sprite2D
		if lying != null:
			return lying
		if r.head_card.visible:
			return r.head_card
	return _kept(game, f.id)


## The lying sprite StreetDeadRest kept once the corpse's rig is back in the pool (its last part).
static func _kept(game: ArenaGame, id: int) -> Sprite2D:
	if game.cast == null or not game.cast.rigs.rest._kept.has(id):
		return null
	var parts: Array = game.cast.rigs.rest._kept[id]
	var last: Variant = parts.back() if not parts.is_empty() else null
	return last if last is Sprite2D else null
