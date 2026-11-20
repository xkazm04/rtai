class_name KerfSlot
extends RefCounted
## The press draws the entire slot. Only its departure end moves as the ink closes.

const CORE_M: float = 0.04
const GLOW_M: float = 0.12
const CORE: Color = Color(0.85, 1.0, 0.96)
const GLOW: Color = Color(0.18, 0.77, 0.71, 0.72)
const CUT_MARK_DELAY_TICKS: int = 3
const MARK_WIDTH_M: float = 0.035
const OVERSHOOT_M: float = 0.5
const RETURN_TICKS: int = 6
const SPARKS: int = 5
const SPARK_RADIUS_M: float = 0.032
const CLEARANCE_M: float = 0.3

var start: Vector2
var end: Vector2
var fade: float
var glow_width: float
var core_width: float
var mark_width: float
var mark_centre: Vector2
var mark_tip: Vector2
var motes: PackedVector2Array = []
var mote_radius: float


static func overshoot(age: int) -> float:
	if age < 0 or age >= RETURN_TICKS:
		return 0.0
	return OVERSHOOT_M * pow(1.0 - float(age) / RETURN_TICKS, 3)


static func end_m(k: KerfStage, i: int, age: int) -> Vector2:
	var to: Vector2 = k.trail_to[i]
	if k.trail_cut[i] == Vector2.INF:
		return to
	return to + k.trail_from[i].direction_to(to) * overshoot(age)


static func remaining(age: int, hang_s: float) -> float:
	if hang_s <= 0.0:
		return 1.0 if age == 0 else 0.0
	return clampf(1.0 - age * SimClock.TICK_DT / hang_s, 0.0, 1.0)


func place(k: KerfStage, i: int, age: int, ppm: float, reduced_motion: bool = false) -> void:
	fade = remaining(age, k.num(&"cut_hang_s"))
	end = end_m(k, i, age) * ppm
	start = end.lerp(k.trail_from[i] * ppm, fade)
	glow_width = GLOW_M * ppm * fade
	core_width = CORE_M * ppm * fade
	mark_width = 0.0
	motes.clear()
	if not reduced_motion and fade > 0.0:
		_place_motes(k, i, age, ppm)
	if age >= CUT_MARK_DELAY_TICKS and k.trail_cut[i] != Vector2.INF:
		mark_centre = k.trail_cut[i] * ppm
		var dir: Vector2 = k.trail_from[i].direction_to(k.trail_to[i])
		mark_tip = dir.rotated(deg_to_rad(KerfView.CUT_DEG)) * KerfView.CUT_HALF_M * ppm * fade
		mark_width = MARK_WIDTH_M * ppm * fade


func _place_motes(k: KerfStage, i: int, age: int, ppm: float) -> void:
	var from: Vector2 = k.trail_from[i] * ppm
	var to: Vector2 = k.trail_to[i] * ppm
	var axis: Vector2 = from.direction_to(to)
	var normal: Vector2 = axis.orthogonal()
	mote_radius = SPARK_RADIUS_M * ppm
	var clear_px: float = (k.trail_radius[i] + CLEARANCE_M) * ppm + mote_radius + 1.0
	for j: int in SPARKS:
		var salt: int = hash(Vector2i(k.trail_tick[i], j))
		var u: float = (j + 0.15 + 0.7 * (salt & 255) / 255.0) / SPARKS
		var at: Vector2 = from.lerp(to, u)
		if (at - start).dot(axis) < 0.0 or axis == Vector2.ZERO:
			continue
		var side: float = -1.0 if salt & 256 else 1.0
		var drift: float = 0.055 + 0.08 * ((salt >> 9) & 255) / 255.0 + 0.003 * age
		at += normal * side * drift * ppm
		if k.trail_cut[i] != Vector2.INF and at.distance_to(k.trail_cut[i] * ppm) <= clear_px:
			continue
		@warning_ignore("return_value_discarded")
		motes.append(at)


func draw(view: CanvasItem) -> void:
	if fade <= 0.0:
		return
	view.draw_line(start, end, Color(GLOW, GLOW.a * fade), glow_width, true)
	view.draw_line(start, end, Color(CORE, fade), core_width, true)
	for at: Vector2 in motes:
		view.draw_circle(at, mote_radius, Color(CORE, 0.90 * fade), true, -1.0, true)
	if mark_width > 0.0:
		view.draw_line(
			mark_centre - mark_tip, mark_centre + mark_tip, Color(CORE, fade), mark_width, true
		)
