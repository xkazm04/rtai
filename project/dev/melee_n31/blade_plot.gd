class_name BladePlot
extends RefCounted
## n31 melee 01a: one weapon's polar plot. Rivet at the centre facing right (+x), PX_M px per
## metre. The hit volume (reach + body radius inside the cone) filled translucent; every drawn blade
## segment and crescent outline of the swing in cream; each ring cell's body circle: drawn-no-hit
## vermilion, hit-not-drawn ice blue, both grey, neither a dim ring. Range rings every metre.

const SIZE: int = 480
const PX_M: float = 64.0
const BG: Color = Color("15171b")
const CREAM: Color = Color("f4ecd8")
const HIT: Color = Color(0.55, 0.62, 0.7, 0.35)
const VERMILION: Color = Color("e34234")
const ICE: Color = Color("8fd3ff")
const BOTH: Color = Color(0.6, 0.6, 0.6)
const DIM: Color = Color(0.35, 0.35, 0.38)


## Writes `<base>.json` (the result) and `<base>.png` (the plot); false when the json fails.
static func write(result: Dictionary, union: Array[Dictionary], base: String) -> bool:
	var f: FileAccess = FileAccess.open(base + ".json", FileAccess.WRITE)
	if f == null:
		return false
	@warning_ignore("return_value_discarded")
	f.store_string(JSON.stringify(result, "	"))
	f.close()
	save(result, union, base + ".png")
	return true


static func save(result: Dictionary, union: Array[Dictionary], path: String) -> void:
	var im: Image = Image.create_empty(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	im.fill(BG)
	var reach: float = result["reach_m"]
	var cone: float = result["cone_dot"]
	_hit_volume(im, reach, cone, _radius(result))
	for m: int in range(1, 4):
		_ring(im, Vector2.ZERO, m, DIM, false)
	for f: Dictionary in union:
		var b: Array = f["blade"]
		if b.size() == 2:
			_line(im, _v(b[0]), _v(b[1]), CREAM)
		var c: Array = f["crescent"]
		for i: int in c.size():
			_line(im, _v(c[i]), _v(c[(i + 1) % c.size()]), CREAM)
	for cell: Dictionary in result["cells"]:
		var deg: float = cell["angle_deg"]
		var dist: float = cell["dist_m"]
		var radius: float = cell["radius_m"]
		var at: Vector2 = Vector2.from_angle(deg_to_rad(deg)) * dist
		var drawn: bool = cell["drawn"]
		var hit: bool = cell["hit"]
		var col: Color = BOTH if drawn and hit else DIM
		if drawn != hit:
			col = VERMILION if drawn else ICE
		_ring(im, at, radius, col, drawn or hit)
	if im.save_png(path) != OK:
		Log.error("blade_plot", "could not save " + path)


static func _radius(result: Dictionary) -> float:
	var cells: Array = result["cells"]
	if cells.is_empty():
		return 0.3
	var first: Dictionary = cells[0]
	var r: float = first["radius_m"]
	return r


static func _hit_volume(im: Image, reach: float, cone_dot: float, radius: float) -> void:
	for y: int in SIZE:
		for x: int in SIZE:
			var p: Vector2 = _m(Vector2(x, y))
			var dir: Vector2 = p.normalized() if p.length() > 0.001 else Vector2.RIGHT
			if p.length() <= reach + radius and dir.dot(Vector2.RIGHT) >= cone_dot:
				im.set_pixel(x, y, im.get_pixel(x, y).blend(HIT))


static func _ring(im: Image, c: Vector2, r: float, col: Color, fill: bool) -> void:
	var n: int = 48
	for i: int in n:
		var a: Vector2 = c + Vector2.from_angle(TAU * i / n) * r
		var b: Vector2 = c + Vector2.from_angle(TAU * (i + 1) / n) * r
		_line(im, a, b, col)
	if not fill:
		return
	var px: Vector2 = _p(c)
	var rp: int = int(r * PX_M)
	for y: int in range(-rp, rp + 1):
		for x: int in range(-rp, rp + 1):
			var q: Vector2i = Vector2i(px) + Vector2i(x, y)
			if x * x + y * y <= rp * rp and Rect2i(0, 0, SIZE, SIZE).has_point(q):
				im.set_pixelv(q, im.get_pixelv(q).blend(Color(col, 0.55)))


## A line between two points in metres (one pixel, plotted along its longer axis).
static func _line(im: Image, a: Vector2, b: Vector2, col: Color) -> void:
	var pa: Vector2 = _p(a)
	var pb: Vector2 = _p(b)
	var n: int = maxi(int(maxf(absf(pb.x - pa.x), absf(pb.y - pa.y))), 1)
	for s: int in n + 1:
		var q: Vector2i = Vector2i(pa.lerp(pb, float(s) / n).round())
		if Rect2i(0, 0, SIZE, SIZE).has_point(q):
			im.set_pixelv(q, col)


static func _v(xy: Variant) -> Vector2:
	var a: Array = xy
	var x: float = a[0]
	var y: float = a[1]
	return Vector2(x, y)


static func _p(m: Vector2) -> Vector2:
	return m * PX_M + Vector2(SIZE, SIZE) * 0.5


static func _m(px: Vector2) -> Vector2:
	return (px - Vector2(SIZE, SIZE) * 0.5) / PX_M
