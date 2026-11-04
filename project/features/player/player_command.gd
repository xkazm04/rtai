class_name PlayerCommand
extends RefCounted
## One tick of player intent decoded from a TickInput (so live play and a replay decode the
## same ints): the move stick (-1..1 per axis), the aim heading (quantised), the held buttons and
## the ones pressed on this tick (an edge against the previous tick's buttons).

const AIM_VALID: int = 0x100
## Lane gunplay: the cursor's distance, REACH_MAX steps of aim_reach_step_m above the valid bit.
const REACH_SHIFT: int = 9
const REACH_MAX: int = 15

var move: Vector2 = Vector2.ZERO
## Unit heading; Vector2.ZERO when no aim was sampled (the aim-valid bit clear).
var aim: Vector2 = Vector2.ZERO
## How far out the cursor sat (m); 0 when none was sent (old replays, the pad, no step).
var aim_m: float = 0.0
var held: int = 0
var pressed: int = 0


static func decode(input: TickInput, previous: int, actions: PlayerActions) -> PlayerCommand:
	var c: PlayerCommand = PlayerCommand.new()
	c.move = Vector2(input.move_x, input.move_y) / float(TickInput.AXIS_MAX)
	var mask: int = (1 << actions.aim_shift) - 1
	c.held = input.buttons & mask
	c.pressed = c.held & ~(previous & mask)
	var word: int = input.buttons >> actions.aim_shift
	if word & AIM_VALID:
		var turn: float = float(word & 0xFF) / float(actions.aim_steps)
		c.aim = Vector2.RIGHT.rotated(turn * TAU)
		c.aim_m = float((word >> REACH_SHIFT) & REACH_MAX) * actions.aim_reach_step_m
	return c


## Packs a heading into the aim bits (8 bits of angle plus an aim-valid bit), and the cursor's
## distance `reach_m` (0 = none) in 4 bits of aim_reach_step_m above them.
static func pack_aim(heading: Vector2, actions: PlayerActions, reach_m: float = 0.0) -> int:
	if heading == Vector2.ZERO:
		return 0
	var turn: float = fposmod(heading.angle(), TAU) / TAU
	var step: int = roundi(turn * actions.aim_steps) % actions.aim_steps
	var reach: int = 0
	if actions.aim_reach_step_m > 0.0 and reach_m > 0.0:
		reach = clampi(roundi(reach_m / actions.aim_reach_step_m), 1, REACH_MAX)
	return (AIM_VALID | step | reach << REACH_SHIFT) << actions.aim_shift


func is_held(actions: PlayerActions, action: StringName) -> bool:
	var b: int = actions.bit(action)
	return b >= 0 and (held >> b) & 1 == 1


func was_pressed(actions: PlayerActions, action: StringName) -> bool:
	var b: int = actions.bit(action)
	return b >= 0 and (pressed >> b) & 1 == 1
