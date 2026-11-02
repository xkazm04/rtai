extends GutTest
## The composition root (ARC-04): one WorldContext, passed down through setup(); systems signal
## up through ctx.events (ARC-05); the autoload budget holds (ARC-02).

const AUTOLOAD_CAP: int = 7


class ProbeSystem:
	extends WorldSystem
	var got: WorldContext = null
	var setups: int = 0

	func setup(ctx: WorldContext) -> void:
		got = ctx
		setups += 1

	func finish_contract(id: StringName) -> void:
		got.events.contract_completed.emit(id)


func test_build_context_holds_what_it_was_given() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	var ctx: WorldContext = World.build_context(bus, data)
	assert_same(ctx.events, bus)
	assert_same(ctx.data, data)


func test_every_system_gets_the_same_context_once() -> void:
	var world: World = autofree(World.new())
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	world.start(bus, data)
	var ctx: WorldContext = world.context()
	var first: ProbeSystem = ProbeSystem.new()
	var second: ProbeSystem = ProbeSystem.new()
	world.add_system(first)
	world.add_system(second)
	assert_same(first.got, ctx)
	assert_same(second.got, ctx)
	assert_eq([first.setups, second.setups], [1, 1])
	assert_eq(world.system_count(), 2)


func test_a_system_signals_up_through_the_injected_bus() -> void:
	var world: World = autofree(World.new())
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	world.start(bus, data)
	var ctx: WorldContext = world.context()
	var system: ProbeSystem = ProbeSystem.new()
	world.add_system(system)
	watch_signals(ctx.events)
	system.finish_contract(&"m01_clock_out")
	assert_signal_emitted_with_parameters(bus, "contract_completed", [&"m01_clock_out"])


func test_world_in_the_tree_wires_the_autoloads() -> void:
	var world: World = add_child_autofree(World.new())
	assert_same(world.context().events, Events)
	assert_same(world.context().data, Data)


func test_autoload_budget() -> void:
	var names: Array[String] = []
	for prop: Dictionary in ProjectSettings.get_property_list():
		var key: String = prop["name"]
		if key.begins_with("autoload/"):
			names.append(key.trim_prefix("autoload/"))
	assert_lte(names.size(), AUTOLOAD_CAP, "ARC-02: %s" % ", ".join(names))
	assert_does_not_have(names, "DebugTools", "DebugTools is never an autoload")
