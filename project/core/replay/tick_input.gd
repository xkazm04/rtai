class_name TickInput
extends RefCounted
## One tick of player intent, quantised to ints so it records and replays bit-identically
## (SIM-05). buttons holds one bit per gameplay action (the bit order lands with features/input
## and its InputMap actions, STM-09); the move axes are -127..127.

const AXIS_MAX: int = 127
const AXIS_BIAS: int = 128

var buttons: int = 0
var move_x: int = 0
var move_y: int = 0


func _init(p_buttons: int = 0, p_move_x: int = 0, p_move_y: int = 0) -> void:
	buttons = p_buttons & 0xFFFFFFFF
	move_x = clampi(p_move_x, -AXIS_MAX, AXIS_MAX)
	move_y = clampi(p_move_y, -AXIS_MAX, AXIS_MAX)


static func unpack(packed: int) -> TickInput:
	var x: int = ((packed >> 8) & 0xFF) - AXIS_BIAS
	var y: int = (packed & 0xFF) - AXIS_BIAS
	return TickInput.new(packed >> 16, x, y)


## One int: buttons in the high bits, then x, then y (each axis biased into a byte).
func pack() -> int:
	return (buttons << 16) | ((move_x + AXIS_BIAS) << 8) | (move_y + AXIS_BIAS)


func is_pressed(bit: int) -> bool:
	return (buttons >> bit) & 1 == 1
