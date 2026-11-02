class_name WorldContext
extends RefCounted
## Everything a system may reach, built once by the composition root (boot/world.gd, ARC-04)
## and passed down through WorldSystem.setup(). Typed fields only: no /root paths, no reaching up
## the tree, no string-keyed service locator. Tests build one from fakes.

var events: EventBus
var data: DataStore


func _init(p_events: EventBus, p_data: DataStore) -> void:
	events = p_events
	data = p_data
