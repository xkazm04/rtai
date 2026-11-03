class_name RigSprings
extends RefCounted
## The rig's three critically damped springs (facing, shove, twist), semi-implicit Euler. A step
## longer than MAX_H runs as equal sub-steps: the quarter-rate LOD poses every 4th tick, and at
## 4 ticks per step the facing spring (k 260) is unstable. Full and half rate keep one step.

const TWIST_K: float = 90.0
const SHOVE_K: float = 120.0
## Two ticks: the half-rate LOD step, the longest step all three springs were tuned at.
const MAX_H: float = 2.0 * SimClock.TICK_DT + 0.0001


static func step(rig: CutRig, dt: float) -> void:
	var n: int = maxi(1, ceili(dt / MAX_H))
	var h: float = dt / float(n)
	for _k: int in n:
		if not rig.dead:
			var dfa: float = wrapf(rig.face_to - rig.facing, -PI, PI)
			rig.face_w += (rig.turn_k * dfa - 2.0 * sqrt(rig.turn_k) * rig.face_w) * h
			rig.facing += rig.face_w * h
		rig.shove_v += (-SHOVE_K * rig.shove - 2.0 * sqrt(SHOVE_K) * rig.shove_v) * h
		rig.shove += rig.shove_v * h
		rig.twist_v += (-TWIST_K * rig.twist - 2.0 * sqrt(TWIST_K) * rig.twist_v) * h
		rig.twist += rig.twist_v * h
