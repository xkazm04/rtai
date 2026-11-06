class_name ServoDentBot
extends InputSource
## `--bot=boss --servo-ghost=dent` (dev, the Dent-and-the-van clip): BossBot moves, dodges and
## shoots as ever; from START it picks Dent (one G press), takes him (Q), and once settled aims
## at the nearest parked car (the depot's delivery van, bosses.json arenas.depot.parked) and
## taps fire to seize it (DentStage: fire in Dent seizes the car on the aim line). Seized, it
## aims the cursor on Servo (the car drives to it), and presses melee to blow it within BLOW_M.

const START: int = 60
const SETTLE: int = 40
const TAP: int = 20
const BLOW_M: float = 3.0
## The steer point (the cursor's reach) lies this far past Servo's centre.
const PAST_M: float = 1.0

var base: BossBot
var _t0: int = -1
var _strikes: int = 0
var _seizes: int = 0
var _blasts: int = 0


static func wrap(bot: BossBot) -> InputSource:
	var d: ServoDentBot = ServoDentBot.new()
	d.base = bot
	return d


func sample(tick: int) -> TickInput:
	var inp: TickInput = base.sample(tick)
	var hook: BossHook = base.hook
	var pilot: StagePilot = base.stage.pilot
	if hook == null or hook.fight == null or pilot == null:
		return inp
	if _t0 < 0:
		_t0 = tick
	var local: int = tick - _t0 - START
	if local == 0:
		return _press(inp, &"power_gearbox", Vector2.ZERO)
	if local == 2:
		return _press(inp, &"power_hauler", Vector2.ZERO)
	if local < 2 + SETTLE or not pilot.ghosts.settled_in(DentStage.GHOST):
		return inp
	return _drive(inp, pilot.ghosts.dent, local, tick)


## Settled in Dent: tap fire on the nearest car until one is seized, then steer it into Servo.
func _drive(inp: TickInput, dent: DentStage, local: int, tick: int) -> TickInput:
	_log(dent, tick)
	var me: Vector2 = base.stage.arena.rivet.pos
	if dent.car == null:
		var van: Vector2 = _nearest_car(me)
		if van == Vector2.INF:
			return inp
		var tap: StringName = &"fire" if local % TAP == 0 else &""
		return _aimed(inp, tap, (van - me).normalized())
	var servo: Vector2 = base.hook.fight.body.pos
	var blow: bool = dent.car.pos.distance_to(servo) <= BLOW_M + base.hook.fight.body.radius_m
	var reach: float = me.distance_to(servo) + PAST_M  # the cursor on Servo: the car parks on him
	return _aimed(inp, &"melee" if blow else &"", (servo - me).normalized(), reach)


func _log(dent: DentStage, tick: int) -> void:
	if dent.seizes != _seizes or dent.strikes != _strikes or dent.blasts != _blasts:
		_seizes = dent.seizes
		_strikes = dent.strikes
		_blasts = dent.blasts
		Log.info(
			"ghosts",
			(
				"servo dent bot: seizes %d strikes %d blasts %d, tick %d"
				% [_seizes, _strikes, _blasts, tick]
			)
		)


func _nearest_car(me: Vector2) -> Vector2:
	var best: Vector2 = Vector2.INF
	for b: VehicleBody in base.stage.cars():
		if b.state != VehicleBody.State.WRECK and me.distance_to(b.pos) < me.distance_to(best):
			best = b.pos
	return best


## The base move aimed at `aim`, the gun's fire cleared, `action` (if any) pressed this tick.
func _aimed(inp: TickInput, action: StringName, aim: Vector2, reach_m: float = 0.0) -> TickInput:
	var actions: PlayerActions = base.actions
	var buttons: int = PlayerCommand.pack_aim(aim, actions, reach_m)
	if action != &"":
		buttons |= 1 << actions.bit(action)
	return TickInput.new(buttons, inp.move_x, inp.move_y)


func _press(inp: TickInput, action: StringName, aim: Vector2) -> TickInput:
	var buttons: int = 1 << base.actions.bit(action)
	buttons |= PlayerCommand.pack_aim(aim, base.actions) if aim != Vector2.ZERO else inp.buttons
	return TickInput.new(buttons, inp.move_x, inp.move_y)
