class_name BotPick
extends RefCounted
## The street adapter supplies bonus rows keyed by their stable offer id.

var excluded_prefix: String = ""
var _mode: StringName
var _profile: BotProfile
var _rng: RandomNumberGenerator
var _moves_rng: RandomNumberGenerator
var _bonuses: Dictionary


func _init(
	mode: StringName, profile: BotProfile, registry: RngRegistry, bonuses: Dictionary
) -> void:
	_mode = mode
	_profile = profile
	_rng = registry.stream(&"test_player_pick")
	_moves_rng = registry.stream(&"test_player_move_picks")
	_bonuses = bonuses


func pick(offered: Array[StringName], wave: int, carry_ref: StringName = &"") -> StringName:
	if offered.is_empty():
		return &""
	for id: StringName in offered:
		if id.begins_with("master_"):
			return id
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
		if kind == &"effect" and ref in [MoveTable.OVERKILL, MoveBonus.OVERKILL_2]:
			var min_wave: float = row.get("min_wave", 3)
			if ref != carry_ref or wave < min_wave:
				continue
			if _profile.move_use < 1.0 and _moves_rng.randf() >= _profile.move_use:
				continue
			return id
		if value > high:
			best = id
			high = value
	return fallback if best == &"" else best
