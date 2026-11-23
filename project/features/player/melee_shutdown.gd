class_name MeleeShutdown
extends RefCounted
## An overload is armed by direct electric contact. Ordinary gun stun and secondary arcs
## cannot prime an execute. Roster.machine distinguishes heavy frames from light robots.

enum Effect { NORMAL, SHUTDOWN, OVERLOAD, HEAVY }

const PRIMED: StringName = &"melee_overload_until"
const HEAVY_UNTIL: StringName = &"melee_heavy_stun_until"


static func primed(body: Object, tick: int) -> bool:
	var until: int = body.get_meta(PRIMED, -1)
	return tick < until


static func effect(arch: EnemyRoster.Archetype, table: MeleeTable, ready: bool) -> Effect:
	if not table.electric or arch == null or arch.body != &"robot":
		return Effect.NORMAL
	if table.never_finish.has(arch.id):
		return Effect.HEAVY
	if arch.machine and not ready:
		return Effect.OVERLOAD
	return Effect.SHUTDOWN


## True when the electric contact owns the entire hit, including stun and displacement.
static func land(arena: CombatArena, target: Fighter, combo: MeleeCombo) -> bool:
	var table: MeleeTable = combo.table
	if (
		not table.electric
		or target == arena.boss
		or target.brain_owned
		or target.kind != Fighter.Kind.GUARD
	):
		return false
	var arch: EnemyRoster.Archetype = MeleeLethal.archetype(target.archetype)
	var mode: Effect = effect(arch, table, primed(target, arena.tick))
	if mode != Effect.NORMAL and not _first_contact(combo, target):
		return true
	match mode:
		Effect.SHUTDOWN:
			target.set_meta(KillEvent.SHUTDOWN, true)
			arena.damage(target, target.hp, arena.rivet.id, table.id, MeleeLethal.FINISH)
			target.remove_meta(KillEvent.SHUTDOWN)
		Effect.OVERLOAD:
			target.set_meta(PRIMED, arena.tick + table.machine_stun_ticks)
			_hold(arena, target, table.machine_stun_ticks)
		Effect.HEAVY:
			arena.damage(target, combo.current().damage, arena.rivet.id, table.id)
			if target.alive():
				_hold(arena, target, table.heavy_stun_ticks)
		_:
			return false
	return true


static func _hold(arena: CombatArena, target: Fighter, ticks: int) -> void:
	PlayerShock.stun_on(PlayerShock.areas_of(arena), target, ticks)
	target.swing_left = 0
	target.tell_left = 0
	target.burst_left = 0
	var squad: ArenaSquad = arena.squad_ai
	if squad != null and squad.owns(target):
		var mind: SquadMind = squad.mind_for(target)
		mind.stun_until = maxi(mind.stun_until, arena.tick + ticks)
		mind.agent.token = false
		mind.agent.vel = Vector2.ZERO
		if mind.shield != null:
			mind.shield.lunge_left = 0
		if mind.turret != null:
			mind.turret.phase = FoeTurret.Phase.IDLE


static func pit_damage(
	pit: EnemyPit, e: EnemyAgent, damage: float, dir: Vector2, combo: MeleeCombo
) -> float:
	if combo == null or combo.current() == null:
		return MeleeLethal.pit_damage(e, damage, dir, pit.tick, combo)
	var table: MeleeTable = combo.table
	var mode: Effect = effect(e.arch, table, primed(e, pit.tick))
	if mode != Effect.NORMAL and not _first_contact(combo, e):
		return 0.0
	match mode:
		Effect.SHUTDOWN:
			return e.hp
		Effect.OVERLOAD:
			e.set_meta(PRIMED, pit.tick + table.machine_stun_ticks)
			pit.stun(e, table.machine_stun_ticks)
			e.vel = Vector2.ZERO
			return 0.0
		Effect.HEAVY:
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
