class_name ControlsMode
extends RefCounted
## Selects the gameplay bindings at boot.


static func id() -> StringName:
	if not LaunchArgs.has("--controls"):
		return &"wheel"
	var mode: String = LaunchArgs.value("--controls")
	match mode:
		"wheel":
			return &"wheel"
		"legacy":
			return &"legacy"
		_:
			Log.warn("input", "Unknown --controls value '%s', using wheel" % mode)
			return &"wheel"


static func wheel() -> bool:
	return id() == &"wheel"


static func start_drawn() -> bool:
	return LaunchArgs.value("--wheel-start") == "drawn"
