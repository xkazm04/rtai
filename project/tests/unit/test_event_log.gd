extends GutTest
## EventLog: the debug ring buffer (ARC-06) and the replay timeline (SIM-05).

var _tick: int = 0


func before_each() -> void:
	_tick = 0


func test_records_tick_signal_and_payload() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var log: EventLog = EventLog.new()
	log.attach(bus, _now)
	_tick = 120
	bus.wanted_changed.emit(2)
	_tick = 121
	bus.cash_changed.emit(10, 10)
	var want: PackedStringArray = ["120 wanted_changed [2]", "121 cash_changed [10,10]"]
	assert_eq(log.lines(), want)
	log.detach()


func test_ring_buffer_keeps_the_newest() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var log: EventLog = EventLog.new(2)
	log.attach(bus, _now)
	for level: int in [1, 2, 3]:
		bus.wanted_changed.emit(level)
	var want: PackedStringArray = ["0 wanted_changed [2]", "0 wanted_changed [3]"]
	assert_eq(log.lines(), want)
	log.detach()


func test_detach_stops_recording() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var log: EventLog = EventLog.new()
	log.attach(bus, _now)
	log.detach()
	bus.wanted_changed.emit(1)
	assert_eq(log.size(), 0)


func test_events_autoload_logs_emits_in_debug_builds() -> void:
	Events.reset()
	Events.set_tick_source(_now)
	_tick = 5
	Events.vehicle_entered.emit(9)
	assert_eq(Events.recent_emits(), PackedStringArray(["5 vehicle_entered [9]"]))
	Events.reset()
	assert_eq(Events.recent_emits().size(), 0)


func _now() -> int:
	return _tick
