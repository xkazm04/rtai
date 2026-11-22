class_name BotPick
extends RefCounted
## The street adapter supplies bonus rows keyed by their stable offer id.

var excluded_prefix: String = ""
var _mode: StringName
var _profile: BotProfile
var _rng: RandomNumberGenerator
var _bonuses: Dictionary


func _init(
	mode: StringName, profile: BotProfile, registry: RngRegistry, bonuses: Dictionary
) -> void:
	_mode = mode
	_profile = profile
	_rng = registry.stream(&"test_player_pick")
	_bonuses = bonuses


func pick(offered: Array[StringName], _wave: int) -> StringName:
	if offered.is_empty():
		return &""
	if excluded_prefix.is_empty() and _mode == &"random":
		return offered[_rng.randi_range(0, offered.size() - 1)]
	var best: StringName = &""
	var fallback: StringName = offered[0]
	var low: float = INF
	var high: float = -INF
	for id: StringName in offered:
		var row: Dictionary = _bonuses.get(id, {})
		var kind: StringName = row.get("kind", &"")
		var ref: StringName = row.get("ref", &"")
		var value: float = _profile.pick_value(kind, ref)
		if not excluded_prefix.is_empty() and String(id).begins_with(excluded_prefix):
			if value < low:
				fallback = id
				low = value
			continue
		if value > high:
			best = id
			high = value
	return fallback if best == &"" else best
