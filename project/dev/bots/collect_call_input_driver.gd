class_name CollectCallInputDriver
extends RefCounted
## Plays quest 1 through the bound input, the way a pad in a player's hands would: each tick
## CollectCallBot decides (into the stage's intent), then this turns the decision into simulated
## input events (InputEventJoypadMotion for the left stick, the right stick aim and the fire
## trigger, the interact action's bound InputEventKey) through Input.parse_input_event, and
## clears the intent, so Rivet moves only through LiveInput -> TickInput -> StagePilot, never
## the bot's direct calls. The stick is proportional to the distance left (an arriving thumb).

const STICK_GAIN: float = 8.0
## The least push past the stick dead zone, so the last few cm still move Rivet (a thumb that
## arrives instead of resting short of the mark).
const STICK_FLOOR: float = 0.02
const STAND_M: float = 0.15

var bot: CollectCallBot
var presses: int = 0
var events_sent: int = 0
var _stage: CollectCallStage
var _interact_down: bool = false


func _init(stage: CollectCallStage, system: QuestSystem) -> void:
	_stage = stage
	bot = CollectCallBot.new(stage, system)
	bot.stand_m = STAND_M
	bot.waits_for_hit = stage.cells == null


func done() -> bool:
	return bot.done()


## Decides this tick and sends the events; call before the loop's step.
func act() -> void:
	bot.act()
	var intent: StageIntent = _stage.intent
	var stick: Vector2 = Vector2.ZERO
	if intent.move_to != Vector2.INF:
		var walk: float = _stage.arena.tuning.rivet["walk_mps"]
		stick = ((intent.move_to - _stage.arena.rivet.pos) * STICK_GAIN / walk).limit_length(1.0)
		var least: float = _stage.pilot.actions.stick_deadzone + STICK_FLOOR
		if stick != Vector2.ZERO and stick.length() < least:
			stick = stick.normalized() * least
	_axis(JOY_AXIS_LEFT_X, stick.x)
	_axis(JOY_AXIS_LEFT_Y, stick.y)
	var aim: Vector2 = Vector2.ZERO
	if intent.fire_at != Vector2.INF:
		aim = (intent.fire_at - _stage.arena.rivet.pos).normalized()
	_axis(JOY_AXIS_RIGHT_X, aim.x)
	_axis(JOY_AXIS_RIGHT_Y, aim.y)
	_axis(JOY_AXIS_TRIGGER_RIGHT, 1.0 if aim != Vector2.ZERO else 0.0)
	var want: bool = intent.interact and not _interact_down
	if want:
		presses += 1
	_key(want)
	intent.clear()
	Input.flush_buffered_events()


## Lets go of everything (the run is over).
func release() -> void:
	for axis: JoyAxis in [JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y, JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y]:
		_axis(axis, 0.0)
	_axis(JOY_AXIS_TRIGGER_RIGHT, 0.0)
	_key(false)
	Input.flush_buffered_events()


func _axis(axis: JoyAxis, value: float) -> void:
	var ev: InputEventJoypadMotion = InputEventJoypadMotion.new()
	ev.device = 0
	ev.axis = axis
	ev.axis_value = value
	Input.parse_input_event(ev)
	events_sent += 1


func _key(down: bool) -> void:
	if down == _interact_down:
		return
	_interact_down = down
	var ev: InputEvent = null
	for bound: InputEvent in InputMap.action_get_events(&"interact"):
		if bound is InputEventKey:
			ev = bound.duplicate()
			break
	var key: InputEventKey = ev as InputEventKey
	key.pressed = down
	Input.parse_input_event(ev)
	events_sent += 1
