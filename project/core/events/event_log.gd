class_name EventLog
extends RefCounted
## Records every domain signal of an EventBus with the tick it fired on (ARC-06 debug ring
## buffer; SIM-05 replay event timeline). capacity 0 means unbounded (a replay timeline).
## Lines are "<tick> <signal> <args json>", full float precision, so two runs compare as text.

var _capacity: int = 0
var _lines: Array[String] = []
var _tick_source: Callable = Engine.get_physics_frames
var _bus: EventBus = null
var _bound: Dictionary[StringName, Callable] = {}


func _init(capacity: int = 0) -> void:
	_capacity = capacity


## Listens to every domain signal of `bus`. tick_source returns the current tick (int).
func attach(bus: EventBus, tick_source: Callable) -> void:
	detach()
	_bus = bus
	_tick_source = tick_source
	for signal_name: StringName in bus.signal_names():
		_bound[signal_name] = _record.bind(signal_name)
		var err: int = bus.connect(signal_name, _bound[signal_name])
		if err != OK:
			Log.error("events", "event log could not listen to %s (%d)" % [signal_name, err])


## Disconnects from the bus (GDS-10: never left connected to a longer-lived emitter).
func detach() -> void:
	if _bus == null:
		return
	for signal_name: StringName in _bound:
		if _bus.is_connected(signal_name, _bound[signal_name]):
			_bus.disconnect(signal_name, _bound[signal_name])
	_bound.clear()
	_bus = null


func set_tick_source(tick_source: Callable) -> void:
	_tick_source = tick_source


func lines() -> PackedStringArray:
	return PackedStringArray(_lines)


func size() -> int:
	return _lines.size()


func clear() -> void:
	_lines.clear()


## Bound args arrive last, so the signal name is the final element.
func _record(...args: Array) -> void:
	var signal_name: StringName = args.pop_back()
	var tick: int = _tick_source.call() if _tick_source.is_valid() else -1
	_lines.append("%d %s %s" % [tick, signal_name, JSON.stringify(args, "", false, true)])
	if _capacity > 0 and _lines.size() > _capacity:
		_lines.remove_at(0)
