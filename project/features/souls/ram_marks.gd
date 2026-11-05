class_name RamMarks
extends RefCounted
## n7-melee: Tonnage's ram made to read at 32 px/m (the 48 px/m audit: the press shoved cops into
## a heap with no mark on the contact; HaulerKick's shake and stop ran, but nothing printed where
## the press met the body). Drawn for each recent ram hit HaulerStage keeps, by TonnageView (the
## ghost forms) or CastView (quest 1): on the contact frame a cream impact burst edged in ink just
## past the body (the press hides its near side), and a few paper chips edged in ink flung on along
## the shove. A world impact prints in ink and paper. Data: ghost_attacks.json tonnage
## ram_flash_s (0 = none) and ram_chips; --feel=off = none. Seeded from the hit: view only.

const INK: Color = SlamDebris.INK
const CREAM: Color = SlamDebris.CREAM
const RAYS: int = 6
const BURST_M: float = 0.7
const CHIP_S: float = 0.35
const CHIP_LIE_S: float = 0.5

static var _loaded: bool = false
static var _flash_s: float = 0.0
static var _chips: int = 0


## Every recent ram hit `h` keeps (HaulerStage.ram_marks), at stage tick `tick`.
static func draw_all(ci: CanvasItem, h: HaulerStage, tick: int, ppm: float) -> void:
	for m: Vector4 in h.ram_marks:
		var age: float = (tick - int(m.w)) * SimClock.TICK_DT
		draw(ci, Vector2(m.x, m.y) * ppm, Vector2.from_angle(m.z), age, ppm)


## The marks of one ram hit `age` seconds old: `at` is the body (canvas px), `dir` the shove.
static func draw(ci: CanvasItem, at: Vector2, dir: Vector2, age: float, ppm: float) -> void:
	_load()
	if _flash_s <= 0.0 or age < 0.0:
		return
	var contact: Vector2 = at + dir * 0.1 * ppm  # past the body: the press hides its near side
	if age < _flash_s:
		_burst(ci, contact, dir.angle(), age / _flash_s, ppm)
	if age < CHIP_S + CHIP_LIE_S:
		for i: int in _chips:
			_chip(ci, contact, dir, age, ppm, i)


static func _burst(ci: CanvasItem, c: Vector2, turn: float, t: float, ppm: float) -> void:
	var r: float = BURST_M * ppm * (1.0 - 0.4 * t)
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in RAYS * 2:
		var k: float = 1.0 if i % 2 == 0 else 0.45
		@warning_ignore("return_value_discarded")
		pts.push_back(c + Vector2.from_angle(turn + TAU * i / (RAYS * 2)) * r * k)
	ci.draw_colored_polygon(pts, Color(CREAM, 1.0 - t * t))
	@warning_ignore("return_value_discarded")
	pts.push_back(pts[0])
	ci.draw_polyline(pts, Color(INK, 1.0 - t), 3.0, true)


## One chip on along the shove (a 70-degree fan), decelerating, then lying until it fades.
static func _chip(ci: CanvasItem, c: Vector2, dir: Vector2, age: float, ppm: float, i: int) -> void:
	var h: float = fposmod(sin(float(i) * 12.9898 + 4.1) * 43758.5453, 1.0)
	var a: float = dir.angle() + (float(i) / maxf(1.0, float(_chips - 1)) - 0.5) * 1.2 + h * 0.2
	var t: float = clampf(age / CHIP_S, 0.0, 1.0)
	var fade: float = 1.0 - clampf((age - CHIP_S) / CHIP_LIE_S, 0.0, 1.0)
	var reach: float = (0.7 + 0.8 * h) * ppm * (1.0 - pow(1.0 - t, 2.0))
	var p: Vector2 = c + Vector2.from_angle(a) * reach
	var s: float = (0.12 + 0.08 * h) * ppm
	var spin: float = a + t * 7.0
	var pts: PackedVector2Array = PackedVector2Array(
		[
			p + Vector2(s, 0.0).rotated(spin),
			p + Vector2(0.0, s * 0.6).rotated(spin),
			p + Vector2(-s * 0.8, 0.0).rotated(spin),
			p + Vector2(0.0, -s * 0.7).rotated(spin)
		]
	)
	ci.draw_colored_polygon(pts, Color(CREAM, fade))
	@warning_ignore("return_value_discarded")
	pts.append(pts[0])
	ci.draw_polyline(pts, Color(INK, fade), 1.5, true)


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	var g: GhostAttacks = GhostAttacks.shipped()
	var on: bool = HitFeel.feel_flag() != "off"
	_flash_s = g.num(&"tonnage", &"ram_flash_s") if on else 0.0
	_chips = int(g.num(&"tonnage", &"ram_chips"))
