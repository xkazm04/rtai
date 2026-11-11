class_name KillThrowArt
extends RefCounted
## Rivet's bare-claw finisher (lane kills-new, style `throw`), render only. The baton cooks him
## from inside and the electro gun strobes his skeleton; the charged claw is Rivet's own body, so
## it THROWS him. For `arc_ticks` a cream arc jumps from the claw into his chest while the pose
## track lifts him onto his toes; the slide (row `slide_m` by the track's tip share) carries him
## back along the blow, lofted `lift_m` in a low hop from `lift_from` to `land_at`, where his
## drawn fall grid has him on his back; he skids on. A cream spark crawls over him every
## `spark_every` ticks to `spark_to` (none under --reduced-motion: no strobe), an ink skid line
## stays from where he landed to his boots, and smoke rises off him. No blood. No RNG: shapes
## from KillNewStyles.h.

const ARC: Color = Color("#F4E3B5")
const SKID: Color = Color(0.11, 0.1, 0.12, 0.55)


## Layer px the throw lofts him this tick (screen up): a sine hop from `lift_from` to `land_at`.
static func lift(d: KillNewStyles.Death, age: int, ppm: float) -> Vector2:
	var a: float = d.extra.num("lift_from", 4.0)
	var b: float = d.extra.num("land_at", 20.0)
	if float(age) <= a or float(age) >= b:
		return Vector2.ZERO
	var u: float = (float(age) - a) / (b - a)
	return Vector2(0.0, -sin(PI * u) * d.extra.num("lift_m", 0.4) * ppm)


## Layer px of the slide (the track's tip share of `slide_m` along the blow) at `age`.
static func slide(d: KillNewStyles.Death, age: int, ppm: float) -> Vector2:
	var tip: float = clampf(KillTrack.sample(d.extra.track, age).z, 0.0, 1.0)
	return d.dir * KillDeathCells.slide_m_of(d) * ppm * tip


static func draw(ci: KillNewStyles, d: KillNewStyles.Death, age: int) -> void:
	var land: int = roundi(d.extra.num("land_at", 20.0))
	if age >= land:  # the skid: from where he landed to his boots now
		var back: Vector2 = slide(d, age, ci.ppm) - slide(d, land, ci.ppm)
		ci.draw_line(d.feet_px - back, d.feet_px, SKID, maxf(1.0, ci.ppm * 0.07))
		KillCookArt.smoke(ci, d, age - land)
	var chest: Vector2 = d.feet_px.lerp(d.head_px, 0.62)
	if age < roundi(d.extra.num("arc_ticks", 4.0)):
		var claw: Vector2 = chest - d.dir * ci.ppm * d.extra.num("arc_m", 0.7)
		_zap(ci, d, claw, chest, age)
	var every: int = maxi(1, roundi(d.extra.num("spark_every", 4.0)))
	if ci.reduced_motion or age >= roundi(d.extra.num("spark_to", 60.0)) or age % every > 1:
		return
	var n: int = floori(float(age) / float(every))
	var u: float = 0.3 + 1.2 * KillNewStyles.h(d.serial, n)
	var on: Vector2 = d.feet_px.lerp(_middle(d, age >= land), u)
	var span: Vector2 = Vector2.from_angle(TAU * KillNewStyles.h(d.serial, n + 50)) * ci.ppm * 0.14
	_zap(ci, d, on - span, on + span, n + 100)


## Layer px of the body's middle: the drawn lying cell's alpha centroid once he is down, else the
## chest.
static func _middle(d: KillNewStyles.Death, lying: bool) -> Vector2:
	if lying and d.cells != null and d.cells.visible:
		return d.xf * (d.cells.transform * KillCellBody.centroid(d.cells))
	return d.feet_px.lerp(d.head_px, 0.62)


## A jagged cream bolt from `a` to `b` with an ink line under it (`kink` picks the kinks).
static func _zap(
	ci: KillNewStyles, d: KillNewStyles.Death, a: Vector2, b: Vector2, kink: int
) -> void:
	var pts: PackedVector2Array = PackedVector2Array([a])
	var side: Vector2 = (b - a).orthogonal().normalized() * ci.ppm * 0.06
	for k: int in 3:
		var u: float = float(k + 1) / 4.0
		var off: float = KillNewStyles.h(d.serial + kink, k) * 2.0 - 1.0
		@warning_ignore("return_value_discarded")
		pts.append(a.lerp(b, u) + side * off)
	@warning_ignore("return_value_discarded")
	pts.append(b)
	ci.draw_polyline(pts, Ink.INK, maxf(2.0, ci.ppm * 0.05))
	ci.draw_polyline(pts, ARC, maxf(1.0, ci.ppm * 0.025))
