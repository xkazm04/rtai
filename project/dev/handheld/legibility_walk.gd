extends SceneTree
## handheld lane (n9): runs the legibility walker (legibility_walker.gd) under a device row.
## "$GODOT_BIN" --rendering-driver d3d12 --path project
##   -s res://dev/handheld/legibility_walk.gd -- <out dir> [device]

const WALKER: String = "res://dev/handheld/legibility_walker.gd"


func _initialize() -> void:
	_go.call_deferred()


func _go() -> void:
	var made: Object = (load(WALKER) as GDScript).new()
	root.add_child(made as Node)
