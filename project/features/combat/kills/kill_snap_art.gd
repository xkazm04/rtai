class_name KillSnapArt
extends RefCounted
## The pistol death's overlay (lane kills-new, style `snap`), render only: the exit spray out of the
## back of the head as the head snaps back - a jet of red drops along the shot and a mist puff that
## grows and thins over `mist_ticks` (row fx). The fan on the street is the row's own spray mark
## (KillMarks); this is the spray in the air, the beat that reads at 32 px/m. Red is blood only.

const BLOOD: Color = KillMarkArt.BLOOD
const BLOOD_DARK: Color = KillMarkArt.BLOOD_DARK


static func draw(ci: KillNewStyles, d: KillNewStyles.Death, age: int) -> void:
	var ticks: int = roundi(d.extra.num("mist_ticks", 6))
	var a: int = age - d.row.hitstop_ticks
	if age < 0 or a >= ticks:
		return
	var k: float = clampf(float(maxi(a, 0) + 1) / float(ticks), 0.0, 1.0)
	var reach: float = d.extra.num("mist_m", 0.55) * ci.ppm
	var drops: int = roundi(d.extra.num("drops", 7))
	var from: Vector2 = d.head_px
	var fade: float = 1.0 - k * k
	var mist: Color = Color(BLOOD, 0.6 * fade)
	ci.draw_circle(from + d.dir * reach * 0.35 * k, reach * (0.22 + 0.3 * k), mist)
	for n: int in drops:
		var spread: float = (KillNewStyles.h(d.serial, n) - 0.5) * 0.7
		var run: float = reach * (0.25 + 0.75 * KillNewStyles.h(d.serial, n + 40)) * k
		var at: Vector2 = from + d.dir.rotated(spread) * run
		var r: float = maxf(1.5, ci.ppm * (0.05 + 0.05 * KillNewStyles.h(d.serial, n + 80)))
		r *= 1.2 - 0.4 * k
		ci.draw_circle(at, r + 1.0, BLOOD_DARK)
		ci.draw_circle(at, r, BLOOD)
