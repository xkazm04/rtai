class_name ArsenalAuditFiles
extends RefCounted
## Raw on-disk PNGs keep this audit headless and independent of the import cache. A named strip
## needs equal-width cells and visible ink in the requested cells. A noflash twin needs the same
## canvas. Shoulder launchers need exhaust in each diagonal. Behind the helmet
## at least one opaque warm pixel of flare must disappear/change in the flashless pose.

var exists: Callable = FileAccess.file_exists
var _images: Dictionary[String, Image] = {}


static func cell(status: String, reason: String) -> Dictionary[String, String]:
	return {"status": status, "reason": reason}


static func result(issues: Array[String], success: String) -> Dictionary[String, String]:
	return cell("ok", success) if issues.is_empty() else cell("HOLE", "; ".join(issues))


func has(path: String) -> bool:
	return not path.is_empty() and exists.call(path) == true


func require_file(path: String, label: String, issues: Array[String]) -> void:
	if not has(path):
		issues.append("missing " + (label if path.is_empty() else path))


func references(value: Variant, issues: Array[String]) -> void:
	if value is Dictionary:
		var object: Dictionary = value
		for item: Variant in object.values():
			references(item, issues)
	elif value is Array:
		var items: Array = value
		for item: Variant in items:
			references(item, issues)
	elif value is String and str(value).begins_with("res://"):
		require_file(str(value), "", issues)


func strip(path: String, count: int, indexes: Array, issues: Array[String]) -> Image:
	if not _images.has(path):
		_images[path] = _png(path)
	var img: Image = _images[path]
	if img == null or img.is_empty() or img.get_width() % count != 0:
		issues.append("missing or invalid " + path.get_file())
		return null
	@warning_ignore("integer_division")
	var w: int = img.get_width() / count
	for i: int in indexes:
		if img.get_region(Rect2i(i * w, 0, w, img.get_height())).get_used_rect().has_area():
			continue
		issues.append("%s cell %d is blank" % [path.get_file(), i])
	return img


func _png(path: String) -> Image:
	if not has(path):
		return null
	var img: Image = Image.new()
	return img if img.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) == OK else null


func check_strip(path: String, count: int, indexes: Array, issues: Array[String]) -> void:
	@warning_ignore("return_value_discarded")
	strip(path, count, indexes, issues)


func fire(base: String, pitch: String, id: String, stream: bool) -> Dictionary:
	var issues: Array[String] = []
	var eq: Image = strip(base + ".png", RivetFrames.EQ_CELLS, [5, 6], issues)
	var count: int = RivetStrips.DIAG_CELLS
	var diagonal: Image = strip(base + RivetStrips.DIAG, count, range(count), issues)
	var key: String = pitch + "/" + id
	if stream:
		var angles: PackedFloat32Array = RivetStrips.FLAME_DEG.get(key, [])
		if angles.size() != RivetStrips.DIAG_CELL.size() or not RivetStrips.DIAG_FOOT_PX.has(pitch):
			issues.append("missing flame angles or foot pad")
		return result(issues, "side/camera, stream diagonals and flame placement")
	var deg: PackedFloat32Array = RivetGunDiag.DEG.get(key, [])
	var xs: PackedFloat32Array = RivetGunDiag.HELMET_X.get(key, [])
	if deg.size() != count:
		issues.append("incomplete DEG")
	if xs.size() != count:
		issues.append("incomplete HELMET_X")
	if not RivetGunDiag.FOOT_PX.has(key):
		issues.append("missing FOOT_PX")
	@warning_ignore("return_value_discarded")
	_twin(base, eq, RivetFrames.EQ_CELLS, [5, 6], issues)
	var twin: Image = _twin(base + "_diag", diagonal, count, range(count), issues)
	if id in ["mini_nuke", "rocket_launcher"] and xs.size() == count and diagonal and twin:
		for i: int in count:
			if not _exhaust(diagonal, twin, i, xs[i]):
				issues.append("diagonal %d lacks rear exhaust" % i)
	return result(issues, "side/camera, four seated diagonals and matching noflash strips")


func _twin(base: String, lit: Image, count: int, indexes: Array, issues: Array[String]) -> Image:
	var twin: Image = strip(base + RivetNoFlash.SUFFIX, count, indexes, issues)
	if twin != null and lit != null and twin.get_size() != lit.get_size():
		issues.append(base.get_file() + " noflash canvas differs")
		return null
	return twin


func _exhaust(lit: Image, dark: Image, i: int, helmet_x: float) -> bool:
	@warning_ignore("integer_division")
	var w: int = lit.get_width() / RivetStrips.DIAG_CELLS
	var origin: int = i * w
	var left: int = origin if i < 2 else origin + ceili(helmet_x)
	var right: int = origin + floori(helmet_x) if i < 2 else origin + w
	for x: int in range(maxi(origin, left), mini(origin + w, right)):
		for y: int in lit.get_height():
			var c: Color = lit.get_pixel(x, y)
			if c.a < 0.5 or c.r < 0.8 or c.g < 0.35 or c.r - c.b < 0.27:
				continue
			var d: Color = dark.get_pixel(x, y)
			if maxf(absf(c.a - d.a), maxf(absf(c.r - d.r), absf(c.g - d.g))) > 0.12:
				return true
	return false
