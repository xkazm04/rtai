extends SceneTree
## rivet-arsenal: writes the live pilot's movement feel numbers (RivetFeel, loaded at run time so
## this -s main script names no global class at parse time) to a JSON file.
## Usage: <godot> --headless --path project -s res://dev/rivet_arsenal/feel_main.gd -- --out=<json>


func _initialize() -> void:
	var out_path: String = "user://rivet-feel.json"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_path = arg.substr(6)
	var bus: Node = (load("res://core/events/events.gd") as GDScript).new()
	var data: Node = (load("res://core/data/data.gd") as GDScript).new()
	var feel_script: GDScript = load("res://dev/rivet_arsenal/rivet_feel.gd") as GDScript
	var report: Dictionary = {"schema": "gtai.rivet-feel/1", "tick_hz": 60}
	var walk: Array[StringName] = []
	var sprint: Array[StringName] = [&"sprint"]
	var probe: Object = feel_script.new(bus, data)
	report["walk"] = probe.call("run", walk)
	probe = feel_script.new(bus, data)
	report["sprint"] = probe.call("run", sprint)
	probe = feel_script.new(bus, data)
	report["aim_turn_180_ticks"] = probe.call("aim_turn_ticks")
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	@warning_ignore("return_value_discarded")
	f.store_string(JSON.stringify(report, "  ", true))
	f.close()
	bus.free()
	data.free()
	quit(0)
