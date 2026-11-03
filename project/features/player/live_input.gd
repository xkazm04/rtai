class_name LiveInput
extends InputSource
## Live devices into one TickInput per tick (SIM-05: the sim sees only these ints, so a recorded
## run replays bit-identically). The move stick from the move_* actions (keys, d-pad or the left
## stick), the buttons from the bit-carrying actions, and the aim heading from the right stick
## when it is pushed, else from the mouse relative to `origin_px` (Rivet on screen).

var actions: PlayerActions
## Rivet's position in viewport pixels; the mouse aim is the heading from here to the cursor.
var origin_px: Callable = func() -> Vector2: return Vector2.INF
var viewport: Viewport = null
## false while a menu is open: the sim then sees idle input.
var enabled: bool = true
## true once the mouse moved last, false once a pad was used last: a released right stick
## then faces the walk direction instead of snapping to wherever the cursor rests.
var mouse_aims: bool = true
## true once a pad was used last, false once a key or the mouse was: the prompts name the pad's
## buttons or the keys (aim is not affected; that is mouse_aims).
var pad_last: bool = false


func _init(p_actions: PlayerActions) -> void:
	actions = p_actions


func sample(_tick: int) -> TickInput:
	if not enabled:
		return TickInput.new()
	var move: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	var buttons: int = 0
	for action: StringName in actions.bits:
		if Input.is_action_pressed(action):
			buttons |= 1 << actions.bits[action]
	buttons |= PlayerCommand.pack_aim(_aim(), actions)
	var k: float = float(TickInput.AXIS_MAX)
	return TickInput.new(buttons, roundi(move.x * k), roundi(move.y * k))


## The game forwards its input events here to track which device aims.
func note_event(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		mouse_aims = true
		pad_last = false
	elif event is InputEventKey:
		pad_last = false
	elif event is InputEventJoypadMotion or event is InputEventJoypadButton:
		var motion: InputEventJoypadMotion = event as InputEventJoypadMotion
		if motion == null or absf(motion.axis_value) >= actions.stick_deadzone:
			mouse_aims = false
			pad_last = true


func _aim() -> Vector2:
	var stick: Vector2 = Input.get_vector(&"aim_left", &"aim_right", &"aim_up", &"aim_down")
	if stick.length() >= actions.stick_deadzone:
		return stick.normalized()
	var from: Vector2 = origin_px.call()
	if not mouse_aims or viewport == null or from == Vector2.INF:
		return Vector2.ZERO
	var d: Vector2 = viewport.get_mouse_position() - from
	return d.normalized() if d.length() > 4.0 else Vector2.ZERO
