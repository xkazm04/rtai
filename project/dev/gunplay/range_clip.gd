extends SceneTree
## Lane gunplay range clip launcher: adds range_view.gd under the root (loaded at run time).
## Usage: <godot> --rendering-driver d3d12 --path project --fixed-fps 60 --write-movie <png>
##   --quit-after <frames> -s res://dev/gunplay/range_clip.gd


func _initialize() -> void:
	var script: GDScript = load("res://dev/gunplay/range_view.gd")
	if script == null or not script.can_instantiate():
		quit(2)
		return
	var view: Node2D = script.new()
	root.add_child(view)
