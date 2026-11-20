class_name StatMods
extends RefCounted
## Multipliers accumulated from this run's stat cards.

const STATS: Array[StringName] = [&"hp_max", &"speed", &"damage", &"guard_meter", &"regen"]

var _values: Dictionary[StringName, float] = {}


func add(stat: StringName, k: float) -> void:
	if not STATS.has(stat):
		Log.error("gauntlet", "unknown stat %s" % stat)
		return
	_values[stat] = value(stat) * k


func value(stat: StringName) -> float:
	return _values.get(stat, 1.0)


func to_dict() -> Dictionary:
	var out: Dictionary = {}
	for stat: StringName in _values:
		if _values[stat] != 1.0:
			out[String(stat)] = _values[stat]
	out.sort()
	return out
