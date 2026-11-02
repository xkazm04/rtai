extends GutTest
## Heat (mechanic `heat`): 0..3, drains a level per drain_s_per_level unseen, sight restarts the
## count, the one setter emits wanted_changed.

var _bus: EventBus
var _heat: HeatMeter


func before_each() -> void:
	_bus = autofree(EventBus.new())
	_heat = HeatMeter.new(_bus)
	watch_signals(_bus)


func test_peaks_at_three_and_emits_through_the_setter() -> void:
	_heat.raise_by(5)
	assert_eq(_heat.level, 3)
	assert_signal_emitted_with_parameters(_bus, "wanted_changed", [3])


func test_drains_out_of_sight_and_sight_restarts_the_count() -> void:
	_heat.set_level(2)
	for _i: int in _heat.drain_ticks - 1:
		_heat.step(false)
	_heat.step(true)
	assert_eq(_heat.level, 2, "seen just before the drop: the count restarts")
	for _i: int in _heat.drain_ticks:
		_heat.step(false)
	assert_eq(_heat.level, 1)
	assert_true(_heat.dropped, "the heat-dropping cue")
	for _i: int in _heat.drain_ticks:
		_heat.step(false)
	assert_eq(_heat.level, 0)
	assert_eq(_heat.seconds_to_cool(), 0.0)
