class_name FightNukeArt
extends RefCounted
## The mini-nuke in the D5 ink (drawn by FightAreasArt for a thrown round or a blast of
## NUKE_M or more): a fat finned shell lobbed high over a ground shadow, then the blast: a
## cream flash over the whole radius (one flash, 5 ticks, under the reduced-motion budget), a
## jagged fireball, two ink shock rings racing out, a mushroom of smoke rising on a stem and a
## ring of ground dust. View only: reads FightAreas.blasts. Lane gunplay.

## A blast this wide (metres) is drawn as a nuke, not a rocket burst.
const NUKE_M: float = 6.0
const LOB_M: float = 4.5
const FLASH_TICKS: int = 5
## FightAreas forgets a blast after VFX_KEEP_TICKS (40); the nuke plays out inside that.
const NUKE_TICKS: int = 40
const STEM_M: float = 3.2
const SMOKE: Color = Color(0.090, 0.075, 0.106, 0.62)
const SHADOW: Color = Color(0.090, 0.075, 0.106, 0.35)


static func shell(ci: CanvasItem, s: Shot, went: float, tick: int) -> void:
	var f: float = clampf(went / maxf(went + s.left_m, 0.1), 0.0, 1.0)
	var lift: float = 4.0 * LOB_M * f * (1.0 - f)
	var shadow: Vector2 = Vector2(30.0, 13.0) * (1.0 - 0.12 * lift)
	ci.draw_rect(Rect2(Ink.px(s.pos) - shadow * 0.5, shadow), SHADOW)
	var at: Vector2 = s.pos + Vector2(0.0, -lift)
	# nose follows the arc: up while climbing, down while falling
	var dir: Vector2 = (s.vel.normalized() + Vector2(0.0, -1.6 * (1.0 - 2.0 * f))).normalized()
	var side: Vector2 = dir.orthogonal()
	ci.draw_line(Ink.px(at - dir * 0.45), Ink.px(at + dir * 0.4), Ink.INK, 30.0)
	ci.draw_line(Ink.px(at - dir * 0.36), Ink.px(at + dir * 0.3), Ink.CREAM, 18.0)
	ci.draw_line(Ink.px(at - dir * 0.04), Ink.px(at + dir * 0.08), Ink.INK, 18.0)
	ci.draw_circle(Ink.px(at + dir * 0.4), 9.0, Ink.VERMILION)
	var fins: PackedVector2Array = PackedVector2Array(
		[
			Ink.px(at - dir * 0.6 + side * 0.3),
			Ink.px(at - dir * 0.3),
			Ink.px(at - dir * 0.6 - side * 0.3)
		]
	)
	ci.draw_polyline(fins, Ink.INK, 8.0, true)
	var wob: float = sin(float(tick) * 0.7) * 0.06
	ci.draw_circle(Ink.px(at - dir * (0.7 + wob)), 6.0, Color(SMOKE, 0.4))


static func blast(ci: CanvasItem, b: Vector3, age: int) -> void:
	if age >= NUKE_TICKS:
		return
	var c: Vector2 = Vector2(b.x, b.y)
	var k: float = float(age) / float(NUKE_TICKS)
	var r: float = b.z * Ink.PX_PER_M
	if age < FLASH_TICKS:
		var fl: float = 1.0 - float(age) / float(FLASH_TICKS)
		ci.draw_circle(Ink.px(c), r * (0.7 + 0.3 * fl), Color(Ink.CREAM, 0.85 * fl))
	_dust(ci, c, b.z, k)
	_rings(ci, c, r, age)
	if age < 16:
		_fireball(ci, c, b.z * (0.22 + 0.02 * float(age)), age)
	_mushroom(ci, c, b.z, k)


static func _rings(ci: CanvasItem, c: Vector2, r: float, age: int) -> void:
	for lag: int in [0, 9]:
		var a: int = age - lag
		if a < 0:
			continue
		var k: float = float(a) / float(NUKE_TICKS - lag)
		var w: float = (16.0 - float(lag)) * (1.0 - k) + 1.5
		ci.draw_arc(Ink.px(c), r * (0.25 + 0.85 * sqrt(k)), 0.0, TAU, 72, Ink.INK, w)


static func _fireball(ci: CanvasItem, c: Vector2, rad_m: float, age: int) -> void:
	var pts: Array[Vector2] = []
	for i: int in 25:
		var spike: float = 1.0 if i % 2 == 0 else 0.55 + 0.1 * float(i % 3)
		var ang: float = TAU * float(i) / 24.0 + float(age) * 0.04
		pts.append(Ink.px(c + Vector2.from_angle(ang) * rad_m * spike))
	var star: PackedVector2Array = PackedVector2Array(pts)
	ci.draw_colored_polygon(star.slice(0, 24), Ink.CREAM)
	ci.draw_polyline(star, Ink.INK, 9.0, true)
	ci.draw_circle(Ink.px(c), rad_m * 0.3 * Ink.PX_PER_M, Color(Ink.INK, 0.25))


## The stem rises out of the fireball and the cap rolls out at its top; both thin as they age.
static func _mushroom(ci: CanvasItem, c: Vector2, rad_m: float, k: float) -> void:
	var rise: float = STEM_M * minf(k * 2.2, 1.0)
	var fade: float = 1.0 - k * k
	var puff_m: float = rad_m * 0.07
	for i: int in 6:
		var at: Vector2 = c + Vector2(sin(float(i) * 1.7) * 0.15, -rise * float(i) / 5.0)
		var pr: float = puff_m * (0.8 + 0.1 * float(i)) * Ink.PX_PER_M
		ci.draw_circle(Ink.px(at), pr, Color(SMOKE, SMOKE.a * fade))
	var top: Vector2 = c + Vector2(0.0, -rise)
	var cap_m: float = rad_m * (0.12 + 0.14 * minf(k * 2.0, 1.0))
	for i: int in 9:
		var ang: float = TAU * float(i) / 9.0
		var off: Vector2 = Vector2(cos(ang) * cap_m, sin(ang) * cap_m * 0.45)
		var pr: float = cap_m * (0.42 + 0.08 * float(i % 3)) * Ink.PX_PER_M
		ci.draw_circle(Ink.px(top + off), pr + 4.0, Color(Ink.INK, 0.5 * fade))
		ci.draw_circle(Ink.px(top + off), pr, Color(SMOKE, SMOKE.a * fade))
	if k < 0.4:
		var glow: Color = Color(Ink.CREAM, 0.8 * (1.0 - k / 0.4))
		ci.draw_circle(Ink.px(top), cap_m * 0.45 * Ink.PX_PER_M, glow)


static func _dust(ci: CanvasItem, c: Vector2, rad_m: float, k: float) -> void:
	for i: int in 16:
		var ang: float = TAU * float(i) / 16.0 + float(i % 3) * 0.15
		var at: Vector2 = c + Vector2.from_angle(ang) * rad_m * (0.3 + 0.65 * sqrt(k))
		var pr: float = rad_m * (0.05 + 0.05 * k) * Ink.PX_PER_M
		ci.draw_circle(Ink.px(at), pr, Color(SMOKE, SMOKE.a * 0.7 * (1.0 - k)))
