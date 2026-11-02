extends SceneTree
## Bakes the district's chunk files and the golden hash list (AST-12). Dev-only tool (dev/ is
## excluded from release exports).
## Usage: godot --headless --path project -s res://dev/bake_city.gd [-- --check]
##   (no flag)  write res://data/generated/city/c_XX_YY.bin + data/generated/city_chunks.sha256
##   --check    bake twice, byte-compare, compare with the committed list; exit 1 on drift

const KNOWN_FLAGS: PackedStringArray = ["--check"]


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if not KNOWN_FLAGS.has(arg):
			printerr("bake_city: unknown argument %s" % arg)
			quit(2)
			return
	var bake_script: GDScript = load("res://features/city/gen/city_bake.gd")
	var gen_script: GDScript = load("res://features/city/gen/city_gen.gd")
	var gen: Object = gen_script.call(
		"from_tables",
		"res://data/tables/city_district.json",
		"res://data/tables/city_textures.json"
	)
	var bake: Object = bake_script.new(gen, 16)
	if OS.get_cmdline_user_args().has("--check"):
		var problem: String = bake.call("check")
		printerr("bake_city: %s" % (problem if problem != "" else "deterministic, matches golden"))
		quit(0 if problem == "" else 1)
		return
	var written: int = bake.call("write_files")
	printerr("bake_city: wrote %d chunks" % written)
	quit(0 if written > 0 else 1)
