class_name ControlsMode
extends RefCounted
## Selects the gameplay bindings at boot.


static func id() -> StringName:
	if not LaunchArgs.has("--controls"):
		return &"legacy"
	var mode: String = LaunchArgs.value("--controls")
	match mode:
		"wheel":
			return &"wheel"
		"legacy":
			return &"legacy"
		_:
			Log.warn("input", "Unknown --controls value '%s', using legacy" % mode)
			return &"legacy"


static func wheel() -> bool:
	return id() == &"wheel"
