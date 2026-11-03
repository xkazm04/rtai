class_name PlayerCommand
extends RefCounted
## One tick of player intent decoded from a TickInput (so live play and a replay decode the
## same ints): the move stick (-1..1 per axis), the aim heading (quantised), the held buttons and
## the ones pressed on this tick (an edge against the previous tick's buttons).

const AIM_VALID: int = 0x100

var move: Vector2 = Vector2.ZERO
## Unit heading; Vector2.ZERO when no aim was sampled (the aim-valid bit clear).
var aim: Vector2 = Vector2.ZERO
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
	return c


## Packs a heading into the aim bits (8 bits of angle plus an aim-valid bit).
static func pack_aim(heading: Vector2, actions: PlayerActions) -> int:
	if heading == Vector2.ZERO:
		return 0
	var turn: float = fposmod(heading.angle(), TAU) / TAU
	var step: int = roundi(turn * actions.aim_steps) % actions.aim_steps
	return (AIM_VALID | step) << actions.aim_shift


func is_held(actions: PlayerActions, action: StringName) -> bool:
	var b: int = actions.bit(action)
	return b >= 0 and (held >> b) & 1 == 1


func was_pressed(actions: PlayerActions, action: StringName) -> bool:
	var b: int = actions.bit(action)
	return b >= 0 and (pressed >> b) & 1 == 1
