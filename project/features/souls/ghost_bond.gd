class_name GhostBond
extends RefCounted
## Run-local progress. A release credits each kill and each successful stun once.

var enabled: bool
var master_at: float
var _per_kill: float
var _per_stun: float
var _values: Dictionary[StringName, float] = {}
var _recent: Array[StringName] = []
var _mastered: Array[StringName] = []


func _init(table: GhostFormTable) -> void:
	enabled = table.bond_enabled
	master_at = table.master_at
	_per_kill = table.per_kill
	_per_stun = table.per_stun
	for id: StringName in table.forms:
		_values[id] = 0.0


func record(form: StringName, kills: int, stuns: int) -> void:
	if not enabled or not _values.has(form):
		return
	_recent.erase(form)
	_recent.append(form)
	_values[form] = minf(master_at, value(form) + kills * _per_kill + stuns * _per_stun)


func value(form: StringName) -> float:
	return _values.get(form, 0.0)


func snapshot() -> Dictionary[StringName, float]:
	return _values.duplicate()


func ready(form: StringName) -> bool:
	return enabled and _values.has(form) and value(form) >= master_at and not mastered(form)


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
