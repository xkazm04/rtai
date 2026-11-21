class_name FoeWalkerFilm
extends GunplayBot
## Capture input for the escort encounter. Close after the first shell, step back from
## the foot ring, then use the vent window to circle and fire. All hits use the arena gun.

var _previous: EnemyAgent.State = EnemyAgent.State.PATROL
var _shell_fired: bool = false


func sample(tick: int) -> TickInput:
	var rivet: Vector2 = stage.arena.rivet.pos
	var walker: Fighter
	var escort: Fighter
	for h: Fighter in stage.pit.standing:
		if h.alive() and h.archetype == &"war_machine":
			walker = h
		elif (
			h.alive()
			and (escort == null or rivet.distance_to(h.pos) < rivet.distance_to(escort.pos))
		):
			escort = h
	if walker == null:
		return (
			_shoot(escort, Vector2.ZERO)
			if escort != null
			else _input(Vector2.ZERO, Vector2.RIGHT, false)
		)
	var mind: SquadMind = stage.arena.squad_ai.minds.get(walker.id)
	if mind == null:
		return _input(Vector2.ZERO, rivet.direction_to(walker.pos), false)
	var e: EnemyAgent = mind.agent
	if e.state != _previous:
		var attack: StringName = mind.walker.attack.id if mind.walker.attack != null else &""
		Log.info("foe-film", "%s %s tick %d" % [attack, EnemyAgent.State.keys()[e.state], tick])
		_previous = e.state
	_shell_fired = _shell_fired or e.shot_tick >= 0
	var radial: Vector2 = walker.pos.direction_to(rivet)
	var move: Vector2 = _move(walker, mind, radial)
	if escort != null and e.state != EnemyAgent.State.RECOVER and tick > 180:
		return _shoot(escort, move)
	var rear: bool = radial.dot(walker.facing) <= FoeArmor.REAR_COS
	var fire: bool = (
		rear and e.state == EnemyAgent.State.RECOVER and tick % 24 == 0 and _lane(rivet, walker.pos)
	)
	return _input(move, -radial, fire, rivet.distance_to(walker.pos))


func _move(walker: Fighter, mind: SquadMind, radial: Vector2) -> Vector2:
	var rivet: Vector2 = stage.arena.rivet.pos
	if walker.tell_left > 0 and stage.arena.guard_tell.locked(walker):
		return radial.orthogonal()
	if not _shell_fired:
		return Vector2.ZERO
	if walker.swing_left > 0 and walker.swing_left < mind.agent.arch.alt_telegraph_ticks - 8:
		return (
			radial
			if rivet.distance_to(walker.pos) < mind.walker.attack.splash_radius_m + 0.35
			else radial.orthogonal()
		)
	var side: float = clampf(radial.angle_to(-walker.facing) * 2.0, -1.0, 1.0)
	var approach: float = clampf(1.8 - rivet.distance_to(walker.pos), -1.0, 1.0)
	return radial * approach + radial.rotated(PI * 0.5) * side


func _shoot(h: Fighter, move: Vector2) -> TickInput:
	var rivet: Vector2 = stage.arena.rivet.pos
	return _input(move, rivet.direction_to(h.pos), _lane(rivet, h.pos), rivet.distance_to(h.pos))
