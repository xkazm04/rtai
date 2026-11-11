class_name KillPinArt
extends RefCounted
## Gloria's death (lane kills-new, style `pin`), render only: the nail gun pins him. On the hit the
## nails streak in along the shot; with a wall within `wall_m` behind him (the stage's push_out,
## probed along the shot) he is carried back onto it and hangs there by both sleeves, feet off the
## street (`lift_m`), writhing (`writhe_deg`, dying out over `writhe_ticks`); on the open street he
## falls back (his drawn fall grid) and a nail through the foot and one through a sleeve hold him to
## the street while he writhes. The drawn nails stay with the body. No RNG.

const SHANK: Color = Color(0.07, 0.06, 0.07)
const HEAD: Color = Color("#F4E3B5")
## Ticks a nail streaks in after the hit-stop, and its streak's length (m).
const STREAK_TICKS: int = 3
const STREAK_M: float = 0.9
const PROBE_STEP_M: float = 0.15
## The length of a driven nail's shank left showing (m), its head at the end.
const SHANK_M: float = 0.16


## Metres to the first wall behind `at` along `dir` within `reach_m` (-1: none, or no stage walls).
static func wall_behind(kills: SignatureKills, at: Vector2, dir: Vector2, reach_m: float) -> float:
	if not kills.push_out.is_valid():
		return -1.0
	var m: float = PROBE_STEP_M
	while m <= reach_m:
		var p: Vector2 = at + dir * m
		var out: Vector2 = kills.push_out.call(p)
		if out != p:
			return m
		m += PROBE_STEP_M
	return -1.0


## The writhe added to the track's lean this tick (degrees), from `settle` on, dying out.
static func writhe(d: KillNewStyles.Death, age: int) -> float:
	var from: float = d.extra.num("settle", 10.0)
	var ticks: float = maxf(1.0, d.extra.num("writhe_ticks", 80.0))
	var t: float = float(age) - from
	if t < 0.0 or t > ticks:
		return 0.0
	var fade: float = 1.0 - t / ticks
	return d.extra.num("writhe_deg", 6.0) * sin(t * 0.55) * sin(t * 0.13 + 0.7) * fade


## The carry onto the wall (layer px): back along the shot to the wall and up off the street.
static func shift(d: KillNewStyles.Death, age: int, ppm: float) -> Vector2:
	if d.wall_m < 0.0:
		return Vector2.ZERO
	var k: float = clampf(float(age) / maxf(1.0, d.extra.num("slide_ticks", 6.0)), 0.0, 1.0)
	k = 1.0 - (1.0 - k) * (1.0 - k)  # eased out: slammed, then stopped by the wall
	var back: float = maxf(0.0, d.wall_m - 0.2) * ppm
	return d.dir * back * k + Vector2(0.0, -d.extra.num("lift_m", 0.12) * ppm * k)


static func draw(ci: KillNewStyles, d: KillNewStyles.Death, age: int) -> void:
	var a: int = age - d.row.hitstop_ticks
	for p: Vector2 in _nails(d, ci.ppm):
		if a >= 0 and a < STREAK_TICKS:  # the nail flying in along the shot
			var k: float = float(a + 1) / float(STREAK_TICKS)
			var tail: Vector2 = p - d.dir * STREAK_M * ci.ppm * (1.0 - k * 0.6)
			ci.draw_line(tail, p, SHANK, maxf(2.0, 0.05 * ci.ppm))
			ci.draw_line(tail, p, HEAD, maxf(1.0, 0.025 * ci.ppm))
		if age >= d.row.hitstop_ticks:  # driven in at a slant: the shank shows toward the gun
			var stub: Vector2 = p - d.dir * SHANK_M * ci.ppm
			ci.draw_line(p, stub, SHANK, maxf(2.5, 0.05 * ci.ppm))
			ci.draw_line(p, stub, HEAD, maxf(1.0, 0.02 * ci.ppm))
			ci.draw_circle(stub, maxf(2.5, 0.06 * ci.ppm), SHANK)
			ci.draw_circle(stub, maxf(1.5, 0.038 * ci.ppm), HEAD)


## The nails (layer px): on the wall both sleeves of the standing figure; on the street a foot
## and the far sleeve of the body lying back along the shot.
static func _nails(d: KillNewStyles.Death, ppm: float) -> PackedVector2Array:
	var h: float = d.height
	if d.wall_m >= 0.0:
		var arm: float = h * 0.62
		return PackedVector2Array(
			[d.xf * (d.feet + Vector2(-h * 0.24, -arm)), d.xf * (d.feet + Vector2(h * 0.24, -arm))]
		)
	var across: Vector2 = d.dir.orthogonal() * 0.22 * ppm
	return PackedVector2Array([d.feet_px + across * 0.4, d.feet_px + d.dir * h * 0.55 + across])
