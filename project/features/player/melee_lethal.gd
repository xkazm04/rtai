class_name MeleeLethal
extends RefCounted
## Weapon contact resolves before the arena announces a death. The pit accepts the same swing
## on hurt(); its ordinary three-argument projectile calls retain their directional armour.

enum Contact { NORMAL, BLOCKED, GRIND, LETHAL }

const FINISH: StringName = &"melee_finish"
const BLOCK: StringName = &"melee_shield_block"
const OPEN_UNTIL: StringName = &"melee_shield_open_until"

static var _roster: EnemyRoster


static func human(f: Fighter) -> bool:
	if f.kind != Fighter.Kind.GUARD or f.brain_owned or f.machine:
		return false
	if f.body_class != &"" and f.body_class != &"human":
		return false
	if f.archetype == &"":
		return true
	var arch: EnemyRoster.Archetype = _arch(f.archetype)
	return arch == null or _eligible(arch)


static func _arch(id: StringName) -> EnemyRoster.Archetype:
	if _roster == null:
		_roster = EnemyRoster.shipped(EnemyRoster.TABLE, true)
	return _roster.archetype(id)


static func _eligible(arch: EnemyRoster.Archetype) -> bool:
	return arch.body == &"human" and arch.id != &"sergeant_mulroney"


static func shield_open(body: Object, now: int) -> bool:
	var until: int = body.get_meta(OPEN_UNTIL, -1)
	return now < until


static func _blocks(
	body: Object, arch: EnemyRoster.Archetype, bearing: float, now: int, table: MeleeTable
) -> bool:
	if arch == null or arch.shield_front_mult >= 1.0 or bearing <= arch.shield_cos:
		return false
	if table.vs_shield != &"blocked" or shield_open(body, now):
		return false
	body.set_meta(OPEN_UNTIL, now + table.shield_break_ticks)
	return true


static func contact(
	f: Fighter, boss: Fighter, combo: MeleeCombo, dir: Vector2, now: int
) -> Contact:
	if not combo.table.kills_human or f == boss or not human(f):
		return Contact.NORMAL
	var arch: EnemyRoster.Archetype = _arch(f.archetype)
	if _blocks(f, arch, f.facing.dot(-dir), now, combo.table):
		return Contact.BLOCKED
	return Contact.GRIND if combo.current().grind_ticks > 0 else Contact.LETHAL


static func pit_damage(
	e: EnemyAgent, dmg: float, dir: Vector2, now: int, swing: MeleeCombo
) -> float:
	var bearing: float = e.facing.dot(-dir.normalized())
	if (
		swing == null
		or swing.current() == null
		or not swing.table.kills_human
		or not _eligible(e.arch)
	):
		return dmg * e.arch.shield_front_mult if bearing > e.arch.shield_cos else dmg
	if _blocks(e, e.arch, bearing, now, swing.table):
		e.pos += dir.normalized() * swing.current().knockback_m
		return 0.0
	var hit: MeleeHit = swing.current()
	if hit.grind_ticks > 0 and swing.ground < hit.grind_min_ticks:
		return 0.0
	return e.hp
