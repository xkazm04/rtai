class_name GhostN31Strike
extends GhostDeployStrike
## n31 measure (dev only): the real strike, logging every Tonnage release (hits, kills, ticks
## from the press). With a what-if `geometry` Tonnage's footprint is GhostN31Geometry instead;
## charge_ticks > 0 holds the hits until that many ticks after the press (foes where they are then).

const NEAR_M: float = 9.0

var geometry: GhostN31Geometry
## The ghost form this strike measures (Tonnage unless --form says otherwise).
var form: StringName = HaulerStage.GHOST
var charge_ticks: int = 0
## Set by the caller on the tick the deploy key goes down (the ghost enters AIMING).
var press_tick: int = -1
var press_rivet: Vector2 = Vector2.ZERO
var deploys: Array[Dictionary] = []
## Kerf cause log: victim id -> {weapon, tick} of its death (watch() connects the arena).
var deaths: Dictionary = {}
var _contacts: int = 0
var _near: int = 0
var _pending: Dictionary = {}
var _why: Dictionary = {}


## Log every kill's weapon and tick, so a broken Kerf lock can name who killed the target.
func watch(arena: CombatArena) -> void:
	var log_death: Callable = func(
		victim: Fighter, weapon: StringName, _d: Vector2, _a: Vector2, _k: StringName
	) -> void:
		deaths[victim.id] = {"weapon": weapon, "tick": arena.tick}
	@warning_ignore("return_value_discarded")
	arena.kill_landed.connect(log_death)


func land(stage: CollectCallStage, ghost: GhostDeploy) -> void:
	_contacts = 0
	_near = _count_near(stage, ghost) if ghost.form == form else 0
	super.land(stage, ghost)
	_why = _reason(stage, ghost)
	if ghost.form == form and _pending.is_empty():
		_record(stage.tick)


func _tonnage(stage: CollectCallStage, ghost: GhostDeploy) -> void:
	if geometry == null:
		super._tonnage(stage, ghost)
		return
	var at: Vector2 = geometry.centre(ghost.spot, press_rivet)
	if charge_ticks > 0:
		var due: int = maxi(stage.tick, press_tick + charge_ticks)
		_pending = {"due": due, "at": at, "facing": ghost.facing}
		return
	_press(stage.arena, at, ghost.facing, stage.tick)


## Play mode calls this after every step: a held what-if charge lands when it is due.
func resolve_due(stage: CollectCallStage) -> void:
	if _pending.is_empty() or stage.tick < _pending.due:
		return
	_contacts = 0
	release_kills = 0
	var at: Vector2 = _pending.at
	var facing: Vector2 = _pending.facing
	_pending.clear()
	_press(stage.arena, at, facing, stage.tick)
	_record(stage.tick)


func _press(arena: CombatArena, at: Vector2, facing: Vector2, tick: int) -> void:
	var squad: ArenaSquad = arena.squad_ai
	for foe: Fighter in arena.hostiles:
		if not foe.alive() or not geometry.hits(at, facing, foe.pos, foe.radius_m):
			continue
		if foe.archetype == &"war_machine" and squad != null and squad.owns(foe):
			TonnageCrack.open(arena, squad.mind_for(foe), tick)
		var dir: Vector2 = (foe.pos - at).normalized()
		if dir == Vector2.ZERO:
			dir = facing
		_hit(arena, foe, dir, press.num(&"stomp_damage"), &"deploy_tonnage")


func _hit(
	arena: CombatArena, foe: Fighter, dir: Vector2, damage: float, weapon: StringName
) -> void:
	_contacts += 1
	super._hit(arena, foe, dir, damage, weapon)


## Live foes within NEAR_M of the spot at the release tick: the group the deploy could have hit.
func _count_near(stage: CollectCallStage, ghost: GhostDeploy) -> int:
	var n: int = 0
	for foe: Fighter in stage.arena.hostiles:
		n += int(foe.alive() and ghost.spot.distance_to(foe.pos) <= NEAR_M)
	return n


## Kerf only: why the lock broke (KerfDrop.broke), relocked or not, who killed it, how far.
func _reason(stage: CollectCallStage, ghost: GhostDeploy) -> Dictionary:
	var lock: KerfDrop = ghost.dump.kerf
	if ghost.form != KerfStage.GHOST or lock.broke == &"":
		return {}
	var out: Dictionary = {"whiff_reason": lock.broke, "relocked": lock.relocked}
	var foe: Fighter = lock.lost
	out.dist_m = stage.arena.rivet.pos.distance_to(foe.pos)
	if deaths.has(foe.id):
		out.killed_by = deaths[foe.id].weapon
		out.killed_tick = deaths[foe.id].tick
		out.cut_tick = stage.tick
	if not lock.relocked:
		out.miss = _relock_miss(stage, ghost)
	return out


## A relock that found nobody: live foes within range_m of Rivet, of them with a clear line,
## of those inside the cone of the press's aim, and the clear ones' smallest angle off it.
func _relock_miss(stage: CollectCallStage, ghost: GhostDeploy) -> Dictionary:
	var range_m: float = ghost.strike.attacks.deploy[KerfStage.GHOST].range_m
	var cone: float = ghost.strike.attacks.num(KerfStage.GHOST, &"cone_deg")
	var from: Vector2 = stage.arena.rivet.pos
	var out: Dictionary = {"in_range": 0, "clear": 0, "in_cone": 0, "min_off_deg": -1.0}
	for foe: Fighter in stage.arena.hostiles:
		var to: Vector2 = foe.pos - from
		if not foe.alive() or to.length() > range_m:
			continue
		out.in_range += 1
		if not GhostDeploySpot.clear(stage, from, foe.pos):
			continue
		out.clear += 1
		var off: float = absf(rad_to_deg(ghost.dump.kerf.aim.angle_to(to)))
		out.in_cone += int(off <= cone)
		if out.min_off_deg < 0.0 or off < out.min_off_deg:
			out.min_off_deg = off
	return out


func _record(tick: int) -> void:
	var held: int = tick - press_tick if press_tick >= 0 else -1
	deploys.append(
		{
			"tick": tick,
			"press_to_damage_ticks": held,
			"hits": _contacts,
			"kills": release_kills,
			"near": _near,
			"why": _why
		}
	)
	_why = {}
