class_name RivetTourBot
extends InputSource
## n10 rivet (dev, the defect hunt): walks the weapon in Rivet's claw through every drawn state, in
## each of the 8 aim octants: a slow walk, a run, a stand, the trigger held, a reload, back home.
## Reads only the sim; the recorder (RivetTourRec) reads `phase` / `oct_i` / `in_phase`.
enum Phase { WALK, RUN, STAND, FIRE, RELOAD, HOME, DONE }

const WALK_STICK: float = 0.25
const LEN: PackedInt32Array = [24, 24, 10, 30, 70, 0, 0]
const OCTS: int = 8
const MAX_HOME: int = 240

var phase: Phase = Phase.WALK
var oct_i: int = 0
var in_phase: int = 0
var home: Vector2 = Vector2.ZERO
var _stage: ArenaStage
var _actions: PlayerActions
var _home_ticks: int = 0


func _init(p_stage: ArenaStage, p_actions: PlayerActions, p_home: Vector2) -> void:
	_stage = p_stage
	_actions = p_actions
	home = p_home


func sample(_tick: int) -> TickInput:
	if phase == Phase.DONE:
		return TickInput.new()
	var aim: Vector2 = Vector2.from_angle(oct_i * PI * 0.25)
	var move: Vector2 = Vector2.ZERO
	var buttons: int = PlayerCommand.pack_aim(aim, _actions)
	match phase:
		Phase.WALK:
			move = aim * WALK_STICK
		Phase.RUN:
			move = aim
		Phase.FIRE:
			buttons |= 1 << _actions.bit(&"fire")
		Phase.RELOAD:
			buttons |= (1 << _actions.bit(&"reload")) if in_phase == 0 else 0
		Phase.HOME:
			var at: Vector2 = _stage.arena.rivet.pos
			var walk: float = _stage.arena.tuning.rivet["walk_mps"]
			move = ArenaRivetBot.arrive(home - at, walk, _actions)
	_home_ticks = _home_ticks + 1 if phase == Phase.HOME else 0
	if _home_ticks > MAX_HOME:  # a prop in the way: start the next octant from where he stands
		move = Vector2.ZERO
	_advance(move)
	var m: Vector2 = move * TickInput.AXIS_MAX
	return TickInput.new(buttons, roundi(m.x), roundi(m.y))


func _advance(move: Vector2) -> void:
	in_phase += 1
	var ended: bool = in_phase >= LEN[phase] if phase != Phase.HOME else move == Vector2.ZERO
	if not ended:
		return
	in_phase = 0
	Log.info("rivet", "tour oct %d phase %d done at (%s)" % [oct_i, phase, _stage.arena.rivet.pos])
	if phase == Phase.HOME:
		oct_i += 1
		phase = Phase.WALK if oct_i < OCTS else Phase.DONE
	else:
		phase = (phase + 1) as Phase
