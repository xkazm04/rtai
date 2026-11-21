extends RefCounted
## Each bearing uses the same ten registry seeds. An expired trial sorts after every
## kill. If either central observation timed out, the median is censored.

const SEEDS: int = 10


func run(path: String) -> int:
	var roster: EnemyRoster = EnemyRoster.shipped(EnemyRoster.TABLE, true)
	var table: WeaponTable = WeaponTable.shipped()
	if not roster.ok() or not table.ok():
		return 1
	var weapons: Array[StringName] = table.playable()
	weapons.append(MeleeTable.CLAW)
	var report: Dictionary = {
		"schema": "gtai.foe-ttk/1",
		"trials": SEEDS,
		"first_seed": 1,
		"tick_hz": SimClock.TICK_RATE,
		"distance_m": FoeTtkTrial.DISTANCE_M,
		"limit_ticks": FoeTtkTrial.LIMIT,
		"weapons": weapons,
		"enemies": {}
	}
	var md: Array[String] = _header(weapons)
	var rows: Array[EnemyRoster.Archetype] = roster.archetypes.values()
	rows.sort_custom(
		func(a: EnemyRoster.Archetype, b: EnemyRoster.Archetype) -> bool:
			return a.tier < b.tier or (a.tier == b.tier and String(a.id) < String(b.id))
	)
	for arch: EnemyRoster.Archetype in rows:
		var cells: Dictionary = {}
		var line: String = "| %d | %s |" % [arch.tier, arch.id]
		for weapon: StringName in weapons:
			var front: Dictionary = _sample(arch.id, weapon, false, table)
			var rear: Dictionary = _sample(arch.id, weapon, true, table)
			cells[weapon] = {"front": front, "rear": rear}
			line += " %s / %s |" % [_seconds(front), _seconds(rear)]
		report.enemies[arch.id] = {"tier": arch.tier, "weapons": cells}
		md.append(line)
		Log.info("foe-ttk", str(arch.id))
	if DirAccess.make_dir_recursive_absolute(path.get_base_dir()) != OK:
		return 1
	var ok: bool = _write(path, JSON.stringify(report, "  ") + "\n")
	return 0 if ok and _write(path.get_basename() + ".md", "\n".join(md) + "\n") else 1


func _sample(id: StringName, weapon: StringName, rear: bool, table: WeaponTable) -> Dictionary:
	var ticks: Array[int] = []
	var attempts: int = 0
	var hits: int = 0
	var kills: int = 0
	var first: int = 0
	for seed_id: int in range(1, SEEDS + 1):
		var row: Dictionary = FoeTtkTrial.new().measure(
			id, weapon, rear, RngRegistry.new(seed_id), table
		)
		ticks.append(row.tick)
		kills += int(ticks[-1] <= FoeTtkTrial.LIMIT)
		attempts += row.attempts
		hits += row.hits
		first += 1 if row.first else 0
	ticks.sort()
	var median: Variant = null
	if ticks[SEEDS / 2] <= FoeTtkTrial.LIMIT:
		median = 0.5 * (ticks[SEEDS / 2 - 1] + ticks[SEEDS / 2]) * SimClock.TICK_DT
	return {
		"median_s": median,
		"kills": kills,
		"first_hit_kills": first,
		"attempts": attempts,
		"hits": hits,
		"hit_share": float(hits) / attempts if attempts > 0 else null
	}


func _seconds(row: Dictionary) -> String:
	return "—" if row.median_s == null else "%.2f" % row.median_s


func _header(weapons: Array[StringName]) -> Array[String]:
	return [
		"# Enemy time to kill at 8 m",
		"",
		"Median seconds from first input to death, front / rear. A dash means timeout at 30 s.",
		"Ten paired seeds (1 to 10), centre aim, shipped spread, cadence and reloads.",
		"Both fighters stay 8 m apart, including for bare-claw swings.",
		"Each column is one playable weapon. Hit class describes impact effects.",
		"Hit share counts direct and splash strikes per round fired, or landed swings per swing.",
		"Lingering fire contributes to TTK. First-hit kills require death on the first damage event.",
		"",
		"| Tier | Enemy | " + " | ".join(weapons) + " |",
		"|---:|---|" + "---:|".repeat(weapons.size())
	]


func _write(path: String, contents: String) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null or not file.store_string(contents):
		Log.error("foe-ttk", "Cannot write %s" % path)
		return false
	return true
