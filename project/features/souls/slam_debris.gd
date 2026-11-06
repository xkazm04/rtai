class_name SlamDebris
extends RefCounted
## n7-melee: the Tonnage press slam's debris (the audit: the landing had a shake and a stop but no
## debris; at 32 px/m with the camera moving it did not read as a hit). Drawn by HaulerMarks under
## every caller (the arena, the city block, quest 1's CastView): on the landing frame a cream flash
## edged in ink round the press head; paper chips edged in ink (ink alone vanished on the asphalt)
## thrown out in low arcs (a shadow under each, spinning, landing and lying until they fade);
## paper-dust puffs rolling out. A world impact prints
## in ink and paper. Data: ghost_attacks.json tonnage slam_debris (chips, 0 = none), slam_debris_s,
## slam_flash_s; --feel=off = none. Seeded from the stomp tick: no RNG stream, view only.

const INK: Color = Color(0.09, 0.08, 0.07)
const CREAM: Color = Color(0.98, 0.94, 0.82)
const PUFFS: int = 7
const LIE_S: float = 1.2

static var _loaded: bool = false
static var _chips: int = 0
static var _span_s: float = 0.0
static var _flash_s: float = 0.0


static func draw(ci: CanvasItem, c: Vector2, age: float, ppm: float, seed: int) -> void:
	_load()
	if _chips <= 0:
		return
	if age < _flash_s:
		var k: float = age / _flash_s
		ci.draw_circle(c, 2.2 * ppm * (1.0 - 0.3 * k), Color(INK, 0.9 * (1.0 - k)))
		ci.draw_circle(c, 2.0 * ppm * (1.0 - 0.3 * k), Color(CREAM, 1.0 - k))
	if age < _span_s:
		_puffs(ci, c, age / _span_s, ppm, seed)
	if age < _span_s + LIE_S:
		for i: int in _chips:
			_chip(ci, c, age, ppm, _hash(seed, i))


## One chip: out along its angle, decelerating, lifted in an arc (screen up), shadow on the road.
static func _chip(ci: CanvasItem, c: Vector2, age: float, ppm: float, h: int) -> void:
	var a: float = TAU * float(h % 1000) / 1000.0
	var reach_m: float = 1.6 + 2.6 * float((h >> 10) % 100) / 100.0
	var size_m: float = 0.16 + 0.16 * float((h >> 17) % 100) / 100.0
	var t: float = clampf(age / _span_s, 0.0, 1.0)
	var fade: float = 1.0 - clampf((age - _span_s) / LIE_S, 0.0, 1.0)
	var ground: Vector2 = c + Vector2.from_angle(a) * reach_m * ppm * (1.0 - pow(1.0 - t, 2.0))
	var lift: float = 0.7 * ppm * 4.0 * t * (1.0 - t) * (reach_m / 4.2)
	ci.draw_circle(ground, size_m * 0.5 * ppm, Color(INK, 0.3 * fade))
	var spin: float = a + t * (6.0 + float(h % 7))
	var at: Vector2 = ground - Vector2(0.0, lift)
	chip(ci, at, size_m * ppm, spin, fade, 2.0)


## One paper chip of side `s` px at canvas `at`, turned `spin`, drawn in local space under a draw
## transform: in the city block (~16000 px from the origin at 32 px/m) a few-px quad given in
## absolute canvas coordinates fails Godot's float32 triangulation and the chip drops out.
static func chip(ci: CanvasItem, at: Vector2, s: float, spin: float, fade: float, w: float) -> void:
	ci.draw_set_transform(at, spin)
	var pts: PackedVector2Array = chip_points(s)
	ci.draw_colored_polygon(pts, Color(CREAM, fade))
	@warning_ignore("return_value_discarded")
	pts.append(pts[0])
	ci.draw_polyline(pts, Color(INK, fade), w, true)
	ci.draw_set_transform(Vector2.ZERO)


## The chip's quad around the origin (local px), the same shape SlamDebris and RamMarks fling.
static func chip_points(s: float) -> PackedVector2Array:
	return PackedVector2Array(
		[Vector2(s, 0.0), Vector2(0.0, s * 0.6), Vector2(-s * 0.8, 0.0), Vector2(0.0, -s * 0.7)]
	)


static func _puffs(ci: CanvasItem, c: Vector2, t: float, ppm: float, seed: int) -> void:
	for i: int in PUFFS:
		var a: float = TAU * (i + 0.5) / PUFFS + 0.3 * sin(seed + i * 1.7)
		var d: float = (1.2 + 1.4 * t) * ppm
		var r: float = (0.35 + 0.5 * t) * ppm
		ci.draw_circle(c + Vector2.from_angle(a) * d, r, Color(CREAM, 0.55 * (1.0 - t)))


static func _hash(seed: int, i: int) -> int:
	return absi((seed * 73856093) ^ (i * 19349663) ^ 0x5bd1e995)


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	var g: GhostAttacks = GhostAttacks.shipped()
	_chips = int(g.num(&"tonnage", &"slam_debris")) if HitFeel.feel_flag() != "off" else 0
	_span_s = maxf(0.05, g.num(&"tonnage", &"slam_debris_s"))
	_flash_s = maxf(0.01, g.num(&"tonnage", &"slam_flash_s"))
