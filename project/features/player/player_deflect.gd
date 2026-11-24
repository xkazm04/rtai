class_name PlayerDeflect
extends RefCounted
## The guard and the active plasma blade roll once per incoming basic round. A returned round
## keeps its speed, gets a fresh range and belongs to Rivet. Heavy rounds keep their exact return.

const PASSED: StringName = &"deflect_passed"
## View-side marker on a round Rivet turned back (never read by the sim): the muzzle flash of a
## rifle round drawn as Rivet's must not appear at the bat point (BareGunFx).
const TURNED: StringName = &"deflect_turned"
const BACK_DAMAGE: float = 1.0
const BACK_RANGE_M: float = 20.0
## In front: the round's offset from Rivet within this of his facing (dot).
const FRONT_DOT: float = 0.0
const SPARK_M: float = 0.45


## Returns the number of rounds actually turned during this active tick.
static func bat(arena: CombatArena, facing: Vector2, reach_m: float) -> int:
	var at: Vector2 = arena.rivet.pos
	var n: int = 0
	for s: Shot in arena.shots:
		var to: Vector2 = s.pos - at
		if s.from_rivet or to.length() > reach_m:
			continue
		if to.length() > 0.001 and to.normalized().dot(facing) < FRONT_DOT:
			continue
		if send_back(arena, s, facing):
			n += 1
	return n


static func send_back(
	arena: CombatArena, s: Shot, facing: Vector2, contact: Vector2 = Vector2.INF
) -> bool:
	if s.has_meta(PASSED):
		return false
	var turn: float = 0.0
	var size: StringName = (
		s.size if s.size_known or s.spec != null else EnemyRounds.size_of(s.weapon)
	)
	if size == Shot.SMALL and not EnemyRounds.is_blast(s):
		var rule: DeflectRule = DeflectRule.of(arena)
		if size in rule.basic_rounds:
			if rule.passes():
				s.set_meta(PASSED, true)
				rule.passed.emit(s.pos if contact == Vector2.INF else contact, s.vel.normalized())
				return false
			turn = rule.turn()
	if contact != Vector2.INF:
		s.pos = contact
	var speed: float = s.vel.length()
	var back: Vector2 = -s.vel.normalized() if speed > 0.0 else facing
	var shooter: Fighter = _fighter(arena, s.shooter_id)
	if shooter != null and shooter.alive():
		back = (shooter.pos - s.pos).normalized()
	back = back.rotated(turn)
	s.vel = back * speed
	s.from_rivet = true
	s.shooter_id = arena.rivet.id
	s.damage = BACK_DAMAGE
	s.left_m = BACK_RANGE_M
	s.origin = s.pos
	s.set_meta(TURNED, true)
	_spark(arena, s.pos, back)
	arena.deflected.emit(s.pos, back)
	return true


static func _spark(arena: CombatArena, at: Vector2, back: Vector2) -> void:
	var areas: FightAreas = PlayerShock.areas_of(arena)
	for turn: float in [0.6, -0.6]:
		var d: Vector2 = back.rotated(turn) * SPARK_M * 0.5
		areas.chain_arcs.append(PackedVector2Array([at - d, at + d]))
		areas.arc_ticks.append(arena.tick)


static func _fighter(arena: CombatArena, id: int) -> Fighter:
	for f: Fighter in arena.hostiles:
		if f.id == id:
			return f
	return null
