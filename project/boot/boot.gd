extends Node
## Main scene root. Its World child (boot/world.gd) is the composition root (ARC-04).


func _ready() -> void:
	Log.info("boot", "RTAI: Uprising booted on backend %s" % Platform.backend_name())
