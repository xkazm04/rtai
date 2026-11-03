class_name AimReadout
extends RefCounted
## What the HUD draws so range reads at a glance (brief item 3): the aim line from the muzzle
## toward the aim point, ending at the weapon's range_m; the reticle at the aim point, its radius
## the live spread cone at that distance (it opens with bloom and closes as it recovers); and
## whether the aim point is beyond the weapon's reach (the HUD dims the reticle). Metres.

## Smallest reticle radius, so a zero-spread weapon still shows a ring.
const MIN_RADIUS_M: float = 0.15

var line_from: Vector2 = Vector2.ZERO
var line_to: Vector2 = Vector2.ZERO
var reticle_at: Vector2 = Vector2.ZERO
var reticle_radius_m: float = MIN_RADIUS_M
var in_range: bool = true


static func of(trigger: Trigger, muzzle: Vector2, aim_point: Vector2) -> AimReadout:
	var r: AimReadout = AimReadout.new()
	var to_aim: Vector2 = aim_point - muzzle
	var dist: float = to_aim.length()
	var reach: float = trigger.spec.range_m
	r.line_from = muzzle
	r.reticle_at = aim_point
	r.in_range = dist <= reach
	r.line_to = muzzle + to_aim.normalized() * minf(dist, reach) if dist > 0.0 else muzzle
	r.reticle_radius_m = maxf(tan(trigger.cone_rad()) * minf(dist, reach), MIN_RADIUS_M)
	return r
