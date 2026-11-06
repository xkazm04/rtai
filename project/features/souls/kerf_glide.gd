class_name KerfGlide
extends RefCounted
## n7-melee, view only: the camera's whip after a Kerf blink. The sim moves Rivet the whole blink
## in one tick, so a camera nailed to him jumped 4-10 m (130-320 px at 32 px/m) on every cut and a
## chain read as cuts in three different rooms. Each live blink instead leaves the camera an offset
## of (from - to) that eases out over cam_glide_s (cubic: most of the travel in the first third),
## summed over the chain so a second blink mid-glide carries on from where the camera is. Stepped
## on the stage tick (a hit-stop holds it on the cut, then the camera travels). Writes nothing to
## the sim. cam_glide_s 0 or `--kerf-glide=off` = the snap (the before).

## A blink shorter than this (m) leaves no glide (no jump worth following).
const MIN_JUMP_M: float = 1.0


## The camera's offset from Rivet (m) on stage tick `tick` for Kerf's live blinks.
static func offset_m(k: KerfStage, tick: int) -> Vector2:
	if k == null or not enabled():
		return Vector2.ZERO
	var span: float = k.num(&"cam_glide_s") / SimClock.TICK_DT
	if span <= 0.0:
		return Vector2.ZERO
	var out: Vector2 = Vector2.ZERO
	for i: int in k.trail_tick.size():
		var age: float = tick - k.trail_tick[i]
		if age < 0.0 or age >= span:
			continue
		var jump: Vector2 = k.trail_from[i] - k.trail_to[i]
		if jump.length() < MIN_JUMP_M:
			continue
		out += jump * residual(age / span)
	return out


## How much of a blink the camera still has to travel at fraction `t` of the glide (1 -> 0).
static func residual(t: float) -> float:
	var r: float = 1.0 - clampf(t, 0.0, 1.0)
	return r * r * r


static func enabled() -> bool:
	return not OS.get_cmdline_user_args().has("--kerf-glide=off")
