class_name MoveTally
extends RefCounted
## One arena's effective move uses. A wave owns the interval after its opening snapshot.

var _uses: Dictionary[StringName, int] = {}
var _start: Dictionary[StringName, int] = {}


func record(id: StringName) -> void:
	_uses[id] = _uses.get(id, 0) + 1


func begin_wave() -> void:
	_start = _uses.duplicate()


func append_wave(row: Dictionary) -> void:
	var moves: Dictionary[String, int] = {}
	for id: StringName in _uses:
		var uses: int = _uses[id] - _start.get(id, 0)
		if uses > 0:
			moves[String(id)] = uses
	if not moves.is_empty():
		row["moves"] = moves
