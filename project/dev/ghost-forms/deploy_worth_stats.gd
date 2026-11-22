class_name DeployWorthStats
extends RefCounted
## Two-sided paired Student intervals for the fixed seed prefix, at most ten pairs.

const T95: Array[float] = [
	0.0, 12.7062, 4.3027, 3.1824, 2.7764, 2.5706, 2.4469, 2.3646, 2.3060, 2.2622
]


static func summarize(pairs: Array[Dictionary]) -> Dictionary:
	var result: Dictionary = {"uses": 0, "empty": 0, "faster": 0, "off_clears": 0, "on_clears": 0}
	var totals: Dictionary[String, float] = {"kills": 0.0, "damage": 0.0, "stun_s": 0.0}
	var complete: Array[float] = []
	var restricted: Array[float] = []
	var hp_off: float = 0.0
	var hp_on: float = 0.0
	var limit: float = DeployWorthTrial.LIMIT * SimClock.TICK_DT
	for pair: Dictionary in pairs:
		var off: Dictionary = pair.off
		var on: Dictionary = pair.on
		hp_off += off.hp_lost
		hp_on += on.hp_lost
		result.off_clears += int(off.has("clear_s"))
		result.on_clears += int(on.has("clear_s"))
		var diff: float = on.get("clear_s", limit) - off.get("clear_s", limit)
		restricted.append(diff)
		result.faster += int(on.has("clear_s") and (not off.has("clear_s") or diff < 0.0))
		if off.has("clear_s") and on.has("clear_s"):
			complete.append(diff)
		result.uses += on.uses
		result.empty += on.empty
		for key: String in totals:
			totals[key] += on[key]
	result.complete_pairs = complete.size()
	result.mean_hp_lost = {"off": hp_off / pairs.size(), "on": hp_on / pairs.size()}
	var uses: int = result.uses
	if uses > 0:
		for key: String in totals:
			result[key + "_per_use"] = totals[key] / uses
	if not complete.is_empty():
		result.clear_delta_s = _estimate(complete)
	result.restricted_delta_s = _estimate(restricted)
	return result


static func _estimate(values: Array[float]) -> Dictionary:
	var mean: float = 0.0
	for x: float in values:
		mean += x
	mean /= values.size()
	var result: Dictionary = {"mean": mean, "pairs": values.size()}
	if values.size() > 1:
		var ss: float = 0.0
		for x: float in values:
			ss += (x - mean) * (x - mean)
		var half: float = T95[values.size() - 1] * sqrt(ss / (values.size() * (values.size() - 1)))
		result.ci95 = [mean - half, mean + half]
	return result
