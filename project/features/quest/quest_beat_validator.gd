class_name QuestBeatValidator
extends RefCounted
## gtai.quest/1 beat checks: a known objective verb, its target and location resolved in the
## world's places (and the place's encounter for fight/sabotage), a positive durationS where
## present, and lineIds that exist in the package. Sums the encounters the beats will run.
## n11 call t-3 (owner, 2026-11-10): verb and location must be strings (no str() coercion), an
## infinite durationS fails, only known line ids count as used, and a beat with any error adds no
## encounter to the sums.

var used_line_ids: Dictionary[String, bool] = {}
var encounter_enemies: int = 0
var encounter_waves: int = 0
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
	var before: int = _report.errors.size()
	var fight: QuestPlaces.Encounter = null
	if not QuestJson.is_text(b.get("id")) or not QuestJson.is_text(b.get("title")):
		_report.error(at, "needs string id and title")
	var o: Variant = b.get("objective")
	if o is Dictionary:
		var objective: Dictionary = o
		fight = _objective(objective, at + ".objective")
	else:
		_report.error(at + ".objective", "missing or not an object")
	if not b.get("lineIds") is Array:
		_report.error(at + ".lineIds", "missing or not an array")
		return
	for line_id: String in QuestJson.strings(b["lineIds"]):
		if line_ids.has(line_id):
			used_line_ids[line_id] = true
		else:
			_report.error(at + ".lineIds", "'%s' is not in lines" % line_id)
	if fight != null and _report.errors.size() == before:
		encounter_enemies += fight.enemies
		encounter_waves += fight.waves


## Checks one objective; returns the encounter it would run (null: none, or not resolvable).
func _objective(o: Dictionary, at: String) -> QuestPlaces.Encounter:
	var verb_name: String = _text(o.get("verb"))
	if not _rules.verbs.has(verb_name):
		var known: PackedStringArray = PackedStringArray(_rules.verbs.keys())
		_report.error(
			at + ".verb", "unknown verb '%s' (handled: %s)" % [verb_name, ", ".join(known)]
		)
		return null
	var verb: QuestVerb = _rules.verbs[verb_name]
	if verb.needs_target:
		_target(o.get("target"), verb, at + ".target")
	var location: String = _text(o.get("location"))
	if verb.needs_location and not _places.markers.has(location):
		_report.error(at + ".location", "'%s' is not a marker" % location)
	var fight: QuestPlaces.Encounter = null
	if verb.needs_encounter:
		if _places.encounters.has(location):
			fight = _places.encounters[location]
		else:
			_report.error(
				at + ".location", "'%s' holds no encounter for '%s'" % [location, verb.id]
			)
	if o.has("durationS"):
		var d: float = QuestJson.num(o["durationS"], 0.0)
		if not (is_finite(d) and d > 0.0):
			_report.error(at + ".durationS", "must be a number > 0 (omit it for untimed verbs)")
	return fight


## A string field's text, or "" for anything that is not a string (a number is not coerced).
static func _text(raw: Variant) -> String:
	return str(raw) if raw is String else ""


func _target(raw: Variant, verb: QuestVerb, at: String) -> void:
	if not QuestJson.is_text(raw):
		_report.error(at, "'%s' needs a target tag" % verb.id)
		return
	var tag: String = str(raw)
	if verb.target_is_vehicle() and not _places.vehicles.has(tag):
		_report.error(at, "'%s' is not a vehicle in the places table" % tag)
	elif not verb.target_is_vehicle() and not _places.actors.has(tag):
		_report.error(at, "'%s' is not an actor in the places table" % tag)
