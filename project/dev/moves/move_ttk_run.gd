extends RefCounted

const MATCHUPS: Dictionary = {
	MoveTable.SHORT_CIRCUIT: [&"sentry_turret", &"shield_robot"],
	MoveTable.ARMOUR_CRACK: [&"war_machine"],
	MoveTable.BLINK_BEHIND: [&"shield_robot"],
	MoveTable.OVERKILL: [&"patrol_cop", &"robot_thug"],
}


func run(path: String, selected: String, seeds: int) -> int:
	if selected != "" and not MATCHUPS.has(selected):
		printerr("move_ttk: unknown --move=", selected)
		return 2
	var cases: Array[Dictionary] = []
	for move: StringName in MATCHUPS:
		if selected != "" and selected != move:
			continue
		for enemy: StringName in MATCHUPS[move]:
			for weapon: StringName in _weapons(move):
				var row: Dictionary = _sample(move, enemy, weapon, seeds)
				if row.is_empty():
					Log.error("move-ttk", "Could not prepare %s / %s / %s" % [move, enemy, weapon])
					return 1
				cases.append(row)
	var report: Dictionary = {
		"schema": "gtai.move-ttk/1",
		"first_seed": 1,
		"seeds": seeds,
		"tick_hz": SimClock.TICK_RATE,
		"limit_ticks": FoeTtkTrial.LIMIT,
		"cases": cases,
	}
	if DirAccess.make_dir_recursive_absolute(path.get_base_dir()) != OK:
		return 1
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null or not file.store_string(JSON.stringify(report, "  ") + "\n"):
		Log.error("move-ttk", "Cannot write %s" % path)
		return 1
	return 0


func _weapons(move: StringName) -> Array[StringName]:
	if move == MoveTable.OVERKILL:
		return [&"hand_cannon", &"pistol"]
	if move == MoveTable.BLINK_BEHIND:
		return [&""]
	return [&"pistol"]


func _sample(move: StringName, enemy: StringName, weapon: StringName, seeds: int) -> Dictionary:
	var pairs: Array[Dictionary] = []
	var arms: PackedStringArray = ["on"]
	if move == MoveTable.OVERKILL:
		arms = ["rank_1", "rank_2"]
	for seed_id: int in range(1, seeds + 1):
		var off: Dictionary = MoveTtkTrial.new().measure(move, enemy, weapon, seed_id, 0)
		if off.is_empty():
			return {}
		var pair: Dictionary = {"seed": seed_id, "off": off}
		for index: int in arms.size():
			var on: Dictionary = MoveTtkTrial.new().measure(move, enemy, weapon, seed_id, index + 1)
			if on.is_empty():
				return {}
			on.delta_ticks = MoveTtkStats.delta_ticks(off.kill_tick, on.kill_tick)
			pair[arms[index]] = on
		pairs.append(pair)
	var summaries: Dictionary = {}
	for arm: String in arms:
		summaries[arm] = MoveTtkStats.summarize(pairs, arm)
	return {
		"move": move,
		"enemy": enemy,
		"weapon": weapon if weapon != &"" else &"kerf_slice",
		"target_count": 3 if move == MoveTable.OVERKILL else 1,
		"pairs": pairs,
		"summary": summaries,
	}
