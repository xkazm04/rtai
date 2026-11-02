class_name QuestValidator
extends RefCounted
## The gtai.quest/1 boundary check (DAT-07): every field the runtime reads, against PoF's
## types.ts and against what this runtime can play (QuestRules) in this world (QuestPlaces).
## Never crashes on bad input: each problem becomes a QuestReport line with its JSON path.
## Beat checks live in QuestBeatValidator.

const ACTS: PackedStringArray = ["prologue", "clock-out", "act1", "act2", "act3", "act4", "finale"]
const STATUSES: PackedStringArray = ["planned", "building", "built", "accepted"]
const PURPOSES: PackedStringArray = ["funny", "character", "progression"]
const HEAT_MAX: float = 6.0

var _rules: QuestRules
var _report: QuestReport = QuestReport.new()
var _speakers: Dictionary[String, bool] = {}
var _line_ids: Dictionary[String, bool] = {}
var _bark_ids: Dictionary[String, bool] = {}


func _init(rules: QuestRules) -> void:
	_rules = rules


## Checks `p` (a parsed quest.json) whose folder name is `folder_id`.
func check(p: Dictionary, folder_id: String, places: QuestPlaces) -> QuestReport:
	_header(p, folder_id)
	_characters(_array(p, "characters"))
	var lines: Array = _array(p, "lines")
	for i: int in lines.size():
		_line(lines[i], "lines[%d]" % i)
	var beats: QuestBeatValidator = QuestBeatValidator.new(_rules, places, _report)
	beats.check_all(_array(p, "beats"), _line_ids)
	for line_id: String in _line_ids:
		if not beats.used_line_ids.has(line_id) and not _bark_ids.has(line_id):
			_report.warn("lines.%s" % line_id, "in no beat's lineIds and not a bark: never plays")
	_reward(p.get("reward"))
	_difficulty(p.get("difficulty"))
	_story(p.get("story"))
	return _report


func _header(p: Dictionary, folder_id: String) -> void:
	if p.get("schema") != QuestPackage.SCHEMA:
		_report.error("schema", "expected %s, got %s" % [QuestPackage.SCHEMA, p.get("schema")])
	if p.get("id") != folder_id:
		_report.error("id", "'%s' must equal the folder name '%s'" % [p.get("id"), folder_id])
	if not QuestJson.is_text(p.get("title")):
		_report.error("title", "missing or not a string")
	if not ACTS.has(str(p.get("act"))):
		_report.error("act", "'%s' is not an act (%s)" % [p.get("act"), ", ".join(ACTS)])
	if not STATUSES.has(str(p.get("status"))):
		_report.error(
			"status", "'%s' is not a status (%s)" % [p.get("status"), ", ".join(STATUSES)]
		)


func _characters(chars: Array) -> void:
	for i: int in chars.size():
		var c: Dictionary = _object(chars[i], "characters[%d]" % i)
		if not QuestJson.is_text(c.get("id")) or not QuestJson.is_text(c.get("name")):
			_report.error("characters[%d]" % i, "needs string id and name")
			continue
		_speakers[str(c["id"])] = true


func _line(raw: Variant, at: String) -> void:
	var l: Dictionary = _object(raw, at)
	for key: String in ["id", "speaker", "text"]:
		if not QuestJson.is_text(l.get(key)):
			_report.error("%s.%s" % [at, key], "missing or empty")
	if QuestJson.is_text(l.get("speaker")) and not _speakers.has(str(l["speaker"])):
		_report.error(at + ".speaker", "'%s' is not in characters" % l["speaker"])
	var purposes: Array[String] = QuestJson.strings(l.get("purpose"))
	if purposes.is_empty():
		_report.error(at + ".purpose", "missing or empty (no line is filler)")
	for purpose: String in purposes:
		if not PURPOSES.has(purpose):
			_report.error(at + ".purpose", "unknown '%s' (%s)" % [purpose, ", ".join(PURPOSES)])
	var line_id: String = str(l.get("id", ""))
	if l.has("when"):
		_when(l["when"], at + ".when")
		_bark_ids[line_id] = true
	if _line_ids.has(line_id):
		_report.error(at + ".id", "duplicate '%s'" % line_id)
	_line_ids[line_id] = true


func _when(raw: Variant, at: String) -> void:
	var tags: Array[String] = QuestJson.strings(raw)
	if not raw is Array or tags.is_empty():
		_report.error(at, "must be a non-empty array (omit it for an always-line)")
	for tag: String in tags:
		var c: QuestCondition = QuestCondition.parse(tag, _rules)
		if c.error != "":
			_report.error(at, c.error)


func _reward(raw: Variant) -> void:
	var r: Dictionary = _object(raw, "reward")
	if QuestJson.num(r.get("cash"), -1.0) < 0.0:
		_report.error("reward.cash", "missing or not a number >= 0")
	if not r.get("unlocks") is Array:
		_report.error("reward.unlocks", "missing or not an array")


func _difficulty(raw: Variant) -> void:
	var d: Dictionary = _object(raw, "difficulty")
	var peak: float = QuestJson.num(d.get("heatPeak"), -1.0)
	if peak < 0.0 or peak > HEAT_MAX:
		_report.error("difficulty.heatPeak", "missing or not a number in 0-6")
	var limit: Variant = d.get("timeLimitS", "absent")
	if not (limit == null or QuestJson.num(limit, -1.0) > 0.0):
		_report.error("difficulty.timeLimitS", "must be a number > 0 or null (null = no timer)")
	var words: Array[String] = QuestJson.strings(d.get("failStates"))
	if words.is_empty():
		_report.error("difficulty.failStates", "missing or empty (the contract says non-empty)")
	for word: String in words:
		var code: StringName = _rules.fail_code(word)
		if code == &"":
			_report.warn("difficulty.failStates", "'%s' is unmapped: never detected" % word)
		elif code == &"timer_expired" and limit == null:
			_report.warn("difficulty.failStates", "'%s' needs a timer, timeLimitS is null" % word)


func _story(raw: Variant) -> void:
	var s: Dictionary = _object(raw, "story")
	if not s.get("reads") is Array:
		_report.error("story.reads", "missing or not an array")
	var writes: Array = _array(s, "writes", "story.")
	for i: int in writes.size():
		var w: Dictionary = _object(writes[i], "story.writes[%d]" % i)
		if not QuestJson.is_text(w.get("var")) or not w.has("value"):
			_report.error("story.writes[%d]" % i, "needs a string var and a value")


func _array(p: Dictionary, key: String, prefix: String = "") -> Array:
	if not p.get(key) is Array:
		_report.error(prefix + key, "missing or not an array")
		return []
	var out: Array = p[key]
	return out


func _object(raw: Variant, at: String) -> Dictionary:
	if not raw is Dictionary:
		_report.error(at, "missing or not an object")
		return {}
	var out: Dictionary = raw
	return out
