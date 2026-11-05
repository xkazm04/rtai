class_name DentLurch
extends RefCounted
## ghost-forms: Dent's stagger (the crash-test dummy's lurch, TARGETS.md ghost_dent_mechanic.jpg)
## read from straight above: the whole body rolls side to side and yaws off its heading once per
## stride, with a limp (one half of the stride hurries, the other drags). Render-side only, stepped
## on sim ticks by GhostFormView; the walk cycle under it is the shared CutRig gait.

## Metres of travel per full lurch (left and right: two steps).
const STRIDE_M: float = 1.5
## Sideways roll at full speed (metres) and the yaw wobble (radians).
const SWAY_M: float = 0.12
const YAW: float = deg_to_rad(15.0)
## The limp: how unevenly the stride's two halves run (0 = even).
const LIMP: float = 0.5
## Speed (m/s) at which the lurch reaches full size; standing still keeps a slow idle sway.
const FULL_MPS: float = 4.0
const IDLE_HZ: float = 0.55
const IDLE_YAW: float = deg_to_rad(2.5)

var phase: float = 0.0
var amount: float = 0.0
var _idle: float = 0.0


func reset() -> void:
	phase = 0.0
	amount = 0.0
	_idle = 0.0


## One sim tick at `speed_mps`.
func step(speed_mps: float, dt: float) -> void:
	phase = fmod(phase + TAU * speed_mps * dt / STRIDE_M, TAU)
	_idle = fmod(_idle + TAU * IDLE_HZ * dt, TAU)
	var want: float = clampf(speed_mps / FULL_MPS, 0.0, 1.0)
	amount = move_toward(amount, want, dt * 4.0)


## The limped phase: the first half of the stride hurries, the second drags.
func limped() -> float:
	return phase + LIMP * sin(phase * 0.5)


## Sideways offset in metres (+ = the body's right).
func sway_m() -> float:
	return sin(limped()) * SWAY_M * amount


## Yaw off the heading (radians): the shoulders lead the roll.
func yaw() -> float:
	return sin(limped() + 0.6) * YAW * amount + sin(_idle) * IDLE_YAW * (1.0 - amount)
