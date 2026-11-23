class_name KillSlashStreak
extends RefCounted
## The blade's path on a split kill (KillSplitFx): a cream slash edged in ink along the cut that
## runs on with the blade and thins out over KillSplitFx.STREAK_TICKS. Length and width come from
## the row (streak_m, streak_w_m; n16 kills-polish, owner n15 verdict "shorter and thinner").
## Render only, no RNG.

## The default length and width (m): the n12 look, kept by a row with no streak keys.
const LENGTH_M: float = SignatureKill.DEFAULT_STREAK_M
const WIDTH_M: float = SignatureKill.DEFAULT_WIDTH_M
## The ink rim's extra width (px) at the default width; it scales with the row's width.
const RIM_PX: float = 3.0
const INK: Color = Color(0.07, 0.06, 0.07)
const CREAM: Color = Color(0.96, 0.92, 0.8)


## Draws streak `s` (at.x, at.y in m, cut angle, kill tick) of `size` (length, width in m) on `ci`.
static func draw(ci: CanvasItem, s: Vector4, size: Vector2, tick: int, ppm: float) -> void:
	var age: int = tick - int(s.w)
	if age < 0 or age > KillSplitFx.STREAK_TICKS:
		return
	var k: float = 1.0 - float(age) / float(KillSplitFx.STREAK_TICKS)
	var c: Vector2 = Vector2.from_angle(s.z)
	var mid: Vector2 = Vector2(s.x, s.y) * ppm
	var half: float = size.x * 0.5 * ppm
	var lead: Vector2 = c * half * (0.6 + 0.4 * (1.0 - k))  # the streak runs on with the blade
	var w: float = size.y * ppm * k
	ci.draw_line(mid - c * half, mid + lead, INK, w + RIM_PX * size.y / WIDTH_M, true)
	ci.draw_line(mid - c * half * 0.8, mid + lead * 0.95, CREAM, w, true)
