class_name GauntletWalker
extends GauntletPilot
## Fallback street pilot. The street runs east. Aim and fire at the closest living hostile.

var _arena: GauntletCombat
var _actions: PlayerActions
var _recovering: bool = false
var _pilot: StagePilot


func bind(_run: GauntletRun, session: ArenaSession) -> void:
	_arena = session.stage.arena as GauntletCombat
	_actions = session.actions
	_pilot = session.pilot


func sample(tick: int) -> TickInput:
	if _arena == null:
		return TickInput.new()
	var at: Vector2 = _arena.rivet.pos
	var foe: Fighter = _nearest(at)
	if foe == null and _arena.can_repair() and _arena.rivet.hp < 0.95 * _arena.rivet.max_hp:
		return TickInput.new()  # repair in the cleared block before entering the next fight
	var goal: Vector2 = foe.pos if foe != null else Vector2(at.x + 8.0, 0.0)
	var offset: Vector2 = goal - at
	var move: Vector2 = _approach(at, goal)

	var buttons: int = PlayerCommand.pack_aim(offset.normalized(), _actions, offset.length())
	if _needs_repair(foe):
		var behind: Vector2 = Vector2(
			maxf(at.x - 10.0, _arena.guard_map.region().position.x + 6.0), 0
		)
		move = _approach(at, behind) if offset.length() < 30.0 else Vector2.ZERO
		buttons |= 1 << _actions.bit(&"sprint")
	elif foe != null:
		if _arena.gun != null and _arena.rivet.weapon != &"":
			buttons |= 1 << _actions.bit(&"fire")
		var reach: float = _pilot.melee.combo.table.hits[0].reach_m + foe.radius_m
		if offset.length() <= reach and tick % ArenaRivetBot.MASH_EVERY == 0:
			buttons |= 1 << _actions.bit(&"melee")
		if _flank(foe) and _arena.guard_map.clear_line(at, goal):
			move = _strafe(offset)
		elif offset.length() < 1.0:
			move = Vector2.ZERO
	if foe != null and _danger(at, offset.length()):
		move = at.direction_to(goal).orthogonal()
		if move.y * at.y > 0.0:
			move = -move
		buttons |= 1 << _actions.bit(&"roll")
	elif offset.length() > ArenaRivetBot.FOE_AIM_M:
		buttons |= 1 << _actions.bit(&"sprint")
	return TickInput.new(
		buttons, roundi(move.x * TickInput.AXIS_MAX), roundi(move.y * TickInput.AXIS_MAX)
	)


## Fall back along the cleared street while Rivet's ordinary delayed repair recovers his HP.
func _needs_repair(foe: Fighter) -> bool:
	var hp: float = _arena.rivet.hp / _arena.rivet.max_hp
	if hp < 0.45:
		_recovering = true
	elif hp >= 0.90:
		_recovering = false
	return foe != null and _arena.can_repair() and _recovering


func _approach(at: Vector2, goal: Vector2) -> Vector2:
	var map: GuardRouteMap = _arena.guard_map
	if map != null and not map.clear_line(at, goal):
		for via: Vector2 in map.route(at, goal):
			if via.distance_to(at) > 0.15:
				return at.direction_to(via)
	return at.direction_to(goal)


func _flank(foe: Fighter) -> bool:
	if not foe.machine:
		return false
	var arch: EnemyRoster.Archetype = _arena.squad_ai.pit.roster.archetype(foe.archetype)
	return foe.weapon != &"" or arch.shield_front_mult < 1.0


## Circle machines inside claw reach to pass their shield or cross their firing line.
func _strafe(offset: Vector2) -> Vector2:
	var inward: Vector2 = offset.normalized()
	var close: float = offset.length() - 0.55
	var tangent: float = 0.9 if close < 1.0 else 0.25
	return (inward * clampf(close, -1.0, 1.0) + inward.orthogonal() * tangent).normalized()


## Read the same visible windup and incoming rounds that a player can dodge.
func _danger(at: Vector2, gap: float) -> bool:
	for foe: Fighter in _arena.hostiles:
		if foe.alive() and foe.swing_left == 8 and at.distance_squared_to(foe.pos) <= 16.0:
			return true
	for shot: Shot in _arena.shots:
		if shot.from_rivet or shot.damage < 2.0 or shot.vel == Vector2.ZERO:
			continue
		if shot.size == Shot.SMALL and gap < 5.0:
			continue
		var seconds: float = (at - shot.pos).dot(shot.vel) / shot.vel.length_squared()
		if seconds > 0.05 and seconds < 0.16:
			if at.distance_to(shot.pos + shot.vel * seconds) < _arena.rivet.radius_m + 0.2:
				return true
	return false


func _nearest(from: Vector2) -> Fighter:
	var nearest: Fighter = null
	var best: float = INF
	for foe: Fighter in _arena.hostiles:
		var distance: float = from.distance_squared_to(foe.pos)
		if foe.alive() and distance < best:
			nearest = foe
			best = distance
	return nearest
