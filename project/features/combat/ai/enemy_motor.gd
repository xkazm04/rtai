class_name EnemyMotor
extends RefCounted
## Movement for one enemy per tick: a desired velocity from the brain, plus separation from the
## other bodies, limited by the archetype's acceleration (no jitter: velocity eases, never snaps)
## and its turn rate (readable turns: a heavy robot swings round slowly). Then cover push-out.

const SEPARATION_GAP_M: float = 0.35
const SEPARATION_GAIN: float = 3.0


static func move(
	e: EnemyAgent, desired: Vector2, look_at: Vector2, agents: Array[EnemyAgent], pit: EnemyPit
) -> void:
	var want: Vector2 = desired + _separation(e, agents, pit)
	var top: float = e.arch.speed_mps * (1.6 if e.state == EnemyAgent.State.PANIC else 1.0)
	want = want.limit_length(top)
	e.vel = e.vel.move_toward(want, e.arch.accel_mps2 * SimClock.TICK_DT)
	e.pos += e.vel * SimClock.TICK_DT
	e.pos = EnemySenses.push_out(e.pos, e.radius(), pit.cover)
	e.pos = e.pos.clamp(pit.bounds.position, pit.bounds.end)
	var face: Vector2 = look_at - e.pos
	if e.state == EnemyAgent.State.PANIC or e.state == EnemyAgent.State.PATROL:
		face = e.vel if e.vel.length() > 0.3 else e.facing
	turn_toward(e, face)


static func turn_toward(e: EnemyAgent, dir: Vector2) -> void:
	if dir.length() < 0.001:
		return
	var delta: float = e.facing.angle_to(dir)
	var step: float = clampf(delta, -e.arch.turn_rad_per_tick, e.arch.turn_rad_per_tick)
	e.facing = e.facing.rotated(step).normalized()


## Steer toward `to`, easing to a stop inside `stop_m` (arrival, so nobody overshoots and jitters).
static func arrive(e: EnemyAgent, to: Vector2, speed: float, stop_m: float = 0.25) -> Vector2:
	var cover: Array[Rect2] = e.cover_ref
	var via: Vector2 = EnemySenses.detour(e.pos, to, e.radius(), cover)
	if via != to:
		return (via - e.pos).normalized() * speed
	var d: Vector2 = to - e.pos
	var dist: float = d.length()
	if dist <= stop_m:
		return Vector2.ZERO
	var slow: float = clampf(dist / 1.5, 0.25, 1.0)
	return d / dist * speed * slow


static func _separation(e: EnemyAgent, agents: Array[EnemyAgent], pit: EnemyPit) -> Vector2:
	var push: Vector2 = Vector2.ZERO
	for o: EnemyAgent in agents:
		if o == e or not o.alive() or o.state == EnemyAgent.State.DOWN:
			continue
		push += _repel(e.pos, o.pos, e.radius() + o.radius() + SEPARATION_GAP_M)
	push += _repel(e.pos, pit.rivet_pos, e.radius() + pit.rivet_radius + SEPARATION_GAP_M)
	return push * SEPARATION_GAIN


static func _repel(p: Vector2, other: Vector2, keep: float) -> Vector2:
	var d: Vector2 = p - other
	var dist: float = d.length()
	if dist >= keep or dist < 0.0001:
		return Vector2.ZERO
	return d / dist * (keep - dist)
