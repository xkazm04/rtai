class_name KillCellBody
extends RefCounted
## Where the drawn body of a fall-grid or death cell lies (lane kills-new, n16), render only: the
## alpha centroid of the sprite's current cell, in the sprite's local px (centred cells, flip_h
## honoured). The drawn corpses do not lie exactly along the death's fall vector (5 drawn facings
## and the camera's foreshortening), so overlays that follow a lying body (KillTorchArt's flames)
## measure it. Measured on a 1/8 copy of the cell, cached per texture and cell.

const STEP: int = 8
const ALPHA_MIN: float = 0.5

static var _cache: Dictionary[String, Vector2] = {}


## The centroid of `s`'s current cell (local px; ZERO when it cannot be read).
static func centroid(s: Sprite2D) -> Vector2:
	if s == null or s.texture == null:
		return Vector2.ZERO
	var key: String = "%d|%d|%d" % [s.texture.get_instance_id(), s.frame_coords.x, s.frame_coords.y]
	if not _cache.has(key):
		_cache[key] = _measure(s)
	var c: Vector2 = _cache[key]
	return Vector2(-c.x if s.flip_h else c.x, c.y) + s.offset


static func _measure(s: Sprite2D) -> Vector2:
	var img: Image = s.texture.get_image()
	if img == null:
		return Vector2.ZERO
	if img.is_compressed():
		@warning_ignore("return_value_discarded")
		img.decompress()
	var w: int = img.get_width() / s.hframes
	var h: int = img.get_height() / s.vframes
	var cell: Image = img.get_region(Rect2i(s.frame_coords.x * w, s.frame_coords.y * h, w, h))
	cell.resize(maxi(1, w / STEP), maxi(1, h / STEP), Image.INTERPOLATE_BILINEAR)
	var sum: Vector2 = Vector2.ZERO
	var n: int = 0
	for y: int in cell.get_height():
		for x: int in cell.get_width():
			if cell.get_pixel(x, y).a > ALPHA_MIN:
				sum += Vector2(x, y)
				n += 1
	if n == 0:
		return Vector2.ZERO
	var k: float = float(w) / float(cell.get_width())
	return (sum / float(n) + Vector2(0.5, 0.5)) * k - Vector2(w, h) * 0.5
