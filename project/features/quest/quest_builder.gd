class_name QuestBuilder
extends RefCounted
## Turns a gtai.quest/1 dictionary that QuestValidator passed into the typed QuestPackage.
## Only called on a valid package, so it trusts the shapes the validator checked.


static func build(raw: Dictionary, rules: QuestRules) -> QuestPackage:
	var pkg: QuestPackage = QuestPackage.new()
	var id: String = raw["id"]
	pkg.id = StringName(id)
	pkg.title = raw["title"]
	pkg.act = raw["act"]
	for c: Dictionary in _dicts(raw["characters"]):
		pkg.characters[str(c["id"])] = str(c["name"])
	for l: Dictionary in _dicts(raw["lines"]):
		var line: QuestLine = _line(l, id, rules)
		pkg.lines[line.id] = line
		pkg.line_order.append(line.id)
	for b: Dictionary in _dicts(raw["beats"]):
		pkg.beats.append(_beat(b, id, rules))
	var reward: Dictionary = raw["reward"]
	pkg.reward_cash = roundi(QuestJson.num(reward["cash"], 0.0))
	pkg.unlocks = QuestJson.strings(reward["unlocks"])
	var difficulty: Dictionary = raw["difficulty"]
	_difficulty(pkg, difficulty, rules)
	var story: Dictionary = raw["story"]
	for w: Dictionary in _dicts(story["writes"]):
		pkg.story_writes[str(w["var"])] = w["value"]
	return pkg


static func _line(l: Dictionary, quest_id: String, rules: QuestRules) -> QuestLine:
	var line: QuestLine = QuestLine.new()
	line.id = l["id"]
	line.speaker = l["speaker"]
	line.text = l["text"]
	line.key = QuestText.line_key(quest_id, line.id)
	line.purposes = QuestJson.strings(l["purpose"])
	line.voice_s = VoiceLengths.seconds_for(str(l.get("audio", "")))
	for tag: String in QuestJson.strings(l.get("when", [])):
		line.conditions.append(QuestCondition.parse(tag, rules))
	return line


static func _beat(b: Dictionary, quest_id: String, rules: QuestRules) -> QuestBeat:
	var beat: QuestBeat = QuestBeat.new()
	beat.id = b["id"]
	beat.title = b["title"]
	beat.title_key = QuestText.beat_key(quest_id, beat.id)
	var o: Dictionary = b["objective"]
	beat.verb = o["verb"]
	beat.handler = rules.verbs[beat.verb].handler
	beat.target = str(o.get("target", ""))
	beat.location = str(o.get("location", ""))
	beat.line_ids = QuestJson.strings(b["lineIds"])
	if beat.handler == QuestRules.Handler.TIMER:
		beat.length_ticks = rules.seconds_to_ticks(_timer_seconds(o, beat.target, rules))
	return beat


## objective.durationS (gtai.quest/1) wins over the legacy "<N>s" target, then the default.
static func _timer_seconds(o: Dictionary, target: String, rules: QuestRules) -> float:
	if o.has("durationS"):
		return QuestJson.num(o["durationS"], 0.0)
	var legacy: String = target.trim_suffix("s")
	if target.ends_with("s") and legacy.is_valid_float():
		return legacy.to_float()
	return rules.tuning["survive_default_s"]


static func _difficulty(pkg: QuestPackage, d: Dictionary, rules: QuestRules) -> void:
	pkg.heat_peak = floori(QuestJson.num(d["heatPeak"], 0.0))
	var limit: Variant = d["timeLimitS"]
	if limit != null:
		pkg.time_limit_ticks = rules.seconds_to_ticks(QuestJson.num(limit, 0.0))
	for word: String in QuestJson.strings(d["failStates"]):
		var code: StringName = rules.fail_code(word)
		if code != &"":
			pkg.fail_codes[word] = code


static func _dicts(raw: Variant) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var items: Array = raw
	for item: Variant in items:
		var d: Dictionary = item
		out.append(d)
	return out
