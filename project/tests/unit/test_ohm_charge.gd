extends GutTest

var _stage: CollectCallStage
var _o: OhmStage
var _charge: OhmCharge


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	_stage = CollectCallStage.new(StageLayout.shipped())
	_stage.setup(World.build_context(bus, data, 1))
	_o = OhmStage.shipped()
	_charge = OhmCharge.new()


func _tick(press: bool = false, power: bool = false) -> void:
	_stage.tick += 1
	_o.drive(_stage, power, press, Vector2.RIGHT)
	_charge.step(_o, _stage.tick)


func _jars() -> Vector3:
	return Vector3(_charge.jar(0), _charge.jar(1), _charge.jar(2))


func test_press_flashes_then_refills_the_jars_in_order() -> void:
	_tick(false, true)
	assert_true(_charge.ready())
	assert_eq(_jars(), Vector3.ONE)
	_tick(true)
	assert_false(_charge.ready())
	assert_eq(_jars(), Vector3.ZERO)
	assert_eq(_charge.flash(), 1.0)
	var gap: int = PowerDef.ticks(_o.num(&"bolt_gap_s"))
	for age: int in range(1, gap + 1):
		_tick()
		var filled: float = 3.0 * age / gap
		for i: int in 3:
			assert_almost_eq(_charge.jar(i), clampf(filled - i, 0.0, 1.0), 0.00001)
		assert_almost_eq(_charge.flash(), maxf(0.0, 1.0 - age / 6.0), 0.00001)
		assert_eq(_charge.vent(), 0.0)
		assert_eq(_charge.ready(), age == gap)


func test_unpowered_jars_are_empty() -> void:
	_tick()
	assert_eq(_jars(), Vector3.ZERO)
	assert_false(_charge.ready())


func test_pending_cast_holds_all_jars_lit_until_release() -> void:
	_o.cast.delay_ticks = 3
	_tick(false, true)
	_tick(true)
	for age: int in 3:
		assert_true(_charge.ready())
		assert_eq(_jars(), Vector3.ONE)
		assert_eq(_charge.flash(), 0.0)
		_tick()
	assert_eq(_charge.flash(), 1.0)
	assert_eq(_charge.vent(), 0.0)
	assert_eq(_jars(), Vector3.ZERO)
	assert_false(_charge.ready())


func test_interrupted_cast_vents_once_on_the_sim_clock() -> void:
	_o.cast.delay_ticks = 3
	_tick(false, true)
	_tick(true)
	_stage.arena.rivet.take(0.25, _stage.tick, Vector2.LEFT)
	_tick()
	assert_eq(_charge.vent(), 1.0)
	for age: int in range(26):
		_charge.step(_o, _stage.tick)  # A second render of this tick holds the same state.
		assert_almost_eq(_charge.vent(), maxf(0.0, 1.0 - age / 24.0), 0.00001)
		assert_eq(_charge.flash(), 0.0)
		assert_false(_charge.ready())
		_tick()


func test_repeated_steps_from_the_same_input_are_deterministic() -> void:
	var twin: OhmCharge = OhmCharge.new()
	for i: int in 60:
		_tick(i == 2 or i == 45, i == 1)
		twin.step(_o, _stage.tick)
		assert_eq(_jars(), Vector3(twin.jar(0), twin.jar(1), twin.jar(2)))
		assert_eq(_charge.flash(), twin.flash())
		assert_eq(_charge.vent(), twin.vent())
		assert_eq(_charge.ready(), twin.ready())
