class_name ServoGhostBot
extends InputSource
## `--bot=boss --servo-ghost=<dent|kerf|ohm>` (dev, the ghost-on-the-drones clips): BossBot moves,
## dodges and shoots as ever; from START it picks the ghost (G presses, order tonnage, dent,
## kerf, ohm), takes it (Q), then at most every CADENCE ticks aims the ghost attack (melee) at
## the thickest knot (KNOT_MIN or more) of the boss's extra bodies (Servo's drones) within
## REACH_M, else (every 2 CADENCE) at the boss. While a knot is in reach the gun holds fire:
## the drones are left to the ghost. Once the form runs out it is the plain boss bot again.

const ORDER: Array[StringName] = [&"tonnage", &"dent", &"kerf", &"ohm"]
const START: int = 60
const SETTLE: int = 40
const CADENCE: int = 45
const REACH_M: float = 10.0
const KNOT_M: float = 3.0
const KNOT_MIN: int = 2

var base: BossBot
var ghost_index: int = -1
## Ghost attacks aimed at a drone knot, and at the boss (the clip's log line).
var at_knot: int = 0
var at_boss: int = 0
var _t0: int = -1
var _last: int = -CADENCE


static func wrap(bot: BossBot, ghost: String) -> InputSource:
	var g: ServoGhostBot = ServoGhostBot.new()
	g.base = bot
	g.ghost_index = ORDER.find(StringName(ghost))
	return g


func sample(tick: int) -> TickInput:
	var inp: TickInput = base.sample(tick)
	var hook: BossHook = base.hook
	if hook == null or hook.fight == null or ghost_index < 0:
		return inp
	if _t0 < 0:
		_t0 = tick
	var local: int = tick - _t0 - START
	var picked: int = ghost_index * 2
	if local >= 0 and local < picked and local % 2 == 0:
		return _press(inp, &"power_gearbox", Vector2.ZERO)
	if local == picked + 2:
		return _press(inp, &"power_hauler", Vector2.ZERO)
	var pilot: StagePilot = base.stage.pilot
	var live: bool = pilot != null and pilot.ghosts.settled_in(ORDER[ghost_index])
	if local - picked < SETTLE or not live:  # settling, or the form ran out: the plain boss bot
		return inp
	return _strike(inp, hook, local - picked - SETTLE, tick)


## In the settled form: hold the gun while a knot is in reach, press the attack on the cadence.
func _strike(inp: TickInput, hook: BossHook, since: int, tick: int) -> TickInput:
	var me: Vector2 = base.stage.arena.rivet.pos
	var at: Vector2 = _knot(hook, me)
	if at != Vector2.INF:
		inp.buttons &= ~(1 << base.actions.bit(&"fire"))
	var wait: int = since - _last
	if wait < CADENCE or (at == Vector2.INF and wait < CADENCE * 2):
		return inp
	_last = since
	var what: String = "drone knot"
	if at == Vector2.INF:
		at = hook.fight.body.pos
		at_boss += 1
		what = "boss"
	else:
		at_knot += 1
	Log.info("ghosts", "boss ghost bot: %s at a %s, tick %d" % [ORDER[ghost_index], what, tick])
	return _press(inp, &"melee", (at - me).normalized())


## The live extra body within REACH_M with the most others within KNOT_M of it (INF if none).
func _knot(hook: BossHook, me: Vector2) -> Vector2:
	var best: Vector2 = Vector2.INF
	var best_n: int = -1
	var bodies: Array[Fighter] = hook.fight.moves.bodies()
	for b: Fighter in bodies:
		if not b.alive() or me.distance_to(b.pos) > REACH_M:
			continue
		var n: int = 0
		for o: Fighter in bodies:
			n += 1 if o.alive() and o.pos.distance_to(b.pos) <= KNOT_M else 0
		if n >= KNOT_MIN and n > best_n:
			best_n = n
			best = b.pos
	return best


## The base tick's move with one action pressed (aimed at `aim` when it is not zero).
func _press(inp: TickInput, action: StringName, aim: Vector2) -> TickInput:
	var actions: PlayerActions = base.actions
	var buttons: int = 1 << actions.bit(action)
	buttons |= PlayerCommand.pack_aim(aim, actions) if aim != Vector2.ZERO else inp.buttons
	return TickInput.new(buttons, inp.move_x, inp.move_y)
