extends GutTest
## rivet-arsenal: the movement feel numbers measured through the live pilot (RivetFeel over
## StagePilot) match the tables they come from: walk top speed, the stop from it (v^2 / 2 brake),
## the 180-degree aim turn at turn_dps, sprint top speed. Planted fault: a near-zero brake never
## stops inside the settle window.

var _feel: RivetFeel


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	_feel = RivetFeel.new(bus, data)


func test_walk_stops_in_the_braking_distance() -> void:
	var walk: Dictionary = _feel.run([])
	var top: float = walk["top_mps"]
	var brake: float = _feel.pilot.actions.brake_mps2
	assert_gt(top, 4.0, "walk top speed")
	var stop_m: float = walk["stop_m"]
	var stop_ticks: int = walk["stop_ticks"]
	assert_almost_eq(stop_m, top * top / (2.0 * brake), 0.06, "v^2 / 2 brake")
	assert_lt(stop_ticks, 10, "stopped within 10 ticks")


func test_sprint_is_faster_and_stops_longer() -> void:
	var sprint: Dictionary = _feel.run([&"sprint"])
	var top: float = sprint["top_mps"]
	var stop_m: float = sprint["stop_m"]
	assert_almost_eq(top, _feel.pilot.motion.sprint_mps, 0.01)
	assert_gt(stop_m, 0.3)


func test_aim_turn_is_turn_dps() -> void:
	var want: int = ceili((180.0 - RivetFeel.TURN_DONE_DEG) / (_feel.pilot.actions.turn_dps / 60.0))
	assert_eq(_feel.aim_turn_ticks(), want, "180 degrees at turn_dps, 5 degrees short")


func test_planted_fault_no_brake_never_stops() -> void:
	_feel.pilot.actions.brake_mps2 = 0.01
	var walk: Dictionary = _feel.run([])
	var stop_ticks: int = walk["stop_ticks"]
	assert_eq(stop_ticks, -1, "the planted fault: the walk coasts on")
