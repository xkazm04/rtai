class_name QuestVerb
extends RefCounted
## One row of quest_rules.json `verbs`: an objective verb, the handler that plays it, whether
## the beat must name a target tag, a location marker and a world encounter at that location,
## and whether the objective also waits for the beat's lines (a meeting is its conversation).

var id: String = ""
var handler: QuestRules.Handler = QuestRules.Handler.REACH
var needs_target: bool = false
var needs_location: bool = false
var needs_encounter: bool = false
var waits_for_lines: bool = false


## null when the row is malformed.
static func from_row(row: Variant) -> QuestVerb:
	if not row is Dictionary:
		return null
	var d: Dictionary = row
	var handler_name: Variant = d.get("handler")
	if not d.get("id") is String or not QuestRules.HANDLERS.has(handler_name):
		return null
	for flag: String in ["needs_target", "needs_location", "needs_encounter", "waits_for_lines"]:
		if not d.get(flag) is bool:
			return null
	var verb: QuestVerb = QuestVerb.new()
	verb.id = str(d["id"])
	verb.handler = QuestRules.HANDLERS[handler_name]
	verb.needs_target = d["needs_target"]
	verb.needs_location = d["needs_location"]
	verb.needs_encounter = d["needs_encounter"]
	verb.waits_for_lines = d["waits_for_lines"]
	return verb


## Vehicle targets resolve in the places table's vehicles, every other target in its actors.
func target_is_vehicle() -> bool:
	return handler == QuestRules.Handler.ENTER_VEHICLE
