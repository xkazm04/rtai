extends SceneTree
## Film quest 1's actual rifle pickup, then aim and fire in each octant.
const KNOWN_FLAGS: PackedStringArray = ["--out", "--ppm", "--view", "--rigs", "--clip"]


func _initialize() -> void:
	call_deferred(&"_start")


func _start() -> void:
	var values: Dictionary[String, String] = ArenaArgs.parse().values
	for key: String in values:
		if not KNOWN_FLAGS.has(key):
			root.get_node("Log").call("error", "clip", "unknown argument " + key)
			quit(2)
			return
	var dest: String = values.get("--out", "")
	if dest.is_empty() or DirAccess.make_dir_recursive_absolute(dest) != OK:
		quit(2)
		return
	var recorder: Node = (load("res://dev/rivet_arsenal/rifle_turn_rec.gd") as GDScript).new()
	recorder.set("out_dir", dest)
	recorder.set("px_per_m", str(values.get("--ppm", "64")).to_float())
	recorder.set("clip", values.has("--clip"))
	root.add_child(recorder)
