class_name GhostN31Strike
extends GhostDeployStrike
## n31 measure (dev only): the real strike, logging every Tonnage release (hits, kills, ticks
## from the press). With a what-if `geometry` Tonnage's footprint is GhostN31Geometry instead;
## charge_ticks > 0 holds the hits until that many ticks after the press (foes where they are then).

var geometry: GhostN31Geometry
var charge_ticks: int = 0
## Set by the caller on the tick the deploy key goes down (the ghost enters AIMING).
var press_tick: int = -1
var press_rivet: Vector2 = Vector2.ZERO
var deploys: Array[Dictionary] = []
var _contacts: int = 0
var _pending: Dictionary = {}


func land(stage: CollectCallStage, ghost: GhostDeploy) -> void:
	_contacts = 0
	super.land(stage, ghost)
	if ghost.form == HaulerStage.GHOST and _pending.is_empty():
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


func _record(tick: int) -> void:
	var held: int = tick - press_tick if press_tick >= 0 else -1
	deploys.append(
		{"tick": tick, "press_to_damage_ticks": held, "hits": _contacts, "kills": release_kills}
	)
