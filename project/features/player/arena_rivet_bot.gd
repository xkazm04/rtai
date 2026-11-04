class_name ArenaRivetBot
extends InputSource
## rivet-arsenal's scripted player for the live arena (--bot=rivet): through the real pilot
## (TickInput -> InputTape -> StagePilot -> PlayerMotion + PlayerMelee) it walks, strafes and
## backpedals around an aim mark, sprints, rolls both ways, then walks to the claw cops (station
## rivet_claw_cops) and mashes the combo on two sparring cops, then one jab on a plain
## cop. Deterministic: it reads only the sim.
## A step is [ticks or -1 = until reached, move or goto (hub-relative m), aim mark, buttons, mash].

const REACH_M: float = 0.12
const MASH_EVERY: int = 5
const MARK: Vector2 = Vector2(6.0, 4.0)
const STEPS: Array = [
	[40, Vector2.ZERO, MARK, [], false],
	[90, Vector2.RIGHT, MARK, [], false],
	[90, Vector2.LEFT, MARK, [], false],
	[40, Vector2.DOWN, MARK, [], false],
	[45, Vector2.UP, MARK, [], false],
	[30, Vector2.ZERO, MARK, [], false],
	[75, Vector2.RIGHT, null, ["sprint"], false],
	[45, Vector2.RIGHT, null, ["roll"], false],
	[40, Vector2.LEFT, null, ["roll"], false],
	[-1, Vector2(2.0, 1.45), Vector2(2.0, 3.0), [], false],
	[48, Vector2.ZERO, Vector2(2.0, 3.0), [], true],
	[40, Vector2.ZERO, Vector2(2.0, 3.0), [], false],
	[-1, Vector2(6.0, 1.45), Vector2(6.0, 3.0), [], false],
	[48, Vector2.ZERO, Vector2(6.0, 3.0), [], true],
	[30, Vector2.ZERO, Vector2(6.0, 3.0), [], false],
	[-1, Vector2(10.0, 1.45), Vector2(10.0, 3.0), [], false],
	[5, Vector2.ZERO, Vector2(10.0, 3.0), [], true],
	[90, Vector2.ZERO, Vector2(10.0, 3.0), [], false],
]

var stage: ArenaStage
var actions: PlayerActions
var index: int = 0
var finished_tick: int = -1
var _in_step: int = 0


func _init(p_stage: ArenaStage, p_actions: PlayerActions) -> void:
	stage = p_stage
	actions = p_actions


func sample(tick: int) -> TickInput:
	if index >= STEPS.size():
		if finished_tick < 0:
			finished_tick = tick
		return TickInput.new()
	var s: Array = STEPS[index]
	var ticks: int = s[0]
	var at: Vector2 = stage.arena.rivet.pos
	var move: Vector2 = s[1]
	if ticks < 0:
		var to: Vector2 = stage.plan.base + move - at
		move = to.normalized() if to.length() > REACH_M else Vector2.ZERO
	var buttons: int = _buttons(s, ticks < 0)
	if s[2] != null:
		var mark: Vector2 = s[2]
		buttons |= PlayerCommand.pack_aim((stage.plan.base + mark - at).normalized(), actions)
	_in_step += 1
	if (ticks >= 0 and _in_step >= ticks) or (ticks < 0 and move == Vector2.ZERO):
		index += 1
		_in_step = 0
	var m: Vector2 = move * TickInput.AXIS_MAX
	return TickInput.new(buttons, roundi(m.x), roundi(m.y))


## Held buttons; a roll is a press on the step's first tick; a mash taps melee every MASH_EVERY.
func _buttons(s: Array, goto: bool) -> int:
	var b: int = 0
	for n: String in s[3]:
		var bit: int = 1 << actions.bit(StringName(n))
		if n != "roll" or _in_step == 0:
			b |= bit
	var mash: bool = s[4]
	if mash and not goto and _in_step % MASH_EVERY == 0:
		b |= 1 << actions.bit(&"melee")
	return b
