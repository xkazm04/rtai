class_name ReelVictim
extends RefCounted
## rivet-motion: one human in the reel (a ped in the sprint lane, a patrolling cop). The body
## reaction the reel drives on its rig: a shove on each claw hit, a knockback slide (decaying
## each tick) with a knockdown that gets up after `down` ticks, or death (the sprawl; the body
## stays down). Render only, stepped on the 60 Hz tick (never a frame delta).

const SLIDE_DECAY: float = 0.82

var rig: CutRig = CutRig.new()
var dead: bool = false
var down: int = 0
## Patrol: the cop walks between `a` and `b` (metres) until `alert`, then faces `look_at`.
var patrol_a: Vector2 = Vector2.ZERO
var patrol_b: Vector2 = Vector2.ZERO
var patrol_mps: float = 0.0
var alert: bool = false
var look_at: Vector2 = Vector2.ZERO
var _px: float = 32.0
var _slide: Vector2 = Vector2.ZERO
var _to_b: bool = true


func _init(plan: BodyPlan, look: RigVariant, at_m: Vector2, facing: float, px: float) -> void:
	_px = px
	rig.setup(plan, look)
	rig.position = at_m * px
	rig.snap_facing(facing)
	rig.face_to = facing
	patrol_a = at_m
	patrol_b = at_m


func pos_m() -> Vector2:
	return rig.position / _px


## A blow along `dir` (unit, world): shoves the rig; slides `metres` over about 10 ticks and, if
## `down_ticks` > 0, knocks it down for that long.
func knock(dir: Vector2, metres: float, down_ticks: int) -> void:
	rig.clips.hit(rig, dir)
	if metres > 0.0:
		_slide = dir * metres * (1.0 - SLIDE_DECAY) * _px
	down = maxi(down, down_ticks)


func kill(dir: Vector2, metres: float) -> void:
	knock(dir, metres, 0)
	dead = true
	rig.clips.die(false)


func step(dt: float, flash: bool) -> void:
	var vel: Vector2 = Vector2.ZERO
	if _slide != Vector2.ZERO:
		rig.position += _slide
		_slide *= SLIDE_DECAY
		if _slide.length() < 0.2:
			_slide = Vector2.ZERO
	elif not dead and down == 0:
		vel = _patrol_vel()
	rig.position += vel * dt * _px
	down = maxi(down - 1, 0)
	rig.clips.down = down > 0
	rig.vel_in = vel * _px
	if alert and not dead:
		rig.face_to = (look_at - pos_m()).angle()
	elif vel != Vector2.ZERO:
		rig.face_to = vel.angle()
	rig.drive(dt)
	if not flash:  # the shared vermilion hit flash breaks "red is blood only" (REQUEST 1 -> gunplay)
		rig.set_tint(false)


func _patrol_vel() -> Vector2:
	if alert or patrol_mps <= 0.0:
		return Vector2.ZERO
	var goal: Vector2 = patrol_b if _to_b else patrol_a
	if pos_m().distance_to(goal) < 0.1:
		_to_b = not _to_b
		goal = patrol_b if _to_b else patrol_a
	return (goal - pos_m()).normalized() * patrol_mps
