class_name GhostRefusalCue
extends RefCounted
## n31 ghost 26: a refused ghost press answers on the refused form's HUD chip. GhostFormHud.sync
## feeds the deploy's view-only refusal counter once per frame; a change starts an 18-frame cue:
## the chip shakes sideways, an amber rim (colour law: amber = a cancelled cast) fades out, and a
## cooldown refusal also flashes the cooling arc. Frames are counted per sync, never by time.

const FRAMES: int = 18
const SHAKE_PX: float = 6.0
const SHAKE_PERIOD: float = 6.0
const AMBER: Color = Color("f0a030")
const RIM_PX: float = 3.0

## The chip the cue runs on (&"" = none yet).
var form: StringName = &""
## Frames since the cue started; FRAMES or more = idle.
var frame: int = FRAMES
## True when the running cue answers a cooldown refusal.
var cooldown: bool = false
var _seen: int = 0


## Once per HUD frame: a changed counter (re)starts the cue on its form, else the cue steps on.
func sync(deploy: GhostDeploy) -> void:
	if deploy == null:
		notice(_seen, form, cooldown)
	else:
		notice(deploy.refusals, deploy.refused_form, deploy.last_refusal == &"cooldown")


func notice(refusals: int, id: StringName, on_cooldown: bool) -> void:
	if refusals != _seen:
		_seen = refusals
		form = id
		cooldown = on_cooldown
		frame = 0
	elif frame < FRAMES:
		frame += 1


func active(id: StringName) -> bool:
	return id == form and frame < FRAMES


## 0 at the start of the cue, 1 at its end.
func k() -> float:
	return float(frame) / FRAMES


## The chip's sideways shake this frame (zero off the cue).
func offset(id: StringName) -> Vector2:
	if not active(id):
		return Vector2.ZERO
	return Vector2(SHAKE_PX * sin(frame * TAU / SHAKE_PERIOD) * (1.0 - k()), 0.0)


## The amber rim's colour this frame (transparent off the cue).
func rim(id: StringName) -> Color:
	return Color(AMBER, 1.0 - k()) if active(id) else Color(AMBER, 0.0)


## The cooling arc's colour: the base colour, flashed toward white on a cooldown cue.
func arc(id: StringName, base: Color) -> Color:
	if not (cooldown and active(id)):
		return base
	return base.lerp(Color.WHITE, 1.0 - k())
