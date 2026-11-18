extends SceneTree
## Dev-only: godot --headless --path project -s res://dev/bake_city.gd [-- --check [--fail-fast]]
## With no flags, write data/generated/city/c_XX_YY.bin and data/generated/city_chunks.sha256.
## --check compares two bakes with the golden list. --fail-fast stops at the first differing chunk.

const KNOWN_FLAGS: PackedStringArray = ["--check", "--fail-fast"]
const TABLES: String = "res://data/tables/"


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	for arg: String in args:
		if not KNOWN_FLAGS.has(arg):
			printerr("bake_city: unknown argument %s" % arg)
			quit(2)
			return
	var fast: bool = args.has("--fail-fast")
	if fast and not args.has("--check"):
		printerr("bake_city: --fail-fast requires --check")
		quit(2)
		return
	var gen := CityGen.from_tables(TABLES + "city_district.json", TABLES + "city_textures.json")
	var bake: CityBake = CityBake.new(gen, SimConst.CITY_CHUNKS)
	if args.has("--check"):
		var problem: String = bake.check_fail_fast() if fast else bake.check()
		var success: String = ("OK " if fast else "") + "deterministic, matches golden"
		printerr("bake_city: %s" % (problem if problem != "" else success))
		quit(0 if problem == "" else 1)
		return
	var written: int = bake.write_files()
	printerr("bake_city: wrote %d chunks" % written)
	quit(0 if written > 0 else 1)
