extends "res://dev/ghost-powers/quest_hauler_rec.gd"
## Tonnage's press slam on quest 1's street car (collect_call_city.json ghost_cars, the
## start-side one), in quest 1's real view through bound input only: Start, dock guards round
## the car, Q (power_hauler), the left stick walks the press toward the car until its head is in
## car_crush_m reach, then the melee press (the slam: the car flattened, the guards thrown) and a
## second slam later. One tick per frame, a PNG every tick. Dev-only:
##   godot --rendering-driver d3d12 --path project res://dev/ghost-powers/quest_crush_rec.tscn
##     -- --out=<abs dir> [--ppm=<32|48|64>]

const TICKS: int = 300
const TAKE_AT: int = 10
## The press stops walking once the car's centre is this close (the head lands press_ahead_m 0.9
## ahead, so a centre within car_crush_m 3.4 + 0.9 is in reach; the solid car holds him ~2.5 m off).
const STOP_M: float = 3.4
const SECOND_SLAM: int = 220
const GUARDS: Array[Vector2] = [
	Vector2(-1.6, 1.4), Vector2(1.8, 1.5), Vector2(0.0, 2.2), Vector2(-3.0, 0.4), Vector2(2.9, -0.2)
]


func _run() -> void:
	var s: Quest1Session = _game.session
	for i: int in WARM:
		s.step()
	var stage: CollectCallStage = s.stage
	var car: VehicleBody = _near_car(stage)
	for off: Vector2 in GUARDS:
		var g: Fighter = stage.arena.spawn_guard(car.pos + off)
		g.pos = car.pos + off
	var slam_at: int = -1
	for t: int in TICKS:
		var gap: Vector2 = car.pos - stage.arena.rivet.pos
		var walk: bool = t > TAKE_AT + 30 and slam_at < 0 and gap.length() > STOP_M
		if t > TAKE_AT + 30 and slam_at < 0 and not walk:
			slam_at = t
		_tap(&"power_hauler", t == TAKE_AT)
		_tap(&"melee", t == slam_at or t == SECOND_SLAM)
		_stick2(gap.normalized() * 0.9 if walk else Vector2.ZERO)
		Input.flush_buffered_events()
		s.step()
		await _save()
		await _hold(s.world.context().clock)
	var h: HaulerStage = stage.pilot.hauler
	var line: String = "slam at %d stomps %d stomp_hits %d cars_crushed %d kills %d car %s"
	var state: String = VehicleBody.State.keys()[car.state]
	Log.info(
		"quest_crush",
		line % [slam_at, h.form.stomps, h.stomp_hits, h.cars_crushed, stage.arena.kills, state]
	)


func _near_car(stage: CollectCallStage) -> VehicleBody:
	var rivet: Vector2 = stage.arena.rivet.pos
	var best: VehicleBody = null
	for b: VehicleBody in stage.cars():
		if best == null or rivet.distance_to(b.pos) < rivet.distance_to(best.pos):
			best = b
	return best


func _stick2(v: Vector2) -> void:
	for axis: JoyAxis in [JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y]:
		var ev: InputEventJoypadMotion = InputEventJoypadMotion.new()
		ev.axis = axis
		ev.axis_value = v.x if axis == JOY_AXIS_LEFT_X else v.y
		Input.parse_input_event(ev)
