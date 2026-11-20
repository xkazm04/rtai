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

var start: Vector2
var end: Vector2
var fade: float
var glow_width: float
var core_width: float
var mark_width: float
var mark_centre: Vector2
var mark_tip: Vector2


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


func place(k: KerfStage, i: int, age: int, ppm: float) -> void:
	fade = remaining(age, k.num(&"cut_hang_s"))
	end = end_m(k, i, age) * ppm
	start = end.lerp(k.trail_from[i] * ppm, fade)
	glow_width = GLOW_M * ppm * fade
	core_width = CORE_M * ppm * fade
	mark_width = 0.0
	if age >= CUT_MARK_DELAY_TICKS and k.trail_cut[i] != Vector2.INF:
		mark_centre = k.trail_cut[i] * ppm
		var dir: Vector2 = k.trail_from[i].direction_to(k.trail_to[i])
		mark_tip = dir.rotated(deg_to_rad(KerfView.CUT_DEG)) * KerfView.CUT_HALF_M * ppm * fade
		mark_width = MARK_WIDTH_M * ppm * fade


func draw(view: CanvasItem) -> void:
	if fade <= 0.0:
		return
	view.draw_line(start, end, Color(GLOW, GLOW.a * fade), glow_width, true)
	view.draw_line(start, end, Color(CORE, fade), core_width, true)
	if mark_width > 0.0:
		view.draw_line(
			mark_centre - mark_tip, mark_centre + mark_tip, Color(CORE, fade), mark_width, true
		)
