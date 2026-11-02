class_name QuestRules
extends RefCounted
## The quest runtime's own table (DAT-01, DAT-05): res://data/tables/quest_rules.json
## (gtai.quest-rules/2), read once into typed fields: the objective verbs the runtime plays,
## the fail-state words it can detect, the bark vocabulary (state conditions and event tags) and
## the timing. PoF reads the same file to guard what the council emits (docs/data-contracts.md).
## A bad table yields errors() and no rules, never a half-built object.

enum Handler { REACH, ENTER_VEHICLE, KILL, TIMER, ESCORT, EVADE, ANSWER, MEET, FIGHT, SABOTAGE }

const SCHEMA: String = "gtai.quest-rules/2"
const PATH: String = "res://data/tables/quest_rules.json"
const HANDLERS: Dictionary[String, Handler] = {
	"reach": Handler.REACH,
	"enter_vehicle": Handler.ENTER_VEHICLE,
	"kill": Handler.KILL,
	"timer": Handler.TIMER,
	"escort": Handler.ESCORT,
	"evade": Handler.EVADE,
	"answer": Handler.ANSWER,
	"meet": Handler.MEET,
	"fight": Handler.FIGHT,
	"sabotage": Handler.SABOTAGE,
}
const TUNING_KEYS: PackedStringArray = [
	"answer_radius_m",
	"escape_m",
	"survive_default_s",
	"event_window_s",
	"line_type_cps",
	"line_hold_s",
	"line_min_s",
	"line_max_s",
]

static var _default: QuestRules = null

var verbs: Dictionary[String, QuestVerb] = {}
## In table order: the first rule whose every keyword group matches wins.
var fail_rules: Array[QuestFailRule] = []
var souls: Array[String] = []
var madness_bands: Array[String] = []
var weapons: Array[String] = []
## `heat:` test grammar (op, N), from the table's heat condition.
var heat_pattern: String = ""
## Bare bark tag -> the fact QuestFacts records for it (`kill` -> `actor_killed:by_player`).
var event_tags: Dictionary[String, String] = {}
var tuning: Dictionary[String, float] = {}
var _errors: Array[String] = []


## The shipped table, parsed on first use and kept (DAT-05: once).
static func shipped() -> QuestRules:
	if _default == null:
		_default = from_json_text(FileAccess.get_file_as_string(PATH))
	return _default


static func from_json_text(text: String) -> QuestRules:
	var rules: QuestRules = QuestRules.new()
	var raw: Dictionary = QuestJson.parse_object(text)
	if raw.is_empty():
		rules._errors.append("quest_rules: not a JSON object")
		return rules
	rules._read(raw)
	if not rules._errors.is_empty():
		rules.verbs.clear()
		rules.fail_rules.clear()
	return rules


func errors() -> Array[String]:
	return _errors.duplicate()


func ok() -> bool:
	return _errors.is_empty()


## The fail code a failure-state word maps to, or &"" when the runtime cannot detect it.
func fail_code(word: String) -> StringName:
	var text: String = word.to_lower()
	for rule: QuestFailRule in fail_rules:
		if rule.matches(text):
			return rule.code
	return &""


func seconds_to_ticks(seconds: float) -> int:
	return ceili(seconds * SimClock.TICK_RATE - SimClock.EPSILON)


func _read(raw: Dictionary) -> void:
	if raw.get("schema") != SCHEMA:
		_errors.append("quest_rules.schema: expected %s" % SCHEMA)
		return
	_read_verbs(raw.get("verbs"))
	_read_fail_rules(raw.get("fail_rules"))
	_read_conditions(raw.get("conditions"))
	_read_event_tags(raw.get("event_tags"))
	var t: Variant = raw.get("tuning")
	if not t is Dictionary:
		_errors.append("quest_rules.tuning: missing")
		return
	var tun: Dictionary = t
	for key: String in TUNING_KEYS:
		var value: Variant = tun.get(key)
		if not QuestJson.is_num(value):
			_errors.append("quest_rules.tuning.%s: not a number" % key)
			continue
		tuning[key] = QuestJson.num(value, 0.0)


func _read_verbs(raw: Variant) -> void:
	if not raw is Array:
		_errors.append("quest_rules.verbs: missing")
		return
	var rows: Array = raw
	for row: Variant in rows:
		var verb: QuestVerb = QuestVerb.from_row(row)
		if verb == null:
			_errors.append("quest_rules.verbs: bad row %s" % JSON.stringify(row))
			continue
		verbs[verb.id] = verb


func _read_fail_rules(raw: Variant) -> void:
	if not raw is Array:
		_errors.append("quest_rules.fail_rules: missing")
		return
	var rows: Array = raw
	for row: Variant in rows:
		var rule: QuestFailRule = QuestFailRule.from_row(row)
		if rule == null:
			_errors.append("quest_rules.fail_rules: bad row %s" % JSON.stringify(row))
			continue
		fail_rules.append(rule)


func _read_conditions(raw: Variant) -> void:
	for row: Dictionary in _rows(raw, "conditions"):
		var values: Array[String] = QuestJson.strings(row.get("values"))
		match str(row.get("id")):
			"soul":
				souls = values
			"madness":
				madness_bands = values
			"weapon":
				weapons = values
			"heat":
				heat_pattern = str(row.get("pattern", ""))
	if souls.is_empty() or madness_bands.is_empty() or weapons.is_empty() or heat_pattern == "":
		_errors.append(
			"quest_rules.conditions: needs soul, madness, weapon values and a heat pattern"
		)


func _read_event_tags(raw: Variant) -> void:
	for row: Dictionary in _rows(raw, "event_tags"):
		var tag: String = str(row.get("id", ""))
		var fact: String = str(row.get("fact", ""))
		if not QuestFacts.SOURCES.has(fact.get_slice(":", 0)):
			_errors.append("quest_rules.event_tags.%s: no Events source for '%s'" % [tag, fact])
			continue
		event_tags[tag] = fact


func _rows(raw: Variant, key: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if not raw is Array:
		_errors.append("quest_rules.%s: missing" % key)
		return out
	var rows: Array = raw
	for row: Variant in rows:
		if row is Dictionary:
			var d: Dictionary = row
			out.append(d)
		else:
			_errors.append("quest_rules.%s: bad row %s" % [key, JSON.stringify(row)])
	return out
