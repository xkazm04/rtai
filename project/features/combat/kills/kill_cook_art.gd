class_name KillCookArt
extends RefCounted
## The electro baton's death (lane kills-new, style `cook`), render only: the overload. Unlike the
## electro gun's X-ray strobe there is no skeleton, no strobe and no arc: the current cooks him from
## inside. From `cook_from` to `cook_to` (row fx) he stands locked with a fine tremble while cream
## veins of light spread through his torso and limbs, brighter each tick, a glow builds under the
## skin, steam rises off his collar and shoulders and his eyes burn as two cream points that go out
## at `eyes_out`; then his drawn fall grid drops him (cells_at) and smoke rises off the body for
## `smoke_ticks`. Under --reduced-motion no tremble and no flicker. No blood. No RNG.

const CREAM: Color = Color("#F4E3B5")
const STEAM: Color = Color(0.86, 0.84, 0.78, 0.5)
const SMOKE: Color = Color(0.25, 0.24, 0.24, 0.42)
const VEINS: int = 7


## The tremble's lean (deg) at `age`: a fine buzz while he cooks, none under reduced motion.
static func tremble(d: KillNewStyles.Death, age: int, reduced_motion: bool) -> float:
	if reduced_motion or age < roundi(d.extra.num("cook_from", 3.0)):
		return 0.0
	if age >= roundi(d.extra.num("cook_to", 45.0)):
		return 0.0
	return d.extra.num("tremble_deg", 1.5) * (1.0 if age % 2 == 0 else -1.0)


static func draw(ci: KillNewStyles, d: KillNewStyles.Death, age: int) -> void:
	var from: float = d.extra.num("cook_from", 3.0)
	var to: float = d.extra.num("cook_to", 45.0)
	if age >= roundi(from) and age < roundi(to):
		var k: float = clampf((float(age) - from) / maxf(1.0, to - from), 0.0, 1.0)
		var flick: float = (
			1.0 if ci.reduced_motion else 0.85 + 0.15 * KillNewStyles.h(d.serial, age)
		)
		if not KillDeathCells.owns(d.cells):  # his own drawn cells carry the glow, veins, eyes
			_glow(ci, d, k * flick)
			_veins(ci, d, k * flick)
			if age < roundi(d.extra.num("eyes_out", 40.0)):
				_eyes(ci, d, k)
		_steam(ci, d, age - roundi(from))
	elif age >= roundi(to):
		smoke(ci, d, age - roundi(to))


static func _at(d: KillNewStyles.Death, up: float, side: float, ppm: float) -> Vector2:
	var axis: Vector2 = d.head_px - d.feet_px
	var across: Vector2 = axis.normalized().orthogonal() if axis != Vector2.ZERO else Vector2.RIGHT
	return d.feet_px + axis * up + across * side * ppm


static func _glow(ci: KillNewStyles, d: KillNewStyles.Death, k: float) -> void:
	var c: Vector2 = _at(d, 0.55, 0.0, ci.ppm)
	ci.draw_circle(c, ci.ppm * 0.26, Color(CREAM, 0.12 + 0.3 * k))
	ci.draw_circle(c, ci.ppm * 0.14, Color(CREAM, 0.2 + 0.45 * k))


## Veins of light from the chest out into the limbs, reaching further as he cooks.
static func _veins(ci: KillNewStyles, d: KillNewStyles.Death, k: float) -> void:
	var w: float = maxf(1.0, ci.ppm * 0.035)
	for v: int in VEINS:
		var a: float = KillNewStyles.h(d.serial, v + 500)
		var up: float = 0.55 + (a - 0.5) * (0.5 + 0.3 * k)
		var side: float = (KillNewStyles.h(d.serial, v + 510) - 0.5) * 0.5 * (0.4 + 0.6 * k)
		var mid: Vector2 = _at(d, lerpf(0.55, up, 0.5), side * 0.4 + 0.04, ci.ppm)
		var pts: PackedVector2Array = PackedVector2Array(
			[_at(d, 0.55, 0.0, ci.ppm), mid, _at(d, up, side, ci.ppm)]
		)
		ci.draw_polyline(pts, Color(CREAM, 0.35 + 0.6 * k), w, true)


static func _eyes(ci: KillNewStyles, d: KillNewStyles.Death, k: float) -> void:
	var r: float = maxf(1.2, ci.ppm * (0.02 + 0.015 * k))
	for s: float in [-0.045, 0.045]:
		ci.draw_circle(_at(d, 0.87, s, ci.ppm), r * 1.8, Color(CREAM, 0.35))
		ci.draw_circle(_at(d, 0.87, s, ci.ppm), r, CREAM)


## Steam off the collar and shoulders: puffs that rise and thin, a new one every 6 ticks.
static func _steam(ci: KillNewStyles, d: KillNewStyles.Death, a: int) -> void:
	for n: int in mini(a / 6 + 1, 7):
		var t: float = float(a - n * 6) / 24.0
		if t < 0.0 or t > 1.0:
			continue
		var side: float = 0.16 if n % 2 == 0 else -0.16
		var p: Vector2 = _at(d, 0.82, side, ci.ppm) + Vector2(0.0, -ci.ppm * 0.6 * t)
		ci.draw_circle(p, ci.ppm * (0.05 + 0.08 * t), Color(STEAM, STEAM.a * (1.0 - t)))


## Smoke off the body where it lies, rising and thinning over `smoke_ticks`.
static func smoke(ci: KillNewStyles, d: KillNewStyles.Death, a: int) -> void:
	var ticks: float = d.extra.num("smoke_ticks", 200.0)
	if float(a) >= ticks:
		return
	var fade: float = 1.0 - float(a) / ticks
	var body: Vector2 = d.feet_px + d.fall * d.height * 0.45
	for n: int in 3:
		var t: float = fposmod(float(a) / 40.0 + float(n) / 3.0, 1.0)
		var p: Vector2 = body + Vector2(ci.ppm * 0.1 * float(n - 1), -ci.ppm * 0.9 * t)
		ci.draw_circle(p, ci.ppm * (0.06 + 0.1 * t), Color(SMOKE, SMOKE.a * (1.0 - t) * fade))
