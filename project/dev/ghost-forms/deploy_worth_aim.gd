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
var ahead: float
var radius: float


func _init(host: ArenaStage, id: StringName) -> void:
	stage = host
	form = id
	actions = stage.pilot.actions
	attacks = stage.pilot.ghosts.deploy.strike.attacks
	row = attacks.deploy[form]
	if form == HaulerStage.GHOST:
		ahead = attacks.num(form, &"press_ahead_m")
		radius = stage.pilot.hauler.form.num(&"stomp_radius_m")


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
	if form == KerfStage.GHOST:
		return _kerf()
	var margin: float = maxf(row.radius_m, row.ram_half_m) + ahead + radius
	if gun.length() > row.range_m + margin + stage.arena.rivet.radius_m:
		return Vector2.ZERO
	var best: Vector2 = Vector2.ZERO
	var high: int = 0
	var first: int = roundi(gun.angle() * actions.aim_steps / TAU)
	var reaches: int = mini(PlayerCommand.REACH_MAX, ceili(row.range_m / actions.aim_reach_step_m))
	for i: int in actions.aim_steps:
		var offset: int = ceili(i * 0.5) * (1 if i % 2 == 1 else -1)
		var face: Vector2 = Vector2.from_angle((first + offset) * TAU / actions.aim_steps)
		for step: int in range(1, reaches + 1):
			var dist: float = minf(row.range_m, step * actions.aim_reach_step_m)
			var score: int = _score(face, dist)
			if score > high:
				high = score
				best = face * dist
	return best


func _score(face: Vector2, dist: float) -> int:
	var rivet: Fighter = stage.arena.rivet
	var spot: Vector2 = rivet.pos + face * dist
	var side: Vector2 = rivet.pos + face.orthogonal() * rivet.radius_m
	var score: int = 0
	for foe: Fighter in stage.arena.hostiles:
		if not foe.alive():
			continue
		match form:
			OhmStage.GHOST:
				if spot.distance_to(foe.pos) <= row.radius_m:
					score += 1 + (10 if foe.machine else 0)
			HaulerStage.GHOST:
				if (
					(foe.pos - spot).dot(face) >= 0.0
					and (spot + face * ahead).distance_to(foe.pos) <= radius
				):
					score += 1
			DentStage.GHOST:
				var near: Vector2 = Geometry2D.get_closest_point_to_segment(foe.pos, side, spot)
				if foe.exposed and near.distance_to(foe.pos) <= row.ram_half_m:
					score += 1
	return score


func _kerf() -> Vector2:
	var best: Vector2 = Vector2.ZERO
	var high: float = 0.0
	var rivet: Fighter = stage.arena.rivet
	for foe: Fighter in stage.arena.hostiles:
		var cursor: Vector2 = foe.pos - rivet.pos
		if not foe.alive() or cursor.length() > row.range_m:
			continue
		var word: TickInput = TickInput.new(
			PlayerCommand.pack_aim(cursor, actions, cursor.length())
		)
		var c: PlayerCommand = PlayerCommand.decode(word, 0, actions)
		var at: Vector2 = rivet.pos + c.aim * minf(row.range_m, c.aim_m)
		var victim: Fighter = GhostDeploySpot.kerf_target(stage, at, c.aim, attacks)
		if victim == null:
			continue
		var damage: float = attacks.num(
			form, &"robot_damage" if victim.machine else &"human_damage"
		)
		var score: float = minf(victim.hp, damage) + (1000.0 if victim.hp <= damage else 0.0)
		if score > high:
			best = cursor
			high = score
	return best
