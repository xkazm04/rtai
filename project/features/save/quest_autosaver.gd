class_name QuestAutosaver
extends RefCounted
## Glue between a running quest and the Save engine: poll() once after each step with the
## runner's beat index; every autosave point that fires gets a snapshot (taken now, on the main
## thread) and goes to `sink` (Save.autosave). The session owns the one call to poll().
##   snapshot: Callable(point: String) -> Dictionary  {"body": Dictionary, "meta": Dictionary}
##   sink:     Callable(point: String, body: Dictionary, meta: Dictionary) -> void

var fired: Array[String] = []
var _edges: AutosaveEdges
var _snapshot: Callable
var _sink: Callable


func _init(
	points: AutosavePoints.Result, beat_ids: Array[String], p_snapshot: Callable, p_sink: Callable
) -> void:
	_edges = AutosaveEdges.new(points, beat_ids)
	_snapshot = p_snapshot
	_sink = p_sink


func poll(beat_index: int, finished: bool) -> void:
	for point: String in _edges.poll(beat_index, finished):
		var snap: Dictionary = _snapshot.call(point)
		var body: Dictionary = snap.get("body", {})
		var meta: Dictionary = snap.get("meta", {})
		_sink.call(point, body, meta)
		fired.append(point)
