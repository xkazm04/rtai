extends Node
## Headless street fire timing. Each trial starts from the same seed on clear level ground.
## node tools/dev/run.mjs fire_gaps -- --out=C:/absolute/path/before.json

const KNOWN_FLAGS: PackedStringArray = ["--out"]
const SEED: int = 1
const MOTIONS: Array[String] = ["standing", "circle", "strafe"]


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var path: String = args.text("--out")
	if args.values.size() != 1 or not path.is_absolute_path() or path.get_extension() != "json":
		Log.error("fire-gaps", "expected --out=<absolute .json path>")
		get_tree().quit(2)
		return
	var bus: EventBus = EventBus.new()
	var rows: Array[Dictionary] = []
	var roster: EnemyRoster = EnemyRoster.shipped(EnemyRoster.TABLE, true)
	var pool: GauntletComposer = GauntletComposer.shipped(RngRegistry.new(SEED))
	var tuning: DataTable = DataTable.open(PlayerMotion.TABLE, PlayerMotion.SCHEMA)
	var speed: float = PlayerMotion.from_table(tuning).sprint_mps
	for id: StringName in pool.tiers:
		if roster.archetype(id).weapon.melee:
			continue
		for motion: String in MOTIONS:
			var registry: RngRegistry = RngRegistry.new(SEED)
			var arena: FireGapArena = FireGapArena.new(
				CombatTuning.shipped(), bus, registry.stream(&"combat")
			)
			arena.prepare(id, motion, speed)
			if not arena.measure():
				bus.free()
				get_tree().quit(1)
				return
			rows.append(arena.result())
	bus.free()
	var ok: bool = _save(path, rows, speed)
	get_tree().quit(0 if ok else 1)


func _save(path: String, rows: Array[Dictionary], speed: float) -> bool:
	var data: Dictionary = {
		"schema": "gtai.fire-gaps/1",
		"seed": SEED,
		"tick_rate": SimClock.TICK_RATE,
		"ticks": FireGapArena.TICKS,
		"start_distance_m": FireGapArena.RANGE_M,
		"run_mps": speed,
		"strafe_half_width_m": 5,
		"trials": rows,
		"table_sha256": {},
	}
	for name: String in ["combat", "enemies", "gauntlet", "rivet_motion", "weapons"]:
		data.table_sha256[name] = FileAccess.get_sha256("res://data/tables/%s.json" % name)
	if DirAccess.make_dir_recursive_absolute(path.get_base_dir()) != OK:
		return false
	if not _write(path, JSON.stringify(data, "  ", true, true) + "\n"):
		return false
	return _write(path.get_basename() + ".md", _markdown(rows, speed))


func _write(path: String, contents: String) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null or not file.store_string(contents):
		Log.error("fire-gaps", "could not write %s" % path)
		return false
	file.close()
	return true


func _number(value: Variant) -> String:
	return "—" if value == null else "%.3f" % value


func _markdown(rows: Array[Dictionary], speed: float) -> String:
	var lines: Array[String] = [
		"# Enemy fire on the gauntlet street",
		"",
		"Open ground, 10 m initial range, 30 seconds at 60 Hz. Every trial uses seed %d." % SEED,
		"Rivet stands still, circles the moving enemy at 10 m, or strafes from y = -5 to +5 at x = 10.",
		"Kinematic movement is %.1f m/s. Rivet takes damage and uses no combat inputs." % speed,
		"",
		"Hits include direct and splash impacts from sample rounds followed to the end of flight.",
		"Under fire counts ticks with at least one airborne round that later hits Rivet.",
		"",
		"| Enemy | Gun | Motion | Rounds | RPS | Mean s | Max s | Hits | Hit share | Under fire |",
		"|---|---|---|---:|---:|---:|---:|---:|---:|---:|"
	]
	for r: Dictionary in rows:
		lines.append(
			(
				"| %s | %s | %s | %d | %.3f | %s | %s | %d | %s | %.1f%% |"
				% [
					r.archetype,
					r.weapon,
					r.motion,
					r.rounds,
					r.rounds_per_s,
					_number(r.mean_gap_s),
					_number(r.max_gap_s),
					r.hits,
					_number(r.hit_share),
					100.0 * r.under_fire_share
				]
			)
		)
	lines.append_array(_parts(rows))
	return "\n".join(lines) + "\n"


func _parts(rows: Array[Dictionary]) -> Array[String]:
	var lines: Array[String] = [
		"",
		"## Seconds between the first and last muzzle events",
		"",
		"Ticks follow the active branch and include the next muzzle event.",
		"Startup and the unfinished final interval are excluded. The JSON retains exact tick counts.",
		"Tracking tells and locked aim are separate. The turret traverses to its locked lane.",
		"The war machine traverses in place while in range and waiting to align its cannon.",
		"Rocket repositioning takes priority over a concurrent cooldown.",
		"Street riflemen use GuardBrain. EnemyGunner volley rest applies to the range drill.",
		"",
	]
	lines.append("| Enemy | Motion | " + " | ".join(FireGapClock.PARTS) + " |")
	lines.append("|---|---|" + "---:|".repeat(FireGapClock.PARTS.size()))
	for r: Dictionary in rows:
		var cells: Array[String] = [r.archetype, r.motion]
		for part: String in FireGapClock.PARTS:
			var count: int = r.gap_parts_ticks[part]
			cells.append("%.2f" % (count * SimClock.TICK_DT))
		lines.append("| " + " | ".join(cells) + " |")
	return lines
