class_name StalkPilot
extends GauntletTestPlayer
## n31 foes (--stalk): Rivet walks at a target to HOLD_M and stands there for HOLD_TICKS (the cop
## should back off slowly while firing), rushes straight at it to CLOSE_M, walks away to FAR_M,
## repeats. No buttons are ever pressed (no swing, no fire, no ghost). The bot still steps so
## picks and waves match, and its input plays until a target exists.

enum Phase { APPROACH, HOLD, RUSH, AWAY }

const HOLD_M: float = 6.0
const CLOSE_M: float = 2.0
const FAR_M: float = 12.0
const HOLD_TICKS: int = 240

var target: Vector2 = Vector2.INF
var phase: Phase = Phase.APPROACH
var _hold_until: int = 0


func sample(tick: int) -> TickInput:
	var bot_input: TickInput = super.sample(tick)
	var me: Vector2 = _stage.arena.rivet.pos
	if not target.is_finite() or not _stage.arena.rivet.alive():
		return bot_input if not target.is_finite() else TickInput.new()
	var to: Vector2 = target - me
	_advance(tick, to.length())
	var dir: Vector2 = Vector2.ZERO
	if phase == Phase.APPROACH or phase == Phase.RUSH:
		dir = to.normalized()
	elif phase == Phase.AWAY:
		dir = -to.normalized()
	var move: Vector2 = dir * TickInput.AXIS_MAX
	return TickInput.new(0, roundi(move.x), roundi(move.y))


func _advance(tick: int, d: float) -> void:
	if phase == Phase.APPROACH and d <= HOLD_M:
		phase = Phase.HOLD
		_hold_until = tick + HOLD_TICKS
	elif phase == Phase.HOLD and tick >= _hold_until:
		phase = Phase.RUSH
	elif phase == Phase.RUSH and d <= CLOSE_M:
		phase = Phase.AWAY
	elif phase == Phase.AWAY and d >= FAR_M:
		phase = Phase.APPROACH
