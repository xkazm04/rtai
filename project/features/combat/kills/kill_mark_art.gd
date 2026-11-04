class_name KillMarkArt
extends RefCounted
## How a signature kill's marks print (lane brutality), drawn into a CanvasItem by KillView: the
## red spray fan (drops with a dark rim, the near ones splatting into lobed blots), the drag smears
## of sliding parts, the scorch star (soot halo, ink core) and the kill's ink flash. Red is blood
## only; the scorch is ink. Shapes vary by position, not dice, so they never touch the sim RNG.

const BLOOD: Color = Color("#A30509")
const BLOOD_DARK: Color = Color("#540005")
const SOOT: Color = Color(0.09, 0.075, 0.105, 0.55)
## A drag smear thins from the landing over this much slide (metres).
const SMEAR_TAPER_M: float = 1.6


static func scorch(ci: CanvasItem, m: KillMarks.Mark, ppm: float) -> void:
	if m.scorch_m <= 0.0:
		return
	var c: Vector2 = m.at * ppm
	var halo: PackedVector2Array = PackedVector2Array()
	var core: PackedVector2Array = PackedVector2Array()
	for k: int in 22:
		var a: float = TAU * float(k) / 22.0
		var jag: float = 0.7 + 0.3 * sin(a * 5.0 + m.at.x) + (0.25 if k % 2 == 0 else 0.0)
		@warning_ignore("return_value_discarded")
		halo.append(c + Vector2.from_angle(a) * m.scorch_m * ppm * jag)
		@warning_ignore("return_value_discarded")
		core.append(c + Vector2.from_angle(a) * m.scorch_m * ppm * 0.42 * (0.8 + 0.2 * jag))
	KillPoly.fill(ci, halo, SOOT)
	KillPoly.fill(ci, core, Ink.INK)


static func spray(ci: CanvasItem, m: KillMarks.Mark, ppm: float) -> void:
	var c: Vector2 = m.at * ppm
	for d: Vector3 in m.drops:
		var p: Vector2 = c + Vector2(d.x, d.y) * ppm
		var r: float = d.z * ppm
		ci.draw_circle(p, r * 1.18, BLOOD_DARK)
		ci.draw_circle(p, r, BLOOD)
		if r > 0.12 * ppm:  # a big drop throws a satellite further out along the fan
			ci.draw_circle(p + m.dir * r * 1.9, r * 0.35, BLOOD)
	if not m.drops.is_empty():  # a bloodless kill (fire) leaves no splat
		blot(ci, c + m.dir * 0.75 * ppm, 0.5 * ppm, m.at.y)


## A lobed blood blot (the splash where the body was), lobes set by `phase`.
static func blot(ci: CanvasItem, c: Vector2, r: float, phase: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for k: int in 16:
		var a: float = TAU * float(k) / 16.0
		var lobe: float = 0.72 + 0.28 * sin(a * 4.0 + phase) + (0.18 if k % 3 == 0 else 0.0)
		@warning_ignore("return_value_discarded")
		pts.append(c + Vector2.from_angle(a) * r * lobe)
	KillPoly.fill(ci, pts, BLOOD_DARK)
	var inner: PackedVector2Array = PackedVector2Array()
	for p: Vector2 in pts:
		@warning_ignore("return_value_discarded")
		inner.append(c + (p - c) * 0.82)
	KillPoly.fill(ci, inner, BLOOD)


## One blot of a drag smear (point `k` of the slide, `run_px` from where the part landed),
## appended to the canvas item `rid` once and never redrawn: fat at the landing, thinning over
## SMEAR_TAPER_M of slide, every fifth point a gap, so it reads as a wet streak, not a ruled line.
static func smear_blot(rid: RID, at: Vector2, k: int, run_px: float, ppm: float) -> void:
	if k % 5 == 4:
		return
	var t: float = clampf(run_px / (SMEAR_TAPER_M * ppm), 0.0, 1.0)
	var r: float = ppm * (0.13 - 0.08 * t) * (0.75 + 0.25 * sin(float(k) * 2.3))
	RenderingServer.canvas_item_add_circle(rid, at, r * 1.2, BLOOD_DARK)
	RenderingServer.canvas_item_add_circle(rid, at, r, BLOOD)


static func flash(ci: CanvasItem, m: KillMarks.Mark, age: int, ppm: float, hold: int) -> void:
	var c: Vector2 = m.at * ppm
	var grow: float = (1.0 + 0.25 * float(age)) * m.flash_scale
	var pts: PackedVector2Array = PackedVector2Array()
	for k: int in 24:
		var r: float = (1.6 if k % 2 == 0 else 0.8) * ppm * grow
		@warning_ignore("return_value_discarded")
		pts.append(c + Vector2.from_angle(TAU * float(k) / 24.0 + 0.2) * r)
	KillPoly.fill(ci, pts, Ink.CREAM if age < hold else SOOT)
	@warning_ignore("return_value_discarded")
	pts.append(pts[0])
	ci.draw_polyline(pts, Ink.INK, maxf(2.0, ppm * 0.08))
