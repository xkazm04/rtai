extends Node
## Headless seed table for the n27 takes: every take at every seed, pooled and with Wilson
## intervals. Run: node tools/dev/run.mjs pressure_seeds -- --out=<abs dir> [--seeds=10]

const KNOWN_FLAGS: PackedStringArray = ["--out", "--seeds"]
const TAKE_IDS: Array[String] = ["pair_circle", "pair_dash", "guard6", "blade6"]


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var dir: String = args.text("--out")
	var count: int = int(args.number("--seeds", 10))
	if not dir.is_absolute_path() or count < 1 or DirAccess.make_dir_recursive_absolute(dir) != OK:
		Log.error("pressure-seeds", "Expected an absolute --out directory and --seeds >= 1")
		get_tree().quit(2)
		return
	var rows: Array[Dictionary] = []
	for id: String in TAKE_IDS:
		for seed_value: int in range(1, count + 1):
			rows.append(_run(id, seed_value))
	var ok: bool = _write(dir.path_join("seeds.json"), _json(rows))
	ok = ok and _write(dir.path_join("seeds.md"), PressureSeedsText.markdown(rows))
	get_tree().quit(0 if ok else 1)


func _run(id: String, seed_value: int) -> Dictionary:
	var shot: PressureTake = PressureTake.new()
	if not shot.open(id, seed_value):
		Log.error("pressure-seeds", "%s seed %d did not open" % [id, seed_value])
		return {"take": id, "seed": seed_value, "opened": false}
	var fates: PressureFates = PressureFates.new(MeleeTable.weapon(&"plasma_sword").deflect_m)
	while shot.tick < shot.length:
		shot.advance()
		fates.observe(shot.arena, shot.session.pilot.melee.combo.hit_index, shot.tick)
	var row: Dictionary = shot.summary()
	row.merge(fates.summary())
	row["fate_log"] = fates.log
	row["seed"] = seed_value
	row["opened"] = true
	row["rivet_hp_max"] = shot.arena.rivet.max_hp
	shot.session.close()
	return row


func _json(rows: Array[Dictionary]) -> String:
	var report: Dictionary = {
		"schema": "gtai.pressure-seeds/1",
		"curve_pct": PressureSeedsText.CURVE,
		"z": PressureSeedsText.Z,
		"rows": rows
	}
	return JSON.stringify(report, "  ", true, true) + "\n"


func _write(path: String, contents: String) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null or not file.store_string(contents):
		Log.error("pressure-seeds", "Could not write %s" % path)
		return false
	file.close()
	return true
