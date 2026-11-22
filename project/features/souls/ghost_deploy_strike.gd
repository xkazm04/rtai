class_name GhostDeployStrike
extends RefCounted
## Resolves one attack at release. All geometry belongs to the ghost. Rivet is the killer
## passed to CombatArena.damage, and the ghost never enters the arena's fighter list.

var attacks: GhostAttacks
var press: HaulerForm
## Wave statistics sample after combat, including the tick of a wave's last kill.
var release_tick: int = -1
var release_form: StringName = &""
var release_kills: int = 0
var _shorts: Dictionary[Fighter, int] = {}


func _init(p_attacks: GhostAttacks, p_press: HaulerForm) -> void:
	attacks = p_attacks
	press = p_press


func land(stage: CollectCallStage, ghost: GhostDeploy) -> void:
	release_tick = stage.tick
	release_form = ghost.form
	release_kills = 0
	match ghost.form:
		KerfStage.GHOST:
			_kerf(stage, ghost)
		OhmStage.GHOST:
			_ohm(stage, ghost)
		HaulerStage.GHOST:
			_tonnage(stage, ghost)
		DentStage.GHOST:
			_dent(stage, ghost)


func _kerf(stage: CollectCallStage, ghost: GhostDeploy) -> void:
	var foe: Fighter = GhostDeploySpot.kerf_target(stage, ghost.spot, ghost.facing, attacks)
	if foe == null:
		return
	var behind: float = attacks.num(ghost.form, &"behind_m")
	var rear: Vector2 = KerfBehind.rear_spot(stage, foe, behind, stage.arena.walls)
	if not rear.is_finite():
		return
	ghost.spot = rear
	ghost.origin = rear
	ghost.facing = rear.direction_to(foe.pos)
	var robot: bool = foe.machine or foe.kind == Fighter.Kind.BOSS
	var damage: float = attacks.num(ghost.form, &"robot_damage" if robot else &"human_damage")
	_hit(stage.arena, foe, ghost.facing, damage, &"deploy_kerf")


func _ohm(stage: CollectCallStage, ghost: GhostDeploy) -> void:
	var arena: CombatArena = stage.arena
	var radius: float = attacks.deploy[ghost.form].radius_m
	# Discard expired references even outside a measured wave.
	@warning_ignore("return_value_discarded")
	stunned_count(arena, stage.tick)
	var applied: bool = false
	for foe: Fighter in arena.hostiles:
		if not foe.alive() or ghost.spot.distance_to(foe.pos) > radius:
			continue
		if OhmShortCircuit.short_machine(arena, foe, stage.tick):
			_shorts[foe] = arena.squad_ai.mind_for(foe).stun_until
			applied = true
		var dir: Vector2 = ghost.spot.direction_to(foe.pos)
		_hit(arena, foe, dir, attacks.num(ghost.form, &"bolt_damage"), &"deploy_ohm")
	if applied:
		arena.move_tally.record(MoveTable.SHORT_CIRCUIT)


func _tonnage(stage: CollectCallStage, ghost: GhostDeploy) -> void:
	var arena: CombatArena = stage.arena
	var head: Vector2 = ghost.spot + ghost.facing * attacks.num(ghost.form, &"press_ahead_m")
	var squad: ArenaSquad = arena.squad_ai
	for foe: Fighter in arena.hostiles:
		var offset: Vector2 = foe.pos - ghost.spot
		if not foe.alive() or offset.dot(ghost.facing) < 0.0:
			continue
		if head.distance_to(foe.pos) > press.num(&"stomp_radius_m"):
			continue
		if foe.archetype == &"war_machine" and squad != null and squad.owns(foe):
			TonnageCrack.open(arena, squad.mind_for(foe), stage.tick)
		_hit(arena, foe, offset.normalized(), press.num(&"stomp_damage"), &"deploy_tonnage")


func _dent(stage: CollectCallStage, ghost: GhostDeploy) -> void:
	var arena: CombatArena = stage.arena
	var side: Vector2 = ghost.facing.orthogonal() * arena.rivet.radius_m
	ghost.origin = GhostDeploySpot.clip(stage, arena.rivet.pos, arena.rivet.pos + side)
	ghost.spot = GhostDeploySpot.clip(stage, ghost.origin, ghost.spot)
	var dir: Vector2 = ghost.origin.direction_to(ghost.spot)
	if dir == Vector2.ZERO:
		return
	ghost.facing = dir
	for foe: Fighter in arena.hostiles:
		if not foe.alive() or not foe.exposed:
			continue
		var near: Vector2 = Geometry2D.get_closest_point_to_segment(
			foe.pos, ghost.origin, ghost.spot
		)
		if near.distance_to(foe.pos) > attacks.deploy[ghost.form].ram_half_m:
			continue
		_hit(arena, foe, dir, attacks.num(ghost.form, &"jab_damage"), &"deploy_dent")
		var pushed: Vector2 = foe.pos + dir * attacks.num(ghost.form, &"jab_knock_m")
		foe.pos = DentStage.push_out(stage, pushed, foe.radius_m)


## Count living machines still held by this deployment's stun deadline.
func stunned_count(arena: CombatArena, tick: int) -> int:
	if _shorts.is_empty():
		return 0
	for foe: Fighter in _shorts.keys():
		var mind: SquadMind = arena.squad_ai.minds.get(foe.id) if arena.squad_ai != null else null
		var until: int = _shorts[foe]
		if not foe.alive() or tick >= until or mind == null or mind.stun_until != until:
			@warning_ignore("return_value_discarded")
			_shorts.erase(foe)
	return _shorts.size()


func _hit(
	arena: CombatArena, foe: Fighter, dir: Vector2, damage: float, weapon: StringName
) -> void:
	arena.hit_dir = dir
	arena.hit_at = foe.pos - dir * foe.radius_m
	var kind: StringName = &"shot"
	if weapon == &"deploy_kerf":
		kind = KerfStage.KILL_KIND
	elif weapon == &"deploy_ohm":
		kind = OhmStage.KILL_KIND
	arena.damage(foe, damage, arena.rivet.id, weapon, kind)
	if not foe.alive():
		release_kills += 1
