class_name QuestBeatValidator
extends RefCounted
## gtai.quest/1 beat checks: a known objective verb, its target and location resolved in the
## world's places, a positive durationS where present, and lineIds that exist in the package.

var used_line_ids: Dictionary[String, bool] = {}
var _rules: QuestRules
var _places: QuestPlaces
var _report: QuestReport


func _init(rules: QuestRules, places: QuestPlaces, report: QuestReport) -> void:
	_rules = rules
	_places = places
	_report = report


func check_all(beats: Array, line_ids: Dictionary[String, bool]) -> void:
	if beats.is_empty():
		_report.error("beats", "a quest needs at least one beat")
	for i: int in beats.size():
		_beat(beats[i], "beats[%d]" % i, line_ids)


func _beat(raw: Variant, at: String, line_ids: Dictionary[String, bool]) -> void:
	if not raw is Dictionary:
		_report.error(at, "not an object")
		return
	var b: Dictionary = raw
	if not QuestJson.is_text(b.get("id")) or not QuestJson.is_text(b.get("title")):
		_report.error(at, "needs string id and title")
	var o: Variant = b.get("objective")
	if o is Dictionary:
		var objective: Dictionary = o
		_objective(objective, at + ".objective")
	else:
		_report.error(at + ".objective", "missing or not an object")
	if not b.get("lineIds") is Array:
		_report.error(at + ".lineIds", "missing or not an array")
		return
	for line_id: String in QuestJson.strings(b["lineIds"]):
		if not line_ids.has(line_id):
			_report.error(at + ".lineIds", "'%s' is not in lines" % line_id)
		used_line_ids[line_id] = true


func _objective(o: Dictionary, at: String) -> void:
	var verb_name: String = str(o.get("verb", ""))
	if not _rules.verbs.has(verb_name):
		var known: PackedStringArray = PackedStringArray(_rules.verbs.keys())
		_report.error(
			at + ".verb", "unknown verb '%s' (handled: %s)" % [verb_name, ", ".join(known)]
		)
		return
	var verb: QuestVerb = _rules.verbs[verb_name]
	if verb.needs_target:
		_target(o.get("target"), verb, at + ".target")
	if verb.needs_location and not _places.markers.has(str(o.get("location", ""))):
		_report.error(at + ".location", "'%s' is not a marker" % o.get("location", ""))
	if o.has("durationS") and QuestJson.num(o["durationS"], 0.0) <= 0.0:
		_report.error(at + ".durationS", "must be a number > 0 (omit it for untimed verbs)")


func _target(raw: Variant, verb: QuestVerb, at: String) -> void:
	if not QuestJson.is_text(raw):
		_report.error(at, "'%s' needs a target tag" % verb.id)
		return
	var tag: String = str(raw)
	if verb.target_is_vehicle() and not _places.vehicles.has(tag):
		_report.error(at, "'%s' is not a vehicle in the places table" % tag)
	elif not verb.target_is_vehicle() and not _places.actors.has(tag):
		_report.error(at, "'%s' is not an actor in the places table" % tag)
