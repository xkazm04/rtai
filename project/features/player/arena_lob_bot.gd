class_name ArenaLobBot
extends InputSource
## rivet-arsenal's scripted thrower (--bot=lob --loadout=molotov): walks to LOB_SPOT at the hub's
## west end, then holds fire aimed at the nearest live claw cop (station rivet_claw_cops, 6.7-16 m
## east on y 4.4), so the wind-up, the bottle's arc and the landing read in one frame at 32 px/m.
## The cops walk at Rivet and stand up again 150 ticks after they burn, so the throws go on.
## Deterministic: it reads only the sim.

const LOB_SPOT: Vector2 = Vector2(-2.0, -0.5)
const REACH_M: float = 0.12
const AIM_MAX_M: float = 16.0
## The nearest cop this close is a melee matter: the bot holds its fire (the patch would reach it).
const TOO_CLOSE_M: float = 5.0

var stage: ArenaStage
var actions: PlayerActions
var arrived_tick: int = -1


func _init(p_stage: ArenaStage, p_actions: PlayerActions) -> void:
	stage = p_stage
	actions = p_actions


func sample(tick: int) -> TickInput:
	var at: Vector2 = stage.arena.rivet.pos
	var to: Vector2 = stage.plan.base + LOB_SPOT - at
	if arrived_tick < 0:
		if to.length() > REACH_M:
			var m: Vector2 = to.normalized() * TickInput.AXIS_MAX
			return TickInput.new(0, roundi(m.x), roundi(m.y))
		arrived_tick = tick
	var foe: Fighter = _nearest(at)
	if foe == null:
		return TickInput.new()
	var buttons: int = PlayerCommand.pack_aim((foe.pos - at).normalized(), actions)
	if foe.pos.distance_to(at) > TOO_CLOSE_M:
		buttons |= 1 << actions.bit(&"fire")
	return TickInput.new(buttons)


## The nearest live claw cop (other stations' lines stand on the hub too: never aimed at).
func _nearest(at: Vector2) -> Fighter:
	var best: float = AIM_MAX_M
	var out: Fighter = null
	for hook: ArenaHook in stage.hooks:
		var station: ArenaClawCops = hook as ArenaClawCops
		if station == null:
			continue
		for f: Fighter in station.cops:
			var d: float = f.pos.distance_to(at)
			if f.alive() and d < best:
				best = d
				out = f
	return out
