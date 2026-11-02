class_name QuestLine
extends RefCounted
## One gtai.quest/1 line (PoF types.ts QuestLine) as the runtime holds it. A line with `when`
## conditions is a bark: armed for the whole active quest, it fires once, on the first tick all
## of its conditions hold. The words are reached through `key` (LOC-01); `text` is the package's
## English, the `en` source until the PO pipeline extracts it (QuestText).

var id: String = ""
var speaker: String = ""
var text: String = ""
var key: StringName = &""
var purposes: Array[String] = []
var conditions: Array[QuestCondition] = []


func is_bark() -> bool:
	return not conditions.is_empty()


## The display time: typed out at line_type_cps, then held line_hold_s, clamped to the min/max.
func duration_ticks(rules: QuestRules) -> int:
	var seconds: float = text.length() / rules.tuning["line_type_cps"] + rules.tuning["line_hold_s"]
	seconds = clampf(seconds, rules.tuning["line_min_s"], rules.tuning["line_max_s"])
	return rules.seconds_to_ticks(seconds)


## Characters of the text on screen `ticks` after the line started (the typewriter).
func typed_chars(ticks: int, rules: QuestRules) -> int:
	var shown: float = ticks * SimClock.TICK_DT * rules.tuning["line_type_cps"]
	return mini(floori(shown + SimClock.EPSILON), text.length())


func holds(soul: String, madness: String, heat: int) -> bool:
	for c: QuestCondition in conditions:
		if not c.holds(soul, madness, heat):
			return false
	return true


func holds_in(world: QuestWorld) -> bool:
	for c: QuestCondition in conditions:
		if not c.holds_in(world):
			return false
	return true
