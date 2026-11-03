class_name ArenaRangeBot
extends InputSource
## The range station's scripted player (deterministic: it reads only the sim): walk to the firing
## line, then aim at each dummy in turn and hold fire for DWELL_TICKS, strafing while it shoots.
## Its TickInputs go through the same InputTape as live play, so a run records and replays.

const DWELL_TICKS: int = 120
const FIRING_SPOT: Vector2 = Vector2(0.0, -12.0)

var stage: ArenaStage
var actions: PlayerActions
## False plants the scenario's fault: aim, never fire.
var trigger: bool = true


func _init(p_stage: ArenaStage, p_actions: PlayerActions) -> void:
	stage = p_stage
	actions = p_actions


func sample(tick: int) -> TickInput:
	var rivet: Vector2 = stage.arena.rivet.pos
	var spot: Vector2 = stage.plan.base + FIRING_SPOT
	var to_spot: Vector2 = spot - rivet
	if to_spot.length() > 0.6 and tick < 240:
		return _input(to_spot.normalized(), to_spot.normalized(), false)
	var list: Array[ArenaTargets.Target] = stage.targets.targets
	if list.is_empty():
		return TickInput.new()
	var t: ArenaTargets.Target = list[(tick / DWELL_TICKS) % list.size()]
	var aim: Vector2 = (t.fighter.pos - rivet).normalized()
	var side: float = 1.0 if (tick / 60) % 2 == 0 else -1.0
	var drift: Vector2 = aim.orthogonal() * side * 0.5 + to_spot.limit_length(1.0) * 0.5
	return _input(drift, aim, trigger)


func _input(move: Vector2, aim: Vector2, fire: bool) -> TickInput:
	var m: Vector2 = move.limit_length(1.0) * TickInput.AXIS_MAX
	var buttons: int = PlayerCommand.pack_aim(aim, actions)
	if fire:
		buttons |= 1 << actions.bit(&"fire")
	return TickInput.new(buttons, roundi(m.x), roundi(m.y))
