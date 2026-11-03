extends SceneTree
## Lane gunplay clip launcher: adds <view>_view.gd (default range) under the root at run time.
## Usage: <godot> --rendering-driver d3d12 --path project --fixed-fps 60 --write-movie <png>
##   --quit-after <frames> -s res://dev/gunplay/range_clip.gd -- [--view=dodge] [--ppm=48]


func _initialize() -> void:
	var view_name: String = "range"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--view="):
			view_name = arg.trim_prefix("--view=")
	var script: GDScript = load("res://dev/gunplay/%s_view.gd" % view_name)
	if script == null or not script.can_instantiate():
		quit(2)
		return
	var view: Node2D = script.new()
	root.add_child(view)
