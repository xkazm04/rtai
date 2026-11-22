class_name CastPlate
extends CanvasLayer
## Assemble native viewport samples on their common foot line. Measure a shadow-free exposure
## against its own matte. Never scale, mirror or paint an actor in the contact sheet.

const PAPER: Color = Color("#d6d1c5")
const INK: Color = Color("#262732")
const MUTED: Color = Color("#555661")
const EXTENT: Vector2i = Vector2i(1920, 1080)


class Portrait:
	extends RefCounted
	var photo: Texture2D
	var offset: Vector2i
	var height: int


class Column:
	extends RefCounted
	var id: String
	var poses: Array[Portrait] = []


var _columns: Array[Column] = []
var _canvas: Node2D
var _ppm: int
var _pitch: int
var _matte: Color


func add_portrait(id: String, facing: int, photo: Image, body: Image, feet: Vector2i) -> bool:
	var bounds: Rect2i = _bounds(body)
	var visible_box: Rect2i = _bounds(photo)
	_matte = photo.get_pixel(0, 0)
	var image_rect: Rect2i = Rect2i(Vector2i.ZERO, photo.get_size())
	if bounds.size.y < 10 or not image_rect.encloses(visible_box.grow(1)):
		Log.error(
			"cast", "%s empty or clipped, body %s, with shadow %s" % [id, bounds, visible_box]
		)
		return false
	var pose: Portrait = Portrait.new()
	pose.height = bounds.size.y
	pose.photo = ImageTexture.create_from_image(photo.get_region(visible_box))
	pose.offset = visible_box.position - feet
	if facing == 0:
		var fresh: Column = Column.new()
		fresh.id = id
		_columns.append(fresh)
	var col: Column = _columns.back()
	col.poses.append(pose)
	var changed: int = _shadow_pixels(photo, body, visible_box)
	Log.info(
		"cast",
		(
			"%s facing %d body %s (px), with shadow %s, shadow pixels %d"
			% [id, facing, bounds, visible_box, changed]
		)
	)
	return true


## Any RGB channel at least 12 digital levels away from the uniformly lit paper.
func _bounds(img: Image) -> Rect2i:
	var bg: Color = img.get_pixel(0, 0)
	var lo: Vector2i = img.get_size()
	var hi: Vector2i = Vector2i(-1, -1)
	for y: int in img.get_height():
		for x: int in img.get_width():
			var c: Color = img.get_pixel(x, y)
			if maxf(absf(c.r - bg.r), maxf(absf(c.g - bg.g), absf(c.b - bg.b))) >= 12.0 / 255:
				lo = lo.min(Vector2i(x, y))
				hi = hi.max(Vector2i(x, y))
	return Rect2i(lo, hi - lo + Vector2i.ONE) if hi.y >= 0 else Rect2i()


func _shadow_pixels(photo: Image, body: Image, box: Rect2i) -> int:
	var count: int = 0
	for y: int in range(box.position.y, box.end.y):
		for x: int in range(box.position.x, box.end.x):
			var diff: Color = body.get_pixel(x, y) - photo.get_pixel(x, y)
			if maxf(diff.r, maxf(diff.g, diff.b)) >= 12.0 / 255:
				count += 1
	return count


func save_sheet(path: String, ppm: int, pitch: int) -> bool:
	for facing: int in 2:
		if _dimensions(facing).x > EXTENT.x - _columns.size():
			Log.error("cast", "row %d is too wide: %s" % [facing, _dimensions(facing)])
			return false
	_ppm = ppm
	_pitch = pitch
	return await save_canvas(path, EXTENT, _draw_sheet)


func save_canvas(path: String, size: Vector2i, paint: Callable) -> bool:
	layer = RenderLayers.canvas(&"hud") + 1
	_canvas = Node2D.new()
	add_child(_canvas)
	@warning_ignore("return_value_discarded")
	_canvas.draw.connect(paint)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var sheet: Image = get_viewport().get_texture().get_image()
	return (
		sheet.get_size() == EXTENT
		and DirAccess.make_dir_recursive_absolute(path.get_base_dir()) == OK
		and sheet.get_region(Rect2i(Vector2i.ZERO, size)).save_png(path) == OK
	)


func _dimensions(facing: int) -> Vector3i:
	var dims: Vector3i = Vector3i.ZERO
	for col: Column in _columns:
		var pose: Portrait = col.poses[facing]
		dims.x += pose.photo.get_width()
		dims.y = maxi(dims.y, -pose.offset.y)
		dims.z = maxi(dims.z, pose.offset.y + pose.photo.get_height())
	return dims


func _draw_sheet() -> void:
	_canvas.draw_rect(Rect2(Vector2.ZERO, Vector2(EXTENT)), _matte)
	_text(Vector2(24, 47), tr("RTAI / Wave cast"), 32)
	_text(
		Vector2(1380, 44), tr("%d px/m   -   %d deg pitch   -   1920 x 1080") % [_ppm, _pitch], 22
	)
	for i: int in 2:
		_draw_row(i)
	_text(
		Vector2(24, 1063),
		tr("Pixel heights include equipment. Cast shadows are measured separately."),
		16
	)


func _draw_row(facing: int) -> void:
	var dims: Vector3i = _dimensions(facing)
	var gap: float = (EXTENT.x - dims.x) / float(_columns.size() + 1)
	var caption: int = 486 if facing == 0 else 981
	var base: int = caption - dims.z - 19
	var title: String = tr("Front three-quarter") if facing == 0 else tr("Back")
	_text(Vector2(24, 90 if facing == 0 else 588), title, 20)
	var left: float = gap
	for col: Column in _columns:
		var pose: Portrait = col.poses[facing]
		_canvas.draw_texture(pose.photo, Vector2(roundf(left), base + pose.offset.y))
		_caption(col, pose, Vector2(left + pose.photo.get_width() * 0.5, caption))
		left += pose.photo.get_width() + gap


func _caption(col: Column, pose: Portrait, at: Vector2) -> void:
	var words: PackedStringArray = col.id.split("_")
	var top: String = "SWAT" if col.id == "swat" else words[0].capitalize()
	_center(at, top, 16)
	if words.size() > 1:
		_center(at + Vector2.DOWN * 19, words[1].capitalize(), 16)
	_center(at + Vector2.DOWN * 43, "%d px" % pose.height, 15)


func _text(at: Vector2, words: String, size_px: int) -> void:
	_canvas.draw_string(
		ThemeDB.fallback_font, at, words, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, INK
	)


func _center(at: Vector2, words: String, size_px: int) -> void:
	var font: Font = ThemeDB.fallback_font
	var w: float = font.get_string_size(words, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x
	_canvas.draw_string(
		font,
		(at - Vector2.RIGHT * w * 0.5).round(),
		words,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		size_px,
		MUTED
	)
