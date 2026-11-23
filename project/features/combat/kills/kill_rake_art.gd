class_name KillRakeArt
extends RefCounted
## Two clamp tips score the drawn victim. Blood follows the rake out of the wound,
## curves down into the street, and collects below it. All distances are view metres.

const FAN_TICKS: int = 17
const SCORE_TICKS: int = 9
const POOL_TICKS: int = 30


## Normalized time on a drop's flight. The last few drops leave two ticks later.
static func flight(age: int, drop: int) -> float:
	return clampf(float(age - drop % 3) / float(FAN_TICKS), 0.0, 1.0)


static func drop_offset(index: int, serial: int, axis: Vector2, u: float) -> Vector2:
	var spread: float = lerpf(-0.38, 0.38, KillNewStyles.h(serial, index))
	var reach: float = lerpf(0.36, 1.38, KillNewStyles.h(serial, index + 31))
	var cast: Vector2 = axis.rotated(spread) * reach
	return cast * u + Vector2.DOWN * u * (1.1 * u - 0.36)


static func pool(ci: KillGround, age: int) -> void:
	var growth: float = smoothstep(4.0, float(POOL_TICKS), float(age))
	if growth <= 0.0:
		return
	var mark: KillMarks.Mark = ci.mark
	var at: Vector2 = (mark.at + mark.dir * 0.32) * ci.view.ppm
	KillMarkArt.blot(ci, at, growth * mark.blot_m * ci.view.ppm, mark.at.x, mark.dir)


static func draw(ci: KillNewStyles, d: KillNewStyles.Death, age: int) -> void:
	if age < 0 or age > FAN_TICKS + 2:
		return
	var height: float = d.extra.num("wound_height", 0.68)
	var wound: Vector2 = d.feet_px.lerp(d.head_px, height)
	var turn: float = deg_to_rad(d.extra.num("rake_angle", 20.0))
	var side: float = -1.0 if d.dir.x < 0.0 else 1.0
	var axis: Vector2 = d.dir.rotated(side * turn)
	if age < SCORE_TICKS:
		_scores(ci, wound, axis, age)
	for i: int in 11:
		var u: float = flight(age, i)
		if u >= 1.0:
			continue
		var offset: Vector2 = drop_offset(i, d.serial, axis, u)
		var drop: Vector2 = wound + offset * ci.ppm
		var r: float = ci.ppm * lerpf(0.035, 0.082, KillNewStyles.h(d.serial, i + 61))
		var tail: Vector2 = axis * r * (1.8 - u)
		ci.draw_line(drop - tail, drop, KillMarkArt.BLOOD_DARK, maxf(1.0, r * 1.6), true)
		ci.draw_circle(drop, maxf(1.0, r), KillMarkArt.BLOOD)


static func _scores(ci: KillNewStyles, wound: Vector2, axis: Vector2, age: int) -> void:
	var ppm: float = ci.ppm
	var normal: Vector2 = axis.orthogonal()
	var length_m: float = lerpf(0.64, 0.35, float(age) / SCORE_TICKS)
	for tine: float in [-0.065, 0.065]:
		var middle: Vector2 = wound + normal * tine * ppm
		var start: Vector2 = middle - axis * 0.2 * ppm
		var tip: Vector2 = middle + (axis * length_m - normal * 0.08) * ppm
		KillPoly.fill(
			ci, PackedVector2Array([start, middle + normal * 0.04 * ppm, tip]), KillMarkArt.BLOOD
		)
