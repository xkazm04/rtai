class_name DeployWorthAim
extends RefCounted
## Search the headings and reaches the actual input word can encode, on the open floor.
## Ties keep the bearing closest to the pistol target, then the shortest reach.

var stage: ArenaStage
var form: StringName
var actions: PlayerActions
var attacks: GhostAttacks
var row: GhostAttacks.DeployRow
var held: bool = false
var last_aim: Vector2
var spots: GhostDeployBotSpot


func _init(host: ArenaStage, id: StringName) -> void:
	stage = host
	form = id
	actions = stage.pilot.actions
	attacks = stage.pilot.ghosts.deploy.strike.attacks
	row = attacks.deploy[form]
	spots = GhostDeployBotSpot.new(host, actions)


func sample(enabled: bool) -> TickInput:
	var rivet: Fighter = stage.arena.rivet
	var gun: Vector2 = _nearest(rivet.pos)
	var cursor: Vector2 = gun
	var bits: int = 0
	if enabled and stage.pilot.ghosts.deploy.cooldowns.get(form, 0) <= 2:
		var best: Vector2 = _best(gun)
		if held:
			cursor = best if best != Vector2.ZERO else last_aim
			held = false
		elif best != Vector2.ZERO:
			cursor = best
			last_aim = best
			held = true
			bits |= 1 << actions.bit(&"ghost_deploy")
	if PlayerCommand.pack_aim(cursor, actions) == PlayerCommand.pack_aim(gun, actions):
		bits |= 1 << actions.bit(&"fire")
	if stage.arena.gun != null and stage.arena.gun.trigger.ammo == 0:
		bits |= 1 << actions.bit(&"reload")
	bits |= PlayerCommand.pack_aim(cursor.normalized(), actions, cursor.length())
	var radial: Vector2 = rivet.pos - Vector2(5.5, 0.0)
	var walk: Vector2 = (
		(radial.normalized().orthogonal() - radial.normalized() * (radial.length() - 5.5))
		. normalized()
	)
	return TickInput.new(
		bits, roundi(walk.x * TickInput.AXIS_MAX), roundi(walk.y * TickInput.AXIS_MAX)
	)


func _nearest(from: Vector2) -> Vector2:
	var distance: float = INF
	var cursor: Vector2 = Vector2.ZERO
	for foe: Fighter in stage.arena.hostiles:
		var delta_m: Vector2 = foe.pos - from
		if foe.alive() and delta_m.length_squared() < distance:
			distance = delta_m.length_squared()
			cursor = delta_m
	return cursor


func _best(gun: Vector2) -> Vector2:
	var seen: Array[BotView.Hostile] = []
	for fighter: Fighter in stage.arena.hostiles:
		if fighter.alive() and (form != DentStage.GHOST or fighter.exposed):
			seen.append(BotArenaFoe.read(fighter, stage.arena))
	return spots.best(form, gun, seen, false)
