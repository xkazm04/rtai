class_name RamWake
extends RefCounted
## n7-melee: Tonnage's ram called before the contact (audit 7b, anticipation 2: the ram hurt on
## touch at speed with nothing to say the press was charging). While the press moves faster than
## the ram speed, a bow wave of ink and paper rolls ahead of it outside its footprint (two swept
## arcs from the nose past the flanks) with dust streaks off the flanks, growing in from 0.8 of
## ram_mps to full at ram_mps, so the charge reads a beat before anyone is hit. Drawn by
## TonnageView (the ghost forms) and CastView (quest 1). Data: ghost_attacks.json tonnage
## ram_wake_k (opacity; 0 = none); --feel=off = none. Phase from the tick: view only.

const INK: Color = SlamDebris.INK
const CREAM: Color = SlamDebris.CREAM
## How far past the body radius the wave's nose rides and its flanks sweep: the press is drawn
## about 0.7 m past its 0.9 m body (the gear arms 1.1 m), so the wave rides outside the art.
const NOSE_M: float = 1.3
const FLANK_M: float = 1.5
const STREAKS: int = 3
const STREAK_M: float = 0.9

static var _loaded: bool = false
static var _k: float = 0.0


## The wave strength for a press at `speed` with ram speed `ram_mps`: 0 below 0.8 of it, 1 at it.
static func strength(speed: float, ram_mps: float) -> float:
	_load()
	if _k <= 0.0 or ram_mps <= 0.0:
		return 0.0
	return _k * clampf((speed / ram_mps - 0.8) / 0.2, 0.0, 1.0)


## The wave round the press at `c` (canvas px) for `form` (its speed, ram_mps and body class).
static func draw(ci: CanvasItem, c: Vector2, form: HaulerForm, tick: int, ppm: float) -> void:
	var a: float = strength(form.vel.length(), form.num(&"ram_mps"))
	if a <= 0.0:
		return
	var reach: float = ArenaBodies.table().radius(form.body_class)
	var fwd: Vector2 = form.vel.normalized()
	for s: float in [-1.0, 1.0]:  # metres in: x ahead, y out past this flank
		var xf: Transform2D = Transform2D(fwd * ppm, fwd.orthogonal() * s * ppm, c)
		var pts: PackedVector2Array = PackedVector2Array()
		for i: int in 7:  # the swept arc: from the nose back past the flank
			var t: float = i / 6.0
			var back: float = (reach + NOSE_M) * (1.0 - t) - reach * 0.6 * t
			var out: float = (reach + FLANK_M) * sin(t * PI * 0.5)
			@warning_ignore("return_value_discarded")
			pts.push_back(xf * Vector2(back, out))
		ci.draw_polyline(pts, Color(INK, 0.75 * a), 5.0, true)
		ci.draw_polyline(pts, Color(CREAM, a), 2.0, true)
		_streaks(ci, xf, reach, a, tick)


## Dust streaks peeling off a flank, drifting back with the tick.
static func _streaks(ci: CanvasItem, xf: Transform2D, reach: float, a: float, tick: int) -> void:
	for i: int in STREAKS:
		var phase: float = fposmod(tick * 0.06 + i / float(STREAKS), 1.0)
		var at: Vector2 = Vector2(-reach * 0.4 * phase, reach + FLANK_M - 0.2 * i)
		var tail: Vector2 = at - Vector2(STREAK_M * (0.5 + 0.5 * phase), 0.0)
		ci.draw_line(xf * at, xf * tail, Color(INK, 0.6 * a * (1.0 - phase)), 2.0, true)


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	var on: bool = HitFeel.feel_flag() != "off"
	_k = GhostAttacks.shipped().num(&"tonnage", &"ram_wake_k") if on else 0.0
