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
	var sample: Dictionary = {"attempts": 0, "hits": 0, "kills": 0, "first_hit_kills": 0}
	for seed_id: int in range(1, SEEDS + 1):
		var rng: RngRegistry = RngRegistry.new(seed_id)
		var row: Dictionary = FoeTtkTrial.new().measure(id, weapon, rear, rng, table)
		ticks.append(row.tick)
		sample.kills += int(ticks[-1] <= FoeTtkTrial.LIMIT)
		sample.attempts += row.attempts
		sample.hits += row.hits
		sample.first_hit_kills += 1 if row.first else 0
		sample.distance_m = row.distance_m
	ticks.sort()
	sample.median_s = null
	if ticks[SEEDS / 2] <= FoeTtkTrial.LIMIT:
		sample.median_s = 0.5 * (ticks[SEEDS / 2 - 1] + ticks[SEEDS / 2]) * SimClock.TICK_DT
	sample.hit_share = 1.0 * sample.hits / sample.attempts if sample.attempts > 0 else null
	return sample


func _seconds(row: Dictionary) -> String:
	return "—" if row.median_s == null else "%.2f" % row.median_s


func _header(weapons: Array[StringName]) -> Array[String]:
	return [
		"# Enemy time to kill",
		"",
		"Median seconds from first input to death, front / rear. A dash means timeout at 30 s.",
		"Ten paired seeds (1 to 10), centre aim, shipped spread, cadence and reloads.",
		"Guns fire at 8 m. Claw distance is the shortest combo reach plus target radius, less 1 cm.",
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
