extends SceneTree
## Run with --path project --position 0,1440 --rendering-driver d3d12
## -s ../evidence/film_shock.gd -- --view=combo --ppm=64 --out=<absolute-directory>.

func _initialize() -> void:
	call_deferred("_film")


func _film() -> void:
	var here: String = ProjectSettings.globalize_path("res://../evidence")
	var board: Node = (load(here.path_join("ped_shock_board.gd")) as GDScript).new()
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			board.set("out_dir", arg.trim_prefix("--out="))
		elif arg.begins_with("--ppm="):
			board.set("ppm", arg.trim_prefix("--ppm=").to_float())
		elif arg != "--view=combo":
			quit(2)
			return
	if str(board.get("out_dir")).is_empty():
		quit(2)
		return
	root.add_child(board)
	var result: int = await board.call("shoot")
	board.free()
	quit(result)
