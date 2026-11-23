class_name MeleeShutdown
extends RefCounted
## An overload is armed by direct electric contact. Ordinary gun stun and secondary arcs
## cannot prime an execute. Roster.machine distinguishes heavy frames from light robots.

const PRIMED: StringName = &"melee_overload_until"
const HEAVY_UNTIL: StringName = &"melee_heavy_stun_until"


static func primed(body: Object, tick: int) -> bool:
	var until: int = body.get_meta(PRIMED, -1)
	return tick < until


static func land(arena: CombatArena, target: Fighter, combo: MeleeCombo) -> bool:
	var table: MeleeTable = combo.table
	var mode: RobotFinish.Effect = table.contact(arena, target)
	if mode == RobotFinish.Effect.NORMAL:
		return false
	if _first_contact(combo, target):
		table.apply(arena, target, arena.rivet.id, combo.current().damage, mode)
	return true


static func pit_damage(
	pit: EnemyPit, e: EnemyAgent, damage: float, dir: Vector2, combo: MeleeCombo
) -> float:
	if combo == null or combo.current() == null:
		return MeleeLethal.pit_damage(e, damage, dir, pit.tick, combo)
	var table: MeleeTable = combo.table
	var mode: RobotFinish.Effect = table.effect(e.arch, primed(e, pit.tick))
	if mode != RobotFinish.Effect.NORMAL and not _first_contact(combo, e):
		return 0.0
	match mode:
		RobotFinish.Effect.SHUTDOWN:
			return e.hp
		RobotFinish.Effect.OVERLOAD:
			e.set_meta(PRIMED, pit.tick + table.machine_stun_ticks)
			pit.stun(e, table.machine_stun_ticks)
			e.vel = Vector2.ZERO
			return 0.0
		RobotFinish.Effect.HEAVY:
			e.set_meta(HEAVY_UNTIL, pit.tick + table.heavy_stun_ticks)
			pit.stun(e, table.heavy_stun_ticks)
			e.vel = Vector2.ZERO
	return MeleeLethal.pit_damage(e, damage, dir, pit.tick, combo)


## hurt() applies an archetype's ordinary flinch after damage. An electric lock already set
## on this contact takes precedence over that flinch (notably the turret's shorter stagger).
static func holding_pit(e: EnemyAgent, tick: int) -> bool:
	var until: int = e.get_meta(HEAVY_UNTIL, -1)
	return tick < until or primed(e, tick)


static func _first_contact(combo: MeleeCombo, body: Object) -> bool:
	if combo.electric_hits.has(body):
		return false
	combo.electric_hits[body] = true
	return true
