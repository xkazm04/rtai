class_name RivetFeel
extends RefCounted
## rivet-arsenal: the movement feel numbers measured through the live pilot (StagePilot on a
## CollectCallStage, the path quest 1, the arena and the city block drive), on open ground, 60 Hz
## tick-true: top speed and the ticks to reach 90 % of it, the stop (distance and ticks from top
## speed to standstill once the stick is let go), the 180-degree aim turn (ticks until the facing
## is within 5 degrees of the new aim) and the reversal (ticks until the walk velocity points the
## other way). Walk and sprint. Read by feel_main.gd (evidence JSON) and test_live_feel.

const SETTLE_TICKS: int = 120
const TURN_DONE_DEG: float = 5.0

var stage: CollectCallStage
var pilot: StagePilot


func _init(bus: EventBus, data: DataStore) -> void:
	stage = CollectCallStage.new(StageLayout.shipped())
	stage.setup(World.build_context(bus, data, 1))
	pilot = StagePilot.new(PlayerActions.shipped())
	stage.pilot = pilot
	stage.arena.rivet.pos = Vector2(200.0, 200.0)


## One tick through the pilot; returns Rivet's displacement (m).
func drive(move_x: int, held: Array[StringName], aim: Vector2 = Vector2.ZERO) -> Vector2:
	var buttons: int = 0
	for a: StringName in held:
		buttons |= 1 << pilot.actions.bit(a)
	if aim != Vector2.ZERO:
		buttons |= PlayerCommand.pack_aim(aim, pilot.actions)
	pilot.drive(stage, TickInput.new(buttons, move_x, 0))
	var by: Vector2 = stage.intent.move_by
	stage.arena.rivet.pos += by
	stage.intent.clear()
	return by


## {top_mps, to_90_ticks, stop_m, stop_ticks, reverse_ticks} walking (or sprinting) along +x.
func run(held: Array[StringName]) -> Dictionary:
	var out: Dictionary = {}
	var top: float = 0.0
	var to_90: int = -1
	var speeds: Array[float] = []
	for t: int in SETTLE_TICKS:
		speeds.append(drive(TickInput.AXIS_MAX, held).length() / SimClock.TICK_DT)
	top = speeds[speeds.size() - 1]
	for t: int in speeds.size():
		if to_90 < 0 and speeds[t] >= 0.9 * top:
			to_90 = t + 1
	out["top_mps"] = top
	out["to_90_ticks"] = to_90
	var stop: Dictionary = _stop()
	out["stop_m"] = stop["m"]
	out["stop_ticks"] = stop["ticks"]
	for t: int in SETTLE_TICKS:
		@warning_ignore("return_value_discarded")
		drive(TickInput.AXIS_MAX, held)
	out["reverse_ticks"] = _reverse(held)
	return out


## Ticks for the facing to swing 180 degrees onto a new aim (aim held right, then left).
func aim_turn_ticks() -> int:
	for t: int in 30:
		@warning_ignore("return_value_discarded")
		drive(0, [], Vector2.RIGHT)
	for t: int in SETTLE_TICKS:
		@warning_ignore("return_value_discarded")
		drive(0, [], Vector2.LEFT)
		if absf(rad_to_deg(pilot.motion.facing().angle_to(Vector2.LEFT))) <= TURN_DONE_DEG:
			return t + 1
	return -1


func _stop() -> Dictionary:
	var m: float = 0.0
	for t: int in SETTLE_TICKS:
		var by: Vector2 = drive(0, [])
		m += by.length()
		if by == Vector2.ZERO:
			return {"m": m, "ticks": t}
	return {"m": m, "ticks": -1}


func _reverse(held: Array[StringName]) -> int:
	for t: int in SETTLE_TICKS:
		if drive(-TickInput.AXIS_MAX, held).x < 0.0:
			return t + 1
	return -1
