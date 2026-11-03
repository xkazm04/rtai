extends GutTest
## features/audio: the engine pitch follows the driven car, the boss loop follows the boss fight,
## and the vehicles lane's wreck is voiced.

var _bus: EventBus = null
var _service: AudioService = null
var _hooks: AudioHooks = null


func before_each() -> void:
	_bus = EventBus.new()
	add_child_autofree(_bus)
	_service = AudioService.new(AudioTables.shipped(), 3)
	add_child_autofree(_service)
	_hooks = AudioHooks.new()
	_service.add_child(_hooks)
	_hooks.attach(
		_service, _bus, func() -> int: return 1000, func() -> Vector2: return Vector2.ZERO
	)
	_bus.vehicle_entered.emit(1)


func _drive(mps: float, frames: int) -> void:
	var dt: float = 1.0 / 60.0
	var x: float = 0.0
	_hooks.drive_to(Vector2(x, 0.0), dt)
	for i: int in frames:
		x += mps * dt
		_hooks.drive_to(Vector2(x, 0.0), dt)


func test_the_engine_climbs_with_speed() -> void:
	_drive(2.0, 120)
	var slow: float = _service.loops.pitch(&"engine_loop")
	_drive(24.0, 240)
	var fast: float = _service.loops.pitch(&"engine_loop")
	assert_gt(fast, slow + 0.4, "24 m/s is well above 2 m/s")
	assert_between(fast, 1.4, 1.6)
	assert_between(slow, 0.75, 0.95)


func test_a_stopped_car_idles_low() -> void:
	_drive(0.0, 120)
	assert_almost_eq(_service.loops.pitch(&"engine_loop"), 0.75, 0.01)


func test_the_boss_loop_runs_from_the_boss_to_the_contract_end() -> void:
	assert_false(_service.loops.is_on(&"boss_loop"))
	_bus.boss_engaged.emit(&"quartermaster-mertz")
	assert_true(_service.loops.is_on(&"boss_loop"))
	var stings: int = _service.played.get(&"boss_stinger", 0)
	assert_eq(stings, 1)
	_bus.contract_completed.emit(&"collect-call")
	assert_false(_service.loops.is_on(&"boss_loop"))


func test_a_wreck_explodes() -> void:
	assert_true(_service.cue(&"car_wreck", Vector2(3.0, 0.0), 1000))
	var wrecks: int = _service.played.get(&"car_wreck", 0)
	assert_eq(wrecks, 1)
