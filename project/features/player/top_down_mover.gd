class_name TopDownMover
extends RefCounted
## Top-down movement feel on the fixed tick: the velocity accelerates toward stick * top speed
## (it brakes harder than it accelerates), the facing turns toward the aim (or the walk) at a
## capped rate, and moving away from the facing (strafing, backpedalling) is a little slower.

var velocity: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.DOWN


## The displacement for one tick; `aim` Vector2.ZERO faces the walk direction.
func step(stick: Vector2, aim: Vector2, top_mps: float, actions: PlayerActions) -> Vector2:
	var dt: float = SimClock.TICK_DT
	var push: Vector2 = stick.limit_length(1.0)
	var want_face: Vector2 = aim if aim != Vector2.ZERO else push.normalized()
	if want_face != Vector2.ZERO:
		var turn: float = deg_to_rad(actions.turn_dps) * dt
		facing = facing.rotated(clampf(facing.angle_to(want_face), -turn, turn)).normalized()
	var away: float = 1.0 - maxf(push.normalized().dot(facing), 0.0)
	var speed: float = top_mps * lerpf(1.0, actions.strafe_scale, away)
	var rate: float = actions.accel_mps2 if push != Vector2.ZERO else actions.brake_mps2
	velocity = velocity.move_toward(push * speed, rate * dt)
	return velocity * dt


func stop() -> void:
	velocity = Vector2.ZERO


func write_state(out: StreamPeerBuffer) -> void:
	out.put_float(velocity.x)
	out.put_float(velocity.y)
	out.put_float(facing.x)
	out.put_float(facing.y)
