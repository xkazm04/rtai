extends SceneTree
## Weapon-art dev still launcher: loads electro_cells_view.gd at run time (a -s main script must not
## name global classes at parse time) and writes <out>/electro-cells-48ppm.png.
##   <godot> --rendering-driver d3d12 --path project -s res://dev/weapon_art/electro_cells.gd
##           -- --out=<dir>


func _initialize() -> void:
	root.size = Vector2i(1280, 720)
	var script: GDScript = load("res://dev/weapon_art/electro_cells_view.gd")
	if script == null or not script.can_instantiate():
		printerr("electro_cells: view does not compile")
		quit(2)
		return
	var view: Node = script.new()
	root.add_child(view)
	_shoot()


func _shoot() -> void:
	for i: int in 4:
		await process_frame
	var out: String = "user://"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
	var image: Image = root.get_texture().get_image()
	quit(0 if image.save_png(out.path_join("electro-cells-48ppm.png")) == OK else 1)
