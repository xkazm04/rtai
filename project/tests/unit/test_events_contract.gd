extends GutTest
## One contract test per Events signal (ARC-06): the declaration in core/events/events.gd matches
## res://data/schemas/events.json name for name and type for type (the achievements tracker maps
## args by these names), and an emit delivers the payload in declared order.

const REGISTRY_PATH: String = "res://data/schemas/events.json"
const TYPES: Dictionary[String, int] = {
	"int": TYPE_INT,
	"float": TYPE_FLOAT,
	"bool": TYPE_BOOL,
	"String": TYPE_STRING,
	"StringName": TYPE_STRING_NAME,
}

var _bus: EventBus
var _log: EventLog


func before_each() -> void:
	_bus = autofree(EventBus.new())
	_log = EventLog.new()
	_log.attach(_bus, func() -> int: return 7)


func after_each() -> void:
	_log.detach()


func test_registry_and_bus_list_the_same_signals() -> void:
	var listed: Array[StringName] = []
	for entry: Dictionary in _registry_signals():
		var signal_name: StringName = entry["name"]
		listed.append(signal_name)
	listed.sort()
	var declared: Array[StringName] = _bus.signal_names()
	declared.sort()
	assert_eq(declared, listed)
	var cap: int = _registry()["cap"]
	assert_lte(declared.size(), cap, "ARC-06 cap")


func test_tutorial_completed() -> void:
	_bus.tutorial_completed.emit()
	_check("tutorial_completed", "[]")


func test_soul_swapped() -> void:
	_bus.soul_swapped.emit(0, 1)
	_check("soul_swapped", "[0,1]")


func test_vehicle_hijacked() -> void:
	_bus.vehicle_hijacked.emit(&"taxi")
	_check("vehicle_hijacked", '["taxi"]')


func test_actor_killed() -> void:
	_bus.actor_killed.emit(1, 42, &"stamped")
	_check("actor_killed", '[1,42,"stamped"]')
	var params: Array = _entry("actor_killed")["params"]
	var kind: Dictionary = params[2]
	var values: Array = kind["values"]
	assert_eq(values, ["blown", "burned", "shot", "stamped"], "closed set of kinds")
	var contract: String = _entry("actor_killed")["contract"]
	assert_string_contains(contract, "BEFORE the damage")


func test_wanted_changed() -> void:
	_bus.wanted_changed.emit(3)
	_check("wanted_changed", "[3]")


func test_cash_changed() -> void:
	_bus.cash_changed.emit(150, -50)
	_check("cash_changed", "[150,-50]")


func test_contract_started() -> void:
	_bus.contract_started.emit(&"m01_clock_out")
	_check("contract_started", '["m01_clock_out"]')


func test_contract_completed() -> void:
	_bus.contract_completed.emit(&"m01_clock_out")
	_check("contract_completed", '["m01_clock_out"]')


func test_vehicle_entered() -> void:
	_bus.vehicle_entered.emit(12)
	_check("vehicle_entered", "[12]")


func test_vehicle_exited() -> void:
	_bus.vehicle_exited.emit(12)
	_check("vehicle_exited", "[12]")


## The declared params match events.json, and the one emit arrived with its tick and payload.
func _check(signal_name: String, payload_json: String) -> void:
	var expected: Array[String] = []
	var params: Array = _entry(signal_name)["params"]
	for param: Dictionary in params:
		var type_name: String = param["type"]
		expected.append("%s:%d" % [param["name"], TYPES[type_name]])
	assert_eq(_declared(signal_name), expected, "%s params" % signal_name)
	var want: PackedStringArray = ["7 %s %s" % [signal_name, payload_json]]
	assert_eq(_log.lines(), want, "%s payload" % signal_name)


func _declared(signal_name: String) -> Array[String]:
	var out: Array[String] = []
	var script: Script = _bus.get_script()
	for info: Dictionary in script.get_script_signal_list():
		if info["name"] == signal_name:
			var args: Array = info["args"]
			for arg: Dictionary in args:
				out.append("%s:%d" % [arg["name"], arg["type"]])
	return out


func _entry(signal_name: String) -> Dictionary:
	for entry: Dictionary in _registry_signals():
		if entry["name"] == signal_name:
			return entry
	fail_test("%s is not in events.json" % signal_name)
	return {}


func _registry_signals() -> Array:
	var signals: Array = _registry()["signals"]
	return signals


func _registry() -> Dictionary:
	var parser: JSON = JSON.new()
	assert_eq(parser.parse(FileAccess.get_file_as_string(REGISTRY_PATH)), OK, "events.json parses")
	var data: Dictionary = parser.data
	return data
