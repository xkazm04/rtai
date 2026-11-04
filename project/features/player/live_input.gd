class_name LiveInput
extends InputSource
## Live devices into one TickInput per tick (SIM-05: the sim sees only these ints, so a recorded
## run replays bit-identically). The move stick from the move_* actions (keys, d-pad or the left
## stick), the buttons from the bit-carrying actions, and the aim heading from the right stick
## when it is pushed, else from the mouse relative to `origin_px` (Rivet on screen).

var actions: PlayerActions
## Rivet's position in viewport pixels; the mouse aim is the heading from here to the cursor.
var origin_px: Callable = func() -> Vector2: return Vector2.INF
## Lane gunplay: screen pixels per world metre (0 = the cursor's distance is not sent).
var px_per_m: Callable = func() -> float: return 0.0
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
	buttons |= PlayerCommand.pack_aim(_aim(), actions, _reach_m())
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


## The cursor's distance from Rivet in metres while the mouse aims; with the pad, how far the right
## stick is pushed (0 with no scale or a released stick).
func _reach_m() -> float:
	var stick: Vector2 = Input.get_vector(&"aim_left", &"aim_right", &"aim_up", &"aim_down")
	if stick.length() >= actions.stick_deadzone:
		return stick_reach_m(stick.length(), actions)
	var from: Vector2 = origin_px.call()
	var ppm: float = px_per_m.call()
	if not mouse_aims or viewport == null or from == Vector2.INF or ppm <= 0.0:
		return 0.0
	return viewport.get_mouse_position().distance_to(from) / ppm


## Lane gunplay: a pad throws by how far the right stick is pushed: just past the deadzone lands
## one reach step out, a full push the fixed aim_range_m lob (so a pad player who flicks the
## stick all the way throws as before). 0 when the reach bits are off.
static func stick_reach_m(deflection: float, a: PlayerActions) -> float:
	if a.aim_reach_step_m <= 0.0:
		return 0.0
	var t: float = clampf((deflection - a.stick_deadzone) / (1.0 - a.stick_deadzone), 0.0, 1.0)
	return lerpf(a.aim_reach_step_m, a.aim_range_m, t)
