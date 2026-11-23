class_name KillCookArt
extends RefCounted
## The baton's contact flash and crawling current follow the posed victim, including drawn
## death cards. The first twenty ticks jerk about the planted feet, then each row's fall takes over.

const SEIZURE_TICKS: int = 20
const FLASH_TICKS: int = 3
const BLUE: Color = Color("#88aaff")
const AMBER: Color = Color("#ffbf56")
const CREAM: Color = Color("#F4E3B5")
const STEAM: Color = Color(0.86, 0.84, 0.78, 0.5)
const SMOKE: Color = Color(0.25, 0.24, 0.24, 0.42)
const VEINS: int = 7


## The tremble's lean (deg) at `age`: a fine buzz while he cooks, none under reduced motion.
static func tremble(d: KillNewStyles.Death, age: int, reduced_motion: bool) -> float:
	if reduced_motion or age < 0 or age >= SEIZURE_TICKS:
		return 0.0
	var muscle: float = d.extra.num("tremble_deg", 1.5)
	var sign_x: float = 1.0 if (age / 2) % 2 == 0 else -1.0
	return sign_x * (5.0 + muscle) * (1.0 - 0.35 * float(age) / SEIZURE_TICKS)


static func pose(d: KillNewStyles.Death, age: int, reduced_motion: bool) -> float:
	if not d.row.victim.is_empty() and d.body != null:
		char_body(d, age)
	return tremble(d, age, reduced_motion)


static func char_body(d: KillNewStyles.Death, age: int) -> void:
	var stop: float = d.extra.num("cook_to", 45.0)
	var soot: float = smoothstep(stop * 0.7, stop, float(age))
	d.body.modulate = Color.WHITE.lerp(Color(0.45, 0.43, 0.4), soot)


static func draw(ci: KillNewStyles, d: KillNewStyles.Death, age: int) -> void:
	if age >= 0 and age < SEIZURE_TICKS:
		_current(ci, d, age)
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


## Two linked paths around the shoulders and legs, grounded on the same pose as the body.
static func _current(ci: KillNewStyles, d: KillNewStyles.Death, age: int) -> void:
	var tick: int = 0 if ci.reduced_motion else age / 2
	var chest: Vector2 = _at(d, 0.68, 0.0, ci.ppm)
	for flank: int in 2:
		var side: float = 1.0 if flank == 0 else -1.0
		var bend: float = KillNewStyles.h(d.serial + flank, tick) * 0.22
		var bolt: PackedVector2Array = PackedVector2Array(
			[
				_at(d, 0.96, side * 0.10, ci.ppm),
				_at(d, 0.77, side * (0.38 + bend), ci.ppm),
				_at(d, 0.64, side * 0.23, ci.ppm),
				_at(d, 0.53, side * (0.43 + bend), ci.ppm),
				_at(d, 0.37, side * 0.18, ci.ppm),
				_at(d, 0.18, side * (0.26 + bend), ci.ppm)
			]
		)
		ci.draw_polyline(bolt, Color(AMBER, 0.65), ci.ppm * 0.15, true)
		ci.draw_polyline(bolt, BLUE, ci.ppm * 0.085, true)
		ci.draw_polyline(bolt, Color.WHITE, maxf(1.3, ci.ppm * 0.041), true)
	if age < FLASH_TICKS and not ci.reduced_motion:
		ci.draw_circle(chest, ci.ppm * 0.34, Color(AMBER, 0.42))
		ci.draw_circle(chest, ci.ppm * 0.14, Color.WHITE)


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
