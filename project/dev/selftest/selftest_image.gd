class_name SelftestImage
extends RefCounted
## Sanity checks on a captured frame: the expected size, not blank, and enough distinct colours
## on a sampling grid that it is a drawn city and not a clear colour or a single placeholder.

const GRID: int = 48
const MIN_DISTINCT: int = 24
const QUANT: float = 32.0


static func check(img: Image, want: Vector2) -> Dictionary:
	var size_ok: bool = img != null and Vector2(img.get_width(), img.get_height()) == want
	if img == null or img.is_empty():
		return {"ok": false, "why": "empty image"}
	var seen: Dictionary[int, bool] = {}
	var lum: float = 0.0
	for gy: int in GRID:
		for gx: int in GRID:
			var c: Color = img.get_pixel(
				floori((gx + 0.5) * img.get_width() / GRID),
				floori((gy + 0.5) * img.get_height() / GRID)
			)
			lum += c.get_luminance()
			seen[_bucket(c)] = true
	var distinct: int = seen.size()
	return {
		"ok": size_ok and distinct >= MIN_DISTINCT,
		"width": img.get_width(),
		"height": img.get_height(),
		"distinct_colours": distinct,
		"mean_luminance": lum / (GRID * GRID),
		"why": "" if size_ok and distinct >= MIN_DISTINCT else "size or colour variety off",
	}


static func _bucket(c: Color) -> int:
	return int(c.r * QUANT) * 1024 + int(c.g * QUANT) * 32 + int(c.b * QUANT)
