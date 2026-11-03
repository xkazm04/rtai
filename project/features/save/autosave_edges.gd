class_name AutosaveEdges
extends RefCounted
## Watches a running quest and says which autosave point just fired. Poll it once per tick (or
## after each step) with the runner's current beat index; it reports a point exactly once, at the
## beat edge it is declared on, and the quest's end always (id QUEST_END if undeclared).
## "end" of beat N and "start" of beat N+1 are the same instant; both fire if both are declared.

var _points: AutosavePoints.Result
var _beat_ids: Array[String]
var _index: int = -1
var _ended: bool = false


func _init(points: AutosavePoints.Result, beat_ids: Array[String]) -> void:
	_points = points
	_beat_ids = beat_ids


## Points that fired since the last call, in order. `index` is the active beat's index;
## `finished` is true once the contract has succeeded (the quest end). The first call only
## arms the watcher at the quest's opening beat (the quest start is not an edge).
func poll(index: int, finished: bool) -> Array[String]:
	var fired: Array[String] = []
	if _index < 0:
		_index = index
		return fired
	if index != _index and not _ended:
		_edge(_index, AutosavePoints.AT_END, fired)
		if index >= 0 and index < _beat_ids.size():
			_edge(index, AutosavePoints.AT_START, fired)
		_index = index
	if finished and not _ended:
		_ended = true
		_edge(_index, AutosavePoints.AT_END, fired)
		fired.append(AutosavePoints.QUEST_END)
	return fired


func _edge(index: int, at: String, fired: Array[String]) -> void:
	if index < 0 or index >= _beat_ids.size():
		return
	var p: AutosavePoints.Point = _points.at_edge(_beat_ids[index], at)
	if p != null and not fired.has(p.id):
		fired.append(p.id)
