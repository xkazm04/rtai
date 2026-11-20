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
	steer(e, desired + _separation(e, agents, pit), look_at, pit)


static func steer(e: EnemyAgent, want: Vector2, look_at: Vector2, pit: EnemyPit) -> void:
	var arch: EnemyRoster.Archetype = e.arch
	if arch.speed_mps == 0.0:
		e.vel = Vector2.ZERO
		turn_toward(e, look_at - e.pos)
		return
	var top: float = arch.speed_mps * (1.6 if e.state == EnemyAgent.State.PANIC else 1.0)
	want = want.limit_length(top)
	e.vel = e.vel.move_toward(want, arch.accel_mps2 * SimClock.TICK_DT)
	var pos: Vector2 = e.pos + e.vel * SimClock.TICK_DT
	if not pit.cover.is_empty():
		pos = EnemySenses.push_out(pos, e.radius(), pit.cover)
	e.pos = pos.clamp(pit.bounds.position, pit.bounds.end)
	var face: Vector2 = look_at - e.pos
	if e.state == EnemyAgent.State.PANIC or e.state == EnemyAgent.State.PATROL:
		face = e.vel if e.vel.length() > 0.3 else e.facing
	turn_toward(e, face)


## A committed dash at `v` (the melee lunge): no easing, no steering, still stopped by cover.
static func dash(e: EnemyAgent, v: Vector2, pit: EnemyPit) -> void:
	e.vel = v
	e.pos += v * SimClock.TICK_DT
	e.pos = EnemySenses.push_out(e.pos, e.radius(), pit.cover)
	e.pos = e.pos.clamp(pit.bounds.position, pit.bounds.end)


static func turn_toward(e: EnemyAgent, dir: Vector2) -> void:
	if dir.length() < 0.001:
		return
	var delta: float = e.facing.angle_to(dir)
	var step: float = clampf(delta, -e.arch.turn_rad_per_tick, e.arch.turn_rad_per_tick)
	e.facing = e.facing.rotated(step).normalized()


## Steer toward `to`, easing to a stop inside `stop_m` (arrival, so nobody overshoots and jitters).
static func arrive(e: EnemyAgent, to: Vector2, speed: float, stop_m: float = 0.25) -> Vector2:
	var cover: Array[Rect2] = e.cover_ref
	if not cover.is_empty():
		var via: Vector2 = EnemySenses.detour(e.pos, to, e.radius(), cover)
		if via != to:
			return (via - e.pos).normalized() * speed
	var d: Vector2 = to - e.pos
	var dist: float = d.length()
	if dist <= stop_m:
		return Vector2.ZERO
	var slow: float = clampf(dist / 1.5, 0.25, 1.0)
	return d / dist * speed * slow


## The enemy pit uses its original body gap and overlap response.
static func _separation(e: EnemyAgent, agents: Array[EnemyAgent], pit: EnemyPit) -> Vector2:
	return separation(e, agents, pit)


static func separation(
	e: EnemyAgent,
	agents: Array[EnemyAgent],
	pit: EnemyPit,
	gap: float = SEPARATION_GAP_M,
	split_overlap: bool = false
) -> Vector2:
	var push: Vector2 = Vector2.ZERO
	var p: Vector2 = e.pos
	var radius: float = e.radius()
	# Reject distant bodies before reading their state and archetype or normalizing.
	# Round out the broad phase; the original length comparison decides contacts.
	var reach: float = radius + EnemyAgent.ROBOT_RADIUS_M + gap + 0.001
	var reach_sq: float = reach * reach
	for o: EnemyAgent in agents:
		var other: Vector2 = o.pos
		if p.distance_squared_to(other) > reach_sq or o == e:
			continue
		if o.state == EnemyAgent.State.DEAD or o.state == EnemyAgent.State.DOWN:
			continue
		var keep: float = radius + o.radius() + gap
		var side: float = 1.0 if e.id > o.id else -1.0
		push += repel(p, other, keep, side if split_overlap else 0.0)
	var keep_player: float = radius + pit.rivet_radius + gap
	push += repel(p, pit.rivet_pos, keep_player, e.strafe_sign if split_overlap else 0.0)
	return push * SEPARATION_GAIN


static func repel(p: Vector2, other: Vector2, keep: float, overlap_sign: float = 0.0) -> Vector2:
	if p == other:
		return Vector2.RIGHT * keep * overlap_sign
	var d: Vector2 = p - other
	var dist: float = d.length()
	if dist >= keep or dist < 0.0001:
		return Vector2.ZERO
	return d / dist * (keep - dist)
