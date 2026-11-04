class_name PlayerDeflect
extends RefCounted
## rivet-arsenal: the plasma sword's timed deflect. During a deflecting weapon's active ticks
## (MeleeTable.deflect_m > 0), every hostile round within deflect_m of Rivet and in front of him
## goes back: it flies at its shooter (or straight back if the shooter is gone) at its own speed,
## now Rivet's round (it hits hostiles, BACK_DAMAGE: a human drops) with a fresh range. Each bat
## leaves a spark (two short crossing arcs on FightAreas' VFX list, as the shock's crackle; view
## only, not replay state) where the blade met the round.

const BACK_DAMAGE: float = 1.0
const BACK_RANGE_M: float = 20.0
## In front: the round's offset from Rivet within this of his facing (dot).
const FRONT_DOT: float = 0.0
const SPARK_M: float = 0.45


## Bats every hostile round in reach back; returns how many.
static func bat(arena: CombatArena, facing: Vector2, reach_m: float) -> int:
	var at: Vector2 = arena.rivet.pos
	var n: int = 0
	for s: Shot in arena.shots:
		var to: Vector2 = s.pos - at
		if s.from_rivet or to.length() > reach_m:
			continue
		if to.length() > 0.001 and to.normalized().dot(facing) < FRONT_DOT:
			continue
		var speed: float = s.vel.length()
		var back: Vector2 = -s.vel.normalized() if speed > 0.0 else facing
		var shooter: Fighter = _fighter(arena, s.shooter_id)
		if shooter != null and shooter.alive():
			back = (shooter.pos - s.pos).normalized()
		s.vel = back * speed
		s.from_rivet = true
		s.shooter_id = arena.rivet.id
		s.damage = BACK_DAMAGE
		s.left_m = BACK_RANGE_M
		s.origin = s.pos
		_spark(arena, s.pos, back)
		n += 1
	return n


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
