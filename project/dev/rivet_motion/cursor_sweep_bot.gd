class_name CursorSweepBot
extends InputSource
## n11 hero (dev): the player's mouse hand as a script. The cursor circles Rivet on screen while he
## stands, walks a square and sprints, and goes through LiveInput's real projection (not a bot's
## ready-made aim). In the MELEE leg he stands and swings once per cursor octant.

enum Leg { STAND, WALK, SPRINT, MELEE, DONE }

const REV_TICKS: int = 240
const RADIUS_PX: float = 280.0
const LEG_TICKS: int = 480
const MELEE_EVERY: int = 60
const SIDE_TICKS: int = 60
const SIDES: Array[Vector2] = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]

var leg: Leg = Leg.STAND
var in_leg: int = 0
## The cursor this tick, in viewport px (the recorder draws it and measures against it).
var cursor: Vector2 = Vector2.ZERO
var _live: LiveInput
var _actions: PlayerActions
var _centre: Callable


func _init(live: LiveInput, actions: PlayerActions, centre: Callable) -> void:
	_live = live
	_actions = actions
	_centre = centre
	_live.cursor_px = func() -> Vector2: return cursor


func sample(tick: int) -> TickInput:
	var c: Vector2 = _centre.call()
	var turns: float = float(in_leg) / float(REV_TICKS)
	if leg == Leg.MELEE:
		turns = float(int(float(in_leg) / MELEE_EVERY)) / 8.0  # one held octant per swing
	cursor = c + Vector2.from_angle(TAU * turns) * RADIUS_PX
	var input: TickInput = _live.sample(tick)
	var buttons: int = input.buttons
	var move: Vector2 = Vector2.ZERO
	if leg == Leg.WALK or leg == Leg.SPRINT:
		move = SIDES[(in_leg / SIDE_TICKS) % SIDES.size()]
	if leg == Leg.SPRINT:
		buttons |= 1 << _actions.bit(&"sprint")
	if leg == Leg.MELEE and in_leg % MELEE_EVERY == 20:
		buttons |= 1 << _actions.bit(&"melee")
	_advance()
	var m: Vector2 = move * TickInput.AXIS_MAX
	return TickInput.new(buttons, roundi(m.x), roundi(m.y))


func _advance() -> void:
	in_leg += 1
	if leg != Leg.DONE and in_leg >= LEG_TICKS:
		in_leg = 0
		leg = (leg + 1) as Leg
