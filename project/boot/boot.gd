extends Node
## Main scene root. The composition root (world.gd, ARC-04) lands with the first feature port.


func _ready() -> void:
	Log.info("boot", "RTAI: Uprising booted on backend %s" % Platform.backend_name())
