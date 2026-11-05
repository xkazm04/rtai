class_name AlleyBot
extends InputSource
## n5-look: the alley's scripted player for the close-up clip (deterministic: it reads only the
## sim). Holds the alley's middle, aims at the nearest standing cop of the alley's waves (either
## end), closes to CLOSE_M (the cops stand off at their engage range, past the 48 px/m frame),
## fires once inside FIRE_M for REACT_TICKS and strafes across the lane. ArenaPitBot's loop
## against AlleyHook.waves instead of the pit.

const FIRE_M: float = 11.0
const REACT_TICKS: int = 45
const STRAFE_TICKS: int = 50
const CLOSE_M: float = 6.0

var stage: ArenaStage
var actions: PlayerActions
var _hook: AlleyHook = null
var _in_range_since: int = -1


func _init(p_stage: ArenaStage, p_actions: PlayerActions) -> void:
	stage = p_stage
	actions = p_actions
	for h: ArenaHook in stage.hooks:
		if h is AlleyHook:
			_hook = h as AlleyHook


func sample(tick: int) -> TickInput:
	if _hook == null:
		return TickInput.new(0, 0, 0)
	var rivet: Vector2 = stage.arena.rivet.pos
	var spot: Vector2 = _hook.waves.zone.get_center()
	var foe: Fighter = _nearest(rivet)
	if foe == null:
		_in_range_since = -1
		return _input((spot - rivet).limit_length(1.0), Vector2.DOWN, false)
	var aim: Vector2 = (foe.pos - rivet).normalized()
	var close: bool = rivet.distance_to(foe.pos) <= FIRE_M
	_in_range_since = (tick if _in_range_since < 0 else _in_range_since) if close else -1
	var fire: bool = close and tick - _in_range_since >= REACT_TICKS
	var side: float = 1.0 if (tick / STRAFE_TICKS) % 2 == 0 else -1.0
	var drift: Vector2 = aim.orthogonal() * side * 0.6
	if rivet.distance_to(foe.pos) > CLOSE_M:
		drift = aim + aim.orthogonal() * side * 0.3
	return _input(drift, aim, fire)


func _nearest(at: Vector2) -> Fighter:
	var best: Fighter = null
	for f: Fighter in _hook.waves.standing:
		if f.alive() and (best == null or at.distance_to(f.pos) < at.distance_to(best.pos)):
			best = f
	return best


func _input(move: Vector2, aim: Vector2, fire: bool) -> TickInput:
	var m: Vector2 = move.limit_length(1.0) * TickInput.AXIS_MAX
	var buttons: int = PlayerCommand.pack_aim(aim, actions)
	if fire:
		buttons |= 1 << actions.bit(&"fire")
	return TickInput.new(buttons, roundi(m.x), roundi(m.y))
