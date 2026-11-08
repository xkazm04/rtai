extends SceneTree


func _initialize() -> void:
	_go.call_deferred()


func _go() -> void:
	var made: Object = (load("res://dev/zz_pad_walker.gd") as GDScript).new()
	root.add_child(made as Node)
