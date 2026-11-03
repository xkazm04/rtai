class_name ArenaPitBot
extends InputSource
## The pit station's scripted player (deterministic: it reads only the sim): through the west
## door to a spot in the pit, then fight every wave: aim at the nearest standing guard, fire
## once it is inside FIRE_M, and strafe across its line of fire (the side flips every
## STRAFE_TICKS) while leaning back to the spot. `done_tick` is when WAVES waves were cleared.

const ENTRY: Array[Vector2] = [Vector2(3.0, 3.0), Vector2(3.0, 10.0), Vector2(14.0, 17.0)]
const REACH_M: float = 0.6
const STRAFE_TICKS: int = 45
const WAVES: int = 2
## Holds fire until the nearest guard is this close (just past their engage_m 12, where they stop
## and shoot), so the guards shoot back and the pit measures dodges and damage, not only
## Rivet's reach (gloria 26 m against 1 hp guards kills every guard before it fires).
const FIRE_M: float = 13.0
## A human's acquire-and-shoot time: the bot fires only after a guard has been inside FIRE_M
## this long (a one-tick bot kills every guard before its first burst; nothing gets measured).
const REACT_TICKS: int = 60

var stage: ArenaStage
var actions: PlayerActions
## False plants the scenario's fault: aim, never fire.
var trigger: bool = true
var next: int = 0
var done_tick: int = -1
var _in_range_since: int = -1


func _init(p_stage: ArenaStage, p_actions: PlayerActions) -> void:
	stage = p_stage
	actions = p_actions


func sample(tick: int) -> TickInput:
	var rivet: Vector2 = stage.arena.rivet.pos
	if done_tick < 0 and stage.pit.waves_cleared >= WAVES:
		done_tick = tick
	if next < ENTRY.size():
		var to: Vector2 = stage.plan.base + ENTRY[next] - rivet
		if to.length() <= REACH_M:
			next += 1
		return _input(to.normalized(), to.normalized(), false)
	var spot: Vector2 = stage.plan.base + ENTRY[ENTRY.size() - 1]
	var foe: Fighter = _nearest(rivet)
	if foe == null:
		_in_range_since = -1
		return _input((spot - rivet).limit_length(1.0), Vector2.DOWN, false)
	var aim: Vector2 = (foe.pos - rivet).normalized()
	var close: bool = rivet.distance_to(foe.pos) <= FIRE_M
	_in_range_since = (tick if _in_range_since < 0 else _in_range_since) if close else -1
	var fire: bool = close and tick - _in_range_since >= REACT_TICKS
	var side: float = 1.0 if (tick / STRAFE_TICKS) % 2 == 0 else -1.0
	var drift: Vector2 = aim.orthogonal() * side * 0.8 + (spot - rivet).limit_length(1.0) * 0.4
	return _input(drift, aim, trigger and fire)


func _nearest(at: Vector2) -> Fighter:
	var best: Fighter = null
	for f: Fighter in stage.pit.standing:
		if f.alive() and (best == null or at.distance_to(f.pos) < at.distance_to(best.pos)):
			best = f
	return best


func _input(move: Vector2, aim: Vector2, fire: bool) -> TickInput:
	var m: Vector2 = move.limit_length(1.0) * TickInput.AXIS_MAX
	var buttons: int = PlayerCommand.pack_aim(aim, actions)
	if fire:
		buttons |= 1 << actions.bit(&"fire")
	return TickInput.new(buttons, roundi(m.x), roundi(m.y))
