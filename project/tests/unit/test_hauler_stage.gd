extends GutTest
## features/souls HaulerStage on quest 1's stage through the bound pilot: Q (power_hauler) turns
## Rivet into the tank, the melee press arms the stomp (no jab), the stomp hurts every guard in
## its radius and leaves one outside it, the tank's heavy movement replaces the walk.

var _bus: EventBus
var _data: DataStore
var _stage: CollectCallStage
var _pilot: StagePilot
var _prev: int = 0


func before_each() -> void:
	_bus = autofree(EventBus.new())
	_data = autofree(DataStore.new())
	_stage = CollectCallStage.new(StageLayout.shipped())
	_stage.setup(World.build_context(_bus, _data, 1))
	_pilot = StagePilot.new(PlayerActions.shipped())
	_stage.pilot = _pilot
	_stage.arena.rivet.pos = Vector2(200.0, 200.0)


func _press(action: StringName, move_x: int = 0) -> void:
	var buttons: int = 1 << _pilot.actions.bit(action) if action != &"" else 0
	_pilot.drive(_stage, TickInput.new(buttons, move_x, 0))
	_stage.intent.clear()


func _ticks(n: int, move_x: int = 0) -> void:
	for i: int in n:
		_press(&"", move_x)


func _ring(r: float) -> Array[Fighter]:
	var out: Array[Fighter] = []
	for i: int in 4:
		out.append(_guard(Vector2.from_angle(i * TAU / 4) * r))
	return out


## spawn_guard spreads its spawn at random: pin the guard exactly `off` from Rivet.
func _guard(off: Vector2) -> Fighter:
	var g: Fighter = _stage.arena.spawn_guard(_stage.arena.rivet.pos)
	g.pos = _stage.arena.rivet.pos + off
	return g


func test_q_transforms_and_the_melee_press_stomps_the_ring() -> void:
	var near: Array[Fighter] = _ring(1.5)
	var far: Fighter = _guard(Vector2(9.0, 0.0))
	_press(&"power_hauler")
	assert_true(_pilot.hauler.form.on, "Q turned Rivet into the tank")
	assert_eq(_pilot.hauler.form.body_class, &"rivet_ghost")
	_ticks(2)
	_press(&"melee")
	assert_eq(_pilot.melee_swings, 0, "the tank's melee press is the stomp, not the jab")
	_ticks(40)
	assert_eq(_pilot.hauler.form.stomps, 1)
	for g: Fighter in near:
		assert_false(g.alive(), "a guard 1.5 m out died in the stomp")
	assert_true(far.alive(), "a guard 9 m out is outside the 4 m stomp")
	assert_eq(_pilot.hauler.stomp_hits, 4)


func test_without_the_power_melee_is_the_jab_and_nothing_stomps() -> void:
	var near: Array[Fighter] = _ring(1.5)
	_press(&"melee")
	_ticks(20)
	assert_eq(_pilot.melee_swings, 1)
	assert_eq(_pilot.hauler.form.stomps, 0)
	assert_eq(near.filter(func(g: Fighter) -> bool: return g.alive()).size(), 3)


func test_the_tank_has_momentum_and_a_lower_top_speed() -> void:
	_press(&"power_hauler")
	_ticks(60, TickInput.AXIS_MAX)
	var top: float = _pilot.hauler.form.num(&"top_mps")
	assert_almost_eq(_pilot.hauler.form.vel.length(), top, 0.01, "at the tank's top speed")
	_ticks(1, 0)
	assert_gt(_pilot.hauler.form.vel.length(), top * 0.5, "no instant stop: momentum carries")
