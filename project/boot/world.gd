class_name World
extends Node
## Composition root (ARC-04): builds the WorldContext once and hands it down to every system
## through setup(). Nothing below this node reaches up the tree or into /root.

var _ctx: WorldContext = null
var _systems: Array[WorldSystem] = []


## The one place a WorldContext is assembled. Tests call it with fresh instances or fakes.
static func build_context(events: EventBus, data: DataStore) -> WorldContext:
	return WorldContext.new(events, data)


func _ready() -> void:
	if _ctx == null:
		start(Events, Data)


## Builds the context from the given bus and data (the autoloads in the game, fakes in tests).
func start(events: EventBus, data: DataStore) -> void:
	_ctx = build_context(events, data)
	_systems.clear()


## Registers a system and calls down into it with the context (ARC-05).
func add_system(system: WorldSystem) -> void:
	_systems.append(system)
	system.setup(_ctx)


func context() -> WorldContext:
	return _ctx


func system_count() -> int:
	return _systems.size()
