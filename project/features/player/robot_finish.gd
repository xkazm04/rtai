class_name RobotFinish
extends RefCounted
## Direct electric contacts share one overload timer. Each source supplies its own tier tuning.

enum Effect { NORMAL, SHUTDOWN, OVERLOAD, HEAVY }

const BOLT_TABLE: String = "res://data/tables/robot_finishers.json"
const BOLT_SCHEMA: String = "gtai.robot_finishers/1"

static var _bolt: RobotFinish

var id: StringName
var electric: bool = false
var machine_stun_ticks: int = 0
var heavy_stun_ticks: int = 0
var never_finish: Array[StringName] = []
var charged_only: bool = false


static func from_row(t: DataTable, row: Dictionary) -> RobotFinish:
	var source: RobotFinish = RobotFinish.new()
	source.id = StringName(t.text(row, "id"))
	source.machine_stun_ticks = t.integer(row, "machine_stun_ticks")
	source.heavy_stun_ticks = t.integer(row, "heavy_stun_ticks")
	for enemy: String in t.array(row, "never_finish"):
		source.never_finish.append(StringName(enemy))
	source.charged_only = row.get("charged_only", false) == true
	source.electric = t.ok()
	if not source.electric:
		Log.error("robot_finish", str(t.errors()))
	return source


static func direct_bolt(arena: CombatArena, shot: Shot, target: Fighter) -> bool:
	if shot.spec.id != &"electro_gun":
		return false
	if _bolt == null:
		var t: DataTable = DataTable.open(BOLT_TABLE, BOLT_SCHEMA)
		_bolt = from_row(t, t.object(t.raw, "electro_gun"))
	if _bolt.charged_only and not shot.charged:
		return false
	var mode: Effect = _bolt.contact(arena, target)
	if mode == Effect.NORMAL:
		return false
	var dir: Vector2 = shot.vel.normalized()
	arena.hit_dir = dir
	arena.hit_at = target.pos - dir * target.radius_m
	_bolt.apply(arena, target, shot.shooter_id, shot.damage, mode)
	arena.struck.emit(target, dir, not target.alive(), shot.spec.id)
	return true


func effect(arch: EnemyRoster.Archetype, ready: bool) -> Effect:
	if not electric or arch == null or arch.body != &"robot":
		return Effect.NORMAL
	if never_finish.has(arch.id):
		return Effect.HEAVY
	if arch.machine and not ready:
		return Effect.OVERLOAD
	return Effect.SHUTDOWN


func contact(arena: CombatArena, target: Fighter) -> Effect:
	if (
		not electric
		or target == arena.boss
		or target.brain_owned
		or target.kind != Fighter.Kind.GUARD
	):
		return Effect.NORMAL
	return effect(MeleeLethal.archetype(target.archetype), MeleeShutdown.primed(target, arena.tick))


func apply(arena: CombatArena, target: Fighter, killer: int, amount: float, mode: Effect) -> void:
	match mode:
		Effect.SHUTDOWN:
			target.set_meta(KillEvent.SHUTDOWN, true)
			arena.damage(target, target.hp, killer, id, MeleeLethal.FINISH)
			target.remove_meta(KillEvent.SHUTDOWN)
		Effect.OVERLOAD:
			target.set_meta(MeleeShutdown.PRIMED, arena.tick + machine_stun_ticks)
			_hold(arena, target, machine_stun_ticks)
		Effect.HEAVY:
			arena.damage(target, amount, killer, id)
			if target.alive():
				_hold(arena, target, heavy_stun_ticks)


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
