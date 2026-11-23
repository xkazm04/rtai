class_name PlayerMotionDash
extends RefCounted
## A committed ground burst. Cover and roll keep their own phases and damage windows.

var enabled: bool
var hold_sprints: bool
var distance_m: float
var ticks: int
var cooldown_ticks: int
var iframe_ticks: int
var cooldown: int = 0
var frame: int = -1
var direction: Vector2
var _next: int = 0


func configure(t: DataTable) -> void:
	var row: Dictionary = t.object(t.raw, "dash")
	enabled = row.get("enabled") == true
	hold_sprints = row.get("hold_sprints") == true
	distance_m = t.num(row, "distance_m")
	ticks = maxi(1, t.integer(row, "ticks"))
	cooldown_ticks = t.integer(row, "cooldown_ticks")
	iframe_ticks = t.integer(row, "iframe_ticks")


func rest_tick() -> bool:
	frame = -1
	if cooldown > 0:
		cooldown -= 1
		return false
	return enabled


func sprint_held(c: PlayerCommand, actions: PlayerActions) -> bool:
	return enabled and hold_sprints and c.is_held(actions, &"dash")


func start(motion: PlayerMotion, c: PlayerCommand) -> void:
	direction = c.move.normalized() if c.move != Vector2.ZERO else motion.heading(c.aim)
	motion.mover.facing = direction
	motion.phase = PlayerMotion.Phase.DASH
	motion.sprinting = false
	motion.dashes += 1
	_next = 0


func advance(motion: PlayerMotion, walk_mps: float) -> Vector2:
	frame = _next
	_next += 1
	# Successive differences of 1 - (1-u)^2 sum to exactly one.
	var ds: float = distance_m * (2 * (ticks - frame) - 1) / (ticks * ticks)
	motion.mover.velocity = direction * ds / SimClock.TICK_DT
	if _next == ticks:
		finish(motion)
		motion.mover.velocity = direction * walk_mps
	return direction * ds


func finish(motion: PlayerMotion) -> void:
	motion.phase = PlayerMotion.Phase.FREE
	cooldown = cooldown_ticks
	_next = 0


## Walk the burst in radius-sized pieces so a thin solid cannot eject Rivet to its far side.
## Leave movable contacts on their approach side for the stage's ordinary tackle resolver.
func clip_move(stage: CollectCallStage, motion: PlayerMotion, move: Vector2) -> Vector2:
	var start_pos: Vector2 = stage.arena.rivet.pos
	var pos: Vector2 = start_pos
	var pieces: int = maxi(1, ceili(move.length() / stage.arena.rivet.radius_m))
	var stride: Vector2 = move / pieces
	for i: int in pieces:
		var next: Vector2 = stage.collide_preview(pos + stride)
		var at_body: Vector2 = _body_limit(stage.arena, pos, next, move / SimClock.TICK_DT)
		pos = at_body
		if not at_body.is_equal_approx(next):
			break
	var actual: Vector2 = pos - start_pos
	if actual.dot(direction) < 0.5 * move.length():
		finish(motion)
		motion.mover.stop()
	return actual


func _body_limit(arena: CombatArena, pos: Vector2, next: Vector2, velocity: Vector2) -> Vector2:
	var table: BodyTable = ArenaBodies.table()
	for other: Fighter in arena.hostiles:
		if not other.alive():
			continue
		var contact: BodyContact = BodyContact.resolve(
			table, RivetBody.CLASS, ArenaBodies.class_of(other), [next, other.pos], velocity
		)
		if contact.result == &"blocked":
			next = contact.a_pos
		elif contact.result != &"" and (other.pos - next).dot(velocity) <= 0.0:
			# Preserve the incoming normal so the existing rule measures positive closing speed.
			return pos
	return next


func write_state(out: StreamPeerBuffer, count: int) -> void:
	out.put_32(count)
	out.put_32(_next)
	out.put_32(cooldown)
	out.put_float(direction.x)
	out.put_float(direction.y)
