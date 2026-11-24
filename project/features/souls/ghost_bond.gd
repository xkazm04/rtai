class_name GhostBond
extends RefCounted
## Run-local progress. A release credits each kill, each successful stun and each Kerf cut that
## hurt a boss once.

var enabled: bool
## The general bar; master_at_for(form) is the form's own.
var master_at: float
var _bars: Dictionary[StringName, float] = {}
var _per_kill: float
var _per_stun: float
var _per_boss_cut: float
var _values: Dictionary[StringName, float] = {}
var _recent: Array[StringName] = []
var _mastered: Array[StringName] = []


func _init(table: GhostFormTable) -> void:
	enabled = table.bond_enabled
	master_at = table.master_at
	_bars = table.master_at_by_form.duplicate()
	_per_kill = table.per_kill
	_per_stun = table.per_stun
	_per_boss_cut = table.per_boss_cut
	for id: StringName in table.forms:
		_values[id] = 0.0


func record(form: StringName, kills: int, stuns: int, boss_cuts: int = 0) -> void:
	if not enabled or not _values.has(form):
		return
	_recent.erase(form)
	_recent.append(form)
	var earned: float = kills * _per_kill + stuns * _per_stun + boss_cuts * _per_boss_cut
	_values[form] = minf(master_at_for(form), value(form) + earned)


func master_at_for(form: StringName) -> float:
	return _bars.get(form, master_at)


func value(form: StringName) -> float:
	return _values.get(form, 0.0)


func snapshot() -> Dictionary[StringName, float]:
	return _values.duplicate()


func ready(form: StringName) -> bool:
	return (
		enabled and _values.has(form) and value(form) >= master_at_for(form) and not mastered(form)
	)


func master(form: StringName) -> bool:
	if not ready(form):
		return false
	_mastered.append(form)
	return true


func mastered(form: StringName) -> bool:
	return enabled and _mastered.has(form)


func last_deployed_mastered() -> StringName:
	for i: int in range(_recent.size() - 1, -1, -1):
		if mastered(_recent[i]):
			return _recent[i]
	return &""
