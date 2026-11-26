class_name StalkPilot
extends GauntletTestPlayer
## n31 foes (--stalk): Rivet walks at a target, holds 2 m from it, walks away, repeats. No buttons
## are ever pressed (no swing, no fire, no ghost). The bot still steps so picks and waves match.

enum Phase { APPROACH, HOLD, AWAY }

const CLOSE_M: float = 2.0
const FAR_M: float = 10.0
const HOLD_TICKS: int = 180

var target: Vector2 = Vector2.INF
var phase: Phase = Phase.APPROACH
var _hold_until: int = 0


func sample(tick: int) -> TickInput:
	var bot_input: TickInput = super.sample(tick)
	var me: Vector2 = _stage.arena.rivet.pos
	if not target.is_finite() or not _stage.arena.rivet.alive():
		return bot_input if not target.is_finite() else TickInput.new()
	var to: Vector2 = target - me
	var d: float = to.length()
	if phase == Phase.APPROACH and d <= CLOSE_M:
		phase = Phase.HOLD
		_hold_until = tick + HOLD_TICKS
	elif phase == Phase.HOLD and tick >= _hold_until:
		phase = Phase.AWAY
	elif phase == Phase.AWAY and d >= FAR_M:
		phase = Phase.APPROACH
	var dir: Vector2 = Vector2.ZERO
	if phase == Phase.APPROACH:
		dir = to.normalized()
	elif phase == Phase.AWAY:
		dir = -to.normalized()
	var move: Vector2 = dir * TickInput.AXIS_MAX
	return TickInput.new(0, roundi(move.x), roundi(move.y))
