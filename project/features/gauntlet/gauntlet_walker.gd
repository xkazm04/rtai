class_name GauntletWalker
extends GauntletPilot
## Fallback street pilot. The street runs east. Aim and fire at the closest living hostile.

var _arena: CombatArena
var _actions: PlayerActions


func bind(_run: GauntletRun, session: ArenaSession) -> void:
	_arena = session.stage.arena
	_actions = session.actions


func sample(_tick: int) -> TickInput:
	var buttons: int = 0
	if _arena != null:
		var from: Vector2 = _arena.rivet.pos
		var nearest: Fighter = _nearest(from)
		if nearest != null:
			var offset: Vector2 = nearest.pos - from
			buttons = PlayerCommand.pack_aim(offset.normalized(), _actions, offset.length())
			buttons |= 1 << _actions.bit(&"fire")
	return TickInput.new(buttons, TickInput.AXIS_MAX, 0)


func _nearest(from: Vector2) -> Fighter:
	var nearest: Fighter = null
	var best: float = INF
	for foe: Fighter in _arena.hostiles:
		var distance: float = from.distance_squared_to(foe.pos)
		if foe.alive() and distance < best:
			nearest = foe
			best = distance
	return nearest
