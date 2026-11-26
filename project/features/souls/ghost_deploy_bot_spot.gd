class_name GhostDeployBotSpot
extends RefCounted
## Score the cursor positions the input word can send. Equal scores keep the bearing nearest
## the gun aim, then the shortest reach. The worth probe accepts single-body opportunities.

var _stage: ArenaStage
var _actions: PlayerActions
var _attacks: GhostAttacks
var _row: GhostAttacks.DeployRow
var _form: StringName
var _require_fit: bool
var _ahead: float
var _radius: float
var _nearby: Array[BotView.Hostile] = []


func _init(stage: ArenaStage, actions: PlayerActions) -> void:
	_stage = stage
	_actions = actions
	_attacks = stage.pilot.ghosts.deploy.strike.attacks


func best(
	form: StringName, gun: Vector2, seen: Array[BotView.Hostile], require_fit: bool
) -> Vector2:
	_form = form
	_require_fit = require_fit
	_row = _attacks.deploy[form]
	var stomp: bool = form == HaulerStage.GHOST and not _row.drops()
	_ahead = _attacks.num(form, &"press_ahead_m") if stomp else 0.0
	_radius = _stage.pilot.hauler.form.num(&"stomp_radius_m") if stomp else 0.0
	var rivet: Fighter = _stage.arena.rivet
	var margin: float = maxf(_row.radius_m, _row.ram_half_m) + _ahead + _radius + rivet.radius_m
	_nearby.clear()
	var machines: int = 0
	var special: bool = false
	for foe: BotView.Hostile in seen:
		if not foe.alive or rivet.pos.distance_to(foe.pos) > _row.range_m + margin:
			continue
		_nearby.append(foe)
		machines += int(foe.robot)
		special = special or _special(foe)
	if _nearby.is_empty():
		return Vector2.ZERO
	if form == KerfStage.GHOST:
		return _kerf()
	if require_fit and not _fits(_nearby.size(), machines, special):
		return Vector2.ZERO
	return _area(gun, _nearby.size() + (10 * machines if form == OhmStage.GHOST else 0))


func _area(gun: Vector2, maximum: int) -> Vector2:
	var cursor: Vector2 = Vector2.ZERO
	var high: int = 0
	var first: int = roundi(gun.angle() * _actions.aim_steps / TAU)
	var reaches: int = mini(
		PlayerCommand.REACH_MAX, ceili(_row.range_m / _actions.aim_reach_step_m)
	)
	var from: Vector2 = _stage.arena.rivet.pos
	for i: int in _actions.aim_steps:
		var offset: int = ceili(i * 0.5) * (1 if i % 2 == 1 else -1)
		var face: Vector2 = Vector2.from_angle((first + offset) * TAU / _actions.aim_steps)
		for step: int in range(1, reaches + 1):
			var dist: float = minf(_row.range_m, step * _actions.aim_reach_step_m)
			var spot: Vector2 = from + face * dist
			var score: int = _score(face, spot)
			if score > high and GhostDeploySpot.clear(_stage, from, spot):
				high = score
				cursor = face * dist
				if high == maximum:
					return cursor
	return cursor


func _score(face: Vector2, spot: Vector2) -> int:
	var r: Fighter = _stage.arena.rivet
	var side: Vector2 = r.pos + face.orthogonal() * r.radius_m
	var bodies: int = 0
	var machines: int = 0
	var special: bool = false
	for foe: BotView.Hostile in _nearby:
		match _form:
			OhmStage.GHOST:
				if spot.distance_to(foe.pos) > _row.radius_m:
					continue
			HaulerStage.GHOST:
				if _row.drops():
					# n31: the dump is a full circle on the spot (or on Rivet, drop_at rivet).
					var at: Vector2 = r.pos if _row.drop_at == &"rivet" else spot
					if at.distance_to(foe.pos) > _row.radius_m:
						continue
				elif (
					(foe.pos - spot).dot(face) < 0.0
					or (spot + face * _ahead).distance_to(foe.pos) > _radius
				):
					continue
			DentStage.GHOST:
				var near: Vector2 = Geometry2D.get_closest_point_to_segment(foe.pos, side, spot)
				if near.distance_to(foe.pos) > _row.ram_half_m:
					continue
		bodies += 1
		machines += int(foe.robot)
		special = special or _special(foe)
	if _require_fit and not _fits(bodies, machines, special):
		return 0
	return bodies + (10 * machines if _form == OhmStage.GHOST else 0)


func _special(foe: BotView.Hostile) -> bool:
	return (
		(_form == OhmStage.GHOST and foe.archetype == &"sentry_turret")
		or (_form == HaulerStage.GHOST and foe.archetype == &"war_machine")
	)


func _fits(bodies: int, machines: int, special: bool) -> bool:
	match _form:
		OhmStage.GHOST:
			return special or machines >= 2
		HaulerStage.GHOST:
			return special or bodies >= 3
	return bodies >= 2


func _kerf() -> Vector2:
	var eligible: Dictionary[int, bool] = {}
	for foe: BotView.Hostile in _nearby:
		if not _require_fit or foe.tier >= 3 or foe.archetype in [&"shield_robot", &"war_machine"]:
			eligible[foe.id] = true
	var best_cursor: Vector2 = Vector2.ZERO
	var high: float = 0.0
	var from: Vector2 = _stage.arena.rivet.pos
	for foe: BotView.Hostile in _nearby:
		var cursor: Vector2 = foe.pos - from
		if not eligible.has(foe.id) or cursor.length() > _row.range_m:
			continue
		var word: TickInput = TickInput.new(
			PlayerCommand.pack_aim(cursor, _actions, cursor.length())
		)
		var c: PlayerCommand = PlayerCommand.decode(word, 0, _actions)
		var at: Vector2 = from + c.aim * minf(_row.range_m, c.aim_m)
		var victim: Fighter = GhostDeploySpot.kerf_target(_stage, at, c.aim, _attacks)
		if victim == null or not eligible.has(victim.id):
			continue
		var damage: float = _attacks.num(
			_form, &"robot_damage" if victim.machine else &"human_damage"
		)
		var score: float = minf(victim.hp, damage) + (1000.0 if victim.hp <= damage else 0.0)
		if score > high:
			best_cursor = cursor
			high = score
	return best_cursor
