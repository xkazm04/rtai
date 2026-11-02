extends SceneTree
## Parity gate runner (NAT-06, TST-03): native CitySim vs the GDScript reference, then the same
## run with a planted mutation, which must be caught. Exits 0 only when the real run is exact AND
## the planted one fails; 2 when the native library is not loaded, or on an unknown argument.
## Usage: godot --headless --path project -s res://tests/parity/run_parity.gd
##        [-- --steps=1200 --out=<json path>]

const KNOWN_FLAGS: PackedStringArray = ["--steps", "--out"]


func _initialize() -> void:
	var steps: int = 1200
	var out: String = ""
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(flag):
			printerr("run_parity: unknown argument %s" % arg)
			quit(2)
			return
		var value: String = arg.substr(flag.length() + 1)
		steps = value.to_int() if flag == "--steps" else steps
		out = value if flag == "--out" else out
	quit(_run(steps, out))


func _run(steps: int, out: String) -> int:
	var native_script: GDScript = load("res://features/city/sim/city_sim_native.gd")
	var ref_script: GDScript = load("res://features/city/sim/city_sim_ref.gd")
	var parity_script: GDScript = load("res://tests/parity/city_parity.gd")
	if not ClassDB.class_exists(&"CitySim"):
		printerr("run_parity: native CitySim not loaded (build native/ first)")
		_write(out, {"error": "native library not loaded", "exact": false})
		return 2
	var real: Object = parity_script.new()
	var exact: bool = real.call("run", ref_script.new(), native_script.new(), steps, -1)
	var planted: Object = parity_script.new()
	var caught: bool = not planted.call(
		"run", ref_script.new(), native_script.new(), steps, steps >> 1
	)
	var res: Dictionary = real.get("result")
	res["planted_mutation_caught"] = caught
	var planted_res: Dictionary = planted.get("result")
	res["planted_first_mismatch_step"] = planted_res.get("first_mismatch_step", -1)
	printerr("run_parity: %s" % JSON.stringify(res))
	_write(out, res)
	return 0 if exact and caught else 1


func _write(out: String, res: Dictionary) -> void:
	if out == "":
		return
	var f: FileAccess = FileAccess.open(out, FileAccess.WRITE)
	if f != null:
		var ok: bool = f.store_string(JSON.stringify(res, "  ", true))
		f.close()
		assert(ok)
