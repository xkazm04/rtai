class_name CitySimClips
extends RefCounted
## Which animation clip and frame a person shows (render only, never sim state). Clips per
## variant: 0 idle, 1 walk, 2 flee/run, 3 hit, 4 death, 5 shoot.

const IDLE: int = 0
const WALK: int = 1
const RUN: int = 2
const DEATH: int = 4
const SHOOT: int = 5


static func clip_of(s: CitySimState, i: int) -> int:
	var m: int = s.mode[i]
	var k: int = s.kind[i]
	if m == SimConst.M_DEAD:
		return DEATH
	if k == SimConst.K_COP and s.t1[i] > 0.0:
		return SHOOT
	if s.v[i] < 0.2:
		return IDLE
	if m == SimConst.M_FLEE or m == SimConst.M_RIOT or k == SimConst.K_COP or s.v[i] > 3.0:
		return RUN
	return WALK


## clip = (frame count, fps) of the chosen clip.
static func frame_of(s: CitySimState, i: int, cl: int, clip: Vector2i) -> int:
	var cnt: int = clip.x
	if cl == DEATH:
		return mini(int(s.t2[i] * clip.y), cnt - 1)
	if cl == SHOOT:
		return mini(int((0.25 - s.t1[i]) * 24.0), cnt - 1)
	if cl == IDLE:
		return int((s.time + i * 0.37) * clip.y) % cnt
	if cl == RUN:
		return int(s.phase[i] / 2.585 * cnt) % cnt
	return int(s.phase[i] / 1.869 * cnt) % cnt
