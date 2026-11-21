extends SceneTree
## tools/film arena capture entry. Install the input driver before the arena joins
## the tree. With the viewport set to the master resolution, one drawn pixel is one film pixel.


func _initialize() -> void:
	_open.call_deferred()


func _open() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	var controller: GDScript = load("res://dev/enemy_ai/foe_flank_film.gd")
	var driver: Node = controller.new()
	root.add_child(driver)
	var arena: PackedScene = load("res://dev/arena/arena.tscn")
	root.add_child(arena.instantiate())
