extends RefCounted


func run(path: String, selected: String, seeds: int) -> int:
	if selected != "all" and not DeployWorthTrial.ENCOUNTERS.has(selected):
		Log.error("deploy-worth", "Unknown form %s" % selected)
		return 2
	var cases: Dictionary = {}
	for form: StringName in DeployWorthTrial.ENCOUNTERS:
		if selected != "all" and form != selected:
			continue
		var pairs: Array[Dictionary] = []
		for seed_id: int in range(1, seeds + 1):
			var pair: Dictionary = {"seed": seed_id}
			for enabled: bool in [false, true]:
				var arm: Dictionary = DeployWorthTrial.new().measure(form, seed_id, enabled)
				if arm.is_empty():
					Log.error("deploy-worth", "Failed %s seed %d" % [form, seed_id])
					return 1
				pair["on" if enabled else "off"] = arm
			pairs.append(pair)
		cases[form] = _case(form, pairs)
		Log.info("deploy-worth", "%s: %d pairs" % [form, pairs.size()])
	var report: Dictionary = {
		"schema": "gtai.deploy-worth/1",
		"tick_hz": SimClock.TICK_RATE,
		"budget_ticks": DeployWorthTrial.LIMIT,
		"cases": cases,
	}
	if DirAccess.make_dir_recursive_absolute(path.get_base_dir()) != OK:
		return 1
	var out: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if out == null or not out.store_string(JSON.stringify(report, "  ") + "\n"):
		return 1
	return 0


func _case(form: StringName, pairs: Array[Dictionary]) -> Dictionary:
	var formation: Array[Dictionary] = []
	for spec: Array in DeployWorthTrial.ENCOUNTERS[form]:
		var at: Vector2 = spec[1]
		formation.append({"archetype": spec[0], "position_m": [at.x, at.y]})
	var summary: Dictionary = DeployWorthStats.summarize(pairs)
	var cooldown: int = pairs[0].on.cooldown_ticks
	summary.cooldown_ticks = cooldown
	summary.max_uses_in_30_s = ceili(float(DeployWorthTrial.LIMIT) / cooldown)
	return {"encounter": formation, "pairs": pairs, "summary": summary}
