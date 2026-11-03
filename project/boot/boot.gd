extends Node
## Main scene root. Its World child (boot/world.gd) is the composition root (ARC-04).
## Only the main scene warns on unknown `--` args (the dev runners build a World with their own
## flags).


func _ready() -> void:
	Log.info("boot", "RTAI: Uprising booted on backend %s" % Platform.backend_name())
	for arg: String in LaunchArgs.unknown():
		Log.warn("boot", "unknown launch arg %s (ignored)" % arg)
